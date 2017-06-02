#' extract location(s) name available for a certain region and from a set of location identifiers.
#' 
#' Location identifiers should be provided to restrict to locations
#' sampled in a certain survey.
#' @param regionName name of the survey, e.g. 'Antwerpen'
#' @param locationId location identifier
#' @param ch database connection, created with 
#' the \code{odbcConnect} function of the \code{RODBC} package
#' @return list with two elements
#' \itemize{
#' \item{'surveyId'}{survey identifier}
#' \item{'regioWVNaam'}{region name}
#' }vector of regions available for specified surveys
#' @author Laure Cougnaud
#' @export
getLocationFromRegionLocationId <- function(regionName, locationId, ch){
	
	# RegioWVNaam -> LocationWVNaam
	locationName <- extractYFromYTable(
		x = list('RegioWVNaam' = regionName, 'LocationWVKey' = locationId),
		y = "LocationWVNaam", table = "DimLocationWV",
		ch = ch)
	
	return(locationName)
	
}