import uuid
import json
import re
import random
import hashlib
import uuid
from datetime import datetime
from dateutil.parser import parse
from bson.objectid import ObjectId
from bson.binary import Binary
from gridfs import GridFS
import StringIO

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

    @coroutine
    def _generate_token(self, user):
        token = str(uuid.uuid4()).replace('-', '')
        self.application.db.access_tokens.insert({'user': user['_id'], 'token': token})
        raise Return(token)

    def _authenticate(self):
        token = self.request.headers.get("Authorization")
        if not token:
            raise tornado.web.HTTPError(403, "Missing authorization header")
        if token.split()[0] == "bearer":
            stored_token = self.application.db.access_tokens.find({'token': token.split()[1]})
            try:
                stored_token = stored_token.next()
                existing_users = self.application.db.users.find({'_id': stored_token['user']})
                try:
                    self.cur_user = existing_users.next()
                except StopIteration:
                    raise tornado.web.HTTPError(401, "Invalid access token")
            except StopIteration:
                raise tornado.web.HTTPError(401, "Invalid access token")

    def _user_response(self, user_id=None, facebook_id=None):
        if not user_id and not facebook_id:
            raise ValueError("No valid identifier found")
        cond = {'_id': ObjectId(user_id)}
        if facebook_id:
            cond = {'fbid': facebook_id}

        user = list(self.application.db.users.find(cond))
        if len(user) > 0:
            user = user[0]
        else:
            return None
        return {
            'name': user['name'],
                '_id': user['_id'],
                'profileImageID': user['profileImageID'] if 'profileImageID' in user else "",
                'fbid': user['fbid'] if 'fbid' in user else ""
            }


class FacebookHandler(Base3ThingsHandler):
    @coroutine
    def get(self):
        fb_id = self.get_argument("fbid", default="")
        fname = self.get_argument("name", default="")

        existing_users = self.application.db.users.find({'fbid': fb_id})
        # if there is no user, create one
        if existing_users.count() == 0:
            user_registered = yield self._register_user_from_fb(fb_id, fname)
            if not user_registered:
                self.set_status(304)
                self.finish()
                return

        # login the user either way
        user = yield self._login_user_from_fb(fb_id)
        if not user:
            raise tornado.web.HTTPError(403, "Facebook ID %s does not exist in DB" % fb_id)

        self.set_status(200)
        token = yield self._generate_token(user)
        ret = {"access_token": token, "name": user['name'], "uid": user['_id'], "fbid": user['fbid']}
        self._send_response(ret)

    @coroutine
    def _register_user_from_fb(self, identifier, name):
        self.application.db.users.insert({
            'fbid': identifier,
            'name': name,
            'friends': []})
        raise Return(True)

    @coroutine
    def _login_user_from_fb(self, fb_id, image=None):
        users = self.application.db.users.find({'fbid': fb_id})
        try:
            user = users.next()
            if user['fbid'] != fb_id:
                raise Return(None)
            raise Return(user)
        except StopIteration:
            raise Return(None)
        raise Return(None)


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
        existing_users = self.application.db.users.find({'email': identifier})
        if existing_users.count() != 0:
            raise Return(False)
        encrypted = self._set_password(pw)
        self.application.db.users.insert({
            'email': identifier,
            'name': fname,
            'password': encrypted,
            'friends': []})
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
    def post(self):
        login_json = self.request.files['login'][0]['body']
        image = None
        if 'userpic' in self.request.files:
            image = self.request.files['userpic'][0]

        try:
            sent_login = json.loads(login_json)
        except:
            raise tornado.web.HTTPError(400, "Could not decode request body as JSON")

        email = sent_login['email']
        pw = sent_login['pw']

        if not email:
            raise tornado.web.HTTPError(400, "Missing 'email' parameter")
        if not pw:
            raise tornado.web.HTTPError(400, "Missing 'pw' parameter")

        user = yield self._login_user(email, pw, image)
        if not user:
            raise tornado.web.HTTPError(403, "Email or password is incorrect")

        self.set_status(200)
        token = yield self._generate_token(user)
        ret = {"access_token": token, "name": user['name'], "uid": user['_id'], "profileImageID": user['profileImageID']}
        self._send_response(ret)

    @coroutine
    def _login_user(self, email, pw, image=None):
        users = self.application.db.users.find({'email': email})
        try:
            user = users.next()
            if user['email'] != email:
                raise Return(None)
            if not self._check_password(pw, user['password']):
                raise Return(None)
            if image:
                ctype = image["content_type"]
                fs = GridFS(self.application.db)
                image = fs.put(
                    image['body'],
                    content_type=ctype,
                    filename=image["filename"]
                )

                user = dict(user.items() + {'profileImageID': image}.items())
                self.application.db.users.update(
                    {'email': email}, user
                )
            raise Return(user)
        except StopIteration:
            raise Return(None)
        raise Return(None)

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
        user = list(self.application.db.users.find({'_id': for_user}))
        if len(user) == 0:
            raise tornado.web.HTTPError(400, "User %s not found" % for_user)
        friends = user[0]['friends'] if 'friends' in user[0] else []
        cond = {'user': {"$in": friends + [for_user]}}
        history = list(self.application.db.days.find(cond).limit(20).sort("date", -1))
        for item in history:
            item['user'] = self._user_response(item['user'])
        return history


class UserTodayController(Base3ThingsHandler):
    @coroutine
    @authenticated
    def get(self, user_id):
        history = yield self._get_user_today(user_id)
        for item in history:
            item.pop('user')
        ret = {"history": history, "user": user_id}
        self.set_status(200)
        self._send_response(ret)

    @coroutine
    def _get_user_today(self, user_id):
        # TODO - this probably needs to be timezone-aware (must take timezone as a parameter?)
        date = datetime.combine(datetime.utcnow(), datetime.min.time())
        history = self.application.db.days.find({'date': date, 'user': ObjectId(user_id)})
        if history.count() == 0:
            raise tornado.web.HTTPError(404, "No history found for user %s" % user_id)
        raise Return(list(history))


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

        if 'day' not in self.request.files:
            raise tornado.web.HTTPError(400, "Day JSON not found")
        day_json = self.request.files['day'][0]['body']

        try:
            print "Decoding request body\n%s" % day_json
            sent_day = json.loads(day_json)
        except:
            raise tornado.web.HTTPError(400, "Could not decode request body as JSON")

        if "things" not in sent_day:
            raise tornado.web.HTTPError(400, "Invalid JSON document")
        if len(sent_day['things']) != 3:
            raise tornado.web.HTTPError(400, "Invalid JSON document")
        for thing in sent_day['things']:
            if 'text' not in thing:
                raise tornado.web.HTTPError(400, "Invalid JSON document")
        if 'time' not in sent_day:
            raise tornado.web.HTTPError(400, "Invalid JSON document")

        date_time = parse(sent_day['time'])

        images = ["", "", ""]
        if 'thingimage' in self.request.files:
            for image in self.request.files['thingimage']:
                ctype = image["content_type"]
                fs = GridFS(self.application.db)
                images.insert(
                    int(image['filename'].split('.')[0]),
                    fs.put(
                        image['body'],
                        content_type=ctype,
                        filename=image["filename"]
                    )
                )

        day = yield self._insert_day(date_time, sent_day, images)

        self.finish()

    @coroutine
    def _get_user_history(self, user_id):
        history = self.application.db.days.find({'user': ObjectId(user_id)}).sort("date", -1)
        if history.count() == 0:
            raise tornado.web.HTTPError(404, "No history found for user %s" % user_id)
        raise Return(list(history))

    @coroutine
    def _insert_day(self, date, sent_day, images):
        if len(sent_day['things']) < 3:
            raise tornado.web.HTTPError(400, "Missing some Things")
        updating_day = True

        date_only = datetime.combine(date, datetime.min.time())
        date_only.replace(tzinfo=date.tzinfo)

        for i,thing in enumerate(sent_day['things']):
            thing['imageID'] = images[i]

        record = {'user': self.cur_user['_id'], 'date': date_only}
        self.application.db.days.remove(record)
        record['time'] = date

        record = dict(record.items() + sent_day.items())
        days = self.application.db.days.insert(record)
        raise Return(days)


class UsersController(Base3ThingsHandler):
    @coroutine
    def get(self):
        query = self.get_argument("q", default="")
        uid = self.get_argument("uid", default="")
        ret = yield self._user_search(query, uid)
        self.set_status(200)
        self._send_response(ret)

    @coroutine
    def _user_search(self, query, user_id):
        regex = re.compile(query, re.IGNORECASE)
        cond = {"name": regex} if query else {}
        users = list(self.application.db.users.find(cond).limit(20))
        thisuser = list(self.application.db.users.find({"_id": ObjectId(user_id)}))[0]
        ret = []
        for user in users:
            if user['_id'] not in thisuser['friends']:
                ret.append({'name': user['name'], '_id': user['_id']})
        raise Return(ret)


class UserController(Base3ThingsHandler):
    def get(self, user_id):
        ret = self._user_response(user_id)
        self.set_status(200)
        self._send_response(ret)


class UserFriendsController(Base3ThingsHandler):
    @coroutine
    @authenticated
    def get(self, user_id):
        ret = yield self._get_user_friends(user_id)
        self.set_status(200)
        self._send_response(ret)

    @coroutine
    def _get_user_friends(self, user_id):
        user = list(self.application.db.users.find({'_id': ObjectId(user_id)}))
        if len(user) > 0:
            user = user[0]
        else:
            raise tornado.web.HTTPError(404, "User not found")
        user_friends = []
        if 'friends' in user:
            for friend_id in user['friends']:
                user_friends.append(self._user_response(friend_id))
        raise Return({"friends": user_friends})


class UserFriendController(Base3ThingsHandler):
    @coroutine
    @authenticated
    def put(self, user_id, friend_id):
        if str(self.cur_user['_id']) != user_id:
            raise tornado.web.HTTPError(403, "Not allowed to edit friends for other user")

        self._add_friend_for_user(user_id, friend_id)

        self.set_status(200)
        self.finish()

    @coroutine
    @authenticated
    def delete(self, user_id, friend_id):
        if str(self.cur_user['_id']) != user_id:
            raise tornado.web.HTTPError(403, "Not allowed to edit friends for other user")

        self._remove_friend_for_user(user_id, friend_id)

        self.set_status(200)
        self.finish()

    # TODO - friending should be a two-way relationship??
    @coroutine
    def _add_friend_for_user(self, user_id, friend_id):
        user = self.application.db.users.update(
            {'_id': ObjectId(user_id)},
            {"$addToSet": {"friends": ObjectId(friend_id)}}
        )

    @coroutine
    def _remove_friend_for_user(self, user_id, friend_id):
        user = self.application.db.users.update(
            {'_id': ObjectId(user_id)},
            {"$pull": {"friends": ObjectId(friend_id)}}
        )


class FacebookFriendFindController(Base3ThingsHandler):
    @authenticated
    def post(self, user_id):
        friend_ids = self.request.files['jsondata'][0]['body']
        if not friend_ids:
            raise tornado.web.HTTPError(400, "Missing friend_ids parameter")

        friend_ids = json.loads(friend_ids)['friends']

        ret = []
        thisuser = list(self.application.db.users.find({"_id": user_id}))[0]
        for friend in friend_ids:
            user = self._user_response(facebook_id=friend)
            if user and user['_id'] not in thisuser['friends']:
                ret.append(user)
        self.set_status(200)
        self._send_response(ret)


class ImagesController(Base3ThingsHandler):
    @coroutine
    def get(self, _id):
        fs = GridFS(self.application.db)
        img = fs.get(ObjectId(_id))
        self.set_header('Content-Type', img.content_type)
        self.finish(img.read())
