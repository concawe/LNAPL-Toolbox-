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
                               img(src="./04_LNAPL-Persist/Tier_1/Persist.png", width = "85%")
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
                               includeMarkdown("./www/04_LNAPL-Persist/Tier_2/LNAPL-Persist_Tier-2.md")
                        ), # end column 1
                        column(2,
                               HTML("<h3><b>Inputs:</b></h3>"),
                               numericInput(ns("initial_volume"),"Initial Volume of LNAPL Body (L)", 
                                            value = 250000),
                               numericInput(ns("area"),"Area of LNAPL Body (ha)", value = 5),
                               numericInput(ns("nszd_rate"),"NSZD Rate (L/ha/yr)", value = 1500),
                               numericInput(ns("start_year"),"Model Start Year", value = 1965),
                               numericInput(ns("end_year"),"Model End Year", value = 2065)
                               ), # end column 2
                        column(6, style='border-left: 1px solid black',
                               plotOutput(ns("LNAPL_Vol_Plot"))
                               ) # end column 3
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
                               br(),
                               # Button to download pdf
                               fluidRow(align = "center",
                                        downloadButton(ns("download_pdf"), HTML("<br>Download Information"), style=button_style)),
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
      output$LNAPL_Vol_Plot <- renderPlot({
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
          labs(x = "\nYear", y = "LNAPL Volume (liters)", title = "LNAPL Body Lifetime assuming\nconstant NSZD rate over time.\n") +
          scale_color_manual(values = c("Zero-Order" = plot_col[1])) +
          theme + theme(legend.position = c(0.7, 0.9),
                        plot.title = element_text(size = 16, hjust = 0, face="bold"))
        
        p2 <- ggplot(data = cd) +
          geom_path(aes(x = Year, y = first_order, color = First_group), size = 3) +
          scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0, 0)),
                             labels = scales::label_comma(accuracy = 1, big.mark = ',', decimal.mark = '.')) +
          scale_x_continuous(expand = expansion(mult = c(0, 0))) +
          labs(x = "\nYear", y = "LNAPL Volume (liters)", 
               title = "LNAPL Body Lifetime assuming\nNSZD rate decreases proportional\nto the LNAPL mass remaining.") +
          scale_color_manual(values = c("First-Order" = plot_col[2])) +
          theme + theme(legend.position = c(0.7, 0.9),
                        plot.title = element_text(size = 16, hjust = 0, face="bold"))
        
        
        grid.arrange(p1, p2, nrow = 1)

      }) # end LNAPL_Vol_Plot
      
      ## Tier 3 -----------------------------
      ## Download pdf -----------------------
      output$download_pdf <- downloadHandler(
        filename = function(){
          paste("LNAPL_Persist","pdf",sep=".")
        },
        content = function(con){
          file.copy("./www/04_LNAPL-Persist/Tier_3/C.  Tier 3 Materials_v3.pdf", con)
        }
      )# end download_data
      
    }
  )
} # end LNAPL Persist Server