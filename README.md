# chmsflow <img src="man/figures/logo.svg" align="right" width="180" alt = "chmsflow logo"/>

<!-- badges: start -->
[![R-CMD-check](https://github.com/Big-Life-Lab/chmsflow/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Big-Life-Lab/chmsflow/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

*chmsflow* supports the use of the Canadian Health Measures Survey (CHMS) by transforming variables from each cycle into harmonized, consistent versions that span survey cycles 1-6 (2007 to 2019).

The CHMS is a cross-sectional survey administered by Statistics Canada that collects questionnaire and directly measured health information from community-dwelling individuals aged 3 to 79 living in the 10 provinces. There are approximately 5,700 respondents per cycle. Studies use multiple CHMS cycles to examine trends overtime and increase sample size to examine sub-groups that are too small to examine in a single cycle. CHMS data is not available to the public, but at Research Data Centres (RDCs) managed by Statistics Canada. Information about the survey is found [here](https://www.statcan.gc.ca/en/survey/household/5071), while information about accessing data at the RDC is found [here](https://crdcn.ca/publications-data/access-crdcn-data/).

## Concept

Each cycle of the CHMS contains over 1000 variables that cover the four main topics: sociodemographic measures, socioeconomic measures, health behaviours, and health status. The *seemingly* consistent questions across CHMS cycles entice you to combine them together to increase sample size; however, you soon realize a challenge...

Imagine you want to use ethnicity for a study that spans all six cycles of the CHMS. Ethnicity *seems* like a straightforward measure that is routinely-collected worldwide. Indeed, ethnicity is included in all CHMS cycles. You examine the documentation and find the variable `sdcdcgt` in the first two cycles corresponds to ethnicity, but that for the last four cycles, the variable name changes to `pgdcgt`. These types of changes occur for many CHMS variables. Sometimes the changes are subtle and difficult to find in the documentation, even for seemingly straightforward variables such as ethnicity. `chmsflow` harmonizes the ethnicity variable across different cycles.

## Usage

`chmsflow` creates harmonized variables (where possible) between CHMS cycles. Searching ethnicity in `variables.csv` shows `pgdcgt` collects ethnicity across all cycles for all respondents.

*Calculate a harmonized ethnicity variable for CHMS cycle 3*

```         
    # Load synthetic CHMS data - included in chmsflow

    cycle3_ethnicity <- recodeflow::rec_with_table(cycle3, "pgdcgt", variable_details = variable_details)
    
```

Notes printed to console indicate issues that may affect ethnicity classification for your study.

```         
Using the passed data variable name as database_name
NOTE for pgdcgt: Respondents who respond as indigenous to previous question are identified as 'not applicable' in this question. Recode to "other", as per OCAP.
```

## Important notes

Care must be taken to understand how specific variable transformation and harmonization with `chmsflow` affect your study or use of CHMS data. Across survey cycles, many CHMS variables have had at least some change in wording and category responses. Furthermore, there have been changes in survey sampling, response rates, weighting methods and other survey design changes that affect responses.

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

1.  `variables.csv` - a list of variables that can be transformed across CHMS surveys.
2.  `variable_details.csv` - information that describes how the variables are recoded.
3.  Vignettes - that describe how to use R to transform or generate new derived variables that are listed in `variables.csv`. Transformations are performed using `rec_with_table()`. `variables.csv` and `variable_details.csv`.
4.  Synthetic CHMS data - `chmsflow` includes synthetic data used for the vignettes and to imitate actual CHMS data housed at the RDC. The synthetic CHMS data is stored in /data as .RData files. They can be read as a package database.

```         
# Read synthetic cycle 2 data

synthetic_cycle2_data <- cycle2
```

### Roadmap

Project on the roadmap can be found on [here](https://github.com/Big-Life-Lab/chmsflow/projects).

## Contributing

Please follow [this guide](https://github.com/Big-Life-Lab/chmsflow/blob/dev/CONTRIBUTING.md) if you would like to contribute to the *chmsflow* package.

We encourage PRs for additional variable transformations and derived variables that you believe may be helpful to the broad CHMS community.

Currently, *chmsflow* supports R through the `rec_with_table()` function of *recodeflow*. The CHMS community commonly uses SAS, Stata and other statistical packages. Please feel free to contribute to `chmsflow` by making a PR that creates versions of `rec_with_table()` for other statistical and programming languages.

## Statistics Canada Attribution

CHMS data used in this library is synthetic in nature and consists of no actual data.

Adapted from Statistics Canada, Canadian Health Measures Survey Cycles 1-6 (2007 to 2019), accessed June 2023. This does not constitute an endorsement by Statistics Canada of this product.
