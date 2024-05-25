if (!require(pacman)) install.packages("pacman")
pacman::p_load(data.table, tidyverse, tidymodels, quantreg, MASS, glue)
options(scipen=6, OutDec=",")

ft <- fread("data/infame_filter.csv")
ft[, tramit_tmp := NULL]

set.seed(pi); train_data <- ft %>%
    sample_n(2000)

fml <- bx_tmp ~ .

rq_selector <- function(fml, quantiles = c(.1, .25, .5, .75, .9), train_data = train_data) {

  rq_models <- list()

  for (q in quantiles) {
      cat(glue("Quantile: {q}\n\n"))
      model <- rq(fml, tau = q, data = train_data)
      step_selection <- stepAIC(model)
      rq_models[[as.character(q)]] <- step_selection
  }

  return(rq_models)
}

model_to_df <- function(model, caption, label) {
  renames <- c(
    "(Intercept)" = "Intercepto",
    "sigla_grau_G2" = "Grau",
    "procedimento_2" = "Procedimento 2",
    "procedimento_6" = "Procedimento 6",
    "procedimento_7" = "Procedimento 7",
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
  tau <- with(model, tau)

  caption <- paste(caption, tau)

  tbl <- model %>%
    summary() %>%
    coefficients() %>%
    as.data.frame()
  
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
      Variável = renames[rownames(tbl)]
    ) %>%
    dplyr::select(Variável, Coeficiente = Value, `Erro Padrão` = `Std. Error`, Significância = `Pr(>|t|)`) %>%
    xtable::xtable(
      caption = caption,
      align = "cc|cc|c",
      label=paste0(label, tau)
    )
}

qr_linear <- rq_selector(fml = fml, train_data = train_data)

textbls_wout_inter <- qr_linear %>%
  lapply(function(model) model_to_df(model, caption = "Modelo de regressão quantílica selecionado por Stepwise para o quantil de", label = "tab:quantreg_woutinter_"))
  
for (tbl in textbls_wout_inter) {
  print(tbl, caption.placement = "top", include.rownames=F, table.placement="H")
}


qr_median_reduced <- rq(
  bx_tmp ~ sigla_grau_G2 + procedimento_2 + procedimento_6 + procedimento_7 + formato_Físico + ind5 + ind4 + ind10 + ind9 + ind6a,
  tau = .5,
  data = train_data
)

print(model_to_df(
    qr_median_reduced,
    caption = "Modelo de regressão quantílica com variáveis mais significantes para o quantil de",
    label = "tab:quantreg_reduce_"),
  caption.placement = "top",
  include.rownames=F,
  table.placement="H"
)

fml_interactions <- as.formula(
  glue("bx_tmp ~ {paste(nonumeric_cols, collapse = ' + ')} + {paste(numeric_cols, collapse = ' + ')} + {paste(combn(numeric_cols, 2, paste, collapse=':'), collapse=' + ')}")
)

qr_inter <- rq_selector(fml = fml_interactions, quantiles = list(.5))
 selecionado: bx_tmp ~ sigla_grau_G2 + procedimento_6 + ind5 + 
    ind4 + ind6a + ind8a + ind9 + ind10 + ind11 + ind13a + ind13b + 
    ind24 + ind25 + ind26 + ind5:ind4 + ind5:ind8a + ind5:ind9 + 
    ind5:ind11 + ind5:ind13a + ind5:ind24 + ind5:ind25 + ind4:ind8a + 
    ind4:ind11 + ind4:ind13a + ind4:ind13b + ind6a:ind9 + ind6a:ind13a + 
    ind6a:ind13b + ind8a:ind9 + ind8a:ind10 + ind8a:ind11 + ind8a:ind13a + 
    ind8a:ind13b + ind9:ind10 + ind9:ind13a + ind9:ind25 + ind10:ind24 + 
    ind10:ind25 + ind11:ind25 + ind13a:ind13b + ind13a:ind24 + 
    ind13a:ind26 + ind13b:ind26 + ind24:ind25

qr_inter <- rq(bx_tmp ~ sigla_grau_G2 + procedimento_6 + ind5 + 
    ind4 + ind6a + ind8a + ind9 + ind10 + ind11 + ind13a + ind13b + 
    ind24 + ind25 + ind26,# + ind5:ind4 + ind5:ind8a + ind5:ind9 + 
    #ind5:ind11 + ind5:ind13a + ind5:ind24 + ind5:ind25 + ind4:ind8a + 
    #ind4:ind11 + ind4:ind13a + ind4:ind13b + ind6a:ind9 + ind6a:ind13a + 
    #ind6a:ind13b + ind8a:ind9 + ind8a:ind10 + ind8a:ind11 + ind8a:ind13a + 
    #ind8a:ind13b + ind9:ind10 + ind9:ind13a + ind9:ind25 + ind10:ind24 + 
    #ind10:ind25 + ind11:ind25 + ind13a:ind13b + ind13a:ind24 + 
    #ind13a:ind26 + ind13b:ind26 + ind24:ind25,
    tau = .5, data = train_data)

lr_linear <- stepAIC(lm(fml, data = train_data))
lr_inter <- stepAIC(lm(fml_interactions, data = train_data))
