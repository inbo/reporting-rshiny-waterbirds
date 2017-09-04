#' extract region(s) available for a certain survey and person
#' @param surveyName name of the survey, e.g. 'Slaapplaatstellingen Aalscholvers'
#' @param ch database connection, created with 
#' the \code{odbcConnect} function of the \code{RODBC} package
#' @param personKey integer with person key
#' @return list with two elements
#' \itemize{
#' \item{'surveyId': }{survey identifier}
#' \item{'location': }{identifiers of available location(s for the survey}
#' \item{'regioName': }{name of available region(s) for the survey}
#' }vector of regions available for specified surveys
#' @author Laure Cougnaud
#' @export
getRegioFromSurvey <- function(surveyName, personKey, ch){
	
	# surveyName -> surveyId
	surveyId <- extractYFromXTable(
		x = list('SurveyNaam' = surveyName), 
		y = "SurveyKey", table = "DimSurvey",
		ch = ch)

	# surveyId -> LocationId
	locationId <- extractYFromXTable(
		x = list('SurveyKey' = surveyId, 'PersonKey' = personKey), 
		y = "LocationWVKey", table = "FactTaxonOccurrence",
		ch = ch, distinct = TRUE)

	# LocationId -> RegioName
	regioName <- extractYFromXTable(
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