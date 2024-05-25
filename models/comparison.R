rq(bx_tmp ~ procedimento_6 + ind5 + ind4 + ind9 + ind4:ind6a, tau = .5, data=train_data) %>% AIC()

qr_median_interactions %>% AIC()
qr_median_reduced_wout_format %>% AIC()

AIC(qr_median_reduced)
AIC(qr_median_reduced_wout_format)
AIC(qr_median_reduced)
AIC(qr_linear[["0,5"]])

