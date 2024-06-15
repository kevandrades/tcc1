library(magrittr)
source("srcr/maps.R")



correlator <- function(model, dataset) {
    with(
        model, {

        inds <- names(coefficients) %>% .[stringr::str_detect(., "ind")]

        x <- do.call(
          function(...) dplyr::select(dataset, ...),
          reverse_explicative_labels[fmt_explicative_labels[inds]]
        ) %>% as.data.frame()

        corrFunc <- function(var1, var2, data) {
          result = cor.test(data[,var1], data[,var2])
          data.frame(var1, var2, result[c("estimate","p.value")], 
                     stringsAsFactors=FALSE)
        }

        combs <- combn(colnames(x), 2, c) %>% t() %>% as.data.frame()

        x <- do.call(rbind,
              mapply(corrFunc, combs[,1], combs[,2], MoreArgs=list(data=x), 
              SIMPLIFY=FALSE)
            ) %>%
            mutate(
                estimate = round(estimate, 2),
                var1 = str_replace(var1, "\n", " "),
                var2 = str_replace(var2, "\n", " "),
                p.value = signif(p.value, digits=3)
            )

        unlisted_labels <- unlist(reverse_explicative_labels)
        names(unlisted_labels) <- names(unlisted_labels) %>% stringr::str_replace("\n", " ")

        x$unique_key <- apply(
            x %>%
            dplyr::mutate(
                var1 = unlisted_labels[var1],
                var2 = unlisted_labels[var2]
            ), 1,  
            function(row) {
              paste(sort(c(row["var1"], row["var2"])), collapse = ":")
        })

        x <- x %>%
            dplyr::select(unique_key = unique_key, Var1 = var1, Var2 = var2, value = estimate, pvalue = p.value) %>%
            dplyr::arrange(value, pvalue)


        rownames(x) <- NULL

        return(x)
    })
}


