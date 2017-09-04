#' extract taxon group(s) available for a certain survey location and survey
#' @param locationName name of the location, e.g. 'Galgenschoor (Schelde Lillo-Fort - Containerkaai) (RO)'
#' @param surveyId identifier of the survey, e.g. 6
#' @param personKey integer with person key
#' @param ch database connection, created with 
#' the \code{odbcConnect} function of the \code{RODBC} package
#' @return list with two elements
#' \itemize{
#' \item{'locationId': }{location identifier}
#' \item{'taxonId': }{identifier of available taxon(s)}
#' \item{'taxonGroup': }{name of available taxon group(s) for the survey}
#' }
#' @author Laure Cougnaud
#' @export
getTaxonGroupFromLocationSurvey <- function(locationName, surveyId, personKey, ch){
	
	# locationName -> locationId
	locationId <- extractYFromXTable(
		x = list('LocationWVNaam' = locationName), 
		y = "LocationWVKey", table = "DimLocationWV",
		ch = ch)
	
	# locationId + surveyId -> taxonId
	taxonId <- extractYFromXTable(
		x = list('LocationWVKey' = locationId, 'SurveyKey' = surveyId, 'personKey' = personKey), 
		y = "TaxonWVKey", table = "FactTaxonOccurrence",
		ch = ch, distinct = TRUE)

	# taxonId -> taxon group name
	taxonGroup <- extractYFromXTable(
		x = list('TaxonWVKey' = taxonId), 
		y = "TaxonGroupDescription", table = "DimTaxonWV",
		ch = ch, distinct = TRUE)

	# Note: if exported data, naam was concatenated with RegioWVCode,
	# is it required?

	res <- list(
		locationId = locationId,
		taxonId = taxonId, 
		taxonGroup = taxonGroup
	)
	
	return(res)
	
}