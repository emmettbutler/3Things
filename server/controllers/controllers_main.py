import uuid
import json
import re
import random
import hashlib

import tornado.web

from utils import ThreeThingsResponse, EncryptionManager


class Base3ThingsHandler(tornado.web.RequestHandler):
    def _send_response(self, response):
        self.set_header('Content-Type', "application/json")
        self.write(ThreeThingsResponse(response).write_out())


class RegistrationHandler(Base3ThingsHandler):
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

        if not self._register_user(email, fname, pw):
            self.set_status(304)
            self.finish()
            return

        code = self._generate_confirmation_code(email)
        ret = {"conf_code": code, "uid": email, "name": fname}
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

    def _register_user(self, identifier, fname, pw):
        db = self.application.dbclient.three_things
        existing_users = db.users.find({'email': identifier})
        if existing_users.count() != 0:
            return False
        encrypted = self._set_password(pw)
        db.users.insert({'email': identifier, 'name': fname, 'password': encrypted})
        return True

    def _generate_confirmation_code(self, identifier):
        return str(uuid.uuid4()).replace('-', '')[:7]

    def _set_password(self, raw_password):
        algo = 'sha1'
        manager = EncryptionManager()
        salt = manager.get_hexdigest(algo, str(random.random()), str(random.random()))[:5]
        hsh = manager.get_hexdigest(algo, salt, raw_password)
        return '%s$%s$%s' % (algo, salt, hsh)


class LoginHandler(Base3ThingsHandler):
    def get(self):
        email = self.get_argument("email", default="")
        pw = self.get_argument("pw", default="")

        if not email:
            raise tornado.web.HTTPError(400, "Missing 'email' query parameter")
        if not pw:
            raise tornado.web.HTTPError(400, "Missing 'pw' query parameter")

        if not self._login_user(email, pw):
            raise tornado.web.HTTPError(403, "Email or password is incorrect")

        self.set_status(200)
        ret = {"access_token": "6969696969"}
        self._send_response(ret)

    def _login_user(self, email, pw):
        db = self.application.dbclient.three_things
        users = db.users.find({'email': email})
        try:
            user = users.next()
            if user['email'] != email:
                return False
            if not self._check_password(pw, user['password']):
                return False
            return True
        except StopIteration:
            return False
        return False

    def _check_password(self, _raw_password, enc_password):
        """
        Returns a boolean of whether the raw_password was correct. Handles
        encryption formats behind the scenes.
        http://stackoverflow.com/questions/2572099/pythons-safest-method-to-store-and-retrieve-passwords-from-a-database
        """
        algo, salt, hsh = enc_password.split('$')
        manager = EncryptionManager()
        return hsh == manager.get_hexdigest(algo, salt, _raw_password)


class DayController(Base3ThingsHandler):
    def post(self):
        sent_day = self.get_argument("day", "")
        sent_day = json.loads(sent_day)

        if not sent_day:
            raise tornado.web.HTTPError(400, "Missing 'day' parameter")

        self.finish()
