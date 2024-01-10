%% create 'cleaned' version of resulst (i.e. fits > 1)
fits_cl = fits;
fits_cl(fits_cl > 1) = NaN;
