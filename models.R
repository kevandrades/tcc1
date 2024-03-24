if (!require(pacman)) install.packages("pacman")
pacman::p_load(data.table, tidyverse, tidymodels, quantreg, MASS, glue)

set.seed(299792458)
ft <- fread("data/infame_filter.csv") 

ft_train <- ft %>%
    sample_n(2200)

quantiles <- list(.1, .25, .5, .75, .9)

rq_models <- list()

for (q in quantiles) {
    model <- rq(tramit_tmp ~ ., tau = q, data = ft_train)
    step_selection <- stepAIC(model)
    rq_models[[as.character(q)]] <- step_selection
}

fit_inicial_lm <- lm(model_formula, data = ft_train)

lm_fit_selecionado <- stepAIC(fit_inicial_lm)

rq_summaries <- list()

for (quantile in names(rq_models)) rq_summaries[[quantile]] <- summary(rq_models[[quantile]])
