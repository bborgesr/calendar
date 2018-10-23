# A basic calendar API
# 
# There are 2 roles: candidate and interviewer.
# An interview slot is a 1-hour period that starts on the hour (xx:00)
# Interviewers and candidates submit their availability slots.
# Anyone can query the API to get a collection of slots when it's 
# possible to interview a particular candidate and one or more interviewers.
# 
# Notes: It's okay to skip the UI and authentication, and implement
# the API only.

# library(tidyverse)  -- make sure to have it installed: install.packages("tidyverse")
# library(R6)         -- make sure to have it installed: install.packages("R6")

Calendar <- R6::R6Class("Calendar",
  public = list(
    # Register a new interviewer by adding it to the private$interviewer vector
    # 
    # @param name A (unique) name for the interviewer
    # TODO: Make names unique in the implementation, rather than 
    # requiring it from the user 
    registerInterviewer = function(name) {
      if (name %in% private$interviewers) {
        warning(paste(name, "is already registered. No changes made"))
      } else {
        private$interviewers <- c(private$interviewers, name)
      }
    },
    # Register a new candidate by adding it to the private$candidate vector
    # 
    # @param name A (unique) name for the candidate
    # TODO: Make names unique in the implementation, rather than 
    # requiring it from the user 
    registerCandidate = function(name) {
      if (name %in% private$candidates) {
        warning(paste(name, "is already registered. No changes made"))
      } else {
        private$candidates <- c(private$candidates, name)
      }
    },
    # One of two main functions, `setSlot`, is available for both candidates and 
    # interviewers, to set their availability.
    # 
    # @param role Must be `candidate` or `interviewer`
    # @param name The (unique) name for the candidate or interviewer
    # @param days A list of the days that the person is available,
    #   in which each element is a string in the format "yyyy-mm-dd"
    # @param hourRange A list of the same length as `days` that specifies
    #    the hour range (for that corresponding day) that the person is 
    #    available. Each element must be either a number from 0 to 23, or 
    #    a vector of such numbers (like `9:11` or c(9, 11, 13)). Note that 
    #    each number corresponds to the beginning of an interview slot, so
    #    if someone is available on a day from 9 am to noon, the `hourRange`
    #    element for that day should be `9:11`, since 11 am is the latest
    #    start for a possible interview.
    # 
    # TODO: enforce `days` and `hourRange` formats. Fail with informative 
    #   message otherwise.
    setSlot = function(role, name, days, hourRange) {
      if (length(days) != length(hourRange)) {
        stop("Param `days` must be the same length as param `hourRange`")
      }
      if (!(role %in% c("candidate", "interviewer"))) {
        stop("Undefined role: ", role, ". Must be `candidate` or `interviewer`. Aborting")
      }
      if (!(name %in% c(private[[ paste0(role, "s") ]]))) {
        stop(name, " is not registered. Aborting")
      }
      # for each day and each hour that the person is available, call
      # `private$setUnitSlot()`, which adds a row for the person
      # and the datetime value in question to the appropriate table
      # (`private$interviewer_slots` or `private$candidate_slots`)
      for (ith_day in seq_len(length(days))) {
        for (hour in hourRange[[ith_day]]) {
          # offset hour by -1 since the "hour" slot in lubridate is also offset
          dateTime <- lubridate::ymd_h(paste(days[[ith_day]], hour - 1))
          private$setUnitSlot(role, name, dateTime)
        }
      }
    },
    # The second main function, `searchAvailability`, is available for anyone
    # who wishes to know when it's possible to interview a candidate.
    # 
    # @param name The (unique) name for the candidate
    # @param ... The names of the interviewers who need to be present at the
    #   interview. If no-one is specified, all interviewers are considered.
    searchAvailability = function(name, ...) {
      if (!(name %in% private$candidates)) stop("Candidate ", name, " is not registered. Aborting")
      interviewer_args <- list(...)
      
      # get all datetimes that the candidate with `name` with available
      candidateCalendar <- dplyr::filter(private$candidate_slots, candidate == name)
      if (length(interviewer_args) == 0) {
        
        # if no interviewer is specified, join the `candidateCalendar` table with
        # the `private$interviewer_slots` table, by `slot`. This will return a
        # table with 3 columns ("candidate", "slot" and "interviewer") and one
        # row for each time slot that the candidate and any of the interviewers 
        # have in common
        candidateCalendar <- dplyr::inner_join(candidateCalendar, private$interviewer_slots, by = "slot")
      } else {
        for (i in interviewer_args) {
          if (!(i %in% private$interviewers)) stop("Interviewer ", i, " is not registered. Aborting")
          
          # if 1 (or more) interviewers are specified, then for each of them, get the
          # all the datetimes they are available and join it with the `candidateCalendar`.
          # This will return a table with at least 3 columns as before, but this time,
          # each interviewer specified gets their own column (`interviewer.x`, 
          # `interviewer.y`, etc)
          interviewerSlot <- dplyr::filter(private$interviewer_slots, interviewer == i)
          candidateCalendar <- dplyr::inner_join(candidateCalendar, interviewerSlot, by = "slot")
        }
      }
      return(candidateCalendar)
    }
  ),
  private = list(
    interviewers = character(0),
    candidates = character(0),
    interviewer_slots = tibble::tibble(
      "interviewer" = character(0), 
      "slot" = as.POSIXct(character(0))
    ),
    candidate_slots = tibble::tibble(
      "candidate" = character(0), 
      "slot" = as.POSIXct(character(0))
    ),
    # This function adds a row to one of two tables: the `private$candidate_slots` table
    # or the `private$interviewer_slots` table (each corresponding to the 2 possible roles).
    # Both tables are structurally identical, with a column for the (unique) `name` of
    # the candidate/interviewer and another column for the date-time they are available,
    # in the format "yyyy-mm-dd h" (created programmatically by a call to 
    # `lubridate::ymd_h` in the `self$setSlot` function), where `h` refers to the o'clock
    # hour that an interview slot starts (i.e. `9` means that the interview would go from
    # 9 am to 10 am; `17` means that the interview would go from 5 pm to 6 pm)
    # 
    # TODO: check for duplicates, warn, don't add duplicate row, and continue
    setUnitSlot = function(role, name, dateTime) {
      # assume unique `name`s for all candidates and interviewers
      if (role == "candidate") {
        private$candidate_slots <- tibble::add_row(
          private$candidate_slots, candidate = name, slot = dateTime)
      } else if (role == "interviewer") {
        private$interviewer_slots <- tibble::add_row(
          private$interviewer_slots, interviewer = name, slot = dateTime)
      }
    }
  )
)
