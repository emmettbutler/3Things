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

    def _create_temp_user(self, identifier, callback):
        def handle(response):
            callback(response)
            self.stop()
        pw = "test"
        params = {'identifier': identifier,
                  'name': "emmett butler", "pw": pw, "pwc": pw}
        self.http_client.fetch(
            self.get_url("/register?" + urllib.urlencode(params)),
            handle
        )

    def test_new_user(self):
        identifier = "emmett.butler321@gmail.com"
        def handle_new_user(response):
            assert response.code == 201
            self.stop()
        app = self.get_app()
        db = app.dbclient.three_things
        db.users.remove({'email': identifier})
        self._create_temp_user(identifier, handle_new_user)
        self.wait()

    def _test_login(self, pw, callback):
        def handle(response):
            callback(response)
            self.stop()
        identifier = "test@test.com"
        def do_nothing(response):
            self.stop()
        self._create_temp_user(identifier, do_nothing)
        self.http_client.fetch(
            self.get_url("/login?") + urllib.urlencode(
                {'email': identifier, 'pw': pw}
            ),
            handle
        )
        self.wait()

    def test_login(self):
        def handle_login(response):
            assert response.code == 200, "Login should return a 200"
            assert 'access_token' in json.loads(response.body)['data'], "Login should return an access token"
        self._test_login("test", handle_login)

    def _get_json(self, url, callback):
        def handle(response):
            assert response.code == 200
            callback(json.loads(response.body))
            self.stop()
        self.http_client.fetch(
            url,
            # this token belongs to one of the more permanent test users
            #headers={"Authorization": "bearer 63cffb835612406bbf6b93de1f6d1536"},
            callback=handle
        )
        self.wait()

    def test_bad_login(self):
        def handle_login(response):
            assert response.code == 403, "Bad login should return a 403"
        self._test_login("testr", handle_login)

    def test_get_users(self):
        def handle_users(response):
            assert len(response['data']) > 0
        self._get_json(self.get_url("/users"), handle_users)
