# LNAPL Persist Modules -----------------------------

## UI Module -----------------------------------------
LNAPLPersistUI <- function(id, label = "LNAPL Persistence"){
  ns <- NS(id)
  
  tabPanel("LNAPL Persistence",
           tags$i(h1("How long will the LNAPL persist?")),
           tabsetPanel(
             ### Tier 1 --------------------------
             tabPanel(Tier1,
                      br(),
                      fluidRow(
                        column(5,
                               # Text
                               includeMarkdown("./www/04_LNAPL-Persist/Tier_1/LNAPL-Persist_Tier-1.md")
                               ), # end column 1
                        column(7, align = "center",
                               br(), br(),
                               img(src="./04_LNAPL-Persist/Tier_1/Persist.png", width = "100%", height = "auto")
                               ) # end column 2
                        ), # end fluid rows
                      fluidRow(
                        br(),br(),
                        # Table
                        gt_output(ns("table_1")),
                        br(),
                        # Reference Text
                        includeMarkdown("./www/04_LNAPL-Persist/Tier_1/LNAPL-Persist_Tier-1-Refs.md"))
             ), # end Tier 1
             ### Tier 2 ---------------------
             tabPanel(Tier2,
                      br(),
                      fluidRow(
                        column(4, style='border-right: 1px solid black',
                               includeMarkdown("./www/04_LNAPL-Persist/Tier_2/LNAPL-Persist_Tier-2.md"),
                               br(), br()
                        ), # end column 1
                        column(2,
                               HTML("<h3><b>Inputs:</b></h3>"),
                               numericInput(ns("initial_volume"),"Initial Volume of LNAPL Body (L)", 
                                            value = 250000),
                               numericInput(ns("area"),"Area of LNAPL Body (ha)", value = 0.5),
                               numericInput(ns("nszd_rate"),"NSZD Rate (L/ha/yr)", value = 15000),
                               numericInput(ns("start_year"),"Model Start Year", value = 1965),
                               numericInput(ns("end_year"),"Model End Year", value = 2065)
                               ), # end column 2
                        column(6, style='border-left: 1px solid black',
                               fluidRow(align = "center",
                                 HTML("<h3>LNAPL Body Lifetime assuming constant NSZD rate over time.</h3>"),
                                 plotOutput(ns("LNAPL_Vol_Plot1")),
                                 HTML("<h3>LNAPL Body Lifetime assuming NSZD rate decreases proportional to the LNAPL mass remaining.</h3>"),
                                 plotOutput(ns("LNAPL_Vol_Plot2"))
                               )) # end column 3
                      ) # end fluid row
             ), # end Tier 2
             ### Tier 3 ------------------------------------
             tabPanel(Tier3,
                      br(),
                      fluidRow(
                        column(2,), 
                        column(8, 
                               # Markdown Text
                               br(),
                               includeMarkdown("./www/04_LNAPL-Persist/Tier_3/LNAPL-Persist_Tier-3.md"),
                               br(), br()
                        ), # end column 1
                        column(2,) # end column 2
                      ) # end fluid row 
                      ) # end Tier 3
             )
           )
  
} # LNAPL Persist UI


## Server Module -----------------------------------------
LNAPLPersistServer <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {
      
      ### Tier 1 ---------------------------------
      # Table 1
      output$table_1 <- render_gt({
        LNAPLPersist_Table
      })
      
      ### Tier 2 ---------------------------------
      # Calculate NSZD rate - output (Python Code)
      NSZD_RateOut_get <- reactive({
        validate(need(!is.na(input$area) & input$area > 0, "Area of LNAPL Body is invalid! Calculated results should be discarded. Please try again..."))
        validate(need(!is.na(input$nszd_rate) & input$nszd_rate > 0, "NSZD Rate is invalid! Calculated results should be discarded. Please try again..."))

        NSZD_RateOut(input$area, input$nszd_rate)
      }) # end NSZD_RateOut_get
      
      # Estimate range (in years) when most/all LNAPL will be removed by NSZD (Python Code)
      NSZD_RemovalRng_get <- reactive({
        validate(need(!is.na(input$initial_volume) & input$initial_volume > 0, "Initial Volume of LNAPL Body is invalid! Calculated results should be discarded. Please try again..."))
        validate(need(!is.na(input$area) & input$area > 0, "Area of LNAPL Body is invalid! Calculated results should be discarded. Please try again..."))
        validate(need(!is.na(input$nszd_rate) & input$nszd_rate > 0, "NSZD Rate is invalid! Calculated results should be discarded. Please try again..."))
        
        NSZD_RemovalRng(input$initial_volume, input$area, input$nszd_rate)
      }) # end NSZD_RemovalRng_get
      
      # Calculate LNAPL volume as a function of time (Python Code)
      NSZD_VolOut_get <- reactive({
        validate(need(!is.na(input$initial_volume) & input$initial_volume > 0, "Initial Volume of LNAPL Body is invalid! Calculated results should be discarded. Please try again..."))
        validate(need(!is.na(input$area) & input$area > 0, "Area of LNAPL Body is invalid! Calculated results should be discarded. Please try again..."))
        validate(need(!is.na(input$nszd_rate) & input$nszd_rate > 0, "NSZD Rate is invalid! Calculated results should be discarded. Please try again..."))
        validate(need(!is.na(input$start_year) & input$start_year > 0, 
                      "Model Start Year is invalid! Calculated results should be discarded. Please try again..."))
        validate(need(!is.na(input$end_year) & input$end_year > 0,
                      "Model End Year is invalid! Calculated results should be discarded. Please try again..."))
        validate(need(input$end_year > input$start_year,
                      "Model End Year must be greater then Model Start Year! Calculated results should be discarded. Please try again..."))
        
        NSZD_VolOut(input$initial_volume, input$area, input$nszd_rate, input$start_year, input$end_year)
      }) # end NSZD_VolOut_get 

      # Plot of Temp v Rate
      output$LNAPL_Vol_Plot1 <- renderPlot({
        req(input$initial_volume,
            input$area,
            input$nszd_rate,
            input$start_year,
            input$end_year)
        
        
        cd <- as.data.frame(NSZD_VolOut_get())
        colnames(cd) <- c("Year", "n_yr", "Zero_order", "first_order")
        cd$Zero_group <- "Zero-Order"
        cd$First_group <- "First-Order"

        p1 <- ggplot(data = cd) +
          geom_path(aes(x = Year, y = Zero_order, color = Zero_group), size = 3) +
          scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0, 0)),
                             labels = scales::label_comma(accuracy = 1, big.mark = ',', decimal.mark = '.')) +
          scale_x_continuous(expand = expansion(mult = c(0, 0))) +
          labs(x = "\nYear", y = "LNAPL Volume (liters)") +
          scale_color_manual(values = c("Zero-Order" = plot_col[1])) +
          theme + theme(legend.position = c(0.7, 0.9),
                        plot.title = element_text(size = 16, hjust = 0.5, face="bold"),
                        panel.grid.major.x = element_line(color = "grey", linetype = 1, size = 0.5),
                        panel.grid.major.y =  element_line(color = "grey", linetype = 1, size = 0.5),
                        panel.grid.minor.y = element_line(color = "grey", linetype = 1, size = 0.25),
                        panel.grid.minor.x = element_line(color = "grey", linetype = 1, size = 0.25))
        
        p1

      }) # end LNAPL_Vol_Plot
      
      output$LNAPL_Vol_Plot2 <- renderPlot({
        req(input$initial_volume,
            input$area,
            input$nszd_rate,
            input$start_year,
            input$end_year)
        
        
        cd <- as.data.frame(NSZD_VolOut_get())
        colnames(cd) <- c("Year", "n_yr", "Zero_order", "first_order")
        cd$Zero_group <- "Zero-Order"
        cd$First_group <- "First-Order"
        
        p2 <- ggplot(data = cd) +
          geom_path(aes(x = Year, y = first_order, color = First_group), size = 3) +
          scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0, 0)),
                             labels = scales::label_comma(accuracy = 1, big.mark = ',', decimal.mark = '.')) +
          scale_x_continuous(expand = expansion(mult = c(0, 0))) +
          labs(x = "\nYear", y = "LNAPL Volume (liters)") +
          scale_color_manual(values = c("First-Order" = plot_col[2])) +
          theme + theme(legend.position = c(0.7, 0.9),
                        plot.title = element_text(size = 16, hjust = 0.5, face="bold"),
                        panel.grid.major.x = element_line(color = "grey", linetype = 1, size = 0.5),
                        panel.grid.major.y =  element_line(color = "grey", linetype = 1, size = 0.5),
                        panel.grid.minor.y = element_line(color = "grey", linetype = 1, size = 0.25),
                        panel.grid.minor.x = element_line(color = "grey", linetype = 1, size = 0.25))
        
        
        p2
        
      }) # end LNAPL_Vol_Plot
      
    }
  )
} # end LNAPL Persist Server