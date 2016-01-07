# pmf-jags: Probabilistic Matrix Factorization with JAGS in R
====================

The project is devoted to provide an educational framework for Probabilistic Matrix Factorization with JAGS in R. The original idea is taken from: `Mnih, Andriy, and Ruslan Salakhutdinov. "Probabilistic matrix factorization." In Advances in neural information processing systems, pp. 1257-1264. 2007.`. The current version contains several variations of the original models, several encapsulated wrappers for JAGS and a few evaluation methods.



# Content
* `models` - various BUGS/JAGS models  
* `wrappers` - JAGS wrappers for PMF in R
* `params` - scripts for parameters preparation
* `evaluation` - evaluation methods
* `run.R` - the main script that loads data, prepares parameters, run samplers and evaluates results
* `data` - sample data (including a part of ml-100k movielens subset)
* `data_generator.R` - a script that generates sample input data

# Data and representation

Data contains *N* users, *M* items and *dataSize* ratings from range 1-5. Input (train & test) files should follow the format of [movielens ml-100k](http://grouplens.org/datasets/movielens/100k/). 

However the input data is sparse, internally (in models) two representations can be used. Different models can work with one or the another representation:
* dense *train* and *test* matrices with NAs for missing elements 
* sparse matrix *ixs* (with users in the first row and items in the second) along with two vectors *userIxs = ixs[,1]* and *itemIxs = ixs[,2]*. Number of rows is passed as a *dataSize* parameter.


# Models

Users and items are represented by *D* latent factors (per each user and per each item) and stored in matrices *u* (*N x D*) and *v* (*M x D*). Ratings and latent representations are believed to be sampled with distributions parametrized with deviations *s*, *su*, *sv*. However models can differ in manifold ways. 

Few models work with the dense representation where missing ratings are represented with non-observed nodes (=NAs) and some with the sparse representation where missing ratings are not represented as nodes at all. Although it is not obvious both representations seems to be equivalent. 

Some models apply squashing function *g(x)=1/(1+exp(-x))* whereas others not. If *g* is applied a noise (measured with the standard deviation of ratings *s*) can be added either before or after squashing. 

Furthermore, deviations *s* (ratings), *su* (users), *sv* (items) can be sampled from various distributions or passed as fixed parameters.

Different variations of the initial model perform differently:
* `pmf_fixed.bug` - dense representations, no squashing, deviations *s*, *su*, *sv* as fixed parameters
* `pmf_hypnorm3.bug` - dense representations, squashing, noise added after squashing, deviations *s*, *su*, *sv* sampled from *~ uniform(0,100)*
* `pmf_hypnorm2.bug` - dense representations, no squashing, deviations *s*, *su*, *sv* sampled from *~ uniform(0,100)*
* `pmf_hypnorm.bug` - dense representations, squashing, noise added before squashing, deviations *s*, *su*, *sv* sampled from *~ uniform(0,100)*
* `pmf_hypnorm_sparse2.bug` - sparse representations, squashing, noise added before squashing, deviations *s*, *su*, *sv* sampled from *~ uniform(0,100)*
* `pmf_hypnorm_sparse.bug` - sparse representations, squashing, noise added after squashing, deviations *s*, *su*, *sv* sampled from *~ uniform(0,100)*

# Wrappers

Different JAGS wrappers can be found on-line (it is not always clear what were the motivations of their authors). Output formats and parametrizations are different. To make use of some of them in the unified way, the following scripts (`wrappers` directory) are provided:
* `R2jags.R`  
* `rjags.R`  
* `runjags.R`
* `coda.R`  

Each of the scripts makes use of similar set of parameters (see below) and provides standarized output (that is stored to the R namespace):
* *retrieved.u* - *N x D*-dimensional matrix of users latent factors 
* *retrieved.v* - *M x D*-dimensional matrix of items latent factors 
* *iterations* - a number of generated samples
* *user_sample* - a function *(i, k)* that returns D-dimensional, k-th sample of i-th user
* *item_sample* - a function *(j, k)* that returns D-dimensional, k-th sample of j-th item

Additionally, `R2jags.R` supports parallel computing. If *n.cluster>1* parallel version is used. However the condition *n.chains>n.cluster* must hold.


# Parameters

Scripts from `params` directory prepares objects *jags.data*, *jags.inits*, *jags.params* that are required by samplers and used in models. 

Currently, the following scenarios are modelled:
* `fixed.R` - dense representation, fixed deviations *s*, *su*, *sv*
* `hypnorm.R` - dense representation, deviations *s*, *su*, *sv* sampled
* `sparse.R` - sparse representation, deviations *s*, *su*, *sv* sampled

The objects are prepared according to the parameters (typically only these parameters are modified):
* *model.file* - model path (can be overwritten with a parameter of the main script)
* *n.chains* - number of chains
* *n.iter* - number of iterations per chain, excluding *n.burnin* (after adaptation phase), before thinning
* *n.burnin* - adaptation phase length (thinning does not apply here)
* *n.thin* - thinning
* *D* - latent factors dimensionality
* *lu* - a proportion between *su* and *s* (see the paper)
* *lv* - a proportion between *sv* and *s* (see the paper)
* *n.cluster* - number of processes (for parallel computing)

# Evaluation

Evaluation is done on the output of the wrappers (see above) with the help of supplied test data. Currently the following strategies are implemented:
* `baselines.R` - pmf-blind baselines: random prediction and mean from the training  
* `mle_g.R` - predictions based on expected values of latent matrices *retrieved.u* and *retrieved.v* (with squashing *g*)
* `mle.R` - predictions based on expected values of latent matrices *retrieved.u* and *retrieved.v* (without squashing *g*)
* `bayesian_g.R` - fully bayesian predictions based on summing over samples with the help of *user_sample* and *item_sample* functions (with squashing *g*)
* `bayesian.R` - fully bayesian predictions based on summing over samples with the help of *user_sample* and *item_sample* functions (without squashing *g*)


# Main script

The main script `run.R` is responsible for selecting the input data, parameters, wrappers and evaluation methods according to parameters: 

```
Usage: Rscript run.R [options]

Options:
	-f CHARACTER, --train=CHARACTER
		train data file [default = data/artificial/u1.base]

	-t CHARACTER, --test=CHARACTER
		test data file [default = data/artificial/u1.test]

	-p CHARACTER, --params=CHARACTER
		R script (from params// directory) that prepares model & learning parameters [default = params/hypnorm.R]

	-m CHARACTER, --model=CHARACTER
		selects model file (overwrites the one selected in params file)

	-w CHARACTER, --wrapper=CHARACTER
		selects JAGS wrappers (from wrappers// directory) [default = wrappers/R2jags.R]

	-e CHARACTER, --eval=CHARACTER
		a list of comma-separated evaluation methods (from evaluation// directory) [default = evaluation/baselines.R,evaluation/mle.R,evaluation/mle_g.R]

	-s, --save
		saves the workspace when quitting (default off)

	-h, --help
		Show help message and exit
```

Sample run:
```
Rscript run.R -f data/artificial/u1.base -t data/artificial/u1.test -p params/hypnorm.R -m models/pmf_hypnorm.bug -w wrappers/runjags.R -e evaluation/baselines.R,evaluation/mle_g.R,evaluation/bayesian_g.R
```

# Experiments

Some of the above models were experimentally compared on movielens data. Results can be found below.

## Settings

* data: movielens 100k (`u1.base` + `u1.test` from the `data//ml-100k//`)
* `R2jags.R` wrapper  
* 1 chain, 5k burin iterations, 5k samples, thin=1.

## Baselines:

* train data mean baseline: rmse = 1.154
* random baseline: rmse = 1.713


## Initalization:
* *start.s* = mean over training sample = 0.28
* *start.su = sqrt(start.s^2/0.05)* = 1.25
* *start.sv = sqrt(start.s^2/0.05)* = 1.25
* *u ~ N(0, start.su)*
* *v ~ N(0, start.sv)*

## Results

 | model                     | RMSE  | RMSEb | E(s)  | E(su) | E(sv) |
 |---------------------------|-------|-------|-------|-------|-------|
 | `pmf_hypnorm3.bug`        | 0.947 | 0.943 | 0.187 | 0.482 | 0.789 |
 | `pmf_hypnorm_sparse.bug`  | 0.951 | 0.941 | 0.187 | 0.597 | 0.634 |
 | `pmf_hypnorm2.bug`        | 1.072 | 1.055 | 0.192 | 0.325 | 0.387 |
 | `pmf_hypnorm_sparse2.bug` | 1.006 | 1.038 | 2.515 | 0.971 | 0.941 |
 | `pmf_hypnorm.bug`         | 1.022 | ?     | 2.515 | 0.815 | 1.124 |
 | `pmf_hypnorm.bug` x1      | 1.011 | ?     | 2.514 | 0.381 | 2.418 |
 | `pmf_fixed.bug` x2        | 1.062 | 1.077 | ?     | ?     | ?     |
 
- RMSEb - bayesian
- x1 (`rjags.R` instead of `R2jags.R`)
- x2 (s=0.28, su=1.25, sv=1.25)


# Further reading

* [Convergence diagnostics tutorial](http://www.people.fas.harvard.edu/~plam/teaching/methods/convergence/convergence_print.pdf)
* [R functions to filter rjags results](https://johnbaumgartner.wordpress.com/2012/06/07/r-functions-to-filter-rjags-results/)
* ...

# TODO

* new model: Wishart priors for *s*, *su*, *sv*
* coda wrapper
