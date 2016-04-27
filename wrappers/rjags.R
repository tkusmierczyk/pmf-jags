
library(rjags)
print("rjags")

model = jags.model(model.file, jags.data, n.chains=n.chains, n.adapt=n.burnin) #n.adapt SEEM TO NOT WORK!
update(model)
samples = jags.samples(model, jags.params, n.iter=n.iter, thin=n.thin)

####################################################################################

#jags.samples:
retrieved.u = summary(samples$u, mean)$stat
retrieved.v = summary(samples$v, mean)$stat

per.chain = dim(samples$u)[3]
iterations = per.chain * dim(samples$u)[4]
user_sample = function(i, k) {samples$u[i, , (k-1)%%per.chain+1, ceiling(k/per.chain)]}
item_sample = function(j, k) {samples$v[j, , (k-1)%%per.chain+1, ceiling(k/per.chain)]}

#save.image(paste("rjags_",gsub(" ", "_",Sys.time()),".RData", sep="_"))
