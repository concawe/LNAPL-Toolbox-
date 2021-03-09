# LNAPL Migrate Modules -----------------------------

## UI Module -----------------------------------------
LNAPLMigrateUI <- function(id, label = "LNAPL Migrate"){
  ns <- NS(id)
  
  tabPanel("LNAPL Migration",
           tags$i(h1("How far will the LNAPL migrate?")),
           tabsetPanel(
             ### Tier 1 -----------------------
             tabPanel(Tier1,
                      # Text
                      includeMarkdown("./www/03_LNAPL-Migration/Tier-1/LNAPL-Migration_Tier-1.md")
                      ), # end Tier 1
             ### Tier 2 -----------------------
             tabPanel(Tier2,
                      tabsetPanel(
                        ### Tier 2.1 -----------------------
                        tabPanel(HTML("<i>Addition Migration Tool</i>"),
                                 br(),
                                 fluidRow(
                                   column(4, style='border-right: 1px solid black',
                                          includeMarkdown("./www/03_LNAPL-Migration/Tier-2/LNAPL-Migrate_Tier-2-1.md")
                                          ), # end column 1
                                   column(2,
                                          HTML("<h3><b>Inputs:</b></h3>"),
                                          numericInput(ns("Trans"), HTML("LNAPL Transmissivity (m<sup>2</sup>/day)"), value = 1.18, min = 0, step = 0.1),
                                          numericInput(ns("Gradient"), HTML("LNAPL Gradient (m/m)"), value = 0.001, min = 0, step = 0.001),
                                          # numericInput(ns("Rate"),HTML("NSZD Rate (m/day)"), value = 0.000002),
                                          numericInput(ns("radius"),HTML("Current LNAPL Body Radius (m)"), value = 100, min = 0)
                                          ), # end column 2
                                   column(6, align = "center", style='border-left: 1px solid black',
                                          plotOutput(ns("T_v_Radius")),
                                          plotOutput(ns("Radius_Spread"))
                                          )# end column 3
                                   ) # end fluid row
                                 ), # end Tier 2.1
                        ### Tier 2.2 ---------------------------
                        tabPanel(HTML("<i>Mahler Migration Model</i>"),
                                 br(),
                                 fluidRow(
                                   column(4, style='border-right: 1px solid black',
                                          includeMarkdown("./www/03_LNAPL-Migration/Tier-2/LNAPL-Migrate_Tier-2-2.md")
                                          ), # end column 1
                                   column(2,
                                          HTML("<h3><b>Inputs:</b></h3>"), style='border-right: 1px solid black',
                                          pickerInput(ns("Release_Rate"), HTML("Long-Term LNAPL Release Rate (L/yr)"), 
                                                      choices = c(250, 510, 1010), 
                                                      selected = 250, multiple = F),
                                          pickerInput(ns("Rate"), HTML("NSZD Rate (L/ha/day)"), 
                                                      choices = c(5000, 10000, 20000), 
                                                      selected = 5000, multiple = F),
                                          pickerInput(ns("Time_sel"), HTML("Time Period Of Model (years)"), 
                                                      choices = c(40, 80, 160), 
                                                      selected = 40, multiple = F)
                                          ), # end column 2
                                   column(6, align = "center",
                                          # plotOutput(ns("Length_Plot"))
                                          uiOutput(ns("Length_Text"))
                                          ) # end column 3
                                   ) # end fluid row
                                 ) # end Tier 2.2
                        ) 
                      ), # end Tier 2
             ### Tier 3 -----------------------------
             tabPanel(Tier3,
                      br(),
                      fluidRow(
                        column(2,), 
                        column(8, 
                               # Markdown Text
                               br(),
                               includeMarkdown("./www/03_LNAPL-Migration/Tier-3/LNAPL-Migration_Tier-3.md"),
                               br(),
                               fluidRow(align = "center",
                               includeHTML("./www/03_LNAPL-Migration/Tier-3/Video1.Rhtml"), br(), br(),
                               includeHTML("./www/03_LNAPL-Migration/Tier-3/Video2.Rhtml")),
                               br(),
                               includeMarkdown("./www/03_LNAPL-Migration/Tier-3/LNAPL-Migration_Tier-3-3.md"),
                               br(),
                               gt_output(ns("Table_5")),
                               br(),
                               includeMarkdown("./www/03_LNAPL-Migration/Tier-3/LNAPL-Migration_Tier-3-2.md"),
                               # Button to download pdf
                               fluidRow(align = "center",
                                        downloadButton(ns("download_pdf"), HTML("<br>Download Information"), style=button_style)),
                               br(), br()
                        ), # end column 1
                        column(2,
                        ) # end column 2
                        ) # end fluid row 
                      ) # end Tier 3
             )
           )
}# LNAPL Migrate UI

## Server Module --------------------------------------
LNAPLMigrateServer <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {
      
      ## Tier 2.1 ------------------------
      ### Function to Calculate Migration -------------------
      cd_mig <- eventReactive({input$Trans
                              input$Gradient},{
        req(input$Trans,
            input$Gradient)
        
        validate(need(!is.na(input$Trans) & input$Trans > 0, 
                      "LNAPL Transmissivity is invalid! Calculated results should be discarded. Please try again..."))
        validate(need(!is.na(input$Gradient) & input$Gradient > 0, 
                      "LNAPL Gradient is invalid! Calculated results should be discarded. Please try again..."))
        
        r <- as.data.frame(migrationModel(input$Trans, input$Gradient))
        
        validate(need(r$R > 0,
                      "Nomograph indicates negative additional spreading, so no additional spreading assumed."))
        
        r
      }) # end cd_mig
      
      ### Plot of Migration Results -----------------------
      output$T_v_Radius <- renderPlot({
        # Calculate Result and format
        cd <- as.data.frame(cd_mig())
        colnames(cd) <- c("Tn_i", "R")
        
        # Determine Max limits based on calculated Value
        y_lim <- cd$R*2
        x_lim <- cd$Tn_i*2
        
        # Create df for line on plot
        cd_line <- data.frame(Tn_i = seq(0, x_lim, length.out = 100)) %>%
          mutate(R = ifelse(Tn_i <= 0.0004, Tn_i*262397-20.1, Tn_i*66329+61.7)) %>%
          filter(R >= 0)
        
        # Create Plot
        plot <- ggplot(data = cd) +
          geom_path(data = cd_line, aes(x = Tn_i, y = R, color = "black"), size = 2) +
          geom_point(aes(x = Tn_i, y = R, color = "red"), size = 5) +
          labs(x = expression(bold("Tn x i "~(m^2/day))), 
               y = "Estimated Additional\nRadial Spread (m)",
               title = paste0("Estimated Additional Radial Spread (m): \n", signif(cd$R,3), "\n")) +
          scale_x_continuous(limits = c(0, x_lim), labels = fmt_dcimals(1, "E")) +
          scale_y_continuous(limits = c(0, y_lim), labels = fmt_dcimals(1, "E"))  +
          scale_color_identity(breaks = c("black", "red"),
                               labels = c("Migration nomograph","Modeled LNAPL plume"),
                               guide = guide_legend(override.aes = list(
                                 linetype = c("solid", "blank"),
                                 shape = c(NA, 16)))) +
          theme +
          theme(legend.position = "bottom")
        
        plot
      }) # end T_v_Radius
      
      ### Circle Plot of Calculated and Given Radius ----------
      output$Radius_Spread <- renderPlot({
        # Calculate Result and format
        cd <- as.data.frame(cd_mig())
        colnames(cd) <- c("Tn_i", "R")
        
        req(input$radius)
        validate(need(!is.na(input$radius) & input$radius >= 0, 
                      "Current LNAPL Body Radius is invalid! Calculated results should be discarded. Please try again..."))
        r <- input$radius
        
        cd <- data.frame(Name = c("Estimated Ultimate Extent of LNAPL Body (m)", "Approximate Current LNAPL Body (m)"), 
                        Value = c(cd$R + r, r))
        
        plot <- ggplot(cd) +
          geom_circle(aes(x0 = 0, y0 = 0, r = Value, color = Name, linetype = Name), size = 2) +
          scale_color_manual(values = c("Approximate Current LNAPL Body (m)" = "black",
                                        "Estimated Ultimate Extent of LNAPL Body (m)" = "grey")) + 
          guides(color = guide_legend(nrow=2,byrow=TRUE)) +
          labs(x = "Radial Spread (m)") +
          coord_fixed() + 
          theme +
          theme(panel.border = element_blank(),
                axis.text.y = element_blank(), 
                axis.title.y = element_blank(),
                panel.grid.major.y =  element_blank(),
                axis.ticks.y = element_blank(),
                axis.ticks.x = element_line(colour = "black"),
                axis.line.x = element_line(colour = "black"),
                legend.position = "bottom")
        plot
      })# end Radius_Spread
      
      ## Tier 2.2 ------------------------
      ### Update Time Dropdown --------------------
      observeEvent({
        input$Release_Rate
        input$Rate},{
          
          req(input$Release_Rate,
              input$Rate)
          
          choices <- unique((LNAPLMigrate_Mahler %>%
                               filter(LNAPL.Source.L.yr == input$Release_Rate, NSZD.Rate.L.ha.yr == input$Rate))$Time.Period.yr)
          
          updatePickerInput(session = session, inputId = "Time_sel",
                            choices = choices)
        }) # end updatePickerInput for Time_sel
      
      ### Function to subset look-up table based on inputs --------------
      ans <- eventReactive({
        input$Release_Rate
        input$Rate
        input$Time_sel},{
          
        req(input$Release_Rate,
            input$Rate,
            input$Time_sel)
        
        cd <- LNAPLMigrate_Mahler %>% 
          filter(NSZD.Rate.L.ha.yr == input$Rate, Time.Period.yr == input$Time_sel) %>%
          mutate(color = ifelse(LNAPL.Source.L.yr == input$Release_Rate, "red",  plot_col[1]),
                 size = ifelse(LNAPL.Source.L.yr == input$Release_Rate, 8, 5))
        
        cd
      }) # end ans
      
      ### Create Plot -----------------------
      # output$Length_Plot <- renderPlot({
      #   cd <- ans()
      #   
      #   ans <- filter(cd, color == "red")
      #   ans <- prettyNum(signif(ans$Plume.Length.m, 3), big.mark = ",")
      #   
      #   plot <- ggplot(data = cd) +
      #     geom_path(aes(x = LNAPL.Source.L.yr, y = Plume.Length.m), size = 2) +
      #     geom_point(aes(x = LNAPL.Source.L.yr, y = Plume.Length.m,  color = color, size = size)) +
      #     labs(x = "\nLong-Term LNAPL Release Rate (L/yr)", y = "Estimated Ultimate\nLNAPL Body Length (m)",
      #          title = paste0("Estimated Ultimate LNAPL Body Length (m): \n", ans, "\n")) +
      #     scale_color_identity() +
      #     scale_size_identity() +
      #     scale_x_continuous(labels = scales::label_comma(accuracy = NULL, big.mark = ',', decimal.mark = '.')) +
      #     scale_y_continuous(labels = scales::label_comma(accuracy = NULL, big.mark = ',', decimal.mark = '.')) +
      #     theme
      #   
      #   plot
      # }) # end Length_Plot
      
      ## Create Text Output --------------------
      output$Length_Text <- renderUI({
        cd <- ans()

        ans <- filter(cd, color == "red")
        ans <- prettyNum(signif(ans$Plume.Length.m, 3), big.mark = ",")
        
        HTML(paste0("<h2>Estimated Ultimate LNAPL Body Length: <br><b>", ans, " m</b></h2>"))
      })# end Length_Text
      
      ## Tier 3 -----------------------------
      ## Download pdf -----------------------
      output$download_pdf <- downloadHandler(
        filename = function(){
          paste("LNAPL_Migration","pdf",sep=".")
        },
        content = function(con){
          file.copy("./www/03_LNAPL-Migration/Tier-3/B.  Tier 3 Materials_v3.pdf", con)
        }
      )# end download_data
      
      ## Table 5 ----------------
      output$Table_5 <- render_gt({
        
        Table5 <- read.csv("./data/LNAPL-Migrat_Tier-3_Table_5.csv", encoding = "UTF-8", colClasses = "character")
        
        Table5 %>% gt() %>%
          tab_header("Table 5 Outline of HSSM-WIN Interface") %>%
          cols_label(Interface.Function = "Interface Function", Section.References = "Section References") %>%
          tab_style(style = list(cell_text(weight = "bold", align = "center")),
                    locations = cells_title(group = "title"))%>%
          tab_style(style = list(cell_text(align = "center")),
                    locations = cells_body(columns = "Section.References", rows = everything())) %>%
          tab_style(style = list(cell_text(align = "center")),
                    locations = cells_column_labels(columns = everything())) %>%
          tab_style(style = list(cell_borders(sides = "all", color = "black", weight = px(2))),
                    locations = list(cells_body(), cells_column_labels(columns = everything()), cells_title(group = "title")))
        
      }) # end Table5
      
    }
  )}
      