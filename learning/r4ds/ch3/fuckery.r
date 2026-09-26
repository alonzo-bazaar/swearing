library(nycflights13)
library(tidyverse)

## was there a flight from nyc on on every day of 2013?
### ways to do it
count(distinct(flights, month, day))$n # one way
count(distinct(flights, month * 100 + day))$n # another way

is_leap_year <- function(year) {
    ## secondo il calendario gregoriano
    if (year %% 400 == 0) return(TRUE)
    if (year %% 100 == 0) return(FALSE)
    if (year %%   4 == 0) return(TRUE)
                          return(FALSE)
}
months_length <- function(year) {
    ## 30 giorni ha novembre, con april, giugno, e settembre
    nov_len <- 30
    apr_len <- 30
    jun_len <- 30
    sep_len <- 30
    ## di 28 ce n'è solo uno
    feb_len <- if (is_leap_year(year)) 29 else 28
    ## tutti gli altri ne han 31
    jan_len <- 31
    mar_len <- 31
    may_len <- 31
    jul_len <- 31
    aug_len <- 31
    oct_len <- 31
    dec_len <- 31
    month_length = c(jan_len, feb_len, mar_len, apr_len, may_len, jun_len,
                     jul_len, aug_len, sep_len, oct_len, nov_len, dec_len)
}

month         <- flights$month
month_day     <- flights$day
month_offset  <- append(c(0), cumsum(months_length(2013)))
year_day      <- month_day + month_offset[month]
length(unique(year_day)) # yet another way

## most distance
slice_max(flights, distance)
## least distance
slice_min(flights, distance)

                 
