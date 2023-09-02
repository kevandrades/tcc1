from .maps import FT_SELECT_COLUMNS, ID_FORMATO, SIGLA_GRAU, ORIGINARIO, EXP_COLUMNS
from settings.generics import c
import polars as pl

def read_data(filename, columns=FT_SELECT_COLUMNS):
    DTYPES = {
        "ultimo_dia": pl.Date,
        **{ind: pl.Int64 for ind in EXP_COLUMNS}
    }

    df = (
        pl.scan_csv(filename, null_values=["NA"], dtypes=DTYPES)
        .select(columns)
        .filter(
            (c.ramo_justica == "Justiça do Trabalho") &
            (c.id_formato.is_in((1, 2)))
        )
        .with_columns(
            c.originario.map_dict(ORIGINARIO),
            formato = c.id_formato.map_dict(ID_FORMATO),
            grau = c.sigla_grau.map_dict(SIGLA_GRAU),
            *{
                column: pl.col(column).fill_null(0)
                for column in columns
                if "ind" in column and "min" not in column and "max" not in column
            }
        )
        .with_columns(tramit_tmp = c.ind16_dias / c.ind16_proc)
    )

    return df

