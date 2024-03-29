% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/deduplicate_equivalence.R
\name{deduplicate_equivalence}
\alias{deduplicate_equivalence}
\title{Deduplication using equivalence groups}
\usage{
deduplicate_equivalence(pairs, variable, selection, x = attr(pairs, "x"))
}
\arguments{
\item{pairs}{a \code{pairs} object, such as generated by 
\code{\link{pair_blocking}}}

\item{variable}{name of the variable to create in \code{x} that will contain the
group labels.}

\item{selection}{a logical variable with the same length as \code{pairs} has
rows, or the name of such a variable in \code{pairs}. Pairs are only 
selected when \code{select} is \code{TRUE}. When missing 
it is assumed all pairs are selected.}

\item{x}{the first data set; when missing \code{attr(pairs, "x")} is used.}
}
\value{
Returns \code{x} with a variable containing the group labels. Records with 
the same group label (should) correspond to the same entity.
}
\description{
Deduplication using equivalence groups
}
