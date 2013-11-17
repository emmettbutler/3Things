import unittest
import urllib
import json
from bson.objectid import ObjectId
import datetime
import time

import tornado.testing
import tornado.httpclient
from tornado.httpclient import HTTPRequest

from three_things import get_app

TEST_EXISTING_USER = "527ab4f333a3a1233d9f7dc3"
TEST_FRIEND = "5283ccc233a3a11018085cd9"
AUTH_HEADER = {"Authorization": "bearer 63cffb835612406bbf6b93de1f6d1536"}


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
            headers=AUTH_HEADER,
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

    def test_get_user(self):
        def handle_user(response):
            assert '_id' in response['data']
        self._get_json(self.get_url("/users/%s" % TEST_EXISTING_USER), handle_user)

    def test_user_friends(self):
        def handle_user_friends(response):
            assert len(response['data']['friends']) > 0
        self._get_json(self.get_url("/users/%s/friends" % TEST_EXISTING_USER), handle_user_friends)

    def test_add_remove_friend(self):
        app = self.get_app()
        db = app.dbclient.three_things
        def handle_friend(response):
            user = list(db.users.find(
                {'_id': ObjectId(TEST_EXISTING_USER), 'friends': ObjectId(TEST_FRIEND)}
            ))
            assert len(user) > 0
            self.stop()
        url = self.get_url("/users/%s/friends/%s" % (TEST_EXISTING_USER, TEST_FRIEND))
        request = HTTPRequest(url, method="PUT", headers=AUTH_HEADER, body="")
        self.http_client.fetch(request, callback=handle_friend)
        self.wait()

        def handle_unfriend(response):
            user = list(db.users.find(
                {'_id': ObjectId(TEST_EXISTING_USER), 'friends': ObjectId(TEST_FRIEND)}
            ))
            assert len(user) == 0
            self.stop()
        url = self.get_url("/users/%s/friends/%s" % (TEST_EXISTING_USER, TEST_FRIEND))
        request = HTTPRequest(url, method="DELETE", headers=AUTH_HEADER)
        self.http_client.fetch(request, callback=handle_unfriend)
        self.wait()

    def test_user_days(self):
        def handle_get(response):
            assert len(response['data']['history']) > 0
            assert response['data']['user'] == TEST_EXISTING_USER
        self._get_json(self.get_url("/users/%s/days" % TEST_EXISTING_USER), handle_get)

        def handle_post(response):
            assert response.code == 200
            app = self.get_app()
            db = app.dbclient.three_things
            day = list(db.days.find(
                {"user": ObjectId(TEST_EXISTING_USER), "things":{"text": "testing"}}
            ))
            assert len(day) == 1
            self.stop()
        url = self.get_url("/users/%s/days" % (TEST_EXISTING_USER))
        dtime = datetime.datetime.now()
        dtime = time.mktime(dtime.timetuple())
        day = {"time": dtime, "things": [{"text": "testing"}, {"text": "some more"}, {"text": "also"}]}
        request = HTTPRequest(url, method="POST", headers=AUTH_HEADER, body=json.dumps(day))
        self.http_client.fetch(request, callback=handle_post)
        self.wait()

        def handle_wrong_user(response):
            assert response.code == 403
            self.stop()
        url = self.get_url("/users/%s/days" % ("1"))
        request = HTTPRequest(url, method="POST", headers=AUTH_HEADER, body=json.dumps(day))
        self.http_client.fetch(request, callback=handle_wrong_user)
        self.wait()
