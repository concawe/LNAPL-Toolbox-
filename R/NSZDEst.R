## NSZD Est Modules -----------------------------

## UI -------------------------------------------
NSZDEstUI <- function(id, label = "NSZD Est"){
  ns <- NS(id)
  
  tabPanel("NSZD Estimation",
           tags$i(h1("How can one estimate NSZD?")),
           tabsetPanel(
             # Tier 1 -----------------------
             tabPanel(Tier1,
                      br(),
                      fluidRow(
                      column(5,
                             includeMarkdown("www/07_NSZD-Estimation/Tier_1/NSZD-Est_Tier-1-1.md")),
                      column(7, align = "center",
                             br(), br(),
                             img(src="07_NSZD-Estimation/Tier_1/NSZD-Est_Tier1-1_Figure.png"))),
                      br(), br()
             ), # Simple Explanation
             # Tier 2 ------------------------
             tabPanel(Tier2, 
                      tabsetPanel(
                        ## Tier 2.2 -----------------------
                        tabPanel(HTML("<i>NSZD Rate Converter</i>"),
                                 br(),
                                 fluidRow(
                                   column(4, style='border-right: 1px solid black',
                                          includeMarkdown("www/07_NSZD-Estimation/Tier_2/NSZD-Estimation_Tier-2-2.md"),
                                          gt_output(ns("Para_Table")),
                                          includeMarkdown("www/07_NSZD-Estimation/Tier_2/NSZD-Estimation_Tier-2-2-2.md"),
                                          br(), br()
                                   ), # end column 1
                                   column(2, style='border-right: 1px solid black',
                                          HTML("<h3><b>Inputs:</b></h3>"),
                                          numericInput(ns("Rate"), "NSZD Rate Value", value = 1),
                                          selectizeInput(ns("units_in"), "NSZD Rate Units", 
                                                         choices = NULL, multiple = F),
                                          selectizeInput(ns("units_out"), "Converted NSZD Rate Units", 
                                                         choices = NULL, multiple = F),
                                          uiOutput(ns("LNAPL_compound")),
                                          uiOutput(ns("Treatment_Area"))
                                   ), # end column 2
                                   column(6,
                                          uiOutput(ns("Converted_Rates"))
                                          )# end column 3
                                   ) # end fluid row
                                 ),# end NSZD Rate Converter
                        ## Tier 2.3 -----------------------
                        tabPanel(HTML("<i>NSZD Temperature Enhancement Calculator</i>"),
                                 br(),
                                 fluidRow(
                                   column(4, style='border-right: 1px solid black',
                                          includeMarkdown("www/07_NSZD-Estimation/Tier_2/NSZD-Estimation_Tier-2-3.md"),
                                          br(), br()
                                   ), # end column 1
                                   column(2,
                                          numericInput(ns("T1"), HTML("Initial Groundwater Temperature (&deg;C)"), value=15),
                                          numericInput(ns("T2"), HTML("Enhanced Temperature Using STELA (&deg;C)"), value=30),
                                          numericInput(ns("NSZD_T1Rate"),HTML("NSZD Rate at T1 (L/ha/yr)"), value=7500),
                                          numericInput(ns("Q10"),HTML("Temperature Coefficent <i>(typically 2.0)</i>"), value=2)
                                   ), # end column 2
                                   column(6, style='border-left: 1px solid black',
                                          plotOutput(ns("NSZD_Rate_v_Temp")),
                                          uiOutput(ns("NSZD_T2Rate_ans"))
                                          )# end column 3
                                   ) # end fluid row
                                 )# end NSZD Temperature Enhancement Calculator
                        )
                      ), #tier 2 tabpanel
             ## Tier 3 -----------------------
             tabPanel(Tier3, 
                      br(),
                      fluidRow(
                        column(2,), 
                        column(8, 
                               # Markdown Text
                               br(),
                               includeMarkdown("www/07_NSZD-Estimation/Tier_3/NSZD-Est_Tier-3.md"),
                               br(),
                               gt_output(ns("Table1")),
                               br(), br(),
                               gt_output(ns("Table2")),
                               br(),
                               includeMarkdown("www/07_NSZD-Estimation/Tier_3/NSZD-Est_Tier-3-2.md"),
                               br(), br()
                        ), # end column 1
                        column(2,
                        ) # end column 2
                      ) # end fluid row 
                      ) # end Tier 3
             )
  )
             
     
  
} # NSZD Estimation UI

## Server -------------------------------------
NSZDEstServer <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {
      # Tier 2 --------------------------------
      ### Tier 2-1 -----------------------------
      # NSZD Rate Range
      output$Rate_Range <- renderUI({
        req(input$fuel)
        
        HTML(paste0("<p>25<sup>th</sup> Percentile: <br></p>",
                    "<p>Median: <br></p>",
                    "<p>75<sup>th</sup> Percentile: <br></p>"
        ))
      }) # Rate_Range
      
      ## Tier 2-2 -----------------------------
      ### Table of Parameters -----------------
      output$Para_Table <- render_gt(para)
      
      ### Rate Conversion Unit In Drop Down --------------
      updateSelectizeInput(
        session, "units_in", server = TRUE, 
        choices = data_for_select_in, 
        selected = data_for_select_in[[1]][1], 
        
        options = list(render = I(
          '{ option: function(item, escape) {
            return "<div>" + item.html + "</div>";
            }
         }'
        ))
      ) # Adding HTML to dropdown labels
      
      ### Rate Conversion Unit Out Drop Down --------------------------
      updateSelectizeInput(
        session, "units_out", server = TRUE, 
        choices = data_for_select_out, 
        selected = data_for_select_out[[1]][2], 
        
        options = list(render = I(
          '{ option: function(item, escape) {
            return "<div>" + item.html + "</div>";
            }
         }'
        ))
      ) # Adding HTML to dropdown labels
      
      ### LNAPL Reference Compound (if conversion requires it) -------------
      output$LNAPL_compound <- renderUI({
        req(input$units_in,
            input$units_out)
        
        ns <- session$ns
        
        conv <- paste0(input$units_in, "_to_", input$units_out)
        
        if(conv %in% conv_w_compounds | conv %in% conv_w_compound_area){
          
          selectizeInput(ns("compound"), "LNAPL Reference Compound", 
                         choices = c("benzene", "toluene", "octane", "decane", "gasoline", "diesel", "jet fuel"),
                         selected = compound(),
                         multiple = F)
        }
        
      }) # end compound
      
      compound <- reactiveVal("benzene")
      
      observe({
        
        validate(need(!is.null(input$compound), ""))
        
        compound(ifelse(input$compound == "jet fuel", "jet_fuel", input$compound))
        })
      
      ### Treatment_Area (if conversion requires it) ---------------
      output$Treatment_Area <- renderUI({
        req(input$units_in,
            input$units_out)
        
        ns <- session$ns
        
        conv <- paste0(input$units_in, "_to_", input$units_out)
        
        if(conv %in% conv_w_area | conv %in% conv_w_compound_area){
          numericInput(ns("area"), label = HTML("Treatment Area (m<sup>2</sup>)"), value = NA)
        }
        
      }) # end area
      
      ### Unit Conversion (python function) ------------------------
      unitConversion <- eventReactive({
        input$Rate
        input$units_in
        input$units_out
        input$compound
        input$area},{
          
        req(input$Rate,
            input$units_in,
            input$units_out)

        validate(need(input$Rate > 0, "Rate is invalid! Calculated results should be discarded. Please try again..." ))
        
        conv <- paste0(input$units_in, "_to_", input$units_out)

        validate(need(conv %in% conv_all, "Unit combination not supported. Please choose again."))
        
        # Scenario where compound is require
        if(conv %in% conv_w_compounds){

          ans <- unitConv(input$Rate, input$units_in, input$units_out, compound(), 1)
        }
        
        # Scenario where compound and area is require
        if(conv %in% conv_w_compound_area){
          req(input$area)
          
          validate(need(input$area > 0, "Treatment Area is invalid! Calculated results should be discarded. Please try again..."))

          ans <- unitConv(input$Rate, input$units_in, input$units_out, compound(), input$area)
        }
        
        # Scenario where area is require
        if(conv %in% conv_w_area){
          req(input$area)
          
          validate(need(input$area > 0, "Treatment Area is invalid! Calculated results should be discarded. Please try again..."))
          
          ans <- unitConv(input$Rate, input$units_in, input$units_out, "benzene", input$area)
        }
        
        # Scenario where neither compound nor area is require
        if(!(conv %in% conv_w_compounds) & !(conv %in% conv_w_compound_area) & !(conv %in% conv_w_area)){

          ans <- unitConv(input$Rate, input$units_in, input$units_out, "benzene", 1)
        }
        
        ans
      }, ignoreNULL = F) # end unitConversion
      
      ### Output Text with Result -------------------------
      output$Converted_Rates <- renderUI({

        cd <- unitConversion()
        req(input$units_out)
        units_out_pretty <- case_when(input$units_out == "gal/ac/yr" ~ "gal/ac/yr",
                                      input$units_out == "L/ha/yr" ~ "L/ha/yr",
                                      input$units_out == "umol CO2/m2/sec" ~ "µmol CO<sub>2</sub>/m<sup>2</sup>/sec",
                                      input$units_out == "g/m2/yr" ~ "g/m<sup>2</sup>/yr",
                                      input$units_out == "lb/ac/yr" ~ "lb/ac/yr",
                                      input$units_out == "kg/ha/yr" ~ "kg/ha/yr",
                                      input$units_out == "kg/yr" ~ "kg/yr",
                                      input$units_out == "L/yr" ~ "L/yr")
        
        HTML(paste0("<h3> Converted NSZD Rate: <br><br>", prettyNum(signif(cd, 3), big.mark = ","), " ", 
                    units_out_pretty,"</h3>"))
      }) # end Converted_Rates

      ### Tier 2-3 ------------------------------
      # Calculate Rate at T2 (Python Code)
      NSZD_T2Rate_get <- reactive({
        validate(need(!is.na(input$T1) & input$T1 > 0 & input$T1 < 40, "Initial Groundwater Temperature is invalid! Calculated results should be discarded. Please try again..."))
        validate(need(!is.na(input$T2) & input$T2 > 0 & input$T2 < 40, "Enhanced Temperature Using STELA is invalid! Calculated results should be discarded. Please try again..."))
        validate(need(!is.na(input$NSZD_T1Rate) & input$NSZD_T1Rate > 0, "NSZD Rate at T1 is invalid! Calculated results should be discarded. Please try again..."))
        validate(need(!is.na(input$Q10) & input$Q10 > 0, "Temperature Coefficent is invalid! Calculated results should be discarded. Please try again..."))
        
        NSZD_T2Rate(input$T1, input$T2, input$NSZD_T1Rate, input$Q10)
      }) # NSZD_T2Rate_get
      
      # Plot of Temp v Rate
      output$NSZD_Rate_v_Temp <- renderPlot({
        req(input$T1,
            input$T2,
            input$NSZD_T1Rate,
            input$Q10)
        
        
        cd <- data.frame(Temp = c(input$T1, input$T2), 
                         Rate = c(input$NSZD_T1Rate, NSZD_T2Rate_get()),
                         Label = c("T1", "T2"))
        
       ggplot(data = cd) +
          geom_function(fun = ~(input$NSZD_T1Rate*input$Q10^((.x-input$T1)/10.0)), size = 2, color = "#002131") +
          geom_point(aes(x = Temp, y = Rate), size = 5, color = "grey") +
          geom_text(aes(x = Temp, y = Rate, label = Label), family = "sans", size = 5, fontface = "bold", hjust = 1.5, vjust = -2) + 
          scale_x_continuous(limits = c(input$T1, round(input$T2*.25 + input$T2, 1)),
                             labels = scales::label_comma(accuracy = 1, big.mark = ',', decimal.mark = '.')) +
          scale_y_continuous(labels = scales::label_comma(accuracy = 1, big.mark = ',', decimal.mark = '.')) +
          labs(x = HTML("Avg. Subsurface Temperature (°C)"), y = "NSZD Rate\n(liters per hectare per year)") + 
          theme
        
      }) # NSZD_Rate_v_Temp
      
      output$NSZD_T2Rate_ans <- renderUI({
        ans <- NSZD_T2Rate_get()
        
        HTML(paste0("<h3><b>Answer:<br>NSZD Rate at Enhanced Temperature (T2):<br><span style='color: #ff0000'>", 
                    prettyNum(round(ans, 2), big.mark = ","), "</span> (L/ha/yr)</b></h3>"))
      })
      
      ## Tier 3 -----------------------------
      output$Table1 <-  render_gt({NSZD_Est_Table1})
      
      output$Table2 <-  render_gt({NSZD_Est_Table2})
    }
  )
}



