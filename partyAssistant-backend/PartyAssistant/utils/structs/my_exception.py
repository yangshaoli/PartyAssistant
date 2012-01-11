class myException(Exception):
    def __init__(self, description, *args):
        self.description = description
        self.data = {}
        if 'data' in args:
            self.data = args['data']
        if 'status' in args:
            self.status = args['status']
        else:
            self.status = "error"
    
