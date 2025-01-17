---
name: Variable request
about: Suggest a variable for chmsflow
title: ''
labels: ''
assignees: ''

---

**Introduction**

We accept requests and PR for new variables. Providing information about your request helps discussion about whether and how to include the variable.

**Is the variable an existing CHMS variable, or a derived variable?**

Does this variable exist already in CHMS cycles, or is it a newly derived variable?

**What is the name of the variable?**

What is the most consistent name for this variable? If this is an derived variable, what is the name of the newly derived variable?

**Description of variable**

Provide a brief description of the variable.

**Is it consistent across CHMS cycles? If not, explain changes between cycles**

For existing variables in the CHMS.

**Which cycles is this variable found?**

For existing variables in the CHMS.

**Derived variables only. What variables are used to create this variable?**

List the variables in chmsflow used to create this variable

**Additional context**

Add any other context or screenshots about the feature request here.

**Additional instructions for derived variables**

Derived variables use R code for more complex operations and multiple starting variables. Note: chmsflow currently uses only base R to derive variables. More complex derived variables that require dependancies are currently out-of-scope for chmsflow.

If possible, attach an .R file that includes documentation of the derived variable as per roxygen2 standards, along with the code to derive the variable. Include all starting variables.
