def validate_string(s, variable_name=""):
    assert isinstance(s, str), "{} not a string".format(variable_name)
    assert s != "", "{} is empty".format(variable_name)
    return s


def validate_int(i, variable_name=""):
    assert isinstance(i, int), "{} not an int".format(variable_name)
    return i


def validate_double(d, variable_name=""):
    assert isinstance(d, float), "{} not a double".format(variable_name)
    return d


def validate_bool(b, variable_name=""):
    assert isinstance(b, bool), "{} not a bool".format(variable_name)
    return b


def validate_list(l, variable_name=""):
    assert isinstance(l, list), "{} not a list".format(variable_name)
    return l


def validate_hexcolor(c, variable_name=""):
    assert isinstance(c, str), "{} not a color".format(variable_name)
    assert c.startswith("#")
    assert len(c) == 7
    return c
