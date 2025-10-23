# MockData Comparison: Current vs MockData Functions

**Date**: 2025-10-17
**Purpose**: Objective comparison of variable coverage between current manual approach (prep-dummy-data.R) and new metadata-driven mockdata functions

## Overview

This document compares two approaches to generating mock data for chmsflow:

1. **Current**: Manual approach in `data-raw/prep-dummy-data.R` - hand-coded variable ranges
2. **MockData Functions**: Automated metadata-driven approach using modular functions in `R/`

### Methodology

- Loaded all 12 existing mock datasets (cycle1-6 and cycle1_meds-cycle6_meds)
- Generated variable lists using mockdata functions for same 12 cycles
- Compared variable names between approaches
- Categorized differences by type
- **Only differences are shown** (variables present in both approaches are not listed)

---

## Summary Statistics

| Cycle | Current | MockData Functions | Difference | Notes |
|-------|---------|-------------------|------------|-------|
| cycle1 | 77 | 79 | +2 mockdata functions | |
| cycle1_meds | 81 | 81 | 0 | |
| cycle2 | 77 | 79 | +2 mockdata functions | |
| cycle2_meds | 81 | 81 | 0 | |
| cycle3 | 81 | 83 | +2 mockdata functions | |
| cycle3_meds | 3 | 3 | 0 | |
| cycle4 | 82 | 84 | +2 mockdata functions | |
| cycle4_meds | 3 | 3 | 0 | |
| cycle5 | 77 | 79 | +2 mockdata functions | |
| cycle5_meds | 3 | 3 | 0 | |
| cycle6 | 78 | 80 | +2 mockdata functions | |
| cycle6_meds | 3 | 3 | 0 | |
| **TOTAL** | **646** | **658** | **+12** | |

---

## Detailed Differences by Cycle

**Legend**:
- ✓ = Variable present in this approach
- ✗ = Variable absent from this approach

### cycle1

**Differences**: 2 variables

| Variable | Current | MockData Functions | Explanation |
|----------|---------|-------------------|-------------|
| anymed2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| diab_drug2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |

### cycle2

**Differences**: 2 variables

| Variable | Current | MockData Functions | Explanation |
|----------|---------|-------------------|-------------|
| anymed2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| diab_drug2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |

### cycle3

**Differences**: 2 variables

| Variable | Current | MockData Functions | Explanation |
|----------|---------|-------------------|-------------|
| anymed2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| diab_drug2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |

### cycle4

**Differences**: 2 variables

| Variable | Current | MockData Functions | Explanation |
|----------|---------|-------------------|-------------|
| anymed2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| diab_drug2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |

### cycle5

**Differences**: 2 variables

| Variable | Current | MockData Functions | Explanation |
|----------|---------|-------------------|-------------|
| anymed2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| diab_drug2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |

### cycle6

**Differences**: 2 variables

| Variable | Current | MockData Functions | Explanation |
|----------|---------|-------------------|-------------|
| ANYMED2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| DIAB_DRUG2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |

---

## Explanation Categories

**Raw vs harmonized name**: Variable exists in both but with different names. Current uses harmonized name (e.g., `ammdmva1`), mockdata functions uses raw cycle-specific name (e.g., `amsdmva1` for cycle1).

**Not in metadata**: Variable present in current data but not found in `variables.csv`. May be real CHMS variable not included in harmonization, or outdated/incorrect variable name.

**Wrong cycle**: Variable exists in metadata but for different cycles. Example: `paadtot` exists in cycle3+ but current includes it in cycle1.

**Metadata-driven**: Variable exists in metadata with harmonization specifications but was not included in current manual data. Mockdata functions includes all variables from metadata.

**Not in variable_details**: Variable found in `variables.csv` but no recoding specifications for this cycle in `variable_details.csv`.

---

## Files

**Machine-readable data**: [MOCKDATA_COMPARISON.csv](MOCKDATA_COMPARISON.csv)

**Current approach**: [data-raw/prep-dummy-data.R](data-raw/prep-dummy-data.R)

**MockData functions**:
- [R/create_cat_var.R](R/create_cat_var.R)
- [R/create_con_var.R](R/create_con_var.R)
- [R/parse-range-notation.R](R/parse-range-notation.R)
- [data-raw/test-all-cycles.R](data-raw/test-all-cycles.R)

---

## Next Steps

This comparison identifies differences for team review. Key questions:

1. Should mock data use raw or harmonized variable names?
2. Should variables not in metadata (e.g., gen_015) be included?
3. Is current coverage (72-75 vars/cycle) intentionally minimal or should it be comprehensive?
4. Should variables from wrong cycles (e.g., paadtot in cycle1) be removed?

See [MOCKDATA_QUESTIONS.md](MOCKDATA_QUESTIONS.md) for detailed questions.
