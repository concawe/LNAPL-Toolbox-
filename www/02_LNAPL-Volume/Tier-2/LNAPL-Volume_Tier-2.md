<h3> Multi-Site LNAPL Volume and Extent Model </h3>


<h3> What the Model Does </h3>   

This tool calculates several key LNAPL values, including specific volume, recoverable volume, and transmissivity, at multiple locations for multiple layers of differing soil types. These values are used to calculate a total subsurface LNAPL volume. Based on LNAPL gradients specified by the user, estimated LNAPL velocities are also calculated. The distribution of calculated values is depicted graphically.

<hr class="featurette-divider">

<h3> How the Model Works </h3>

The model is based on an extension of the methodology of the API’s LDRM (Charbeneau, 2007). The user enters data into three different input databases: 1) a soil parameter input database, 2) a well coordinate and fluid level gauging input database, and 3) a stratigraphy input database. The model determines the layers in which LNAPL is present, then calculates specific volume and other LNAPL parameters for the layered system. An area-weighted average of the specific volume is calculated to arrive at a total LNAPL volume. 

To improve the site-wide LNAPL volume calculations, it is important to </b>include nearby monitoring wells that do not have any apparent LNAPL thickness</b> in the monitoring well database.  This will help establish a “clean line” around the LNAPL body and prevent extrapolation errors.  

<p align="center">
<img class = "one" src="./02_LNAPL-Volume/Tier-2/LNAPL_Pic_2-1.png" width="300" height="220">
</p>

If you are just calculating the LNAPL volume in only a portion of an LNAPL body, use the polygon tool in the map to the right.

<hr class="featurette-divider">

<h3> Input Data </h3>  

Guidance on the selection of specific input parameters for this tool is provided in <b>Section 4.2</b> of the User’s Manual which can be seen here:

<div style = "text-align:center;">
<a class="btn btn-default btn btn-default shiny-download-link shiny-bound-output button1" onclick="window.open('https://www.concawe.eu/wp-content/uploads/Rpt_22-5.pdf#page=22')" role="button">Download User's Manual</a>
<a class="btn btn-default btn btn-default shiny-download-link shiny-bound-output button1" onclick="window.open('02_LNAPL-Volume/Tier-2/Volume and Extent Example Application.docx')" role="button">Download Example</a>
<a class="btn btn-default btn btn-default shiny-download-link shiny-bound-output button1" onclick="window.open('02_LNAPL-Volume/Tier-2/Soil-Classification.pdf')" role="button">Learn more about soil classification systems</a>
</div>

<p>More general guidance on parameters can be found in the API’s Parameter Selection Guide which can be downloaded here: </p>

<div style = "text-align:center;">
<a class="btn btn-default btn btn-default shiny-download-link shiny-bound-output button1" onclick="window.open('02_LNAPL-Volume/Tier-2/LDRM_User_Manual.pdf')" role="button">Download Parameter Selection Guide</a>
</div>

<hr class="featurette-divider">

<h3> Key Assumptions </h3>  

The model assumes that the LNAPL is in hydrostatic equilibrium with the surrounding media. Relative permeability is calculated by combining the Mualum model with the van Genuchten soil characteristic curve parameters (Charbeneau, 2007).

<hr class="featurette-divider">

<h3> Developers </h3>  

This LNAPL tool, sometimes referred to as the de Blanc LNAPL Model, was developed by Dr. Phil de Blanc and Dr. Shahla Farhat of GSI Environmental, Houston, Texas.

<hr class="featurette-divider">

Charbeneau, 2007. LNAPL Distribution and Recovery Model (LDRM) Volume 1: Distribution and Recovery of Petroleum Hydrocarbon Liquids in Porous Media, Randall J. Charbeneau, American Petroleum Institute.

de Blanc, P.C. and S.  K. Farhat, 2018.  New Tool for Determining LNAPL Volume and Extent.  GSI Environmental Inc.  25th   International Petroleum Environmental Conference, October 30 – November 1, 2018, Denver, Colorado.