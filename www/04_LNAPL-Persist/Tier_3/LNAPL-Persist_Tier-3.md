<i><b>Information on this page can be downloaded using the button at the bottom of the page.</b></i><br>

A simple box model is provided in Tier 2 and provides a range of time required for the LNAPL to be removed by Natural Source Zone Depletion (NSZD). Users enter the estimated mass/volume of LNAPL present and the estimated NSZD rate. <br>

Two more sophisticated computer tools that can be used to estimate how long the LNAPL might persist at a site are <a href="https://cfpub.epa.gov/si/si_public_record_report.cfm?Lab=NRMRL&dirEntryId=241847" target="_blank">REMFuel</a> (<a href="https://cfpub.epa.gov/si/si_public_file_download.cfm?p_download_id=536926&Lab=NRMRL" target="_blank">Falta et al., 2012</a>) and <a href="https://www.api.org/oil-and-natural-gas/environment/clean-water/ground-water/lnapl/evaluating-hydrocarbon-removal" target="_blank">LNAST</a> (<a href="https://www.api.org/oil-and-natural-gas/environment/clean-water/ground-water/lnapl/evaluating-hydrocarbon-removal" target="_blank">Huntley and Beckett, 2002</a>). A short summary of each model is provided below:

<h3><b> Overview of REMFuel </b></h3>

<ul>
<li> REMFuel is a coupled analytical source zone/plume response model distributed by USEPA. </li>
<li> Based on popular <a href="https://www.epa.gov/water-research/remediation-evaluation-model-chlorinated-solvents-remchlor" target="_blank">REMChlor model</a> used at chlorinated solvent sites. </li>
<li> The source zone model includes a box model where the mass of the dissolution product to be modeled is entered and a relationship “gamma” that describes the mass flux out of the source at any time compared to the remaining mass is specified by the user. </li>
<li> Solute transport model simulates advection, dispersion, retardation, sorption assuming simple 1-D groundwater flow. </li>
<li> The user can specify any percent of source removal at any time to model plume response to active remediation. </li>
<li> The user can model plume remediation at any time in three separate spatial zones by increasing first order decay constants. </li>
<li> NSZD can also be simulated by entering a value for “Source Decay” although there is no discussion in User’s Guide on how to do this. </li>
<li> Key output of the model are graphs showing the concentration (or mass discharge) of the constituents in the dissolved plume vs. distance from source. </li>
<li> Download model from USEPA web page <a href="https://www.epa.gov/water-research/remediation-evaluation-model-fuel-hydrocarbons-remfuel" target="_blank">here</a>. </li>
</ul>

<h3><b> Overview of API’s <u>LN</u>APL Dissolution <u>a</u>nd Transport <u>S</u>creening <u>T</u>ool (LNAST; version 2.0.4) </b></h3>

<ul>
<li> LNAST is suite of calculation tools, information about LNAPL, and LNAPL parameter databases. LNAST focuses on LNAPL distribution and fate at the water table. The calculation tool part of LNAST: </li><ul>
<li> Predicts LNAPL distribution, dissolution, and volatilization over time. </li>
<li>	Calculates downgradient dissolved-phase concentration through time. </li>
<li>	Shows results both with and without hydraulic recovery of LNAPL. </li></ul>
<li> LNAST simulates the smear zone and the downgradient dissolved plume. </li>
<li> Combines multi-phase transport, dissolution, and solute transport. </li>
<ul>
<li> Accounts for relative permeability effects caused by LNAPL. </li>
<li> Zones of high LNAPL saturation have much less groundwater flow through them, extending the longevity of these zones. </li></ul>
<li> Good tool for estimating how long an LNAPL-generated plume will persist. </li>
<li>	Powerful tool to see if LNAPL recovery reduces the longevity of the source and plume. </li>
<li>	Key output is concentration of dissolved constituents in the plume vs. time at an observation well. </li>
<li>	Does not account for NSZD. </li>
<li>	Assumes that remediation occurs shortly after the LNAPL release. You cannot release LNAPL many years ago and then start the remediation now a few decades later. </li>
<li>	LNAST can be downloaded <a href="https://www.api.org/oil-and-natural-gas/environment/clean-water/ground-water/lnapl/evaluating-hydrocarbon-removal" target="_blank">here</a>. </li>
</ul>

<h3><b> Videos </h3></b>

Two short videos are available to learn more about REMFuel and LNAST:
<ul>
<li> <a href="https://www.youtube.com/watch?v=H8JP8gvZcr8" target="_blank">REMFuel</a> </li>
<li> <a href="https://www.youtube.com/watch?v=C2F66MNywKk" target="_blank">LNAST</a> </li>
</ul>
<br><br>
<p align="center">
<iframe width="560" height="315" src="https://www.youtube.com/embed/H8JP8gvZcr8" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe><br><br>
<button class="btn btn-lg btn-primarys" onclick=" window.open('https://www.epa.gov/water-research/remediation-evaluation-model-fuel-hydrocarbons-remfuel','_blank')">Link to Remediation Evaluation Model for Fuel Hydrocarbons</button>
<br><br>
<iframe width="560" height="315" src="https://www.youtube.com/embed/C2F66MNywKk" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe><br><br>
<button class="btn btn-lg btn-primarys" onclick=" window.open('https://www.api.org/oil-and-natural-gas/environment/clean-water/ground-water/lnapl/evaluating-hydrocarbon-removal','_blank')">Link to LNAPL Dissolution and Transport Screening Tool</button>
</p><br><br>

<h3><b> Checklist for REMFuel Input Data </b></h3>

Key input data are shown below. One key feature is that the plume produced by the source can be broken up into nine “space-time” domains with three separate time periods and three separate spatial zones. For example, the first third of the plume downgradient from a 40-year-old source can have its own first order decay coefficients for three separate time periods, such as a 20-year natural attenuation period, then a 5-year plume remediation period, then a 15-year post-remediation natural attenuation period.

While much of the input data below is commonly collected during site characterization activities (e.g., Darcy groundwater velocity, source width/height/length, porosity) the source zone gamma term may be unfamiliar to many users. Basically, gamma defines the relationship between mass flux leaving the source and the remaining mass in the source at any time. For example:  
<ul>
<li> Gamma of zero results in a constant source mass flux until mass is gone, then zero flux (a step function). </li>
<li> Gamma of 0.5 results in a linear decline in source concentration based on the amount of LNAPL mass originally released and the original source concentrations. </li>
<li> Gamma of 1.0 results in an exponential decline in source concentration based on the amount of LNAPL mass originally released and the original source concentrations (this is often used as a default value). </li>
</ul>

<p align="center">
<img src="./04_LNAPL-Persist/Tier_3/images/Picture1.png">
</p><br><br>

<h3><b> Example of REMFuel Output Data for Three Separate Time Periods </b></h3>

In this example, source remediation and plume remediation were performed, leading to the spikey concentration vs. distance curves in the 2021 panel (see the <a href="https://www.youtube.com/watch?v=H8JP8gvZcr8" target="_blank">REMFuel video</a> for a more detailed explanation). Note that the Y-axis is log-scale.

<p align="center">
<img src="./04_LNAPL-Persist/Tier_3/images/Picture2.png">
</p><br><br>

<h3><b> Checklist of Input Data for LNAST </b></h3>
Images reproduced courtesy of the American Petroleum Institute from LNAPL Dissolution and Transport Screening Tool, version 2.0.4, February 2006

To use LNAST, the user first indicates the information desired from the tool:
<br><br>

<p align="center">
<img src="./04_LNAPL-Persist/Tier_3/images/Picture3.png">
</p><br><br>

The tool then takes the user through a series of eight input screens to define soil properties, groundwater conditions, source area parameters, LNAPL properties, and solute transport.
<br><br>

<p align="center">
<img src="./04_LNAPL-Persist/Tier_3/images/Picture4.png">
<br><br>
<img src="./04_LNAPL-Persist/Tier_3/images/Picture5.png">
<br><br>
<img src="./04_LNAPL-Persist/Tier_3/images/Picture6.png">
<img src="./04_LNAPL-Persist/Tier_3/images/Picture7.png">
<br><br>
<img src="./04_LNAPL-Persist/Tier_3/images/Picture8.png">
<br><br>
<img src="./04_LNAPL-Persist/Tier_3/images/Picture9.png">
<img src="./04_LNAPL-Persist/Tier_3/images/Picture10.png">
<br><br>
<img src="./04_LNAPL-Persist/Tier_3/images/Picture11.png">
</p><br><br>


<h3><b> Example of LNAST Output Data </b></h3>

Images reproduced courtesy of the American Petroleum Institute from LNAPL Dissolution and Transport Screening  Tool, version 2.0.4, February 2006

After performing the selected calculations, LNAST allows users to display results to the screen, create a report, or export the results.

<p align="center">
<img src="./04_LNAPL-Persist/Tier_3/images/Picture12.png">
</p><br><br>

An example of key output for LNAPL recovery in a trench is shown below:

<p align="center">
<img src="./04_LNAPL-Persist/Tier_3/images/Picture13.png">
<img src="./04_LNAPL-Persist/Tier_3/images/Picture14.png">
<br><br>
<img src="./04_LNAPL-Persist/Tier_3/images/Picture15.png">
<img src="./04_LNAPL-Persist/Tier_3/images/Picture16.png">
</p><br><br>

<hr class="featurette-divider">

<h3><b> References </b></h3>

<a href="https://cfpub.epa.gov/si/si_public_file_download.cfm?p_download_id=536926&Lab=NRMRL" target="_blank">Falta, R.W., Ahsanuzzaman, A.N.M., Stacy, M., Earle, R.C., 2012. REMFuel:  Remediation Evaluation Model for Fuel Hydrocarbons User’s Manual. USEPA.</a> 

<a href="https://www.api.org/oil-and-natural-gas/environment/clean-water/ground-water/lnapl/evaluating-hydrocarbon-removal" target="_blank">Huntley, D., Beckett, G., 2002. Evaluating Hydrocarbon Removal from Source Zones and Its Effect on Dissolved Plume Longevity and Magnitude. American Petroleum Institute.</a> 

<div style = "text-align:center;">
<a class="btn btn-default btn btn-default shiny-download-link shiny-bound-output button2" onclick="window.open('04_LNAPL-Persist/Tier_3/C.  Tier 3 Materials.pdf')" role="button">Download Information</a>
</div>
