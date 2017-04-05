#' generate a plot with counts distribution
#' @param inputDataPlot data.frame with input data
#' @param typePlot string, 'ggplot' for static plot of 'plotly' for interactive plot
#' @return a code{ggplot} or a \code{plotly} object, depending on the parameter \code{typePlot}
#' @import ggplot2
#' @importFrom plotly ggplotly
#' @author Laure Cougnaud
#' @export
plotCountsDistribution <- function(inputDataPlot, typePlot = c('ggplot', 'plotly')){
	
	# order datum by season
	orderIdx <- with(inputDataPlot, order(surveyseason, teldatum))
	teldatumUnique <- unique(as.character(inputDataPlot[orderIdx, 'teldatum']))
	inputDataPlot$teldatum <- factor(inputDataPlot$teldatum, levels = teldatumUnique)
	
	# indicate season in the x-axis
	surveySeasonX <- inputDataPlot[
		match(teldatumUnique, inputDataPlot$teldatum), 
		"surveyseason"]
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
			labels = labelsAxisX
		)

	# increase bottom margin
#	defaultMargin <- theme_bw()$plot.margin
#	defaultMargin[1] <- defaultMargin[1] + unit(1,"pt")
#	gg <- gg + theme(plot.margin = defaultMargin)
	
	# render the plot, static or interactive
	switch(typePlot,
		'ggplot' = gg,
		'plotly' = ggplotly(gg, tooltip = c('x', 'fill', 'y'))
	)
	
}

## other implementation: use factor with date/soort in x-axis

# create a variable combining date and soort
# to be able to use it in the x-axis
#teldatumAndSoort <- with(inputDataPlot, paste(teldatum, soort))
#teldatumAndSoortLevels <- sort(unique(teldatumAndSoort))
#inputDataPlot$`teldatum and soort` <- factor(teldatumAndSoort, 
#		levels = teldatumAndSoortLevels)
# for x-axis, use season
#surveySeasonX <- inputDataPlot[
#		match(teldatumAndSoortLevels, inputDataPlot$`teldatum and soort`), 
#		"surveyseason"]
##	sub("([[:digit:]]{1,}-[[:digit:]]{1,})-[[:digit:]]{1,}.+", "\\1", teldatumAndSoortLevels)
## position season at the mean of all dates of this season
#idxLabel <- sapply(unique(surveySeasonX), function(season) 
#			floor(mean(which(surveySeasonX == season))))
#labelsAxisX <- rep("", length(surveySeasonX))
#labelsAxisX[idxLabel] <- names(idxLabel)

# create the plot
#gg <- ggplot(data = inputDataPlot, 
#				aes(x = `teldatum and soort`, y = telling, fill = soort)) +
#		
#		geom_bar(stat = "identity") + 
#		theme_bw() +
#		labs(x = 'telseizoen', y = 'telling', title = "Telling distributie") +
#		#	scale_x_discrete(breaks = NULL) +
#		
#		# only include the date in the x-axis
#		scale_x_discrete(
#				breaks = teldatumAndSoortLevels,
#				labels = labelsAxisX
#		)#+
# rotate x-labels
#		theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 4))

