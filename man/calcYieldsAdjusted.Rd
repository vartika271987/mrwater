% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calcYieldsAdjusted.R
\name{calcYieldsAdjusted}
\alias{calcYieldsAdjusted}
\title{calcYieldsAdjusted}
\usage{
calcYieldsAdjusted(
  lpjml,
  climatetype,
  iniyear,
  selectyears,
  yieldcalib,
  multicropping
)
}
\arguments{
\item{lpjml}{LPJmL version used}

\item{climatetype}{Switch between different climate scenarios or
historical baseline "GSWP3-W5E5:historical" for yields}

\item{iniyear}{Year to be used for cropland of yield calibration}

\item{selectyears}{Years to be returned by the function}

\item{yieldcalib}{If TRUE: LPJmL yields calibrated to FAO country yield in iniyear
If FALSE: uncalibrated LPJmL yields are used}

\item{multicropping}{Multicropping activated (TRUE) or not (FALSE)}
}
\value{
magpie object in cellular resolution
}
\description{
This function returns irrigated and rainfed yields for MAgPIE crops.
}
\examples{
\dontrun{
calcOutput("YieldsAdjusted", aggregate = FALSE)
}

}
\author{
Felicitas Beier
}
