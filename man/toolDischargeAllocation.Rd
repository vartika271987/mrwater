% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/toolDischargeAllocation.R
\name{toolDischargeAllocation}
\alias{toolDischargeAllocation}
\title{toolDischargeAllocation}
\usage{
toolDischargeAllocation(y, rs, l_inout, l_in, allocationrule, glocellrank)
}
\arguments{
\item{y}{Current year of loop}

\item{rs}{River structure (list of river structure details and
cell numbers including ordered cell number)}

\item{l_inout}{List of inputs that are at the same time outputs:
minWatReserved Minimum (water requirement reserved per grid cell (as magpie object of correct dimension));
discharge (Discharge to be allocated (as magpie object of correct dimension));
fracFullirrig (fraction of fullirrigation requirements that can be fulfilled)}

\item{l_in}{List of inputs:
irrigGain (yield gain potential through irrigation of proxy crops: magpie object with cellular and year dimension (as magpie object of correct dimension));
reqWatFullirrigWW (required withdrawal for full irrigation in specific cell (as magpie object of correct dimension));
reqWatFullirrigWC (required consumption for full irrigation in specific cell (as magpie object of correct dimension));
gainthreshold (Minimum yield gain in USD/ha (as scalar value)); avlWatWW; avlWatWC}

\item{allocationrule}{Rule to be applied for river basin discharge allocation
across cells of river basin ("optimization", "upstreamfirst")}

\item{glocellrank}{Cell ranking for different years (array).
Note: only applicable when allocationrule "optimization" chosen}
}
\value{
magpie object in cellular resolution
}
\description{
This tool function executes the Allocation Algorithm in
             cell order of selected allocation rule
}
\author{
Felicitas Beier, Jens Heinke, Jan Philipp Dietrich
}
