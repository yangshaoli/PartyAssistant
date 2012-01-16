class myException(Exception):
    def __init__(self, description, *args, **kargs):
        self.description = description
        self.data = {}
        if 'data' in kargs:
            self.data = kargs['data']
        if 'status' in kargs:
            self.status = kargs['status']
        else:
            self.status = "error"
    
