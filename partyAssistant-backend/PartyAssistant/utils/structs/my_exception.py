class myException(Exception):
    def __init__(self, description, *args):
        self.description = description
        if 'status' in args:
            self.status = args['status']
        else:
            self.status = "error"
    