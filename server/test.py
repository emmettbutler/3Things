import unittest
import urllib
import json

import tornado.testing
import tornado.httpclient

from three_things import get_app


class TestServer(tornado.testing.AsyncHTTPTestCase):
    def get_app(self):
        return get_app()

    def setUp(self):
        super(TestServer, self).setUp()

    def test_register_no_args(self):
        def handle_no_args(response):
            assert response.code == 400
            self.stop()
        self.http_client.fetch(self.get_url("/register"), handle_no_args)
        self.wait()

    def test_new_user(self):
        identifier = "emmett.butler321@gmail.com"
        def handle_new_user(response):
            assert response.code == 201
            app = self.get_app()
            db = app.dbclient.three_things
            db.users.remove({'email': identifier})
            self.stop()
        params = {'identifier': identifier,
                  'name': "emmett butler", "pw": "test", "pwc": "test"}
        self.http_client.fetch(
            self.get_url("/register?" + urllib.urlencode(params)),
            handle_new_user
        )
        self.wait()

    def _test_login(self, pw, callback):
        def handle(response):
            callback(response)
            self.stop()
        self.http_client.fetch(
            self.get_url("/login?") + urllib.urlencode(
                {'email': 'emmett.butler612@gmail.co', 'pw': pw}
            ),
            handle
        )
        self.wait()

    def test_login(self):
        def handle_login(response):
            assert response.code == 200, "Login should return a 200"
            assert 'access_token' in json.loads(response.body)['data'], "Login should return an access token"
        self._test_login("butts", handle_login)

    def test_bad_login(self):
        def handle_login(response):
            assert response.code == 403, "Bad login should return a 403"
        self._test_login("wrong", handle_login)
