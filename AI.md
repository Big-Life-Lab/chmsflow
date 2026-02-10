# chmsflow style guide for AI assistants

**Purpose**: Coding conventions for the chmsflow package. Reference for both human developers and AI assistants.

**Status**: DRAFT - Under development

**Foundation**: [Tidyverse style guide](https://style.tidyverse.org/) with extensions for recodeflow ecosystem.

---

## Variable naming

**Use `snake_case` for all variables**

**Pattern**: `[category]_[specifics]_[type]`

```r
# Medication variables
any_htn_med      # Any anti-hypertension medication
ace_med          # ACE inhibitor medication
diab_med         # Diabetes medication

# Health outcomes
htn_status       # Hypertension status
bmi_category     # BMI category
```

**Type suffixes**: `_med`, `_status`, `_category`, `_score`, `_date`

**DISCUSSION**: Some existing variables need renaming:

```r
# Medication variables (_med suffix)
anymed → any_htn_med          # Any antihypertension medication
acemed → ace_med              # ACE inhibitor medication
diab_drug → diab_med          # Diabetes medication
bbmed → bb_med                # Beta blocker medication
ccbmed → ccb_med              # Calcium channel blocker medication
diurmed → diur_med            # Diuretic medication
miscmed → misc_htn_med        # Other antihypertension medication
nsaid_drug → nsaid_med        # NSAID medication
anymed2 → any_htn_med2       # Any antihypertension medication (source)
diab_drug2 → diab_med2       # Diabetes medication (source)

# Status/category variables (_status, _category suffixes)
bmigroup → bmi_category                    # BMI classification
cardiov → cvd_status                       # Cardiovascular disease status
ckd → ckd_status                           # Chronic kidney disease status
diab_m → diab_a1c                          # Diabetes prevalence (HbA1C)
diabx → diab_status                        # Diabetes status (inclusive)
gooddiet → healthy_diet_indicator          # Diet quality indicator
highbp14090 → htn_status                   # Hypertension 140/90 status
highbp14090_adj → htn_adj_status           # Hypertension adjusted 140/90
control14090 → htn_control_status          # Controlled hypertension 140/90
control14090_adj → htn_control_adj_status  # Controlled hypertension adjusted
mvpa150wk → enough_exercise_indicator      # Meets 150min/week guideline
nonhdltodd → nonhdl_category               # High non-HDL cholesterol status
incq → income_quintile                     # Household income quintile
incq1 → lowest_income_quintile             # Lowest income quintile flag

# Score variables (_score suffix) -> these could maybe retain original name?
low_drink_score → alc_risk_score           # Alcohol consumption risk score
low_drink_score1 → alc_detailed_risk_score # Alcohol risk with former/never

# Continuous measurement variables
adj_hh_inc → adj_hh_income                 # Adjusted household income
dbp_adj → dbp_adj_mmhg                     # Adjusted diastolic BP (mmHg)
sbp_adj → sbp_adj_mmhg                     # Adjusted systolic BP (mmHg)
gfr → gfr_ml_min                           # Estimated GFR (mL/min)
minperweek → exercise_min_week             # Exercise minutes per week
mvpa_min → exercise_avg_min_day            # Average exercise minutes per day
nonhdl → nonhdl_mmoll                      # Non-HDL cholesterol (mmol/L)
pack_years_der → pack_years                # Smoking pack-years
totalfv → fv_daily_times                   # Daily fruit/vegetable servings
whr → waist_height_ratio                   # Waist-to-height ratio

# Family history variables (_family suffix)
fambp → fam_bp                             # Family history of high BP (source)
famcvd60 → cvd_premature_famhist_status    # Premature CVD family history
```

---

## Function naming

**Use `snake_case` and start with a verb**

**Proposed verb taxonomy** (simplified):

| Verb           | Purpose                              | Returns                | Example                          |
| -------------- | ------------------------------------ | ---------------------- | -------------------------------- |
| `is_`          | Boolean check                        | 0/1 or TRUE/FALSE      | `is_beta_blocker()`              |
| `calculate_`   | Mathematical computation             | Continuous numeric     | `calculate_gfr()`                |
| `categorize_`  | Continuous → categorical             | Category codes (1,2,3) | `categorize_income()`            |
| `adjust_`      | Correction/transformation            | Adjusted numeric       | `adjust_sbp()`                   |
| `derive_`      | Complex multi-input derivation       | Derived variable       | `derive_diabetes_status()`       |

**DISCUSSION**: Rename all functions to use the five verbs above. Use lowercase for function names.

```r
# Alcohol functions (alcohol.R)
low_drink_score_fun → derive_alcohol_risk                     # 3-level risk category
low_drink_score_fun1 → derive_alcohol_risk_detailed           # With former/never drinker detail

# Blood pressure functions (blood-pressure.R)
adjust_SBP → adjust_sbp                                                       # Adjusted systolic BP
adjust_DBP → adjust_dbp                                                       # Adjusted diastolic BP
determine_hypertension → derive_hypertension                                  # HTN status (1=yes, 2=no)
determine_adjusted_hypertension → derive_hypertension_adj                     # HTN status with adjusted BP
determine_controlled_hypertension → derive_hypertension_control               # Controlled HTN status
determine_controlled_adjusted_hypertension → derive_hypertension_control_adj  # Controlled HTN with adjusted BP

# Cholesterol and obesity functions (cholesterol-and-obesity.R)
calculate_nonHDL → calculate_nonhdl                           # Non-HDL cholesterol (mmol/L)
categorize_nonHDL → categorize_nonhdl                         # High non-HDL status
calculate_WHR → calculate_waist_height_ratio                  # Waist-to-height ratio

# Diabetes functions (diabetes.R)
determine_inclusive_diabetes → derive_diabetes_status         # Combines multiple inputs

# Diet functions (diet.R)
find_totalFV_cycles1and2 → calculate_fv_daily_cycles1to2      # Daily F&V servings
find_totalFV_cycles3to6 → calculate_fv_daily_cycles3to6       # Daily F&V servings
determine_gooddiet → categorize_diet_quality                  # Meets 5/day guideline

# Exercise functions (exercise.R)
find_week_accelerometer_average → calculate_exercise_daily_avg  # Avg min/day
minperday_to_minperweek → calculate_exercise_weekly             # Min per week
categorize_minperweek → categorize_exercise                     # Meets 150min/week guideline

# Family history functions (family-history.R)
determine_CVD_personal_history → derive_cvd_personal_history  # CVD status in individual
determine_CVD_family_history → derive_cvd_family_history      # Premature CVD in family

# Income functions (income.R)
calculate_hhld_income → calculate_household_income            # Household income
categorize_income → categorize_income_quintile                # 5 income quintiles
in_lowest_income_quintile → is_lowest_income_quintile         # Boolean: lowest quintile

# Kidney functions (kidney.R)
calculate_GFR → calculate_gfr                                 # eGFR (mL/min/1.73m²)
categorize_GFR_to_CKD → categorize_ckd                        # CKD status from GFR

# Medication functions - element-wise (medications.R)
is_taking_drug_class → is_taking_drug_class                   # (keep, internal helper)
is_beta_blocker → is_beta_blocker                             # (keep)
is_ace_inhibitor → is_ace_inhibitor                           # (keep)
is_diuretic → is_diuretic                                     # (keep)
is_calcium_channel_blocker → is_calcium_channel_blocker       # (keep)
is_other_antiHTN_med → is_other_antihtn_med                   # Lowercase
is_any_antiHTN_med → is_any_antihtn_med                       # Lowercase
is_NSAID → is_nsaid                                           # Lowercase
is_diabetes_drug → is_diabetes_med                            # Consistent _med suffix

# Medication functions - cycle-specific (medications.R)
cycles1to2_beta_blockers → is_bb_med_cycles1to2               # Beta blocker (cycles 1-2)
cycles1to2_ace_inhibitors → is_ace_med_cycles1to2             # ACE inhibitor (cycles 1-2)
cycles1to2_diuretics → is_diur_med_cycles1to2                 # Diuretic (cycles 1-2)
cycles1to2_calcium_channel_blockers → is_ccb_med_cycles1to2   # CCB (cycles 1-2)
cycles1to2_other_antiHTN_meds → is_misc_htn_med_cycles1to2    # Other antiHTN (cycles 1-2)
cycles1to2_any_antiHTN_meds → is_any_htn_med_cycles1to2       # Any antiHTN (cycles 1-2)
cycles1to2_nsaid → is_nsaid_med_cycles1to2                    # NSAID (cycles 1-2)
cycles1to2_diabetes_drugs → is_diab_med_cycles1to2            # Diabetes med (cycles 1-2)

# Smoking functions (smoking.R)
pack_years_fun → calculate_pack_years                         # Pack-years from smoking history
```

**Open questions**:

- Should parameters be lowercase (tidyverse) or UPPERCASE (CHMS traceability)?

---

## Architecture patterns

**Principles**:

- Hide complexity from users where possible
- Automate workflows - minimize manual steps
- Handle data structure differences internally when feasible

**DISCUSSION**:

- Document current architecture patterns (separate task)
- Evaluate approaches for multi-cycle variables
- Decide on intermediate variable handling

---

## Documentation

**Vignette structure** (user-first):

1. What's available
2. When to use them
3. Quick start
4. How it works
5. Advanced topics

**Function documentation** (roxygen2):

- Document all parameters
- Provide examples
- Include references for derivation methods

---

## Working with AI assistants

**Critical review required**

**DO**:

- ✓ Use AI for drafts and exploration
- ✓ **Critically review all AI output**
- ✓ Ask AI to explain reasoning
- ✓ Test thoroughly

**DON'T**:

- ✗ Accept without understanding
- ✗ Assume AI follows conventions
- ✗ Let AI make architectural decisions alone

**Using this guide**:

1. Provide guide to AI at session start
2. Ask AI to follow conventions explicitly
3. Review output against guide
4. Request revisions if needed
5. Document gaps/ambiguities

**This is a living document** - update when you find issues or make decisions.

---

## Discussion questions

**Open decisions**:

1. Variable renaming: Single PR or gradual? Backwards compatibility?
2. Function verbs: Which to keep? Exact meanings?
3. Parameter naming: Lowercase or UPPERCASE?
4. Cycle-specific functions: Refactor or keep?
5. Intermediate variables: Eliminate or document?
6. Vignette restructuring: Rewrite existing?

**Next steps**:

1. Review together
2. Discuss open questions
3. Pilot with medications code
4. Refine based on learnings

---

## References

- [Tidyverse style guide](https://style.tidyverse.org/)
- [R packages book](https://r-pkgs.org/)
- [cchsflow package](https://github.com/Big-Life-Lab/cchsflow)
