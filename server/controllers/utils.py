import json
import hashlib

class ThreeThingsResponse():
    def __init__(self, data):
        self.data = data

    def write_out(self):
        return json.dumps({"data": self.data})


class EncryptionManager():
    def get_hexdigest(self, algo, salt, _hash):
        if algo == 'sha1':
            return hashlib.sha1('%s%s' % (salt, _hash)).hexdigest()
        raise ValueError("No algorithm found for '%s'" % algo)
