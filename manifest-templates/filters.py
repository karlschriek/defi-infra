import base64

def base64encode(string):
    """
    args:
        string (str)
    returns:
        string (str)
    """
    # b64encode take a byte-like object as input so we need to encode our string(str)
    # b64encode returns a byte-like object so we convert it to a str
    return base64.b64encode(string.encode()).decode()


def base64decode(string):
    """
    args:
        string (str)
    returns:
        string (str)
    """
    return base64.b64decode(string.encode()).decode()


def quote(string):
    return "'{}'".format(string)