#' extract season(s) available for a survey, location and taxon
#' @param surveyId survey identifier
#' @param locationId location identifier
#' @param taxon taxon name
#' @param ch ch database connection, created with 
#' the \code{odbcConnect} function of the \code{RODBC} package
#' @return vector with available seasons
#' @author Laure Cougnaud
#' @export
getSeasonFromSurveyLocationTaxon <- function(surveyId, locationId, taxon, ch){
	
	# taxonName -> taxonId
	taxonId <- extractYFromYTable(
		x = list('commonname' = taxon), 
		y = "TaxonWVKey", table = "DimTaxonWV",
		ch = ch)

	# surveyId + locationId + taxonId -> seasonsId
	seasonsId <- extractYFromYTable(
		x = list(
			'SurveyKey' = surveyId,
			'LocationWVKey' = locationId,
			'TaxonWVKey' = taxonId
		), 
		y = "SeasonKey", table = "FactTaxonOccurrence",
		ch = ch
	)
	
	# seasonsIds -> seasonNames
	seasonNames <- extractYFromYTable(
		x = list('SeasonKey' = seasonsId),
		y = "SeasonName", table = "DimSeason",
		ch = ch
	)
	
	res <- list(seasonNames = seasonNames, taxonId = taxonId)
	
	return(res)
	
}