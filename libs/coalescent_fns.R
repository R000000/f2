## Some helpful coalescent functions

########################################################################
## The function qn gives the expected ratio of the total branch length
## to 2t, conditional on the total height T=t
########################################################################

q1 <- function(t){
    0*t+1
}

q2 <- function(t){
    0*t+1
}

q3 <- function(t){
  val <- 1.25 + 0.25/t - 0.25*(exp(t)+exp(-t))/(exp(t)-exp(-t))
  return(ifelse(t<0.00001, 1.25, val))                                                
}

q4 <- function(t){
    top <- 44+240*t-25*exp(3*t)*(5+18*t)+9*exp(5*t)*(9+20*t)
    bottom <- 60*(2-5*exp(3*t)+3*exp(5*t))*t
    return(ifelse(t<0.0001, 1.5, top/bottom))
}

q5 <- function(t){
    top <- 196*exp(9*t)*(37+60*t)-300*exp(7*t)*(47+126*t)+147*exp(4*t)*(59+240*t)-25*(73+420*t)
    bottom <- 840*(-5+21*exp(4*t)-30*exp(7*t)+14*exp(9*t))*t
    return(ifelse(t<0.0001, 1.75, top/bottom))
}
