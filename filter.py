from src.data.loading import pl, c, DTYPES, read_data
from src.data.maps import PROCEDIMENTOS_ID, NUM_EXP_COLUMNS, EXP_COLUMNS
from datetime import date
# -----------------------------------------------

# 1. Lendo os dados
filename = "data/tbl_fato_R.csv"

df = read_data(filename)

df.write_csv("data/tbl_ft_TRT.csv")

df = df.filter(
    (c.ultimo_dia == date(2024, 1, 31)) &
    (c.ind16_proc != 0)
)

df.write_csv("data/ft_filtrado.csv")


infame_filter = (
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
infame_filter = infame_filter.select((
    *(
        column for column in infame_filter.columns
        if column.split("_")[0] in {"sigla", "formato", "procedimento"}
    ),
    *NUM_EXP_COLUMNS,
    "tramit_tmp"
))

infame_filter.write_csv("data/infame_filter.csv")


df = (
    df.with_columns(pl.col("procedimento").replace(PROCEDIMENTOS_ID))
    .to_dummies(columns=["sigla_grau", "formato", "procedimento"], drop_first=True)
)

df.write_csv("data/dummied.csv")
