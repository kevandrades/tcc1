if (!require(pacman)) install.packages("pacman")
pacman::p_load(MASS, data.table, quantreg, purrr, glue, tidyverse, tidymodels)

options(
  scipen=6,
  OutDec=",",
  xtable.sanitize.colnames.function = function(x) paste("\\textbf{", x, "}", sep = "")
)

source("models/pval_selector.R")
source("models/models.R")
source("srcr/maps.R")
source("models/correlator.R")

tau <- .5


candidate1 <- function(tau) {

  result <- stepwiseAIC(rq(bx_tmp ~ ., tau=tau, data = train_data)) %>% 
    select_with_pval(sig.level=.1)
  
  return(result)

}

candidate2 <- function(tau, model) {
  corrs <- correlator(model, train_data)

  with(model, {
      numeric_cols <- colnames(x) %>% .[str_detect(., "ind")]

      full_cols <- colnames(x) %>% .[!str_detect(., "Intercept")]

      nonlinears <- "I(ind11^2) + I(ind13a^2) + I(ind13b^2) + I(ind26^2) + I(ind24^2) + I(ind25^2)"

      fml <- paste(c(
          glue("bx_tmp ~ {paste(full_cols, collapse='+')}"),
          #filter(cors_result, value > .3)$unique_key,
          corrs$unique_key,
          nonlinears
      ), collapse=" + ")

      result <- MASS::stepAIC(rq(as.formula(fml), tau = tau, data = train_data), direction="both") %>%
        select_with_pval(sig.level = .1)

      return(result)

  })
}

check_candidates <- function(tau) {
  mdl1 <- candidate1(tau)

  mdl2 <- candidate2(tau, mdl1)

  return(list(mdl1, mdl2))
}

