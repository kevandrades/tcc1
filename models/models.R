if (!require(pacman)) install.packages("pacman")
if (!require(MASS)) install.packages("MASS")
pacman::p_load(data.table, quantreg, purrr, glue, tidyverse, tidymodels)
options(scipen=6, OutDec=",")

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
    "ind4" = "Suspensos e Sobrestados",
    "ind10" = "Decisões",
    "ind24"  = "Casos Novos de Rec. Interno",
    "ind6a" = "Conclusos",
    "ind11" = "Audiências",
    "ind25" = "Rec. Interno Pendente"
  )

qr_model_to_df <- function(model, add.tau = FALSE) {
  tau <- with(model, tau)

  tbl <- model %>%
    summary(se = "boot") %>%
    coefficients() %>%
    as.data.frame()
  
  rows <- rownames(tbl)

  for (name in names(renames)) {
    rows <- str_replace_all(rows, name, renames[name] %>% unname())
  }

  tbl <- tbl %>%
    mutate(
      `Std. Error` = case_when(
        `Std. Error` > 99999 ~ formatC(`Std. Error`),
        TRUE ~ as.character(round(`Std. Error`, 3))
      ),
      Value = case_when(
        Value > 99999 ~ formatC(Value),
        TRUE ~ as.character(round(Value, 3))
      ),
      Variável = case_when(
        !str_detect(rownames(tbl), ":") ~ renames[rownames(tbl)],
        TRUE ~ strsplit(rownames(tbl), ":") %>% lapply(function(x) renames[x] %>% paste(collapse=":")) %>% unlist()
      )
    ) %>%
    dplyr::select(Variável, Coeficiente = Value, `Erro Padrão` = `Std. Error`, Significância = `Pr(>|t|)`)
  
  if (add.tau) {
    tbl <- tbl %>%
      mutate(tau = tau)
  }

  tbl[]
}

qr_model_to_xtable <- function(model, caption, label) {

  tau <- with(model, tau)

  caption <- paste(caption, tau)

  qr_model_to_df(model) %>%
    xtable::xtable(
      caption = caption,
      align = "cc|cc|c",
      label=paste0(label, tau)
    )
}

italic_stepwise <- "\\textit{stepwise}"

gr_model_to_df <- function(model, caption, label) {
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
      Variável = rows
    ) %>%
    dplyr::select(Variável, Coeficiente = Estimate, `Erro Padrão` = `Std. Error`, `P-valor` = `Pr(>|t|)`) %>%
    xtable::xtable(
      caption = caption,
      align = "cc|cc|c",
      label = label,
      digits = 3
    ) %>%
    print(caption.placement = "top", include.rownames=F, table.placement="H", floating.environment = "modelo")
}

stepAIC <- stepwiseAIC <- function(..., direction = "both") MASS::stepAIC(..., direction=direction)
