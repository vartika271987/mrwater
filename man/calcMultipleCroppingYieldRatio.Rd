% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calcMultipleCroppingYieldRatio.R
\name{calcMultipleCroppingYieldRatio}
\alias{calcMultipleCroppingYieldRatio}
\title{calcMultipleCroppingYieldRatio}
\usage{
calcMultipleCroppingYieldRatio(selectyears, lpjml, climatetype)
}
\arguments{
\item{selectyears}{Years to be returned}

\item{lpjml}{LPJmL version required for grassland input}

\item{climatetype}{Climate model or historical baseline "GSWP3-W5E5:historical"}
}
\value{
magpie object in cellular resolution
}
\description{
This function returns the ratio of off-season to main-season yields
}
\examples{
\dontrun{
calcOutput("MultipleCroppingYieldRatio", aggregate = FALSE)
}

}
\author{
Felicitas Beier
}
