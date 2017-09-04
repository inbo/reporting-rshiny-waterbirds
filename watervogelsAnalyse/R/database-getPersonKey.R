#' get key of person stored in database from email (provided in ShinyProxy)
#' @param ch database connection, created with 
#' the \code{odbcConnect} function of the \code{RODBC} package
#' @param email string with email
#' @return string with person key
#' @author Laure Cougnaud
#' @export
getPersonKey <- function(ch, email){
	
	personKey <- extractYFromXTable(
		x = list(email = email), y = "PersonKey",
		table = "DimPerson", ch = ch
	)
	
	return(personKey)
	
}