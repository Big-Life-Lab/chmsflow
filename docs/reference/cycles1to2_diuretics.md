# Diuretics - cycles 1-2

This function checks if a person is taking diuretics based on the
provided Anatomical Therapeutic Chemical (ATC) codes for medications and
the Canadian Health Measures Survey (CHMS) response for the time when
the medication was last taken.

## Usage

``` r
cycles1to2_diuretics(
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

  Character vector representing the ATC code of respondent's first
  prescription medication.

- atc_102a:

  Character vector representing the ATC code of respondent's second
  prescription medication.

- atc_103a:

  Character vector representing the ATC code of respondent's third
  prescription medication.

- atc_104a:

  Character vector representing the ATC code of respondent's fourth
  prescription medication.

- atc_105a:

  Character vector representing the ATC code of respondent's fifth
  prescription medication.

- atc_106a:

  Character vector representing the ATC code of respondent's sixth
  prescription medication.

- atc_107a:

  Character vector representing the ATC code of respondent's seventh
  prescription medication.

- atc_108a:

  Character vector representing the ATC code of respondent's eighth
  prescription medication.

- atc_109a:

  Character vector representing the ATC code of respondent's ninth
  prescription medication.

- atc_110a:

  Character vector representing the ATC code of respondent's tenth
  prescription medication.

- atc_111a:

  Character vector representing the ATC code of respondent's eleventh
  prescription medication.

- atc_112a:

  Character vector representing the ATC code of respondent's twelfth
  prescription medication.

- atc_113a:

  Character vector representing the ATC code of respondent's thirteenth
  prescription medication.

- atc_114a:

  Character vector representing the ATC code of respondent's fourteenth
  prescription medication.

- atc_115a:

  Character vector representing the ATC code of respondent's fifteenth
  prescription medication.

- atc_201a:

  Character vector representing the ATC code of respondent's first
  over-the-counter medication.

- atc_202a:

  Character vector representing the ATC code of respondent's second
  over-the-counter medication.

- atc_203a:

  Character vector representing the ATC code of respondent's third
  over-the-counter medication.

- atc_204a:

  Character vector representing the ATC code of respondent's fourth
  over-the-counter medication.

- atc_205a:

  Character vector representing the ATC code of respondent's fifth
  over-the-counter medication.

- atc_206a:

  Character vector representing the ATC code of respondent's sixth
  over-the-counter medication.

- atc_207a:

  Character vector representing the ATC code of respondent's seventh
  over-the-counter medication.

- atc_208a:

  Character vector representing the ATC code of respondent's eighth
  over-the-counter medication.

- atc_209a:

  Character vector representing the ATC code of respondent's ninth
  over-the-counter medication.

- atc_210a:

  Character vector representing the ATC code of respondent's tenth
  over-the-counter medication.

- atc_211a:

  Character vector representing the ATC code of respondent's eleventh
  over-the-counter medication.

- atc_212a:

  Character vector representing the ATC code of respondent's twelfth
  over-the-counter medication.

- atc_213a:

  Character vector representing the ATC code of respondent's thirteenth
  over-the-counter medication.

- atc_214a:

  Character vector representing the ATC code of respondent's fourteenth
  over-the-counter medication.

- atc_215a:

  Character vector representing the ATC code of respondent's fifteenth
  over-the-counter medication.

- atc_131a:

  Character vector representing the ATC code of respondent's first new
  prescription medication.

- atc_132a:

  Character vector representing the ATC code of respondent's second new
  prescription medication.

- atc_133a:

  Character vector representing the ATC code of respondent's third new
  prescription medication.

- atc_134a:

  Character vector representing the ATC code of respondent's fourth new
  prescription medication.

- atc_135a:

  Character vector representing the ATC code of respondent's fifth new
  prescription medication.

- atc_231a:

  Character vector representing the ATC code of respondent's first new
  over-the-counter medication.

- atc_232a:

  Character vector representing the ATC code of respondent's second new
  over-the-counter medication.

- atc_233a:

  Character vector representing the ATC code of respondent's third new
  over-the-counter medication.

- atc_234a:

  Character vector representing the ATC code of respondent's fourth new
  over-the-counter medication.

- atc_235a:

  Character vector representing the ATC code of respondent's fifth new
  over-the-counter medication.

- mhr_101b:

  Integer representing the response for when the first prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_102b:

  Integer representing the response for when the second prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_103b:

  Integer representing the response for when the third prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_104b:

  Integer representing the response for when the fourth prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_105b:

  Integer representing the response for when the fifth prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_106b:

  Integer representing the response for when the sixth prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_107b:

  Integer representing the response for when the seventh prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_108b:

  Integer representing the response for when the eighth prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_109b:

  Integer representing the response for when the ninth prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_110b:

  Integer representing the response for when the tenth prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_111b:

  Integer representing the response for when the eleventh prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_112b:

  Integer representing the response for when the twelfth prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_113b:

  Integer representing the response for when the thirteenth prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_114b:

  Integer representing the response for when the fourteenth prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_115b:

  Integer representing the response for when the fifteenth prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_201b:

  Integer representing the response for when the first over-the-counter
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_202b:

  Integer representing the response for when the second over-the-counter
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_203b:

  Integer representing the response for when the third over-the-counter
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_204b:

  Integer representing the response for when the fourth over-the-counter
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_205b:

  Integer representing the response for when the fifth over-the-counter
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_206b:

  Integer representing the response for when the sixth over-the-counter
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_207b:

  Integer representing the response for when the seventh
  over-the-counter medication was last taken. 1 = Today, 2 = Yesterday,
  3 = Within the last week, 4 = Within the last month, 5 = More than a
  month ago, 6 = Never taken

- mhr_208b:

  Integer representing the response for when the eighth over-the-counter
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_209b:

  Integer representing the response for when the ninth over-the-counter
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_210b:

  Integer representing the response for when the tenth over-the-counter
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_211b:

  Integer representing the response for when the eleventh
  over-the-counter medication was last taken. 1 = Today, 2 = Yesterday,
  3 = Within the last week, 4 = Within the last month, 5 = More than a
  month ago, 6 = Never taken

- mhr_212b:

  Integer representing the response for when the twelfth
  over-the-counter medication was last taken. 1 = Today, 2 = Yesterday,
  3 = Within the last week, 4 = Within the last month, 5 = More than a
  month ago, 6 = Never taken

- mhr_213b:

  Integer representing the response for when the thirteenth
  over-the-counter medication was last taken. 1 = Today, 2 = Yesterday,
  3 = Within the last week, 4 = Within the last month, 5 = More than a
  month ago, 6 = Never taken

- mhr_214b:

  Integer representing the response for when the fourteenth
  over-the-counter medication was last taken. 1 = Today, 2 = Yesterday,
  3 = Within the last week, 4 = Within the last month, 5 = More than a
  month ago, 6 = Never taken

- mhr_215b:

  Integer representing the response for when the fifteenth
  over-the-counter medication was last taken. 1 = Today, 2 = Yesterday,
  3 = Within the last week, 4 = Within the last month, 5 = More than a
  month ago, 6 = Never taken

- mhr_131b:

  Integer representing the response for when the first new prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_132b:

  Integer representing the response for when the second new prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_133b:

  Integer representing the response for when the third new prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_134b:

  Integer representing the response for when the fourth new prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_135b:

  Integer representing the response for when the fifth new prescription
  medication was last taken. 1 = Today, 2 = Yesterday, 3 = Within the
  last week, 4 = Within the last month, 5 = More than a month ago, 6 =
  Never taken

- mhr_231b:

  Integer representing the response for when the first new
  over-the-counter medication was last taken. 1 = Today, 2 = Yesterday,
  3 = Within the last week, 4 = Within the last month, 5 = More than a
  month ago, 6 = Never taken

- mhr_232b:

  Integer representing the response for when the second new
  over-the-counter medication was last taken. 1 = Today, 2 = Yesterday,
  3 = Within the last week, 4 = Within the last month, 5 = More than a
  month ago, 6 = Never taken

- mhr_233b:

  Integer representing the response for when the third new
  over-the-counter medication was last taken. 1 = Today, 2 = Yesterday,
  3 = Within the last week, 4 = Within the last month, 5 = More than a
  month ago, 6 = Never taken

- mhr_234b:

  Integer representing the response for when the fourth new
  over-the-counter medication was last taken. 1 = Today, 2 = Yesterday,
  3 = Within the last week, 4 = Within the last month, 5 = More than a
  month ago, 6 = Never taken

- mhr_235b:

  Integer representing the response for when the fifth new
  over-the-counter medication was last taken. 1 = Today, 2 = Yesterday,
  3 = Within the last week, 4 = Within the last month, 5 = More than a
  month ago, 6 = Never taken

## Value

diurmed, a numeric set to 1 if the person is taking diuretics, NA if no
information is available, 0 otherwise.

## See also

`is_diuretic`
