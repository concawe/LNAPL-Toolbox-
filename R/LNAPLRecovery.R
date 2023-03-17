## LNAPL Recovery Modules -----------------------------

## UI Module ------------------------------------------
LNAPLRecoveryUI <- function(id, label = "LNAPL Recovery"){
  ns <- NS(id)
  
  tabPanel("LNAPL Recovery",
           tags$i(h1("Will LNAPL recovery be effective?")),
           tabsetPanel(
             ### Tier 1 -----------------------
             tabPanel(Tier1,
                      fluidRow(
                        br(),
                        column(5,
                               includeMarkdown("www/06_LNAPL-Recovery/Tier_1/LNAPL-Recovery_Tier-1.md")),
                        column(7,
                               includeHTML("www/06_LNAPL-Recovery/Tier_1/LNAPL-Recovery_Tier-1-2.html")))
             ),
             ### Tier 2 ------------------------
             tabPanel(Tier2,
                      tabsetPanel(
                        tabPanel(HTML("<i>LNAPL Model</i>"),
                                 br(),
                                 includeHTML("./www/06_LNAPL-Recovery/Tier_2/LNAPL-Recovery_Tier-2-1.html"),
                                 br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br()
                        ), # LNAPL Model
                        tabPanel(HTML("<i>LNAPL Transmissivity Calculator</i>"),
                                 br(),
                                 fluidRow(
                                   column(4, style='border-right: 1px solid black',
                                          includeMarkdown("www/06_LNAPL-Recovery/Tier_2/LNAPL-Recovery_Tier-2-2.md"),
                                          br(), br()
                                   ), # end column 1
                                   column(3, 
                                          HTML("<h3><b>Inputs:</b></h3>"),
                                          selectizeInput(ns("soil_type"),"Soil Type", 
                                                         choices = c("clay", "clay loam", "loam", "loamy sand", "silt",
                                                                     "silt loam", "silty clay", "silty clay loam", "sand",
                                                                     "sandy clay","sandy clay loam","sandy loam","clayey sand",
                                                                     "clayey silt","fill","gravel",
                                                                     "sandy silt","silty sand"),
                                                         selected = "silt"),
                                          selectizeInput(ns("LNAPL"),"LNAPL Type",
                                                         choices = c("crude oil", "gasoline", "diesel/kerosene/jetfuel", "heavy fuel oil"),
                                                         selected = "gasoline"),
                                          numericInput(ns("thickness"),"Thickness of LNAPL in Well (m)", value = 0.8),
                                          numericInput(ns("delta_thickness"),"LNAPL Gradient (m/m)", value = 0.01),
                                          HTML("<i>Note: LNAPL Gradient only affects results for LNAPL Darcy Flux and LNAPL Average Seepage Velocity.</i>")
                                   ), # end column 2
                                   column(5, style='border-left: 1px solid black',
                                          gt_output(ns("calc_output")),
                                          br(), br(),
                                          gt_output(ns("calc_output2")),
                                          br(), br()
                                   )# end column 3
                                   )# fluid row
                                 )# end Darcy Calc
                        )
             ), #tier 2 tabpanel
             ### Tier 3 ------------------------------
             tabPanel(Tier3,
                      br(),
                      fluidRow(
                        column(2,), 
                        column(8, 
                               # Markdown Text
                               br(),
                               includeMarkdown("./www/06_LNAPL-Recovery/Tier_3/LNAPL-Recovery_Tier-3.md"),
                               br(), br()
                        ), # end column 1
                        column(2,
                        ) # end column 2
                      ) # end fluid row 
           ))
  )
            
} # LNAPL Recovery UI

## Server -------------------------------------
LNAPLRecoveryServer <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {
      ### Darcy Calc Function ---------------
      darcy_get <- reactive({
        req(input$soil_type,
            input$LNAPL,
            input$thickness,
            input$delta_thickness)
        
        validate(need(!is.na(input$thickness) & input$thickness > 0, 
                      "Thickness of LNAPL in Well is invalid! Calculated results should be discarded. Please try again..."))
        validate(need(!is.na(input$delta_thickness) & input$delta_thickness > 0, 
                      "Change in LNAPL Elevation is invalid! Calculated results should be discarded. Please try again..."))
        
        LNAPL <- ifelse(input$LNAPL == "crude oil", "crude_oil", input$LNAPL)
        LNAPL <- ifelse(LNAPL == "heavy fuel oil", "heavy_fuel_oil", LNAPL)
        
        cd <- darcyCalc(input$soil_type, LNAPL, input$thickness, input$delta_thickness)
        
        cd
      }) # end dary_get
      
      ## Results Table 1 ---------------------
      output$calc_output <- render_gt({
        # Get Values
        cd <- darcy_get()
        # cd <- darcyCalc("silt","gasoline",10,0.001)
        values <- as.numeric(as.data.frame(cd)$Tn)
        
        cd <- data.frame(Parameters = c('LNAPL Transmissivity (m<sup>2</sup>/d)', 
                                        "Key threshold for LNAPL recoverability:  LNAPL Transmissivity above this range (numbers <i>within</i> this range are in a grey zone for recoverability)"), 
                         Values = c(formatC(values, digits = 2, big.mark = ",", format = "G"), 
                                    "0.0093 to 0.074 m<sup>2</sup>/day "))
        
        # Create Table
        cd %>% gt() %>% 
          tab_header("Calculated LNAPL Transmissivity") %>%
          # fmt_scientific(columns = 2, rows = 1, decimals = 2) %>%
          fmt_markdown(columns = vars("Parameters", "Values")) %>%  
          tab_style(style = list(cell_text(style = "italic")),
                    locations = cells_column_labels(columns = everything())) %>%
          tab_style(style = list(cell_text(weight = "bold")),
                    locations = list(cells_title(group = "title"), 
                                     cells_body(rows = 1, columns = everything()))) %>%
          opt_table_outline()
      }) # end calc_output table
      
      
      ## Results Table 2 ---------------------
      output$calc_output2 <- render_gt({
        # Get Values
        cd <- darcy_get()
        # cd <- darcyCalc("silt","gasoline",10,0.001)
        values <- as.numeric(t((as.data.frame(cd) %>% select(-Tn, -den_r, -vg_M)))[,1])
        
        parameters <- c('Thickness of Formation Containing LNAPL (m)',
                        'Height of LNAPL/<br>Air Interface above Water (m)',
                        'LNAPL Specific Volume (m<sup>3</sup>/m<sup>2</sup>)',
                        'LNAPL Mobile Specific Volume (m<sup>3</sup>/m<sup>3</sup>)',
                        'LNAPL Average Relative Permeability (unitless)',
                        'LNAPL Average Conductivity (m/d)',
                        'LNAPL Darcy Flux (m/d)',
                        'Average LNAPL Volumetric Content (unitless)',
                        'LNAPL Average Seepage Velocity (m/d)')
        
        cd <- data.frame(Parameters = parameters, Values = formatC(values, digits = 2, big.mark = ",", format = "G"))

        # Create Table
        cd %>% gt() %>%
          tab_header("Additional Results from Calculator") %>%
          # fmt_scientific(columns = vars("Values"), decimals = 2) %>%
          fmt_markdown(columns = vars("Parameters")) %>%
          tab_style(style = list(cell_text(style = "italic")),
                    locations = cells_column_labels(columns = everything())) %>%
          tab_style(style = list(cell_text(weight = "bold")),
                    locations = cells_title(group = "title")) %>%
          opt_table_outline()
      }) # end calc_output2 table
    }
  )
} # end LNAPLRecoveryServer