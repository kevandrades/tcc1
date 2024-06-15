source("models/models.R")
source("models/correlator.R")
source("models/pval_selector.R")

gaussian_mdl1 <- stepwiseAIC(lm(bx_tmp ~ ., data = train_data)) %>% 
    select_gaussian_with_pval(sig.level=.1)

gr_model_to_df(
    gaussian_mdl1,
    caption = "Regressão gaussiana com seleção \\textit{stepwise} usando AIC",
    label = "tab:gr_selection"
)

gr_interactions <- with(gaussian_mdl1, {
      corrs <- correlator(gaussian_mdl1, train_data)

      numeric_cols <- names(coefficients) %>% .[str_detect(., "ind")]

      full_cols <- names(coefficients) %>% .[!str_detect(., "Intercept")]

      nonlinears <- "I(ind11^2) + I(ind13a^2) + I(ind13b^2) + I(ind26^2) + I(ind24^2) + I(ind25^2)"

      fml <- paste(c(
          glue("bx_tmp ~ {paste(full_cols, collapse='+')}"),
          corrs$unique_key,
          nonlinears
      ), collapse=" + ")

      result <- stepwiseAIC(lm(as.formula(fml), data = train_data), direction="both") %>%
        select_gaussian_with_pval(sig.level = .1)

      return(result)
  })


gr_model_to_df(
    gr_interactions,
    caption = "Regressão gaussiana com interações",
    label = "tab:gr_selection_interaction"
)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    