import json

class ThreeThingsResponse():
    def __init__(self, data):
        self.data = data

    def write_out(self):
        return json.dumps({"data": self.data})
