<h3> LNAPL Lifetime Model </h3> 

<h3> What the Model Does </h3>   
This simple LNAPL lifetime calculator shows two different models of how Natural Source Zone Depletion (NSZD) will remove LNAPL over time.
*	The left graph shows a “zero order” NSZD model where the current NSZD rate stays constant over a long period of time, as suggested by Garg et al. (2017) (see excerpt below).
*	The right graphs shows a “first order” NSZD model where the current NSZD rate drops in proportion to the mass of LNAPL remaining.  Many natural attenuation models assume this type of relationship (e.g., BIOSCREEN model, Newell et al., 1996).

<p align='center'>
<img src='./04_LNAPL-Persist/Tier_2/LNAPL_Persistence_Image.png' style='width: 75%; height auto;'>
</p><br>

<hr class="featurette-divider">

<h3> How the Model Works </h3>

Given an initial LNAPL body volume and NSZD rate (either via an NSZD study in the field or using typical NSZD rates in the scientific literature), the model calculates an estimated range when most/all of the LNAPL will be removed by NSZD. For example, one could take the estimated total LNAPL volume from the <u>Tier 2 How Much LNAPL is Present?</u> tool and enter this value as the Initial Volume of LNAPL Body in units of liters of LNAPL.  The Model start year would be the year that the input data to the model were obtained. 

<hr class="featurette-divider">

<h3> Key Assumptions </h3>  

The model assumes the user has an estimate of the LNAPL volume remaining in the subsurface (in volume units of total liters of LNAPL in the source zone) and has an estimate for the NSZD rates. Current knowledge suggests that a zero-order depletion rate can be assumed for much of the life of the LNAPL until a low saturation of LNAPL or a relatively recalcitrant fraction is left, but research is needed to determine if this fraction should be considered important for site management, for example, its magnitude and any persisting secondary water quality effects.

Overall, the linear model will present a best-case estimate for the LNAPL lifetime, and the first order model will be more conservative (i.e., may overestimate the LNAPL lifetime).

<hr class="featurette-divider">

<h3> Input Data </h3> 

Guidance on the selection of specific input parameters for this tool is provided in <b>Section 6.2</b> of the User’s Manual which can be seen here:

<div style = "text-align:center;">
<a class="btn btn-default btn btn-default shiny-download-link shiny-bound-output button1" onclick="window.open('https://www.concawe.eu/wp-content/uploads/Rpt_22-5.pdf#page=39')" role="button">Download User's Manual</a>
<a class="btn btn-default btn btn-default shiny-download-link shiny-bound-output button1" onclick="window.open('04_LNAPL-Persist/Tier_2/LNAPL_Lifetime_Calculator_Example.pdf')" role="button">Download Example</a>
</div>

NSZD values reported in the literature range from 2,800 to 72,000 liters per hectare per year with the middle 50% of NSZD values falling between 6,600 to 26,000 liters per hectare per year (<a href="https://ngwa.onlinelibrary.wiley.com/doi/full/10.1111/gwmr.12219" target="_blank">Garg et al., 2017</a>).  More information is provided in “NSZD Estimation” under the Tier 3 tab.

<hr class="featurette-divider">

<h3> Developer </h3>  

This LNAPL tool was developed by Poonam Kulkarni of GSI Environmental.

<hr class="featurette-divider">

<h3> References </h3>

<p>Kulkarni, P., 2021.  LNAPL  Body Lifetime Calculator, Concawe LNAPL Toolbox.</p>

<p>Newell, C.J., D.T. Adamson, 2005. Planning-Level Source Decay Models to Evaluate Impact of Source Depletion on Remediation Timeframe. Remediation 15. </p>

<p>Newell, C.J., Gonzales, J., McLeod, R. , 1996. BIOSCREEN Natural Attenuation Decision Support System. U.S. Environmental Protection Agency. (<a href="https://www.gsi-net.com/en/software/free-software/bioscreen.html" target="_blank">https://www.gsi-net.com/en/software/free-software/bioscreen.html</a>)</p>

<p>Garg, S., C. Newell, P. Kulkarni, D. King, M. Irianni Renno, and T. Sale, 2017. Overview of Natural Source Zone Depletion: Processes, Controlling Factors, and Composition Change. Groundwater Monitoring and Remediation 37. (open access; <a href="https://ngwa.onlinelibrary.wiley.com/doi/full/10.1111/gwmr.12219" target="_blank">https://ngwa.onlinelibrary.wiley.com/doi/full/10.1111/gwmr.12219</a>).</p>
