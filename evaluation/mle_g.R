
#MLE:
r2 = matrix(nrow=N, ncol=M)
for (j in 1:M) {
  for (i in 1:N) {
    if (!is.na(test[i,j])) { #to speed up calculate only for test samples
      g = ((retrieved.u[i,] %*% retrieved.v[j,]))
      g = 1/(1+exp(-g))
      r2[i,j] <- g
    }
  }
}

##########################################################################################

#RMSE:
library(hydroGOF)
print(paste("mle rmse:",rmse(as.vector(test*4+1), as.vector(r2*4+1))))



