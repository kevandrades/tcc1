source("models/models.R")

numeric_cols <- with(qr_median_reduced, colnames(x) %>% .[str_detect(., "ind")])

qr_median_reduced_inter <- rq(
  as.formula(
    glue(
      "bx_tmp ~ sigla_grau_G2 + procedimento_6 +
      {paste(numeric_cols, collapse='+')} +
      {paste(combn(numeric_cols, 2, paste, collapse=':'), collapse=' + ')}"
    )
  ),
  tau = .5, data = train_data
)

qr_median_reduced_inter_step <- stepAIC(qr_median_reduced_inter, direction="both")

print(model_to_df(
    qr_median_reduced_inter,
    caption = "Modelo de regressão quantílica ($\\tau$ = {tau}) com interações e seleção automática",
    label = "tab:qr_median_interactions_"
  ),
  caption.placement = "top",
  include.rownames=F,
  table.placement="H"
)


print(model_to_df(
    qr_median_reduced_inter_step,
    caption = "Modelo de regressão quantílica ($\\tau$ = {tau}) com variáveis significativas e Formato removido",
    label = "tab:qr_median_reduced_inter_step_"),
  caption.placement = "top",
  include.rownames=F,
  table.placement="H"
)


qr_median_interactions <- rq(fml_interactions, tau = .5, data = train_data) 


print(model_to_df(
    qr_median_interactions,
    caption = "Modelo de regressão quantílica ($\\tau$ = {tau}) com interações",
    label = "tab:qr_"),
  caption.placement = "top",
  include.rownames=F,
  table.placement="H"
)

qr_median_interactions <- stepAIC(rq(fml_interactions, tau = .5, data = train_data), direction = "both")


qr_inter <- rq(fml_interactions, tau = .5, data = train_data) %>% stepAIC()


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
