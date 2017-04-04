#' get path of start template available in the package
#' @return string with path of start template
#' @author Laure Cougnaud and Kirsten Van Hoorde
#' @export
getPathStartTemplate <- function(){
	
	basePathStartTemplate <- grep("watervogelsAnalyse", searchpaths(), value = TRUE)
	pathStartTemplate <- dir(basePathStartTemplate , pattern = ".Rmd", full.names = TRUE)
	
	return(pathStartTemplate)
	
}
