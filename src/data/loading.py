from .maps import FT_SELECT_COLUMNS, ID_FORMATO, SIGLA_GRAU, ORIGINARIO, NUM_EXP_COLUMNS
from settings.generics import c
import polars as pl

DTYPES = {
    "ultimo_dia": pl.Date,
    **{ind: pl.Int32 for ind in NUM_EXP_COLUMNS}
}

def read_data(filename, columns=FT_SELECT_COLUMNS, dtypes=DTYPES):
    df = (
        pl.read_csv(
            filename, null_values=["NA", ""],
            columns=FT_SELECT_COLUMNS,
            ignore_errors=True, encoding="utf8",
            separator=";", dtypes=dtypes
        )
        .filter(
            (c.ramo_justica == "Justiça do Trabalho") &
            c.id_formato.is_in((1, 2)) &
            ~c.ultimo_dia.is_null()
        )
        .with_columns(
            c.originario.replace(ORIGINARIO),
            formato = c.id_formato.replace(ID_FORMATO),
            grau = c.sigla_grau.replace(SIGLA_GRAU),
            *(pl.col(column).fill_null(0) for column in NUM_EXP_COLUMNS + ('ind1', ))
        )
        .with_columns(
            bx_tmp = c.ind16_dias / c.ind16_proc,
            tramit_tmp = c.ind18_dias / c.ind18_proc
        )
        .select((*columns, "bx_tmp", "tramit_tmp", "formato", "grau"))
    )

    return df