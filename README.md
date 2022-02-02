
<!-- README.md is generated from README.Rmd. Please edit that file -->

# helpeRs

<!-- badges: start -->

[![R-CMD-check](https://github.com/drejom/helpeRs/workflows/R-CMD-check/badge.svg)](https://github.com/drejom/helpeRs/actions)
[![Codecov test
coverage](https://codecov.io/gh/drejom/helpeRs/branch/main/graph/badge.svg)](https://app.codecov.io/gh/drejom/helpeRs?branch=main)
[![Project Status: Concept – Minimal or no implementation has been done
yet, or the repository is only intended to be a limited example, demo,
or
proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://choosealicense.com/licenses/mit/)
[![Last-changedate](https://img.shields.io/badge/last%20change-2022--02--01-yellowgreen.svg)](/commits/main)
[![minimal R
version](https://img.shields.io/badge/R%3E%3D-41.2-6666ff.svg)](https://cran.r-project.org/)
[![packageversion](https://img.shields.io/badge/Package%20version-x86_64-apple-darwin17.0,%20x86_64,%20darwin17.0,%20x86_64,%20darwin17.0,%20,%204,%201.2,%202021,%2011,%2001,%2081115,%20R,%20R%20version%204.1.2%20(2021-11-01),%20Bird%20Hippie-orange.svg?style=flat-square)](commits/main)

<!-- badges: end -->

The goal of helpeRs is to …

## Things to include

<https://www.r-bloggers.com/2016/07/introducing-badgecreatr-a-package-that-places-badges-in-your-readme/>

<https://www.r-bloggers.com/2017/06/how-to-add-code-coverage-codecov-to-your-r-package/>

<https://cynkra.github.io/fledge/>

## Installation

You can install the development version of helpeRs from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("drejom/helpeRs")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(helpeRs)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this. You could also
use GitHub Actions to re-render `README.Rmd` every time you push. An
example workflow can be found here:
<https://github.com/r-lib/actions/tree/v1/examples>.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
