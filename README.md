# chmsflow <img src="man/figures/logo.svg" alt="chmsflow logo" align="right" width="180"/>

<!-- badges: start -->

[![Lifecycle: development](https://img.shields.io/badge/lifecycle-stable-green.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable-1) [![](https://img.shields.io/cran/v/chmsflow?color=green)](https://CRAN.R-project.org/package=chmsflow) ![](https://img.shields.io/github/v/release/big-life-lab/chmsflow?color=green&label=GitHub) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![](https://cranlogs.r-pkg.org/badges/chmsflow)](https://cran.r-project.org/package=chmsflow) [![R-CMD-check](https://github.com/Big-Life-Lab/chmsflow/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Big-Life-Lab/chmsflow/actions/workflows/R-CMD-check.yaml)

<!-- badges: end -->

`chmsflow` is an R package designed to simplify the use of the Canadian Health Measures Survey (CHMS). It harmonizes variables across different survey cycles (Cycles 1-6, 2007-2019), creating consistent and analysis-ready datasets.

## The Challenge of Harmonizing CHMS Data

The CHMS, administered by Statistics Canada, is a valuable resource for health research. It provides a rich collection of questionnaire and directly measured health data from a representative sample of Canadians. While the survey is conducted in cycles, combining data across these cycles can be challenging due to inconsistencies in variable names, coding schemes, and survey methodologies.

For example, a seemingly simple variable like ethnicity might be named `sdcdcgt` in one cycle and `pgdcgt` in another. These subtle changes can be difficult to track and can introduce errors into your analysis.

## How `chmsflow` Helps

`chmsflow` addresses these challenges by providing a set of tools to:

*   **Harmonize variables:** It automatically recodes variables to ensure consistency across survey cycles.
*   **Provide detailed documentation:** The package includes a comprehensive list of harmonized variables and their corresponding transformations.
*   **Streamline your workflow:** By handling the data cleaning and harmonization process, `chmsflow` allows you to focus on your research questions.

### Example: Harmonizing Ethnicity

Let's say you want to create a harmonized ethnicity variable for CHMS Cycle 3. With `chmsflow`, you can do this in a single line of code:

```r
# Load CHMS dummy data (included in chmsflow)
cycle3_ethnicity <- recodeflow::rec_with_table(cycle3, "pgdcgt", variable_details = variable_details)
```

The package will also print helpful notes to the console, alerting you to any potential issues with the data:

```
Using the passed data variable name as database_name
NOTE for pgdcgt: Respondents who respond as indigenous to previous question are identified as 'not applicable' in this question. Recode to "other", as per OCAP.
```

## Installation

You can install the latest version of `chmsflow` from CRAN or GitHub:

```r
# Install from CRAN
install.packages("chmsflow")

# Install from GitHub
devtools::install_github("Big-Life-Lab/chmsflow")
```

## Getting Started at the RDC

To use `chmsflow` at a Research Data Centre (RDC), you'll need to load the package and its dependencies from a local directory:

```r
# Set the library path to your local package directory
.libPaths("<path_to_your_package_directory>")

# Load the chmsflow package
library(chmsflow)
```

## Development setup

This package uses renv for dependency management. After cloning the repository:

```r
# Restore package dependencies
renv::restore()

# Install the package locally
devtools::install()
```

The project requires R >= 4.0.0. When you load the project, `.Rprofile` will warn if your R version is below this floor.

## What's Included?

The `chmsflow` package comes with several useful resources:

*   **`variables.csv`:** A comprehensive list of variables that can be harmonized across CHMS cycles.
*   **`variable_details.csv`:** Detailed information about how each variable is recoded.
*   **Vignettes:** Step-by-step guides on how to use `chmsflow` to transform and derive new variables.
*   **Dummy data:** A set of sample datasets that mimic the structure of the actual CHMS data.

You can load the dummy data for a specific cycle like this:

```r
# Read Cycle 2 dummy data
cycle2_dummy_data <- cycle2
```

## Important Considerations

While `chmsflow` simplifies the harmonization process, it's crucial to understand the underlying changes in the CHMS data. Be sure to review the package documentation and the original CHMS documentation to ensure that the transformations are appropriate for your research.

## Roadmap

For a list of planned features and improvements, please see the [project roadmap](https://github.com/Big-Life-Lab/chmsflow/projects).

## Contributing

We welcome contributions to `chmsflow`! If you'd like to get involved, please follow our [contributing guide](https://github.com/Big-Life-Lab/chmsflow/blob/dev/CONTRIBUTING.md).

## Statistics Canada Attribution

The dummy data included in this package is for illustrative purposes only and does not contain any real data from Statistics Canada.

This package is adapted from Statistics Canada, Canadian Health Measures Survey Cycles 1-6 (2007 to 2019), accessed June 2023. This does not constitute an endorsement by Statistics Canada of this product.