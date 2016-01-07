

#Bayesian:
r2 = matrix(nrow=N, ncol=M)
progress.bar.step = ceiling(M/10)
for (j in 1:M) {
  if (j%%progress.bar.step==0) {
    print(paste(j, "of", M))
  }
  for (i in 1:N) {
    
    if (!is.na(test[i, j])) { #to speed up calculate only for test samples
      preds = rep(0, iterations)
      for (k in 1:iterations) {
        g = ((user_sample(i, k) %*% item_sample(j, k)))
        g = 1/(1+exp(-g))
        preds[k] = g
      }
      #u = samples$u[i,,,1]
      #v = samples$v[i,,,1]
      #g = diag(t(u) %*% v)
      #g = 1/(1+exp(-g))
      #preds = g
      r2[i,j] <- mean(preds)      
    }
    
  }
}


##########################################################################################

#RMSE:
library(hydroGOF)
print(paste("bayes rmse:",rmse(as.vector(test*4+1), as.vector(r2*4+1))))
