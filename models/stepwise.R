source("models/models.R")

fml <- bx_tmp ~ .

quantiles <- c(.1, .25, .5, .75, .9)

step1 <- with(list(), {
    step1 <- list()
    
    for (q in quantiles) {
        qr_linear[[as.character(q)]] <- stepwiseAIC(rq(fml, tau = q, data = train_data))    
    }

    step1
})

for (model in qr_linear) qr_model_to_df(model,
    caption = "Regressão quantílica ($\\tau$ = {tau}) selecionado por {italic_stepwise}",
    label = "tab:qr_woutinter_"
)
