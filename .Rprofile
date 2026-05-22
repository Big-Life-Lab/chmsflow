# Activate renv for reproducible package management
source("renv/activate.R")

# Use binary packages (no compiler needed)
# Posit Package Manager provides binaries for faster installation
options(
  pkgType = "binary",
  repos = c(CRAN = "https://cloud.r-project.org")
)

# Warn if R version is below the package floor
if (getRversion() < "4.0") {
  warning(
    "chmsflow requires R >= 4.0.0. ",
    "You are using R ", getRversion(), ". ",
    "Some features may not work correctly."
  )
}
