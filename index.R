if (!require(pacman)) install.packages("pacman")

pacman::p_load(data.table, ggplot2)

ft_file <- "data/tbl_ft_sample.csv"

ft <- fread(ft_file) %>%
    filter(id_formato %in% c(1, 2)) %>%
    mutate(
        formato = c("Eletrônico", "Físico")[id_formato]
    )
# selecionando apenas formatos ou físico ou eletrônico7

ggplot(ft) +
    aes(x = formato, y = ind16_dias / ind16_proc) +
    geom_boxplot()

ggplot(ft) +
    aes(x = originario, y = ind16_dias / ind16_proc) +
    geom_boxplot()

ggplot(ft) +
    aes(x = sigla_grau, y = ind16_dias / ind16_proc) +
    geom_boxplot()

ggplot(ft) +
    aes(x = procedimento, y = ind16_dias / ind16_proc) +
    geom_boxplot()

ggplot(ft) +
    aes(x = ramo_justica, y = ind16_dias / ind16_proc) +
    geom_boxplot()
