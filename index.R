source("srcr/maps.R")
pacman::p_load(data.table, tidyverse, magrittr, viridis, glue, xtable, gridExtra)
theme_set(theme_bw())
ft <- fread("data/tbl_ft_TRT.csv")

ft[, procedimento := factor(procedimento,
    levels=c(
      "Conhecimento criminal", "Conhecimento não criminal",
      "Execução extrajudicial não fiscal", "Execução fiscal",
      "Execução judicial", "Pré-processual", "Outros"
    )
  )
]
temporal_cn <- ft %>%
  group_by(ultimo_dia) %>%
  summarise(
    pct_fisicos = (
      100 * sum(ind1 * (formato == "Físico")) / sum(ind1)
    ),
    sum_fisicos = sum(ind1 * (formato == "Físico"))
  ) %>%
  as.data.table()

ggplot(temporal_cn) +
  aes(x = ultimo_dia, y = pct_fisicos) +
  scale_y_continuous(
    labels = c("0,00", "0,02", "0,04", "0,06")
  ) +
  geom_line() +
  theme_bw() +
  labs(x = "Data", y = "Casos Novos Físicos (%)")
ggsave("img/pct_fisicos_tempo.pdf", scale=.9, width = 7, height = 4, limitsize=FALSE)

ft <- fread("data/ft_filtrado.csv")

pend_fisicos_eletronicos <- ft %>%
  filter(formato != "Indisponível") %>%
  group_by(formato) %>%
  summarise(tramit = sum(ind5, na.rm=T)) %>%
  mutate(
    tramit_pct = 100 * tramit / sum(tramit, na.rm=T),
  ) %>%
  as.data.table()

qtd_varas <- ft %>%
  group_by(sigla_tribunal) %>%
  summarise(qtd = n_distinct(id_orgao_julgador)) %>%
  arrange(-qtd) %>%
  mutate(
    pct = (100 * qtd / sum(qtd)) %>%
      round(2) %>%
      paste0("%") %>%
      str_replace("\\.", ","),
    Estado = courts_states[sigla_tribunal]
  ) %>%
  as.data.table()

qtd_varas[, .(sigla_tribunal, Estado, qtd, pct)] %>%
  xtable::xtable()

qtd_varas[, sum(qtd)]

tempo <- ft[, .(tempo = bx_tmp)][!is.na(tempo)]

resumo <- tempo %>%
  summary() %>%
  as.data.frame() %>%
  rbind(data.frame(Var2 = ))

set.seed(299792458)
normality_tests <- sapply(
  1:10, function(index) ft[, bx_tmp] %>%
    sample(size=1e3, replace=FALSE) %>%
    shapiro.test() %$% p.value
  )


ggplot(ft,
    mapping = aes(
      x = bx_tmp,
      y = after_stat(density),
      fill = 1
    )
  ) +
  geom_histogram(color=1, bins=40) +
  geom_density(lwd = .9) +
  scale_fill_viridis() +
  xlim(0, 8e3) +
  guides(fill=FALSE) +
  labs(
    x = "Tempo de tramitação (dias)",
    y = ""
  )
ggsave("img/dist_tempo.pdf", width = 7, height = 4, limitsize=FALSE)


# selecionando apenas formatos ou físico ou eletrônico

ggplot(ft[formato!="Indisponível"]) +
  aes(
    x = formato, y = bx_tmp,
    fill = formato
  ) +
  geom_boxplot() +
  labs(x = "Formato", y = "Tempo de tramitação (dias)") +
  scale_fill_viridis(discrete=TRUE, begin = .2, end=.6) +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  ) +
  guides(fill=FALSE)
ggsave("img/formato_tempo.pdf", width = 6, height = 3.75)

ggplot(ft) +
  aes(
    x = c("G1" = "Primeiro Grau", "G2" = "Segundo Grau")[sigla_grau],
    y = bx_tmp,
    fill = sigla_grau
  ) +
  geom_boxplot() +
  labs(x = "Grau de Jurisdição", y = "Tempo de tramitação (dias)") +
  scale_fill_viridis(discrete=TRUE, begin = .2, end=.6) +
  guides(fill=FALSE) +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  ) +
  ylim(c(0, 1500))
ggsave("img/grau_tempo.pdf", width = 6, height = 3.75)

ggplot(ft) +
  aes(
    x = factor(originario, levels = c("Sim", "Não")), y = bx_tmp,
    fill=originario
  ) +
  geom_boxplot() +
  scale_fill_viridis(discrete=TRUE, begin = .6, end=.2) +
  guides(fill=FALSE) +
  ylim(c(0, 1500)) +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  )+
  labs(x="Originário", y = "Tempo de tramitação (dias)")
ggsave("img/originario.pdf", width = 6, height = 3.75)


originario_grau <- ft[, sum(ind2, na.rm=T), by=.(sigla_grau, originario)] %>%
  pivot_wider(names_from = originario, values_from = V1) %>%
  mutate(
    originario_pct = 1000 * Sim / (Sim + Não),
    recursal_pct = 1000 - originario_pct
  )

originario_grau %>%
  mutate(
    Originário = paste(Sim, " (", round(originario_pct, 2), "‰)", sep=""),
    Recursal = paste(Não, " (", round(recursal_pct, 2), "‰)", sep="")
  ) %>%
  select(Grau = sigla_grau, Sim, Não) %>%
  as.data.table() %>%
  xtable()

chisq.test(as.matrix(as.data.table(originario_grau)[, .(Sim, Não)]))

procedimento_formato <- originario_grau <- ft[, sum(ind2, na.rm=T), by=.(procedimento, formato)] %>%
  pivot_wider(names_from = originario, values_from = V1) %>%
  mutate(
    originario_pct = 1000 * Sim / (Sim + Não),
    recursal_pct = 1000 - originario_pct
  )


  
procedimentos_tempos <- ft[, .(procedimento = factor(procedimento, levels=c("Conhecimento criminal", "Conhecimento não criminal", "Execução extrajudicial não fiscal", "Execução fiscal", "Execução judicial", "Pré-processual", "Outros")), ind16 = sum(ind16_dias)), by=procedimento]

ggplot(ft) +
  aes(y = bx_tmp, x = procedimentos_output[procedimento], fill = procedimento) +
  geom_boxplot() +
  labs(y = "Tempo de tramitação (dias)", x="", fill="") +
  scale_fill_viridis(discrete=TRUE) +
  theme_bw() +
  theme(#axis.title.x=element_blank(),
        #axis.text.x=element_blank(),
        #axis.ticks.x=element_blank(),
    axis.text.x = element_text(angle = 90, hjust=1),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        legend.position="bottom") +
  guides(fill="none")
ggsave("img/procedimento_tempo.pdf", width = 7, height = 4.6)

sum_all <- colSums(ft[, ..explicative_columns])

ind_sums <- data.table(
  ind = fct_reorder(
    explicative_labels[names(sum_all)],
    as.integer(sum_all)
  ),
  value = as.integer(sum_all)
) %>%
  arrange(-value) %>%
  as.data.table()

ggplot(ind_sums) +
  aes(x = value, y = ind, fill=ind) +
  geom_col() +
  geom_text(aes(label=value), position=position_dodge(width=0.9), hjust=-.1) +
  xlim(c(0, 1.15 * ind_sums[, max(value)])) +
  labs(x = "Quantitativo de Processos", y = "Indicador") +
  guides(fill=F) +
  scale_fill_viridis_d(begin=0, end=.7) +
  theme_bw() +
  theme(
    axis.text.x=element_blank(),
    axis.ticks.x=element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank()
  )

ggsave("img/inds_qtd.pdf", width = 7, height = 4, limitsize=FALSE)


plot_point <- function(explicative, df = ft, filter = "#", y="bx_tmp") {
  expr <- glue("
        a <- df[
          {filter}
        ]
        ggplot(a) +
          aes(
            x = as.integer({explicative}),
            y = {y}
          ) +
          geom_point() +
          geom_quantile(quantiles=.5, linewidth=1) +
          geom_smooth(method = lm, color='#00822e', se=FALSE) +
          labs(y = '', x=explicative_labels['{explicative}']) +
          theme_classic() +
          xlim(c(0, a[{y} != 0][, max({explicative})]))
    ")
  eval(
    parse(
      text=expr
    )
  )
}

chart <- do.call(
  function(...) grid.arrange(..., nrow=4),
  lapply(explicative_columns, plot_point)
)

standardize <- function(x) {
  xbar <- mean(x, na.rm=T)

  S <- sd(x, na.rm=T)

  return((x - xbar) / S)
}

ggsave("img/cross_charts.png", chart, scale=1, width = 8.1, height = 10.8, limitsize=FALSE)

chart_without_outliers <- do.call(
  function(...) grid.arrange(..., nrow=4),
  lapply(explicative_columns, function(explicative) plot_point(
    explicative, filter = glue(
      "({explicative} <= quantile({explicative}, .9995, na.rm = TRUE)) & (
            bx_tmp <= quantile(bx_tmp, .97, na.rm=TRUE)
        )"
    )
  ))
)

ggsave("img/cross_charts_without_outliers.png", chart_without_outliers, scale=1, width = 8.1, height = 10.8, limitsize=FALSE)

infame <- fread("data/infame_filter.csv")

chart_infame <- do.call(
  function(...) grid.arrange(..., nrow=4),
  lapply(explicative_columns, function(explicative) plot_point(
    explicative, filter = glue(
      "({explicative} <= quantile({explicative}, .997, na.rm = TRUE)) & (
            bx_tmp <= quantile(bx_tmp, .99, na.rm=TRUE)
        )"
    ),
    df = infame
  ))
)
ggsave("img/infame_cross_charts_without_outliers.png", chart_without_outliers_infame, scale=1, width = 8.1, height = 10.8, limitsize=FALSE)

chart_infame_standardized <- do.call(
  function(...) grid.arrange(..., nrow=4),
  lapply(glue("standardize({explicative_columns})"), function(explicative) plot_point(
    explicative, filter = glue(
      "(standardize({explicative}) <= quantile(standardize({explicative}), .997, na.rm = TRUE)) & (
            bx_tmp <= quantile(bx_tmp, .99, na.rm=TRUE)
        )"
    ),
    df = infame
  ))
)
ggsave("img/infame_cross_charts_standardized.png", chart_infame_standardized, scale=1, width = 8.1, height = 10.8, limitsize=FALSE)

pend_outl <- ft[(ind2 < 120) & (bx_tmp > 1000)] %>%
  group_by(formato, sigla_grau, originario, procedimento) %>%
  summarise(n = n(), tempo = as.integer(sum(ind16_dias) / sum(ind16_proc))) %>%
  arrange(-n) %>%
  as.data.table()

pend_outl %>%
  xtable()

corr_matrix <- do.call(
  function(...) select(ft, ...),
  reverse_explicative_labels
) %>%
  as.data.table() %>%
  cor() %>%
  round(2) %>%
  melt(na.rm = TRUE) %>%
  mutate(Var2 = factor(Var2)) %>%
  mutate(Var1 = factor(Var1, rev(levels(Var2))))

ggplot(corr_matrix, aes(Var2, Var1, fill = value)) +
  geom_point(aes(size=value), shape = 21, color="white") +
  scale_size(range = c(7, 17)) +
  scale_fill_gradient2(
    low = "#7d0401", high = "#083464", mid = "white", 
    midpoint = 0, limit = c(-1,1), space = "Lab", 
    name="Correlação\nde Pearson",
    breaks=c(-1, -.5, 0, .5, 1),
    labels=c(-1.0, -.5, 0.0, .5, 1.0) %>% str_replace("\\.", ",")
  ) +
  theme_bw() +
  coord_fixed() +
  geom_text(aes(label = str_replace(value, "\\.", ","), alpha = 2*value), color = "black", size = 4) +
  scale_alpha_continuous(range = c(0.7, 1)) +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 1, size = 12, hjust = 1),
    axis.text.y = element_text(size = 12),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank(),
    axis.ticks = element_blank(),
    legend.justification = c(1, 0),
    legend.position = c(0.75, 0.634),
    legend.direction = "horizontal"
  ) +
  guides(
    fill = guide_colorbar(
      barwidth = 7, barheight = 1,
      title.position = "top", title.hjust = 0.5
    ),
    alpha="none",
    size="none"
  )

ggsave("img/corrplot.pdf", width = 7.48, height = 7.48)
