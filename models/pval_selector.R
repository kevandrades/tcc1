options(scipen=999)

select_with_pval <- function(model, sig.level = .1) {
    tau <- with(model, tau)
    fit_model <- function(df) {
        with(
            df, {
                fml <- as.formula(paste("bx_tmp ~", paste(variable, collapse=" + ")))
                mdl <- rq(fml, data = ft, tau = tau)
                return(mdl)
            }
        )
    }

    to_df <- function(model) {
        mdl <- model %>%
            (function(mdl) {
                tryCatch(
                    summary(mdl),
                    error = function(cond) summary(mdl, se="boot")
                )
            }) %>%
            coefficients() %>%
            as.data.frame() %>%
            mutate(., variable = row.names(.)) %>%
            as_tibble() %>%
            select(variable, pvalue = `Pr(>|t|)`) %>%
            arrange(pvalue) %>%
            dplyr::filter(variable != "(Intercept)")
        return(mdl)
    }

    rmv <- function(tbl) {
        tbl %>%
            dplyr::filter(
                !((row_number() >= n() - 1) & (pvalue > sig.level))
            )
    }

    tbl <- to_df(model)

    while(TRUE) {
        if(sum(tbl$pvalue > sig.level) == 0){
            break
        }
        
        model <- fit_model(rmv(to_df(model)))
        
        tbl <- to_df(model)
    }

    return(model)
}


select_gaussian_with_pval <- function(model, sig.level = .1) {
    fit_model <- function(df) {
        with(
            df, {
                fml <- as.formula(paste("bx_tmp ~", paste(variable, collapse=" + ")))
                mdl <- lm(fml, data = ft)
                return(mdl)
            }
        )
    }

    to_df <- function(model) {
        mdl <- model %>%
            summary() %>%
            coefficients() %>%
            as.data.frame() %>%
            mutate(., variable = row.names(.)) %>%
            as_tibble() %>%
            select(variable, pvalue = `Pr(>|t|)`) %>%
            arrange(pvalue) %>%
            dplyr::filter(variable != "(Intercept)")
        return(mdl)
    }

    rmv <- function(tbl) {
        tbl %>%
            dplyr::filter(
                !((row_number() >= n() - 1) & (pvalue > sig.level))
            )
    }

    tbl <- to_df(model)

    while(TRUE) {
        if(sum(tbl$pvalue > sig.level) == 0){
            break
        }
        
        model <- fit_model(rmv(to_df(model)))
        
        tbl <- to_df(model)
    }

    return(model)
}

