# Other anti-hypertensive medications - cycles 1-2

This function checks if a person is taking another type of
anti-hypertensive medication based on the provided Anatomical
Therapeutic Chemical (ATC) codes for medications and the Canadian Health
Measures Survey (CHMS) response for the time when the medication was
last taken.

## Usage

``` r
is_misc_htn_med_cycles1to2(
  atc_101a = NULL,
  atc_102a = NULL,
  atc_103a = NULL,
  atc_104a = NULL,
  atc_105a = NULL,
  atc_106a = NULL,
  atc_107a = NULL,
  atc_108a = NULL,
  atc_109a = NULL,
  atc_110a = NULL,
  atc_111a = NULL,
  atc_112a = NULL,
  atc_113a = NULL,
  atc_114a = NULL,
  atc_115a = NULL,
  atc_201a = NULL,
  atc_202a = NULL,
  atc_203a = NULL,
  atc_204a = NULL,
  atc_205a = NULL,
  atc_206a = NULL,
  atc_207a = NULL,
  atc_208a = NULL,
  atc_209a = NULL,
  atc_210a = NULL,
  atc_211a = NULL,
  atc_212a = NULL,
  atc_213a = NULL,
  atc_214a = NULL,
  atc_215a = NULL,
  atc_131a = NULL,
  atc_132a = NULL,
  atc_133a = NULL,
  atc_134a = NULL,
  atc_135a = NULL,
  atc_231a = NULL,
  atc_232a = NULL,
  atc_233a = NULL,
  atc_234a = NULL,
  atc_235a = NULL,
  mhr_101b = NULL,
  mhr_102b = NULL,
  mhr_103b = NULL,
  mhr_104b = NULL,
  mhr_105b = NULL,
  mhr_106b = NULL,
  mhr_107b = NULL,
  mhr_108b = NULL,
  mhr_109b = NULL,
  mhr_110b = NULL,
  mhr_111b = NULL,
  mhr_112b = NULL,
  mhr_113b = NULL,
  mhr_114b = NULL,
  mhr_115b = NULL,
  mhr_201b = NULL,
  mhr_202b = NULL,
  mhr_203b = NULL,
  mhr_204b = NULL,
  mhr_205b = NULL,
  mhr_206b = NULL,
  mhr_207b = NULL,
  mhr_208b = NULL,
  mhr_209b = NULL,
  mhr_210b = NULL,
  mhr_211b = NULL,
  mhr_212b = NULL,
  mhr_213b = NULL,
  mhr_214b = NULL,
  mhr_215b = NULL,
  mhr_131b = NULL,
  mhr_132b = NULL,
  mhr_133b = NULL,
  mhr_134b = NULL,
  mhr_135b = NULL,
  mhr_231b = NULL,
  mhr_232b = NULL,
  mhr_233b = NULL,
  mhr_234b = NULL,
  mhr_235b = NULL
)
```

## Arguments

- atc_101a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's first prescription medication.

- atc_102a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's second prescription medication.

- atc_103a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's third prescription medication.

- atc_104a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's fourth prescription medication.

- atc_105a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's fifth prescription medication.

- atc_106a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's sixth prescription medication.

- atc_107a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's seventh prescription medication.

- atc_108a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's eighth prescription medication.

- atc_109a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's ninth prescription medication.

- atc_110a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's tenth prescription medication.

- atc_111a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's eleventh prescription medication.

- atc_112a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's twelfth prescription medication.

- atc_113a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's thirteenth prescription medication.

- atc_114a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's fourteenth prescription medication.

- atc_115a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's fifteenth prescription medication.

- atc_201a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's first over-the-counter medication.

- atc_202a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's second over-the-counter medication.

- atc_203a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's third over-the-counter medication.

- atc_204a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's fourth over-the-counter medication.

- atc_205a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's fifth over-the-counter medication.

- atc_206a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's sixth over-the-counter medication.

- atc_207a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's seventh over-the-counter medication.

- atc_208a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's eighth over-the-counter medication.

- atc_209a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's ninth over-the-counter medication.

- atc_210a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's tenth over-the-counter medication.

- atc_211a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's eleventh over-the-counter medication.

- atc_212a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's twelfth over-the-counter medication.

- atc_213a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's thirteenth over-the-counter medication.

- atc_214a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's fourteenth over-the-counter medication.

- atc_215a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's fifteenth over-the-counter medication.

- atc_131a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's first new prescription medication.

- atc_132a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's second new prescription medication.

- atc_133a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's third new prescription medication.

- atc_134a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's fourth new prescription medication.

- atc_135a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's fifth new prescription medication.

- atc_231a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's first new over-the-counter medication.

- atc_232a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's second new over-the-counter medication.

- atc_233a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's third new over-the-counter medication.

- atc_234a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's fourth new over-the-counter medication.

- atc_235a:

  [character](https://rdrr.io/r/base/character.html) ATC code of
  respondent's fifth new over-the-counter medication.

- mhr_101b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  first prescription medication was last taken (1 = Today, …, 6 =
  Never).

- mhr_102b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  second prescription medication was last taken (1-6).

- mhr_103b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  third prescription medication was last taken (1-6).

- mhr_104b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  fourth prescription medication was last taken (1-6).

- mhr_105b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  fifth prescription medication was last taken (1-6).

- mhr_106b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  sixth prescription medication was last taken (1-6).

- mhr_107b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  seventh prescription medication was last taken (1-6).

- mhr_108b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  eighth prescription medication was last taken (1-6).

- mhr_109b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  ninth prescription medication was last taken (1-6).

- mhr_110b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  tenth prescription medication was last taken (1-6).

- mhr_111b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  eleventh prescription medication was last taken (1-6).

- mhr_112b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  twelfth prescription medication was last taken (1-6).

- mhr_113b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  thirteenth prescription medication was last taken (1-6).

- mhr_114b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  fourteenth prescription medication was last taken (1-6).

- mhr_115b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  fifteenth prescription medication was last taken (1-6).

- mhr_201b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  first over-the-counter medication was last taken (1-6).

- mhr_202b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  second over-the-counter medication was last taken (1-6).

- mhr_203b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  third over-the-counter medication was last taken (1-6).

- mhr_204b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  fourth over-the-counter medication was last taken (1-6).

- mhr_205b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  fifth over-the-counter medication was last taken (1-6).

- mhr_206b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  sixth over-the-counter medication was last taken (1-6).

- mhr_207b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  seventh over-the-counter medication was last taken (1-6).

- mhr_208b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  eighth over-the-counter medication was last taken (1-6).

- mhr_209b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  ninth over-the-counter medication was last taken (1-6).

- mhr_210b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  tenth over-the-counter medication was last taken (1-6).

- mhr_211b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  eleventh over-the-counter medication was last taken (1-6).

- mhr_212b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  twelfth over-the-counter medication was last taken (1-6).

- mhr_213b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  thirteenth over-the-counter medication was last taken (1-6).

- mhr_214b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  fourteenth over-the-counter medication was last taken (1-6).

- mhr_215b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  fifteenth over-the-counter medication was last taken (1-6).

- mhr_131b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  first new prescription medication was last taken (1-6).

- mhr_132b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  second new prescription medication was last taken (1-6).

- mhr_133b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  third new prescription medication was last taken (1-6).

- mhr_134b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  fourth new prescription medication was last taken (1-6).

- mhr_135b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  fifth new prescription medication was last taken (1-6).

- mhr_231b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  first new over-the-counter medication was last taken (1-6).

- mhr_232b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  second new over-the-counter medication was last taken (1-6).

- mhr_233b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  third new over-the-counter medication was last taken (1-6).

- mhr_234b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  fourth new over-the-counter medication was last taken (1-6).

- mhr_235b:

  [integer](https://rdrr.io/r/base/integer.html) Response for when the
  fifth new over-the-counter medication was last taken (1-6).

## Value

[numeric](https://rdrr.io/r/base/numeric.html) Returns 1 if the person
is taking another type of anti-hypertensive medication, 0 otherwise. If
all medication information is missing, it returns a tagged NA.

## Details

The function identifies other anti-hypertensive drugs based on ATC codes
starting with "C02", excluding a specific sub-code. It checks all
medication variables provided in the input data frame.

         **Missing Data Codes:**
         - The function handles tagged NAs from the `is_other_antihtn_med` function and propagates them.

## See also

`is_other_antihtn_med`

## Examples

``` r
# This is a wrapper function and is not intended to be called directly by the user.
# See `is_other_antihtn_med` for usage examples.
```
