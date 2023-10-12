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
                               includeMarkdown("./www/02_LNAPL-Volume/Tier-1/LNAPL-Volume_Tier-1-2.md")
                               ) # end column 2
                        ) # end fluid row
             ), # end Tier 1
             ### Tier 2 ------------
             tabPanel(Tier2,
                      br(),
                      fluidRow(
                        column(3, style='border-right: 1px solid black',
                               includeMarkdown("./www/02_LNAPL-Volume/Tier-2/LNAPL-Volume_Tier-2.md"),
                               br(), br()
                               ), # end column 1
                        column(3, 
                               HTML("<h3><b>Inputs:</b></h3>"),
                               fluidRow(align = "center",
                                        fluidRow(align = "center",
                                                 column(6, 
                                                        HTML("<a class='btn btn-default btn btn-default shiny-download-link shiny-bound-output button1' href='02_LNAPL-Volume/Tier-2/LNAPL_Volume_Data_Template.xlsx' target = '_blank'>Download Data Template</a>"),
                                                        br(), br()),
                                                 column(6, fileInput(ns("file"), "Choose Input File",
                                                                     multiple = F,
                                                                     accept = c("text/xlsx",
                                                                                "text/comma-separated-values,text/plain",
                                                                                ".xlsx"), width = "200px"))),
                                        fluidRow(align = "center",
                                                 column(6, 
                                                        actionButton(ns("update_inputs"), HTML("Update Input Values<br>from Input File"), style=button_style),br(),
                                                        HTML("<i>Will reset all input values.</i>")),
                                                 column(6,
                                                        downloadButton(ns("model_results"), HTML("Export Model Results and Input Tables"), style=button_style)))
                                 ), #fluid row 1
                               fluidRow(align = "center",
                                        br(), br(),
                                        numericInput(ns("water_density"),"Water Density (g/cm3)", value=1, min = 0, step = 0.1, width = '200px'),
                                        numericInput(ns("LNAPL_density"),"LNAPL Density (g/cm3)", value=0.7, min = 0, step = 0.1, width = '200px'),
                                        numericInput(ns("viscosity"),"LNAPL Viscosity (cp)", value=0.5, min = 0, width = '200px'),
                                        numericInput(ns("a_w_tension"),"Air/Water Interfacial Tension (dyn/cm)", value=70, min = 0, width = '200px'),
                                        numericInput(ns("o_w_tension"),"LNAPL/Water Interfacial Tension (dyn/cm)", value=50, min = 0, width = '200px'),
                                        numericInput(ns("a_o_tension"),"Air/LNAPL Interfacial Tension (dyn/cm)", value=25, min = 0, width = '200px'),
                                        numericInput(ns("sat_factor"),"Residual Saturation (f) Factor", value=0.2, min = 0, step = 0.1, width = '200px'),
                                        br(),
                                        HTML("<i>Click Calculate to Update Maps and Model Output</i>"),br(), br(),
                                        actionButton(ns("calculate"), "Calculate", style=button_style), br(), br(),
                                        div(style="text-align: left; padding-left: 10px;",
                                            HTML("<i><p>Note: If extreme values are entered, model may crash and the website will have to be reloaded.</p>
                                                 <p>There are assumptions that the app makes for how stratigraphy profiles should be entered and the model may fail if the input does not meet these conditions. These assumptions are:</p>
                                              <ul>
                                                <li>No overlapping stratigraphy (i.e., each layer top is equal to the bottom of the layer above).</li>
                                                <li>There are at least two stratigraphic layers at each location.</li>
                                                <li>There is at least 1 stratigraphic layer below the layer containing LNAPL.</li>
                                                <li>LNAPL thickness &gt;0 m.</li>
                                              </ul></i>
                                              "))
                                 ) #fluid row 2
                               ), # end column 2
                        column(5, style='border-left: 1px solid black',
                               tabsetPanel(id = "Outputs",
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
                                                                              "Apparent Thickness of LNAPL", 
                                                                              "Average LNAPL Conductivity",
                                                                              "Average Transmissivity",
                                                                              "LNAPL Darcy Flux", 
                                                                              "Average LNAPL Seepage Velocity"),
                                                                  selected = "LNAPL Specific Volume"))),
                                          withSpinner(leafletOutput(ns("map_holder"), height = 600)), br(),
                                          uiOutput(ns("Heatmap")), 
                                          HTML("<i>This is a relatively simple mapping system where a heat map is developed where a certain region 
                                               around each well is assigned a color based on the parameter value for this well. </i>"), br(),
                                          HTML("<h4><i>Control Parameters for Heat Map Appearance:</i></h4>"),
                                          fluidRow(
                                            column(6, align = "center", sliderInput(ns("radius"), "Radius", value = 100, min = 1, max = 100, width = '200px'),
                                                   HTML("<i>Controls the spread of the heatmap around the measured values.</i>")),
                                            column(6, align = "center", sliderInput(ns("blur"), "Blur", value = 30, min = 1, max = 30, width = '200px'),
                                                   HTML("<i>Controls the blur around each measured value.</i>"))#,
                                            # column(4, align = "center", numericInput(ns("max"), "Maximum Point Intensity", value = 0.25, min = 0.00000001, width = '200px'))
                                            )
                                          ),
                                 tabPanel("Interpolation", 
                                          br(),
                                          fluidRow(
                                            column(4, 
                                                   downloadButton(ns("map_export2"), HTML("<br>Save Map"), style=button_style)),
                                            column(8,
                                                   selectizeInput(ns("Parameters2"), "Select Parameter to View:",
                                                                  choices = c("LNAPL Specific Volume", 
                                                                              "Mobile LNAPL Specific Volume", 
                                                                              "Average LNAPL Relative Permeability",
                                                                              "Apparent Thickness of LNAPL", 
                                                                              "Average LNAPL Conductivity",
                                                                              "Average Transmissivity",
                                                                              "LNAPL Darcy Flux", 
                                                                              "Average LNAPL Seepage Velocity"),
                                                                  selected = "LNAPL Specific Volume"))),
                                          HTML("<p><i>To refine the area of interpolation use the draw tools in the upper left-hand corner to 
                                                 draw the area you want to interpolate over. To remove the shape and reset the map click 'Calculate' again. 
                                               At least <b>3 wells</b> must be present for interpolation.</i></p>"),
                                          withSpinner(leafletOutput(ns("nn_map"), height = 600)), br(),
                                          uiOutput(ns("Total_LNAPLVol")), br(),
                                          HTML("<p>For more information, or to learn how to perform your own interpolation, go to this 
                                               <a href='https://rspatial.org/raster/analysis/4-interpolation.html' target='_blank'>tutorial</a>.</p>")),
                                 tabPanel("Model Output",
                                          DTOutput(ns("Model_DT"), height = 600), br(), br())
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
      ## Reactive Values ------------------------------
      # Defining reactive variables for each input file
      loc <- reactiveVal(default_loc)
      strat <- reactiveVal(default_strat)
      soil <- reactiveVal(default_soil)
      
      # Defining reactive variable for calculations
      MW_Calcs <- reactiveVal()
      
      ## Model Calculations (python function) ------------------
      observeEvent(input$calculate,{
        
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
        
        cd <- tryCatch({mwCalc(waterDensity = input$water_density,
                               lnaplDensity = input$LNAPL_density,
                               lnaplViscosity = input$viscosity,
                               airWaterTension = input$a_w_tension,
                               lnaplWaterTension = input$o_w_tension,
                               lnaplAirTension = input$a_o_tension,
                               lnaplResidSatFact = input$sat_factor,
                               locR = loct,
                               soilR = soilt,
                               stratR = stratt)
              #when it throws an error, the following block catches the error
            }, error = function(msg){
              print("Error with Inputs")
            })

        
        #if(cd != "Error with Inputs"){
        if(cd[1] != "Error with Inputs"){ # BS modified 6/1/2023
        # Assign Variable names to list items
        for(i in 1:length(cd)){
          cd[[i]] <- as.character(cd[[i]])
          names(cd[[i]]) <- c("Do_m3_cm2", "Do_mobile_m3_cm2", "kro_avg", "zmax_m", "KLNAPL_avg_m_d", "T_avg_m2_d", "ULNAPL_m2_d", "vLNAPL_avg_m_d")
        }
        
        # Change list into DF
        cd <- map_dfr(1:length(cd), 
                      ~c(Location = names(cd[.x]),cd[[.x]]))
        cd <- cd %>%
          mutate(across(-Location, as.numeric))
        
        #Convert Units
        cd$Do_m3_m2 <- cd$Do_m3_cm2
        cd$Do_mobile_m3_m2 <- cd$Do_mobile_m3_cm2
        
        cd <- cd %>% select(Location, Do_m3_m2, Do_mobile_m3_m2, kro_avg, zmax_m, KLNAPL_avg_m_d, T_avg_m2_d, ULNAPL_m2_d, vLNAPL_avg_m_d)
        }
        MW_Calcs(cd)
        
      }) # end mwCalc
      
      ## Function to Filter Map Data
      map_cd <- reactive({
        validate(need(!is.null(MW_Calcs()), 'Click Calculate'))
        validate(need(MW_Calcs() != "Error with Inputs", 'Please Check Input Values'))
        
        results <-  MW_Calcs()
        
        results <- full_join(loc(), results, by = "Location")
        x <- input$Parameters
        
        # Filter Results by Chosen Parameter
        var <- case_when(
          x == "LNAPL Specific Volume" ~  "Do_m3_m2",
          x == "Mobile LNAPL Specific Volume" ~ "Do_mobile_m3_m2",
          x == "Average LNAPL Relative Permeability" ~ "kro_avg",
          x == "Apparent Thickness of LNAPL" ~ "zmax_m",
          x == "Average LNAPL Conductivity" ~ "KLNAPL_avg_m_d",
          x == "Average Transmissivity" ~ "T_avg_m2_d",
          x == "LNAPL Darcy Flux" ~ "ULNAPL_m2_d",
          x == "Average LNAPL Seepage Velocity" ~ "vLNAPL_avg_m_d")
        
        # Defining Units
        units <- case_when(
          x == "LNAPL Specific Volume" ~  "m<sup>3</sup>/m<sup>2</sup>",
          x == "Mobile LNAPL Specific Volume" ~ "m<sup>3</sup>/m<sup>2</sup>",
          x == "Average LNAPL Relative Permeability" ~ "",
          x == "Apparent Thickness of LNAPL" ~ "m",
          x == "Average LNAPL Conductivity" ~ "m/d",
          x == "Average Transmissivity" ~ "m<sup>2</sup>/d",
          x == "LNAPL Darcy Flux" ~ "m<sup>2</sup>/d",
          x == "Average LNAPL Seepage Velocity" ~ "m/d")
        
        # Defining Color
        color <- case_when(
          x == "LNAPL Specific Volume" ~  plot_col[1],
          x == "Mobile LNAPL Specific Volume" ~ plot_col[1],
          x == "Average LNAPL Relative Permeability" ~ plot_col[2],
          x == "Apparent Thickness of LNAPL" ~ plot_col[3],
          x == "Average LNAPL Conductivity" ~ plot_col[4],
          x == "Average Transmissivity" ~ plot_col[5],
          x == "LNAPL Darcy Flux" ~ plot_col[6],
          x == "Average LNAPL Seepage Velocity" ~ plot_col[7])
        
        cd <- results %>% select(Location, Date, Latitude, Longitude, Result = !!var) %>%
          mutate(pop = paste0("Location ID: ", Location, "<br>",
                              "Date: ", Date, "<br>",
                              x, ": ", signif(Result, 3), " ", units),
                 color = color)
        cd
      })# end map_cd
      
      ## Org Data for Nearest Neighbor -------------
      map_cd_nn <- reactive({
        
        validate(need(!is.null(MW_Calcs()), 'Click Calculate'))
        validate(need(MW_Calcs() != "Error with Inputs", 'Please Check Input Values'))
        results <-  MW_Calcs()
        results <- full_join(loc(), results, by = "Location")
        x <- input$Parameters2
        
        # Filter Results by Chosen Parameter
        var <- case_when(
          x == "LNAPL Specific Volume" ~  "Do_m3_m2",
          x == "Mobile LNAPL Specific Volume" ~ "Do_mobile_m3_m2",
          x == "Average LNAPL Relative Permeability" ~ "kro_avg",
          x == "Apparent Thickness of LNAPL" ~ "zmax_m",
          x == "Average LNAPL Conductivity" ~ "KLNAPL_avg_m_d",
          x == "Average Transmissivity" ~ "T_avg_m2_d",
          x == "LNAPL Darcy Flux" ~ "ULNAPL_m2_d",
          x == "Average LNAPL Seepage Velocity" ~ "vLNAPL_avg_m_d")
        
        # Defining Units
        units <- case_when(
          x == "LNAPL Specific Volume" ~  "m<sup>3</sup>/m<sup>2</sup>",
          x == "Mobile LNAPL Specific Volume" ~ "m<sup>3</sup>/m<sup>2</sup>",
          x == "Average LNAPL Relative Permeability" ~ "",
          x == "Apparent Thickness of LNAPL" ~ "m",
          x == "Average LNAPL Conductivity" ~ "m/d",
          x == "Average Transmissivity" ~ "m<sup>2</sup>/d",
          x == "LNAPL Darcy Flux" ~ "m<sup>2</sup>/d",
          x == "Average LNAPL Seepage Velocity" ~ "m/d")
        
        # Defining Color
        color <- case_when(
          x == "LNAPL Specific Volume" ~  plot_col[1],
          x == "Mobile LNAPL Specific Volume" ~ plot_col[1],
          x == "Average LNAPL Relative Permeability" ~ plot_col[2],
          x == "Apparent Thickness of LNAPL" ~ plot_col[3],
          x == "Average LNAPL Conductivity" ~ plot_col[4],
          x == "Average Transmissivity" ~ plot_col[5],
          x == "LNAPL Darcy Flux" ~ plot_col[6],
          x == "Average LNAPL Seepage Velocity" ~ plot_col[7])
        
        cd <- results %>% select(Location, Date, Latitude, Longitude, Result = !!var, 
                                 Do_m3_m2_fin = Do_m3_m2, 
                                 Do_mobile_m3_m2_fin = Do_mobile_m3_m2) %>%
          mutate(pop = paste0("Location ID: ", Location, "<br>",
                              "Date: ", Date, "<br>",
                              x, ": ", signif(Result, 3), " ", units),
                 color = color)
        cd
      })# end map_cd_nn
      
      ## Nearest Neighbor Polygon Calculations  ------------------------
      v_used <- reactiveVal() # save values used in map
      
      # Default intrep
      near_neigh <- reactive({
        cd <-  map_cd_nn() %>% na.omit()
        
        req(dim(cd)[1] > 3) # Need at least 3 points to do intreperlation
        
        dsp <- SpatialPoints(cd[,c("Longitude", "Latitude")], proj4string=CRS("+proj=longlat +datum=NAD83"))
        dsp <- SpatialPointsDataFrame(dsp, cd)
        
        v <- voronoi(dsp)
        
        v
      }) # end near_neigh
      
      # Intrp with Polygon
      near_neigh_poly <- reactive({
        req(input$nn_map_draw_stop)
        cd <-  map_cd_nn()  %>% na.omit()
        
        req(dim(cd)[1] > 3) # Need at least 3 points to do intreperlation
        
        feature_type <- input$nn_map_draw_new_feature$properties$feature_type
        cd <- map_cd_nn()
        coordinates <- SpatialPointsDataFrame(cd[,c("Longitude","Latitude")],cd)
        
        if(feature_type %in% c("rectangle","polygon")) {
          #get the coordinates of the polygon
          polygon_coordinates <- input$nn_map_draw_new_feature$geometry$coordinates[[1]]
          req(polygon_coordinates)
          #transform them to an sp Polygon
          drawn_polygon <- Polygon(do.call(rbind,lapply(polygon_coordinates,function(x){c(x[[1]][1],x[[2]][1])})))
          
          #use over from the sp package to identify selected cities
          selected_wells <- coordinates %over% SpatialPolygons(list(Polygons(list(drawn_polygon),"drawn_polygon")))
          
          cd <- cd[which(!is.na(selected_wells)),]
          
          dsp <- SpatialPoints(cd[,c("Longitude", "Latitude")], proj4string=CRS("+proj=longlat +datum=NAD83"))
          dsp <- SpatialPointsDataFrame(dsp, cd)
          
          v <- voronoi(dsp)
          v <- intersect(v,aggregate(SpatialPolygons(list(Polygons(list(drawn_polygon),"drawn_polygon")))))
          v
        }
      }) # end near_neigh_poly
      
      ## Download Parameter Selection Guide ------------------------
      output$download_user_manual <- downloadHandler(
        filename = function(){
          paste("LDRM_User-and-Parameter-Selection-Guide","pdf",sep=".")
        },
        content = function(con){
          file.copy("./www/02_LNAPL-Volume/Tier-2/LDRM_User_Manual.pdf", con)
        }
      )# end download_data
      
      ## Download Model Example ------------------------
      output$download_ex <- downloadHandler(
        filename = function(){
          paste("LNAPL_Volume_and_Extent_Model_Example","pdf",sep=".")
        },
        content = function(con){
          file.copy("./www/02_LNAPL-Volume/Tier-2/LNAPL_Volume_and_Extent_Model_Example.pdf", con)
        }
      )# end download_data
      
      ## Download Model Example ------------------------
      output$download_soil_class <- downloadHandler(
        filename = function(){
          paste("Soil-Classification","pdf",sep=".")
        },
        content = function(con){
          file.copy("./www/02_LNAPL-Volume/Tier-2/Soil-Classification.pdf", con)
        }
      )# end download_data

      ## Export Model Results ---------------------------
      output$model_results <- downloadHandler(
        filename = function(){
          paste("LNAPL_Volume_Model_Results","xlsx",sep=".")
        },

        content = function(con){
          # Model Results
          cd <- MW_Calcs()
          validate(need(cd != "Error with Inputs", 'Please Check Input Values'))

          cd <- full_join(loc() %>% select("Location", "Date"), cd, by = "Location")

          colnames(cd) <- c('Monitoring Well', 'Date',
                            'LNAPL Specific Volume (m3/m2)',
                            'Mobile LNAPL Specific Volume (m3/cm2)',
                            'Avg. LNAPL Relative Permeability',
                            'Apparent Thickness of LNAPL (m)',
                            'Avg. LNAPL Conductivity (m/d)',
                            'Avg. Transmissivity (m2/d)',
                            'LNAPL Darcy Flux (m2/d)',
                            'Avg. LNAPL Seepage Velocity (m/d)')


          # Create empty excel file
          wb <- createWorkbook()

          # Add Results Tab
          addWorksheet(wb, "Model_Results")
          writeData(wb, sheet = "Model_Results", x = cd, startCol = 1, startRow = 1, colNames = T)

          # Add Location_Information Tab
          cd <- loc()
          colnames(cd) <- c("Monitoring Well",
                            "Date", "Latitude", "Longitude",
                            "LNAPL Top Depth Below Ground Surface (m)",
                            "LNAPL Bottom Depth Below Ground Surface (m)",
                            "LNAPL Gradient (m/m)")

          addWorksheet(wb, "Location_Information")
          writeData(wb, sheet = "Location_Information", x = cd, startCol = 1, startRow = 1, colNames = T)

          # Add Stratigraphy Tab
          cd <- strat()
          colnames(cd) <- c("Monitoring Well",
                            "Layer Top Depth Below Ground Surface (m)",
                            "Layer Bottom Depth Below Ground Surface (m)",
                            "Soil Type")

          addWorksheet(wb, "Stratigraphy")
          writeData(wb, sheet = "Stratigraphy", x = cd, startCol = 1, startRow = 1, colNames = T)

          # Add Soil_Types Tab
          cd <- soil()
          colnames(cd) <- c("Soil Num", "Soil_Type", "Porosity", "Ks (m/d)", "Theta_wr", "N", "alpha (1/m)", "M")

          addWorksheet(wb, "Soil_Types")
          writeData(wb, sheet = "Soil_Types", x = cd, startCol = 1, startRow = 2, colNames = T)
          writeData(wb, sheet = "Soil_Types", x = "van Genuchten Parameters", startCol = 6, startRow = 1, colNames = T)
          writeData(wb, sheet = "Soil_Types", x = "Soil Types", startCol = 1, startRow = 1, colNames = T)
          mergeCells(wb, sheet = "Soil_Types", cols = 6:8, rows = 1)
          mergeCells(wb, sheet = "Soil_Types", cols = 1:5, rows = 1)

          # Add Parameters Tab
          x <- data.frame(c("Water Density (g/cm3)", input$water_density),
                          c("LNAPL Density (g/cm3)", input$LNAPL_density),
                          c("LNAPL Viscosity (cp)", input$viscosity),
                          c("Air/Water Interfacial Tension (dyn/cm)", input$a_w_tension),
                          c("LNAPL/Water Interfacial Tension (dyn/cm)", input$o_w_tension),
                          c("Air/LNAPL Interfacial Tension (dyn/cm)", input$a_o_tension),
                          c("Residual Saturation (f) Factor", input$sat_factor))

          addWorksheet(wb, "Parameters")
          writeData(wb, sheet = "Parameters", x = x, startCol = 1, startRow = 1, colNames = F)

          saveWorkbook(wb, con)
        }
      )# end model_results

      ## Update Input Button ----------------------------
      # update_inputs Button (updates DT and input variables)
      observeEvent(input$update_inputs,{

        # If no file is loaded use deaf
        if(!is.null(input$file)){
          file <- input$file
          
          # Organize Location Information
          loc <- read_xlsx(file$datapath, sheet = "Location_Information", range = cell_cols("A:G"),
                           col_types = c("text", "text", "numeric", "numeric", "numeric", "numeric", "numeric")) %>%
            select(Location = `Monitoring Well`,
                   Date, Latitude, Longitude,
                   LNAPL_Top_Depth_m = `LNAPL Top Depth Below Ground Surface (m)`,
                   LNAPL_Bottom_Depth_m = `LNAPL Bottom Depth Below Ground Surface (m)`,
                   LNAPL_Gradient = `LNAPL Gradient (m/m)`) %>%
            filter(Location != "Add additional rows as needed.") %>%
            mutate(Date = as.character(Date))
          
          # Organize Stratigraphy
          strat <- read_xlsx(file$datapath, sheet = "Stratigraphy", range = cell_cols("A:D"),
                             col_types = c("text", "numeric", "numeric", "text")) %>%
            select(Location = `Monitoring Well`,
                   Layer_Top_Depth_m = `Layer Top Depth Below Ground Surface (m)`,
                   Layer_Bottom_Depth_m = `Layer Bottom Depth Below Ground Surface (m)`,
                   Soil_Type = `Soil Type`) %>%
            filter(Location != "Add additional rows as needed.")
          
          # Organize Soil_Types
          soil <- read_xlsx(file$datapath, sheet = "Soil_Types", range = cell_cols("A:H"),
                            col_types = c("text", "text", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric")) %>%
            na.omit() %>%
            select(Soil_Num = 1, Soil_Type = 2, Porosity = 3, `Ks_m-d` = 4, Theta_wr = 5, N = 6, alpha_m = 7, M = 8) %>% 
            mutate(Soil_Num = as.numeric(Soil_Num))
          
          # Organize Parameters
          par <- read_xlsx(file$datapath, sheet = "Parameters", col_types = "numeric") %>%
            select(water_den_gcm3 = `Water Density (g/cm3)`, LNAPL_den_gcm3 = `LNAPL Density (g/cm3)`, LNAPL_vis_cp = `LNAPL Viscosity (cp)`,
                   air_water_ten_dcm = `Air/Water Interfacial Tension (dyn/cm)`, LNAPL_water_ten_dcm = `LNAPL/Water Interfacial Tension (dyn/cm)`,
                   air_LNAPL_ten_dcm = `Air/LNAPL Interfacial Tension (dyn/cm)`, res_sat = `Residual Saturation (f) Factor`)
          
          data_output <- list(loc = loc, strat = strat, soil = soil, para = par)

          # Update Tables
          loc(data_output[["loc"]])
          strat(data_output[["strat"]])
          soil(data_output[["soil"]])

          # Update Parameters
          para_x <- data_output[["para"]]

          updateNumericInput(session = session, "water_density", value = para_x$water_den_gcm3)
          updateNumericInput(session = session, "LNAPL_density", value = para_x$LNAPL_den_gcm3)
          updateNumericInput(session = session, "viscosity", value = para_x$LNAPL_vis_cp)
          updateNumericInput(session = session, "a_w_tension", value = para_x$air_water_ten_dcm)
          updateNumericInput(session = session, "o_w_tension", value = para_x$LNAPL_water_ten_dcm)
          updateNumericInput(session = session, "a_o_tension", value = para_x$air_LNAPL_ten_dcm)
          updateNumericInput(session = session, "sat_factor", value = para_x$res_sat)

        }
      }) # end update_inputs button
      
      ## Data Table: Location Info ----------------
      # Create Location Table
      output$loc_info <- renderDT(loc(), server = FALSE, editable = TRUE, selection = "none",
                                  colnames = c("Location", "Date", "Latitude", "Longitude", "LNAPL Top Depth (m)", "LNAPL Bottom Depth (m)", "LNAPL Gradient"),
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
                               colnames = c("Location", "Layer Top Depth (m)", "Layer Bottom Depth (m)", "Soil Type"),
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
        gen_map %>%
          addLayersControl(baseGroups = c('Base','Roads (Google)','Topo (ESRI)','Topo (Google)','Satellite (ESRI)','Satellite (Google)','Hybrid (Google)'),
                           overlayGroups = c("Wells"),
                           position = "bottomleft",
                           options = layersControlOptions(collapsed = FALSE)) 
      }) # end map_holder
      
      # Update Map with Results
      observeEvent({
        input$Parameters
        input$calculate
        input$radius
        # input$max
        input$blur
        },{
          # Remove markers
          proxy <- leafletProxy("map_holder") %>%
            clearMarkers() %>%
            removeControl(layerId = "Legend") %>%
            clearGroup("heatmap")

          cd <- map_cd() %>% na.omit()

          validate(need(dim(cd)[1] > 0, ''))
          validate(need(input$radius > 0, ''))
          # validate(need(input$max > 0, ''))
          validate(need(input$blur >= 1, ''))
          
          x <- input$Parameters
            
          # Defining Units
          units <- case_when(
            x == "LNAPL Specific Volume" ~  "(m<sup>3</sup>/m<sup>2</sup>)",
            x == "Mobile LNAPL Specific Volume" ~ "(m<sup>3</sup>/m<sup>2</sup>)",
            x == "Average LNAPL Relative Permeability" ~ "",
            x == "Apparent Thickness of LNAPL" ~ "(m)",
            x == "Average LNAPL Conductivity" ~ "(m/d)",
            x == "Average Transmissivity" ~ "(m<sup>2</sup>/d)",
            x == "LNAPL Darcy Flux" ~ "(m<sup>2</sup>/d)",
            x == "Average LNAPL Seepage Velocity" ~ "(m/d)")
          
          
          pal <- colorNumeric("viridis", cd$Result,
                              na.color = "transparent")
          
          proxy <- proxy  %>%
            fitBounds(min(cd$Longitude), min(cd$Latitude), max(cd$Longitude), max(cd$Latitude)) %>%
            addCircleMarkers(data = cd, lng = ~Longitude, lat = ~Latitude,
                             layerId = ~Location, group = "Wells",
                             popup = ~pop,
                             color = "black", fillColor = ~color, radius=4, stroke = TRUE,
                             fillOpacity = 0.8, weight = .5, opacity = .8) %>%
            addHeatmap(data =cd, lng = ~Longitude, lat = ~Latitude, minOpacity = min(cd$Result, na.rm = T), 
                       intensity = ~Result, gradient = "viridis",
                       max = max(cd$Result, na.rm = T), blur = input$blur, radius = input$radius, group = "heatmap") %>%
            addLegend("bottomright", pal = pal, values = cd$Result,
                      title = gsub("\n", "<br>", paste(str_wrap(input$Parameters, 20), units)), 
                      opacity = 0.6, layerId = "Legend")
          
          proxy

        }) # end map observe event

      ## Download Map Button ------------------------
      output$map_export <- downloadHandler(
        filename = function(){
          paste("LNAPL_Volume_Map_", input$Parameters,".html")
        },
        content = function(con){

          # Get Data
          cd <- map_cd() %>% na.omit()

          validate(need(dim(cd)[1] > 0, ''))
          validate(need(input$radius > 0, ''))
          # validate(need(input$max > 0, ''))
          validate(need(input$blur >= 1, ''))
          
          x <- input$Parameters
          
          # Defining Units
          units <- case_when(
            x == "LNAPL Specific Volume" ~  "(m<sup>3</sup>/m<sup>2</sup>)",
            x == "Mobile LNAPL Specific Volume" ~ "(m<sup>3</sup>/m<sup>2</sup>)",
            x == "Average LNAPL Relative Permeability" ~ "",
            x == "Apparent Thickness of LNAPL" ~ "(m)",
            x == "Average LNAPL Conductivity" ~ "(m/d)",
            x == "Average Transmissivity" ~ "(m<sup>2</sup>/d)",
            x == "LNAPL Darcy Flux" ~ "(m<sup>2</sup>/d)",
            x == "Average LNAPL Seepage Velocity" ~ "(m/d)")

          pal <- colorNumeric(palette = "viridis", cd$Result,
                              na.color = "transparent")

          # Create map to export
          map <- gen_map %>%
            addCircleMarkers(data = cd, lng = ~Longitude, lat = ~Latitude,
                             layerId = ~Location, group = "Wells",
                             popup = ~pop,
                             color = "black", fillColor = ~color, radius=4, stroke = TRUE,
                             fillOpacity = 0.8, weight = .5, opacity = .8) %>%
            addHeatmap(data =cd, lng = ~Longitude, lat = ~Latitude, minOpacity = min(cd$Result, na.rm = T), 
                       intensity = ~Result, gradient = "viridis",
                       max = max(cd$Result, na.rm = T), blur = input$blur, radius = input$radius, group = "heatmap") %>%
            addLegend("bottomright", pal = pal, values = cd$Result,
                      title = gsub("\n", "<br>", paste(str_wrap(input$Parameters, 20), units)), 
                      opacity = 0.6, layerId = "Legend")%>%
            addLayersControl(baseGroups = c('Base','Roads (Google)','Topo (ESRI)','Topo (Google)','Satellite (ESRI)','Satellite (Google)','Hybrid (Google)'),
                             overlayGroups = c("Wells"),
                             position = "bottomleft",
                             options = layersControlOptions(collapsed = FALSE)) 
          # Export Map
          saveWidget(widget = map, file = con)
        }
      )# end map_export
      
      ## Loading Message for Heatmap -------------
      output$Heatmap <- renderUI({
        validate(need(!is.null(MW_Calcs()), 'Click Calculate'))
        validate(need(MW_Calcs() != "Error with Inputs", 'Please Check Input Values'))
      }) # end Heatmap

      ## Map of Nearest Neighbors ------------------
      output$nn_map <- renderLeaflet({
        gen_map %>%
          addDrawToolbar(targetGroup='Drawn Shape', polylineOptions=FALSE, markerOptions = FALSE, circleMarkerOptions = FALSE,
                         circleOptions = FALSE, singleFeature = T, editOptions = editToolbarOptions(selectedPathOptions = selectedPathOptions())) %>%
          addLayersControl(baseGroups = c('Base','Roads (Google)','Topo (ESRI)','Topo (Google)','Satellite (ESRI)','Satellite (Google)','Hybrid (Google)'),
                           overlayGroups = c("Wells", "Drawn Shape"),
                           position = "bottomleft",
                           options = layersControlOptions(collapsed = FALSE)) %>%
          addMeasure() %>%
          hideGroup(group = "Drawn Shape")
      }) # end nn_map


      observeEvent({
        input$Parameters2
        input$calculate
      },{
        
    
        # Remove markers
        proxy <- leafletProxy("nn_map") %>%
          clearMarkers() %>%
          removeControl(layerId = "Legend") %>%
          clearGroup(group = "image")
        
        cd <- map_cd_nn() %>% na.omit()
        print(dim(cd)[1])
        req(dim(cd)[1] > 3)
        
        nnmsk <- near_neigh()
        req(nnmsk)
        
        pal <- colorNumeric(palette = "viridis", nnmsk$Result,
                            na.color = "transparent")

        nnmsk$colors <- pal(nnmsk$Result)
        
        x <- input$Parameters2
        
        # Defining Units
        units <- case_when(
          x == "LNAPL Specific Volume" ~  "(m<sup>3</sup>/m<sup>2</sup>)",
          x == "Mobile LNAPL Specific Volume" ~ "(m<sup>3</sup>/m<sup>2</sup>)",
          x == "Average LNAPL Relative Permeability" ~ "",
          x == "Apparent Thickness of LNAPL" ~ "(m)",
          x == "Average LNAPL Conductivity" ~ "(m/d)",
          x == "Average Transmissivity" ~ "(m<sup>2</sup>/d)",
          x == "LNAPL Darcy Flux" ~ "(m<sup>2</sup>/d)",
          x == "Average LNAPL Seepage Velocity" ~ "(m/d)")

        proxy <- proxy  %>%
          fitBounds(min(cd$Longitude), min(cd$Latitude), max(cd$Longitude), max(cd$Latitude)) %>%
          addCircleMarkers(data = cd, lng = ~Longitude, lat = ~Latitude,
                           layerId = ~Location, group = "Wells",
                           popup = ~pop,
                           color = "black", fillColor = ~color, radius=4, stroke = TRUE,
                           fillOpacity = 0.8, weight = .5, opacity = .8, options = pathOptions(pane = "markers")) %>%
          addFeatures(nnmsk, weight = 1, color = "black", fillColor = ~colors, group = "image") %>%
          addLegend("bottomright", pal = pal, values = nnmsk$Result,
                    title = gsub("\n", "<br>", paste(str_wrap(input$Parameters2, 20), units)), 
                    layerId = "Legend")

        proxy
        
        v_used(nnmsk) # Save value for vol calcs
      }) # end map observe event
      
      ## Draw Polygon ------
      observe({
        req(input$nn_map_draw_stop)
        
        proxy <- leafletProxy("nn_map") %>%
          clearGroup(group = "image")
        
        v <- near_neigh_poly()
        
        pal <- colorNumeric("viridis", v$Result,
                            na.color = "transparent")
        
        v$colors <- pal(v$Result)
        proxy <- proxy  %>%
          addFeatures(v, weight = 1, color = "black", fillColor = ~colors, group = "image")
        
        proxy
        v_used(v) # Save value for vol calcs
      })

      ## Calculate Total LNAPL Volumes -------------
      output$Total_LNAPLVol <- renderUI({
        validate(need(!is.null(MW_Calcs()), 'Click Calculate'))
        validate(need(MW_Calcs() != "Error with Inputs", 'Please Check Input Values'))
        cd <-  MW_Calcs()
        cd <- full_join(loc(), cd, by = "Location") %>% na.omit()
        validate(need(dim(cd)[1] > 3, 'Not enought Data to Interpolate'))
        
        v <- v_used()
        req(v)

        v@data$Area <- area(v)
        total_area <- sum(v@data$Area)
        Vol <- sum(v@data$Do_m3_m2_fin * (v@data$Area), na.rm = T)
        Vol_Mobile <- sum(v@data$Do_mobile_m3_m2_fin* (v@data$Area), na.rm = T)

        HTML(paste0("<h3>Total Area: ", formatC(round(total_area, 0), digits = 0, format = "f", big.mark = ","), " m<sup>2</sup><br><br>",
                    "LNAPL Volume: ", formatC(round(Vol*1000, 0), digits = 0, format = "f", big.mark = ","), " L<br><br>
                    Recoverable LNAPL Volume: ", formatC(round(Vol_Mobile * 1000, 0), digits = 0, format = "f", big.mark = ","), " L</h3>"))

      }) # end Total_LNAPLVol

      ## Export Interpolation Map ------------------
      output$map_export2 <- downloadHandler(
        filename = function(){
          paste("LNAPL_Volume_Inter-Map_", input$Parameters2,".html")
        },
        content = function(con){

          # Get Data
          validate(need(!is.null(MW_Calcs()), 'Click Calculate'))
          validate(need(MW_Calcs() != "Error with Inputs", 'Please Check Input Values'))
          nnmsk <- v_used() %>% na.omit()
          cd <- map_cd_nn() %>% na.omit()

          pal <- colorNumeric("viridis", nnmsk$Result,
                              na.color = "transparent")
          
          x <- input$Parameters
          
          # Defining Units
          units <- case_when(
            x == "LNAPL Specific Volume" ~  "(m<sup>3</sup>/m<sup>2</sup>)",
            x == "Mobile LNAPL Specific Volume" ~ "(m<sup>3</sup>/m<sup>2</sup>)",
            x == "Average LNAPL Relative Permeability" ~ "",
            x == "Apparent Thickness of LNAPL" ~ "(m)",
            x == "Average LNAPL Conductivity" ~ "(m/d)",
            x == "Average Transmissivity" ~ "(m<sup>2</sup>/d)",
            x == "LNAPL Darcy Flux" ~ "(m<sup>2</sup>/d)",
            x == "Average LNAPL Seepage Velocity" ~ "(m/d)")

          nnmsk$colors <- pal(nnmsk$Result)

          # Remove markers
          proxy <- leafletProxy("nn_map") %>%
            clearMarkers() %>%
            removeControl(layerId = "Legend") %>%
            clearGroup(group = "image")

          map <- gen_map %>%
            fitBounds(min(cd$Longitude), min(cd$Latitude), max(cd$Longitude), max(cd$Latitude)) %>%
            addCircleMarkers(data = cd, lng = ~Longitude, lat = ~Latitude,
                             layerId = ~Location, group = "Wells",
                             popup = ~pop,
                             color = "black", fillColor = ~color, radius=4, stroke = TRUE,
                             fillOpacity = 0.8, weight = .5, opacity = .8, options = pathOptions(pane = "markers")) %>%
            addFeatures(nnmsk, weight = 1, color = "black", fillColor = ~colors, group = "image") %>%
            addLegend("bottomright", pal = pal, values = nnmsk$Result,
                      title = gsub("\n", "<br>", paste(str_wrap(input$Parameters2, 20), units)), 
                      layerId = "Legend")%>%
            addLayersControl(baseGroups = c('Base','Roads (Google)','Topo (ESRI)','Topo (Google)','Satellite (ESRI)','Satellite (Google)','Hybrid (Google)'),
                             overlayGroups = c("Wells"),
                             position = "bottomleft",
                             options = layersControlOptions(collapsed = FALSE))
          

          # Export Map
          saveWidget(widget = map, file = con)
        }
      )# end map_export

      ## Data Table of Results --------------------
      observeEvent({input$calculate},{
      output$Model_DT <- renderDT({
        
        validate(need(!is.null(MW_Calcs()), 'Click Calculate'))
        validate(need(MW_Calcs() != "Error with Inputs", 'Please Check Input Values'))

        cd <- MW_Calcs()

        cd <- full_join(loc() %>% select("Location", "Date"), cd, by = "Location")

        # Column to highlight in table
        x <- input$Parameters

        var <- case_when(
          x == "LNAPL Specific Volume" ~  "Do_m3_m2",
          x == "Mobile LNAPL Specific Volume" ~ "Do_mobile_m3_m2",
          x == "Average LNAPL Relative Permeability" ~ "kro_avg",
          x == "Apparent Thickness of LNAPL" ~ "zmax_m",
          x == "Average LNAPL Conductivity" ~ "KLNAPL_avg_m_d",
          x == "Average Transmissivity" ~ "T_avg_m2_d",
          x == "LNAPL Darcy Flux" ~ "ULNAPL_m2_d",
          x == "Average LNAPL Seepage Velocity" ~ "vLNAPL_avg_m_d")

        DT::datatable(cd,
                      rownames = FALSE,
                      selection = "none",
                      fillContainer = F,
                      escape = F,
                      colnames = c('Location<br>ID', 'Date',
                                   'LNAPL Specific Volume<br>(m<sup>3</sup>/m<sup>2</sup>)',
                                   'Mobile LNAPL Specific Volume<br>(m<sup>3</sup>/m<sup>2</sup>)',
                                   'Avg. LNAPL Relative Permeability',
                                   'Apparent Thickness of LNAPL<br>(m)',
                                   'Avg. LNAPL Conductivity<br>(m/d)',
                                   'Avg. Transmissivity (m<sup>2</sup>/d)',
                                   'LNAPL Darcy Flux<br>(m<sup>2</sup>/d)',
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
      })

    }
  )
}

      