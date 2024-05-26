source("models/models.R")
options(scipen=999)

qr_median_reduced <- rq(
  bx_tmp ~ sigla_grau_G2 + procedimento_6 + formato_Físico + ind5 + ind4 + ind10 + ind9 + ind6a,
  tau = .5, data = train_data
)

qr_median_reduced %>% qr_model_to_df(
  caption = "Regressão quantílica  ($\\tau$ = 0,5) com adição de Formato e remoção dos Casos Novos de Rec. Interno",
  label = "tab:qr_reduce_formato_"
)

qr_median_reduced_wout_format <- rq(
  bx_tmp ~ sigla_grau_G2 + procedimento_6 + ind5 + ind4 + ind10 + ind9 + ind6a,
  tau = .5,
  data = train_data
)

qr_median_reduced %>% qr_model_to_df(
  caption = "Regressão quantílica  ($\\tau$ = 0,5) reduzida",
  label = "tab:qr_reduce_"
)
