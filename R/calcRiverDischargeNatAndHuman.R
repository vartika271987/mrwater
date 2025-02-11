#' @title       calcRiverDischargeNatAndHuman
#' @description This function calculates cellular discharge after considering known human consumption (non-agricultural and committed agricultural) along the river calculated and accounted for in previous river routings (see calcRiverNaturalFlows and calcRiverHumanUses)
#'
#' @param lpjml         LPJmL version required for respective inputs: natveg or crop
#' @param selectyears   Years to be returned (Note: does not affect years of harmonization or smoothing)
#' @param climatetype   Switch between different climate scenarios or historical baseline "GSWP3-W5E5:historical"
#' @param iniyear       Initialization year of irrigation system
#' @param efrMethod     EFR method used including selected strictness of EFRs (e.g. Smakhtin:good, VMF:fair)
#' @param com_ag        if TRUE: the currently already irrigated areas in initialization year are reserved for irrigation,
#'                      if FALSE: no irrigation areas reserved (irrigation potential)
#' @param multicropping Multicropping activated (TRUE) or not (FALSE)
#'
#' @importFrom madrat calcOutput
#' @importFrom magclass collapseNames getNames new.magpie getCells setCells mbind setYears dimSums
#' @importFrom stringr str_split
#'
#' @return magpie object in cellular resolution
#' @author Felicitas Beier, Jens Heinke
#'
#' @examples
#' \dontrun{
#' calcOutput("RiverDischargeNatAndHuman", aggregate = FALSE)
#' }
#'
calcRiverDischargeNatAndHuman <- function(lpjml, selectyears, iniyear, climatetype, efrMethod, com_ag, multicropping) {

  #######################################
  ###### Read in Required Inputs ########
  #######################################
  # River structure
  rs <- readRDS(system.file("extdata/riverstructure_stn_coord.rds", package = "mrwater"))

  # Non-agricultural human consumption that can be fulfilled by available water determined in previous river routings
  nAgWC <- collapseNames(calcOutput("RiverHumanUses", humanuse = "non_agriculture", aggregate = FALSE,
                                    lpjml = lpjml, climatetype = climatetype,
                                    efrMethod = efrMethod, multicropping = multicropping,
                                    iniyear = iniyear, selectyears = selectyears)[, , "currHuman_wc"])

  if (com_ag) {

    # Committed agricultural human consumption that can be fulfilled by available water determined in previous river routings
    cAgWC <- collapseNames(calcOutput("RiverHumanUses", humanuse = "committed_agriculture", aggregate = FALSE,
                                      lpjml = lpjml, climatetype = climatetype,
                                      efrMethod = efrMethod, multicropping = multicropping,
                                      iniyear = iniyear, selectyears = selectyears)[, , "currHuman_wc"])
  } else {

    # No committed agricultural human consumption considered
    cAgWC <- new.magpie(cells_and_regions = getCells(nAgWC),
                        years = getYears(nAgWC),
                        names = getNames(nAgWC),
                        fill = 0)
  }

  # Yearly Runoff (on land and water)
  yearlyRunoff <- collapseNames(calcOutput("YearlyRunoff", selectyears = selectyears,
                                           lpjml = lpjml, climatetype = climatetype,
                                           aggregate = FALSE))
  # Lake evaporation as calculated by natural flow river routing
  lakeEvap     <- collapseNames(calcOutput("RiverNaturalFlows", selectyears = selectyears,
                                           lpjml = lpjml, climatetype = climatetype,
                                           aggregate = FALSE)[, , "lake_evap_nat"])

  ## Transform object dimensions
  .transformObject <- function(x) {
    # empty magpie object structure
    object0 <- new.magpie(cells_and_regions = getCells(yearlyRunoff),
                          years = getYears(yearlyRunoff),
                          names = getNames(nAgWC),
                          fill = 0,
                          sets = c("x.y.iso", "year", "data"))
    # bring object x to dimension of object0
    out     <- x + object0
    return(out)
  }

  #######################################
  ###### Transform object size   ########
  #######################################
  lakeEvap     <- as.array(.transformObject(lakeEvap))
  cAgWC        <- as.array(.transformObject(cAgWC))
  nAgWC        <- as.array(.transformObject(nAgWC))
  yearlyRunoff <- as.array(.transformObject(yearlyRunoff))

  # helper variables for river routing
  inflow       <- as.array(.transformObject(0))
  avlWat       <- as.array(.transformObject(0))

  # output variable that will be filled during river routing
  discharge    <- as.array(.transformObject(0))

  ###########################################
  ###### River Discharge Calculation ########
  ###########################################

  for (o in 1:max(rs$calcorder)) {

    # Note: the calcorder ensures that the upstreamcells are calculated first
    cells <- which(rs$calcorder == o)

    for (c in cells) {

      # available water
      avlWat[c, , ] <- inflow[c, , , drop = F] + yearlyRunoff[c, , , drop = F] - lakeEvap[c, , , drop = F]

      # discharge
      discharge[c, , ] <- avlWat[c, , , drop = F] - nAgWC[c, , , drop = F] - cAgWC[c, , , drop = F]

      # inflow into nextcell
      if (rs$nextcell[c] > 0) {
        inflow[rs$nextcell[c], , ] <- inflow[rs$nextcell[c], , , drop = F] + discharge[c, , , drop = F]
      }
    }
  }

  out <- as.magpie(discharge, spatial = 1)

  # Check for NAs
  if (any(is.na(out))) {
    stop("produced NA discharge")
  }

  return(list(x            = out,
              weight       = NULL,
              unit         = "mio. m^3",
              description  = "Cellular discharge after accounting for environmental flow requirements and known human uses along the river",
              isocountries = FALSE))
}
