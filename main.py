import polars as pl
from src_py.data.loading import read_data, c
from src_py.charts import (
    ts_fmt, dist_tramit_tmp, grau_tempo,
    fmt_tmp, originario_tempo,
    procedimento_tempo
)
# -----------------------------------------------

# 1. Lendo os dados
#df = read_data("data/tbl_fato_R.csv")

# -----------------------------------------------
# 2. Plotando os gráficos
# _______________________________
# 2.1 Físicos ao longo do tempo
#(ts_fmt_chart := ts_fmt(df))
#
#ts_fmt_chart.save("img/py/ts_fmt.pdf", width = 7, height = 4, limitsize=False)

# _______________________________
# 2.2 Distribuição do tempo de tramitação
#df = (
#    df.filter((c.ultimo_dia == c.ultimo_dia.max()) & (c.ind16_proc != 0))
#    .collect()
#)

df = pl.read_csv("data/ft_filtrado.csv")

(dist_tramit_tmp_chart := dist_tramit_tmp(df))

dist_tramit_tmp_chart.save("img/py/dist_tempo.pdf", width = 7, height = 4, limitsize=False)

# _______________________________
# 2.3 Tempo de tramitação por formato

(fmt_tmp_chart := fmt_tmp(df))

fmt_tmp_chart.save("img/py/formato_tempo.pdf", width = 6, height = 3.75)

# _______________________________
# 2.4 Tempo de tramitação por grau
(grau_tempo_chart := grau_tempo(df))

grau_tempo_chart.save("img/py/grau_tempo.pdf", width = 6, height = 3.75)

# _______________________________
# 2.4 Tempo de tramitação por originário
(originario_tempo_chart := originario_tempo(df))

originario_tempo_chart.save("img/py/originario_tempo.pdf", width = 6, height = 3.75)

# _______________________________
# 2.5 Tempo de tramitação por procedimento
(prcdmnt_tmp_chart := procedimento_tempo(df))

prcdmnt_tmp_chart.save("img/procedimento_tempo.pdf", width = 7, height = 4.6)
