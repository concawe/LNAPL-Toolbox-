# 5538_Concawe_LNAPL-Webtool_1.0a
The application is implemented in R using the Shiny framework. It additionally uses the reticulate package to allow for interoperability between R and Python.

If this is a first download open the LNAPL-Toolbox-.Rproj file in RStudio and run 'renv::restore()' in the console (this may take a few minutes). In addition, prior to running the app, the reticulate package must be libraried.  This will trigger the installation of Miniconda.

## Initial App Set Up
### Requires R tools
1) Download R Tools https://cran.r-project.org/bin/windows/Rtools/rtools40.html
2) After R Tools is installed, open R and run the following code in console: 
    ```r
    write('PATH="${RTOOLS40_HOME}\\usr\\bin;${PATH}"', file = "~/.Renviron", append = TRUE)
    ```
    Restart R and verify that make can be found
    ```r
    Sys.which("make")
    ```
### Restore Environment
1) Restore renv environment
    In console, run: 
    ```r
    renv::restore()
    ```
2) Open global.R and run app
3) Need miniconda? try following prompts to install. If you get exit errors follow below:
    ```r
    # Install remotes package if not already installed
    install.packages('remotes')
    remotes::install_github("hafen/rminiconda")
    rminiconda::install_miniconda(name='concawe')
    py <- rminiconda::find_miniconda_python("concawe")
    reticulate::use_python(py, required = TRUE)
    # Has python package numpy + argparse been installed on machine yet? If not, run:
    reticulate::py_install('numpy')
    reticulate::py_install('argparse')
    ```
4) Try running app again

