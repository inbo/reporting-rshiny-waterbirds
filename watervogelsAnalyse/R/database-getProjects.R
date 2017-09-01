#' get available projects
#' @param ch database connection, created with 
#' the \code{odbcConnect} function of the \code{RODBC} package
#' @return vector with available projects
#' @author Laure Cougnaud
#' @export
getProjects <- function(ch){
	
	surveyNaam <- extractYFromYTable(
		x = NULL, 
		y = "SurveyNaam", table = "DimSurvey",
		ch = ch, distinct = TRUE)

	return(surveyNaam)
	
}