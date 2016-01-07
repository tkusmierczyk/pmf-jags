
library(hydroGOF)

r.baseline = rep(mean(train[!is.na(train)]), dim(test)[1]*dim(test)[2])
print(paste("mean rmse:",rmse(as.vector(test*4+1), r.baseline*4+1)))

r.baseline = runif(dim(test)[1]*dim(test)[2], 0, 1)
print(paste("random rmse:",rmse(as.vector(test*4+1), r.baseline*4+1)))