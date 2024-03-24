if (!require(pacman)) install.packages("pacman")
pacman::p_load(data.table, tidyverse, tidymodels, quantreg, MASS, glue)

set.seed(299792458)
ft <- fread("data/infame_filter.csv") 

ft_train <- ft %>%
    sample_n(2000)

model_formula <- tramit_tmp ~ .

quantiles <- list(.1, .25, .5, .75, .9)

rq_models <- list()

for (q in quantiles) {
    model <- rq(model_formula, tau = q, data = ft_train)
    step_selection <- stepAIC(model)
    rq_models[[as.character(q)]] <- step_selection
}

fit_inicial_lm <- lm(model_formula, data = ft_train)

lm_fit_slc <- stepAIC(fit_inicial_lm)

rq_summaries <- list()

for (quantile in names(rq_models)) rq_summaries[[quantile]] <- summary(rq_models[[quantile]])

# função oriunda da biblioteca regclass
VIF <- function (mod) {
  if (any(is.na(coef(mod)))) 
    stop("there are aliased coefficients in the model")
  v <- vcov(mod)
  assign <- attr(model.matrix(mod), "assign")
  if (names(coefficients(mod)[1]) == "(Intercept)") {
    v <- v[-1, -1]
    assign <- assign[-1]
  }
  else warning("No intercept: vifs may not be sensible.")
  terms <- labels(terms(mod))
  n.terms <- length(terms)
  if (n.terms < 2) 
    stop("model contains fewer than 2 terms")
  R <- cov2cor(v)
  detR <- det(R)
  result <- matrix(0, n.terms, 3)
  rownames(result) <- terms
  colnames(result) <- c("GVIF", "Df", "GVIF^(1/(2*Df))")
  for (term in 1:n.terms) {
    subs <- which(assign == term)
    result[term, 1] <- det(as.matrix(R[subs, subs])) * det(as.matrix(R[-subs, 
                                                                       -subs]))/detR
    result[term, 2] <- length(subs)
  }
  if (all(result[, 2] == 1)) 
    result <- result[, 1]
  else result[, 3] <- result[, 1]^(1/(2 * result[, 2]))
  result
}
