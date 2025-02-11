% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calcYieldgainArea.R
\name{calcYieldgainArea}
\alias{calcYieldgainArea}
\title{calcYieldgainArea}
\usage{
calcYieldgainArea(
  rangeGT,
  lpjml,
  selectyears,
  iniyear,
  climatetype,
  efrMethod,
  yieldcalib,
  thresholdtype,
  landScen,
  cropmix,
  multicropping
)
}
\arguments{
\item{rangeGT}{Range of gainthreshold for calculation of potentially
irrigated areas}

\item{lpjml}{LPJmL version required for respective inputs: natveg or crop}

\item{selectyears}{Years for which irrigatable area is calculated}

\item{iniyear}{Initialization year for cropland area}

\item{climatetype}{Switch between different climate scenarios or historical baseline "GSWP3-W5E5:historical"}

\item{efrMethod}{EFR method used including selected strictness of EFRs (e.g. Smakhtin:good, VMF:fair)}

\item{yieldcalib}{If TRUE: LPJmL yields calibrated to FAO country yield in iniyear
If FALSE: uncalibrated LPJmL yields are used}

\item{thresholdtype}{TRUE: monetary yield gain (USD05/ha), FALSE: yield gain in tDM/ha}

\item{landScen}{Land availability scenario consisting of two parts separated by ":":
1. available land scenario (currCropland, currIrrig, potCropland)
2. protection scenario (WDPA, BH, FF, CPD, LW, HalfEarth, BH_FF, NA).
For case of no land protection select "NA"
or do not specify second part of the argument}

\item{cropmix}{Selected cropmix (options:
"hist_irrig" for historical cropmix on currently irrigated area,
"hist_total" for historical cropmix on total cropland,
or selection of proxycrops)}

\item{multicropping}{Multicropping activated (TRUE) or not (FALSE)}
}
\value{
magpie object in cellular resolution
}
\description{
reports potentially irrigated area depending on gainthreshold
             and land constraint only
}
\examples{
\dontrun{
calcYieldgainArea(rangeGT = seq(0, 10000, by = 100), scenario = "ssp2")
}

}
\author{
Felicitas Beier
}
