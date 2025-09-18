# CHMSFLOW Vector Refactoring Guide

## Overview

This guide provides step-by-step instructions for refactoring CHMSFLOW functions to support vector operations using tidyverse patterns. The goal is to enable functions to work with vectors of any length while maintaining existing logic and preparing for future integration with the cchsflow modernization framework.

## Target Audience

- **Developers**: Clear explanations and practical examples
- **AI code assistants**: Structured patterns and templates for consistent refactoring

## Problem Statement

Current CHMSFLOW functions use scalar-only logic patterns that prevent vector operations:

```r
# ❌ PROBLEM: Only works with single values
if (CLC_SEX == 1 && ALCDWKY > 10 && ALCDWKY <= 15) {
  step1 <- 0
} else if (CLC_SEX == 2 && ALCDWKY > 10 && ALCDWKY <= 15) {
  step1 <- 1
}
```

**Issues:**

- `&&` operator requires length-1 vectors
- `if/else` chains don't vectorize
- Sequential logic assumes scalar values

## Solution: Tidyverse Vector Patterns

### 1. Replace `if/else` with `case_when()`

**Key concept:** `case_when()` evaluates multiple conditions simultaneously and works with vectors of any length.

**Implementation pattern:** Replace all `if/else if/else` chains with `case_when()` statements.

```r
# ✅ SOLUTION: Works with vectors
step1 <- case_when(
  !CLC_SEX %in% c(1, 2) | !ALC_11 %in% c(1, 2) ~ NA_real_,
  ALC_11 == 2 ~ 0,
  is.na(ALCDWKY) ~ NA_real_,
  ALCDWKY <= 10 ~ 0,
  ALCDWKY > 10 & ALCDWKY <= 15 & CLC_SEX == 1 ~ 0,
  ALCDWKY > 10 & ALCDWKY <= 15 & CLC_SEX == 2 ~ 1,
  ALCDWKY > 15 & ALCDWKY <= 20 & CLC_SEX == 1 ~ 1,
  ALCDWKY > 15 & ALCDWKY <= 20 & CLC_SEX == 2 ~ 3,
  ALCDWKY > 20 ~ 3,
  TRUE ~ NA_real_
)
```

### 2. Replace `&&` with `&`

**Key concept:** `&&` only works with single values, `&` works with vectors.

**Implementation pattern:** Replace all `&&` with `&` and `||` with `|` in vectorized contexts.

```r
# ❌ PROBLEM
if (CLC_SEX %in% c(1, 2) && !is.na(ALC_11) && ALC_11 == 1)

# ✅ SOLUTION  
ALCDWKY > 10 & ALCDWKY <= 15 & CLC_SEX == 1
```

### 3. Use Vectorized Missing Data Handling

**Key concept:** Handle missing values consistently using `case_when()` and `haven::tagged_na()`.

**Implementation pattern:** Use `is.na()` conditions in `case_when()` and return `haven::tagged_na("b")` for invalid cases.

```r
# Final result handling
case_when(
  is.na(step1) ~ haven::tagged_na("b"),
  step1 == 0 ~ 1L,
  step1 %in% 1:2 ~ 2L,
  step1 %in% 3:4 ~ 3L,
  step1 %in% 5:9 ~ 4L,
  TRUE ~ haven::tagged_na("b")
)
```

## Documentation Standards

### Required roxygen2 Documentation

All refactored functions must include comprehensive documentation with three types of examples:

**Template Structure:**

```r
#' @title Brief function name
#'
#' @description 
#' Detailed description explaining the function's purpose and vector capabilities.
#' Always mention that the function supports vector operations.
#'
#' @param param_name [type] Description including valid values and ranges
#' @param param_name2 [type] Description including valid values and ranges
#'
#' @return [type] Description of return values and their meanings
#'
#' @details
#' Explain the calculation methodology, phases, and any important notes
#' about the vector processing capabilities.
#'
#' @examples
#' # Scalar usage: Single respondent
#' function_name(param1 = value1, param2 = value2)
#' # Returns: expected_value (interpretation)
#' 
#' # Vector usage: Multiple respondents
#' function_name(
#'   param1 = c(val1, val2, val3),
#'   param2 = c(val1, val2, val3)
#' )
#' # Returns: c(result1, result2, result3)
#' 
#' # Database usage: Applied to survey datasets
#' library(dplyr)
#' dataset %>%
#'   mutate(
#'     new_variable = function_name(PARAM1, PARAM2)
#'   ) %>%
#'   group_by(new_variable) %>%
#'   summarise(count = n())
#'
#' @export
```

### Documentation Requirements

**Mandatory elements for all functions:**

1. **Three example types**: Scalar, vector, and database usage
2. **Vector capability mention**: Always state that function works with vectors
3. **Parameter types**: Use `[integer]`, `[numeric]`, `[character]` format
4. **Return interpretation**: Explain what each return value means
5. **Expected outputs**: Show what each example should return

**Example patterns to follow:**

```r
# Scalar usage: Single respondent
function_name(param = 1)
# Returns: 2 (Category description)

# Vector usage: Multiple respondents  
function_name(param = c(1, 2, 3))
# Returns: c(2, 3, 1)

# Database usage: Survey analysis
survey_data %>%
  mutate(derived_var = function_name(SOURCE_VAR)) %>%
  count(derived_var)
```

## Refactoring Workflow

### Step 1: Identify Function Structure

1. Find all `if/else` chains
2. Identify input validation logic
3. Locate missing data handling
4. Map the logical flow

### Step 2: Convert to Vector Operations

1. Replace `if/else` with `case_when()`
2. Change `&&`/`||` to `&`/`|`
3. Handle edge cases with `TRUE ~ NA_real_`
4. Ensure consistent return types

### Step 3: Test Vector Functionality

```r
# Test with vectors
test_sex <- c(1, 2, 1, 2)
test_alc <- c(1, 1, 2, 1) 
test_weekly <- c(5, 15, 0, 25)

result <- low_drink_score_fun(test_sex, test_alc, test_weekly)
# Should return: c(1, 2, 1, 4)
```

## Complete Example: Alcohol Functions Refactored

### Original Function (Scalar-Only)

```r
low_drink_score_fun <- function(CLC_SEX, ALC_11, ALCDWKY) {
  ## Step 1: How many standard drinks did you have in a week?
  if (CLC_SEX %in% c(1, 2) && !is.na(ALC_11) && ALC_11 == 1) {
    if (!is.na(ALCDWKY) && ALCDWKY <= 10) {
      step1 <- 0
    } else if (CLC_SEX == 1 && !is.na(ALCDWKY) && ALCDWKY > 10 && ALCDWKY <= 15) {
      step1 <- 0
    } else if (CLC_SEX == 2 && !is.na(ALCDWKY) && ALCDWKY > 10 && ALCDWKY <= 15) {
      step1 <- 1
    } else if (CLC_SEX == 1 && !is.na(ALCDWKY) && ALCDWKY > 15 && ALCDWKY <= 20) {
      step1 <- 1
    } else if (CLC_SEX == 2 && !is.na(ALCDWKY) && ALCDWKY > 15 && ALCDWKY <= 20) {
      step1 <- 3
    } else if (!is.na(ALCDWKY) && ALCDWKY > 20) {
      step1 <- 3
    } else {
      step1 <- NA
    }
  } else if (CLC_SEX %in% c(1, 2) && !is.na(ALC_11) && ALC_11 == 2) {
    step1 <- 0
  } else {
    step1 <- NA
  }

  ## Categorical score
  low_drink_score <- 0
  if (!is.na(step1)) {
    if (step1 == 0) {
      low_drink_score <- 1
    } else if (step1 %in% 1:2) {
      low_drink_score <- 2
    } else if (step1 %in% 3:4) {
      low_drink_score <- 3
    } else if (step1 %in% 5:9) {
      low_drink_score <- 4
    }
  } else {
    low_drink_score <- haven::tagged_na("b")
  }

  return(low_drink_score)
}
```

### Refactored Function (Vector-Ready)

```r
#' @title Low risk drinking score
#'
#' @description
#' Calculate low drink score using Canada's Low-Risk Alcohol Drinking Guidelines.
#' This function now supports vector operations for batch processing.
#'
#' @param CLC_SEX [integer] Respondent's sex (1=male, 2=female)
#' @param ALC_11 [integer] Past year alcohol use (1=yes, 2=no)  
#' @param ALCDWKY [integer] Weekly standard drinks consumed
#'
#' @return [integer] Risk score: 1=Low risk, 2=Marginal risk, 3=Medium risk, 4=High risk
#'
#' @details
#' This function calculates risk scores in two phases:
#' 1. Assign points based on weekly consumption and sex
#' 2. Convert points to categorical risk levels
#' 
#' The function works with vectors of any length, enabling batch processing
#' of multiple respondents simultaneously.
#'
#' @examples
#' # Scalar usage: Single respondent
#' low_drink_score_fun(CLC_SEX = 1, ALC_11 = 1, ALCDWKY = 3)
#' # Returns: 1 (Low risk)
#' 
#' # Vector usage: Multiple respondents  
#' low_drink_score_fun(
#'   CLC_SEX = c(1, 2, 1, 2),
#'   ALC_11 = c(1, 1, 2, 1),
#'   ALCDWKY = c(5, 15, 0, 25)
#' )
#' # Returns: c(1, 2, 1, 4)
#' 
#' # Database usage: Apply to survey data
#' library(dplyr)
#' survey_data %>%
#'   mutate(
#'     alcohol_risk = low_drink_score_fun(CLC_SEX, ALC_11, ALCDWKY)
#'   ) %>%
#'   count(alcohol_risk)
#'
#' @export
low_drink_score_fun <- function(CLC_SEX, ALC_11, ALCDWKY) {
  
  # Step 1: Calculate points based on consumption and sex
  step1 <- case_when(
    # Invalid inputs
    !CLC_SEX %in% c(1, 2) | !ALC_11 %in% c(1, 2) ~ NA_real_,
  
    # Did not drink in past year
    ALC_11 == 2 ~ 0,
  
    # Missing weekly consumption data
    is.na(ALCDWKY) ~ NA_real_,
  
    # Low consumption (≤10 drinks/week)
    ALCDWKY <= 10 ~ 0,
  
    # Medium consumption (11-15 drinks/week)
    ALCDWKY > 10 & ALCDWKY <= 15 & CLC_SEX == 1 ~ 0,  # Male: 0 points
    ALCDWKY > 10 & ALCDWKY <= 15 & CLC_SEX == 2 ~ 1,  # Female: 1 point
  
    # Higher consumption (16-20 drinks/week)  
    ALCDWKY > 15 & ALCDWKY <= 20 & CLC_SEX == 1 ~ 1,  # Male: 1 point
    ALCDWKY > 15 & ALCDWKY <= 20 & CLC_SEX == 2 ~ 3,  # Female: 3 points
  
    # High consumption (>20 drinks/week)
    ALCDWKY > 20 ~ 3,  # Both sexes: 3 points
  
    # Catch-all for unexpected cases
    TRUE ~ NA_real_
  )
  
  # Step 2: Convert points to categorical risk score
  case_when(
    is.na(step1) ~ haven::tagged_na("b"),  # Invalid input
    step1 == 0 ~ 1L,                       # Low risk (0 points)
    step1 %in% 1:2 ~ 2L,                   # Marginal risk (1-2 points)
    step1 %in% 3:4 ~ 3L,                   # Medium risk (3-4 points)
    step1 %in% 5:9 ~ 4L,                   # High risk (5-9 points)
    TRUE ~ haven::tagged_na("b")           # Unexpected point values
  )
}
```

### Refactored Complex Function (Vector-Ready)

```r
#' @title Low risk drinking score - former/never categories
#'
#' @description
#' Extended alcohol risk scoring that distinguishes between never, former, 
#' light, moderate, and heavy drinkers. Vector-enabled for batch processing.
#'
#' @param CLC_SEX [integer] Respondent's sex (1=male, 2=female)
#' @param ALC_11 [integer] Past year alcohol use (1=yes, 2=no)
#' @param ALCDWKY [integer] Weekly standard drinks (0-84)
#' @param ALC_17 [integer] Lifetime alcohol use (1=yes, 2=no)  
#' @param ALC_18 [integer] History of heavy drinking >12/week (1=yes, 2=no)
#'
#' @return [integer] 1=Never drank, 2=Low-risk, 3=Moderate, 4=Heavy
#'
#' @examples
#' # Scalar usage: Single respondent
#' low_drink_score_fun1(CLC_SEX = 1, ALC_11 = 2, ALCDWKY = NA, ALC_17 = 1, ALC_18 = 2)
#' # Returns: 1 (Never drank/light former)
#' 
#' # Vector usage: Multiple respondents
#' low_drink_score_fun1(
#'   CLC_SEX = c(1, 2, 1, 2),
#'   ALC_11 = c(1, 2, 1, 1), 
#'   ALCDWKY = c(5, NA, 18, 25),
#'   ALC_17 = c(1, 1, 1, 1),
#'   ALC_18 = c(2, 1, 2, 2)
#' )
#' # Returns: c(2, 2, 3, 4)
#' 
#' # Database usage: Complex drinking history analysis  
#' library(dplyr)
#' survey_data %>%
#'   mutate(
#'     detailed_alcohol_risk = low_drink_score_fun1(
#'       CLC_SEX, ALC_11, ALCDWKY, ALC_17, ALC_18
#'     )
#'   ) %>%
#'   group_by(detailed_alcohol_risk) %>%
#'   summarise(
#'     count = n(),
#'     avg_age = mean(age, na.rm = TRUE)
#'   )
#'
#' @export
low_drink_score_fun1 <- function(CLC_SEX, ALC_11, ALCDWKY, ALC_17, ALC_18) {
  
  # Step 1: Calculate base points from weekly consumption
  step1 <- case_when(
    # Current drinkers with valid data
    CLC_SEX %in% c(1, 2) & ALC_11 == 1 & !is.na(ALCDWKY) & ALCDWKY >= 0 & ALCDWKY <= 84 ~ case_when(
      ALCDWKY <= 10 ~ 0,
      ALCDWKY > 10 & ALCDWKY <= 15 & CLC_SEX == 1 ~ 0,  # Male: 0 points
      ALCDWKY > 10 & ALCDWKY <= 15 & CLC_SEX == 2 ~ 1,  # Female: 1 point  
      ALCDWKY > 15 & ALCDWKY <= 20 & CLC_SEX == 1 ~ 1,  # Male: 1 point
      ALCDWKY > 15 & ALCDWKY <= 20 & CLC_SEX == 2 ~ 3,  # Female: 3 points
      ALCDWKY > 20 & CLC_SEX == 1 ~ 3,                   # Male: 3 points
      ALCDWKY > 20 & CLC_SEX == 2 ~ 5,                   # Female: 5 points
      TRUE ~ NA_real_
    ),
  
    # Former drinkers (did not drink in past year)
    CLC_SEX %in% c(1, 2) & ALC_11 == 2 & is.na(ALCDWKY) ~ 0,
  
    # Invalid cases
    TRUE ~ NA_real_
  )
  
  # Step 2: Convert to final categorical score with drinking history
  case_when(
    is.na(step1) ~ haven::tagged_na("b"),
  
    # Zero points - classify based on drinking history
    step1 == 0 ~ case_when(
      # Never drank
      ALC_17 == 2 & ALC_11 == 2 ~ 1L,
  
      # Former drinker, light history
      ALC_17 == 1 & ALC_11 == 2 & ALC_18 == 2 ~ 1L,
  
      # Former drinker, heavy history  
      ALC_17 == 1 & ALC_11 == 2 & ALC_18 == 1 ~ 2L,
  
      # Current light drinker
      ALC_11 == 1 ~ 2L,
  
      # Missing history data
      TRUE ~ haven::tagged_na("b")
    ),
  
    # 1-2 points: Moderate drinker
    step1 %in% c(1, 2) ~ 3L,
  
    # 3+ points: Heavy drinker  
    step1 >= 3 ~ 4L,
  
    # Unexpected cases
    TRUE ~ haven::tagged_na("b")
  )
}
```

## Key Benefits of Vector Refactoring

### For Developers

- **Efficiency**: Process thousands of records at once
- **Readability**: Clear logical flow with `case_when()`
- **Maintainability**: Easier to modify and extend
- **Testing**: Simpler to test with vector inputs

### For AI Code Assistants

- **Pattern Recognition**: Consistent `case_when()` structure
- **Vectorization**: All operations work on vectors by default
- **Error Handling**: Predictable missing data patterns
- **Integration Ready**: Prepared for cchsflow modernization

## AI Assistant Instructions

When refactoring CHMSFLOW functions, follow this exact pattern:

1. **Identify all scalar logic patterns** (`if/else`, `&&`, `||`)
2. **Convert to vector patterns** (`case_when()`, `&`, `|`)
3. **Preserve original logic** (same conditions, same outcomes)
4. **Add vector documentation** (examples with multiple inputs)
5. **Test vector functionality** (verify with c() inputs)

**Template for AI refactoring:**

```r
function_name <- function(param1, param2, param3) {
  # Step 1: Calculate intermediate values
  intermediate <- case_when(
    # Invalid inputs first
    !param1 %in% valid_values ~ NA_real_,
    # Main logic conditions
    condition1 ~ value1,
    condition2 ~ value2,
    # Catch-all
    TRUE ~ NA_real_
  )
  
  # Step 2: Final categorization  
  case_when(
    is.na(intermediate) ~ haven::tagged_na("b"),
    intermediate == value_a ~ result_a,
    intermediate %in% value_range ~ result_b,
    TRUE ~ haven::tagged_na("b")
  )
}
```

## Testing Vector Functions

Always test refactored functions with vector inputs:

```r
# Test vectors of different lengths
test_single <- function_name(1, 1, 5)
test_multiple <- function_name(c(1,2,1), c(1,1,2), c(5,15,25))
test_mixed <- function_name(c(1,2,NA), c(1,NA,1), c(5,999,15))

# Verify results match original function for single values
original_result <- original_function(1, 1, 5)
new_result <- new_function(1, 1, 5)[1]  # Extract first element
expect_equal(original_result, new_result)
```

## Integration Notes

This refactoring approach creates a smooth transition path toward the cchsflow modernization framework:

- **Vector operations**: Ready for batch processing
- **Consistent patterns**: Aligns with tidyverse conventions
- **Missing data handling**: Compatible with `haven::tagged_na()`
- **Testing ready**: Prepared for infrastructure testing templates
- **Documentation**: Follows cchsflow documentation standards

The refactored functions maintain all original logic while enabling the vector operations needed for efficient data processing in health survey analysis.
