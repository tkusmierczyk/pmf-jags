#!/usr/bin/env Rscript
#setwd("~/Dropbox/PMF/jags/")

print("Trains and tests PMF model with JAGS. Use -h for help.")

##########################################################################################
# parsing parameters

#install.packages("optparse")
library("optparse")

option.list = list(
  make_option(c("-f", "--train"), type="character", default="data/artificial/u1.base", 
              help="train data file [default = %default]", metavar="character"),
  make_option(c("-t", "--test"), type="character", default="data/artificial/u1.test", 
              help="test data file [default = %default]", metavar="character"),
  make_option(c("-p", "--params"), type="character", default="params/hypnorm.R", 
              help="R script (from params// directory) that prepares model & learning parameters [default = %default]", 
              metavar="character"),
  make_option(c("-m", "--model"), type="character", default=NULL, 
              help="selects model file (overwrites the one selected in params file)", 
              metavar="character"), 
  make_option(c("-w", "--wrapper"), type="character", default="wrappers/R2jags.R", 
              help="selects JAGS wrappers (from wrappers// directory) [default = %default]", 
              metavar="character"), 
  make_option(c("-e", "--eval"), type="character", default="evaluation/baselines.R,evaluation/mle.R,evaluation/mle_g.R", 
              help="a list of comma-separated evaluation methods (from evaluation// directory) [default = %default]", 
              metavar="character"), 
  make_option(c("-s", "--save"), type="logical", default=F, action="store_true",
              help="saves the workspace when quitting (default off)", 
              metavar="character")
); 

opt_parser = OptionParser(option_list=option.list)
opt = parse_args(opt_parser);


##########################################################################################

print("Data loading")
source(file="io.R")
files = load.multiple(opt$train, opt$test)
train = files[[1]]; test = files[[2]]

# sparse representation:
ixs = which(!is.na(train), arr.ind =T)
userIxs = ixs[,1]
itemIxs = ixs[,2]
dataSize = length(itemIxs)

print(" train data:")
print.data.report(train)
print(" test data:")
print.data.report(test)

##########################################################################################

#params:
paste(paste("Loading parameters from file", opt$params))
source(file=opt$params)

if (!is.null(opt$model)) {
  print(paste(" overwriting model path with", opt$model))
  model.file = opt$model
}

##########################################################################################

#sampling:
paste(paste("Sampling with a wrapper from file", opt$wrapper))
start.time <- Sys.time()
source(file=opt$wrapper)
end.time <- Sys.time()
print(paste("execution time:", as.double(end.time - start.time)))
source("report.R")


##########################################################################################

#evaluation:
files = strsplit(opt$eval, ",")
for (f in files[[1]]) {
  print(paste("Evaluating with a method from file", f))
  source(file=f)
}

##########################################################################################
# saving

if (opt$save) {
  path = paste("pmf",gsub(" ", "_",Sys.time()),".RData", sep="_")
  print(paste("Storing workspace to", path))
  save.image(path)
  #load("movielens.RData")
}
##########################################################################################
##########################################################################################
