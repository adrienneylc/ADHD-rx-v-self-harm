
/********************************************************************************/
/* 																				*/
/*		Multinational ADHD medication and the risk of suicide attempt  	 	    */
/*		SCCS_SAS_programme														*/
/*		Please refer to separate programme files for analysis 					*/
/*																				*/
/********************************************************************************/
option compress=yes;

libname a "D:\SAS\sccs_mph\raw"; /*original data*/
libname b "D:\SAS\sccs_mph\working library"; /*working library*/
libname c "D:\SAS\sccs_mph\common_data_model";  /* Please enter the path which save the coverted CDM */
libname d "D:\SAS\sccs_mph\results";  /* Folder which save the Results */
%let path=D:\SAS\sccs_mph; 	
/*------------------------*/
/*	[7] OUTPUT RESULTS	  */
/*------------------------*/
data d.irr;
set 
d.irr_exposure_main
d.irr_exposure_submale
d.irr_exposure_subfemale
d.irr_exposure_stim
d.irr_exposure_nons
d.irr_exposure_sen1
d.irr_exposure_sen2
d.irr_exposure_sen3
d.irr_exposure_sen4
d.irr_exposure_sen5
d.irr_exposure_sen6
d.irr_exposure_sen7
d.irr_exposure_nons
d.irr_riskperiod0_main
d.irr_riskperiod0_submale
d.irr_riskperiod0_subfemale
d.irr_riskperiod_stim
d.irr_riskperiod_nons
d.irr_riskperiod_sen1
d.irr_riskperiod_sen2
d.irr_riskperiod_sen3
d.irr_riskperiod_sen4
d.irr_riskperiod_sen5
d.irr_riskperiod_sen6
d.irr_riskperiod_sen7;
run;

data d.incidence;
set 
d.incidence_exposure_main
d.incidence_exposure_submale
d.incidence_exposure_subfemale
d.incidence_exposure_stim
d.incidence_exposure_nons
d.incidence_exposure_sen1
d.incidence_exposure_sen2
d.incidence_exposure_sen3
d.incidence_exposure_sen4
d.incidence_exposure_sen5
d.incidence_exposure_sen6
d.incidence_exposure_sen7
d.incidence_riskperiod0_main
d.incidence_riskperiod0_submale
d.incidence_riskperiod0_subfemale
d.incidence_riskperiod_stim
d.incidence_riskperiod_nons
d.incidence_riskperiod_sen1
d.incidence_riskperiod_sen2
d.incidence_riskperiod_sen3
d.incidence_riskperiod_sen4
d.incidence_riskperiod_sen5
d.incidence_riskperiod_sen6
d.incidence_riskperiod_sen7;
run;

proc export data=d.irr
outfile="&path\irr.xlsx"
dbms=xlsx replace;
run;

proc export data=d.incidence
outfile="&path\incidence.xlsx"
dbms=xlsx replace;
run;
