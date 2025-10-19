# MockData Comparison: Current vs MockData Functions

**Date**: 2025-10-17
**Purpose**: Objective comparison of variable coverage between current manual approach (prep-dummy-data.R) and new metadata-driven mockdata functions

---

## Key pattern identified: Case sensitivity differences

**166 of 235 differences (70%) involve case sensitivity, not missing variables.**

Three cycles use UPPERCASE variable names in the hard-coded mock data, while the metadata uses lowercase:
- **cycle6**: 77 variables (UPPERCASE in hard-coded, lowercase in metadata)
- **cycle4_meds**: 3 variables (UPPERCASE in hard-coded, lowercase in metadata)
- **cycle6_meds**: 3 variables (UPPERCASE in hard-coded, lowercase in metadata)

Examples: `CLINICID` vs `clinicid`, `ALC_11` vs `alc_11`, `PAADTOT` vs `paadtot`

**Context**: CHMS data comes from SAS files (case-insensitive), which store variable names in uppercase. Haven imports preserve this uppercase storage format. The pattern likely reflects different import workflows: cycle6/cycle4_meds used direct Haven import (uppercase), while cycles 1-5 may have been converted to lowercase after import.

See [MOCKDATA_CRITICAL_FINDINGS.md](MOCKDATA_CRITICAL_FINDINGS.md) for detailed analysis and suggestions for standardization.

---

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
| cycle1 | 78 | 80 | +2 mockdata functions | |
| cycle1_meds | 76 | 83 | +7 mockdata functions | |
| cycle2 | 78 | 80 | +2 mockdata functions | |
| cycle2_meds | 76 | 83 | +7 mockdata functions | |
| cycle3 | 82 | 81 | -1 current | |
| cycle3_meds | 3 | 3 | 0 | |
| cycle4 | 82 | 82 | 0 | |
| cycle4_meds | 3 | 3 | 0 | |
| cycle5 | 78 | 78 | 0 | |
| cycle5_meds | 3 | 3 | 0 | |
| cycle6 | 77 | 77 | 0 | |
| cycle6_meds | 3 | 3 | 0 | |
| **TOTAL** | **639** | **656** | **+17** | |

---

## Detailed Differences by Cycle

**Legend**:
- ✓ = Variable present in this approach
- ✗ = Variable absent from this approach

### cycle1

**Differences**: 10 variables

| Variable | Current | MockData Functions | Explanation |
|----------|---------|-------------------|-------------|
| gen_015 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| gen_018 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| gen_020 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| paadtot | ✓ | ✗ | Variable only exists in: cycle3, cycle4, cycle5, cycle6 |
| anymed2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| diab_drug2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gen_15 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gen_18 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gen_20 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| thifimp4 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |

### cycle1_meds

**Differences**: 7 variables

| Variable | Current | MockData Functions | Explanation |
|----------|---------|-------------------|-------------|
| meucatc | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| mhr_131b | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| mhr_132b | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| mhr_133b | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| mhr_134b | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| mhr_135b | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| npi_25b | ✗ | ✓ | Variable exists in metadata but not included in current manual data |

### cycle2

**Differences**: 12 variables

| Variable | Current | MockData Functions | Explanation |
|----------|---------|-------------------|-------------|
| gen_015 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| gen_018 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| gen_020 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| lbf_soc | ✓ | ✗ | Variable in current data but not found in variables.csv |
| paadtot | ✓ | ✗ | Variable only exists in: cycle3, cycle4, cycle5, cycle6 |
| anymed2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| diab_drug2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gen_15 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gen_18 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gen_20 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| lafcoc16 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| thifimp4 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |

### cycle2_meds

**Differences**: 7 variables

| Variable | Current | MockData Functions | Explanation |
|----------|---------|-------------------|-------------|
| meucatc | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| mhr_131b | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| mhr_132b | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| mhr_133b | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| mhr_134b | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| mhr_135b | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| npi_25b | ✗ | ✓ | Variable exists in metadata but not included in current manual data |

### cycle3

**Differences**: 13 variables

| Variable | Current | MockData Functions | Explanation |
|----------|---------|-------------------|-------------|
| gen_015 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| gen_018 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| gen_020 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| gfvd17dy | ✓ | ✗ | Needs investigation |
| lab_alt | ✓ | ✗ | Variable only exists in: cycle1, cycle2, cycle4, cycle6 |
| lab_bpb | ✓ | ✗ | Variable only exists in: cycle1, cycle2 |
| lfh_016 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| anymed2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| diab_drug2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gen_15 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gen_18 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gen_20 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| lfh_16 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |

### cycle4

**Differences**: 12 variables

| Variable | Current | MockData Functions | Explanation |
|----------|---------|-------------------|-------------|
| gen_015 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| gen_018 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| gen_020 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| gfvd17dy | ✓ | ✗ | Needs investigation |
| lab_bpb | ✓ | ✗ | Variable only exists in: cycle1, cycle2 |
| lfh_016 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| anymed2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| diab_drug2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gen_15 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gen_18 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gen_20 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| lfh_16 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |

### cycle4_meds

**Differences**: 6 variables

| Variable | Current | MockData Functions | Explanation |
|----------|---------|-------------------|-------------|
| CLINICID | ✓ | ✗ | Variable in current data but not found in variables.csv |
| MEUCATC | ✓ | ✗ | Variable in current data but not found in variables.csv |
| NPI_25B | ✓ | ✗ | Variable in current data but not found in variables.csv |
| clinicid | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| meucatc | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| npi_25b | ✗ | ✓ | Variable exists in metadata but not included in current manual data |

### cycle5

**Differences**: 8 variables

| Variable | Current | MockData Functions | Explanation |
|----------|---------|-------------------|-------------|
| gfvd17dy | ✓ | ✗ | Needs investigation |
| imm_03 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| lab_alt | ✓ | ✗ | Variable only exists in: cycle1, cycle2, cycle4, cycle6 |
| lab_bpb | ✓ | ✗ | Variable only exists in: cycle1, cycle2 |
| diab_drug2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| img_03 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| lab_una | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| thifimp4 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |

### cycle6

**Differences**: 154 variables

| Variable | Current | MockData Functions | Explanation |
|----------|---------|-------------------|-------------|
| CLINICID | ✓ | ✗ | Variable in current data but not found in variables.csv |
| ALC_11 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| ALC_17 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| ALC_18 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| ALCDWKY | ✓ | ✗ | Variable in current data but not found in variables.csv |
| AMMDMVA1 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| AMMDMVA2 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| AMMDMVA3 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| AMMDMVA4 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| AMMDMVA5 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| AMMDMVA6 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| AMMDMVA7 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| BIR_14 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| BPMDPBPD | ✓ | ✗ | Variable in current data but not found in variables.csv |
| BPMDPBPS | ✓ | ✗ | Variable in current data but not found in variables.csv |
| CCC_32 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| CCC_51 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| CCC_59 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| CCC_61 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| CCC_63 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| CCC_81 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| CLC_AGE | ✓ | ✗ | Variable in current data but not found in variables.csv |
| CLC_SEX | ✓ | ✗ | Variable in current data but not found in variables.csv |
| DHH_MS | ✓ | ✗ | Variable in current data but not found in variables.csv |
| DHHDHSZ | ✓ | ✗ | Variable in current data but not found in variables.csv |
| EDUDR04 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| GEN_025 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| GEN_045 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| GEN_055 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| GENDHDI | ✓ | ✗ | Variable in current data but not found in variables.csv |
| GENDMHI | ✓ | ✗ | Variable in current data but not found in variables.csv |
| GFVD17AY | ✓ | ✗ | Variable in current data but not found in variables.csv |
| GFVD17BY | ✓ | ✗ | Variable in current data but not found in variables.csv |
| GFVD17CY | ✓ | ✗ | Variable in current data but not found in variables.csv |
| GFVD17DY | ✓ | ✗ | Variable in current data but not found in variables.csv |
| GFVD18Y | ✓ | ✗ | Variable in current data but not found in variables.csv |
| GFVD19Y | ✓ | ✗ | Variable in current data but not found in variables.csv |
| GFVD20Y | ✓ | ✗ | Variable in current data but not found in variables.csv |
| GFVD22Y | ✓ | ✗ | Variable in current data but not found in variables.csv |
| GFVD23Y | ✓ | ✗ | Variable in current data but not found in variables.csv |
| HWM_11CM | ✓ | ✗ | Variable in current data but not found in variables.csv |
| HWM_13KG | ✓ | ✗ | Variable in current data but not found in variables.csv |
| HWM_14CX | ✓ | ✗ | Variable in current data but not found in variables.csv |
| HWMDBMI | ✓ | ✗ | Variable in current data but not found in variables.csv |
| IMM_03 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| LAB_ALKP | ✓ | ✗ | Variable in current data but not found in variables.csv |
| LAB_ALT | ✓ | ✗ | Variable in current data but not found in variables.csv |
| LAB_BCRE | ✓ | ✗ | Variable in current data but not found in variables.csv |
| LAB_BPB | ✓ | ✗ | Variable in current data but not found in variables.csv |
| LAB_CA | ✓ | ✗ | Variable in current data but not found in variables.csv |
| LAB_CHOL | ✓ | ✗ | Variable in current data but not found in variables.csv |
| LAB_GGT | ✓ | ✗ | Variable in current data but not found in variables.csv |
| LAB_HBA1 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| LAB_HDL | ✓ | ✗ | Variable in current data but not found in variables.csv |
| LAB_VIDS | ✓ | ✗ | Variable in current data but not found in variables.csv |
| LAFCOC16 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| LAFDWSL | ✓ | ✗ | Variable in current data but not found in variables.csv |
| LMH_016 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| MDCD04Y | ✓ | ✗ | Variable in current data but not found in variables.csv |
| PAADTOT | ✓ | ✗ | Variable in current data but not found in variables.csv |
| PGDCGT | ✓ | ✗ | Variable in current data but not found in variables.csv |
| PRS_11 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| SMK_11 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| SMK_21 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| SMK_31 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| SMK_41 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| SMK_42 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| SMK_52 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| SMK_53 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| SMK_54 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| SMKDSTY | ✓ | ✗ | Variable in current data but not found in variables.csv |
| SPA_020 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| THI_01 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| THIFIMP4 | ✓ | ✗ | Variable in current data but not found in variables.csv |
| WGT_FULL | ✓ | ✗ | Variable in current data but not found in variables.csv |
| WSDD34Y | ✓ | ✗ | Variable in current data but not found in variables.csv |
| WSDD35Y | ✓ | ✗ | Variable in current data but not found in variables.csv |
| alc_11 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| alc_17 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| alcdwky | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| ammdmva1 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| ammdmva2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| ammdmva3 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| ammdmva4 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| ammdmva5 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| ammdmva6 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| ammdmva7 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| anymed2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| bir_14 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| bpmdpbpd | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| bpmdpbps | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| ccc_32 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| ccc_51 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| ccc_59 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| ccc_61 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| ccc_63 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| ccc_81 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| clc_age | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| clc_sex | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| clinicid | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| dhh_ms | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| dhhdhsz | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| diab_drug2 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| edudr04 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gen_025 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gen_045 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gen_055 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gendhdi | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gendmhi | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gfvd17ay | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gfvd17by | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gfvd17cy | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gfvd18y | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gfvd19y | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gfvd20y | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gfvd22y | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| gfvd23y | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| hwm_11cm | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| hwm_13kg | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| hwm_14cx | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| hwmdbmi | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| img_03 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| lab_alkp | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| lab_alt | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| lab_bcre | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| lab_ca | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| lab_chol | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| lab_ggt | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| lab_hba1 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| lab_hdl | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| lab_una | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| lab_vids | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| lafcoc16 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| lafdwsl | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| lmh_016 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| mdcd04y | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| paadtot | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| pgdcgt | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| prs_11 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| smk_11 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| smk_21 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| smk_31 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| smk_41 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| smk_42 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| smk_52 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| smk_53 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| smk_54 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| smkdsty | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| spa_020 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| thi_01 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| thifimp4 | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| wgt_full | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| wsdd34y | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| wsdd35y | ✗ | ✓ | Variable exists in metadata but not included in current manual data |

### cycle6_meds

**Differences**: 6 variables

| Variable | Current | MockData Functions | Explanation |
|----------|---------|-------------------|-------------|
| CLINICID | ✓ | ✗ | Variable in current data but not found in variables.csv |
| MEUCATC | ✓ | ✗ | Variable in current data but not found in variables.csv |
| NPI_25B | ✓ | ✗ | Variable in current data but not found in variables.csv |
| clinicid | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| meucatc | ✗ | ✓ | Variable exists in metadata but not included in current manual data |
| npi_25b | ✗ | ✓ | Variable exists in metadata but not included in current manual data |

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
- [R/mockdata-parsers.R](R/mockdata-parsers.R)
- [R/mockdata-helpers.R](R/mockdata-helpers.R)
- [R/mockdata-generators.R](R/mockdata-generators.R)
- [mockdata-tools/test-all-cycles.R](mockdata-tools/test-all-cycles.R)

---

## Next Steps

This comparison identifies differences for team review. Key questions:

1. Should mock data use raw or harmonized variable names?
2. Should variables not in metadata (e.g., gen_015) be included?
3. Is current coverage (72-75 vars/cycle) intentionally minimal or should it be comprehensive?
4. Should variables from wrong cycles (e.g., paadtot in cycle1) be removed?

See [MOCKDATA_QUESTIONS.md](MOCKDATA_QUESTIONS.md) for detailed questions.
