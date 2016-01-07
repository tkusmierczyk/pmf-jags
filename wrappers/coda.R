print("coda")

library(coda)
samples = coda.samples(model, jags.params, n.iter=n.iter, 
                       n.chains=n.chains, n.adapt=n.burnin,
                       thin=n.thin)

#coda.samples
############################################################################

ss <- summary(samples)
m <- ss$statistics[,"Mean"]
#m <- s$statistics[,"Median"]

retrieved.u = matrix(m[4: (4+N*D-1)], N, D)
retrieved.v = matrix(m[(4+N*D): length(m)], M, D)


iterations = ceiling( (n.iter * n.chains)/n.thin ) #TODO
user_sample = function(i, k) { stop("user_sample function not implemented for coda"); }
item_sample = function(j, k) { stop("item_sample function not implemented for coda"); }


