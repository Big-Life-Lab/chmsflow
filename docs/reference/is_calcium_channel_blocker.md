# Calcium channel blockers

This function checks if a given medication for a CHMS respondent belongs
to the calcium channel blocker drug class. The identification is based
on the Anatomical Therapeutic Chemical (ATC) code of the medication and
the time when the medication was last taken.

## Usage

``` r
is_calcium_channel_blocker(MEUCATC, NPI_25B)
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

A numeric, 1 if medication is in the calcium channel blocker class and 0
if it is not.

## Details

This function uses the `startsWith` function to identify calcium channel
blockers based on their ATC codes, which typically start with "C08". If
the ATC code matches the pattern and the medication was taken within the
last month (NPI_25B \<= 4), the medication is considered a calcium
channel blocker, and the function returns TRUE. Otherwise, it returns
FALSE.

## Examples

``` r

# Let's say the ATC code is "C08CA05" and the time last taken was today (1).

is_calcium_channel_blocker("C08CA05", 1) # Should return 1 (TRUE)
#> [1] 1
```
