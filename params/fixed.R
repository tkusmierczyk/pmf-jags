

##########################################################################################

#learning params:
n.chains = 1
n.iter = 5000
n.burnin = n.iter
n.thin = 1 # max(1, floor((n.iter - n.burnin)/1000))
D = 10
lu = 0.05
lv = 0.05
n.cluster=n.chains

model.file = "models/pmf_fixed.bug"

##########################################################################################

N = dim(train)[1]
M = dim(train)[2]
start.s = sd(train[!is.na(train)])
start.su = sqrt(start.s^2/lu)
start.sv = sqrt(start.s^2/lv)

jags.data = list(N=N, M=M, D=D, r=train, s=start.s, su=start.su, sv=start.sv)
jags.params = c("u", "v")
jags.inits = list(u=matrix( rnorm(N*D,mean=0,sd=start.su), N, D), 
                  v=matrix( rnorm(M*D,mean=0,sd=start.sv), M, D))

##########################################################################################


