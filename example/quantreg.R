if (!require(pacman)) install.packages("pacman")

pacman::p_load(quantreg, ggplot2)

create_df <- function(n, std, add_outliers=FALSE) {
     set.seed(299792458)

     x <- runif(n, 0, 7)

     y <- 100 - 27 * x + rnorm(n, sd = std)

     flag <- rep("common", n)

     if (add_outliers) {
       xout <- runif(3, 6, 7)

       yout <- rnorm(3, 97)

       flagout <- rep("outlier", 3)

       x <- c(x, xout)

       y <- c(y, yout)

       flag <- c(flag, flagout)
     }

     return(data.frame(x, y, flag))
}

draw_vert_dist <- function(x0, model) {
     std <- sigma(lm_fit)
     coeffs <- coef(lm_fit)

     a <- coeffs[1]
     b <- coeffs[2]

     y0 <- a + b * x0

     segment <- data.frame(
          x = x0, y = y0 - (2 * std),
          xend = x0, yend = y0 + 2 * std
     )

     x <- seq(-2*std, 2*std, length.out = 50)
     y <- dnorm(x, 0, std/1.5)/dnorm(0, 0, std/1.5)

     path <- data.frame(x = y + x0, y = x + y0)


     return(
          list(
               geom_path(aes(x, y), data = path),
               geom_segment(
                    aes(x=x, y=y, xend=xend, yend=yend),
                    data = segment
               )
          )
     )
}

std <- 30

df <- create_df(n = 27, std=std)

df_out <- create_df(n = 27, std=std, add_outliers=TRUE)

lm_fit <- lm(y ~ x, data = df)

scatterplot <- ggplot(df, mapping = aes(x=x, y=y)) +
    geom_point() +
    labs(
      title = "Modelos de regressão", subtitle = "Funcionamento geral",
      x = "Variável explicativa", y = "Variável resposta"
    ) +
    theme_classic() +
    theme(legend.position="none")


scatterplot_out <- ggplot(df_out, mapping = aes(x=x, y=y)) +
  geom_point(aes(color=flag)) +
  labs(
    title = "Modelos de regressão", subtitle = "Funcionamento geral",
    x = "Variável explicativa", y = "Variável resposta"
  ) +
  theme_classic() +
  theme(legend.position="none")

scatterplot
ggsave("example/img/scatter1.pdf")


scatterplot +
  draw_vert_dist(1.5, lm_fit) +
  draw_vert_dist(3.5, lm_fit) +
  draw_vert_dist(5, lm_fit)

ggsave("example/img/scatter2.pdf")



scatterplot +
  geom_smooth(method=lm, se=FALSE, color="red")
ggsave("example/img/scatter3.pdf")


scatterplot +
  geom_smooth(method=lm, se=FALSE, color="red") +
  geom_quantile(quantiles=.5)
ggsave("example/img/scatter4.pdf")


scatterplot_out +
  geom_smooth(method = lm, se = FALSE, color = "red") +
  geom_quantile(quantiles=.5) +
  scale_color_manual(values=c("black", "red"))
ggsave("example/img/scatter5.pdf")

scatterplot_out +
  geom_smooth(method = lm, se = FALSE, color = "red") +
  geom_quantile() +
  scale_color_manual(values=c("black", "red"))
ggsave("example/img/scatter6.pdf")
