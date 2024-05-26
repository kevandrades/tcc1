source("models/models.R")

gr_full <- lm(bx_tmp ~ ., data = train_data)

gr_selection <- lm(bx_tmp ~ ., data = train_data) %>% stepAIC()

gr_interactions <- with(gr_selection, {
    categorical <- names(coefficients) %>% .[!str_detect(., "(ind|Intercept)")] %>% paste(collapse = " + ")
    inds <- names(coefficients) %>% .[str_detect(., "ind")]

    individual <- paste(inds, collapse=' + ')
    interact <- paste(combn(inds, 2, paste, collapse=':'), collapse=' + ')

    lm(as.formula(
        glue("bx_tmp ~ {categorical} + {individual} + {interact}")
    ), data = train_data) %>%
    stepAIC()
})

gr_nonlinear <- rq(bx_tmp ~ ind5 + ind4 + ind10 + ind9 + ind6a + ind8a + I(ind11^2) + I(ind13a^2) + I(ind13b^2) + I(ind26^2) + I(ind24^2) + I(ind25^2), tau = .5, data = train_data) %>%
    stepAIC()
