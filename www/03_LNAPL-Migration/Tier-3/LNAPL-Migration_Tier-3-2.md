
<h3><b> Example Output from HSSM </h3></b>

Example output is shown below (<a href="https://cfpub.epa.gov/si/si_public_record_report.cfm?Lab=NRMRL&dirEntryId=124906" target="_blank">Weaver et al., 1994</a>).
<br><br>

<p align="center">
<img src="./03_LNAPL-Migration/Tier-3/images/Picture7.png">
</p><br><br>

<h3><b> UTCHEM Key Processes that Require Input Data </h3></b>

The UTCHEM Users Guide provides this list of processes. For each process there are required input data. The overall list of potential input data is determined by the nature of the UTCHEM simulation.

<p align="center">
<img src="./03_LNAPL-Migration/Tier-3/images/Picture8.png">
</p><br><br>

<h3><b> Example UTCHEM Flowchart for a Surfactant Problem </h3></b>

An example problem in the GMS Tutorials Document (<a href="https://cfpub.epa.gov/si/si_public_record_report.cfm?Lab=NRMRL&dirEntryId=124906" target="_blank">Aquaveo, 2021</a>) outlines this process:

<ol type="1">
<li> Contamination:  Define media and contaminant properties, initial and boundary conditions, and release. </li>
<li> Dissolution:  Equilibrium dissolution (only) from NAPL and conservative transport. </li>
<li> Pre-flush PITT:  A partitioning interwell tracer test (PITT) to assess NAPL saturations is simulated. </li>
<li> Water Flush:  A “pump and treat” simulation of 270 days of flushing using water. The results of this flush can be compared with the surfactant flush simulation. </li>
<li> Surfactant Flush:  A SEAR simulation using a surfactant to enhance dissolution and recovery with a 60-day simulation time. </li>
<li> Post Flush:  Simulation to determine recovery after the SEAR treatment is complete.  </li>
</ol>

<p align="center">
<img src="./03_LNAPL-Migration/Tier-3/images/Picture9.png">
</p><br><br>

<h3><b> An Emerging LNAPL Model:  The Panday LNAPL Simulator Based on MODFLOW </h3></b>

<ul>
<li> Key Concept:  Reduce governing multiphase flow equations using appropriate approximations to simplify and speed-up computations. </li>
<ul>
<li> Solve only one (LNAPL phase) equation for evaluating LNAPL flow in the vadose zone and along the water table. </li>
<li> Assume air phase instantly equilibrates to movement of liquids. </li>
<ul>
<li> Valid for unsaturated zone flow (this is not a petroleum reservoir). </li>
<li> Validated for flow of water in the vadose zone using Richards’ Equation. </li>
<li> Eliminates air flow equation. </li></ul>
<li> Assume water saturation is unchanged by neglecting water flow dynamics and water redistribution. </li><ul>
<li> Appropriate at residual water saturations above capillary fringe. </li>
<li> Neglects depression of water table by pressure of overlying LNAPL so that lateral LNAPL spread will be larger than computed so impact is conservative. </li>
<li> Can bound impacts of LNAPL in capillary fringe and depression of water table. </li>
<li> Eliminates water flow equation. </li></ul>
<li> Solve LNAPL flow equation only. </li><ul>
<li> Simplify constitutive relationships such that air-filled pore space is the porosity available for LNAPL flow—reduces 3-phase relations to standard 2-phase air-LNAPL equations readily solved by available unsaturated zone flow codes. </li> </ul></ul>
<li> Why is it important and useful? </li><ul>
<li> Can accommodate larger domain, finer grid, three-dimensional representation and structural complexity that may be difficult or impossible to represent and solve at a complex contaminated site with a multi-phase flow model. </li>
<li> Significantly alleviates computational burden. </li>
<ul>
<li> Model runs quickly so that many alternative conceptualizations, parameter distributions, and ranges can be simulated to bracket likely behavior. </li> </ul></ul>
<li> Reduces parameterization burden (parameters are only needed for LNAPL phase). </li><ul>
<li> Parameterization of unsaturated and saturated zones at a site is difficult. </li>
<li> Parameterization of multi-phase flow is difficult. </li> </ul>
<li> <b>Key Point</b>:  LNAPL migration can be performed with open source, public domain codes such as MODFLOW-USG or other unsaturated single phase flow codes. </li> 
<li> Current Status:  A journal article is being prepared (Panday et al., in review) titled <i>“Simulation of LNAPL flow in the vadose zone using a single-phase flow equation”</i>. The abstract is reproduced below. </li>
<br>
<i>A simplified decoupled approach that considers flow only of the NAPL phase has been presented for simulating migration of LNAPL in the vadose zone and on the water table. The approach is applicable to several analyses of practical interest and can be readily adapted into existing vadose zone simulators by appropriate transformation of the constitutive relationships and parameters. Comparative examples demonstrate that results of LNAPL migration using the single-phase approach compare favorably to multiphase flow simulations in the vadose zone. The single-phase approach greatly reduces modeling effort and allows many more simulations to be performed within the same time period, than is possible with multiphase models. The main limitation of the single-phase approach is that it overestimates the spreading of LNAPL at the water table by about 10 to 20% in our comparative experiments for a flat water-table; these errors however reduce with increased water table gradients. The more rapid flow along the water table simulated by this approach as compared to the multiphase simulations is conservative for many examinations, however, this error is within the range of uncertainty in the impact of subsurface parameters such as intrinsic and relative permeability. If that is acceptable for an analysis, the single-phase approach presented here is a valid alternative for rapidly evaluating LNAPL migration in environmental settings.</i>
</ul>

<hr class="featurette-divider">

<h3><b> References </h3></b>

<a href="http://gmstutorials.aquaveo.com/UTCHEM.pdf" target="_blank">Aquaveo, 2021. GMS Tutorials UTCHEM. Downloaded Feb. 2021.</a>
<br>

<a href="https://www.epa.gov/water-research/hydrocarbon-spill-screening-model-hssm-windows-version" target="_blank">Charbeneau, R., Weaver, J., Lien, B., 1995. The Hydrocarbon Spill Screening Model (HSSM). Volume 2: Theoretical Background and Source Codes. U.S. Environmental Protection Agency.</a>
<br>

<a href="https://www.api.org/oil-and-natural-gas/environment/clean-water/ground-water/lnapl/interactive-guide" target="_blank">EST, Aqui-Ver, 2006. API Interactive LNAPL Guide. American Petroleum Institute.</a>
<br>

<a href="https://ngwa.onlinelibrary.wiley.com/doi/abs/10.1111/j.1745-6584.2012.00949.x" target="_blank">Mahler et al., 2012. A mass balance approach to resolving LNAPL stability, N. Mahler, T. Sale, and M. Lyverse, Ground Water 50(6): 861-571, November/December 2012.</a>
<br>

Panday, S., P. de Blanc, and R. Falta, in review. Simulation of LNAPL flow in the vadose zone using a single-phase flow equation. Submitted to Groundwater, in review (Feb. 2021).
<br>

<a href="http://gmsdocs.aquaveo.com/UTCHEM_Users_Guide.pdf" target="_blank">University of Texas, 2000a. Volume I: User’s Guide for UTCHEM-9.0.</a>
<br>

<a href="http://gmsdocs.aquaveo.com/UTCHEM_Users_Guide.pdf" target="_blank">University of Texas, 2000b. Volume II: Technical Documentation for UTCHEM-9.0.</a>
<br>

<a href="https://cfpub.epa.gov/si/si_public_record_report.cfm?Lab=NRMRL&dirEntryId=124906" target="_blank">Weaver, J.W., R. Charbeneau, J.D. Tauxe, B.K. Lien, and J.B. Provost, 1994. The Hydrocarbon Spill Screening Model (HSSM) Volume 1: User's Guide EPA/600/R-94/039a</a>
<br>

<div style = "text-align:center;">
<a class="btn btn-default btn btn-default shiny-download-link shiny-bound-output button2" onclick="window.open('03_LNAPL-Migration/Tier-3/B.  Tier 3 Materials_v3.pdf')" role="button">Download Information</a>
</div>

