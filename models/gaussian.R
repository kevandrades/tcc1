source("models/models.R")
source("models/correlator.R")
source("models/pval_selector.R")
library(xtable)

options(
    xtable.sanitize.colnames.function = function(x) paste("\\textbf{", x, "}", sep = "")
)

lbl_mdl1 <- "tab:gr_selection"
lbl_mdl2 <- "tab:gr_selection_interaction"

gr_mdl1 <- stepwiseAIC(lm(bx_tmp ~ ., data = train_data)) %>% 
    select_gaussian_with_pval(sig.level=.05)

gr_model_to_xtable(
    gr_mdl1,
    caption = "Regressão gaussiana",
    label = lbl_mdl1
)

gr_mdl2 <- with(gr_mdl1, {
      corrs <- correlator(gr_mdl1, train_data)

      numeric_cols <- names(coefficients) %>% .[str_detect(., "ind")]

      full_cols <- names(coefficients) %>% .[!str_detect(., "Intercept")]

      nonlinears <- "I(ind11^2) + I(ind13a^2) + I(ind13b^2) + I(ind26^2) + I(ind24^2) + I(ind25^2)"

      fml <- paste(c(
          glue("bx_tmp ~ {paste(full_cols, collapse='+')}"),
          corrs$unique_key,
          nonlinears
      ), collapse=" + ")

      result <- stepwiseAIC(lm(as.formula(fml), data = train_data), direction="both") %>%
        select_gaussian_with_pval(sig.level = .05)

      return(result)
  })


gr_model_to_xtable(
    gr_mdl2,
    caption = "Regressão gaussiana com interações",
    label = lbl_mdl2
)

data.frame(
    Modelo = paste0("\\ref{", c(lbl_mdl1, lbl_mdl2), "}"),
    AIC = c(AIC(gr_mdl1), AIC(gr_mdl2)) %>% prettyNum(big.mark = "."),
    BIC = c(BIC(gr_mdl1), BIC(gr_mdl2)) %>% prettyNum(big.mark = "."),
    MAE = c(
        mae(with(train_data, bx_tmp), predict(gr_mdl1, train_data)),
        mae(with(train_data, bx_tmp), predict(gr_mdl2, train_data))
    ),
    Coeficientes = c(
        length(coefficients(gr_mdl1)), length(coefficients(gr_mdl2))
    )
) %>%
    xtable::xtable(
        align = "cc|cccc",
        label = "tab:aic_bic_gaussianos",
        caption = "AIC e BIC para os modelos gaussianos"
    ) %>%
    print(
        include.rownames=F,
        caption.placement = "top",
        sanitize.text.function = identity
    )

common_gr <- gr_model_to_df(gr_mdl1) %>%
    select(Variável, mdl1coef = Coeficiente) %>%
    arrange(-abs(mdl1coef)) %>%
    full_join(gr_model_to_df(gr_mdl2) %>%
    select(Variável, mdl2coef = Coeficiente)) %>%
    mutate(
        mdl1coef = case_when(
            !is.na(mdl1coef) ~ '\\checkmark',
            TRUE ~ NA
        ),
        mdl2coef = case_when(!is.na(mdl2coef) ~ '\\checkmark',
            TRUE ~ NA),
        Comum = case_when(!is.na(mdl1coef) & !is.na(mdl2coef) ~ '\\checkmark')
    ) %>%
    select(
        Variável,
        `Modelo \\ref{tab:gr_selection}` = mdl1coef,
        `Modelo \\ref{tab:gr_selection_interaction}`= mdl2coef,
        Comum
    )
    
common_gr %>%
    df_to_xtable(
        caption="Coeficientes significativos para cada modelo gaussiano", label='tab:coefs_gauss', align='cc|cc|c',
        floating.environment="table")
