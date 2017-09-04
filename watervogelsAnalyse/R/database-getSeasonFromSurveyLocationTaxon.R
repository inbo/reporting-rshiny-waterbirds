#' extract season(s) available for a survey, location and taxon
#' @param surveyId survey identifier
#' @param locationId location identifier
#' @param taxon taxon name
#' @param personKey integer with person key
#' @param ch ch database connection, created with 
#' the \code{odbcConnect} function of the \code{RODBC} package
#' @return vector with available seasons
#' @author Laure Cougnaud
#' @export
getSeasonFromSurveyLocationTaxon <- function(surveyId, locationId, taxon, personKey, ch){
	
	# taxonName -> taxonId
	taxonId <- extractYFromXTable(
		x = list('commonname' = taxon), 
		y = "TaxonWVKey", table = "DimTaxonWV",
		ch = ch)

	# surveyId + locationId + taxonId -> seasonsId
	seasonsId <- extractYFromXTable(
		x = list(
			'SurveyKey' = surveyId,
			'LocationWVKey' = locationId,
			'TaxonWVKey' = taxonId,
			'PersonKey' = personKey
		), 
		y = "SeasonKey", table = "FactTaxonOccurrence",
		ch = ch
	)
	
	# seasonsIds -> seasonNames
	seasonNames <- extractYFromXTable(
		x = list('SeasonKey' = seasonsId),
		y = "SeasonName", table = "DimSeason",
		ch = ch
	)
	
	res <- list(seasonNames = seasonNames, taxonId = taxonId)
	
	return(res)
	
}