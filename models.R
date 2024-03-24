if (!require(pacman)) install.packages("pacman")
pacman::p_load(data.table, tidyverse, tidymodels, quantreg, MASS, glue)

set.seed(299792458)
ft <- fread("data/infame_filter.csv") 

ft_train <- ft %>%
    sample_n(2000)

explicative_columns <- names(ft) %>%
    setdiff("tramit_tmp") %>%
    paste(collapse=" + ")

model_formula <- parse(
    text=glue("tramit_tmp ~ {explicative_columns}")
 ) %>%
    eval()

quantiles <- list(.1, .25, .5, .75, .9)

rq_models <- list()

for (q in quantiles) {
    model <- rq(model_formula, tau = q, data = ft)
    step_selection <- stepAIC(model)
    rq_models[[as.character(q)]] <- step_selection
}


fit_inicial_lm <- lm(model_formula, data = ft)

lm_fit_selecionado <- stepAIC(fit_inicial_lm)

rq_summaries <- list()

for (quantile in names(rq_models)) rq_summaries[[quantile]] <- summary(rq_models[[quantile]])