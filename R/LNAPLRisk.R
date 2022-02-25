## LNAPL Risk Modules -----------------------------

## UI Module --------------------------------------
LNAPLRiskUI <- function(id, label = "LNAPL Risk"){
  ns <- NS(id)
  
  tabPanel("LNAPL Risk",
           tags$i(h1("How will LNAPL risk change over time?")),
           tabsetPanel(
             ### Tier 1 -------------------
             tabPanel(Tier1,
                      br(),
                      fluidRow(
                        column(1),
                        column(10,
                               # Text
                               includeMarkdown("www/05_LNAPL-Risk/Tier_1/LNAPL-Risk_Tier-1.md"),
                               fluidRow(align = "center",
                                        # Table 1
                                        br(), br(),
                                        gt_output(ns("Table_1")),
                                        br(), br(),
                                        # Table 2
                                        HTML("<h3><b> Entire LNAPL Composition (Mass Fraction) Dataset from Johnson et al. (1990) 
                                             Used in Hypothetical Example Above  </b></h3>"),
                                        DTOutput(ns("Table_2")),
                                        br(), br()
                               )), # end column 1
                        column(1)
                        ) # end fluid row
                      ),# end Tier 1
             ### Tier 2 ---------------------
             tabPanel(Tier2,
                      br(),
                      fluidRow(
                        column(4, style='border-right: 1px solid black',
                               includeMarkdown("www/05_LNAPL-Risk/Tier_2/LNAPL-Risk_Tier-2.md"),
                               br(), br()
                        ), # end column 1
                        column(2, style='border-right: 1px solid black',
                               HTML("<h3><b>Model Inputs:</b></h3>"),
                               numericInput(ns("K"),"Hydraulic Conductivity (cm/s)", value = 0.01, min = 0, step = 0.1),
                               numericInput(ns("h"),"Hydraulic Gradient (m/m)", value = 0.005, min = 0, step = 0.001),
                               numericInput(ns("W"),"Width of LNAPL Lens (m)", value = 50, min = 0),
                               numericInput(ns("thick"), "Average Thickness of LNAPL Lens (m)", value = 0.5, min = 0, step = 0.1),
                               # numericInput(ns("den"), HTML("Density of LNAPL (g/cm<sup>3</sup>)"), value = 0.78, min = 0, max = 1, step = 0.1),
                               numericInput(ns("time"), "Time Step (days)", value = 0.1, min = 0),
                               numericInput(ns("Vol"), HTML("LNAPL Body Volume (Liters)"), value = 1000, min = 0, step = 1),
                               numericInput(ns("len"), "Length of Simulation (years)", value = 10, min = 0, step = 1),
                               fluidRow(align = "center",
                                        br(),
                                        HTML("<i>Click Calculate to Update Plot</i>"),br(), br(),
                                        actionButton(ns("calc"), label = "Calculate", style=button_style),
                                        br(), br(),
                                        HTML("<i> Note: If the calculated solution appears to be unstable try reducing the model time step. </i>"))
                        ), # end column 2
                        column(6,
                               HTML("<h3><b>LNAPL Constituents Chemistry Inputs:</b></h3>"),
                               DTOutput(ns("LNAPL_info")),
                               HTML("<i>Add up to 5 constituents. Double click to edit</i>"),
                               br(),br(),
                               fluidRow(align = "center", style='padding: 10px 10px 10px 10px;',
                                        plotlyOutput(ns("Time_const_Plot")),
                                        fluidRow(align = "left", style='padding: 10px 10px 10px 50px;',
                                                 checkboxInput(ns("log_scale"), label = "Y-Axis Log Scale", value = F)))
                        ) # end column 3
                      ) # end fluid row
             ), # end Tier 2
             ### Tier 3 -------------------------
             tabPanel(Tier3,
                      br(),
                      fluidRow(
                        column(2,), 
                        column(8, 
                               # Markdown Text
                               br(),
                               includeMarkdown("./www/05_LNAPL-Risk/Tier_3/LNAPL-Risk_Tier-3.md"),
                               br(), br()
                        ), # end column 1
                        column(2,) # end column 2
                      ) # end fluid row 
                      ) # end Tier 3
             )
           )
} # LNAPL Risk UI

## Server Module ---------------------------------------------------

LNAPLRiskServer <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {
      
      # Tier 1 ---------------
      ## Table 1 -------------
      output$Table_1 <- render_gt(
        LNAPLRisk_Table1
      ) # end Table_1
      
      ## Table 2 -------------
      output$Table_2 <- renderDT(
        
        datatable(LNAPLRisk_Table2 %>% select(-Approximate.Composition),
                  colnames = c("Compound Name", "Mw (g)", "Fresh Gasoline", "Weathered Gasoline"),
                  rownames = FALSE, escape = FALSE, 
                  options = list(
                    paging =TRUE,
                    pageLength = 10,
                    stateSave = TRUE,
                    columnDefs = list(list(className = 'dt-center', targets = 1:3))
                  ))
        )# end Table 2
      
      # Tier 2 ----------------------
      ## Editable Input Table --------------
      #Starting Values
      info <- reactiveVal(data.frame(`LNAPL_Constituents` = c("benzene", "toluene", "other", "", ""),
                                     `Volume_fraction` = c(0.05,0.1, 0.85, NA, NA),
                                     MW = c(78.1, 92.1, 100, NA, NA),
                                     Solubility = c(1770, 530, 10, NA, NA),
                                     Density = c(0.87, 0.74, 0.78, NA, NA)))
      # Create Input Table
      output$LNAPL_info <- renderDT(info(), 
                                    server = FALSE, 
                                    editable = TRUE, 
                                    selection = "none",
                                    fillContainer = F,
                                    escape = F,
                                    colnames = c("LNAPL Constituents", "Volume fraction", "Molecular weight (g/mol)", 
                                                 "Solubility (mg/L)", "Density (g/cm<sup>3</sup>)"),
                                    options = list(paging = FALSE,
                                                   searching = FALSE,
                                                   scrollX = TRUE,
                                                   sScrollY = '50vh', scrollCollapse = TRUE,
                                                   columnDefs = list(list(className = 'dt-center', targets = "_all")), extensions = list("Scroller")))
      
      # store a proxy of tabl
      proxy_info <- dataTableProxy(outputId = "LNAPL_info")
      
      # When table is edited update reactive variable
      observeEvent(input$LNAPL_info_cell_edit, {
        info(editData(info(), input$LNAPL_info_cell_edit))
      })
      
      ## Model Calculation (python function) ---------------
      model <- reactiveVal()
      v <- reactiveValues(plot = NULL)
      
      observeEvent(input$calc,{
        
        v$plot <- NULL
        
        req(input$K > 0,
            input$h,
            input$W > 0,
            input$thick > 0,
            input$time > 0,
            input$Vol > 0,
            input$len > 0,
            length((info() %>% na.omit())$LNAPL_Constituents) >= 2,
            length((info() %>% na.omit())$LNAPL_Constituents) == length(unique((info() %>% na.omit())$LNAPL_Constituents)),
            input$len/input$time <= 500)
    
        ccd <- info() %>% na.omit()

        cd <- partModel(input$K*864, input$h, input$W, input$thick, input$time, input$Vol/1000, 
                        as.character(ccd$LNAPL_Constituents), 
                        as.numeric(ccd$Volume_fraction), 
                        as.numeric(ccd$MW), 
                        as.numeric(ccd$Solubility), 
                        as.numeric(ccd$Density), input$len)
        
        cd <- cd[["timeSeries"]]

        num <- length((ccd$LNAPL_Constituents) %>% na.omit())
        
        cols <- c("Time (days)", "Time (yrs)", "N_T", paste0("N_", 1:num), paste0("x_", 1:num), paste0("Se", 1:num))
        
        colnames(cd) <- cols
        cd <- as.data.frame(cd)
        
        cd <- cd %>% select(`Time (yrs)`, paste0("Se", 1:num)) %>%
          pivot_longer(cols = -`Time (yrs)`) 
        
        for(i in 1:num) {
          cd <- cd %>% mutate(name = ifelse(grepl(i, name), ((ccd$LNAPL_Constituents) %>% na.omit())[i], name))
        }
        
        cd$name <- factor(cd$name, levels = ccd$LNAPL_Constituents, order = T)
        
        # Replacing Values less then 1e-7 with 1e-7 (due to computing restrictions)
        cd <- cd %>% 
          mutate(value = ifelse(value <= 1e-7, 1e-7, value)) %>%
          rename(Constituents = name)
        
        model(as.data.frame(cd))


        color <- plot_col[1:length(unique(cd$Constituents))]
        names(color) <- unique(cd$Constituents)
        
        v$plot <- ggplot(data = cd) +
          geom_path(aes(x = `Time (yrs)`, y = value, color = Constituents), size = 2) +
          scale_x_continuous(expand = c(0,0), labels = scales::label_comma(accuracy = NULL, big.mark = ',', decimal.mark = '.')) +
          scale_y_continuous(limits = c(1e-6, NA), expand = c(0,0), labels = scales::label_comma(accuracy = NULL, big.mark = ',', decimal.mark = '.')) +
          scale_color_manual(values = color) +
          labs(x = "Time (years)", y = "Concentration (mg/L)") +
          theme_bw() +
          theme(legend.position = "bottom")
        
        
      }) # end model calc
      
      ## Plot ----------
      output$Time_const_Plot <- renderPlotly({
        
        validate(need(!is.null(model()), "Click Calculate Button"))
        
        validate(need(input$len/input$time <= 500, "Please select a larger time step."))


        if (is.null(v$plot)){print("Click Calculate Button")}
        validate(need(!is.null(v$plot), "Check Entered Values"))

        # Check Inputs

        validate(need(length((info() %>% na.omit())$LNAPL_Constituents) >= 2, "Please provide at least 2 LNAPL constituents."))
        validate(need(sum(info()$Volume_fraction, na.rm = T) == 1, "Total volume fraction for all LNAPL constituents must be equal to 1."))
        validate(need(length((info() %>% na.omit())$LNAPL_Constituents) == length(unique((info() %>% na.omit())$LNAPL_Constituents)),
                                                                                  "Consituents must have unique names."))

        validate(need(input$K > 0, "Hydraulic conductivity is invalid"))
        validate(need(input$W > 0, "Width of LNAPL lens is invalid"))
        validate(need(input$thick > 0, "Average thickness of LNAPL lens is invalid"))
        validate(need(input$time > 0, "Time step is invalid"))
        validate(need(input$Vol > 0, "Release volume of LNAPL is invalid"))
        validate(need(input$len > 0, "Length of simulation is invalid"))
        
        if(input$log_scale == T){
          v <- v$plot + 
            scale_y_log10(limits = c(1e-6, NA), expand = c(0,0), labels = scales::label_comma(accuracy = NULL, big.mark = ',', decimal.mark = '.'))
        }else{
          v <- v$plot
        }
        ggplotly(v)

      })
    }
  )}

