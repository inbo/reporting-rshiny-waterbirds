#' extract a specific column '\code{y}' from a \code{table}
#' of the database 'W0004_00_Waterbirds' corresponding to 
#' specified '\code{xValue}' in column '\code{x}'
#' @param ch database connection, created with 
#' the \code{odbcConnect} function of the \code{RODBC} package
#' @param verbose logical, if TRUE, print the corresponding SQL query in a message
#' @return query results, data.frame if multiple columns are specified with '\code{y}',
#' otherwise sorted vector
#' @inheritParams getQuery
#' @importFrom RODBC sqlQuery
#' @author Laure Cougnaud
extractYFromXTable <- function(x, y, table, ch, distinct = FALSE, verbose = TRUE){
	
	# build query
	query <- getQuery(x = x, y = y, table = table, distinct = distinct)

	if(verbose)	message("The query used is: ", query)
	
	# query database
	resQuery <- sqlQuery(ch, query, stringsAsFactors = FALSE)
	
	# format output: unlist if only one column requested
	yValue <- if(length(y) == 1 && y != "*")	
		sort(unlist(resQuery, use.names = FALSE))	else resQuery
	
	return(yValue)
	
}

#' create a SQL query
#' @param x list with value for query parameter(s)
#' List should be named by query columns in \code{table}.
#' @param y name of the column(s) in \code{table} of output
#' @param table name of the database table to query
#' @param distinct logical, if TRUE (FALSE by default) extract distinct elements only
#' @return string with SQL query
#' @author Laure Cougnaud
#' @export
getQuery <- function(x = NULL, y, table, distinct = FALSE){
	
	# build SQL query
	yRf <- ifelse(
		length(y) == 1 && y == "*",
		y, toString(y) # in case multiple columns
	)
	
	queryWhere <- ifelse(!is.null(x),
		paste(" WHERE", 
			paste(
				sapply(names(x), function(xName)
					paste0(xName, " IN (", toString(paste0("'", x[[xName]], "'")), ")")			
				),
				collapse = " AND "
			)
		), "")
	
	# list the tables:
	# listTables <- sqlTables(ch, tableType = "TABLE")
#	sqlQuery(ch, "select top 10 * from W0004_01_Waterbirds.dbo.[table]")
	query <- paste0("SELECT ", 
		ifelse(distinct, "DISTINCT ", ""), 
		yRf, " FROM W0004_01_Waterbirds.dbo.", table, 
		queryWhere# " = '", xValue, "'"
	)
	
	return(query)
	
}

#' build join part of SQL query
#' @param tableX name of first SQL table to join from
#' @param tableY name of second SQL table to join to
#' @param key key used to join the two tables
#' @param typeJoin string with type of join: 'none', 'left' or 'right'
#' @return string with join part of SQL query
#' @author Laure Cougnaud
#' @export
getQueryJoin <- function(tableX, tableY, key, typeJoin = c("none", "left", "right")){

	typeJoin <- match.arg(typeJoin)
	
	sqlJoin <- paste0(switch(typeJoin, 'none' = "", 'left' = "LEFT ", 'right' = "RIGHT "), "JOIN")

	queryJoin <- paste(sqlJoin, tableY, "ON",
		paste0(tableX, ".", key), "=", paste0(tableY, ".", key)
	)
	
	return(queryJoin)
	
}