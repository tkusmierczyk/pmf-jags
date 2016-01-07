
print.var <- function(name) {
  if (exists(name)) {
    print(paste(name,"=",get(name)))
  } else {
    print(paste(name,"does not exist"))
  }
}

print.vars <- function(names) {
  for (name in names) {
    print.var(name)
  }
}


########################################################################################

if (exists("s")) mean.s = mean(s)
if (exists("sv")) mean.sv = mean(sv)
if (exists("su")) mean.su = mean(su)

print.vars(c("start.time", "end.time", "model.file",
             "n.chains","n.iter", "iterations","n.burnin","n.thin",
             "D","lu","lv","n.cluster",
             "M","N","start.s","start.su","start.sv",
             "mean.s","mean.su","mean.sv"))
if(exists("u")) print(paste("dim(u) =", dim(u)))
if(exists("v")) print(paste("dim(v) =", dim(v)))
if(exists("jagsfit")) {
  print(jagsfit$model.file)
  #print(jagsfit$model[[1]])
}
