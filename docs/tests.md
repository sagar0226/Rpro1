# Tests

## Why test your code?

As you write code, you will inevitably make mistakes. There are two main types of mistakes with coding - those that prevent code from working (i.e. give you an error message and don't run the code) and those that run the code but give you the wrong result. Of these, the first is probably more frustrating as R tends to give fairly unhelpful error messages and you'll feel you hit a roadblock since R just isn't working right. However, the second issue - code is wrong but doesn't tell you it's wrong! - is far more dangerous. This is especially true for research projects.

Let's use examining whether a policy affected murder as an example. In the example data set below, we have two years of data for both murder and theft. If we want to see if murder changed from 2000 to 2001, we could (overly simply) see if the number of murders in 2001 was different from the number in 2000. And since the data also has theft, we'd want to subset to murder first.


```r
example_data <- data.frame(year = c(2000, 2000, 2001, 2001),
                           crime_type = c("murder", "theft", "murder", "theft"),
                           crime_count = c(100, 100, 200, 50))
example_data
#>   year crime_type crime_count
#> 1 2000     murder         100
#> 2 2000      theft         100
#> 3 2001     murder         200
#> 4 2001      theft          50
```


```r
example_data[, crime_type ! "theft"]
#> Error: <text>:1:27: unexpected '!'
#> 1: example_data[, crime_type !
#>                               ^
```



## Unit tests

### What to test

### How to test

## Continuous integration services

### Travis CI

### App Veyor

## Test-driven development (TDD)

## Tests for research projects

When you use R for a research project you'll usually take data that someone else collected, or scrape it yourself, do some work to clean this data (e.g. subset or aggregate the data, standardize values) and then run a regression on it. In these cases there are fewer opportunities to use unit tests to check your code. Indeed, the best checks are often content knowledge about the data and examining the results of the regression to see if it makes sense and fits prior literature. 