
#' @rdname select_n_to_m
#' @export
select_greedy <- function(pairs, variable, score, threshold, preselect = NULL, 
    id_x = NULL, id_y = NULL, ...) {
  UseMethod("select_greedy")
}


#' @rdname select_n_to_m
#' @export
select_greedy.pairs <- function(pairs, variable, score, threshold, preselect = NULL, 
    id_x = NULL, id_y = NULL, x = attr(pairs, "x"), y = attr(pairs, "y"), 
    inplace = FALSE, include_ties = FALSE, n = 1L, m = 1L, ...) {
  prep <- select_preprocess(pairs, score = score, threshold = threshold, 
    preselect = preselect, id_x = id_x, id_y = id_y, x = x, y = y)
  sel <- greedy(prep$.x, prep$.y, prep$score, include_ties = include_ties, 
    n = n, m = m)
  if (inplace) {
    pairs[, (variable) := FALSE]
    pairs[prep$index[sel], (variable) := TRUE]
    invisible(pairs)
  } else {
    pairs[[variable]] <- if (nrow(pairs) > 0) FALSE else logical(0)
    pairs[[variable]][prep$index[sel]] <- if (nrow(pairs) > 0) TRUE else logical(0)
    pairs
  }
}

