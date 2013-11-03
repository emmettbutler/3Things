import json
from bson.objectid import ObjectId
from datetime import datetime
import hashlib


class JSONEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, ObjectId):
            return str(o)
        if isinstance(o, datetime):
            return str(o)
        return json.JSONEncoder.default(self, o)

class ThreeThingsResponse():
    def __init__(self, data):
        self.data = data

    def write_out(self):
        return JSONEncoder().encode({"data": self.data})


class EncryptionManager():
    def get_hexdigest(self, algo, salt, _hash):
        if algo == 'sha1':
            return hashlib.sha1('%s%s' % (salt, _hash)).hexdigest()
        raise ValueError("No algorithm found for '%s'" % algo)
