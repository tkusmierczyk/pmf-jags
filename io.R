load <- function(path, N=NA, M=NA) {
  d <- read.csv(path, header=F, sep="\t")
  lims <- apply(d, 2, max)
  if (is.na(N)) N = lims[1]
  if (is.na(M)) M = lims[2]
  R <- matrix(nrow=N, ncol=M)
  R[ cbind(d$V1, d$V2) ] <- (d$V3-1)/(4)
  return (R)
}

load.multiple <- function(...) {
  lims = c()
  for (path in list(...)) {
    d <- read.csv(path, header=F, sep="\t")
    lims <- rbind(lims, apply(d, 2, max))
  }
  lims <- apply(lims, 2, max)
  N = lims[1]; M = lims[2]
  
  files = list()
  for (path in list(...)) {
    files[[path]] <- load(path, N, M)
  }
  return (files)
}

match.matrices.dims <- function(...) {
  matrices <- list(...)
  dims <- lapply(matrices, dim)
  dims <- matrix(unlist(dims), ncol = 2, byrow = TRUE)
  dims <- apply(dims, 2, max)
  expanded <- list()
  for (ix in 1:length(matrices)){
    old.matrix = matrices[[ix]]
    rows = 1: dim(old.matrix)[1]
    cols = 1: dim(old.matrix)[2]
    new.matrix <- matrix(nrow=dims[1], ncol=dims[2])
    new.matrix[rows, cols] <- old.matrix
    expanded[[ix]] <- new.matrix
  }
  return (expanded)
}

print.data.report <- function(train) {
  print(paste("  dim =", dim(train)))
  print(paste("  sparsity =", sum(is.na((train)))/(dim(train)[1]*dim(train)[2]) ))
  print(paste("  mean =", mean(train[!is.na(train)])))
  print(paste("  sd =", sd(train[!is.na(train)])))
}

