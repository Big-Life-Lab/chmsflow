# Smoking pack-years

This function calculates an individual's smoking pack-years based on
various CHMS smoking variables. Pack years is a measure used by
researchers to quantify lifetime exposure to cigarette use.

## Usage

``` r
pack_years_fun(
  SMKDSTY,
  CLC_AGE,
  SMK_54,
  SMK_52,
  SMK_31,
  SMK_41,
  SMK_53,
  SMK_42,
  SMK_21,
  SMK_11
)
```

## Arguments

- SMKDSTY:

  An integer representing the smoking status of the respondent:

  - 1: Daily smoker

  - 2: Occasional smoker (former daily)

  - 3: Occasional smoker (never daily)

  - 4: Former daily smoker (non-smoker now)

  - 5: Former occasional smoker (non-smoker now) who smoked at least 100
    cigarettes in their lifetime

  - 6: Non-smoker (never smoked more than 100 cigarettes)

- CLC_AGE:

  A numeric value representing the respondent's age.

- SMK_54:

  A numeric value representing the respondent's age when they stopped
  smoking daily.

- SMK_52:

  A numeric value representing the respondent's age when they first
  started smoking daily.

- SMK_31:

  An numeric representing the number of cigarettes smoked per day for
  daily smokers.

- SMK_41:

  A numeric value representing the number of cigarettes smoked per day
  for occasional smokers.

- SMK_53:

  A numeric value representing the number of cigarettes smoked per day
  for former daily smokers.

- SMK_42:

  A numeric value representing the number of days in past month the
  respondent smoked at least 1 cigarette (for occasional smokers).

- SMK_21:

  A numeric value representing the respondent's age when they first
  started smoking occasionally.

- SMK_11:

  An integer representing whether the respondent has smoked at least 100
  cigarettes in their lifetime:

  - 1: Yes

  - 2: No

## Value

A numeric value representing the pack years for the respondent's smoking
history.

- If `CLC_AGE` is missing or negative, returns `tagged_na("b")`.

- For different smoking statuses (`SMKDSTY`), the function calculates
  pack years as follows:

  - **Daily smoker (1):**
    `pmax(((CLC_AGE - SMK_52) * (SMK_31 / 20)), 0.0137)`

  - **Occasional smoker (former daily) (2):**
    `pmax(((CLC_AGE - SMK_52 - (CLC_AGE - SMK_54)) * (SMK_53 / 20)), 0.0137) + ((pmax((SMK_41 * SMK_42 / 30), 1) / 20) * (CLC_AGE - SMK_54))`

  - **Occasional smoker (never daily) (3):**
    `(pmax((SMK_41 * SMK_42 / 30), 1) / 20) * (CLC_AGE - SMK_21)`

  - **Former daily smoker (4):**
    `pmax(((CLC_AGE - SMK_52 - (CLC_AGE - SMK_54)) * (SMK_53 / 20)), 0.0137)`

  - **Former occasional smoker (5)**:

    - If `SMK_11 == 1` (≥100 cigarettes): `0.0137`

    - If `SMK_11 == 2` (\<100 cigarettes): `0.007`

  - **Non-smoker (6):** `0`

  - If `SMKDSTY` is `NA(a)`, returns `tagged_na("a")`.

  - For all other unexpected inputs, returns `tagged_na("b")`.

## See also

https://big-life-lab.github.io/cchsflow/reference/pack_years_fun.html

## Examples

``` r

# Example 1: Age = 40, daily smoker, started smoking at 20, and smokes 30 cigs/day (1.5 packs/day).
pack_years_fun(SMKDSTY = 1, CLC_AGE = 40, SMK_52 = 20, SMK_31 = 30)
#> [1] 30
# Output: 30 (pack years)

# Example 2: A former occasional smoker who smoked at least 100 cigarettes in their lifetime.
pack_years_fun(
  SMKDSTY = 5, CLC_AGE = 50, SMK_54 = 40, SMK_52 = 18, SMK_31 = NA,
  SMK_41 = 15, SMK_53 = NA, SMK_42 = 3, SMK_21 = 25, SMK_11 = 1
)
#> [1] 0.0137
# Output: 0.0137 (pack years)
```
