if (!require(pacman)) install.packages("pacman")
pacman::p_load(MASS, data.table, quantreg, purrr, glue, tidyverse, tidymodels)
options(scipen=6, OutDec=",")

ft <- fread("data/infame_filter.csv")
ft[, tramit_tmp := NULL]

set.seed(pi); train_data <- ft %>%
    sample_n(2000)

model_to_df <- function(model, caption, label) {
  renames <- c(
    "\\(Intercept\\)" = "Intercepto",
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
  tau <- with(model, as.character(tau))

  tbl <- model %>%
    summary() %>%
    coefficients() %>%
    as.data.frame()
  
  rows <- rownames(tbl)

  for (name in names(renames)) {
    rows <- str_replace_all(rows, name, renames[name] %>% unname())
  }

  label <- paste0(label, tau)
  caption <- glue(caption) %>% as.character()
  
  tbl %>%
    mutate(
      `Std. Error` = case_when(
        `Std. Error` > 99999 ~ formatC(`Std. Error`),
        TRUE ~ as.character(round(`Std. Error`, 3))
      ),
      Value = case_when(
        Value > 99999 ~ formatC(Value),
        TRUE ~ as.character(round(Value, 3))
      ),
      Variável = rows
    ) %>%
    dplyr::select(Variável, Coeficiente = Value, `Erro Padrão` = `Std. Error`, `P-valor` = `Pr(>|t|)`) %>%
    xtable::xtable(
      caption = caption,
      align = "cc|cc|c",
      label = label,
      digits = 3
    ) %>%
    print(caption.placement = "top", include.rownames=F, table.placement="H", floating.environment = "modelo")
}

italic_stepwise <- "\\textit{stepwise}"