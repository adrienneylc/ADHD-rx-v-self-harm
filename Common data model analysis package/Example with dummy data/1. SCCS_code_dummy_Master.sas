
/********************************************************************************/
/* 																				*/
/*		Multinational ADHD medication and the risk of suicide attempt  	 	    */
/*		SCCS_SAS_programme														*/
/*		Please refer to separate programme files for analysis 3&4				*/
/*																				*/
/********************************************************************************/
option compress=yes;

%let path=G:\enter\4_bouken\2024_4 ADHD Suicide\ADHD-medication-use-and-self-harm\Common data model analysis package\Example with dummy data; 			*Specify the pathname to your data folder;

libname a "&path\raw"; /*original data*/
libname b "&path\working library"; /*working library*/
libname c "&path\common_data_model";  /* Please enter the path which save the coverted CDM */
libname d "&path\results";  /* Folder which save the Results */
/*--------------------------------------------------------------------------------------------------*/
/* [1] ESTABLISH THE COMMON DATA MODEL 																*/
/*	Table 1: Demographic table => c.demo_final														*/
/*	Table 2: Drug table => c.drug_final																*/
/*	Table 3: Diagnosis table => dx_final															*/
/*--------------------------------------------------------------------------------------------------*/
*Our cohort includes: 
•	Individuals with at least one ADHD medication between 01JAN2001 and 31DEC2020                  
•	Those who had at least one suicide attempt diagnosis between 01JAN2001 and 31DEC2020
•	Aged six and above at observation start date 
We excluded the following from the cohort:
•	Individuals with any cancer diagnosis 
•	Individuals with suicide attempt before observation start date or before age 6.
•	Individuals with missing age or sex 

•	We excluded also if the suicide attempt date is the same as 'Enrol_In_Date'
;

/*------------------------------------*/
/*	[2] SET GLOBAL MACRO VARIABLES	  */
/*------------------------------------*/
	* change values on the right of "=";

%let datea0='01JAN2000'd;           * PLEASE UPDATE IF REQUIRED; *start date of study period, 01JAN2001'd;
%let datea='01JAN2001'd;           	* PLEASE UPDATE IF REQUIRED; *start date of observation period, 01JAN2001'd;
%let dateb='31DEC2020'd;          	* PLEASE UPDATE IF REQUIRED; *end date of observation period, 31DEC2020'd;
%let yeare=2000;                    * PLEASE UPDATE IF REQUIRED; *eligible period, for dbs without life-long enrolment;
%let yeara=2001;                    * PLEASE UPDATE IF REQUIRED; *start year of observation period, 2001;
%let yearb=2020;                    * PLEASE UPDATE IF REQUIRED; *end year of observation period, 2020; 
%let agea=6;                     	* inclusion: age over 6; 
%let patientid=id;      			* Enter the variable name that identifies unique patients in your dataset; 
%let sex=sex;                       * Enter the variable name that specifies the sex of individual patiens; 
%let death_date=death_date;         * Enter the variable name that death date of individual patients; 
%let drugcde=atccode;                * Enter the variable name that specifies the ATC code or NDC code; 
%let trtst=rx_date;                 * Enter the variable name that specifies the prescription start date; 
%let trted=rx_end;                  * Enter the variable name that specifies the prescription end date; 
%let trtday=supply_day;            	* Enter the variable name that specifies the duration of the administration;
%let trtq=supply_quantity;         	* Enter the variable name that specifies the quantity of the drug use;
%let trtdose=dose;                  * Enter the variable name that specifies the dose of the prescribed drug;
%let icdcde=icd9cm;                 * Enter the variable name that specifies the primary diagnosis hospitalisation code (ICD code); 
%let admdt=event_date;             	* Enter the variable name that specifies the hospitalisation admission date; 
%let birth_date=birthday;         * Enter the variable name of birthday;
%let enrol_st=enrol_in_date;        * Enter the variable name of date that join database; *HK: birth_date or study start date ('01JAN2001'd);
%let enrol_end=enrol_out_date;   	* Enter the variable name of date that leave database; *study end date ('31DEC2020'd);
%let obsst=obsst;         			* Enter the variable name of date that observation of each individual patients begins; *HK: birth_date+6/study start date ('01JAN2001'd);
%let obsed=obsed;   				* Enter the variable name of date that that observation of each individual patients ends; *HK: death/study end date('31DEC2020'd)/cancer dx date;

* exposure and outcome;
%let exposure=&drugcde in ('N06BA01', 'N06BA02', 'N06BA03', 'N06BA04','N06BA09', 'N06BA11','C02AC01', 'C02AC02'); * enter the drug code for ADHD medication: mph atx gua amp clo;
%let outcome=substr(&icdcde,1,3) in ("E95"); 	* suicide attempt;
%let adhd=substr(&icdcde,1,3) in ("314"); 		* adhd; 

* subgroup exposure;
%let mph=substr(&drugcde,1,7) in ("N06BA04","N06BA11"); 
%let amp=substr(&drugcde,1,7) in ("N06BA01","N06BA02","N06BA03","N06BA12"); 
%let stimulants=substr(&drugcde,1,7) in ("N06BA04","N06BA11","N06BA01","N06BA02","N06BA03","N06BA12"); 
%let nonstimulants=substr(&drugcde,1,7) in ("N06BA09","C02AC01","C02AC02"); 

* comorbidities (ICD-9-CM code) and concomitant medication (ATC Code);
* note that comorbidities are only included as descriptives but not in analysis;
%let cosick1=substr(&icdcde,1,3) in ("311") or substr(&icdcde,1,4) in ("2962", "2963", "3004"); * depressive episode;
%let cosick2=substr(&icdcde,1,3) in ("308"); 													* Acute reaction to stress;
%let cosick3=substr(&icdcde,1,3) in ("313"); 													* emotional disorders with onset specific to childhood;
%let cosick4=substr(&icdcde,1,3) in ("312"); 													* conduct disorders;
%let cosick5=substr(&icdcde,1,3) in ("300") or substr(&icdcde,1,5) in ("29384"); 				* anxiety disorder;
%let cosick6=substr(&icdcde,1,3) in ("309"); 													* adjustment disorder;
%let cosick7=substr(&icdcde,1,3) in ("317", "318", "319"); 										* mental retardation/ intellectual disabilities;
%let cosick8=substr(&icdcde,1,3) in ("315"); 													* specific delayes in development;
%let cosick9= '139'< substr(&icdcde,1,3) <= '239'; 												* all cancer*;

%let codrug1=&drugcde in ("N05AN01"); 				* enter the drug code for lithium;
%let codrug2=substr(&drugcde,1,4) in ("N05A"); 		* enter the drug code for antipsychotics;
%let codrug3=substr(&drugcde,1,4) in ("N06A"); 		* enter the drug code for antidepressants;
%let codrug4=substr(&drugcde,1,4)in ("N03A"); 		* enter the drug code for antiepileptics;
%let codrug5=substr(&drugcde,1,4) in ("N05B"); 		* enter the drug code for anxiolotics;
%let codrug6=substr(&drugcde,1,7) in ("N06BA04"); 	* enter the drug code for METHYLPHENIDATE;
%let codrug7=substr(&drugcde,1,7) in ("N06BA11"); 	* enter the drug code for DEXMETHYLPHENIDATE;
%let codrug8=substr(&drugcde,1,7) in ("N06BA09"); 	* enter the drug code for ATOMOXETINE;
%let codrug9=substr(&drugcde,1,7) in ("N06BA01"); 	* enter the drug code for AMPHETAMINE;
%let codrug10=substr(&drugcde,1,7) in ("N06BA02"); 	* enter the drug code for DEXAMPHETAMINE;
%let codrug11=substr(&drugcde,1,7) in ("N06BA03"); 	* enter the drug code for METAMPHETAMINE;
%let codrug12=substr(&drugcde,1,7) in ("N06BA12"); 	* enter the drug code for LISDEXAMPHETAMINE;
%let codrug13=substr(&drugcde,1,7) in ("C02AC01"); 	* enter the drug code for CLONIDINE;
%let codrug14=substr(&drugcde,1,7) in ("C02AC02"); 	* enter the drug code for GUANFACINE;

/*-------------------------------------------------------------------*/
/*	[3] CREATE VARIABLES FOR EXPOSURE, COMEDICATION, COMORBIDITIES   */
/*-------------------------------------------------------------------*/
*exposure and concomitant medication;
data b.rx_data; 
set c.drug;
if &exposure then exp=1; else exp=0; 
if &codrug1 then codrug1=1; else codrug1=0; 
if &codrug2 then codrug2=1; else codrug2=0; 
if &codrug3 then codrug3=1; else codrug3=0; 
if &codrug4 then codrug4=1; else codrug4=0; 
if &codrug5 then codrug5=1; else codrug5=0; 
if &codrug6 then codrug6=1; else codrug6=0; 
if &codrug7 then codrug7=1; else codrug7=0; 
if &codrug8 then codrug8=1; else codrug8=0; 
if &codrug9 then codrug9=1; else codrug9=0; 
if &codrug10 then codrug10=1; else codrug10=0; 
if &codrug11 then codrug11=1; else codrug11=0; 
if &codrug12 then codrug12=1; else codrug12=0; 
if &codrug13 then codrug13=1; else codrug13=0; 
if &codrug14 then codrug14=1; else codrug14=0; 
if &mph then mph=1; else mph=0;
if &amp then amp=1; else amp=0;
if &stimulants then stimulants=1; else stimulants=0;
if &nonstimulants then nonstimulants=1; else nonstimulants=0;
run;

*comorbidities;
data b.dx_data; 
set c.dx; 
if &adhd then adhd=1; else adhd=0;
if &cosick1 then cosick1=1; else cosick1=0; 
if &cosick2 then cosick2=1; else cosick2=0; 
if &cosick3 then cosick3=1; else cosick3=0; 
if &cosick4 then cosick4=1; else cosick4=0; 
if &cosick5 then cosick5=1; else cosick5=0; 
if &cosick6 then cosick6=1; else cosick6=0; 
if &cosick7 then cosick7=1; else cosick7=0; 
if &cosick8 then cosick8=1; else cosick8=0;
if &cosick9 then cosick9=1; else cosick9=0;  
run;
/*------------------------------------------------------------------------------*/
/*	[4] SELECT STUDY POPULATION   												*/
/*	----------------------------												*/
/*  Main analysis:																*/
/*  inclusion criteria:															*/ 
/*  1. at least one ADHD rx	between 01JAN2001 and 31DEC2020						*/
/*	2. aged six and above between 01JAN2001 and 31DEC2020						*/
/*	3. at least one suicide attempt dx between 01JAN2001 and 31DEC2020			*/
/*																				*/
/* 	exclusion criteria:															*/
/* 	1. patients with cancer dx 													*/
/* 	2. patients with suicide attempt before age 6 or 01JAN2001 					*/
/* 	3. patients with missing age												*/
/* 	4. patients with missing sex 												*/
/*	5. patients with suicide attempt before observation start					*/	
/*------------------------------------------------------------------------------*/
ODS LISTING CLOSE; 
ods rtf file="&path\flowchart.doc";
/* inclusion criteria */
*1) select the population with ADHD rx during total study period -> cohort1;
data b.cohort1; 
set c.demo; 
run; 
title 'Number of patients with ADHD medication';
proc sql; 
select count(distinct &patientid) 
from b.cohort1; 
quit; * Patients with ADHD rx from 01JAN2007 to 31DEC2019 = 5028;

*2) select patients aged over six when received ADHD rx from cohort 1 -> cohort2;
*remove those below 6 before studyed and those died before studyst*;
data b.cohort2;
set b.cohort1;
if missing (&sex) then delete;
if missing (&birth_date) then delete;
if ~(day(&birth_date)=29 and month(&birth_date)=2) then do;
dob6=mdy(month(&birth_date), day(&birth_date), year(&birth_date)+&agea);
end;
else do;
dob6=mdy(3, 1, year(&birth_date)+&agea);
end;
obsst=max(&datea, dob6);
obsed=min(&dateb, death_date);
if obsst > &dateb then delete;
if obsed =< &datea then delete;
format &birth_date death_date dob6 obsst obsed date9.;
keep &patientid Sex &birth_date death_date dob6 obsst obsed;
run; 
title 'Number of patients with ADHD medication and aged >6 ';
proc sql; 
select count(distinct &patientid) 
from b.cohort2; 
quit; * Patients aged >6 with ADHD rx from 01JAN2007 to 31DEC2019 = 5026;

*3) Censor by Cx (ICD9 140-239): find first cx dx and update studyed for each individuals;
proc sql;
create table b.cohort2_2 as
select a.*, b.&icdcde, b.&admdt
from b.cohort2 as a left join b.dx_data as b on a.&patientid=b.&patientid 
order by a.&patientid;
quit;
proc sql; 
create table b.cohort2_3 as
select *, (case
when &cosick9
then event_date else obsed end) as obsed_2 format date9.
from b.cohort2_2;
quit;
proc sql;
create table b.cohort2_4 as
select *, min(obsed_2) as obsed_3 format date9. from b.cohort2_3 group by &patientid;
quit;

*4) selecting current users of exposure from cohort2_4 -> cohort3;
proc sql;
create table b.exp_all as
select distinct a.&patientid, a.&drugcde, a.&trtst, a.&trted, a.&trtday, 
a.&trtq, a.&trtdose, a.setting
from b.rx_data as a, b.cohort2_4 as b
where a.&patientid = b.&patientid
and exp=1 
and b.obsst <= a.&trtst
and a.&trted <= b.obsed
and b.dob6 <= a.&trtst
order by a.&patientid, a.&trtst, a.&trtday desc;
quit;
proc sql;
create table b.exp_prepres as
select distinct &patientid, &trtst, &trted
from b.exp_all
order by 1, 2;
quit;
title 'Number of patients with ADHD medication during individual observation period ';
proc sql; 
select count(distinct &patientid) 
from b.exp_prepres; 
quit; * number of current users aged>6 on study drugs during individual study period =40875 ;
proc sql;
create table b.cohort3 as
select distinct &patientid, 
min(&trtst) as first_stt format date9., 
min(&trted) as first_end format date9.,
max(&trted) as last_end format date9.
from b.exp_all
group by 1
order by 1;
quit;
data b.exp_data;
set b.exp_all;
run;
proc sort data=b.exp_data(keep=id) out=b.cohort4 nodupkey; by _all_; run; 

*5) selecting prevalent patients of outcome during the study period from cohort4 -> cohort5;
proc sql;
create table b.outcome_all as
select &patientid, &admdt, &icdcde 
from b.dx_data
where &patientid in (select &patientid from b.exp_prepres) and &outcome;
quit; /*number of suicide events in ppl w/ adhd rx=998*/
title 'Number of patients with suicide attempt during study period ';
proc sql; 
select count(distinct &patientid) 
from b.outcome_all; 
quit; *prevalent patients of outcome = 4896;

*6) Remove patients with events before obsst;
data b.outcome_all_2;
set b.outcome_all;
proc sql;
create table b.outcome_all_2 as 
select distinct a.*, b.obsst, b.obsed_3
from b.outcome_all as a left join b.cohort2_4 as b
on a.&patientid=b.&patientid;
quit;
data b.outcome_all_3;
set b.outcome_all_2;
if &admdt < &obsst;
run;
proc sql;
create table b.outcome_all_4 as
select * from b.outcome_all_2
where &patientid not in (select &patientid from b.outcome_all_3);
quit;
proc sql;
create table b.check as
select distinct &patientid
from b.outcome_all_4;
quit;

*7) selecting incident patients of outcome during the study period from cohort5 -> cohort6;
proc sort data=b.outcome_all_4; by _all_; run; 
data b.outcome_first; 
set b.outcome_all_4; 
by &patientid; 
if first.&patientid; 
run;
proc sql;
create table b.outcome_first2 as
select a.&patientid, a.obsst, a.obsed_3 as obsed, b.*
from b.cohort2_4 as a left join b.outcome_first as b on a.&patientid=b.&patientid 
order by a.&patientid, b.&admdt;
quit;
data b.outcome_inci; 
set b.outcome_first2; 
if &obsst<=&admdt<=obsed;
run; 
proc sort data=b.outcome_inci nodupkey; by _all_; run; 
*incident patients of outcome in study period = 410;

*8) Remove exp and outcome same date;
data b.cohort5; 
set b.outcome_first; 
keep &patientid;
run; 
proc sql; 
create table b.outcome_data as
select distinct b.*
from b.cohort5 as a left join b.outcome_first2 as b on a.&patientid=b.&patientid
where a.&patientid in (select &patientid from b.outcome_inci)
order by b.&patientid, b.&admdt;
quit;
/*
HK: data contains all dx since dob, as long as first event date is after obsst, 
	there would be at least 6 years screening period.
other databases may use year of study period-1 as screening period
data b.outcome_&yeare(keep=&patientid); 
set b.outcome_first; 
if year(&admdt)=&yeare;
run; 

*defining first outcome as outcome;
proc sql; 
create table b.outcome_data as
select distinct b.*
from b.cohort5 as a left join b.outcome_first as b on a.&patientid=b.&patientid
where a.&patientid not in (select &patientid from b.outcome_&yeare)
order by b.&patientid, b.&admdt;
quit;*/ 

proc sort data=b.outcome_data(keep=&patientid) out=b.cohort6 nodupkey; by _all_; run; 

proc sql;
create table b.out_exp_same as
select distinct a.&patientid, b.&admdt, c.first_stt
from b.cohort6 as a left join b.outcome_first2 as b on a.&patientid=b.&patientid
						   left join b.cohort3 as c on a.&patientid=c.&patientid and b.&admdt=c.first_stt
having c.first_stt^=.
order by a.&patientid, c.first_stt;
quit; *outcome and exposure date is equal = 4;

proc sql;
create table b.cohort7 as
select distinct &patientid
from b.cohort6
where &patientid not in (select &patientid from b.out_exp_same)
order by &patientid;
quit;
* After exclusion = 4884;

proc sql;
create table b.cohort_8 as
select (b.&patientid) as id, b.&sex, b.&birth_date, c.&obsst, c.&obsed 
from b.cohort7 as a left join c.demo as b on (a.&patientid)=(b.&patientid)
left join b.cohort2_4 as c on (a.&patientid)=(c.&patientid)
order by 1;
quit;
proc sort data=b.cohort_8 out=b.cohort_final nodupkey; by _all_; run;
title 'Number of patients in study cohort';
proc sql; 
select count(distinct &patientid) 
from b.cohort_final; 
quit; /* final cohort of the study population, n = 4884*/
ods rtf close;
/*------------------------------------------------------------------------------*/
/*	[5] CONSTRUCT FINAL DATASET w. TIME-VARYING VARIABLES						*/
/*	-----------------------------------------------------						*/
/*  1. base dataset																*/
/*	2. dataset for exposure														*/
/*	3. dataset for outcome														*/
/*	4. dataset for concomitant medication										*/
/* 	5. dataset for comorbidities												*/
/* 	6. dataset for age 															*/															
/*------------------------------------------------------------------------------*/

/******************************/
/*  1.  base dataset (daily)  */
/******************************/
data b.basedata; 
set b.cohort_final; 
format date yymmdd10.; 
do date=&obsst to &obsed; 
by &patientid;
output; 
end; 
drop &sex &birth_date &obsst &obsed;
run;

/******************************/
/*  2. dataset for exposure   */
/******************************/
*1) constructing dataset for all prescription of exposure;
proc sql;
create table exp_data1 as
select distinct a.*, b.&obsst, b.&obsed
from b.exp_data as a left join b.cohort2_4 as b on (a.&patientid)=(b.&patientid)
where a.&patientid in (select &patientid from b.cohort_final)
and (b.&obsst<=&trtst<=b.&obsed or b.&obsst <= &trted <= b.&obsed)
order by &patientid, &trtst, &trtday desc;
quit;
data exp_data1; 
set exp_data1; 
if &trtst<&obsst then &trtst=&obsst; 
if &trted>&obsed then &trted=&obsed; 
run;
*2) eliminating duplicative duration;
proc sort data=exp_data1;
 by  &patientid &trtst &trtday ;
run;
data exp_data1; 
set exp_data1; 
by &patientid; 
if &trtst>lag(&trted+1) then stt_flag=1; 
if first.&patientid then stt_flag=1;
retain order 0;
order+stt_flag;
run;  
proc sql;
create table exp_data2 as
select distinct order, min(&trtst) as &trtst format yymmdd10., max(&trted) as &trted format yymmdd10.
from exp_data1
group by 1;
quit;
proc sql;
create table exp_data3 as
select distinct b.&patientid, a.&trtst, a.&trted, a.order
from exp_data2 as a left join exp_data1 as b
on a.order=b.order
order by b.&patientid, a.&trtst;
quit;
*3) dividing exposure status;
%macro exp_div(data_pre, data_pro, start_dt, end_dt, label);

proc sql noprint;
create table exp_cnt as
select &patientid, count(*) as exp_cnt
from &data_pre
group by &patientid;
select max(exp_cnt) into :_pcount from exp_cnt;
quit;
%let _pcount=&_pcount;

proc transpose data=&data_pre out=start(drop=_name_) prefix=&start_dt;
by &patientid;
var &start_dt;
run;

proc transpose data=&data_pre out=end(drop=_name_) prefix=&end_dt;
by &patientid;
var &end_dt;
run;

data data1;
merge b.basedata exp_cnt start end;
by &patientid;
run;

data &data_pro;
set data1;
array stt_dt[*] &start_dt.1-&start_dt.&_pcount;
array end_dt[*] &end_dt.1-&end_dt.&_pcount;
do i=1 to &_pcount;
if stt_dt[i]<=date<=end_dt[i] then &label=1;
end;
if &label=. then &label=0;
keep &patientid date &label; 
run;

%mend;
*Till here: out of resources;
%exp_div(exp_data3, exp_final1, &trtst, &trted, exposure);

proc sql;
create table exp_final2 as
select distinct a.*, b.&trtst, b.&trted
from exp_final1 as a left join exp_data3 as b 
on a.&patientid=b.&patientid and a.date=b.&trtst
order by a.&patientid, date;
quit;
proc sql;
create table exp_final3 as
select distinct a.*, b.first_stt, b.first_end, b.last_end
from exp_final2 as a left join b.cohort3 as b 
on a.&patientid=b.&patientid
order by a.&patientid, a.date;
quit;
data exp_final4;
set exp_final3;
by &patientid;
format sttdt_index enddt_index yymmdd10.;
if first.&patientid then sttdt_index=.;
if first.&patientid then enddt_index=.;
retain sttdt_index enddt_index;
if &trtst^=. then do;
sttdt_index=first_stt;
end;
if &trted^=. then do;
enddt_index=last_end;
end;
if sttdt_index=. then sttdt_index=first_stt;
if enddt_index=. then enddt_index=last_end;
keep &patientid date sttdt_index enddt_index exposure;
run;
* 4) Assigning risk periods														;
* Risk period -1: first rxdate -1 to 90 days                         	        ; 
* Risk period  0: Baseline period i.e. unexposed p-t before & after exp			;
* Risk period  1: first rxdate to 90 days										;
* Risk period  2: >90 days after first rxdate									; 
	* Note: Subsequent rx within >90 after first rxdate belongs to riskperiod2	;

* Assign exposure days;
data exp_final5_1;
set exp_final4;
by &patientid ;
if /*(lag(exposure)=0 and exposure=1) or (first.&patientid and exposure=1)*/ date=sttdt_index then exp_stt=1;
retain exp_day 0;
if exposure=1 and exp_stt=1 then exp_day=1;
if exposure=1 and exp_stt^=1 then exp_day=exp_day+1;
if exposure=0 then delete;
run;
data exp_final5_2;
set exp_final4;
by &patientid ;
if /*(lag(exposure)=0 and exposure=1) or (first.&patientid and exposure=1)*/ date=sttdt_index then exp_stt=1;
retain exp_day 0;
if exposure=1 then delete;
if exposure=0 then exp_day=0;
run;
data exp_final6;
set exp_final5_1 exp_final5_2;
    BY &patientid date;
RUN;
data exp_final7;
set exp_final6;
if exposure =0 and (-90<=(date-sttdt_index)<=-1) then riskperiod=-1;
else if (exposure =1 and 1<=exp_day<=90) then riskperiod=1;
else if (exposure =1 and exp_day>90) then riskperiod=2;
else if riskperiod=. and exposure =0 and date<sttdt_index then riskperiod=-2;
else if riskperiod=. and exposure =0 and date>sttdt_index then riskperiod=3;
run;
data b.exp_final;
set exp_final7;
if riskperiod=-1 then riskperiod0=-1;
if riskperiod=1 then riskperiod0=1;
if riskperiod=2 then riskperiod0=2;
if riskperiod=-2 then riskperiod0=0;
if riskperiod=3 then riskperiod0=0;
drop exp_stt exp_day;
run;

/******************************/
/*  3. dataset for outcome    */
/******************************/
proc sql;
create table outcome_data1 as
select distinct b.*, b.event_date+0 as event_end format yymmdd10., a.&obsst, a.&obsed
from b.cohort_final as a 
left join b.outcome_data as b on (a.&patientid)=(b.&patientid)
where b.&obsst<=b.&admdt<=b.&obsed
order by b.&patientid, b.&admdt;
quit;
%macro div_status(data_pre, data_pro, start_dt, end_dt, label);

proc sql noprint;
create table exp_cnt as
select &patientid, count(*) as exp_cnt
from &data_pre
group by &patientid;
select max(exp_cnt) into :_pcount from exp_cnt;
quit;
%let _pcount=&_pcount;

proc transpose data=&data_pre out=start(drop=_name_) prefix=&start_dt;
by &patientid;
var &start_dt;
run;

proc transpose data=&data_pre out=end(drop=_name_) prefix=&end_dt;
by &patientid;
var &end_dt;
run;

data data1;
merge b.basedata exp_cnt start end;
by &patientid;
run;

data &data_pro;
set data1;
array stt_dt[*] &start_dt.1-&start_dt.&_pcount;
array end_dt[*] &end_dt.1-&end_dt.&_pcount;
do i=1 to &_pcount;
if stt_dt[i]<=date<=end_dt[i] then &label=1;
end;
if &label=. then &label=0;
keep &patientid date &label; 
run;

%mend;

%div_status(outcome_data1, b.outcome_final, &admdt, event_end, outcome);
/*********************************************/
/*  4. dataset for concomitant medication    */
/*********************************************/

%macro codrug(label, start_dt, end_dt, data_pro);
*1) constructing dataset for all prescriptions of each concomitant medication;
data b.&label._data; 
set b.rx_data; 
where &label=1; 
run;

proc sql;
create table b.&label._data1 as
select distinct b.*,a.&obsst, a.&obsed 
from b.cohort_final as a left join b.&label._data as b on (a.&patientid)=(b.&patientid)
where a.&obsst<=b.&start_dt<=a.&obsed
order by b.&patientid, b.&start_dt, b.&trtday desc;
quit;

data b.&label._data1; 
set b.&label._data1; 
if &start_dt>&obsed then &end_dt=&obsed; 
run;

*2) eliminating duplicative duration;
data b.&label._data1; 
set b.&label._data1; 
by &patientid; 
if &start_dt>lag(&end_dt) then stt_flag=1; 
if first.&patientid then stt_flag=1;
retain order 0;
order+stt_flag;
run;  

proc sql;
create table b.&label._data2 as
select distinct order, min(&start_dt) as &start_dt format yymmdd10., max(&end_dt) as &end_dt format yymmdd10.
from b.&label._data1
group by 1;
quit;

proc sql;
create table b.&label._data3 as
select distinct b.&patientid, a.&start_dt, a.&end_dt
from b.&label._data2 as a left join b.&label._data1 as b
on a.order=b.order
order by b.&patientid, a.&start_dt;
quit;

*3) dividing exposure status;
proc sql noprint;
create table b.pres_cnt as
select &patientid, count(*) as pres_cnt
from b.&label._data3
group by &patientid;
select max(pres_cnt) into :_pcount from b.pres_cnt;
quit;
%let _pcount=&_pcount;

proc transpose data=b.&label._data3 out=b.start(drop=_name_) prefix=&start_dt;
by &patientid;
var &start_dt;
run;

proc transpose data=b.&label._data3 out=b.end(drop=_name_) prefix=&end_dt;
by &patientid;
var &end_dt;
run;

data b.data1;
merge b.basedata b.start b.end;
by &patientid;
run;

data &data_pro;
set b.data1;
array stt_dt[*] &start_dt.1-&start_dt.&_pcount;
array end_dt[*] &end_dt.1-&end_dt.&_pcount;
do i=1 to &_pcount;
if stt_dt[i]<=date<=end_dt[i] then &label=1;
end;
if &label=. then &label=0;
keep &patientid date &label; 
run;

%mend;

%codrug(codrug1, &trtst, &trted, b.codrug1_final);
%codrug(codrug2, &trtst, &trted, b.codrug2_final);
%codrug(codrug3, &trtst, &trted, b.codrug3_final);
%codrug(codrug4, &trtst, &trted, b.codrug4_final);
%codrug(codrug5, &trtst, &trted, b.codrug5_final);
%codrug(codrug6, &trtst, &trted, b.codrug6_final);
%codrug(codrug7, &trtst, &trted, b.codrug7_final);
%codrug(codrug8, &trtst, &trted, b.codrug8_final);
%codrug(codrug9, &trtst, &trted, b.codrug9_final);
%codrug(codrug10, &trtst, &trted, b.codrug10_final);
%codrug(codrug11, &trtst, &trted, b.codrug11_final);
%codrug(codrug12, &trtst, &trted, b.codrug12_final);
%codrug(codrug13, &trtst, &trted, b.codrug13_final);
%codrug(codrug14, &trtst, &trted, b.codrug14_final);
%codrug(mph, &trtst, &trted, b.mph_final);
%codrug(amp, &trtst, &trted, b.amp_final);
%codrug(stimulants, &trtst, &trted, b.stimulants_final);
%codrug(nonstimulants, &trtst, &trted, b.nonstimulants_final);

proc sql;
create table b.codrug_final1 as
select distinct a.*, b.codrug2
from b.codrug1_final as a 
left join b.codrug2_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.codrug_final2 as
select distinct a.*, b.codrug3
from b.codrug_final1 as a 
left join b.codrug3_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.codrug_final3 as
select distinct a.*, b.codrug4
from b.codrug_final2 as a 
left join b.codrug4_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.codrug_final4 as
select distinct a.*, b.codrug5
from b.codrug_final3 as a 
left join b.codrug5_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.codrug_final5 as
select distinct a.*, b.codrug6
from b.codrug_final4 as a 
left join b.codrug6_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.codrug_final6 as
select distinct a.*, b.codrug7
from b.codrug_final5 as a 
left join b.codrug7_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.codrug_final7 as
select distinct a.*, b.codrug8
from b.codrug_final6 as a 
left join b.codrug8_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.codrug_final8 as
select distinct a.*, b.codrug9
from b.codrug_final7 as a 
left join b.codrug9_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.codrug_final9 as
select distinct a.*, b.codrug10
from b.codrug_final8 as a 
left join b.codrug10_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.codrug_final10 as
select distinct a.*, b.codrug11
from b.codrug_final9 as a 
left join b.codrug11_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.codrug_final11 as
select distinct a.*, b.codrug12
from b.codrug_final10 as a 
left join b.codrug12_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.codrug_final12 as
select distinct a.*, b.codrug13
from b.codrug_final11 as a 
left join b.codrug13_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.codrug_final13 as
select distinct a.*, b.codrug14
from b.codrug_final12 as a 
left join b.codrug14_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.codrug_final14 as
select distinct a.*, b.mph
from b.codrug_final13 as a 
left join b.mph_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.codrug_final15 as
select distinct a.*, b.amp
from b.codrug_final14 as a 
left join b.amp_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.codrug_final16 as
select distinct a.*, b.stimulants
from b.codrug_final15 as a 
left join b.stimulants_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.codrug_final as
select distinct a.*, b.nonstimulants
from b.codrug_final16 as a 
left join b.nonstimulants_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
data b.codrug_final;
set b.codrug_final;
if missing (codrug1) then codrug1=0;
if missing (codrug2) then codrug2=0;
if missing (codrug3) then codrug3=0;
if missing (codrug4) then codrug4=0;
if missing (codrug5) then codrug5=0;
if missing (codrug6) then codrug6=0;
if missing (codrug7) then codrug7=0;
if missing (codrug8) then codrug8=0;
if missing (codrug9) then codrug9=0;
if missing (codrug10) then codrug10=0;
if missing (codrug11) then codrug11=0;
if missing (codrug12) then codrug12=0;
if missing (codrug13) then codrug13=0;
if missing (codrug14) then codrug14=0;
if missing (mph) then mph=0;
if missing (amp) then amp=0;
if missing (stimulants) then stimulants=0;
if missing (nonstimulants) then nonstimulants=0;
run;

proc summary data=b.codrug_final;
var codrug1 codrug2 codrug3 codrug4 codrug5 mph stimulants nonstimulants;
output out=codrug1sum;
run;
/***********************************/
/*  5. dataset for comorbidities   */
/***********************************/

%macro cosick(label, start_dt, end_dt, data_pro);

data b.&label._data; 
set b.dx_data; 
where &label=1; 
run;

proc sql;
create table b.&label._data1 as
select distinct b.*, event_date+0 as event_end format yymmdd10.
from b.cohort_final as a left join b.&label._data as b on a.&patientid=b.&patientid
where a.&obsst<=b.&start_dt<=a.&obsed
order by b.&patientid, b.&start_dt;
quit;

proc sql noprint;
create table b.pres_cnt as
select &patientid, count(*) as pres_cnt
from b.&label._data1
group by &patientid;
select max(pres_cnt) into :_pcount from b.pres_cnt;
quit;
%let _pcount=&_pcount;

proc transpose data=b.&label._data1 out=b.start(drop=_name_) prefix=&start_dt;
by &patientid;
var &start_dt;
run;

proc transpose data=b.&label._data1 out=b.end(drop=_name_) prefix=&end_dt;
by &patientid;
var &end_dt;
run;

data b.data1;
merge b.basedata b.start b.end;
by &patientid;
run;

data &data_pro;
set b.data1;
array stt_dt[*] &start_dt.1-&start_dt.&_pcount;
array end_dt[*] &end_dt.1-&end_dt.&_pcount;
do i=1 to &_pcount;
if stt_dt[i]<=date<=end_dt[i] then &label=1;
end;
if &label=. then &label=0;
keep &patientid date &label; 
run;

%mend;
%cosick(cosick1, &admdt, event_end, b.cosick1_final);
%cosick(cosick2, &admdt, event_end, b.cosick2_final);
%cosick(cosick3, &admdt, event_end, b.cosick3_final);
%cosick(cosick4, &admdt, event_end, b.cosick4_final);
%cosick(cosick5, &admdt, event_end, b.cosick5_final);
%cosick(cosick6, &admdt, event_end, b.cosick6_final);
%cosick(cosick7, &admdt, event_end, b.cosick7_final);
%cosick(cosick8, &admdt, event_end, b.cosick8_final);
%cosick(cosick9, &admdt, event_end, b.cosick9_final);

proc sql;
create table b.cosick_final2 as
select distinct a.*, b.cosick2
from b.cosick1_final as a 
left join b.cosick2_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.cosick_final3 as
select distinct a.*, b.cosick3
from b.cosick_final2 as a 
left join b.cosick3_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.cosick_final4 as
select distinct a.*, b.cosick4
from b.cosick_final3 as a 
left join b.cosick4_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.cosick_final5 as
select distinct a.*, b.cosick5
from b.cosick_final4 as a 
left join b.cosick5_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.cosick_final6 as
select distinct a.*, b.cosick6
from b.cosick_final5 as a 
left join b.cosick6_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.cosick_final7 as
select distinct a.*, b.cosick7
from b.cosick_final6 as a 
left join b.cosick7_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.cosick_final8 as
select distinct a.*, b.cosick8
from b.cosick_final7 as a 
left join b.cosick8_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc sql;
create table b.cosick_final as
select distinct a.*, b.cosick9
from b.cosick_final8 as a 
left join b.cosick9_final as b on a.&patientid=b.&patientid and a.date=b.date
order by &patientid, date;
quit;
proc summary data=b.cosick_final;
var cosick1 cosick2 cosick3 cosick4 cosick5 cosick6 cosick7 cosick8 cosick9;
output out=cosick1sum;
run;
/*************************/
/*  6. dataset for age   */
/*************************/
proc sql;
create table age1 as
select a.&patientid, a.date, year(date)-year(&birth_date) as age
from b.basedata as a left join c.demo_final as b
on a.&patientid=b.&patientid
order by a.&patientid, a.date;
quit;
data b.age_final;
set age1;
if age<6 then agg=1;
else if 6<=age<=12 then agg=2;
else if 13<=age<=15 then agg=3;
else if 16<=age<=19 then agg=4;
else if 20<=age<=29 then agg=5;
else if 30<=age<=39 then agg=6;
else if 40<=age<=49 then agg=7;
else if 50<=age<=59 then agg=8;
else if 60<=age<=69 then agg=9;
else if age>=70 then agg=10;
else agg=11;
run;



/* creating the proxy indicator of variables for table 1 */
*1)  comorbidities (lifetime/during study period comorb);
proc sql;
create table b.cosick_proxy as
select distinct &patientid, max(cosick1) as p_cosick1, 
max(cosick2) as p_cosick2, max(cosick3) as p_cosick3, 
max(cosick4) as p_cosick4, max(cosick5) as p_cosick5, 
max(cosick6) as p_cosick6, max(cosick7) as p_cosick7, 
max(cosick8) as p_cosick8, max(cosick9) as p_cosick9
from b.dx_data
where &patientid in (select &patientid from b.cohort_final) and &datea<=&admdt<=&dateb
group by &patientid;
quit;

*2)  concomitant medications;
proc sql;
create table b.codrug_proxy as
select distinct &patientid, max(codrug1) as p_codrug1, max(codrug2) as p_codrug2, 
max(codrug3) as p_codrug3, max(codrug4) as p_codrug4, max(codrug5) as p_codrug5,
max(codrug6) as p_codrug6, max(codrug7) as p_codrug7, max(codrug8) as p_codrug8,
max(codrug9) as p_codrug9, max(codrug10) as p_codrug10, max(codrug11) as p_codrug11,
max(codrug12) as p_codrug12, max(codrug13) as p_codrug13, max(codrug14) as p_codrug14,
max(mph) as p_mph, max(amp) as p_amp, max(nonstimulants) as p_nonstimulants
from b.rx_data
where &patientid in (select &patientid from b.cohort_final) and &datea<=&trtst<=&dateb
group by &patientid;
quit;
proc sql;
create table b.proxy_final as
select distinct a.*, b.*
from b.cosick_proxy as a left join b.codrug_proxy as b
on a.&patientid=b.&patientid
order by &patientid;
quit;

proc sql;
create table b.final_data1 as
select a.&patientid, a.date as fu_stt, a.date+1 as fu_end format yymmdd10.,
b.date, b.exposure, b.sttdt_index, b.enddt_index, b.riskperiod, b.riskperiod0
from b.basedata as a left join 
b.exp_final as b on (a.&patientid)=(b.&patientid) and a.date=b.date
order by a.&patientid, a.date;
quit;
proc sql;
create table b.final_data2 as
select distinct (a.*), b.outcome
from b.final_data1 as a 
left join b.outcome_final as b on (a.&patientid)=(b.&patientid) and a.date=b.date
order by a.&patientid, a.date;
quit;
proc sql;
create table b.final_data3 as
select distinct (a.*), b.codrug1, b.codrug2, b.codrug3, b.codrug4, b.codrug5,
b.codrug6, b.codrug7, b.codrug8, b.codrug9, b.codrug10, b.codrug11, b.codrug12,
b.codrug13, b.codrug14, b.mph, b.amp, b.stimulants, b.nonstimulants
from b.final_data2 as a 
left join b.codrug_final as b on (a.&patientid)=(b.&patientid) and a.date=b.date
order by a.&patientid, a.date;
quit;
proc sql;
create table b.final_data4 as
select distinct (a.*), b.cosick1, b.cosick2, b.cosick3, b.cosick4, b.cosick5,
b.cosick6, b.cosick7, b.cosick8
from b.final_data3 as a 
left join b.cosick_final as b on (a.&patientid)=(b.&patientid) and a.date=b.date
order by a.&patientid, a.date;
quit;
proc sql;
create table b.final_data5 as
select distinct(a.*), b.age, b.agg
from b.final_data4 as a 
left join b.age_final as b on (a.&patientid)=(b.&patientid) and a.date=b.date
order by a.&patientid, a.date;
quit;
proc sql;
create table b.final_data6 as
select distinct(a.*), b.&admdt as outcome_dt format yymmdd10.
from b.final_data5 as a 
left join b.outcome_first as b on (a.&patientid)=(b.&patientid) 
order by a.&patientid, a.date;
quit;
/* add season var = month */
data b.final_data;
set b.final_data6;
if month(date)=1 then season =1;
else if month(date)=2 then season =2;
else if month(date)=3 then season =3;
else if month(date)=4 then season =4;
else if month(date)=5 then season =5;
else if month(date)=6 then season =6;
else if month(date)=7 then season =7;
else if month(date)=8 then season =8;
else if month(date)=9 then season =9;
else if month(date)=10 then season =10;
else if month(date)=11 then season =11;
else season =12;
run;
proc summary data=b.final_data;
var codrug1 codrug2 codrug3 codrug4 codrug5 mph stimulants nonstimulants;
output out=codrug2sum;
run;

/* [6] analyzing SCCS */
*1) table 1;
* check if it is appropriate to use age at individual observation start instead of age at study start;
proc sql;
create table table1 as
select distinct a.*, year(&obsst)-year(&birth_date) as age, b.*
from b.cohort_final as a 
left join b.proxy_final as b on a.&patientid=b.&patientid;
quit;
data b.table1;
set table1;
if age<6 then agg=1;
else if 6<=age<=12 then agg=2;
else if 13<=age<=15 then agg=3;
else if 16<=age<=19 then agg=4;
else if 20<=age<=29 then agg=5;
else if 30<=age<=39 then agg=6;
else if 40<=age<=49 then agg=7;
else if 50<=age<=59 then agg=8;
else if 60<=age<=69 then agg=9;
else if age>=70 then agg=10;
else agg=11;
run;

ODS LISTING CLOSE; 
ods rtf file="&path\table1.doc";
proc freq data=b.table1;
table sex /norow nocol;  							
table agg /norow nocol;  						
table p_cosick1 /norow nocol;  		
table p_cosick2 /norow nocol;  						
table p_cosick3 /norow nocol;  						
table p_cosick4 /norow nocol;  						
table p_cosick5 /norow nocol;  						
table p_cosick6 /norow nocol;  						
table p_cosick7 /norow nocol;
table p_cosick8 /norow nocol;	
table p_cosick9 /norow nocol;	
table p_codrug1 /norow nocol;  						
table p_codrug2 /norow nocol;  						
table p_codrug3 /norow nocol;  						
table p_codrug4 /norow nocol;  						
table p_codrug5 /norow nocol;
table p_codrug6 /norow nocol;  						
table p_codrug7 /norow nocol;  						
table p_codrug8 /norow nocol;  						
table p_codrug9 /norow nocol;  						
table p_codrug10 /norow nocol;
table p_codrug11 /norow nocol;  						
table p_codrug12 /norow nocol;
table p_codrug13 /norow nocol;  						
table p_codrug14 /norow nocol;	
run;
proc sql;
select count(distinct &patientid) as tot_pat
from b.table1;
quit;
proc sql;
create table exp_data_desc as
select distinct * from 
b.exp_data
where &patientid in (select &patientid from b.cohort_final);
quit;
title "1) Number of unique users of each ADHD rx";
proc sql;
select atccode,count(distinct &patientid) as tot_pat
from exp_data_desc
group by atccode;
quit;
title "2) Length of Prescription, Median (Range) [IQR], d";
data exp_data_desc;
set exp_data_desc;
if supply_day=0 then delete;
run;
proc means data=exp_data_desc median min max q1 q3;
var supply_day;
class atccode;
run;
proc means data=exp_data_desc median min max q1 q3;
var supply_day;
run;
title "2) Female Length of Prescription, Median (Range) [IQR], d";
proc sql;
create table exp_data_desc_F as 
select * 
from exp_data_desc;
quit;
proc means data=exp_data_desc_F n median min max q1 q3;
var supply_day;
class atccode;
run;
proc means data=exp_data_desc_F median min max q1 q3;
var supply_day;
run;
title "3) Male Length of Prescription, Median (Range) [IQR], d";
proc sql;
create table exp_data_desc_M as 
select * 
from b.exp_data_desc;
quit;
proc means data=exp_data_desc_M n median min max q1 q3;
var supply_day;
class atccode;
run;
proc means data=exp_data_desc_M median min max q1 q3;
var supply_day;
run;
title "4) Dose, Median (Range) [IQR], mg/d";
data exp_data_desc2;
set exp_data_desc;
if dose=0 then delete;
run;
proc means data=exp_data_desc2 median min max q1 q3;
var dose;
class atccode;
run;
proc means data=exp_data_desc2 median min max q1 q3;
var dose;
run;
title "5) Female Dose, Median (Range) [IQR], mg/d";
proc sql;
create table exp_data_desc2_F as 
select * 
from exp_data_desc2;
quit;
proc means data=exp_data_desc2_F n median min max q1 q3;
var dose;
class atccode;
run;
proc means data=exp_data_desc2_F median min max q1 q3;
var dose;
run;
title "6) Male Dose, Median (Range) [IQR], mg/d";
proc sql;
create table exp_data_desc2_M as 
select * 
from exp_data_desc2;
quit;
proc means data=exp_data_desc2_M n median min max q1 q3;
var dose;
class atccode;
run;
proc means data=exp_data_desc2_M median min max q1 q3;
var dose;
run;

title "7) mean age at baseline";
proc sql;
create table desc6 as
select distinct a.&patientid, year(a.obsst)-year(b.&birth_date) as age
from b.cohort_8 as a
left join b.table1 as b 
on (a.&patientid)=b.&patientid
where (a.&patientid) in (select &patientid from b.cohort_final);
quit;
proc means data=desc6 n mean std;
var age;
run;
proc sql;
create table desc7 as
select distinct a.&patientid, year(a.obsst)-year(b.&birth_date) as age
from b.cohort_8 as a
left join b.table1 as b 
on (a.&patientid)=b.&patientid
where (a.&patientid) in (select &patientid from b.cohort_final) and b.&sex="F";
quit;
title "8) mean F age at baseline";
proc means data=desc7 n mean std;
var age;
run;
proc sql;
create table desc8 as
select distinct a.&patientid, year(a.obsst)-year(b.&birth_date) as age
from b.cohort_8 as a
left join b.table1 as b 
on (a.&patientid)=b.&patientid
where (a.&patientid) in (select &patientid from b.cohort_final) and b.&sex="M";
quit;
title "9) mean M age at baseline";
proc means data=desc8 n mean std;
var age;
run;
ods rtf close;

*Perform the following analysis:
1. Main analysis
2a. male
2b. female
2c. stimulants *
2d. non-stimulants *
3. recurrent suicide *
4a. without people who died *
4b. exposed end date + 1 week *
4c. exposed end date + 5 weeks *
4d. exposed end date + 10 weeks *
4e. adhd rx+ suicide dx + adhd dx *
4f. remove ppl with adhd rx 12 months before observation start *
* - separate programme files;

*1. Main analysis;
%macro main(unit, reference);

data sccs_&unit.0;
set b.final_data;
by &patientid;
compare=compress(catx("-", outcome, &patientid, &unit., codrug1, codrug2, codrug3, codrug4, codrug5,  age, season));
if compare^=lag(compare) then stt_flag=1; 
if first.&patientid then stt_flag=1;
retain order 0;
order+stt_flag;
drop stt_flag;
run;  

proc sql; 
create table sccs_&unit. as
select distinct outcome, &patientid, &unit., codrug1, codrug2, codrug3, codrug4, codrug5, 
age, order, min(fu_stt) as fu_stt format yymmdd10., max(fu_end) as fu_end format yymmdd10., 
((calculated fu_end)-(calculated fu_stt)+1)/365.25 as fu_year, log(calculated fu_year) as l_fu_year,
season
from sccs_&unit.0
group by outcome, &patientid, &unit., codrug1, codrug2, codrug3, codrug4, codrug5,  age, season, order
order by &patientid, calculated fu_stt;
quit;

proc genmod data=sccs_&unit.;
class &unit.(ref="&reference.") &patientid age /*codrug1-codrug5*/ season;
model outcome=&unit. &patientid age codrug1-codrug5 season / dist=poisson offset=l_fu_year link=log;
ods output ParameterEstimates=result;
quit;

data d.irr_&unit._main; 
set result;
IRR=exp(Estimate);
IRR_Lower=exp(LowerWaldCL);
IRR_Upper=exp(UpperWaldCL);
if Parameter="&unit.";
table="main";
keep Parameter Level1 IRR IRR_Lower IRR_Upper Probchisq table;
run;

proc sql;
ods output SQL_results=d.incidence_&unit._main;
select *, event/person_year as incidence 
from (
select &unit., "&unit." as name, sum(outcome) as event, sum(fu_year) as person_year, "Main&unit" as table
from sccs_&unit.
group by &unit.);
quit;
%mend;
title "Main analysis";
%main(exposure, 0);
%main(riskperiod, -2);
%main(riskperiod0, 0);


*2a,b. Subgroup by sex;
*2a Subgroup: Female;
data b.cohort_final_F;
set b.cohort_final;
if &sex="F";
run;
proc sql; 
create table b.final_data_F as
select * 
from b.final_data
where &patientid in (select &patientid from b.cohort_final_F);
quit;
%macro subfemale(unit, reference);
data sccs_&unit.0;
set b.final_data_F;
by &patientid;
compare=compress(catx("-", outcome, &patientid, &unit., codrug1, codrug2, codrug3, codrug4, codrug5,  age, season));
if compare^=lag(compare) then stt_flag=1; 
if first.&patientid then stt_flag=1;
retain order 0;
order+stt_flag;
drop stt_flag;
run;  

proc sql; 
create table sccs_&unit. as
select distinct outcome, &patientid, &unit., codrug1, codrug2, codrug3, codrug4, codrug5, 
age, order, min(fu_stt) as fu_stt format yymmdd10., max(fu_end) as fu_end format yymmdd10., 
((calculated fu_end)-(calculated fu_stt))/365.25 as fu_year, log(calculated fu_year) as l_fu_year,
season
from sccs_&unit.0
group by outcome, &patientid, &unit., codrug1, codrug2, codrug3, codrug4, codrug5,  age, season, order
order by &patientid, calculated fu_stt;
quit;

proc genmod data=sccs_&unit.;
class &unit.(ref="&reference.") &patientid age /*codrug1-codrug5*/ season;
model outcome=&unit. &patientid age codrug1-codrug5 season / dist=poisson offset=l_fu_year link=log;
ods output ParameterEstimates=result;
quit;

data d.irr_&unit._subfemale; 
set result;
IRR=exp(Estimate);
IRR_Lower=exp(LowerWaldCL);
IRR_Upper=exp(UpperWaldCL);
if Parameter="&unit.";
table="subfemale";
keep Parameter Level1 IRR IRR_Lower IRR_Upper Probchisq table;
run;

proc sql;
ods output SQL_results=d.incidence_&unit._subfemale;
select *, event/person_year as incidence 
from (
select &unit., "&unit." as name, sum(outcome) as event, sum(fu_year) as person_year, "subfemale&unit" as table
from sccs_&unit.
group by &unit.);
quit;

%mend;
title "Subgroup 1: Female";
%subfemale(exposure, 0);
%subfemale(riskperiod0, 0);
*2b Subgroup: Male;
data b.cohort_final_M;
set b.cohort_final;
if &sex="M";
run;
proc sql; 
create table b.final_data_M as
select * 
from b.final_data
where &patientid in (select &patientid from b.cohort_final_M);
quit;
%macro submale(unit, reference);
data sccs_&unit.0;
set b.final_data_M;
by &patientid;
compare=compress(catx("-", outcome, &patientid, &unit., codrug1, codrug2, codrug3, codrug4, codrug5,  age, season));
if compare^=lag(compare) then stt_flag=1; 
if first.&patientid then stt_flag=1;
retain order 0;
order+stt_flag;
drop stt_flag;
run;  

proc sql; 
create table sccs_&unit. as
select distinct outcome, &patientid, &unit., codrug1, codrug2, codrug3, codrug4, codrug5, 
age, order, min(fu_stt) as fu_stt format yymmdd10., max(fu_end) as fu_end format yymmdd10., 
((calculated fu_end)-(calculated fu_stt))/365.25 as fu_year, log(calculated fu_year) as l_fu_year,
season
from sccs_&unit.0
group by outcome, &patientid, &unit., codrug1, codrug2, codrug3, codrug4, codrug5,  age, season, order
order by &patientid, calculated fu_stt;
quit;

proc genmod data=sccs_&unit.;
class &unit.(ref="&reference.") &patientid age /*codrug1-codrug5*/ season;
model outcome=&unit. &patientid age codrug1-codrug5 season / dist=poisson offset=l_fu_year link=log;
ods output ParameterEstimates=result;
quit;

data d.irr_&unit._submale; 
set result;
IRR=exp(Estimate);
IRR_Lower=exp(LowerWaldCL);
IRR_Upper=exp(UpperWaldCL);
if Parameter="&unit.";
table="submale";
keep Parameter Level1 IRR IRR_Lower IRR_Upper Probchisq table;
run;

proc sql;
ods output SQL_results=d.incidence_&unit._submale;
select *, event/person_year as incidence 
from (
select &unit., "&unit." as name, sum(outcome) as event, sum(fu_year) as person_year, "male&unit" as table
from sccs_&unit.
group by &unit.);
quit;

%mend;
title "Subgroup 2: Male";
%submale(exposure, 0);
%submale(riskperiod0, 0);


