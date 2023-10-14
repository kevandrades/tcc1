from settings.decorators import operate_lazily
from src.data.loading import c
from src.data.maps import COURT_STATES
import polars as pl
import scipy.stats as st

@operate_lazily
def pend_fisicos_eletronicos(df):
    return (
       df.groupby("formato")
       .agg(pend = c.ind2.sum())
       .with_columns(pend_pct = 100 * c.pend / c.pend.sum())
    )

@operate_lazily
def qtd_varas(df):
   tbl = (
        df.groupby("sigla_tribunal")
        .agg(qtd = c.id_orgao_julgador.n_unique())
        .sort(-c.qtd)
        .with_columns([
            ((100 * c.qtd / c.qtd.sum())
            .round(2)
            .cast(pl.Utf8)),
            c.sigla_tribunal.apply(lambda sigla: COURT_STATES[sigla]).alias("Estado")
        ])
   )

   tbl = pl.concat([
        tbl, (
            tbl.agg(c.qtd.sum())
            .with_columns(
                sigla_tribunal = pl.lit("Total"),
                Estado = pl.lit("Nacional"),
                pct = pl.lit(100)
            )
        )
    ])

   return tbl

@operate_lazily
def indep_orig_grau(df):
    orig_grau = (
        df.pivot(
            values="ind2", index="grau",
            columns="originario",
            aggregate_function="sum"
        )
        .with_columns((1000 * c.Sim / (c.Sim + c.Não)).alias("originario_pml"))
        .with_columns((1000 - c.originario_pct).alias("recursal_pct"))
    )

    return orig_grau



    #chisq.test(as.matrix(as.data.table(originario_grau)[, .(Originário, Recursal)]))


def normality_test(column):
    results = []

    for _ in range(10):
        results.append(
            st.shapiro(column.sample(100)).pvalue
        )
    
    return max(results)