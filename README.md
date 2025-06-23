# chmsflow <img src="man/figures/logo.svg" align="right" width="180"/>

*chmsflow* supports the use of the Canadian Health Measures Survey (CHMS) by transforming variables from each cycle into harmonized, consistent versions that span survey cycles 1-6.

The CHMS is a cross-sectional survey administered by Statistics Canada that collects questionnaire and directly measured health information from community-dwelling individuals aged 3 to 79 living in the 10 provinces. Studies use multiple CHMS cycles to examine trends overtime and increase sample size to examine sub-groups that are too small to examine in a single cycle. CHMS data is not available to the public, but at Research Data Centres (RDCs) managed by Statistics Canada.

## Installation

```         
    # Install release version from CRAN
    install.packages("chmsflow")

    # Install the most recent version from GitHub
    devtools::install_github("Big-Life-Lab/chmsflow")
```

See below for guide on how to load R packages at RDC:

```         
    # Within quotations, define path to the directory where your package folders are located at RDC (ensure all dependencies are also in directory as well)
    .libPaths("")
    
    # Load chmsflow package
    library(chmsflow)
```

## What is in the `chmsflow` package?

*chmsflow* package includes:

1.  `variables.csv` - a list of variables that can be transformed across CHMS surveys.\
2.  `variable_details.csv` - information that describes how the variables are recoded.
3.  Vignettes - that describe how to use R to transform or generate new derived variables that are listed in `variables.csv`. Transformations are performed using `rec_with_table()`. `variables.csv` and `variable_details.csv`.

## Contributing

Please follow [this guide](https://github.com/Big-Life-Lab/chmsflow/blob/dev/CONTRIBUTING.md) if you would like to contribute to the *chmsflow* package.
