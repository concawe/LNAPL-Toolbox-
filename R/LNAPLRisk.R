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
                        column(5,
                               # Text
                               includeMarkdown("www/05_LNAPL-Risk/Tier_1/LNAPL-Risk_Tier-1.md")
                               ), # end column 1
                        column(7, align = "center",
                               # Table 2
                               HTML("<h3><b> Composition (Mass Fractions) of Fresh and Weathered  Gasolines </b></h3>"),
                               DTOutput(ns("Table_2"))
                               ) # end column 2
                        ), # end fluid row
                      fluidRow(
                        # Table 1
                        br(), br(),
                        gt_output(ns("Table_1"))
                        ) # end fluid row
                      ),# end Tier 1
             ### Tier 2 ---------------------
             tabPanel(Tier2,
                      # tabsetPanel(
                        ### Tier 2.1 ---------------
                        # tabPanel(HTML("<i>Bemidji Model Flowchart</i>"),
                        #          HTML("<h3><b><i> Under Construction </i></b></h3>"),
                        #          # br(),
                        #          fluidRow(
                        #            column(6,
                        #                   br(),
                        #                   # Figure
                        #                   div(a(" ",
                        #                         img(src="05_LNAPL-Risk/Tier_1/Bemidji.png")))
                        #                   ), # end column 1
                        #            column(6,
                        #                   h5("Explaination of Bimidji Figure"),
                        #                   actionButton(ns("Ng_Papers"), "Links to Ng et al paper", style=button_style_big)
                        #                   ) # end column 2
                        #            ) # end fluid row
                        #          ), # end Tier 2.1
                        ### Tier 2.2 --------------------
                        # tabPanel(HTML("<i>Dissolution/Partitioning Model</i>"),
                                 br(),
                                 fluidRow(
                                   column(4, style='border-right: 1px solid black',
                                          includeMarkdown("www/05_LNAPL-Risk/Tier_2/LNAPL-Risk_Tier-2.md")
                                          ), # end column 1
                                   column(2, style='border-right: 1px solid black',
                                          HTML("<h3><b>Model Inputs:</b></h3>"),
                                          numericInput(ns("K"),"Hydraulic Conductivity (m/day)", value = 8.64),
                                          numericInput(ns("h"),"Hydraulic Gradient (m/m)", value = 0.005),
                                          numericInput(ns("W"),"Width of LNAPL Lens (m)", value = 10),
                                          numericInput(ns("thick"), "Average Thickness of LNAPL Lens (m)", value = 0.5),
                                          numericInput(ns("den"), HTML("Density of LNAPL (g/cm<sup>3</sup>)"), value = 0.78),
                                          numericInput(ns("time"), "Time Step (days)", value = 1),
                                          numericInput(ns("Vol"), HTML("Release Volume of LNAPL (m<sup>3</sup>)"), value = 1),
                                          selectizeInput(ns("const"), "List of LNAPL Constituents",
                                                         choices = c("benzene", "toluene", "octane", "decane"),
                                                         multiple = T),
                                          uiOutput(ns("Vol_frac_1")),
                                          uiOutput(ns("Vol_frac_2")),
                                          uiOutput(ns("Vol_frac_3")),
                                          uiOutput(ns("Vol_frac_4")),
                                          # uiOutput(ns("other_den")),
                                          numericInput(ns("len"), "Length of Simulation (years)", value = 10),
                                          fluidRow(align = "center",
                                          actionButton(ns("calc"), label = "Calculate", style=button_style),
                                          br(), br(),
                                          HTML("<i> Note: If the calculated solution appears to be unstable try reducing the model time step. </i>"))
                                          ), # end column 2
                                   column(6,
                                          plotOutput(ns("Time_const_Plot"))
                                          ) # end column 3
                                 )# end fluid row
                        # ) # end Tier 2.2
                      # )
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
        
        datatable(LNAPLRisk_Table2,
                  colnames = c("Compound Name", "Mw (g)", "Fresh Gasoline", "Weathered Gasoline",	
                               "Approximate Composition"),
                  rownames = FALSE, escape = FALSE, 
                  options = list(
                    paging =TRUE,
                    pageLength = 10,
                    stateSave = TRUE,
                    columnDefs = list(list(className = 'dt-center', targets = 1:4))
                  ))
        )# end Table 2
      
      # Tier-2 ----------------------
      ## Vol Fraction of Compounds ------------
      output$Vol_frac_1 <- renderUI({
        req(input$const)
        ns <- session$ns
        
        compounds <- c(input$const)

        if("benzene" %in% compounds){
          numericInput(ns("b_frac"), "Volume Fraction of Benzene", value = 0.05)
        }
      }) # end Vol_frac_1
      
      output$Vol_frac_2 <- renderUI({
        req(input$const)
        ns <- session$ns
        compounds <- c(input$const)
        
        if("toluene" %in% compounds){
          numericInput(ns("t_frac"), "Volume Fraction of Toluene", value = 0.1)
        }
      })# end Vol_frac_2
      
      output$Vol_frac_3 <- renderUI({
        req(input$const)
        ns <- session$ns
        compounds <- c(input$const)
        
        if("octane" %in% compounds){
          numericInput(ns("oc_frac"), "Volume Fraction of Octane", value = 0.1)
        }
      })# end Vol_frac_3
      
      output$Vol_frac_4 <- renderUI({
        req(input$const)
        ns <- session$ns
        compounds <- c(input$const)
        
        if("decane" %in% compounds){
          numericInput(ns("d_frac"), "Volume Fraction of Decane", value = 0.1)
        }
      })# end Vol_frac_4
      
      ## Density of Other Fraction -------------
      # output$other_den <- renderUI({
      #   ns <- session$ns
      #   
      #   sum_tot <- sum(input$b_frac, input$d_frac, input$oc_frac, input$t_frac)
      #   
      #   if(sum_tot < 1){
      #     numericInput(ns("other_density"), HTML("Density of Other Fraction (g/cm<sup>3</sup>)"), value = 0.6)
      #   }
      # }) # end other_den
      
      
      ## Model Calculation (python function) ---------------
      Dis_Model <- reactive({
        
        v$plot <- NULL
        
        req(input$K,
            input$h,
            input$W,
            input$thick,
            input$den,
            input$time,
            input$Vol,
            input$const,
            input$len)
        
        validate(need(length(input$const) >= 2, "Please provide at least 2 LNAPL constituents."))
        
        validate(need(input$K > 0, "Hydraulic conductivity is invalid"))
        validate(need(input$W > 0, "Width of LNAPL lens is invalid"))
        validate(need(input$thick > 0, "Average thickness of LNAPL lens is invalid"))
        validate(need(input$den > 0 & input$den < 1, "Density of LNAPL is invalid"))
        validate(need(input$time > 0, "Time step is invalid"))
        validate(need(input$Vol > 0, "Release volume of LNAPL is invalid"))
        validate(need(input$len > 0, "Length of simulation is invalid"))
        validate(need(input$other_density > 0, "Other Density is invalid"))
        
        consts <- c(input$const)
        consts <- consts[order(consts)]
        
        frac_sum <- sum(input$b_frac, input$d_frac, input$oc_frac, input$t_frac)
        other <- 1 - frac_sum
        
        validate(need(frac_sum > 0, "Sum of all volume fractions must be greater then 0."))
        
        fracs <- c(input$b_frac, input$d_frac, input$oc_frac, input$t_frac)
        
        consts <- if(frac_sum < 1){
          consts <- c(consts, "other")} 
        
        fracs <- if(frac_sum < 1){
          fracs <- c(fracs, other)} 
        
        validate(need(frac_sum <= 1, "Sum of all volume fractions must be less then or equal to 1."))
        
        validate(need(length(consts) == length(fracs), "A volume fraction value must be entered for each LNAPL constituent."))

        cd <- partModel(input$K, input$h, input$W, input$thick, input$den, input$time, input$Vol, consts, fracs, input$len)
        cd <- cd[["timeSeries"]]

        num <- length(consts)

        cols <- c("Time (days)", "Time (yrs)", "N_T", paste0("N_", 1:num), paste0("x_", 1:num), paste0("Se", 1:num))

        colnames(cd) <- cols

        as.data.frame(cd)
      }) # end Dis_Model
      
      
      ## Plot of Model Results -------------
      v <- reactiveValues(plot = NULL)
      
      observeEvent(input$calc, {
        
        cd <- Dis_Model()
        
        consts <- c(input$const)
        consts <- consts[order(consts)]
        
        frac_sum <- sum(input$b_frac, input$d_frac, input$oc_frac, input$t_frac)
        
        consts <- if(frac_sum < 1){
          consts <- c(consts, "other")} 
        num <- length(consts)
        
        cd <- cd %>% select(`Time (yrs)`, paste0("Se", 1:num)) %>%
          pivot_longer(cols = -`Time (yrs)`) %>%
          filter(`Time (yrs)` >= 0)

       for(i in 1:num) {
          cd <- cd %>% mutate(name = ifelse(grepl(i, name), consts[i], name))
       }
        
        cd$name <- factor(cd$name, levels = consts, order = T)

        color <- plot_col[1:num]
        names(color) <- consts

        v$plot <- ggplot(data = cd) +
          geom_path(aes(x = `Time (yrs)`, y = value, group = name, color = name), size = 2) +
          scale_x_continuous(labels = scales::label_comma(accuracy = NULL, big.mark = ',', decimal.mark = '.')) +
          scale_y_continuous(labels = scales::label_comma(accuracy = NULL, big.mark = ',', decimal.mark = '.')) +
          scale_color_manual(values = color) +
          labs(x = "Time (years)", y = "Concentration") +
          theme + theme(legend.position = "bottom")
        
      })
      
      output$Time_const_Plot <- renderPlot({
        
        validate(need(length(input$const) >= 2, "Please provide at least 2 LNAPL constituents."))
        
        validate(need(input$K > 0, "Hydraulic conductivity is invalid"))
        validate(need(input$W > 0, "Width of LNAPL lens is invalid"))
        validate(need(input$thick > 0, "Average thickness of LNAPL lens is invalid"))
        validate(need(input$den > 0 & input$den < 1, "Density of LNAPL is invalid"))
        validate(need(input$time > 0, "Time step is invalid"))
        validate(need(input$Vol > 0, "Release volume of LNAPL is invalid"))
        validate(need(input$len > 0, "Length of simulation is invalid"))
        
        frac_sum <- sum(input$b_frac, input$d_frac, input$oc_frac, input$t_frac)
        
        validate(need(frac_sum > 0, "Sum of all volume fractions must be greater then 0."))
        validate(need(frac_sum <= 1, "Sum of all volume fractions must be less then or equal to 1."))
        
        if (is.null(v$plot)) return()
        v$plot
      }) # end observe on calc button
      
      ## Tier 3 -----------------------------
      ## Download pdf -----------------------
      output$download_pdf <- downloadHandler(
        filename = function(){
          paste("LNAPL_Risk","pdf",sep=".")
        },
        content = function(con){
          file.copy("./www/05_LNAPL-Risk/Tier_3/D.  Tier 3 Materials v4.pdf", con)
        }
      )# end download_data
      
      # x <- partModel(8.64, 0.005, 10,0.5, 0.78, 36.524, 1, c("benzene", "toluene", "other"), c(0.05, 0.1, 0.85), 1)
      # y <- x[["timeSeries"]]
      
    }
  )}

