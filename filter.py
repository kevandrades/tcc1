from src.data.loading import pl, c
from src.data.maps import PROCEDIMENTOS_ID
from datetime import date
# -----------------------------------------------

# 1. Lendo os dados
filename = "data/tbl_ft_TRT.csv"

df = pl.read_csv(filename)

df = df.filter(
    (c.ultimo_dia == date(2023, 4, 30)) &
    (c.ind16_proc != 0)
)

df.write_csv("data/ft_filtrado.csv")

df = (
    df.with_columns(pl.col("procedimento").map_dict(PROCEDIMENTOS_ID))
    .to_dummies(columns=["sigla_grau", "formato", "procedimento"])
)

df.write_csv("data/dummied.csv")
