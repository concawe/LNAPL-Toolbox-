<h3> LNAPL Transmissivity Calculator </h3>   

<h3> What the Model Does </h3>   

This tool calculates the following variables that indicate LNAPL volume and mobility at a single location for a single soil type: LNAPL specific volume, transmissivity, and Darcy flux. LNAPL transmissivity is the product of the average LNAPL hydraulic conductivity times the thickness of the LNAPL lens. Large transmissivity values indicate that LNAPL has greater potential to move through the subsurface than small values and suggests that LNAPL may be more easily mobilized or recovered. Transmissivity is often used as an indication of when LNAPL recovery is no longer practical.

<hr class="featurette-divider">

<h3> How the Model Works </h3>

The model is based on the methodology of the API’s LDRM (Charbeneau, 2007). The user enters parameters for the soil type, fluid properties, and the thickness of LNAPL observed in a monitoring well. LNAPL saturations are computed over the LNAPL thickness to calculate specific volume. Transmissivity is then calculated by integrating the saturation-dependent relative permeability over the LNAPL thickness. The product of the average relative permeability and the saturated hydraulic conductivity for the LNAPL is the LNAPL transmissivity. The transmissivity divided by the LNAPL thickness, then multiplied by the LNAPL gradient (see Section 5.2.1.4 of the User Manual for a description) is the LNAPL Darcy flux (volume of LNAPL per unit area of formation). The model uses an “f-factor” approach in which the LNAPL residual saturation is a function of the LNAPL thickness across the lens (Charbeneau, 2007).

Based on guidance from  ITRC (2018) the key threshold for LNAPL recovery is the LNAPL transmissivity has to be higher than this general range of numbers: <b>0.0093 to 0.074 m<sup>2</sup>/day </b>. If the calculated or measured   LNAPL transmissivity is below that the lowest value, then there is a high probability that LNAPL hydraulic recovery will not to be cost effective or efficient.  If above the highest number, then hydraulic recovery has a much higher likelihood of being feasible. Wells exhibiting LNAPL transmissivity values within this range are likely dominated by residual LNAPL.  These values account for multiple soil and LNAPL types (ITRC, 2018).

<hr class="featurette-divider">

<h3> Key Assumptions </h3>  

The model assumes that the LNAPL is in hydrostatic equilibrium with the surrounding media. Relative permeability is calculated by combining the Mualum model with the van Genuchten soil characteristic curve parameters (Charbeneau, 2007).

The model uses default values for various soil and LNAPL properties. Soil properties can be found in Carsel and Parrish (1988), and LNAPL properties can be found in Mercer and Cohen (1990) and Charbeneau (2003).

<hr class="featurette-divider">

<h3> Input Data </h3>  
Guidance on the selection of specific input parameters for this tool is provided in <b>Section 8.2.3</b> of the User’s Manual which can be seen here:

<div style = "text-align:center;">
<a class="btn btn-default btn btn-default shiny-download-link shiny-bound-output button1" onclick="window.open('https://www.concawe.eu/wp-content/uploads/Rpt_22-5.pdf#page=55')" role="button">Download User's Manual</a>
<a class="btn btn-default btn btn-default shiny-download-link shiny-bound-output button1" onclick="window.open('06_LNAPL-Recovery/Tier_2/LNAPL_Transmissivity_Calculator_Example.pdf')" role="button">Download Example</a>
</div>

<hr class="featurette-divider">

<h3> Developer </h3>  

This LNAPL tool was developed by Dr. Phil de Blanc, GSI Environmental.

<hr class="featurette-divider">

Carsel, R.F., and R.S. Parrish. 1988. Developing joint probability distributions of soil water retention characteristics. Water Resour. Res. 24:755-769.

Charbeneau, R. 2003. Models for Design of Free-Product Recovery Systems for Petroleum Hydrocarbon Liquids. American Petroleum Institute.

Charbeneau, R., 2007. LNAPL Distribution and Recovery Model (LDRM) Volume 1: Distribution and Recovery of Petroleum Hydrocarbon Liquids in Porous Media. Volume 2: User and Parameter Selection Guide. American Petroleum Institute.

de Blanc, P., 2021.  LNAPL Transmissivity Calculator, Concawe LNAPL Toolbox.

Mercer, J.W. and Cohen, R.M. 1990. A review of immiscible fluids in the subsurface: properties, models, characterization and remediation, Journal of Contaminant Hydrology, v6:107-163.
