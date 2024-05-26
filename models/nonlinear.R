source("models/models.R")
options(scipen=999)

qr_nonlinear <- rq(bx_tmp ~ ind5 + ind4 + ind10 + ind9 + ind6a + ind8a + I(ind11^2) + I(ind13a^2) + I(ind13b^2) + I(ind26^2) + I(ind24^2) + I(ind25^2), tau = .5, data = train_data) %>%
    stepAIC()

qr_nonlinear %>% qr_model_to_df(
    caption="Regressão quantílica ($\\tau$ = {tau}) com variáveis expressões quadráticas e seleção {italic_stepwise}",
    label="tab:qr_median_nonlinear_"
)
