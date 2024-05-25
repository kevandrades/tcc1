
qr_median_reduced <- rq(
  bx_tmp ~ sigla_grau_G2 + procedimento_6 + formato_Físico + ind5 + ind4 + ind10 + ind9 + ind6a,
  tau = .5, data = train_data
)

qr_median_reduced_wout_format <- rq(
  bx_tmp ~ sigla_grau_G2 + procedimento_6 + ind5 + ind4 + ind10 + ind9 + ind6a,
  tau = .5,
  data = train_data
)