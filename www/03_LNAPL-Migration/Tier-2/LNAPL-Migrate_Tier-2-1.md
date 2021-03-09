<h3> What the Model Does </h3>   

This  tool, sometimes called the Kirkman LNAPL  Body Additional Migration Tool,  calculates the additional distance that the leading edge of an existing LNAPL plume is expected to migrate until it eventually stabilizes in the presence of natural source zone depletion (NSZD). To run the model you need to know three things about your LNAPL body:  1) a representative LNAPL transmissivity from bail down tests or from  transmissivities calculated using the "LNAPL Volume Tier 2 Tool; 2) the measured LNAPL body gradient (the slope of the LNAPL body surface); and 3) the current LNAPL body radius (the model makes a simplifying assumption that the LNAPL body is circular).

<hr class="featurette-divider">

<h3> How the Model Works </h3>

The model is based on multiple runs of the Hydrocarbon Spill Screening Model (HSSM; Weaver et al., 1994). For each run, an average LNAPL transmissivity (Tn) and gradient (i) were calculated across the oil lens at different times and soil types. These average properties were used as starting conditions to calculate the expected additional growth of an LNAPL plume under an assumed zero-order NSZD rate of 2.0 x 10<sup>-6</sup> m/day using the steady-state relationship for a circular source derived by Mahler (Mahler et al., 2012).<br>

The plot shows the calculated LNAPL plume length increase for different average values of LNAPL transmissivity × gradient and piecewise linear fit to the data in the nomograph. <br>

To use the model, the user enters an LNAPL gradient and transmissivity (in m<sup>2</sup>/d), and the estimated additional LNAPL plume growth is calculated from one of the following two equations:

For Tn × i &le; 4.0 × 10<sup>-4</sup>,<br>
<p style="margin-left: 40px"> R (m) = 262397 × Tn × i – 20.1</p>

For Tn × i > 4.0 × 10<sup>-4</sup>,<br>
<p style="margin-left: 40px"> R (m) = 66329 × Tn × i + 61.7</p>
where R is the length increase of the LNAPL plume in meters.

<hr class="featurette-divider">

<h3> Key Assumptions </h3>  

The model assumes that there is an unlimited source of LNAPL and that the LNAPL flux is constant. This is an experimental model. Incorporation of HSSM (Weaver et al., 1994) and Mahler et al. (2012) represents a non-hysteric methodology where entrapment of LNAPL is ignored and loss rate inputs can account for partitioning and biodegradation losses.<br>

Entrapment of LNAPL has been evaluated (Sookhak Lari et al., 2016; Pasha et al., 2014; Guarnaccia et al., 1997) and demonstrated to slow the rate of LNAPL migration. Current methods to incorporate entrapment require numerical models which are not within the scope of this tool. The lack of incorporating entrapment results in a conservative approach where the upper bound of LNAPL migration extent is estimated. The results of this tool are intended to be used for demonstrating LNAPL body stability by comparing the maximum potential for LNAPL migration to current extent.<br>

The model is useful for estimating the upper bound of LNAPL migration. However, if the calculated LNAPL extent is used in cumulative LNAPL loss and time to depletion estimates then the resulting estimates would overestimate losses and underestimate time to depletion (Sookhak Lari et al., 2016). It is appropriate to use current delineated LNAPL body extent for cumulative loss calculations or time to depletion estimates.

<hr class="featurette-divider">

<h3> Developer </h3> 

This LNAPL tool, sometimes referred to as the Kirkman LNAPL  Body Additional Migration Tool, was developed by Andrew Kirkman of BP.

<hr class="featurette-divider">

Guarnaccia, J. , Pinder, G. , Fishman, M. , 1997. NAPL: Simulator Documentation, US EPA. <br>

Kirkman, A., 2021. LNAPL  Body Additional Migration Tool. Andrew Kirkman, BP. Programmed by GSI Environmental.

Mahler et al., 2012. A mass balance approach to resolving LNAPL stability, N. Mahler, T. Sale, and M. Lyverse, Ground Water 50(6): 861-571, November/December 2012. <br>

Pasha, A.Y. , Hu, L. , Meegoda, J.N. , 2014. Numerical simulation of a light nonaqueous phase liquid (LNAPL) movement in variably saturated soils with capillary hysteresis, Can. Geotech. J. 51, 1046–1062. <br>

Sookhak Lari, K. , Davis, G.B. , Johnston, C.D. , 2016 Incorporating hysteresis in a multi-phase multi-component NAPL modelling framework; a multi-component LNAPL gasoline example, Advances in Water Resources. 96, 190-201. <br>

Weaver et al., 1994. The Hydrocarbon Spill Screening Model (HSSM); Volume 1: User’s Guide, J.W. Weaver, R.J. Charbeneau, B.K. Lien, and J.B. Provost, U.S. EPA, EPA/600/R-94/039a. <br>
