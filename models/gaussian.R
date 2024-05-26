source("models/models.R")

gr_selection <- stepwiseAIC(lm(bx_tmp ~ ., data = train_data))

gr_model_to_df(
    gr_selection,
    caption = "Regressão gaussiana com seleção \\textit{stepwise} usando AIC",
    label = "tab:gr_selection"
)

gr_interactions <- with(gr_selection, {
    categorical <- names(coefficients) %>% .[!str_detect(., "(ind|Intercept)")] %>% paste(collapse = " + ")
    inds <- names(coefficients) %>% .[str_detect(., "ind")]

    individual <- paste(inds, collapse=' + ')
    interact <- paste(combn(inds, 2, paste, collapse=':'), collapse=' + ')

    lm(as.formula(
        glue("bx_tmp ~ {categorical} + {individual} + {interact}")
    ), data = train_data) %>%
    stepwiseAIC()
})


gr_model_to_df(
    gr_interactions,
    caption = "Regressão gaussiana com interações",
    label = "tab:gr_selection_interaction"
)

gr_nonlinear <- lm(bx_tmp ~ ind5 + ind4 + ind10 + ind9 + ind6a + ind8a + I(ind11^2) + I(ind13a^2) + I(ind13b^2) + I(ind26^2) + I(ind24^2) + I(ind25^2), data = train_data) %>%
    stepwiseAIC()


gr_model_to_df(
    gr_nonlinear,
    caption = "Regressão gaussiana com variáveis não-lineares",
    label = "tab:gr_selection_nonlinear"
)

gr_minimalist <- lm(formula = bx_tmp ~ ind5 + ind4 + ind10 + ind9 + ind6a, 
    data = train_data)

gr_model_to_df(gr_minimalist, caption="Regressão gaussiana com variáveis quantitativas mais relevantes", label="tab:gr_minimalist")
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    