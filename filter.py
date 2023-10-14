from src.data.loading import pl, c, DTYPES, read_data
from src.data.maps import PROCEDIMENTOS_ID, EXP_COLUMNS
from datetime import date
# -----------------------------------------------

# 1. Lendo os dados
filename = "data/tbl_fato_R.csv"

df = read_data(filename)

df = pl.read_csv(filename, dtypes=DTYPES, null_values=[""])


df.write_csv("data/tbl_ft_TRT.csv")

df = df.filter(
    (c.ultimo_dia == date(2023, 4, 30)) &
    (c.ind16_proc != 0)
)

df.write_csv("data/ft_filtrado.csv")

df = (
    df.with_columns(pl.col("procedimento").map_dict(PROCEDIMENTOS_ID))
    .to_dummies(columns=["sigla_grau", "formato", "procedimento"], drop_first=True)
    .with_columns([pl.col(column).fill_null(0)
        for column in EXP_COLUMNS
        if "ind" in column and "min" not in column and "max" not in column
    ])
)

df.write_csv("data/dummied.csv")
