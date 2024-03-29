# Experiment Overview
This experiment is a baseline experiment using the [GCP's myriad loss functions](https://www.tensortoolbox.org/gcp_opt_fg_options_doc.html) to perform decompositions on data tensors drawn from a variety of known statistical distributions corresponding to the available loss funcitons.

The research questions being pursued are:

- Does using the loss function corresponding with the distribution used to generate a data tensor result in a "better" decomposition?
- How does sparsity of a data tensor impact the outcome of the previous question?

## General experimental structure
1. Generate a data tensor of a specified size using a specified distribution.
2. Estimate the rank of the generated tensor.
3. Create an set of factor matrices used to initialize the decomposition for each of loss functions used the same.
4. Perform decompostions using all relevant loss functions and gather metrics.
5. Compare results.

## Cases to explore
There are 4 general data cases to consider: 

- [ ] **REAL**

LOSSES: 

- normal 
- huber

- [ ] **NON-NEGATIVE REAL (continuous)**  

LOSSES: 

- normal (w/nn constraints)
- huber (w/nn constraints)
- rayleigh
- gamma
- negative-binomial
- beta

- [ ] **BINARY** 

LOSSES: 

- normal (w/nn constraints)
- huber (w/nn constraints)
- binary
- bernoulli-logit

- [ ] **COUNT** 

LOSSES: 

- normal (w/nn constraints)
- huber (w/nn constraints)
- count
- poisson-log

## Data collection regime
- 1000 runs generation-type (i.e. normal, rayleigh, beta, poisson-log, etc).
- A run consists of steps 1-4 detailed in **General experimental structure** section.
