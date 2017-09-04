#' get available projects for a certain person
#' @param ch database connection, created with 
#' the \code{odbcConnect} function of the \code{RODBC} package
#' @param personKey integer with person key
#' @return vector with available projects
#' @author Laure Cougnaud
#' @export
getProjects <- function(ch, personKey){
	
	surveyKey <- extractYFromXTable(
		x = list(PersonKey = personKey), 
		y = "SurveyKey", table = "FactTaxonOccurrence",
		ch = ch, distinct = TRUE)
	
	surveyNaam <- extractYFromXTable(
		x = list(SurveyKey = surveyKey), 
		y = "SurveyNaam", table = "DimSurvey",
		ch = ch, distinct = TRUE)

	return(surveyNaam)
	
}