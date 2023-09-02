import polars as pl

class Column:
    def __getattr__(self, item):
        return pl.col(item)

c = Column()