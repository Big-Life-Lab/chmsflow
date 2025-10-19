# Metadata Documentation for chmsflow

**Last updated**: 2025-10-18

This directory contains metadata schema documentation and database configuration files for the chmsflow package. These files document the structure, validation rules, and patterns used in CHMS data harmonization.

## Purpose

These YAML files serve multiple purposes:

1. **Documentation**: Define the structure and meaning of metadata fields
2. **Validation**: Provide rules for automated quality checking
3. **Future migration**: Support eventual transition to recodeflow architecture
4. **Consistency**: Ensure alignment with cchsflow and broader recodeflow ecosystem

## Directory Structure

```
inst/metadata/
├── README.md                          # This file
├── documentation/                     # General metadata standards
│   ├── database_metadata.yaml        # Dublin Core database-level metadata schema
│   └── metadata_registry.yaml        # Central registry of shared specifications
└── schemas/                           # Data structure schemas
    └── chms/                          # CHMS-specific schemas
        ├── chms_database_config.yaml # CHMS database selection and parsing rules
        ├── variables.yaml            # Schema for variables.csv
        └── variable_details.yaml     # Schema for variable-details.csv
```

## Key Files

### documentation/database_metadata.yaml

Defines Dublin Core-compliant database-level metadata:
- Dataset titles, descriptions, creators
- Coverage (temporal, spatial, population)
- Rights and access information
- Keywords and subject classification

**Use case**: When creating comprehensive dataset documentation

### documentation/metadata_registry.yaml

Central registry of shared specifications used across all schema files:
- CSV format specifications
- Tier system (core, optional, versioning, extension)
- Validation patterns (variable names, dates, etc.)
- Transformation patterns for variableStart field

**Use case**: Reference for understanding validation rules and patterns

### schemas/chms/variables.yaml

Schema for `inst/extdata/variables.csv`:
- Field definitions (variable, label, variableType, databaseStart, variableStart)
- Validation rules and constraints
- Examples and usage notes
- Tier classification (core vs optional fields)

**Use case**: Understanding what each column in variables.csv means

### schemas/chms/variable_details.yaml

Schema for `inst/extdata/variable-details.csv`:
- Field definitions (variable, cycle, recodes, catLabel)
- Recoding specifications
- Missing data handling
- Category label requirements

**Use case**: Understanding how to specify variable recoding rules

### schemas/chms/chms_database_config.yaml

**CHMS database configuration following recodeflow conventions**:

**Recodeflow conventions** (work across CCHS, CHMS, all projects):
- variableStart format specifications (support rec_with_table()):
  - `[varname]` - bracket format (database-agnostic)
  - `database::varname` - database-prefixed format
  - `database::var1, [var2]` - mixed format
  - `DerivedVar::[var1, var2]` - derived variables
- Range notation patterns (e.g., `[7,9]`, `[18.5,25)`, `else`)
- tagged_na patterns for missing data

**CHMS-specific elements**:
- Valid cycle names (cycle1-7, cycle1_meds-cycle6_meds)
- Cycle naming patterns and validation
- OBSERVATION: Cycle 1 often has different variable names than Cycles 2-6
  (e.g., amsdmva1 vs ammdmva1) - this is a CHMS data pattern

**Use case**: Understanding which patterns are universal recodeflow conventions vs CHMS-specific observations

## Recodeflow Conventions Applied to CHMS

### Important: Recodeflow vs CHMS-Specific

**Recodeflow conventions** (universal across all harmonization projects):
- variableStart formats: `[varname]`, `database::varname`, mixed, DerivedVar
- Range notation: `[7,9]`, `[18.5,25)`, `else`
- tagged_na patterns for missing data
- These support rec_with_table() and recodeflow functions

**CHMS-specific observations**:
- Cycle naming: cycle1, cycle2, cycle1_meds, etc.
- Pattern: Cycle 1 (2007-2009) often used different variable names than later cycles

### variableStart Formats (RECODEFLOW CONVENTION)

The `variableStart` field supports multiple recodeflow-standard formats:

#### 1. Bracket format `[varname]` - RECODEFLOW CONVENTION
```yaml
variable: clc_age
variableStart: [clc_age]
databaseStart: cycle1, cycle2, cycle3, cycle4, cycle5, cycle6
```
**Recodeflow standard**: Used when variable name is **consistent across all databases/cycles**.
Works in CCHS, CHMS, and all recodeflow projects.

#### 2. Database-prefixed format `database::varname` - RECODEFLOW CONVENTION
```yaml
variable: gen_025
variableStart: cycle1::gen_15, cycle2::gen_15, cycle3::gen_15, cycle4::gen_15, [gen_025]
databaseStart: cycle1, cycle2, cycle3, cycle4, cycle5, cycle6
```
**Recodeflow standard**: Format is `database_name::variable_name`
- In CHMS: database = cycle1, cycle2, etc.
- In CCHS: database = cchs2001, cchs2017_p, etc.

Used when variable name **changes across databases/cycles**.

#### 3. Mixed format `database::var1, [var2]` - RECODEFLOW CONVENTION
```yaml
variable: ammdmva1
variableStart: cycle1::amsdmva1, [ammdmva1]
databaseStart: cycle1, cycle2, cycle3, cycle4, cycle5, cycle6
```
**Recodeflow standard**: `[variable]` represents the **DEFAULT** for all databases not specifically referenced.

Format: `database::specific_name, [default_name]`
- For specified database: use `database::specific_name`
- For all other databases: use `[default_name]` as default

**Design rationale**: Reduces verbosity and repetition when only one or a few databases use different variable names.

**CHMS example**: Instead of writing:
```
cycle1::amsdmva1, cycle2::ammdmva1, cycle3::ammdmva1, cycle4::ammdmva1, cycle5::ammdmva1, cycle6::ammdmva1
```

We write:
```
cycle1::amsdmva1, [ammdmva1]
```

Where `[ammdmva1]` is the default for cycles 2-6.

#### 4. DerivedVar format `DerivedVar::[var1, var2, ...]` - RECODEFLOW CONVENTION
```yaml
variable: adj_hh_inc
variableStart: DerivedVar::[thi_01, dhhdsz]
databaseStart: cycle1, cycle2, cycle3, cycle4, cycle5, cycle6
```
**Recodeflow standard**: Used for variables requiring **calculation from multiple sources**.
Supported by rec_with_table() across all recodeflow projects.

MockData functions currently return NULL for DerivedVar (future enhancement).

### Range Notation (RECODEFLOW CONVENTION)

The `recodes` field in variable-details.csv uses **recodeflow-standard range notation**:

```yaml
# Integer ranges
[7,9]         # Includes 7, 8, 9
[1,5)         # Includes 1, 2, 3, 4 (excludes 5)

# Continuous ranges
[18.5,25)     # BMI: 18.5 ≤ x < 25
[25,30)       # BMI: 25 ≤ x < 30

# Special values
else          # Catch-all for values not covered by other rules
```

This notation is **universal across all recodeflow projects** (CCHS, CHMS, etc.) and
is parsed by `parse_range_notation()` function (also used in cchsflow).

### databaseStart Format

Comma-separated list of valid database/cycle names:

```yaml
# Single cycle
databaseStart: cycle1

# Multiple cycles
databaseStart: cycle1, cycle2, cycle3, cycle4, cycle5, cycle6

# Medication cycles
databaseStart: cycle1_meds, cycle2_meds, cycle3_meds
```

**Validation rules**:
- All cycle names must be valid (see `chms_database_config.yaml`)
- Use exact matching (not substring matching)
- Spaces after commas are optional but recommended
- No mixing regular and _meds cycles

## How Parsers Use These Schemas

### parse_variable_start.R

Uses the patterns documented in `chms_database_config.yaml`:

1. **Strategy 1**: Look for `cycle::varname` matching requested cycle
2. **Strategy 2**: Check if entire string is `[varname]` format
3. **Strategy 2b**: Check if any segment is `[varname]` (mixed format fallback)
4. **Strategy 3**: Use plain text as-is
5. **Return NULL**: For DerivedVar format

Example with mixed format:
```r
# metadata: variableStart: "cycle1::amsdmva1, [ammdmva1]"

parse_variable_start("cycle1::amsdmva1, [ammdmva1]", "cycle1")
# Returns: "amsdmva1" (Strategy 1 matches)

parse_variable_start("cycle1::amsdmva1, [ammdmva1]", "cycle2")
# Returns: "ammdmva1" (Strategy 2b uses bracket segment as fallback)
```

### get_cycle_variables.R

Uses `databaseStart` validation rules:

```r
# Split databaseStart by comma and exact match
cycles <- strsplit(db_start, ",")[[1]]
cycles <- trimws(cycles)
cycle %in% cycles  # Exact match, not substring
```

This prevents `cycle1` from matching `cycle1_meds`.

## Validation

Run automated validation with:

```r
source("data-raw/validate-metadata.R")
```

This checks:
- ✓ All databaseStart cycles are valid
- ✓ All variableStart entries parse correctly
- ✓ Categorical variables have variable_details
- ⚠ Parsed names are reasonable (warnings only)

## Relationship to cchsflow and recodeflow

These schema files document **recodeflow conventions** that work across all projects:

**From cchsflow (recodeflow standards)**:
- `documentation/database_metadata.yaml` - Dublin Core standard (recodeflow)
- `documentation/metadata_registry.yaml` - Shared specifications (recodeflow)
- `schemas/chms/variables.yaml` - Core variable schema (recodeflow)
- `schemas/chms/variable_details.yaml` - Variable details schema (recodeflow)

**CHMS-specific configuration**:
- `schemas/chms/chms_database_config.yaml` - CHMS cycle names and observed patterns

**Key distinction**:
- **Recodeflow conventions**: variableStart formats, range notation, tagged_na - work across CCHS, CHMS, all projects
- **CHMS-specific**: Cycle naming (cycle1, cycle2), the *observation* that Cycle 1 often has different names

This ensures we're using standard recodeflow patterns while documenting CHMS-specific observations.

## Future Migration to recodeflow

When chmsflow migrates to the recodeflow architecture:

1. These schemas define the expected structure
2. CSV files in `inst/extdata/` can be validated against schemas
3. Migration scripts can reference field definitions
4. Parsing logic is already documented for reuse

## Common Questions

### Why mixed format (`database::var1, [var2]`)?

**Recodeflow convention**: The `[variable]` notation represents the **DEFAULT** for all databases that aren't specifically referenced. The `database::variable` notation is the **exception/override**.

**Purpose**: Reduces verbosity and repetition in metadata. Instead of repeating the same variable name for multiple databases, you specify the exception(s) and provide a default.

**CHMS example**: Cycle 1 (2007-2009) often used different variable names than Cycles 2-6. Rather than:
```
cycle1::amsdmva1, cycle2::ammdmva1, cycle3::ammdmva1, cycle4::ammdmva1, cycle5::ammdmva1, cycle6::ammdmva1
```

We write:
```
cycle1::amsdmva1, [ammdmva1]
```

This design choice reduces repetition while preserving traceability.

### Why are DerivedVar variables NULL in MockData?

DerivedVar is a **recodeflow convention** for variables requiring custom calculation logic (e.g., `adj_hh_inc` = `thi_01 / dhhdsz`).

The MockData functions focus on simple mapping from metadata specifications. Derived variables would require implementing the calculation logic. This is a future enhancement for MockData, though rec_with_table() in recodeflow already supports DerivedVar.

### How do I know if my metadata is valid?

Run `Rscript data-raw/validate-metadata.R` to check:
- All cycles in databaseStart are valid
- All variableStart entries parse for declared cycles
- All categorical variables have specifications
- No case-sensitivity issues

## References

- **cchsflow metadata**: `/Users/dmanuel/github/cchsflow/inst/metadata/`
- **Dublin Core standard**: https://www.dublincore.org/specifications/dublin-core/
- **DCAT vocabulary**: https://www.w3.org/TR/vocab-dcat-2/
- **recodeflow architecture**: (in development)

## Maintenance

These schema files should be updated when:
- New cycles are added (update `valid_cycles` in chms_database_config.yaml)
- New variableStart patterns are introduced
- Field definitions change in variables.csv or variable-details.csv
- Migration to recodeflow requires new specifications

**Maintainer**: chmsflow development team
