
library(watervogelsAnalyse)

shinyServer(function(input, output, session) {
			
	results <- reactiveValues(
		selectedData = 	NULL,
		countDistributionPlot = NULL
	)
			
	# when project selected, update regio
	observe({
				
		# check if project non empty
		if(isTruthy(input$project)){
			
			isolate({
				
				# project (surveyname) -> surveyID
				surveyId <- subset(dataTables$survey, surveyname %in% input$project)$surveyid
				regio <- unique(subset(dataTables$region, surveyid %in% surveyId)$region)
				
				message('Update regio to:', toString(regio))
	
				updateSelectInput(session, 
					inputId = 'regio',
					choices = regio)	
		
			})
		
		}
				
	})

	# when regio selected, update gebied
	observe({
				
		# check if project non empty
		if(isTruthy(input$regio)){
			
			isolate({
					
				# regio -> regioid (region table)
				regioId <- unique(subset(dataTables$region, region %in% input$regio)$regionid)
				# surveyname -> surveyid (survey table)
				surveyId <- subset(dataTables$survey, surveyname %in% input$project)$surveyid
				# surveyid + regionid -> locationname (location table)
				locationname <- sort(unique(
					subset(dataTables$location, 
						regionid %in% regioId & surveyid %in% surveyId
					)$locationname))
		
				updateSelectInput(session, 
					inputId = 'gebied',
					choices = locationname)	
		
			})
					
		}
				
	})

	# when gebied selected, update soortgroep
	observe({
				
		# check if project non empty
		if(isTruthy(input$gebied)){
			
			isolate({
			
				# gebied (locationname) -> locationid (region table)
				locationId <- unique(subset(dataTables$location, locationname %in% input$gebied)$locationid)
				
				# surveyname -> surveyid (survey table)
				surveyId <- subset(dataTables$survey, surveyname %in% input$project)$surveyid
				
				# locationid + surveyid -> taxonid (occurrences table)
				taxonId <- unique(
					subset(dataTables$occurrences, 
						locationid %in% locationId & surveyid %in% surveyId
					)$taxonid)
			
				# taxonid -> taxongroupid (taxongroup table)
				taxonGroupId <- unique(subset(dataTables$taxon, 
					taxonid %in% taxonId
				)$taxongroupid)
		
				# taxongroupid -> taxongroup (taxongroup table)
				taxonGroups <- sort(subset(dataTables$taxongroup, 
					taxongroupid %in% taxonGroupId
				)$taxongroup)
								
				updateSelectInput(session, 
					inputId = 'soortgroep',
					choices = taxonGroups)	
		
			})
			
		}
		
	})


	# when soortgroep selected, update soort
	observe({
			
		# check if project non empty
		if(isTruthy(input$soortgroep)){
				
			# taxongroup -> taxongroupid (taxongroup table)
			taxonGroupId <- subset(dataTables$taxongroup, taxongroup %in% input$soortgroep)$taxongroupid
				
			# taxongroupid -> commonname (taxon table)
			commonname <- sort(subset(dataTables$taxon, taxongroupid %in% taxonGroupId)$commonname)
				
			updateSelectInput(session, 
				inputId = 'soort',
				choices = commonname)	
				
		}
			
	})

	# when soort selected, update telseizoen
	observe({
				
		# check if project non empty
		if(isTruthy(input$soort)){
			
			isolate({
					
				# surveyname -> surveyid (survey table)
				surveyId <- subset(dataTables$survey, surveyname %in% input$project)$surveyid
					
				# gebied -> locationid (location table)
				locationId <- unique(subset(dataTables$location, locationname %in% input$gebied)$locationid)
				
				# soort (commonname) -> taxonid (taxon table)
				taxonId <- subset(dataTables$taxon, commonname %in% input$soort)$taxonid
				
				# soort + gebied + project -> telseizoen
				telseizoen <- sort(unique(
					subset(dataTables$occurrences, 
						locationid %in% locationId &
						surveyid %in% surveyId &
						taxonid %in% taxonId
					)$surveyseason
				))
				
				updateSelectInput(session, 
					inputId = 'telseizoen',
					choices = telseizoen)
		
			})
					
		}
		
	})

	# extract selected data (used for plot and data.table)
	observe({
				
		if(isTruthy(input$telseizoen)){
			
			isolate({
											
				# project (surveyname) -> surveyid (survey table)
				surveyId <- subset(dataTables$survey, surveyname %in% input$project)$surveyid
						
				# gebied (locationname) -> locationid (location table)
				locationId <- unique(subset(dataTables$location, locationname %in% input$gebied)$locationid)
						
				# soort (commonname)-> taxonid (taxon table)
				taxonId <- subset(dataTables$taxon, commonname %in% input$soort)$taxonid
						
				# extract corresponding data [surveyId + locationId + taxonId + telseizoen]
				selectedData <- subset(dataTables$occurrences,
					surveyid %in% surveyId &
					locationid %in% locationId &
					taxonid %in% taxonId &
					surveyseason %in% input$telseizoen
				)	
				
#				message("Update results$selectedData to", str(selectedData))		
				colsOfInterest <- c('project', 'regio', 'gebied', 'surveyseason',
					'telling', 'teldatum', 'tellingstatus', 'euringcode', 'soort', 
					'aantal')
				results$selectedData <- selectedData[, colsOfInterest]

			})
			
		}		
				
	})

	# plot the distribution
	output$countDistributionPlot <- renderPlotly({
		validate(
			need(results$selectedData,
				message = "" #"Please select the parameters."
			)
		)
		plot <- plotCountsDistribution(
			inputDataPlot = results$selectedData, 
			typePlot = 'plotly')
		results$countDistributionPlot <<- plot
		plot
	})

	# print data.table
	output$countData <- renderDataTable({
		validate(
			need(results$selectedData,
				message = ""#"Please select the parameters."
			)
		)
		results$selectedData
	})
		
	output$exportResults <- downloadHandler(
		filename = "waterbirds.html",
		content = function(file) {
			
			# check if selected data and plot not NULL
			validate(
				need(results$countDistributionPlot, message = ""),
				need(results$selectedData, message = "")
			)
				
			# extract parameters
			params <- list(
				countDistributionPlot = results$countDistributionPlot,
				selectedData = results$selectedData
			)
			
			# get path template report
			pathReport <- watervogelsAnalyse::getPathStartTemplate()
			
			# get report name
			reportName <- basename(pathReport)
			
			# copy start template in working directory
			file.copy(
				from = pathReport, 
				to = ".", 
				overwrite = TRUE
			)
			
			# run report
			res <- rmarkdown::render(
				reportName, 
				params = params
			)
			
			file.copy("waterbirds.html", file)
			
		}, 
		
		contentType = "text/html"

	)
#	
#	## individual contrasts button
#	
#	# indices to retain number of contrasts inserted
#	contrastsInserted <- c()
#	
#	observeEvent(
#		
#		input$addContrast, {
#			
#		# path of the ExpressionSet output of the QC report
#		pathQCEset <- file.path(outputPathFileRepository, input$projectID, "QC/objects/eset.RData")	
#		
#		# if some data have been uploaded
#		if(file.exists(pathQCEset)){
#			
#			load(pathQCEset)
#			availableTreatments <- levels(eset$treatment)
#			
#			message("contrastsInserted: '", toString(contrastsInserted), "'")
#			
#			i <- if(length(contrastsInserted) ==  0)
#				1	else max(contrastsInserted) + 1
#			
#			insertUI(
#				selector = "#placeholder", 
#				ui = fluidRow(	
#					column(2, strong(paste0("Define contrast ", i, ":"))),
#					column(2,
#						selectInput(
#							inputId = paste0("contrastLevel", i),
#							label = NULL,
#							multiple = TRUE,
#							choices = availableTreatments
#						)
#					),
#					column(1, "versus"),	
#					column(2,
#						selectInput(
#							inputId = paste0("contrastReference", i),
#							label = NULL,
#							multiple = TRUE,
#							choices = availableTreatments
#						)
#					),
#				id = paste0("contrast", i)
#				)
##				, immediate = TRUE
#			)
#			
#			# need double assignment to set value inside of observeEvent
#			contrastsInserted <<- c(contrastsInserted, i)
#			
#			message("contrastsInserted: '", toString(contrastsInserted), "'")
#			
#		}
#	})
#
#	observeEvent(
#		input$removeContrast, 
#		{
#			removeUI(
#				selector = paste0('#contrast', contrastsInserted[length(contrastsInserted)])
#			)
#			# need double assignment to set value inside of observeEvent
#			contrastsInserted <<- contrastsInserted[-length(contrastsInserted)]
#			message("remaining contrasts: '", toString(contrastsInserted), "'")			
#	})
#
#
#	## intersect of contrasts
#
#	# indices to retain number of contrasts inserted
#	contrastsSetInserted <- c()
#
#	observeEvent(
#		
#		input$addContrastsSet, {
#				
#			i <- if(length(contrastsSetInserted) ==  0)
#				1	else max(contrastsSetInserted) + 1
#				
#			insertUI(
#				selector = "#placeholderContrastsSets", 
#				# TODO
#				ui = fluidRow(
##					tags$head(
##						tags$style(type="text/css", "label.control-label, .selectize-control.multi{ display: table-cell; text-align: center;}")
##					),
#					column(1, strong(br(), paste0("Define contrast set ", i, ":"))),
#					column(2,
#						selectInput(
#							inputId = paste0("contrastSetBoth", i),
#							label = "up- or down-regulated in",
#							multiple = TRUE,
#							choices = if(length(contrastsInserted) > 0)
#								paste("contrast", contrastsInserted)	else ""
#							)
#					),
#					column(1, strong(br(), br(), "OR")),
#					column(2,
#						selectInput(
#							inputId = paste0("contrastSetUp", i),
#							label = "up-regulated in",
#							multiple = TRUE,
#						choices = if(length(contrastsInserted) > 0)
#							paste("contrast", contrastsInserted)	else ""
#						)
#					),
#					column(1, strong(br(), br(), "AND")),
#					column(2,
#						selectInput(
#							inputId = paste0("contrastSetDown", i),
#							label = "down-regulated in",
#							multiple = TRUE,
#							choices = if(length(contrastsInserted) > 0)
#							paste("contrast", contrastsInserted)	else ""
#						)
#					),
#					column(1, strong(br(), br(), "WITHOUT")),
#					column(2,
#						selectInput(
#							inputId = paste0("contrastSetNot", i),
#							label = "not significantly affected in",
#							multiple = TRUE,
#							choices = if(length(contrastsInserted) > 0)
#							paste("contrast", contrastsInserted)	else ""
#						)
#					),
##					column(1, strong(br(), "]")),
#					id = paste0("contrastSetRow", i)
#				)
#			)
#				
#			# need double assignment to set value inside of observeEvent
#			contrastsSetInserted <<- c(contrastsSetInserted, i)
#				
#			message("contrastsInserted: '", toString(contrastsSetInserted), "'")
#				
#	})
#
#	observeEvent(
#		input$removeContrastsSet, 
#		{
#			removeUI(
#				selector = paste0('#contrastSetRow', 
#				contrastsSetInserted[length(contrastsSetInserted)])
#			)
#			# need double assignment to set value inside of observeEvent
#			contrastsSetInserted <<- contrastsSetInserted[-length(contrastsSetInserted)]
#			message("remaining contrasts: '", toString(contrastsSetInserted), "'")			
#		})
#
#	## run analysis
#	
#	# when click on analysis report
#	observeEvent(
#			
#		input$runAnalysisReport, {
#				
#		message("runAnalysisReport button clicked.")
#				
#		# path of the ExpressionSet output of the QC report (TEST)
#		pathQCEset <- file.path(outputPathFileRepository, input$projectID, "QC/objects/eset.RData")
#		
#		# if some data have been uploaded
#		if(file.exists(pathQCEset)){
#			
#			message("contrastsInserted:", toString(contrastsInserted))
#			
#			contrastsSpecified <- length(contrastsInserted) > 0 && 
#				!is.null(input$contrastLevel1) && !is.null(input$contrastReference1)
#			
#			message("contrastsSpecified:", toString(contrastsSpecified))
#			
#			# path for the project (TEST)
#			outputPathProject <- file.path(outputPathFileRepository, input$projectID)	
#		
#			if(contrastsSpecified){
#				
#				output$messageAnalysisReport <- renderUI(div(
#					paste("The results of the QC for the project: ", 
#					basename(outputPathProject), "is used."),
#					style = "color:green"))
#					
#				withProgress(
#						
#					message = "Creation of the Analysis report in progress",
#								
#					detail = "This may take a few minutes",
#								
#						{
#								
#						# get path report (TEST)	
#						pathAnalysisReport <- 
#							analysisTemplateStratiCELL::getPathStartTemplate()
#						analysisReportName <- basename(pathAnalysisReport)
#								
#						# extract already available analysis (TEST)
#						outputPathAnalysisTop <- file.path(outputPathProject, "analysis")
#						availableAnalyses <- list.files(outputPathAnalysisTop)
#						analysisID <- ifelse(
#							is.null(availableAnalyses) || length(availableAnalyses) == 0, 1, 
#							max(as.integer(availableAnalyses)) + 1)
#						# build path of new analysis
#						outputPathAnalysis <- file.path(outputPathAnalysisTop, analysisID, "")
#						
#						# print message
#						output$messageAnalysisReport <- renderUI(div(
#							paste0("This new analysis for the project: ", 
#								input$projectID, " has the identifier: ", 
#								analysisID, "."), style = "color:green"))
#					
#						# delete results previous execution (if any) (TEST)
#						unlink(outputPathAnalysis, recursive = TRUE)
#						dir.create(outputPathAnalysis, recursive = TRUE)
#								
#						# copy start template (TEST)
#						file.copy(
#							from = pathAnalysisReport, 
#							to = paste0(outputPathAnalysis, analysisReportName), 
#							overwrite = TRUE#, recursive = TRUE
#						)
#						
#						# get contrasts
#						message("contrastsInserted:", toString(contrastsInserted))
#						contrastsOfInterestList <- sapply(contrastsInserted, function(i)
#							list(
#								level = input[[paste0("contrastLevel", i)]], 
#								reference = input[[paste0("contrastReference", i)]]
#							)
#						, simplify = FALSE)
#				
#						# get intersect of contrasts
##						message("contrastsSetInserted:", toString(contrastsSetInserted))
##						message("contrastsIntersect buttons:", 
##							toString(paste0("contrastIntersect", contrastsSetInserted)))
#						
#						contrastsSetOfInterestList <- lapply(contrastsSetInserted, function(i)
#							list(
#								both = input[[paste0("contrastSetBoth", i)]],
#								up = input[[paste0("contrastSetUp", i)]],
#								down = input[[paste0("contrastSetDown", i)]],
#								not = input[[paste0("contrastSetNot", i)]]
#							)
#						)# empty list if no contrasts are specified (list())
#						
##						message("contrastsOfInterestList = ", str(contrastsOfInterestList))
##						message("contrastsSetOfInterestList = ", str(contrastsOfInterestList))
#								
#						#  get input parameters for the document (TEST)
#						params <- list(
#							outputPath = outputPathAnalysis,
#							featureSet = input$featureSet,
#							typePathwayAnalysis = input$typePathwayAnalysis,
#							fdr = input$fdr,
#							pathEset = pathQCEset,
#							contrastsOfInterestList = contrastsOfInterestList,
#							contrastsSetOfInterestList = contrastsSetOfInterestList,
#							author = input$author,
#							projectID = input$projectID,
#							projectDescription = input$projectDescription,
#							analysisID = analysisID,
#							reportProgressShiny = TRUE #FALSE
#						)
#						
##						str(input$projectDescription)
##						stop("test")
#								
#						# Knit the document, passing in the `params` list, and eval it in a
#						# child of the global environment (this isolates the code in the document
#						# from the code in this app).
#						potentialErrorMessage <- try(
#										
#							# run analysis report (TEST)
#							res <- rmarkdown::render(
#								paste0(outputPathAnalysis, analysisReportName), 
#								params = params
#							)
#							, silent = TRUE)
#							
#						})
#					
#					if(inherits(potentialErrorMessage, "try-error")){
#						
#						# print message
#						message("error message")
#						output$messageAnalysisReport <- renderUI(
#							div(strong(paste("The Analysis report didn't run:",
#								potentialErrorMessage)), 
#							style = "color:red"))
#						
#					}else{
#						
#						# print message
#						output$messageAnalysisReport <- renderUI(div(
#							"The Analysis has run successfully.", 
#							style = "color:green"))
#						
#					}
#					
#			}else{
#				
#				# print message
#				output$messageAnalysisReport <- renderUI(div(
#					"Please specify some contrast(s) for the analysis.", 
#					style = "color:red"))
#				
#			}
#			
#		}else{
#				
#			# print message
#			output$messageAnalysisReport <- renderUI(div(
#				"Please run a Quality Check analysis first.", 
#				style = "color:red"))
#
#		}
#			
#	})
#	
#	output$getAnalysisReport <- downloadHandler(
#		filename = "microarrayAnalysisReport.html",
#		content = function(file) {
#			outputPathAnalysis <- file.path(outputPathFileRepository, input$projectID, "analysis")
#			filePath <- list.files(outputPathAnalysis, recursive = FALSE)
#			analysisID <- ifelse(length(filePath) == 0, 1, 
#				max(as.integer(filePath)))
#			# build path of new analysis
#			outputPathAnalysis <- file.path(outputPathAnalysis, 
#				analysisID, "microarrayAnalysisReport.html")
#			file.copy(outputPathAnalysis, file)
#		}, 
#		contentType = "text/html"
#	)
			
})