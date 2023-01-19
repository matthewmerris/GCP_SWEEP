# Experiment Overview
This experiment is a baseline experiment using the GCP's myriad loss functions to perform decompositions on data tensors drawn from a variety of known statistical distributions corresponding to the available loss funcitons.

The research questions being pursued are:

- Does using the loss function corresponding with the distribution used to generate a data tensor result in a "better" decomposition?
- How does sparsity of a data tensor impact the outcome of the previous question?

## General experimental structure
1. Generate a data tensor of a specified size using a specified distribution.
2. Estimate the rank of the generated tensor
3. Create an set of factor matrices used to initialize the decomposition for each of loss functions used the same.
4. Perform decompostions and gather metrics
5. Compare results

## Cases to explore
There are 4 general data cases to consider: 

- [ ] real,
- [ ] non-negative real,
- [ ] binary, 
- [ ] count.

