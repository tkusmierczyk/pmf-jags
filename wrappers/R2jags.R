
library(R2jags)

if (n.cluster<=1) {
  print("R2jags one-process")
  method = jags
} else {
  print("R2jags parallel")
  method = jags.parallel 
  jags.data[["jags.inits"]] = jags.inits #pass inits to each process
}

if (n.cluster>1 && n.chains>n.cluster) {
  warning("R2jags parallel may not support: n.chains>n.cluster.")
}

jags.inits.func <- function(){ jags.inits }
params = list(
  data=jags.data, 
  inits=jags.inits.func, 
  parameters.to.save=jags.params, 
  model.file=model.file,
  n.chains=n.chains, 
  n.iter=(n.iter + n.burnin), 
  n.burnin=n.burnin,
  n.thin=n.thin
)

if (n.cluster>1) { #set number of processes if parallel
  params[["n.cluster"]] = n.cluster 
}

jagsfit <- do.call(method, params)

attach.jags(jagsfit)

#########################################################################

retrieved.u = apply(u, c(2,3), mean)
retrieved.v = apply(v, c(2,3), mean)
#retrieved.u = apply(u, c(2,3), median)
#retrieved.v = apply(v, c(2,3), median)

iterations = dim(u)[1]
user_sample = function(i, k) {u[k, i, ]}
item_sample = function(j, k) {v[k, j, ]} 

#save.image(paste("R2jags_",gsub(" ", "_",Sys.time()),".RData", sep="_"))



