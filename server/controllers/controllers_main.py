import tornado.web

class RegistrationHandler(tornado.web.RequestHandler):
    def get(self):
        uname_or_email = self.get_argument("identifier", default="")
        fname = self.get_argument("fname", default="")
        lname = self.get_argument("lname", default="")

        if not uname_or_email or not fname or not lname:
            raise tornado.web.HTTPError(400)

        self._register_user(uname_or_email, fname, lname)

        code = self._generate_confirmation_code(uname_or_email)
        print code
        self.write("success")

    def _register_user(self, identifier, fname, lname):
        db = self.application.dbclient.three_things

        existing_users = db.users.find({'username': identifier})
        if existing_users.count() != 0:
            raise tornado.web.HTTPError(400, 'User with ID %s already exists!', identifier)
        db.users.insert({'username': identifier, 'first_name': fname, 'last_name': lname})

    def _generate_confirmation_code(self, identifier):
        return "123456"
