if (!require(pacman)) install.packages("pacman")
pacman::p.load(data.table, tidyverse, tidymodels, quantreg, MASS)

servidores <- fread("data/servidores.csv")[, id_orgao_julgador := as.integer(id_orgao_julgador)]

ft <- fread("data/ft_filtrado.csv")

fit_inicial_rq <- rq(tramit_tmp ~ sigla_grau_G1 + formato_Eletrônico + procedimento_2 + procedimento_5 + procedimento_6 + procedimento_7 + ind5 + ind4 + ind6a + ind8a + ind9 + ind10 + ind11 + ind13a + ind13b + ind24 + ind25 + ind26, tau = 0.5, data = ft)

fit_inicial_lm <- lm(tramit_tmp ~ sigla_grau_G1 + formato_Eletrônico + procedimento_2 + procedimento_5 + procedimento_6 + procedimento_7 + ind5 + ind4 + ind6a + ind8a + ind9 + ind10 + ind11 + ind13a + ind13b + ind24 + ind25 + ind26, tau = 0.5, data = ft)

# Aplique a seleção de modelos stepwise para a frente (forward)
rq_fit_selecionado <- stepAIC(fit_inicial, direction = "backward")

lm_fit_selecionado <- stepAIC(fit_inicial_lm, direction = "backward")

# Veja o modelo final selecionado
summary(fit_selecionado)