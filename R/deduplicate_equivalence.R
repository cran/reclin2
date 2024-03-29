
#' Deduplication using equivalence groups
#' 
#' @param pairs a \code{pairs} object, such as generated by 
#'   \code{\link{pair_blocking}}
#' @param variable name of the variable to create in \code{x} that will contain the
#'   group labels.
#' @param selection a logical variable with the same length as \code{pairs} has
#'   rows, or the name of such a variable in \code{pairs}. Pairs are only 
#'   selected when \code{select} is \code{TRUE}. When missing 
#'   it is assumed all pairs are selected.
#' @param x the first data set; when missing \code{attr(pairs, "x")} is used.
#' 
#' @return 
#' Returns \code{x} with a variable containing the group labels. Records with 
#' the same group label (should) correspond to the same entity. 
#' 
#' @export
deduplicate_equivalence <- function(pairs, variable, selection, 
    x = attr(pairs, "x")) {
  if (!missing(selection) && !is.null(selection)) {
    if (is.character(selection)) {
      stopifnot(selection %in% names(pairs))
      selection <- pairs[[selection]]
    }
  } else selection <- rep(TRUE, nrow(pairs))
  x <- copy(x)
  x[, (variable) := equivalence(.I, pairs$.x[selection], 
    pairs$.y[selection])]
  x[]
}

