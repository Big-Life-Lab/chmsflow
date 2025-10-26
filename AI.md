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
anymed → any_htn_med
acemed → ace_med
diab_drug → diab_med
```

---

## Function naming

**Use `snake_case` and start with a verb**

**Proposed verb taxonomy** (simplified):

| Verb             | Purpose                   | Example                                                 |
| ---------------- | ------------------------- | ------------------------------------------------------- |
| `calculate_`  | Mathematical computation  | `calculate_gfr(creatinine, age)`<br />calculate_bmi() |
| `categorize_`  | Continuous → categorical | `categorize_bmi(bmi)`                                 |

**DISCUSSION**:

- Map existing verbs: `determine_*`, `find_*`, `adjust_*`, `is_*`, `cycles1to2_*`
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
