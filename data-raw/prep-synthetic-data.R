# variables and variable-details
library(here)

variables <- read.csv(here("inst", "extdata", "variables.csv"))
variable_details <- read.csv(here("inst", "extdata", "variable-details.csv"))

usethis::use_data(variables, overwrite = TRUE)
usethis::use_data(variable_details, overwrite = TRUE)

# cycle 2
cycle2 <- data.frame(
  clinicid = c(1, 2, 3, 4),
  clc_age = c(20, 30, 40, 50),
  clc_sex = c(1, 2, 1, 2),
  sdcdcgt = c(1, 1, 1, 2),
  lab_hba1 = c(0.07, 0.06, 0.05, 0.04),
  lab_bcre = c(20, 30, 40, 50),
  bpmdpbps = c(140, 130, 120, 110),
  bpmdpbpd = c(95, 85, 75, 65),
  ccc_51 = c(1, 2, 2, 2),
  ccc_61 = c(2, 2, 2, 2),
  ccc_63 = c(2, 2, 2, 2),
  ccc_81 = c(1, 2, 2, 1),
  ccc_32 = c(2, 1, 1, 1)
)

cycle2_meds <- data.frame(
  clinicid = c(1, 2, 3, 4),
  atc_101a = c("C07AA05", "C09AA06", "C08CA01", "A10BC02"),
  atc_102a = c("A01AB05", "C09AA02", "C07AB02", "C03AA03"),
  atc_103a = c("C02CC07", "C08CA06", "C07AB07", "C07AB03"),
  atc_104a = c("C03CA01", "C03CA01", "C09AA04", "C08CA02"),
  atc_105a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_106a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_107a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_108a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_109a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_110a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_111a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_112a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_113a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_114a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_115a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_201a = c("C03BA08", "C07AA07", "C07AA12", "M01AG02"),
  atc_202a = c("C07AA05", "C09AA06", "C08CA01", "A10BC02"),
  atc_203a = c("C03BA08", "C07AA07", "C07AA12", "M01AG02"),
  atc_204a = c("C03BC02", "C08CA01", "C07AA05", "C07AA06"),
  atc_205a = c("C02KX01", "C02AA05", "C07AG02", "C07AA06"),
  atc_206a = c("A01AB05", "C09AA02", "C07AB02", "C03AA03"),
  atc_207a = c("C02CC07", "C08CA06", "C07AB07", "C07AB03"),
  atc_208a = c("C03CA01", "C03CA01", "C09AA04", "C08CA02"),
  atc_209a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_210a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_211a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_212a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_213a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_214a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_215a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_131a = c("C07AA05", "C09AA06", "C08CA01", "A10BC02"),
  atc_132a = c("C03BA08", "C07AA07", "C07AA12", "M01AG02"),
  atc_133a = c("C03BC02", "C08CA01", "C07AA05", "C07AA06"),
  atc_134a = c("C02KX01", "C02AA05", "C07AG02", "C07AA06"),
  atc_135a = c("A01AB05", "C09AA02", "C07AB02", "C03AA03"),
  atc_231a = c("C02CC07", "C08CA06", "C07AB07", "C07AB03"),
  atc_232a = c("C03CA01", "C03CA01", "C09AA04", "C08CA02"),
  atc_233a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_234a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  atc_235a = c("C09AA04", "C07AB02", "C08CA02", "A10BD05"),
  mhr_101b = c(2, 3, 1, 3),
  mhr_102b = c(1, 4, 3, 2),
  mhr_103b = c(3, 2, 1, 4),
  mhr_104b = c(1, 2, 4, 3),
  mhr_105b = c(3, 2, 1, 4),
  mhr_106b = c(3, 2, 1, 4),
  mhr_107b = c(3, 2, 1, 4),
  mhr_108b = c(3, 2, 1, 4),
  mhr_109b = c(3, 2, 1, 4),
  mhr_110b = c(3, 2, 1, 4),
  mhr_111b = c(3, 2, 1, 4),
  mhr_112b = c(3, 2, 1, 4),
  mhr_113b = c(3, 2, 1, 4),
  mhr_114b = c(3, 2, 1, 4),
  mhr_115b = c(3, 2, 1, 4),
  mhr_201b = c(3, 2, 2, 3),
  mhr_202b = c(2, 3, 1, 3),
  mhr_203b = c(3, 2, 2, 3),
  mhr_204b = c(3, 1, 5, 1),
  mhr_205b = c(1, 2, 3, 4),
  mhr_206b = c(1, 4, 3, 2),
  mhr_207b = c(3, 2, 1, 4),
  mhr_208b = c(1, 2, 4, 3),
  mhr_209b = c(3, 2, 1, 4),
  mhr_210b = c(3, 2, 1, 4),
  mhr_211b = c(3, 2, 1, 4),
  mhr_212b = c(3, 2, 1, 4),
  mhr_213b = c(3, 2, 1, 4),
  mhr_214b = c(3, 2, 1, 4),
  mhr_215b = c(3, 2, 1, 4),
  mhr_131b = c(2, 3, 1, 3),
  mhr_132b = c(3, 2, 2, 3),
  mhr_133b = c(3, 1, 5, 1),
  mhr_134b = c(1, 2, 3, 4),
  mhr_135b = c(1, 4, 3, 2),
  mhr_231b = c(3, 2, 1, 4),
  mhr_232b = c(1, 2, 4, 3),
  mhr_233b = c(3, 2, 1, 4),
  mhr_234b = c(3, 2, 1, 4),
  mhr_235b = c(3, 2, 1, 4)
)

usethis::use_data(cycle2, overwrite = TRUE)
usethis::use_data(cycle2_meds, overwrite = TRUE)

# cycle 3
cycle3 <- data.frame(
  clinicid = c(1, 2, 3, 4),
  clc_age = c(20, 30, 40, 50),
  clc_sex = c(1, 2, 1, 2),
  pgdcgt = c(1, 1, 1, 2),
  lab_hba1 = c(0.07, 0.06, 0.05, 0.04),
  lab_bcre = c(20, 30, 40, 50),
  bpmdpbps = c(140, 130, 120, 110),
  bpmdpbpd = c(95, 85, 75, 65),
  ccc_51 = c(1, 2, 2, 2),
  ccc_61 = c(2, 2, 2, 2),
  ccc_63 = c(2, 2, 2, 2),
  ccc_81 = c(1, 2, 2, 1),
  ccc_32 = c(2, 1, 1, 1)
)

num_vars_cycle3 <- ncol(cycle3) - 1
clinicids <- unique(cycle3$clinicid)
n_clinicids <- length(clinicids)

cycle3_meds <- data.frame(
  clinicid = rep(clinicids, each = num_vars_cycle3),
  meucatc = rep(c("C07AA05", "C09AA06", "C08CA01", "A10BC02"), length.out = num_vars_cycle3 * n_clinicids),
  npi_25b = rep(c(2, 3, 1, 3), length.out = num_vars_cycle3 * n_clinicids)
)

usethis::use_data(cycle3, overwrite = TRUE)
usethis::use_data(cycle3_meds, overwrite = TRUE)

# cycle 4
n <- 1000
set.seed(123)

ages <- sample(c(18:75), n, replace = TRUE)
sexes <- sample(c(1:2), n, replace = TRUE)
systolic_bps <- sample(c(80:215, 996:999), n, replace = TRUE)
diastolic_bps <- sample(c(50:150, 996:999), n, replace = TRUE)

cycle4 <- data.frame(clc_age = ages, clc_sex = sexes, bpmdpbps = systolic_bps, bpmdpbpd = diastolic_bps)

usethis::use_data(cycle4, overwrite = TRUE)

# cycle 5
cycle5 <- data.frame(
  ccc_51 = sample(1:2, 1000, replace = TRUE), # Binary
  edudr04 = sample(1:3, 1000, replace = TRUE), # 3 categories
  fmh_15 = sample(1:2, 1000, replace = TRUE), # Binary
  gendmhi = sample(1:2, 1000, replace = TRUE), # Binary
  gen_025 = sample(1:2, 1000, replace = TRUE), # Binary
  gen_045 = sample(1:2, 1000, replace = TRUE), # Binary
  clc_sex = sample(1:2, 1000, replace = TRUE), # Binary
  wgt_full = runif(1000, 0, 1), # Continuous weights
  clc_age = runif(1000, 18, 90), # Continuous
  hwmdbmi = runif(1000, 18, 40), # Continuous
  totalfv = runif(1000, 0, 10), # Continuous
  slp_11 = runif(1000, 4, 12), # Continuous
  diabx = sample(1:2, 1000, replace = TRUE), # Binary
  cycle = sample(1:6, 1000, replace = TRUE), # Cycle variable ranging from 1 to 6
  ccc_32 = sample(1:2, 1000, replace = TRUE), # Binary
  alcdwky = sample(0:84, 1000, replace = TRUE), # Integer alcohol consumption per week
  gendhdi = sample(0:4, 1000, replace = TRUE), # Categorical health-disease index
  hwm_13kg = runif(1000, 40, 150), # Numeric weight in kg
  hwm_14cx = runif(1000, 60, 200), # Numeric chest circumference in cm
  img_03 = sample(1:2, 1000, replace = TRUE), # Binary image analysis variable
  lab_bpb = runif(1000, 60, 160), # Numeric blood pressure measurement
  lab_hba1 = runif(1000, 4, 14), # Numeric HbA1c
  pgdcgt = sample(1:13, 1000, replace = TRUE) # Categorical food group codes (removed comma)
)

usethis::use_data(cycle5, overwrite = TRUE)
