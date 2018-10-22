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
    registerInterviewer = function(name) {
      if (name %in% private$interviewers) {
        warning(paste(name, "is already registered. No changes made"))
      } else {
        private$interviewer <- c(private$interviewer, name)
      }
    },
    registerCandidate = function(name) {
      if (name %in% private$candidates) {
        warning(paste(name, "is already registered. No changes made"))
      } else {
        private$candidate <- c(private$candidate, name)
      }
    },
    setUnitSlot = function(role, name, dateTime) {
      # assume unique `name`s for all candidates and interviewers
      if (role == "candidate") {
        private$candidate_slot <- tibble::add_row(
          private$candidate_slot, candidate = name, slot = dateTime)
      } else if (role == "interviewer") {
        private$interviewer_slot <- tibble::add_row(
          private$interviewer_slot, interviewer = name, slot = dateTime)
      }
    },
    setSlot = function(role, name, days, hourRange) {
      if (length(days) != length(hourRange)) {
        stop("Param `days` must be the same length as param `hourRange`")
      }
      if (!(role %in% c("candidate", "interviewer"))) {
        stop("Undefined role: ", role, ". Must be `candidate` or `interviewer`. Aborting")
      }
      if (!(name %in% c(private[[role]]))) {
        stop(name, " is not registered. Aborting")
      }
      for (ith_day in seq_len(length(days))) {
        for (hour in hourRange[[ith_day]]) {
          # offset hour by -1 since the "hour" slot in lubridate is also offset
          dateTime <- lubridate::ymd_h(paste(days[[ith_day]], hour - 1))
          self$setUnitSlot(role, name, dateTime)
        }
      }
    },
    searchAvailability = function(name, ...) {
      if (!(name %in% private$candidate)) stop("Candidate ", name, " is not registered. Aborting")
      interviewers <- list(...)
      candidateCalendar <- dplyr::filter(private$candidate_slot, candidate == name)
      if (length(interviewers) == 0) {
        candidateCalendar <- dplyr::inner_join(candidateCalendar, private$interviewer_slot, by = "slot")
      } else {
        for (i in interviewers) {
          if (!(i %in% private$interviewer)) stop("Interviewer ", i, " is not registered. Aborting") 
          subsetted_interviewer_slots <- dplyr::filter(private$interviewer_slot, interviewer == i)
          candidateCalendar <- dplyr::inner_join(candidateCalendar, subsetted_interviewer_slots,
            by = "slot")
        }
      }
      return(candidateCalendar)
    }
  ),
  private = list(
    interviewer = character(0),
    candidate = character(0),
    interviewer_slot = tibble::tibble(
      "interviewer" = character(0), 
      "slot" = as.POSIXct(character(0))
    ),
    candidate_slot = tibble::tibble(
      "candidate" = character(0), 
      "slot" = as.POSIXct(character(0)))
  )
)
