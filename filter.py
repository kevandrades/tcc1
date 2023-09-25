from src.data.loading import read_data, c
from datetime import date
# -----------------------------------------------

# 1. Lendo os dados
filename = "data/tbl_fato_R.csv"

df = read_data(filename)

df.write_csv("data/tbl_ft_TRT.csv")

df = df.filter(
    (c.ultimo_dia == date(2023, 4, 30)) &
    (c.ind16_proc != 0)
)

df.write_csv("ft_filtrado.csv")