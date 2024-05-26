source("models/models.R")

fml <- bx_tmp ~ .

quantiles <- c(.1, .25, .5, .75, .9)

qr_linear <- with(list(), {
    qr_linear <- list()
    
    for (q in quantiles) {
        qr_linear[[as.character(q)]] <- stepAIC(rq(fml, tau = q, data = train_data))    
    }

    qr_linear
})

map(qr_linear,
    ~model_to_df(.,
        caption = "Regressão quantílica ($\\tau$ = {tau}) selecionado por {italic_stepwise}",
        label = "tab:qr_woutinter_"
    )
)

qr_median_nonlinear <- rq(
  bx_tmp ~ sigla_grau_G2 + procedimento_6 + formato_Físico + ind5 + ind4 + ind10 + ind9 + ind6a,
  tau = .5, data = train_data
)
