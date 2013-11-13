import tornado.ioloop
import tornado.web
from pymongo import MongoClient

from controllers import controllers_main


def get_app():
    application = tornado.web.Application([
        (r"/register", controllers_main.RegistrationHandler),
        (r"/login", controllers_main.LoginHandler),
        (r"/users", controllers_main.UsersController),
        (r"/users/([^\/]+)", controllers_main.UserController),
        (r"/users/([^\/]+)/friends", controllers_main.UserFriendsController),
        (r"/users/([^\/]+)/friends/([^\/]+)", controllers_main.UserFriendController),
        (r"/users/([^\/]+)/days", controllers_main.UserDaysController),
        (r"/days", controllers_main.DaysController)
    ])
    application.dbclient = MongoClient('localhost', 27017)
    return application

if __name__ == "__main__":
    application = get_app()
    application.listen(8888)
    tornado.ioloop.IOLoop.instance().start()
