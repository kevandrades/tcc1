from .maps import FT_SELECT_COLUMNS, ID_FORMATO, SIGLA_GRAU, ORIGINARIO, NUM_EXP_COLUMNS
from settings.generics import c
import polars as pl
import pandas as pd

DTYPES = {
    "ultimo_dia": pl.Date,
    **{ind: pl.Int32 for ind in NUM_EXP_COLUMNS}
}

def read_data(filename, columns=FT_SELECT_COLUMNS, dtypes=DTYPES):
    df = pl.concat([
        (
            pl.from_pandas(df)
            .cast(dtypes=dtypes)
            .filter(
                (c.ramo_justica == "Justiça do Trabalho") &
                (c.id_formato.is_in((1, 2)))
            )
            .with_columns(
                c.originario.replace(ORIGINARIO),
                formato = c.id_formato.replace(ID_FORMATO),
                grau = c.sigla_grau.replace(SIGLA_GRAU),
                *(pl.col(column).fill_null(0) for column in NUM_EXP_COLUMNS + ('ind1', ))
            )
            .with_columns(tramit_tmp = c.ind16_dias / c.ind16_proc)
        ) for df in
        pd.read_csv(filename, usecols=columns, na_values=["NA", ""],
            encoding="latin1",
            delimiter=";",
            chunksize=10000
        )
        
    ])

    return df

