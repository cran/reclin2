#' Generate pairs with a minimal similarity
#'
#' Generates all combinations of records from \code{x} and \code{y} where the 
#' blocking variables are equal. 
#'
#' @param x first \code{data.frame}
#' @param y second \code{data.frame}. Ignored when \code{deduplication = TRUE}.
#' @param on the variables defining on which the pairs of records from \code{x} 
#'   and \code{y} are compared.
#' @param minsim minimal similarity score.
#' @param on_blocking variables for which the pairs have to match.
#' @param comparators named list of functions with which the variables are compared. 
#'   This function should accept two vectors. Function should either return a vector
#'   or a \code{data.table} with multiple columns.
#' @param default_comparator variables for which no comparison function is defined using
#'   \code{comparators} is compares with the function \code{default_comparator}.
#' @param keep_simsum add a variable \code{minsim} to the result with the similarity 
#'   score of the pair.
#' @param deduplication generate pairs from only \code{x}. Ignore \code{y}. This 
#'   is usefull for deduplication of \code{x}.
#' @param add_xy add \code{x} and \code{y} as attributes to the returned 
#'   pairs. This makes calling some subsequent operations that need \code{x} and 
#'   \code{y} (such as \code{\link{compare_pairs}} easier.
#'
#' @details
#' Generating (all) pairs of the records of two data sets, is usually the first 
#' step when linking the two data sets. However, this often results in a too 
#' large number of records. \code{pair_minsim} will only keep pairs with a 
#' similarity score equal or larger than \code{minsim}. The similarity score is
#' calculated by summing the results of the comparators for all variables 
#' of \code{on}.
#'
#' Missing values in the variables on which the pairs are compared count as a 
#' similarity of 0. 
#'  
#' @return 
#' A \code{\link{data.table}} with two columns, 
#' \code{.x} and \code{.y}, is returned. Columns \code{.x} and \code{.y} are 
#' row numbers from \code{data.frame}s \code{.x} and \code{.y} respectively. 
#'
#' @seealso
#' \code{\link{pair}} and \code{\link{pair_blocking}} are other methods
#' to generate pairs. 
#'
#' @examples
#' data("linkexample1", "linkexample2")
#' pairs <- pair_minsim(linkexample1, linkexample2, 
#'    on = c("postcode", "address"), minsim = 1)
#' # Either address or postcode has to match to keep a pair
#' 
#' data("linkexample1", "linkexample2")
#' pairs <- pair_minsim(linkexample1, linkexample2, on_blocking = "postcode",
#'    on = c("lastname", "firstname", "address"), minsim = 2)
#' # Postcode has to match; from lastname, firstname, address there have to match
#' # two or more (e.g. one mismatch is allowed).
#'
#' @import data.table
#' @export
pair_minsim <- function(x, y, on, minsim = 0.0, on_blocking = character(0),
    comparators = list(default_comparator), default_comparator = cmp_identical(), 
    keep_simsum = TRUE, deduplication = FALSE, add_xy = TRUE) {
  x <- as.data.table(x)
  if (deduplication && !missing(y)) warning("y provided will be ignored.")
  y <- if (deduplication) x else as.data.table(y)
  comparators <- extend_to(on, comparators, default = default_comparator) 
  ny <- nrow(y)
  nx <- nrow(x)
  max_size <- 1E7
  nchunks <- max(ceiling(nx * (ny/ max_size)), 1L)
  group <- floor(seq_len(nrow(x))/(nrow(x)+1)*nchunks)
  idx <- split(seq_len(nrow(x)), group)
  pairs <- lapply(idx, function(idx, x, y, on, on_blocking, minsim, comparators, deduplication) {
    if (length(on_blocking)) {
      pairs <- pair_blocking(x, y, on = on_blocking, add_xy = FALSE)
      pairs[, .x := idx[.x]]
    } else {
      pairs <- CJ(.x = idx, .y = seq_len(nrow(y)))
    }
    if (deduplication) pairs <- pairs[.y > .x]
    pairs[, simsum := rep(0, nrow(pairs))]
    for (var in on) {
      cmp_fun <- comparators[[var]]
      cmp <- cmp_fun(x[pairs$.x, ..var][[1]], y[pairs$.y, ..var][[1]])
      cmp[is.na(cmp)] <- 0
      pairs[, simsum := simsum + ..cmp]
    }
    pairs[simsum >= minsim]
  }, x = x, y = y, on = on, on_blocking = on_blocking, minsim = minsim, 
    comparators = comparators, deduplication = deduplication)
  pairs <- rbindlist(pairs)
  if (!keep_simsum) pairs[, simsum := NULL]
  setattr(pairs, "class", c("pairs", class(pairs)))
  if (deduplication) setattr(pairs, "deduplication", TRUE)
  if (add_xy) {
    setattr(pairs, "x", x)
    setattr(pairs, "y", y)
  }
  pairs
}

