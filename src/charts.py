from .data.loading import c
from .data.maps import PROCEDIMENTOS_OUTPUT, PROCEDIMENTOS_ID, NUM_EXP_COLUMNS, EXP_LABELS
import polars as pl
from mizani.breaks import date_breaks
from mizani.formatters import date_format
from plotnine import *

theme_set(theme_bw)

def ts_fmt(df, col = "ind1"):
    ylabel = {
        "ind1": "Casos Novos Físicos (%)",
        "ind5": "Processos Físicos Tramitando (%)"
    }[col]

    ybreaks = ()

    df_fmt = (
        df.group_by(["ultimo_dia"])
        .agg([
            (
                100 * (pl.col(col) * (c.formato == "Físico")).sum() /
                pl.col(col).sum()
            ).alias(ylabel)
        ])
    )

    chart = (
        ggplot(df_fmt) +
        aes(x = "ultimo_dia", y = ylabel) +
        scale_x_datetime(breaks=date_breaks('1 year'), labels=date_format('%Y')) +
        scale_y_continuous(limits=(0, df_fmt[ylabel].max())) +
        geom_line() +
        theme_bw() +
        labs(x = "Data", y = ylabel)
    )

    scales = tuple(chart.scales[1].get_breaks())

    chart = (
        chart + scale_y_continuous(
            limits = (min(scales), max(scales)),
            labels = [str(round(x, 2)).zfill(1).replace(".", ",") for x in scales]
        )
    )

    return chart

def dist_bx_tmp(df):
    return (
        ggplot(df)
        + aes(x = "bx_tmp", y = after_stat('density'))
        + geom_histogram(fill = "#28ac84", bins = 40)
        + geom_density()
        + xlim(0, 8e3)
        + guides(fill=False)
        + labs(x = "Tempo de tramitação (dias)", y = "")
    )

def fmt_tmp(df):
    return (
        ggplot(df)
        + aes(
            x = 'formato', y = 'tramit_tmp',
            fill = 'formato'
        )
        + geom_boxplot()
        + labs(x = "Formato", y = "Tempo de tramitação (dias)")
        + scale_fill_manual(values = ["#484484", "#28ac84"])
        + theme(
            panel_grid_major_x = element_blank(),
            panel_grid_minor_x = element_blank()
        )
        + guides(fill = False)
    )





def grau_tempo(df):
    return (
        ggplot(df)
        + aes(x = "grau", y = "bx_tmp", fill = "grau")
        + geom_boxplot()
        + labs(x = "Grau de Jurisdição", y = "Tempo de tramitação (dias)")
        + scale_fill_manual(values = ["#484484", "#28ac84"])
        + guides(fill=False)
        + theme(
            panel_grid_major_x = element_blank(),
            panel_grid_minor_x = element_blank()
        )
        + ylim(0, 1500)
    )

def originario_tempo(df):
    return (
        ggplot(df)
        + aes(x = "originario", y = "bx_tmp", fill = "originario")
        + geom_boxplot()
        + scale_fill_manual(values = ["#484484", "#28ac84"])
        + guides(fill=False)
        + ylim(0, 1500)
        + theme(
            panel_grid_major_x = element_blank(),
            panel_grid_minor_x = element_blank()
        )
        + labs(x="Originário", y = "Tempo de tramitação (dias)")
    )

def procedimento_tempo(df):
    return (
        ggplot(
            df.with_columns(
                c.procedimento.replace(PROCEDIMENTOS_ID).alias("id_procedimento")
            )
            .sort("id_procedimento")
            .with_columns(
                c.procedimento.replace(PROCEDIMENTOS_OUTPUT)
                .cast(pl.Categorical).cat.set_ordering("physical")
            )
        ) +
        aes(y = "bx_tmp", x = "procedimento", fill = "procedimento") +
        geom_boxplot() +
        labs(y = "Tempo de tramitação (dias)", x="", fill="") +
        theme(
            axis_text_x = element_text(angle = 90, hjust=1),
            panel_grid_major_x = element_blank(),
            panel_grid_minor_x = element_blank(),
            legend_position="bottom"
        ) +
        guides(fill=False)
    )

#def ind_sums(df):
#    ind_sums = (
#        df.select(NUM_EXP_COLUMNS).sum()
#        .transpose(include_header=True)
#        .rename({"column": "Indicador", "column_0": "Valor"})
#        .sort("Valor")
#        .with_columns(
#            c.Indicador
#            .replace(EXP_LABELS)
#            .cast(pl.Categorical)
#            .cat.set_ordering("physical")
#        )
#    )
#
#
#    (ggplot(ind_sums) +
#        aes(x = "Indicador", y = "Valor", fill="Indicador") +
#        geom_col() +
#        geom_text(aes(label="Valor"), position=position_dodge(width=0.9), nudge_y=-100, adjust_text=True) +
#        #xlim(c(0, 1.15 * ind_sums[, max(value)])) +
#        labs(x = "Quantitativo de Processos", y = "Indicador") +
#        guides(fill=False)) #+
#        #scale_fill_viridis_d(begin=0, end=.7) +
#        #theme(
#        #    axis_text_x = element_blank(),
#        #    #axis_ticks_x = element_blank(),
#        #    panel_grid_major_x = element_blank(),
#        #    panel_grid_minor_x = element_blank(),
#        #    panel_grid_major_y = element_blank(),
#        #    panel_grid_minor_y = element_blank()
#        #))