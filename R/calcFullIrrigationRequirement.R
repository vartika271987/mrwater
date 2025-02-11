#' @title       calcFullIrrigationRequirement
#' @description This function calculates the water requirements for full
#'              irrigation per cell per crop given potentially available land
#'
#' @param lpjml            LPJmL version used
#' @param selectyears      Years to be returned
#' @param climatetype      Climate model or historical baseline "GSWP3-W5E5:historical"
#' @param comagyear        if !NULL: already irrigated area is subtracted;
#'                         if NULL: total potential land area is used;
#'                         year specified here is the year of the initialization
#'                         used for cropland area initialization in calcIrrigatedArea
#' @param iniyear          Croparea initialization year
#' @param irrigationsystem Irrigation system used: system share as in initialization year,
#'                         or drip, surface, sprinkler for full irrigation by selected system
#' @param landScen         Land availability scenario consisting of two parts separated by ":":
#'                         1. available land scenario (currCropland, currIrrig, potCropland)
#'                         2. protection scenario (WDPA, BH, FF, CPD, LW, HalfEarth, BH_FF, NA).
#'                         For case of no land protection select "NA"
#'                         or do not specify second part of the argument
#' @param cropmix          Selected cropmix (options:
#'                         "hist_irrig" for historical cropmix on currently irrigated area,
#'                         "hist_total" for historical cropmix on total cropland,
#'                         or selection of proxycrops)
#' @param multicropping    Multicropping activated (TRUE) or not (FALSE)
#'
#' @return magpie object in cellular resolution
#' @author Felicitas Beier
#'
#' @examples
#' \dontrun{
#' calcOutput("FullIrrigationRequirement", aggregate = FALSE)
#' }
#'
#' @importFrom madrat calcOutput toolGetMapping
#' @importFrom magclass collapseNames getCells getSets getYears getNames new.magpie dimSums
#' @importFrom mrcommons toolCell2isoCell toolGetMappingCoord2Country

calcFullIrrigationRequirement <- function(lpjml, climatetype, selectyears, comagyear, iniyear,
                                          irrigationsystem, landScen, cropmix, multicropping) {

  # read in irrigation water requirements for each irrigation system and season
  # [in m^3 per hectare per year] (smoothed & harmonized)
  irrigWat <- calcOutput("IrrigWatRequirements", selectyears = selectyears,
                         lpjml = lpjml, climatetype = climatetype,
                         multicropping = multicropping, aggregate = FALSE)
  # pasture is not irrigated in MAgPIE
  irrigWat <- irrigWat[, , "pasture", invert = TRUE]

  # land area that can potentially be used for irrigated agriculture given assumptions set in the arguments [in Mha]
  land <- calcOutput("AreaPotIrrig", selectyears = selectyears, iniyear = iniyear,
                     comagyear = comagyear, landScen = landScen, aggregate = FALSE)

  # share of corp area by crop type
  cropareaShr <- calcOutput("CropAreaShare", iniyear = iniyear, cropmix = cropmix,
                            aggregate = FALSE)

  # land area per crop
  land <- land * cropareaShr

  # water requirements for full irrigation in cell per crop accounting for cropshare (in mio. m^3)
  # Note on unit transformation:
  # land (mio ha -> ha): multiply with 1e6,
  # irrigation water requirements (m^3 per ha -> mio. m^3 per ha): divide by 1e6
  # --> cancels out -> water requirements for full irrigation (mio. m^3)
  irrigWat <- irrigWat[, , getNames(cropareaShr)] * land

  # sum over crops
  irrigWat <- dimSums(irrigWat, dim = "crop")

  # calculate irrigation water requirements per crop [in mio. m^3 per year] given irrigation system share in use
  if (irrigationsystem == "initialization") {

    # read in irrigation system area initialization [share of AEI by system] and expand to all years
    tmp               <- calcOutput("IrrigationSystem", datasource = "Jaegermeyr",
                                    aggregate = FALSE)
    irrigSystem       <- new.magpie(cells_and_regions = getCells(irrigWat),
                                    years = getYears(irrigWat),
                                    names = getNames(tmp),
                                    sets = c("x.y.iso", "year", "system"))
    irrigSystem[, , ] <- tmp

    # every crop irrigated by same share of initialization irrigation system
    irrigWat <- dimSums(irrigSystem * irrigWat, dim = "system")

  } else {

    # whole area irrigated by one system as selected in argument "irrigationsystem"
    irrigWat <- collapseNames(irrigWat[, , irrigationsystem])

  }

  # Sum over seasons
  irrigWat <- dimSums(irrigWat, dim = "season")

  # Checks
  if (any(is.na(irrigWat))) {
    stop("produced NA full irrigation requirements")
  }

  return(list(x            = irrigWat,
              weight       = NULL,
              unit         = "mio. m^3",
              description  = "Full irrigation requirements per cell for selected cropmix
                              and irrigation system",
              isocountries = FALSE))
}
