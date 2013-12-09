turn_it <- function(dataframe, len.col, turn = -pi/2) {
  dat <- dataframe
  dat[, "turn"] <- rep(turn, nrow(dataframe))
  dat <- within(dat, { 
    facing <- pi/2 + cumsum(turn)
    exp <- exp(1i * facing)
    move <- dat[, len.col] * exp(1i * facing)
    position <- cumsum(move)
    x2 <- Re(position)
    y2 <- Im(position)
    x1 <- c(0, head(x2, -1))
    y1 <- c(0, head(y2, -1))
  })
  
  dat[, c("x1", "y1", "x2", "y2")] <- 
    lapply(dat[, c("x1", "y1", "x2", "y2")], round, digits=0)
  data.frame(dataframe, dat)
}

n <- 15
set.seed(11)
(dat <- data.frame(id = paste("X", 1:n, sep="."), 
                   lens=sample(1:25, n, replace=TRUE)))

library("ggplot2")

ggplot(turn_it(dat, "lens"), aes(x = x1, y = y1, xend = x2, yend = y2)) + 
  geom_segment(aes(color=id), size=3,lineend = "round") + 
  ylim(c(-40, 10)) + xlim(c(-20, 40))
