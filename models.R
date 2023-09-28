if (!require(pacman)) install.packages("pacman")
pacman::p_load(data.table, tidyverse, tidymodels, quantreg, MASS, glue)

servidores <- (
    fread("data/servidores.csv", na.strings="-")
    [, id_orgao_julgador := as.integer(id_orgao_julgador)]
    [str_detect(sigla_tribunal, "TRT")]
)

ft <- fread("data/dummied.csv")

ft[, id_formato := c(0, 1)[id_formato]]

ft[servidores, servidores := i.servidores, on=c("id_orgao_julgador", "sigla_tribunal")]

ft[is.na(ft)] <- 0

fit_inicial_lm <- lm(tramit_tmp ~ sigla_grau_G1 + formato_Eletrônico + procedimento_2 + procedimento_5 + procedimento_6 + procedimento_7 + servidores + ind5 + ind4 + ind6a + ind8a + ind9 + ind10 + ind11 + ind13a + ind13b + ind24 + ind25 + ind26, data = ft)

rq_models <- list()
model_coeffs <- list(lm = coefficients(fit_inicial_lm))

for (qntle in c(.1, .25, .5, .75, .9)) {
    rq_mod <- rq(tramit_tmp ~ sigla_grau_G1 + formato_Eletrônico + procedimento_2 + procedimento_5 + procedimento_6 + procedimento_7 + servidores + ind5 + ind4 + ind6a + ind8a + ind9 + ind10 + ind11 + ind13a + ind13b + ind24 + ind25 + ind26, tau = qntle, data = ft)
    
    model_coeffs[[glue("rq_{qntle}")]] <- coefficients(rq_mod)

    rq_models[[glue("rq_{qntle}")]] <- rq_mod
}

coeffs <- do.call(cbind, model_coeffs) %>%
    round(3) %>%
    as.data.frame() %>%
    rownames_to_column("coeff")

# Aplique a seleção de modelos stepwise para a frente (forward)
lm_fit_selecionado <- stepAIC(fit_inicial_lm)

rq_fit_selecionado <- stepAIC(fit_inicial_rq)

# Veja o modelo final selecionado
summary(fit_selecionado)