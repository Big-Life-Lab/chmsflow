# variables.csv

## Introduction

This vignette describes how the `variables.csv` worksheet is organized
and how to find variables that you can transform. See also the vignette
`variable_details.csv`. The [Get
Started](https://big-life-lab.github.io/chmsflow/articles/get_started.html)
vignette provides examples of how to use the two worksheets.

Read `variables.csv`

    #> There are 213 variables, grouped in 24 subjects and 5 sections that are available for
    #>     transformation in CHMS cycles 1-6.

    #> You can search for variables in the table below. Try searching for the 3 age variables that are used in the Transform
    #>     CHMS variables vignette. All 3 variables are in the age subject. Try sorting the subject column by clicking
    #>     the up beside the `subject` heading: the top 3 rows of the table should show the age variables:
    #> [1] "agegroup2079" "agegroup4"    "clc_age"

## How the `variables.csv` sheet is organized

In each row there are 7 columns in this worksheet and they are as
follows:

1.  **variable:** the name of the final transformed variable.

2.  **label:** the shorthand label for the variable.

3.  **labelLong:** a more detailed label for the variable.

4.  **section:** the section where this variable could be found
    (i.e. demographic, health behaviour, chronic diseases).

5.  **subject:** what the variable pertains to (i.e. age, smoking, sex).

6.  **variableType:** whether the final variable is categorical or
    continuous.

7.  **units:** any units for the final variable.

8.  **databaseStart:** the list of CHMS surveys/cycles that contain the
    variable of interest

9.  **variableStart:** the original names of the variables as they are
    listed in each respective CCHS cycle

## Derived Variables

Derived variables follow the same naming conventions as CHMS variables
when being listed in `variables.csv`.

## Contributing or customizing `variables.csv`

We recommend that you copy `variables.csv` with the variables that you
use for your project. You can include only the variables that you use
for your project, thereby providing a reference for your project.
`variables.csv` is a CSV file to allow use `chmsflow` within teams that
do not use R or have programming experience.

You can create your own transformed or derived variables by using the
chmsflow `variables.csv` as a template. We welcome
[issues](https://github.com/Big-Life-Lab/chmsflow/issues) for comments
to existing variables in \`variables.csv. Also welcomed are PR for new
transformations that you feel are helpful for others who use the CCHS
data. See
[Contributing](https://github.com/Big-Life-Lab/chmsflow/blob/dev/CONTRIBUTING.md).
