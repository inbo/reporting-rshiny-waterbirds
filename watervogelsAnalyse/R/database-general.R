#' extract a specific column '\code{y}' from a \code{table}
#' of the database 'W0004_00_Waterbirds' corresponding to 
#' specified '\code{xValue}' in column '\code{x}'
#' @param x list with value for query parameter(s)
#' List should be named by query columns in \code{table}.
#' @param y name of the column(s) in \code{table} of output
#' @param table name of the database table to query
#' @param ch database connection, created with 
#' the \code{odbcConnect} function of the \code{RODBC} package
#' @param distinct logical, if TRUE (FALSE by default) extract distinct elements only
#' @param verbose logical, if TRUE, print the corresponding SQL query in a message
#' @return query results, data.frame if multiple columns are specified with '\code{y}',
#' otherwise sorted vector
#' @importFrom RODBC sqlQuery
#' @author Laure Cougnaud
extractYFromYTable <- function(x, y, table, ch, distinct = FALSE, verbose = TRUE){
	
	# build SQL query
	yRf <- ifelse(
		length(y) == 1 && y == "*",
		y, toString(y) # in case multiple columns
	)
	
	queryWhere <- paste(
		sapply(names(x), function(xName)
			paste0(xName, " IN (", toString(paste0("'", x[[xName]], "'")), ")")			
		),
		collapse = " AND "
	)
	
	query <- paste0("SELECT ", 
		ifelse(distinct, "DISTINCT ", ""), 
		yRf, " FROM W0004_00_Waterbirds.dbo.", table, 
		" WHERE ", queryWhere# " = '", xValue, "'"
	)
	if(verbose)	message("The query used is: ", query)
	
	# query database
	resQuery <- sqlQuery(ch, query, stringsAsFactors = FALSE)
	
	# format output: unlist if only one column requested
	yValue <- if(length(y) == 1 && y != "*")	
		sort(unlist(resQuery, use.names = FALSE))	else resQuery
	
	return(yValue)
	
}