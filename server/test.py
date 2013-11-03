import unittest

import tornado.testing
import tornado.httpclient

from three_things import get_app


class TestServer(tornado.testing.AsyncHTTPTestCase):
    def get_app(self):
        return get_app()

    def setUp(self):
        super(TestServer, self).setUp()

    def test_register(self):
        def handle_no_args(response):
            assert response.code == 400
            self.stop()
        self.http_client.fetch(self.get_url("/register"), handle_no_args)
        self.wait()
