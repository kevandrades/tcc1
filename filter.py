from src.data.loading import pl, c, read_data
from src.data.maps import PROCEDIMENTOS_ID, NUM_EXP_COLUMNS
from datetime import date
import re
# -----------------------------------------------

# 1. Lendo os dados
if __name__ == "__main__":
    latin1_filename = "data/tbl_fato_R.csv"
    filename = "data/tbl_fato_TRT.csv"

    df = read_data(filename=filename, latin1_filename=latin1_filename)

    df = df.filter(
        (c.ultimo_dia == date(2024, 1, 31)) & (c.ind16_proc != 0)
    )

    df.write_csv("data/ft_filtrado.csv")

    df = (
        df.filter(
            ~(
                (c.sigla_grau == "G1") & (
                    ((c.formato == "Eletrônico") & c.procedimento.is_in(("Execução extrajudicial não fiscal", "Execução fiscal"))) | 
                    c.procedimento.is_in(("Conhecimento não criminal", "Outros"))
                )
            )
        )
        .with_columns(pl.col("procedimento").replace(PROCEDIMENTOS_ID))
        .to_dummies(columns=["sigla_grau", "formato", "procedimento"], drop_first=True)
    )
    df = df.select((
        *(
            column for column in df.columns
            if re.sub("_[^_]+$", "", column) in {"sigla_grau", "formato", "procedimento"}
        ),
        *NUM_EXP_COLUMNS,
        "bx_tmp",
        "tramit_tmp"
    ))

    df.write_csv("data/infame_filter.csv")