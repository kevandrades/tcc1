ft[, ]

ft[, originario := factor(originario, levels=c("Sim", "Não"))]

#ft[, sigla_grau := c("G1" = "1º", "G2" = "2º")[sigla_grau]]


freqs_grau_orig <- table(
    ft[, .(sigla_grau, originario)]
)

xtable::xtable(addmargins(freqs_grau_orig))

fisher.test(freqs_grau_orig)

freqs_grau_fmt <- table(
    ft[, .(sigla_grau, formato)]
)

fisher.test(freqs_grau_fmt)


freqs_prcd_fmt <- table(
    ft[, .(procedimento, formato)]
)

freqs_prcd_fmt |> chisq.test()





freqs_prcd_grau <- table(
    ft[, .(procedimento, sigla_grau)]
)

freqs_prcd_grau |> fisher.test()

