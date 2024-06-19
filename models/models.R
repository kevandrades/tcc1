if (!require(pacman)) install.packages("pacman")
if (!require(MASS)) install.packages("MASS")
pacman::p_load(data.table, quantreg, purrr, glue, tidyverse, tidymodels, Metrics)

options(
  scipen=6,
  OutDec=",",
  xtable.sanitize.colnames.function = function(x) paste("\\textbf{", x, "}", sep = "")
)

ft <- fread("data/infame_filter.csv")
ft[, tramit_tmp := NULL]

set.seed(pi); train_data <- ft #%>%
    #sample_n(.8 * n())
#test_data <- fsetdiff(ft, train_data, all = TRUE)

renames <- c(
    "(Intercept)" = "Intercepto",
    "sigla_grau_G2" = "Grau",
    'procedimento_1' = 'Procedimento - Conhecimento criminal',
    'procedimento_2' = 'Procedimento - Conhecimento não criminal',
    'procedimento_3' = 'Procedimento - Execução extrajudicial não fiscal',
    'procedimento_4' = 'Procedimento - Execução fiscal',
    'procedimento_5' = 'Procedimento - Execução judicial',
    'procedimento_6' = 'Procedimento - Pré-processual',
    'procedimento_7' = 'Procedimento - Outros',
    "formato_Físico" = "Formato",
    "ind8a" = "Julgamentos",
    "ind13a" = "Liminares indeferidas",
    "ind26" = "Rec. Interno Julgado",
    "ind5" = "Tramitando", 
    "ind9" = "Despachos",
    "ind13b" = "Liminares deferidas",    
    "bx_tmp" = "Tempo até a baixa",
    "ind4" = "Suspensos",
    "ind10" = "Decisões",
    "ind24"  = "Casos Novos de Rec. Interno",
    "ind6a" = "Conclusos",
    "ind11" = "Audiências",
    "ind25" = "Rec. Interno Pendente"
  )


round_formatter <- function(x) case_when(
  abs(x) > 1 ~ as.character(as.integer(x)),
  abs(x) < .001 ~ formatC(x, format="e", digits=1),
  TRUE ~ as.character(round(x, 3))
)


to_significative_time <- function(days) {
  time_metric_plural <- function(metric, singular, plural) {
    metric <- case_when(
      floor(abs(metric)) == 1 ~ paste(metric, singular),
      TRUE ~ paste(metric, plural)
    )
    return(metric)
  }

  days_to_seconds <- function(days) {
    seconds <- round(days * 24 * 60 * 60, 0)

    time_metric_plural(seconds, "segundo", "segundos")
  }
  days_to_hours <- function(days) {
    hours <- days * 24

    minutes <- round((hours - floor(hours)) * 60, 0)

    return(paste0(floor(hours), "h", minutes, "min"))
  }

  days_to_metric <- function(days, base, singular, plural, digits) {
    metric <- time_metric_plural(round(days / base, digits), singular, plural)
    return(metric)
  }
  
  case_when(
    abs(days * 24 * 60) < 1 ~ days_to_seconds(days),
    abs(days) < 1 & abs(days * 24 * 60) >= 1 ~ days_to_hours(days),
    abs(days) >= 1 & abs(days) <= 30 ~ days_to_metric(days, 1, "dia", "dias", digits=0),
    abs(days) > 30 & abs(days) < 365 ~ days_to_metric(days, 31, "mês", "meses", digits=1),
    TRUE ~ days_to_metric(days, 365, "ano", "anos", digits=1)
  )
}

qr_model_to_df <- function(model, add.tau = FALSE) {
  tau <- with(model, tau)

  tbl <- model %>%
    (function(mdl) {
        tryCatch(
            summary(mdl),
            error = function(cond) summary(mdl, se="boot")
        )
    })  %>%
    coefficients() %>%
    as.data.frame()
  
  rows <- rownames(tbl)

  for (name in names(renames)) {
    rows <- str_replace_all(rows, name, renames[name] %>% unname())
  }
  rownames(tbl) <- rows

  tbl <- tbl %>%
    mutate(
      `Std. Error` = round_formatter(`Std. Error`),
      `P-valor` = case_when(
        `Pr(>|t|)` < 0.001 ~ "\\approx 0",
        TRUE ~ as.character(round(`Pr(>|t|)`, 3))
      ),
      Variável = rows
    ) %>%
    dplyr::select(Variável, Coeficiente = Value, `Erro Padrão` = `Std. Error`, `P-valor`)
  
  if (add.tau) {
    tbl <- tbl %>%
      mutate(tau = tau)
  }

  tbl[]
}

df_to_xtable <- function(df, caption, label, digits=3, align="cc|cc|c", floating.environment="modelo") {
  df %>% xtable::xtable(
      caption = caption,
      align = align,
      label = label,
      digits = digits
    ) %>%
    print(
      caption.placement = "top", include.rownames=F,
      table.placement="H", floating.environment = floating.environment,
      sanitize.text.function = identity
    )
}

qr_model_to_xtable <- function(model, caption, label, align = "cc|cc|c") {

  tau <- with(model, tau)

  qr_model_to_df(model) %>%
  mutate(Coeficiente = to_significative_time(Coeficiente)) %>%
  df_to_xtable(caption, label, align=align)
}

italic_stepwise <- "\\textit{stepwise}"

gr_model_to_df <- function(model) {
  tbl <- model %>%
    summary() %>%
    coefficients() %>%
    as.data.frame()
  
  rows <- rownames(tbl)

  for (name in names(renames)) {
    rows <- str_replace_all(rows, name, renames[name] %>% unname())
  }
  
  tbl %>%
    mutate(
      Variável = rows,
      `P-valor` = case_when(
        `Pr(>|t|)` < 0.001 ~ "\\approx 0",
        TRUE ~ as.character(round(`Pr(>|t|)`, 3))
      ),
      `Erro Padrão` = round_formatter(`Std. Error`)
    ) %>%
    dplyr::select(
      Variável,
      Coeficiente = Estimate,
      `Erro Padrão`,
      `P-valor`
    ) 
}

gr_model_to_xtable <- function(model, caption, label, digits=3, align = "cc|cc|c") {
  gr_model_to_df(model) %>%
  mutate(Coeficiente = to_significative_time(Coeficiente)) %>%
  df_to_xtable(caption, label, digits, align)
}

stepAIC <- stepwiseAIC <- function(..., direction = "both") MASS::stepAIC(..., direction=direction)

bic_estimate <- function(model) {
    lls <- stats4::logLik(model)
    nos <- with(model, nrow(x))
    
    -2 * as.numeric(lls) + log(nos) * attr(lls, "df")
}

