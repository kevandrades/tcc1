source("models/models.R")

categorical_cols <- c("sigla_grau_G2", "procedimento_2", "procedimento_6", "procedimento_7", "formato_Físico")

numeric_cols <- c("ind5", "ind4", "ind10", "ind9", "ind6a")

qr_median_inter <- rq(
  as.formula(
    glue(
      "bx_tmp ~ sigla_grau_G2 + procedimento_6 +
      {paste(numeric_cols, collapse='+')} +
      {paste(combn(numeric_cols, 2, paste, collapse=':'), collapse=' + ')}"
    )
  ),
  tau = .5, data = train_data
) %>% stepwiseAIC(direction="both")

qr_model_to_df(
    qr_median_inter,
    caption = "Regressão quantílica ($\\tau$ = {tau}) com interações e seleção automática",
    label = "tab:qr_median_interactions_"
  )
