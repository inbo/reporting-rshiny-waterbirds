#' simple wrapper to extract all data tables from set of files
#' @param basePath base path where all the tables are present in csv format
#' @return list of data.frame (each one is a different table)
#' @author Laure Cougnaud
#' @importFrom utils read.csv
#' @export
readData <- function(basePath){
	
	dataFiles <- list.files(basePath, full.names = TRUE, pattern = ".csv$")
	dataAll <- sapply(dataFiles, read.csv, stringsAsFactors = FALSE, simplify = FALSE)
	names(dataAll) <- sub("WB_report_(.+).csv", "\\1", basename(dataFiles))
	
	return(dataAll)
	
}