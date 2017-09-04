#' extract taxon(s) available for a taxon group and from set of taxon identifiers
#' 
#' Taxon identifiers should be provided to restrict to taxons
#' sampled in a certain survey.
#' @param taxonId taxon identifier(s)
#' @param taxonGroup taxon group(s)
#' @param ch database connection, created with 
#' the \code{odbcConnect} function of the \code{RODBC} package
#' @return vector with available taxons (common names)
#' @author Laure Cougnaud
#' @export
getTaxonFromTaxonGroupTaxonId <- function(taxonId, taxonGroup, ch){
	
	# locationName -> locationId
	taxons <- extractYFromXTable(
		x = list(
			'TaxonGroupDescription' = taxonGroup,
			'TaxonWVKey' = taxonId
		), 
		y = "commonname", table = "DimTaxonWV",
		ch = ch)
	
	return(taxons)
	
}