# LNAPL Present Modules -----------------------------

## UI -----------------------------------------
LNAPLPresentUI <- function(id, label = "LNAPL Present"){
  ns <- NS(id)
  
  tabPanel("LNAPL Volume",
           tags$i(h1("How much LNAPL is present?")),
           tabsetPanel(
             ### Tier 1 --------------------
             tabPanel(Tier1,
                      fluidRow(
                        br(),
                        column(7, 
                               # Text
                               includeMarkdown("./www/02_LNAPL-Volume/Tier-1/LNAPL-Volume_Tier-1.md")
                               ),# end column 1
                        column(5, align = "center",
                               br(),
                               br(),
                               # Table
                               includeHTML("./www/02_LNAPL-Volume/Tier-1/LNAPL_Present_Table.html"),
                               br(),
                               # Table Caption
                               HTML("<p><i>Table developed for Concawe Toolbox 2020 using LNAPL tool developed by<br>
                               de Blanc, P. and S. K. Farhat, 2018. 25th IPEC: International Petroleum<br>
                                    Environmental Conference October 30 – November 1, 2018. Denver, Colorado.</i></p>")
                               ) # end column 2
                        ) # end fluid row
             ), # end Tier 1
             ### Tier 2 ------------
             tabPanel(Tier2,
                      br(),
                      fluidRow(
                        column(3, style='border-right: 1px solid black',
                               includeMarkdown("./www/02_LNAPL-Volume/Tier-2/LNAPL-Volume_Tier-2.md"),
                               br(), br(),
                               fluidRow(align = "center",
                               downloadButton(ns("download_user_manual"), "Download Parameter Selection Guide", style=button_style))
                               ), # end column 1
                        column(3, 
                               HTML("<h3><b>Inputs:</b></h3>"),
                               fluidRow(align = "center",
                                 column(6, 
                                        downloadButton(ns("download_data"), "Download Data Template", style=button_style),
                                        br(), br(), br(),
                                        actionButton(ns("update_inputs"), HTML("Update Input Values<br>(Will Reset Table)"), style=button_style)
                                        ),
                                 column(6,
                                        fileInput("file", "Choose Input File",
                                                  multiple = F,
                                                  accept = c("text/xlsx",
                                                             "text/comma-separated-values,text/plain",
                                                             ".xlsx")),
                                        downloadButton(ns("model_results"), HTML("Export Model Results and Input Tables"), style=button_style))
                                 ), #fluid row 1
                               fluidRow(align = "center",
                                        br(), br(),
                                        numericInput(ns("water_density"),"Water Density (g/cm3)", value=1, min = 0, step = 0.1, width = '200px'),
                                        numericInput(ns("LNAPL_density"),"LNAPL Density (g/cm3)", value=0.8, min = 0, step = 0.1, width = '200px'),
                                        numericInput(ns("viscosity"),"LNAPL Viscosity (cp)", value=2, min = 0, width = '200px'),
                                        numericInput(ns("a_w_tension"),"Air/Water Interfacial Tension (dyn/cm)", value=65, min = 0, width = '200px'),
                                        numericInput(ns("o_w_tension"),"LNAPL/Water Interfacial Tension (dyn/cm)", value=15, min = 0, width = '200px'),
                                        numericInput(ns("a_o_tension"),"Air/LNAPL Interfacial Tension (dyn/cm)", value=25, min = 0, width = '200px'),
                                        numericInput(ns("sat_factor"),"Residual Saturation (f) Factor", value=0.2, min = 0, step = 0.1, width = '200px'),
                                        br(),
                                        actionButton(ns("calculate"), "Calculate", style=button_style)
                                 ) #fluid row 2
                               ), # end column 2
                        column(5, style='border-left: 1px solid black',
                               tabsetPanel(
                                 tabPanel("Map",
                                          br(),
                                          fluidRow(
                                            column(4, 
                                                   downloadButton(ns("map_export"), HTML("<br>Save Map"), style=button_style)),
                                            column(8,
                                                   selectizeInput(ns("Parameters"), "Select Parameter to View:",
                                                                  choices = c("LNAPL Specific Volume", 
                                                                              "Mobile LNAPL Specific Volume", 
                                                                              "Average LNAPL Relative Permeability",
                                                                              "Maximum Elevation of Free LNAPL", 
                                                                              "Average LNAPL Hydraulic Conductivity",
                                                                              "Average Transmissivity",
                                                                              "LNAPL Unit Flux", 
                                                                              "Average LNAPL Seepage Velocity"),
                                                                  selected = "LNAPL Specific Volume"))),
                                          leafletOutput(ns("map_holder"), height = 600)
                                          ),
                                 tabPanel("Model Output",
                                          DTOutput(ns("Model_DT"), height = 600))
                                 ),
                               br(), br(),
                               tabsetPanel(
                                 tabPanel("Location Information",
                                          DTOutput(ns("loc_info")),
                                          HTML("<i>Double click to edit</i>"),
                                          br(),
                                          actionButton(ns("addData_loc"), "Add Row"),
                                          br(),br()),
                                 tabPanel("Stratigraphy",
                                          DTOutput(ns("Strat")),
                                          HTML("<i>Double click to edit</i>"),
                                          br(),
                                          actionButton(ns("addData_strat"), "Add Row"),
                                          br(),br()),
                                 tabPanel("Soil Types",
                                          DTOutput(ns("soil")),
                                          HTML("<i>Double click to edit</i>"),
                                          br(),
                                          actionButton(ns("addData_soil"), "Add Row"),
                                          br(),br())
                               )
                               ) # end column 3
                        ) # end Tier 2 fluid row
                      ), # end Tier 2
             
             ### Tier 3 --------------
             tabPanel(Tier3, 
                      br(),
                      fluidRow(
                        column(2,), 
                        column(8, 
                               # Markdown Text
                               br(),
                               includeMarkdown("./www/02_LNAPL-Volume/Tier-3/LNAPL-Volume_Tier-3.md"),
                               br(),
                               # Button to download pdf
                               fluidRow(align = "center",
                                        downloadButton(ns("download_pdf"), 
                                                       HTML("<br>Download Information"), style=button_style)),
                               br(), br()
                        ), # end column 1
                        column(2,) # end column 2
                      ) # end fluid row 
                      ) # end Tier 3
             )
           )
} # end LNAPL Present UI

## Server -------------------------------------
LNAPLPresentServer <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {
      ## Tier 2 ----------------------------------------
      ## Download Parameter Selection Guide ------------------------
      output$download_user_manual <- downloadHandler(
        filename = function(){
          paste("LDRM_User-and-Parameter-Selection-Guide","pdf",sep=".")
        },
        content = function(con){
          file.copy("./www/02_LNAPL-Volume/Tier-2/LDRM_User_Manual.pdf", con)
        }
      )# end download_data
      
      
      # Defining reactive variables for each input file
      loc <- reactiveVal(default_loc)
      strat <- reactiveVal(default_strat)
      soil <- reactiveVal(default_soil)
      
      
      ## Download Data Template ------------------------
      output$download_data <- downloadHandler(
        filename = function(){
          paste("LNAPL_Volume_Data_Template","xlsx",sep=".")
        },
        content = function(con){
          file.copy("./data/LNAPL_Volume_Data_Template.xlsx", con)
        }
      )# end download_data
      
      ## Export Model Results ---------------------------
      output$model_results <- downloadHandler(
        filename = function(){
          paste("LNAPL_Volume_Model_Results","xlsx",sep=".")
        },
        
        content = function(con){
          # Model Results
          
          cd <- get_mwCalc()
          
          cd <- full_join(loc() %>% select("Location", "Date"), cd, by = "Location")
          
          colnames(cd) <- c('Location ID', 'Date',
                            'LNAPL Specific Volume (m3/cm2)',
                            'Mobile LNAPL Specific Volume (m3/cm2)',
                            'Avg. LNAPL Relative Permeability',
                            'Max Elevation of Free LNAPL (m)',
                            'Avg. LNAPL Hydraulic Conductivity (cm/d)',
                            'Avg. Transmissivity (m2/d)',
                            'LNAPL Unit Flux (m2/d)',
                            'Avg. LNAPL Seepage Velocity (m/d)')
                                     
          
          # Create empty excel file
          wb <- createWorkbook()
          
          # Add Results Tab
          addWorksheet(wb, "Model_Results")
          writeData(wb, sheet = "Model_Results", x = cd, startCol = 1, startRow = 1, colNames = T)
          
          # Add Location_Information Tab
          addWorksheet(wb, "Location_Information")
          writeData(wb, sheet = "Location_Information", x = loc(), startCol = 1, startRow = 1, colNames = T)
          
          # Add Stratigraphy Tab
          addWorksheet(wb, "Stratigraphy")
          writeData(wb, sheet = "Stratigraphy", x = strat(), startCol = 1, startRow = 1, colNames = T)
          
          # Add Soil_Types Tab
          addWorksheet(wb, "Soil_Types")
          writeData(wb, sheet = "Soil_Types", x = soil(), startCol = 1, startRow = 1, colNames = T)
          saveWorkbook(wb, con)
        }
      )# end model_results
      
      
      # Function to format excel data input
      input_file <- reactive({
        
        req(input$file)
        
        # Organize Location Information
        loc <- read_xlsx(input$file, sheet = "Location_Information")
        colnames(loc) <- c("Location", "Date",  "Latitude", "Longitude", "LNAPL_Top_Depth_m", "LNAPL_Bottom_Depth_m", "LNAPL_Gradient")
        
        loc <- loc %>% filter(Location != "Add additional rows as needed.")
        
        # Organize Stratigraphy
        strat <- read_xlsx(input$file, sheet = "Stratigraphy")
        colnames(strat) <- c("Location", "Layer_Top_Depth_m", "Layer_Bottom_Depth_m", "Soil_Type")
        
        strat <- strat %>% filter(Location != "Add additional rows as needed.")
        
        # Organize Soil_Types
        soil <- read_xlsx(input$file, sheet = "Soil_Types", skip = 1)
        colnames(soil) <- c("Soil_Num", "Soil_Type", "Porosity", "Ks_m-d", "Theta_wr", "N", "alpha_m", "M")
        
        soil <- soil %>% filter(Soil_Num != "Add additional rows as needed.")
        
        data_output <- list(loc = loc, strat = strat, soil = soil)
        
        data_output
        
      }) # input_file
      
      ## Model Calculations (python function) ------------------
      
      get_mwCalc <- eventReactive(input$calculate,{
        
        req(input$water_density,
            input$LNAPL_density,
            input$viscosity,
            input$a_w_tension,
            input$o_w_tension,
            input$a_o_tension,
            input$sat_factor)
        
        data_in <- list(loc = loc(), strat = strat(), soil = soil())

        validate(need(sum(!(unique(loc()$Location) %in% unique(strat()$Location))) == 0, "Location IDs do not match between Location Information and Stratigraphy Tables.")) 
        # validate(need(sum(!(unique(strat()$Soil_Type) %in% unique(soil()$Soil_Type))) == 0, "Soil Types do not match between Stratigraphy and Soil Tables."))

        # Loc
        loct <- data_in[['loc']] 
        loct$Date <- as.character(loct$Date)
        loct <- loct %>% column_to_rownames("Location")
        loct <- setNames(split(loct, seq(nrow(loct))), rownames(loct))
        
        loct <- dict(loct)
        
        # Soil
        soilt <- data_in[['soil']] 
        soilt <- soilt %>% mutate(Soil_Num = as.numeric(Soil_Num))  %>% column_to_rownames("Soil_Type")
        soilt <- setNames(split(soilt, seq(nrow(soilt))), rownames(soilt))
        
        soilt <- dict(soilt)
        
        # Strat
        stratt <- data_in[["strat"]]
        
        cd <- mwCalc(waterDensity = input$water_density,
                     lnaplDensity = input$LNAPL_density,
                     lnaplViscosity = input$viscosity,
                     airWaterTension = input$a_w_tension,
                     lnaplWaterTension = input$o_w_tension,
                     lnaplAirTension = input$a_o_tension,
                     lnaplResidSatFact = input$sat_factor,
                     locR = loct,
                     soilR = soilt,
                     stratR = stratt)
        # Assign Variable names to list items 
        for(i in 1:length(cd)){
          names(cd[[i]]) <- c("Do_m3_cm2", "Do_mobile_m3_cm2", "kro_avg", "zmax_m", "KLNAPL_avg_cm_d", "T_avg_m2_d", "ULNAPL_m2_d", "vLNAPL_avg_m_d")
        }
        
        # Change list into DF
        cd <- map_dfr(1:length(cd), ~c(Location = names(cd[.x]), cd[[.x]]))
        cd <- cd %>% 
          mutate(across(-Location, as.numeric))
        
        cd
        
      }) # end get_mwCalc
      
      ## update_inputs Button ----------------------------
      # update_inputs Button (updates DT and input variables)
      observeEvent(input$update_inputs,{
        
        if(is.null(input$file)){
          loc_x <- default_loc
          strat_x <- default_strat
          soil_x <- default_soil
        }else{
          loc_x <- input_file()[["loc"]]
          strat_x <- input_file()[["strat"]]
          soil_x <- input_file()[["soil"]]
        }
        
        # Set Location Variable
        col_loc <- c("Location", "Date",  "Latitude", "Longitude", "LNAPL_Top_Depth_m", "LNAPL_Bottom_Depth_m", "LNAPL_Gradient")
        colnames(loc_x) <- col_loc
        
        loc(loc_x)
        
        # Set Strat Variable
        col_strat <- c("Location", "Layer_Top_Depth_m", "Layer_Bottom_Depth_m", "Soil_Type")
        colnames(strat_x) <- col_strat
        
        strat(strat_x)
        
        # Set Soil Type Variable
        col_soil <- c("Soil_Num", "Soil_Type", "Porosity", "Ks_m-d", "Theta_wr", "N", "alpha_m", "M")
        colnames(soil_x) <- col_soil
        
        soil(soil_x)
      }) # end update_inputs button
      
      ## Data Table: Location Info ----------------
      # Create Location Table
      output$loc_info <- renderDT(loc(), server = FALSE, editable = TRUE, selection = "none",
                                  colnames = c("Location", "Date", "Latitude", "Longitude", "LNAPL Top Elevation (m)", "LNAPL Bottom Elevation (m)", "LNAPL Gradient"),
                                  options = list(lengthChange = TRUE, 
                                                 columnDefs = list(list(className = 'dt-center', targets = "_all"))))
      
      # store a proxy of tbl 
      proxy_loc <- dataTableProxy(outputId = "loc_info")
      
      # each time addData is pressed, add user_table to proxy
      observeEvent(eventExpr = input$addData_loc, {
        # Create Empty row
        user_table_loc <- loc() %>% 
          slice(1) %>% 
          replace(values = "")
        rownames(user_table_loc) <- dim(loc())[1] + 1
        
        #Page row will appear on 
        pg <- ceiling((dim(loc())[1] + 1)/10)
        
        # Add empty row to table
        proxy_loc %>% 
          addRow(user_table_loc) %>%
          selectPage(pg)
      }) # end add row event
      
      # When table is edited update reactive variable
      observeEvent(input$loc_info_cell_edit, {
        loc(editData(loc(), input$loc_info_cell_edit))
      })
      
      ## Data Table: Strat ----------------
      # Create Table
      output$Strat <- renderDT(strat(), server = FALSE, editable = TRUE, selection = "none",
                               colnames = c("Location", "Layer Top Elevation (m)", "Layer Bottom Elevation (m)", "Soil Type"),
                                  options = list(lengthChange = TRUE,
                                                 columnDefs = list(list(className = 'dt-center', targets = "_all"))))
      # store a proxy of tbl 
      proxy_strat <- dataTableProxy(outputId = "Strat")
      
      # each time addData is pressed, add user_table to proxy
      observeEvent(eventExpr = input$addData_strat, {
        # Create Empty row
        user_table_strat <- strat() %>% 
          slice(1) %>% 
          replace(values = "")
        rownames(user_table_strat) <- dim(strat())[1] + 1
        
        #Page row will appear on 
        pg <- ceiling((dim(strat())[1] + 1)/10)
        
        # Add empty row to table
        proxy_strat %>% 
          addRow(user_table_strat)%>%
          selectPage(pg)
      }) # end add row event
      
      # When table is edited update reactive variable
      observeEvent(input$strat_cell_edit, {
        strat(editData(strat(), input$strat_cell_edit))
      })
      
      ## Data Table: Soil ----------------
      # Create Table
      output$soil <- renderDT(soil(), server = FALSE, editable = TRUE, selection = "none",
                              colnames =  c("Soil Number", "Soil Type", "Porosity", "Ks (m/d)", "Theta_wr", "N", "alpha (1/m)", "M"),
                               options = list(lengthChange = TRUE,
                                              columnDefs = list(list(className = 'dt-center', targets = "_all"))))
      # store a proxy of tbl 
      proxy_soil <- dataTableProxy(outputId = "soil")
      
      # each time addData is pressed, add user_table to proxy
      observeEvent(eventExpr = input$addData_soil, {
        # Create Empty row
        user_table_soil <- soil() %>% 
          slice(1) %>% 
          replace(values = "")
        rownames(user_table_soil) <- dim(soil())[1] + 1
        
        #Page row will appear on 
        pg <- ceiling((dim(soil())[1] + 1)/10)
        
        # Add empty row to table
        proxy_soil %>% 
          addRow(user_table_soil) %>%
          selectPage(pg)
      }) # end add row event
      
      # When table is edited update reactive variable
      observeEvent(input$soil_cell_edit, {
        soil(editData(soil(), input$soil_cell_edit))
      }) # end Soil DT Edit
      
      ## Map of Results ---------------------------------
      output$map_holder <- renderLeaflet({
        gen_map
      }) # end map_holder
      
      ## Function to Filter Map Data
      map_cd <- reactive({
        results <-  get_mwCalc()
        results <- full_join(loc(), results, by = "Location")
        x <- input$Parameters

        # Filter Results by Chosen Parameter
        var <- case_when(
          x == "LNAPL Specific Volume" ~  "Do_m3_cm2",
          x == "Mobile LNAPL Specific Volume" ~ "Do_mobile_m3_cm2",
          x == "Average LNAPL Relative Permeability" ~ "kro_avg",
          x == "Maximum Elevation of Free LNAPL" ~ "zmax_m",
          x == "Average LNAPL Hydraulic Conductivity" ~ "KLNAPL_avg_cm_d",
          x == "Average Transmissivity" ~ "T_avg_m2_d",
          x == "LNAPL Unit Flux" ~ "ULNAPL_m2_d",
          x == "Average LNAPL Seepage Velocity" ~ "vLNAPL_avg_m_d")

        # Defining Units
        units <- case_when(
          x == "LNAPL Specific Volume" ~  "m<sup>3/cm<sup>2</sup>",
          x == "Mobile LNAPL Specific Volume" ~ "m<sup>3</sup>/cm<sup>2</sup>",
          x == "Average LNAPL Relative Permeability" ~ "",
          x == "Maximum Elevation of Free LNAPL" ~ "m",
          x == "Average LNAPL Hydraulic Conductivity" ~ "cm/d",
          x == "Average Transmissivity" ~ "m<sup>2</sup>/d",
          x == "LNAPL Unit Flux" ~ "m<sup>2</sup>/d",
          x == "Average LNAPL Seepage Velocity" ~ "m/d")

        # Defining Color
        color <- case_when(
          x == "LNAPL Specific Volume" ~  plot_col[1],
          x == "Mobile LNAPL Specific Volume" ~ plot_col[1],
          x == "Average LNAPL Relative Permeability" ~ plot_col[2],
          x == "Maximum Elevation of Free LNAPL" ~ plot_col[3],
          x == "Average LNAPL Hydraulic Conductivity" ~ plot_col[4],
          x == "Average Transmissivity" ~ plot_col[5],
          x == "LNAPL Unit Flux" ~ plot_col[6],
          x == "Average LNAPL Seepage Velocity" ~ plot_col[7])

        cd <- results %>% select(Location, Date, Latitude, Longitude, Result = !!var) %>%
          mutate(pop = paste0("Location ID: ", Location, "<br>",
                              "Date: ", Date, "<br>",
                              x, ": ", signif(Result, 3), " ", units),
                 color = color)
        cd
      })# end map_cd

      # Update Map with Results
      observeEvent({input$Parameters
        input$calculate
        },{

        cd <- map_cd()

        validate(need(dim(cd)[1] > 0, ''))

        # Remove markers
        proxy <- leafletProxy("map_holder") %>%
          clearMarkers()

        proxy <- proxy  %>%
          fitBounds(min(cd$Longitude), min(cd$Latitude), max(cd$Longitude), max(cd$Latitude)) %>%
          addCircleMarkers(data = cd, lng = ~Longitude, lat = ~Latitude,
                           layerId = ~Location, group = "Wells",
                           popup = ~pop,
                           color = "black", fillColor = ~color, radius=4, stroke = TRUE,
                           fillOpacity = 0.8, weight = .5, opacity = .8) %>%
          addHeatmap(data =cd, lng = ~Longitude, lat = ~Latitude, intensity = ~Result,
                     max = 0.05)
        proxy
        }) # end map observe event
      
      ## Download Map Button ------------------------
      output$map_export <- downloadHandler(
        filename = function(){
          paste("LNAPL_Volume_Map_", input$Parameters,".html")
        },
        content = function(con){
          
          # Get Data
          cd <- map_cd()
          
          validate(need(dim(cd)[1] > 0, ''))
          
          # Create map to export
          map <- gen_map %>%
            # fitBounds(min(cd$Longitude), min(cd$Latitude), max(cd$Longitude), max(cd$Latitude)) %>%
            addCircleMarkers(data = cd, lng = ~Longitude, lat = ~Latitude,
                             layerId = ~Location, group = "Wells",
                             popup = ~pop,
                             color = "black", fillColor = ~color, radius=4, stroke = TRUE,
                             fillOpacity = 0.8, weight = .5, opacity = .8) %>%
            addHeatmap(data =cd, lng = ~Longitude, lat = ~Latitude, intensity = ~Result,
                       max = 0.05)
          # Export Map
          saveWidget(widget = map, file = con)
        }
      )# end map_export
      
      ## Data Table of Results --------------------
      # observeEvent({input$calculate},{
      output$Model_DT <- renderDT({
        
        cd <- get_mwCalc()

        cd <- full_join(loc() %>% select("Location", "Date"), cd, by = "Location")

        # Column to highlight in table
        x <- input$Parameters

        var <- case_when(
          x == "LNAPL Specific Volume" ~  "Do_m3_cm2",
          x == "Mobile LNAPL Specific Volume" ~ "Do_mobile_m3_cm2",
          x == "Average LNAPL Relative Permeability" ~ "kro_avg",
          x == "Maximum Elevation of Free LNAPL" ~ "zmax_m",
          x == "Average LNAPL Hydraulic Conductivity" ~ "KLNAPL_avg_cm_d",
          x == "Average Transmissivity" ~ "T_avg_m2_d",
          x == "LNAPL Unit Flux" ~ "ULNAPL_m2_d",
          x == "Average LNAPL Seepage Velocity" ~ "vLNAPL_avg_m_d")

        DT::datatable(cd,
                      rownames = FALSE,
                      selection = "none",
                      fillContainer = F,
                      escape = F,
                      colnames = c('Location<br>ID', 'Date',
                                   'LNAPL Specific Volume<br>(m<sup>3</sup>/cm<sup>2</sup>)',
                                   'Mobile LNAPL Specific Volume<br>(m<sup>3</sup>/cm<sup>2</sup>)',
                                   'Avg. LNAPL Relative Permeability',
                                   'Max Elevation of Free LNAPL<br>(m)',
                                   'Avg. LNAPL Hydraulic Conductivity<br>(cm/d)',
                                   'Avg. Transmissivity (m<sup>2</sup>/d)',
                                   'LNAPL Unit Flux<br>(m<sup>2</sup>/d)',
                                   'Avg. LNAPL Seepage Velocity<br>(m/d)'),
                      options = list(paging = FALSE,
                                     searching = FALSE,
                                     scrollX = TRUE,
                                     sScrollY = '50vh', scrollCollapse = TRUE,
                                     columnDefs = list(list(className = 'dt-center', targets = "_all"))), extensions = list("Scroller")) %>%
          formatStyle(1:10, "white-space"="nowrap") %>%
          formatStyle(var, backgroundColor = "#DCDCDC") %>%
          formatSignif(3:10, digits = 3)
        
        
      })# end Model_DT
      # })
      
      ## Tier 3 -----------------------------
      ## Download pdf -----------------------
      output$download_pdf <- downloadHandler(
        filename = function(){
          paste("LNAPL_Present","pdf",sep=".")
        },
        content = function(con){
          file.copy("./www/02_LNAPL-Volume/Tier-3/A.  Tier 3 Materials_v3.pdf", con)
        }
      )# end download_data
      
    }
  )
}
      