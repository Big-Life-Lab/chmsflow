# Diabetes medications

This function checks if a given medication for a CHMS respondent belongs
to the diabetes drug class. The identification is based on the
Anatomical Therapeutic Chemical (ATC) code of the medication and the
time when the medication was last taken.

## Usage

``` r
is_diabetes_drug(MEUCATC, NPI_25B)
```

## Arguments

- MEUCATC:

  A character vector representing the Anatomical Therapeutic Chemical
  (ATC) code of the medication.

- NPI_25B:

  An integer representing the CHMS response for the time when the
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

## Value

A numeric, 1 if medication is in the diabetes drug class and 0 if it is
not.

## Details

This function uses the `startsWith` function to identify diabetes drugs
based on their ATC codes, which typically start with "A10". If the ATC
code matches the pattern and the medication was taken within the last
month (NPI_25B \<= 4), the medication is considered a diabetes drug, and
the function returns TRUE. Otherwise, it returns FALSE.

## Examples

``` r

# Let's say the ATC code is "A10BB09" and the time last taken was within last week (3).

is_diabetes_drug("A10BB09", 3) # Should return 1 (TRUE)
#> [1] 1
```
