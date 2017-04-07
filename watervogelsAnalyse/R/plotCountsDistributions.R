#' generate a plot with counts distribution
#' @param inputDataPlot data.frame with input data
#' @param teldatumSeasonDf data.frame with available teldatum per surveyseason
#' @param typePlot string, 'ggplot' for static plot of 'plotly' for interactive plot
#' @return a code{ggplot} or a \code{plotly} object, depending on the parameter \code{typePlot}
#' @import ggplot2
#' @importFrom plotly ggplotly
#' @author Laure Cougnaud
#' @export
plotCountsDistribution <- function(inputDataPlot, teldatumSeasonDf, typePlot = c('ggplot', 'plotly')){
	
	# include all available teldatum (empty bar if not present in the data)
	# by creating extra factor levels
	
	# only keep teldatum of selected survey season
	teldatumSeasonDfAvailable <- subset(teldatumSeasonDf, 
		surveyseason %in% inputDataPlot$surveyseason)
	
	# sort by 1) season 2) teldatum
	teldatumSeasonSorted <- teldatumSeasonDfAvailable[
		with(teldatumSeasonDfAvailable, order(surveyseason, teldatum)), ]

	# create variable for x-axis
	teldatumUnique <- teldatumSeasonSorted$teldatum
	inputDataPlot$teldatum <- factor(inputDataPlot$teldatum, levels = teldatumUnique )
	
	# indicate season in the x-axis
	surveySeasonX <- teldatumSeasonSorted$surveyseason
	idxLabel <- sapply(unique(surveySeasonX), function(season) 
		floor(mean(which(surveySeasonX == season))))
	labelsAxisX <- rep("", length(surveySeasonX))
	labelsAxisX[idxLabel] <- names(idxLabel)
	
	# create the plot
	gg <- ggplot(data = inputDataPlot, 
		aes(x = teldatum, y = aantal, fill = soort)) +
		# position_dodge, otherwise stacked-bar
		geom_bar(stat = "identity", position = position_dodge()) + 
		theme_bw() +
		labs(x = 'telseizoen', y = 'aantal', title = "Aantalsverlopen distributie") +
		# only include the date in the x-axis
		scale_x_discrete(
			breaks = teldatumUnique,
			labels = labelsAxisX,
			drop = FALSE # keep 'empty' teldatum
		)
	
	# render the plot, static or interactive
	switch(typePlot,
		'ggplot' = gg,
		'plotly' = ggplotly(gg, tooltip = c('x', 'fill', 'y'))
	)
	
}