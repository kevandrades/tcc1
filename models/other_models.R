source("models/models.R")
source("models/selector.R")
options(scipen=6, OutDec=",")

quantiles <- c(.1, .25, .5, .75, .9)

final <- tibble(Variável = "Intercepto")

aic_linear <- c()
aic_nonlinear <- c()    
bic_linear <- c()
bic_nonlinear <- c()
rho_linear <- c()
rho_nonlinear <- c()

for (tau in quantiles) {
    mdl1 <- candidate1(tau)
    mdl2 <- candidate2(tau, mdl1)

    aic_linear <- c(aic_linear, AIC(mdl1))
    aic_nonlinear <- c(aic_nonlinear, AIC(mdl2))
    bic_linear <- c(bic_linear, bic_estimate(mdl1))
    bic_nonlinear <- c(bic_nonlinear, bic_estimate(mdl2))
    rho_linear <- c(rho_linear, with(mdl1, rho))
    rho_nonlinear <- c(rho_nonlinear, with(mdl2, rho))
    

    mdl1_df <- qr_model_to_df(mdl1) %>%
        select(Variável, Coeficiente) %>%
        as_tibble()

    colnames(mdl1_df) <- c("Variável", paste0("1 (tau = ", tau, ")"))
    
    mdl2_df <- qr_model_to_df(mdl2) %>%
        select(Variável, Coeficiente) %>%
        as_tibble()
    
    colnames(mdl2_df) <- c("Variável", paste0("2 (tau = ", tau, ")"))

    mdl_df <- full_join(mdl1_df, mdl2_df)

    final <- full_join(final, mdl_df)
}

sort_vars <- c(
    "Intercepto",
    "Grau",
    "Formato",
    "Procedimento - Conhecimento não criminal",
    "Procedimento - Pré-processual",
    "Procedimento - Outros",
    "Tramitando",
    "Suspensos",
    "Despachos",
    "Decisões",
    "Conclusos",
    "Rec. Interno Julgado",
    "Liminares indeferidas",
    "Julgamentos",
    "Rec. Interno Pendente",
    "Despachos:Liminares indeferidas",
    "Liminares indeferidas:Julgamentos",
    "Suspensos:Decisões",
    "Rec. Interno Pendente:Julgamentos",
    "Julgamentos:Tramitando",
    "Suspensos:Rec. Interno Julgado",
    "Suspensos:Conclusos",
    "Tramitando:Suspensos e Sobrestados",
    "Rec. Interno Pendente:Conclusos",
    "Suspensos:Despachos",
    "Tramitando:Despachos",
    "Suspensos:Tramitando"
)

final <- final %>%
    mutate(Variável = factor(final$Variável, levels=sort_vars)) %>%
    arrange(Variável) %>%
    mutate_if(is.numeric, function(x) round(x, 4))

nvars <- final %>% select(-Variável) %>% (function(x) !is.na(x)) %>% colSums()

a <- with(final, {
    data.frame(
    quantiles = names(nvars) %>% str_remove_all("(.+ = )|\\)") %>% str_replace(",", ".") %>% as.numeric(),
    type = names(nvars) %>% str_remove_all(" .+") %>% c("1" = "linear", "2" = "nonlinear")[.],
    nvars = nvars
) %>%
    pivot_wider(names_from=type, values_from=nvars) %>%
    mutate(
        aic_linear, bic_linear,
        aic_nonlinear, bic_nonlinear,
        rho_linear, rho_nonlinear,
        nlinear = as.integer(linear), nnonlinear = as.integer(nonlinear)
    ) %>%
    select(
        q = quantiles,
        aic_linear, aic_nonlinear,
        bic_linear, bic_nonlinear,
        rho_linear, rho_nonlinear,
        nlinear, nnonlinear
    ) %>%
    mutate(
        corresp = c(
            sum(!is.na(`1 (tau = 0,1)`) & !is.na(`2 (tau = 0,1)`)),
            sum(!is.na(`1 (tau = 0,25)`) & !is.na(`2 (tau = 0,25)`)),
            sum(!is.na(`1 (tau = 0,5)`) & !is.na(`2 (tau = 0,5)`)),
            sum(!is.na(`1 (tau = 0,75)`) & !is.na(`2 (tau = 0,75)`)),
            sum(!is.na(`1 (tau = 0,9)`) &   !is.na(`2 (tau = 0,9)`))
        )
    )
})


xtable::xtable(
    a %>% lapply(as.integer) %>%
    as.data.frame() %>%
    mutate(q = quantiles)
) %>%
    print(include.rownames = FALSE)

final %>%
    select(-Variável) %>%
    mutate_all(function(x) str_replace_all(x, "^.*$", "\\checkmark")) %>%
    mutate(Variável = final$Variável, .before=`1 (tau = 0,1)`) %>%
    xtable::xtable(digits=2) %>%
    print(digits=2) 


final %>%
    select(Variável, `1 (tau = 0,1)`, `1 (tau = 0,25)`, `1 (tau = 0,5)`, `2 (tau = 0,75)`, `2 (tau = 0,9)`) %>%
    dplyr::filter(
        !is.na(`1 (tau = 0,1)`) |
        !is.na(`1 (tau = 0,25)`) |
        !is.na(`1 (tau = 0,5)`) |
        !is.na(`2 (tau = 0,75)`) |
        !is.na(`2 (tau = 0,9)`)
    ) %>%
    as.data.frame() %>%    
    xtable::xtable(digits=4) %>%
    print(digits=4, include.rownames=FALSE)


