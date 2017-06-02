#' extract region(s) available for a certain survey
#' @param surveyName name of the survey, e.g. 'Slaapplaatstellingen Aalscholvers'
#' @param ch database connection, created with 
#' the \code{odbcConnect} function of the \code{RODBC} package
#' @return list with two elements
#' \itemize{
#' \item{'surveyId': }{survey identifier}
#' \item{'location': }{identifiers of available location(s for the survey}
#' \item{'regioName': }{name of available region(s) for the survey}
#' }vector of regions available for specified surveys
#' @author Laure Cougnaud
#' @export
getRegioFromSurvey <- function(surveyName, ch){
	
	# surveyName -> surveyId
	surveyId <- extractYFromYTable(
		x = list('SurveyNaam' = surveyName), 
		y = "SurveyKey", table = "DimSurvey",
		ch = ch)

	# surveyId -> LocationId
	locationId <- extractYFromYTable(
		x = list('SurveyKey' = surveyId), 
		y = "LocationWVKey", table = "FactTaxonOccurrence",
		ch = ch, distinct = TRUE)

	# LocationId -> RegioName
	regioName <- extractYFromYTable(
		x = list('LocationWVKey' = locationId), 
		y = "RegioWVNaam", table = "DimLocationWV", #"RegioWVCode"
		ch = ch, distinct = TRUE)

	# Note: if exported data, naam was concatenated with RegioWVCode,
	# is it required?

	res <- list(
		surveyId = surveyId, 
		locationId = locationId, 
		regioName = regioName
	)
	
	return(res)
	
}