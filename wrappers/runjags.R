print("runjags")

library(runjags)

rj = run.jags(model = model.file, 
               monitor = jags.params,
               data = jags.data, 
               inits = jags.inits,
               n.chains = n.chains, 
              burnin = n.burnin-1000, 
              adapt = 1000,
              thin = n.thin,
               sample = ceiling(n.iter/n.thin), #!
               keep.jags.files = F,
              summarise = F)

print("Retrieving output objects")

fit = combine.mcmc(rj) #merge chains
iterations = dim(fit)[1]

samples.u = array(dim = c(N, D, iterations))
for (i in 1:N) {
  for (d in 1:D) {
    col.name = paste("u[",i,",",d,"]", sep="")
    samples.u[i, d, ] = fit[ , col.name]
  }
}

samples.v = array(dim = c(M, D, iterations))
for (i in 1:M) {
  for (d in 1:D) {
    col.name = paste("v[",i,",",d,"]", sep="")
    samples.v[i, d, ] = fit[ , col.name]
  }
}
 
user_sample = function(i, k) {samples.u[i, , k]}
item_sample = function(j, k) {samples.v[j, , k]}

retrieved.u = apply(samples.u, c(1,2), mean)
retrieved.v = apply(samples.v, c(1,2), mean)

 
#ss <- summary(samples)
#m <- ss$statistics[,"Mean"]

#ss = as.array( rj$mcmc[ , ] )
#v = array(dim = c(M, D, ))
#rj$mcmc[,"v[1,1]"][[1]]
