<i><b>Information on this page can be downloaded using the button at the bottom of the page.</b></i><br>

The Concawe Toolbox includes a new Tool developed by Andrew Kirkman based on LNAPL mass limitations included in the HSSM conceptual model integrated with LNAPL transmissivity relationships and LNAPL removal via Natural Source Zone Depletion (NSZD) using the <a href="https://ngwa.onlinelibrary.wiley.com/doi/abs/10.1111/j.1745-6584.2012.00949.x" target="_blank">Mahler et al. (2012)</a> model. This Tier 3 section provides additional information about <a href="https://www.epa.gov/water-research/hydrocarbon-spill-screening-model-hssm-windows-version" target="_blank">HSSM</a> and <a href="https://csee.engr.utexas.edu/research/industrial-affiliates-projects/chemical-enhanced-oil-recovery/ut-chem-simulator" target="_blank">UTCHEM</a>, two tools that can be used to answer the question “How far will the LNAPL migrate?” The 2012 paper by <a href="https://ngwa.onlinelibrary.wiley.com/doi/abs/10.1111/j.1745-6584.2012.00949.x" target="_blank">Mahler et al. (2012)</a> presents important findings on how NSZD limits LNAPL migration. Finally, an emerging LNAPL modeling method being developed by GSI’s Dr. Sorab Panday is a promising new approach where LNAPL modeling can be performed using a commonly used groundwater model like MODFLOW.


<h3><b> Overview of HSSM </h3></b>

<ul>
<li>“HSSM” is an acronym for Hydrocarbon Spill Screening Model. </li>
<li> Uses analytical relationships to simulate LNAPL movement. </li>
<li> Simulates vertical LNAPL flow through the unsaturated zone. </li>
<li> Simulates formation and decay of an LNAPL lens at the water table. </li>
<li> Assumes a circular lens that is not affected by a water table slope. </li>
<li> Simulates dissolution of LNAPL constituents and dissolved plume migration. </li>
<li> Older model that requires workarounds to run on 64-bit operating systems like Windows 10. </li>
<li> NSZD cannot be simulated, so that LNAPL spreading predictions in HSSM will overestimate actual spreading. </li>
<li> Can be downloaded <a href="https://www.epa.gov/water-research/hydrocarbon-spill-screening-model-hssm-windows-version" target="_blank">here</a>. </li>
</ul>

<h3><b> Overview of UTCHEM </h3></b>

<ul>
<li> University of Texas chemical flood simulator developed for the oil industry. </li>
<li> 3-D finite-difference numerical simulator for NAPL. </li>
<li> Simulates multiphase, multicomponent, variable temperature systems and complex phase behavior. </li>
<li> Accounts for chemical and physical transformations and heterogeneous porous media. </li>
<li> Uses advanced concepts in high-order numerical accuracy and dispersion control and vector and parallel processing. </li>
<li> Extremely powerful model but expensive and can be difficult to run. </li>
<li> Due to its complexity, it is typically only used for more complicated LNAPL/environmental problems. </li>
<li> Can be run either as a stand-alone program or accessed through GMS package (e.g., <a href="https://www.aquaveo.com/software/gms-groundwater-modeling-system-introduction" target="_blank">https://www.aquaveo.com/software/gms-groundwater-modeling-system-introduction</a>) </li>
</ul>

<h3><b> Video </h3></b>

A short video describing HSSM and UTCHEM can be viewed here.<br>

<p align="center">
<iframe width="560" height="315" src="https://www.youtube.com/embed/h6im2Z63DiY" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe><br><br>

<button class="btn btn-lg btn-primarys" onclick=" window.open('https://www.epa.gov/water-research/hydrocarbon-spill-screening-model-hssm-windows-version','_blank')">Link to Hydrocarbon Spill Screening Model</button><br><br>

<button class="btn btn-lg btn-primarys" onclick=" window.open('https://csee.engr.utexas.edu/research/industrial-affiliates-projects/chemical-enhanced-oil-recovery/ut-chem-simulator','_blank')">Link to University of Texas Chemical Compositional Simulator</button>
</p>

<h3><b> Overview of Mahler et al. (2012) LNAPL Stability Paper </h3></b>

<ul>
<li> “...natural losses of light nonaqueous phase liquids (LNAPLs) through dissolution and evaporation can control the overall extent of LNAPL bodies and LNAPL fluxes observed within LNAPL bodies.” </li> 
<li> Uses proof-of-concept sand tank experiment where LNAPL is continually added but LNAPL body stabilizes due to losses via dissolution and evaporation. </li>
<li> At actual LNAPL sites, LNAPL stability is rapidly achieved because of LNAPL losses via NSZD. </li>
<li> Simple design charts are provided to show when LNAPL bodies will stabilize as a function of loading and NSZD rate, but these charts assume a constant LNAPL addition through time (a situation that is extremely infrequent at actual LNAPL sites). </li>
<li> Key point:  “...natural losses of LNAPL can play an important role in governing LNAPL fluxes within LNAPL bodies and the overall extent of LNAPL bodies.” </li>
<li> The Concawe Toolbox Tier 2 model located under the question “How far will the LNAPL migrate?” developed by Andrew Kirkman uses key concepts from this paper to predict how far LNAPL can migrate. </li>
</ul>

<p align="center">
<img src="./03_LNAPL-Migration/Tier-3/images/Picture1.png">
</p>
<p style="text-align: center;"> <i> LNAPL body stabilization figure from <a href="https://ngwa.onlinelibrary.wiley.com/doi/abs/10.1111/j.1745-6584.2012.00949.x" target="_blank">Mahler et al. (2012)</a>. Each contour line is either 40 years (for panels a, b, c), 20 years (panels d, e, f), or 10 years (panels g, h, and i). (Reprinted with Permission) </i> </p>

<h3><b> Checklist of Input Data for HSSM </b></h3>

Appendix 3 of the HSSM User’s Guide (<a href="https://cfpub.epa.gov/si/si_public_record_report.cfm?Lab=NRMRL&dirEntryId=124906" target="_blank">Weaver et al., 1994</a>) lists key input data and provides support for parameter estimation. Key parameters with example values are reproduced below:

<p align="center">
<img src="./03_LNAPL-Migration/Tier-3/images/Picture2.png">
<br><br>
<img src="./03_LNAPL-Migration/Tier-3/images/Picture3.png">
<br><br>
<img src="./03_LNAPL-Migration/Tier-3/images/Picture4.png">
</p><br><br>

Users select one of three general release scenarios to the unsaturated zone and enter either an LNAPL flowrate over a certain time period, a volume of LNAPL released over a certain area, or a constant head of LNAPL in an impoundment.
<br><br>

<p align="center">
<img src="./03_LNAPL-Migration/Tier-3/images/Picture5.png">
</p><br><br>

<h3><b> General Flowchart for Running HSSM </h3></b>

