KI Labs - Take home code challenge
================
Barbara Borges Ribeiro

``` r
source("Calendar.R")
```

USAGE EXAMPLE

``` r
cal <- Calendar$new()

# The interviewer Ines is available all of next week 
# (22 to 26 October 2018), starting at 9am and 
# finishing at 4pm
cal$registerInterviewer("Ines")
cal$setSlot(role = "interviewer", name = "Ines",
  list("2018-10-22", "2018-10-23", "2018-10-24", "2018-10-25", "2018-10-26"),
  list(9:15, 9:15, 9:15, 9:15, 9:15)
)

# The interviewer Ingrid is available from 12pm to 6pm
# on Mon/Wed and from 9am to 12pm on Tues/Thurs
cal$registerInterviewer("Ingrid")
cal$setSlot(role = "interviewer", name = "Ingrid",
  list("2018-10-22", "2018-10-23", "2018-10-24", "2018-10-25"),
  list(12:17, 9:11, 12:17, 9:11)
)

# The candidate Carl is available at 9 am any weekday,
# and until noon on Wednesday
cal$registerCandidate("Carl")
cal$setSlot(role = "candidate", name = "Carl",
  list("2018-10-22", "2018-10-23", "2018-10-24", "2018-10-25", "2018-10-26"),
  list(9, 9, 9:11, 9, 9)
)

cal$searchAvailability("Carl")
```

    ## # A tibble: 9 x 3
    ##   candidate slot                interviewer
    ##   <chr>     <dttm>              <chr>      
    ## 1 Carl      2018-10-22 09:00:00 Ines       
    ## 2 Carl      2018-10-23 09:00:00 Ines       
    ## 3 Carl      2018-10-23 09:00:00 Ingrid     
    ## 4 Carl      2018-10-24 09:00:00 Ines       
    ## 5 Carl      2018-10-24 10:00:00 Ines       
    ## 6 Carl      2018-10-24 11:00:00 Ines       
    ## 7 Carl      2018-10-25 09:00:00 Ines       
    ## 8 Carl      2018-10-25 09:00:00 Ingrid     
    ## 9 Carl      2018-10-26 09:00:00 Ines

``` r
cal$searchAvailability("Carl", "Ines")
```

    ## # A tibble: 7 x 3
    ##   candidate slot                interviewer
    ##   <chr>     <dttm>              <chr>      
    ## 1 Carl      2018-10-22 09:00:00 Ines       
    ## 2 Carl      2018-10-23 09:00:00 Ines       
    ## 3 Carl      2018-10-24 09:00:00 Ines       
    ## 4 Carl      2018-10-24 10:00:00 Ines       
    ## 5 Carl      2018-10-24 11:00:00 Ines       
    ## 6 Carl      2018-10-25 09:00:00 Ines       
    ## 7 Carl      2018-10-26 09:00:00 Ines

``` r
cal$searchAvailability("Carl", "Ingrid")
```

    ## # A tibble: 2 x 3
    ##   candidate slot                interviewer
    ##   <chr>     <dttm>              <chr>      
    ## 1 Carl      2018-10-23 09:00:00 Ingrid     
    ## 2 Carl      2018-10-25 09:00:00 Ingrid

``` r
cal$searchAvailability("Carl", "Ines", "Ingrid")
```

    ## # A tibble: 2 x 4
    ##   candidate slot                interviewer.x interviewer.y
    ##   <chr>     <dttm>              <chr>         <chr>        
    ## 1 Carl      2018-10-23 09:00:00 Ines          Ingrid       
    ## 2 Carl      2018-10-25 09:00:00 Ines          Ingrid
