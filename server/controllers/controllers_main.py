import uuid
import json

import tornado.web

from utils import ThreeThingsResponse


class RegistrationHandler(tornado.web.RequestHandler):
    def get(self):
        uname_or_email = self.get_argument("identifier", default="")
        fname = self.get_argument("name", default="")

        if not uname_or_email:
            raise tornado.web.HTTPError(400, "Missing 'identifier' query parameter")
        if not fname:
            raise tornado.web.HTTPError(400, "Missing 'name' query parameter")

        if not self._register_user(uname_or_email, fname):
            self.set_status(304)
            self.finish()
            return

        code = self._generate_confirmation_code(uname_or_email)
        ret = {"conf_code": code, "uid": uname_or_email, "name": fname}
        self.write(ThreeThingsResponse(ret).write_out())

    def _register_user(self, identifier, fname):
        db = self.application.dbclient.three_things

        existing_users = db.users.find({'username': identifier})
        if existing_users.count() != 0:
            return False
        db.users.insert({'username': identifier, 'first_name': fname})
        return True

    def _generate_confirmation_code(self, identifier):
        return str(uuid.uuid4()).replace('-', '')[:7]
