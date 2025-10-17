# Activate renv for reproducible package management
source("renv/activate.R") # Temporarily commented for init

# Use binary packages (no compiler needed)
# Posit Package Manager provides binaries for faster installation
options(
  pkgType = "binary",
  repos = c(CRAN = "https://packagemanager.posit.co/cran/latest")
)

# Warn if R version is below the package floor
if (getRversion() < "4.0") {
  warning(
    "chmsflow requires R >= 4.0.0. ",
    "You are using R ", getRversion(), ". ",
    "Some features may not work correctly."
  )
}
