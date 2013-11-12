import uuid
import json
import re
import random
import hashlib
import uuid
from datetime import datetime
from bson.objectid import ObjectId

import tornado.web
import tornado.gen
from tornado.gen import Return, coroutine

from utils import ThreeThingsResponse, EncryptionManager


def authenticated(func):
    def inner(self, *args, **kwargs):
        self._authenticate()
        return func(self, *args, **kwargs)
    return inner


class Base3ThingsHandler(tornado.web.RequestHandler):
    def _send_response(self, response):
        self.set_header('Content-Type', "application/json")
        self.write(ThreeThingsResponse(response).write_out())

    def _authenticate(self):
        token = self.request.headers.get("Authorization")
        if not token:
            raise tornado.web.HTTPError(403, "Missing authorization header")
        if token.split()[0] == "bearer":
            db = self.application.dbclient.three_things
            stored_token = db.access_tokens.find({'token': token.split()[1]})
            try:
                stored_token = stored_token.next()
                existing_users = db.users.find({'_id': stored_token['user']})
                try:
                    self.cur_user = existing_users.next()
                except StopIteration:
                    raise tornado.web.HTTPError(401, "Invalid access token")
            except StopIteration:
                raise tornado.web.HTTPError(401, "Invalid access token")

    def _user_response(self, user_id):
        db = self.application.dbclient.three_things
        user = list(db.users.find({'_id': user_id}))[0]
        return {'name': user['name']}


class RegistrationHandler(Base3ThingsHandler):
    @coroutine
    def get(self):
        email = self.get_argument("identifier", default="")
        fname = self.get_argument("name", default="")
        pw = self.get_argument("pw", default="")
        pw_conf = self.get_argument("pwc", default="")

        if not email:
            raise tornado.web.HTTPError(400, "Missing 'identifier' query parameter")
        if not fname:
            raise tornado.web.HTTPError(400, "Missing 'name' query parameter")
        if not self._validate_password(pw, pw_conf):
            raise tornado.web.HTTPError(400, "Passwords do not match")
        if not self._validate_email(email):
            raise tornado.web.HTTPError(400, "Email is invalid")

        user_registered = yield self._register_user(email, fname, pw)
        if not user_registered:
            self.set_status(304)
            self.finish()
            return

        code = self._generate_confirmation_code(email)
        ret = {"conf_code": code, "email": email, "name": fname}
        self.set_status(201)
        self._send_response(ret)

    def _validate_email(self, email):
        if not re.match(r"[^@]+@[^@]+\.[^@]+", email):
            return False
        return True

    def _validate_password(self, pw, pw_conf):
        if not pw or not pw_conf:
            return False
        if pw != pw_conf:
            return False
        return True

    @coroutine
    def _register_user(self, identifier, fname, pw, callback=None):
        db = self.application.dbclient.three_things
        existing_users = db.users.find({'email': identifier})
        if existing_users.count() != 0:
            raise Return(False)
        encrypted = self._set_password(pw)
        db.users.insert({'email': identifier, 'name': fname, 'password': encrypted})
        raise Return(True)

    def _generate_confirmation_code(self, identifier):
        return str(uuid.uuid4()).replace('-', '')[:7]

    def _set_password(self, raw_password):
        algo = 'sha1'
        manager = EncryptionManager()
        salt = manager.get_hexdigest(algo, str(random.random()), str(random.random()))[:5]
        hsh = manager.get_hexdigest(algo, salt, raw_password)
        return '%s$%s$%s' % (algo, salt, hsh)


class LoginHandler(Base3ThingsHandler):
    @coroutine
    def get(self):
        email = self.get_argument("email", default="")
        pw = self.get_argument("pw", default="")

        if not email:
            raise tornado.web.HTTPError(400, "Missing 'email' query parameter")
        if not pw:
            raise tornado.web.HTTPError(400, "Missing 'pw' query parameter")

        user = yield self._login_user(email, pw)
        if not user:
            raise tornado.web.HTTPError(403, "Email or password is incorrect")

        self.set_status(200)
        token = yield self._generate_token(user)
        ret = {"access_token": token, "name": user['name'], "uid": user['_id']}
        self._send_response(ret)

    @coroutine
    def _login_user(self, email, pw):
        db = self.application.dbclient.three_things
        users = db.users.find({'email': email})
        try:
            user = users.next()
            if user['email'] != email:
                raise Return(None)
            if not self._check_password(pw, user['password']):
                raise Return(None)
            raise Return(user)
        except StopIteration:
            raise Return(None)
        raise Return(None)

    @coroutine
    def _generate_token(self, user):
        token = str(uuid.uuid4()).replace('-', '')
        db = self.application.dbclient.three_things
        db.access_tokens.insert({'user': user['_id'], 'token': token})
        raise Return(token)

    def _check_password(self, _raw_password, enc_password):
        """
        Returns a boolean of whether the raw_password was correct. Handles
        encryption formats behind the scenes.
        http://stackoverflow.com/questions/2572099/pythons-safest-method-to-store-and-retrieve-passwords-from-a-database
        """
        algo, salt, hsh = enc_password.split('$')
        manager = EncryptionManager()
        return hsh == manager.get_hexdigest(algo, salt, _raw_password)


class DaysController(Base3ThingsHandler):
    @coroutine
    @authenticated
    def get(self):
        history = yield self._get_friend_feed(self.cur_user['_id'])
        print "Sending friend feed for user %s" % self.cur_user['_id']
        ret = {"history": history}
        self.set_status(200)
        self._send_response(ret)

    @coroutine
    def _get_friend_feed(self, for_user):
        # TODO - only return user posts that are from friends
        db = self.application.dbclient.three_things
        history = list(db.days.find().limit(20).sort("date", -1))
        for item in history:
            item['user'] = self._user_response(item['user'])
        return history


class UserDaysController(Base3ThingsHandler):
    @coroutine
    @authenticated
    def get(self, user_id):
        history = yield self._get_user_history(user_id)
        for item in history:
            item.pop('user')
        ret = {"history": history, "user": user_id}
        self.set_status(200)
        self._send_response(ret)

    @coroutine
    @authenticated
    def post(self, user_id):
        if str(self.cur_user['_id']) != user_id:
            raise tornado.web.HTTPError(403, "Not allowed to post days for other user")

        try:
            print "Decoding request body\n%s" % self.request.body
            sent_day = json.loads(self.request.body)
        except:
            raise tornado.web.HTTPError(400, "Could not decode request body as JSON")

        date = datetime.fromtimestamp(int(sent_day['time'])).date()
        date = datetime.combine(date, datetime.min.time())

        day = yield self._insert_day(date, sent_day)

        self.finish()

    @coroutine
    def _get_user_history(self, user_id):
        db = self.application.dbclient.three_things
        history = db.days.find({'user': ObjectId(user_id)})
        if history.count() == 0:
            raise tornado.web.HTTPError(404, "No history found for user %s" % user_id)
        raise Return(list(history))

    @coroutine
    def _insert_day(self, date, sent_day):
        if len(sent_day['things']) < 3:
            raise tornado.web.HTTPError(400, "Missing some Things")
        updating_day = False

        # if the day being sent isn't today, error
        if datetime.combine(datetime.now(), datetime.min.time()) != date:
            raise tornado.web.HTTPError(400, "Attempting to set a day that isn't today")
        else:
            updating_day = True

        record = {'user': self.cur_user['_id'], 'date': date}

        db = self.application.dbclient.three_things
        existing_day = db.days.find(record)
        try:
            existing_day = existing_day.next()
        except StopIteration:
            pass
        else:
            if updating_day:
                db.days.remove(existing_day)
            else:
                self.set_status(304)
                raise Return(None)

        record = dict(record.items() + sent_day.items())
        days = db.days.insert(record)
        raise Return(days)


class UserController(Base3ThingsHandler):
    def get(self, user_id):
        ret = self._user_response(user_id)
        self.set_status(200)
        self._send_response(ret)


class UserFriendsController(Base3ThingsHandler):
    def get(self, user_id):
        # get all friends
        pass


class UserFriendController(Base3ThingsHandler):
    def put(self, user_id):
        # add friend
        pass

    def delete(self, user_id):
        # remove friend
        pass
