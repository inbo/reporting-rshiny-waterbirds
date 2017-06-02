#' extract data of interest from a certain survey, location, taxon and survey season
#' @param surveyId survey identifier(s)
#' @param locationId location identifier(s)
#' @param taxonId taxon identifier(s)
#' @param surveyseason survey season name(s)
#' @param ch database connection, created with 
#' the \code{odbcConnect} function of the \code{RODBC} package
#' @return data.frame with data of interest
#' @author Laure Cougnaud
#' @export
getData <- function(surveyId, locationId, taxonId, surveyseason, ch){
	
	# surveyseasonName -> surveySeasonId
	surveySeasonId <- extractYFromYTable(
		x = list('SeasonName' = surveyseason), 
		y = "SeasonKey", table = "DimSeason",
		ch = ch)
	
	# surveyId + locationId + taxonId + seasonId -> 
	# TO TEST:
#	taxons <- extractYFromYTable(
#		x = list(
#			'SurveyKey' = surveyId,
#			'LocationWVKey' = locationId,
#			'TaxonWVKey' = taxonId,
#			'SeasonKey' = surveySeasonId
#		), 
#		y = c('SurveyKey', 'LocationWVKey', 'TaxonWVKey', 'SeasonKey',
#			'SampleKey', 'SampleDate', 'TaxonCount'), 
#		table = "FactTaxonOccurence",
#		ch = ch)
	
#	return(taxons)
	
}