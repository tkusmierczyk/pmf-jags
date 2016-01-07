#!/usr/bin/env Rscript

print("Generates two artificial files (training and testing data) according to PMF generative model.") 

#############################################################################

seed = 123

N = 10 #num users
M = 20 #num items
D = 3 #dimensionality

sv = 1
su = 1
s  = 0.2

sparsity = 0.8
train.fraction = 0.5

train.path = "data//artificial//u1.base"
test.path = "data//artificial//u1.test"

#############################################################################

print("Data generation parameters:")
for (p in ls()) { 
  print( paste(" ", p, "=", get(p)) )
}

#############################################################################

set.seed(seed, kind = NULL, normal.kind = NULL)


v = matrix(nrow=M, ncol=D)
for (j in 1:M) {
  for (d in 1:D) {
    v[j,d] = rnorm(1, 0, sv) 
  }
}

u = matrix(nrow=N, ncol=D)
for (i in 1:N) {
  for (d in 1:D) {
    u[i,d] = rnorm(1, 0, su) 
  }
}

mu = matrix(nrow=N, ncol=M)
r = matrix(nrow=N, ncol=M)
for (i in 1:N) {
  for (j in 1:M) {
    mu[i,j] = (u[i,] %*% v[j,])     
    r[i,j] = rnorm(1, mu[i,j], su) 
    r[i,j] = 1/(1+exp(-r[i,j])) #squashing?
    r[i,j] = round(r[i,j] * 4 + 1)
  }
}
r[sample(M*N, floor(sparsity*M*N))] = NA

#extract triples: user id, item id, rating
vals = which(!is.na(r), arr.ind=T)
train.ixs = sample(1:dim(vals)[1], floor(train.fraction*dim(vals)[1]))
train = vals[train.ixs, ] 
train = cbind(train, r[train])

test = vals[-train.ixs, ]
test = cbind(test, r[test])

#############################################################################

write.table(train, train.path, sep="\t", row.names=F, col.names=F)
write.table(test, test.path, sep="\t", row.names=F, col.names=F)

