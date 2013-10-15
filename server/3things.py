import tornado.ioloop
import tornado.web

from controllers import controllers_main


application = tornado.web.Application([
    (r"/", controllers_main.MainHandler),
])

if __name__ == "__main__":
    application.listen(8888)
    tornado.ioloop.IOLoop.instance().start()
