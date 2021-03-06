## Combine the estimates from different chromosomes, estimate the overall densities

######################################################################################################

library(RColorBrewer)
args <- commandArgs(TRUE)
set.seed(12345)

######################################################################################################

if(length(args)==3){
  chr.res.dir <- args[1]
  res.dir <- args[2]
  code.dir <- args[3]
  plots <- TRUE
  publication.plots <- TRUE
  include.densities <- FALSE
} else{
  stop("Need to specify 3 arguments")
}

######################################################################################################

source(paste(code.dir, "/libs/include.R", sep=""))
chrs <- 1:22

######################################################################################################

all.matched.haps <- list()
ll.mats <- rep(list(list()),6)
t.hats <- list()
subenv <- new.env()
logt.grid=NULL

## load saved results
cat("Loading data\n")
i=1
for(chr in chrs){
  cat(paste("\r", chr))
  this.matched.haps <- read.table(paste(chr.res.dir, "/chr", chr, "/results/matched_haps.txt.gz", sep=""), as.is=TRUE, header=TRUE)
  this.matched.haps$CHR <- chr
  all.matched.haps[[i]] <- this.matched.haps

  load(paste(chr.res.dir, "/chr", chr, "/results/ll_and_density_environment.Rdata", sep=""), envir=subenv)
  for(j in 1:6){
    ll.mats[[j]][[i]] <- subenv$ll.mats[[j]]
  }
  t.hats[[i]] <- subenv$t.hats

  if(i==1){
    logt.grid <- subenv$logt.grid
  }else if (!all(subenv$logt.grid==logt.grid)){
    stop("grids do not match")
  }
    
  
  i=i+1
}
cat("\n")

matched <- do.call("rbind", all.matched.haps)
rm(all.matched.haps)
for(j in 1:6){
  ll.mats[[j]] <- do.call("rbind", ll.mats[[j]])
}
t.hats <- do.call("rbind", t.hats)

denss <-rep(list(NA),6)
## save.image(paste(res.dir, "/ll_and_density_environment.Rdata", sep=""))
if(include.densities){
    cat("Sampling Densities\n")
    alpha <- round(0.05*NROW(matched))
    for(i in 1:6){
        ## Lg and D are dummy entries... the ll matrix is the only information we use... 
        denss[[i]] <- estimate.t.density.mcmc(0*matched$map.len ,0*matched$f2, Ne, p.fun, verbose=TRUE, logt.grid=logt.grid, prior=norm.2.p, alpha=alpha,error.params=NA, n.sims=10000, thin=100, ll.mat=ll.mats[[i]])
    }
}

max.log <- max(logt.grid)
labels=c("True (Lg)", "Observed (Lg)", "Corrected (Lg)", "True (Lg+S)", "Observed (Lg+S)", "Corrected (Lg+S)")
if(plots){png(paste(res.dir, "/compare_estimates.png", sep=""), height=1200, width=1800)}else{dev.new()}
par(mfrow=c(2,3))
for(i in 1:6){
    plot.mle.and.density(matched$Age, t.hats[,i], denss[[i]], main=labels[i], xlim=c(0,10^max.log), ylim=c(0,10^max.log), cex=2, alpha="10")
}
if(plots){dev.off()}

if(plots){pdf(paste(res.dir, "/coverage.pdf", sep=""), height=6, width=6)}else{dev.new()}
plot.coverage.curves(matched$Age, t.hats, labels=labels, lty=rep(1,6), lwd=1, cols=c("black", brewer.pal(5, "Set1")))
if(plots){dev.off()}

if(publication.plots){
    for(i in 1:6){
        png(paste0(res.dir, "/estimate.", labels[i], ".png"), height=600, width=600)
        plot.mle.and.density(matched$Age, t.hats[,i], NA, xlim=c(1,10^max.log), ylim=c(1,10^max.log), cex=2, alpha="10", col="#101010", line.col="red")
        dev.off()
    }
    png(paste0(res.dir, "/Figure2a.png"), height=600, width=600)
    options(scipen = 50)
    plot.mle.and.density(matched$Age, t.hats[,i], NA, xlim=c(1,10^4), ylim=c(1,10^4), cex=2, alpha="10", col="#101010", line.col="red")
    dev.off()

}

## Used these plot for illustration of the effect of using S. 
## plot.mle.and.density(matched$Age, t.hats[,3], denss[[3]], main=labels[i], xlim=c(0,max.log), ylim=c(0,max.log), cex=2, alpha="10")
## plot.mle.and.density(matched$Age, t.hats[,6], denss[[6]], main=labels[i], xlim=c(0,max.log), ylim=c(0,max.log), cex=2, alpha="10")
