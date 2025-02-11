#' @title       calcYieldgainPotential
#' @description reports yield gain potential for irrigatable area under different
#'              scenarios
#'
#' @param scenario          Non-agricultural water use and EFP scenario, separated
#'                          by "." (e.g. "on.ssp2")
#' @param lpjml             LPJmL version used
#' @param selectyears       Years for which yield gain potential is calculated
#' @param iniyear           Initialization year
#' @param climatetype       Switch between different climate scenarios or
#'                          historical baseline "GSWP3-W5E5:historical"
#' @param efrMethod         EFR method used including selected strictness of EFRs
#'                          (e.g. Smakhtin:good, VMF:fair)
#' @param accessibilityrule Strictness of accessibility restriction:
#'                          discharge that is exceeded x percent of the time on average throughout a year (Qx).
#'                          (e.g. Q75: 0.25, Q50: 0.5)
#' @param rankmethod        Rank and optimization method consisting of
#'                          Unit according to which rank is calculated:
#'                          tDM (tons per dry matter),
#'                          USD_ha (USD per hectare) for area return, or
#'                          USD_m3 (USD per cubic meter) for volumetric return;
#'                          and boolean indicating fullpotential (TRUE) or reduced potential (FALSE)
#' @param yieldcalib        If TRUE: LPJmL yields calibrated to FAO country yield in iniyear
#'                          If FALSE: uncalibrated LPJmL yields are used
#' @param allocationrule    Rule to be applied for river basin discharge allocation
#'                          across cells of river basin ("optimization", "upstreamfirst", "equality")
#' @param gainthreshold     Threshold of yield improvement potential required
#'                          (same unit as thresholdtype)
#' @param irrigationsystem  Irrigation system used
#'                          ("surface", "sprinkler", "drip", "initialization")
#' @param landScen          Land availability scenario consisting of two parts separated by ":":
#'                          1. available land scenario (currCropland, currIrrig, potCropland)
#'                          2. protection scenario (WDPA, BH, FF, CPD, LW, HalfEarth, BH_FF, NA).
#'                          For case of no land protection select "NA"
#'                          or do not specify second part of the argument
#' @param cropmix           Selected cropmix (options:
#'                          "hist_irrig" for historical cropmix on currently irrigated area,
#'                          "hist_total" for historical cropmix on total cropland,
#'                          or selection of proxycrops)
#' @param multicropping     Multicropping activated (TRUE) or not (FALSE)
#' @param unlimited         TRUE: no water limitation to potentially irrigated area
#'                          FALSE: irrigatable area limited by water availability
#'
#' @return magpie object in cellular resolution
#' @author Felicitas Beier
#'
#' @examples
#' \dontrun{
#' calcOutput("YieldgainPotential", aggregate = FALSE)
#' }
#'
#' @importFrom madrat calcOutput
#' @importFrom magclass collapseNames getCells getNames setYears dimSums new.magpie
#' @importFrom mrcommons toolGetMappingCoord2Country
#'
#' @export

calcYieldgainPotential <- function(scenario, selectyears, iniyear, lpjml, climatetype,
                                   efrMethod, yieldcalib, irrigationsystem,
                                   accessibilityrule, rankmethod,
                                   gainthreshold, allocationrule,
                                   landScen, cropmix, multicropping, unlimited) {

  thresholdtype <- strsplit(rankmethod, ":")[[1]][1]

  # Cellular yield improvement potential for all crops (in USD/ha)
  yieldGain <- calcOutput("IrrigYieldImprovementPotential", selectyears = selectyears,
                          lpjml = lpjml, climatetype = climatetype, cropmix = NULL,
                          unit = thresholdtype, iniyear = iniyear, yieldcalib = yieldcalib,
                          multicropping = multicropping, aggregate = FALSE)

  # Total area that can potentially be irrigated (in Mha)
  if (unlimited) {

    # Area that can potentially be irrigated without water limitation
    area <- calcOutput("AreaPotIrrig", selectyears = selectyears, iniyear = iniyear,
                        landScen = landScen, comagyear = NULL,
                        aggregate = FALSE)
    d    <- "Potentially Irrigated Area only considering land constraint"

  } else {

    # Area that can potentially be irrigated given land and water constraints
    area <- collapseNames(calcOutput("IrrigatableArea", gainthreshold = gainthreshold,
                                     selectyears = selectyears, iniyear = iniyear,
                                     climatetype = climatetype, lpjml = lpjml,
                                     accessibilityrule = accessibilityrule, efrMethod = efrMethod,
                                     rankmethod = rankmethod, yieldcalib = yieldcalib, allocationrule = allocationrule,
                                     thresholdtype = thresholdtype, irrigationsystem = irrigationsystem,
                                     landScen = landScen, cropmix = cropmix, potential_wat = TRUE,
                                     com_ag = FALSE, multicropping = multicropping,
                                     aggregate = FALSE)[, , "irrigatable"][, , scenario])
    d    <- "Potentially Irrigated Area considering land and water constraints"

  }

  # share of crop area by crop type
  cropareaShr <- calcOutput("CropAreaShare", iniyear = iniyear, cropmix = cropmix,
                            aggregate = FALSE)

  # Potential area by croptype (in Mha)
  area <- cropareaShr * area

  # Potential yield gain per cell (in mio. USD)
  x <- dimSums(yieldGain * area, dim = "crop")
  u <- "mio. USD"

  out <- collapseNames(x)

  return(list(x            = out,
              weight       = NULL,
              unit         = u,
              description  = d,
              isocountries = FALSE))
}
