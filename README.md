KI Labs - Take home code challenge
================
Barbara Borges Ribeiro

## Problem statement

I’ll start by presenting the challenge itself: building an interview
calendar API. There are two possible roles for the end users: an
interviewer, or a candidate. Both types of users need to be able to use
the API to set their date and time availability for interviews. An
interview slot is defined as a 1-hour period of time, starting at the
top of the hour (i.e. xx:00, where 0 \<= xx \<= 23). Finally, anyone may
query the API to know when it’s possible to schedule an interview with a
particular candidate and one (or more) interviewers.

The paragraph above describes the problem statement as simply and
faithfully to the instructions as I could make it. Upon examining these
“rules,” however, I found some room for interpretation. I made
conscious decisions for these gray areas, which I’d like to explain
here:

  - While the problem statement mentions the two possible roles, it also
    says that “anyone may then query the API to get a collection of
    periods of time when it’s possible to arrange an interview.” In this
    context, the word *anyone* may either refer to anyone from the
    universe of the defined end users (i.e. all candidates and all
    interviewers) or anyone from another universe (for example, everyone
    that works at the company that is interviewing). The latter seemed
    more plausible to me, and therefore I purposely don’t require a
    “role” or any name or id when querying the API.

  - Similarly, while it’s clear that in order to query the API for
    possible interview slots, the user needs to provide the candidate’s
    name (or some unique id), it is unclear whether one (or more)
    interviewer’s name/id needs to be provided as well. I decided not to
    require an interviewer’s name/id when searching interview
    availability, in which case, *all* interviewers will be considered.

  - Lastly, and more importantly, I spent a significant amount of time
    deciding on the definition of an API, in the context of this
    project:

### The definition of API

The acronym *API* is overloaded in computer science. In its broadest
definition, an API is some set of tools, provided by a set of software,
that allow users and/or other software to interact with it. At this
level, almost all user-facing code can be considered an API. Whether it
is a set of documented functions in a programming language, or a full
blown GUI in a modern web app, the word API applies to a diverse set of
things.

At the other end of the spectrum, an API can also mean something a lot
more specific. In our web-centric days, the word *API* can also mean
what is technically a subset of API types: a REST API, almost always
implemented using the HTTP protocol. Given the popularity of the web,
this is totally understandable and often desirable. If you have a set of
code and you can expose it using a web-based request-response system,
your API is both following an established medium for real API
implementations and lowering the bar of entry for potential users (no
downloads, no configs – just very modular, simple, documented ways to
interact with code).

For the reasons just mentioned, this project could well go down the
REST, HTTP-based route and do well. However, upon reading the assignment
a few times, I decided against it. Since “the purpose of this test is
not to implement a production-ready API,” the advantages of a REST API
were less clear. It certainly isn’t inherently easier for users to use,
at least not unless it is made into a GUI, which is another thing that
I’m skipping for this project. Choosing to have a looser-definition
*API* gives me a lot more flexibility, and with that come some choices.

### Language and framework choices

I decided to use R for this project, mainly because of my familiarity
with the language. In addition, I’m using the package `R6` to create a
`Calendar` class (it’s possible to do OOP in base R, but `R6` provides a
more modern approach). Finally, the set of packages in the `tidyverse`
wrapper package provide all kinds of helper function for data
manipulation (see <https://tidyverse.tidyverse.org/>).

## Setup and overview

Given how I interpreted the word *API* for the purposes of this project,
users need to have **R** downloaded and installed (see
<https://cloud.r-project.org/>). Once this is done, open the R console.
At this point, you also need to install the following packages:

``` r
install.packages("R6")  # R6 is a package used for OOP in R
install.packages("tidyverse") # this downloads a set of packages used for data manipulation
```

Finally, you need to “source” the the R file in this project to your
open R console:

``` r
source("Calendar.R")
```

This is the only source file required. I documented all user-facing
functions (i.e. the `public` functions) and added other comments as
appropriate. These often include TODOs of features that I think would
make sense to implement for a next step. These are scoped to the
existing code. Proper data management (i.e. not in memory),
authentication and a UI would all be highly desirable, but are also
outside of the scope of this project. While it would be possible to
adapt the current code to meet these (and other) production-level goals,
I think that it would be far more reasonable, at that point, to ditch R
and the existing code and implement the same/similar logic in a
language/framework that is optimized and performant for those goals.

The file **Calendar.R** defines a single class (using the `R6` library),
called “Calendar.” A new calendar is instantiated by calling the
built-in `new()` constructor: `myCal <- Calendar$new()`. The `private`
variables and methods are not accessible to end users and, in this case,
are used to store data, or consist of implementation-level functions.
Since we’re storing the data in the Calendar object itself, all users
would need to use the same machine, in order for that Calendar object to
be complete. (The easiest to productionize/scale this would be moving
the data to a remote, persistent database and using the Calendar’s class
constructor to open a new connection to the database.)

The `public` methods (no public variables exist) make up the API itself:

  - the `registerInterviewer()` and `registerCandidate()` functions are
    used to add new users to the calendar;
  - the `setSlot()` function allows users to add their availability to
    the calendar;
  - the `searchAvailability()` function finds (and returns) the time
    availability for one candidate and one or more interviewers.

I will now demo these functions by giving an usage example. I’ll use the
current week and the same names, roles and times as the assigment
write-up.

## Usage example

First, we instantiate our new `Calendar` object, `cal`:

``` r
cal <- Calendar$new()
```

Then, we register each interviewer and candidate and set their
availability slots:

``` r
# The interviewer Ines is available all week (22 to 26 October 2018),
# starting at 9am and finishing at 4pm
cal$registerInterviewer("Ines")
cal$setSlot(role = "interviewer", name = "Ines",
  list("2018-10-22", "2018-10-23", "2018-10-24", "2018-10-25", "2018-10-26"),
  list(9:15, 9:15, 9:15, 9:15, 9:15)
)

# The interviewer Ingrid is available from 12pm to 6pm on Mon/Wed and
# from 9am to 12pm on Tues/Thurs
cal$registerInterviewer("Ingrid")
cal$setSlot(role = "interviewer", name = "Ingrid",
  list("2018-10-22", "2018-10-23", "2018-10-24", "2018-10-25"),
  list(12:17, 9:11, 12:17, 9:11)
)

# The candidate Carl is available at 9 am any weekday, and until 
# noon on Wednesday
cal$registerCandidate("Carl")
cal$setSlot(role = "candidate", name = "Carl",
  list("2018-10-22", "2018-10-23", "2018-10-24", "2018-10-25", "2018-10-26"),
  list(9, 9, 9:11, 9, 9)
)
```

Finally, we query our `cal` object for the `Carl`’s interview
availability, in three different scenarios:

1.  Not specifying any interviewer (returns all single-interviewer
    options):

<!-- end list -->

``` r
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

2.  Specifying one interviewer (returns all interviewer options for that
    interviewer):

<!-- end list -->

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

2.  Specifying two interviewers (returns all options when both
    interviewers are available):

<!-- end list -->

``` r
cal$searchAvailability("Carl", "Ines", "Ingrid")
```

    ## # A tibble: 2 x 4
    ##   candidate slot                interviewer.x interviewer.y
    ##   <chr>     <dttm>              <chr>         <chr>        
    ## 1 Carl      2018-10-23 09:00:00 Ines          Ingrid       
    ## 2 Carl      2018-10-25 09:00:00 Ines          Ingrid
