import polars as pl
import pandas as pd
from src.data.loading import read_data, c, DTYPES, FT_SELECT_COLUMNS
from src.charts import (
    ts_fmt, dist_tramit_tmp, grau_tempo,
    fmt_tmp, originario_tempo,
    procedimento_tempo
)
# -----------------------------------------------

# 1. Lendo os dados
#df = pl.read_csv(
#    "data/tbl_ft_TRT.csv",
#    null_values=["NA"],
#    ignore_errors = True, encoding="utf-8",
#    separator=",", dtypes=DTYPES
#)#

## -----------------------------------------------
## 2. Plotando os gráficos
## _______________________________
## 2.1 Físicos ao longo do tempo
#ts_fmt(df).save("img/py/ts_fmt.pdf", width = 7, height = 4, limitsize=False)

# _______________________________
# 2.2 Distribuição do tempo de tramitação
#df = (
#    df.filter((c.ultimo_dia == c.ultimo_dia.max()) & (c.ind16_proc != 0))
#    .collect()
#)

df = pl.read_csv("data/ft_filtrado.csv")

dist_tramit_tmp(df).save("img/py/dist_tempo.pdf", width = 7, height = 4, limitsize=False)

# _______________________________
# 2.3 Tempo de tramitação por formato

fmt_tmp(df).save("img/py/formato_tempo.pdf", width = 6, height = 3.75)

# _______________________________
# 2.4 Tempo de tramitação por grau
grau_tempo(df).save("img/py/grau_tempo.pdf", width = 6, height = 3.75)

# _______________________________
# 2.4 Tempo de tramitação por originário
originario_tempo(df).save("img/py/originario_tempo.pdf", width = 6, height = 3.75)

# _______________________________
# 2.5 Tempo de tramitação por procedimento
procedimento_tempo(df).save("img/py/procedimento_tempo.pdf", width = 7, height = 4.6)
