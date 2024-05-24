if (!require(pacman)) install.packages("pacman")
pacman::p_load(data.table, tidyverse, tidymodels, quantreg, MASS, glue)
options(scipen=999)

ft <- fread("data/infame_filter.csv")
ft[, tramit_tmp := NULL]

set.seed(pi); train_data <- ft %>%
    sample_n(2000)

fml <- bx_tmp ~ .

rq_selector <- function(fml, quantiles = list(.1, .25, .5, .75, .9), train_data = train_data) {

  rq_models <- list()

  for (q in quantiles) {
      cat(glue("Quantile: {q}\n\n"))
      model <- rq(fml, tau = q, data = train_data)
      step_selection <- stepAIC(model)
      rq_models[[as.character(q)]] <- step_selection
  }

  return(rq_models)
}

qr_linear <- rq_selector(fml = fml, train_data = train_data)

variables <- dimnames(qr_linear[["0.5"]]$x)[[2]]
numeric_cols <- variables[str_detect(variables, "ind")]
nonumeric_cols <- setdiff(variables, numeric_cols); nonumeric_cols <- nonumeric_cols[!str_detect(nonumeric_cols, "Intercept")]

fml_interactions <- as.formula(
  glue("bx_tmp ~ {paste(nonumeric_cols, collapse = ' + ')} + {paste(numeric_cols, collapse = ' + ')} + {paste(combn(numeric_cols, 2, paste, collapse=':'), collapse=' + ')}")
)

qr_inter <- rq_selector(fml = fml_interactions, quantiles = list(.5))
 selecionado: bx_tmp ~ sigla_grau_G2 + procedimento_6 + ind5 + 
    ind4 + ind6a + ind8a + ind9 + ind10 + ind11 + ind13a + ind13b + 
    ind24 + ind25 + ind26 + ind5:ind4 + ind5:ind8a + ind5:ind9 + 
    ind5:ind11 + ind5:ind13a + ind5:ind24 + ind5:ind25 + ind4:ind8a + 
    ind4:ind11 + ind4:ind13a + ind4:ind13b + ind6a:ind9 + ind6a:ind13a + 
    ind6a:ind13b + ind8a:ind9 + ind8a:ind10 + ind8a:ind11 + ind8a:ind13a + 
    ind8a:ind13b + ind9:ind10 + ind9:ind13a + ind9:ind25 + ind10:ind24 + 
    ind10:ind25 + ind11:ind25 + ind13a:ind13b + ind13a:ind24 + 
    ind13a:ind26 + ind13b:ind26 + ind24:ind25

qr_inter <- rq(bx_tmp ~ sigla_grau_G2 + procedimento_6 + ind5 + 
    ind4 + ind6a + ind8a + ind9 + ind10 + ind11 + ind13a + ind13b + 
    ind24 + ind25 + ind26,# + ind5:ind4 + ind5:ind8a + ind5:ind9 + 
    #ind5:ind11 + ind5:ind13a + ind5:ind24 + ind5:ind25 + ind4:ind8a + 
    #ind4:ind11 + ind4:ind13a + ind4:ind13b + ind6a:ind9 + ind6a:ind13a + 
    #ind6a:ind13b + ind8a:ind9 + ind8a:ind10 + ind8a:ind11 + ind8a:ind13a + 
    #ind8a:ind13b + ind9:ind10 + ind9:ind13a + ind9:ind25 + ind10:ind24 + 
    #ind10:ind25 + ind11:ind25 + ind13a:ind13b + ind13a:ind24 + 
    #ind13a:ind26 + ind13b:ind26 + ind24:ind25,
    tau = .5, data = train_data)

lr_linear <- stepAIC(lm(fml, data = train_data))
lr_inter <- stepAIC(lm(fml_interactions, data = train_data))
