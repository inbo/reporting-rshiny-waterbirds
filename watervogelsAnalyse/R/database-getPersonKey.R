#' get key of person stored in database from username (provided in ShinyProxy)
#' @param ch database connection, created with 
#' the \code{odbcConnect} function of the \code{RODBC} package
#' @param username string with username
#' @return string with person key
#' @author Laure Cougnaud
#' @export
getPersonKey <- function(ch, username){
	
	personKey <- extractYFromXTable(
		x = list(PersonCode = username), y = "PersonKey",
		table = "DimPerson", ch = ch
	)
	
	return(personKey)
	
}