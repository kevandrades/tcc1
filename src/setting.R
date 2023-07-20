if (!require(pacman)) install.packages("pacman")

pacman::p_load(
  dplyr, dtplyr, ggplot2, ggforce, viridis,
  stringr, gridExtra, corrplot, glue,
  forcats, tidyr, data.table, xtable,
  magrittr
)

theme_set(theme_bw())

get_lower_tri<-function(cormat){
  cormat[upper.tri(cormat)] <- NA
  return(cormat)
}
get_upper_tri <- function(cormat){
  cormat[lower.tri(cormat)]<- NA
  return(cormat)
}

read_tbl_ft <- function(filename) {
  ft <- fread(filename, select = select_columns)[ramo_justica == "Justiça do Trabalho"]

  setnafill(
    ft, fill=0,
    cols = ft %>% colnames() %>%
      (function(cols) cols[str_detect(cols, "ind") & !str_detect(cols, "max|min")])
  )

  ft[, formato := c("Eletrônico", "Físico", "Indisponível")[ifelse(id_formato < 1, 3, id_formato)]]

  return(ft)
}

