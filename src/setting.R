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
