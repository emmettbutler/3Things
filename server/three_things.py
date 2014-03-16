import os
from urlparse import urlparse

import tornado.ioloop
import tornado.web
from pymongo import MongoClient

from controllers import controllers_main


def get_app():
    application = tornado.web.Application([
        (r"/fblogin", controllers_main.FacebookHandler),
        (r"/users", controllers_main.UsersController),
        (r"/users/([^\/]+)", controllers_main.UserController),
        (r"/users/([^\/]+)/friends", controllers_main.UserFriendsController),
        (r"/users/([^\/]+)/friends/facebook/search", controllers_main.FacebookFriendFindController),
        (r"/users/([^\/]+)/friends/([^\/]+)", controllers_main.UserFriendController),
        (r"/users/([^\/]+)/days", controllers_main.UserDaysController),
        (r"/users/([^\/]+)/today", controllers_main.UserTodayController),
        (r"/days/([^\/]+)/comments", controllers_main.DayCommentsController),
        (r"/days", controllers_main.DaysController),
        (r"/images/([^\/]+)", controllers_main.ImagesController)
    ])
    PROD_MONGO_URL = "mongodb://heroku:dataz!@paulo.mongohq.com:10084/app19646012"
    MONGO_URL = os.environ.get('MONGOHQ_URL')
    if MONGO_URL:
        MONGO_URL = PROD_MONGO_URL
        print "trying to connect..."
        application.dbclient = MongoClient(MONGO_URL)
        print "connected"
        application.db = getattr(application.dbclient, urlparse(MONGO_URL).path[1:])
        print "got db"
    else:
        application.dbclient = MongoClient("localhost", 27017)
        application.db = getattr(application.dbclient, 'three_things')
    return application

if __name__ == "__main__":
    application = get_app()
    port = int(os.environ.get("PORT", 5000))
    application.listen(port)
    tornado.ioloop.IOLoop.instance().start()
