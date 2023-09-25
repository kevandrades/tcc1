from src_py.data.loading import read_data, c

# -----------------------------------------------

# 1. Lendo os dados
filename = "data/tbl_fato_R.csv"
df = read_data(filename)

df = (
    df#.filter((c.ultimo_dia == c.ultimo_dia.max()) & (c.ind16_proc != 0))
    .collect()
)