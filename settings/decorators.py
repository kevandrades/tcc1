def operate_lazily(fun):
    def wrapper(df):
        return fun(df.lazy()).collect()
    return wrapper