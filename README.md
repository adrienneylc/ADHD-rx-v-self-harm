# ADHD-medication-use-and-self-harm

## Introduction
This repository contains the SAS codes used in the study titled, "The use of ADHD medication and the risk of suicide attemptself-harm: A multinational population-based self-controlled case series study". The SAS codes included here were used to analyse data locally at each participating site according to a study-specific common data model (CDM) that standardises the data structures of participating databases. The coordinating centre distributed the common analysis package with SAS codes and output templates, the participating site would generate aggregated results locally and only the final aggregated results from each participating site were shared with the study coordinator. R codes included here were used to pool the aggregated results from each sites by meta-analyses, and generate visualisations of the results. These codes are intended to provide transparency and reproducibility of the study results, and can be used as a reference for similar studies in the future. Please refer to the documentation in the repository for further information on the data used, methods employed, and results obtained. This readme file explains the specification of the SAS and R codes. 

![image](https://github.com/user-attachments/assets/1f3d52d6-303c-482c-8b53-4a2211358c7c)


## System requirements
SAS codes: 
SAS Version 9.4 or above

R codes:
R version 4.0.4 (2021-02-15) -- "Lost Library Book"
Copyright (C) 2021 The R Foundation for Statistical Computing
Platform: x86_64-w64-mingw32/x64 (64-bit)


## Input data demo
The demo of the input data can be found in the data folder, where the data structures and a synthetic demo of the inputs are provided. Before running the preprocessing codes, make sure the input data format is same to the provided input demo.

Three data tables were used in this study, namely:
1. Demographics table
2. Drug table
3. Diagnosis table
<img width="547" alt="Capture" src="https://github.com/user-attachments/assets/4d4cd999-a399-484c-96d8-6b782433a247" />

## Instructions for use
1. Clean the local data according to the three prespecified tables above.
2. Add the three tables to library c.
   Example of directories set:
   libname a "D:\SAS\sccs_mph\raw"; /*original data*/
   libname b "D:\SAS\sccs_mph\working library"; /*working library*/
   libname c "D:\SAS\sccs_mph\common_data_model";  /* Please enter the path which save the coverted CDM */
   libname d "D:\SAS\sccs_mph\results";  /* Folder which save the Results */
3. In programme 1, update the specification of the global macro variables in part 2. Do not make changes to any other parts of the code and inform the study coordinator if there is any issues encountered when running the codes.
/*------------------------------------*/
/*	[2] SET GLOBAL MACRO VARIABLES	  */
/*------------------------------------*/
	* change values on the right of "=";

%let path=D:\SAS\sccs_mph; 			*Specify the pathname to your data folder;
%let datea0='01JAN2001'd;           * PLEASE UPDATE IF REQUIRED; *start date of study period, 01JAN2001'd;
%let datea='01JAN2001'd;           	* PLEASE UPDATE IF REQUIRED; *start date of observation period, 01JAN2001'd;
%let dateb='31DEC2020'd;          	* PLEASE UPDATE IF REQUIRED; *end date of observation period, 31DEC2020'd;
%let yeare=2000;                    * PLEASE UPDATE IF REQUIRED; *eligible period, for dbs without life-long enrolment;
%let yeara=2001;                    * PLEASE UPDATE IF REQUIRED; *start year of observation period, 2001;
%let yearb=2020;                    * PLEASE UPDATE IF REQUIRED; *end year of observation period, 2020; 
%let agea=6;                     	* inclusion: age over 6; 
%let patientid=id;      			* Enter the variable name that identifies unique patients in your dataset; 
%let sex=sex;                       * Enter the variable name that specifies the sex of individual patiens; 
%let death_date=death_date;         * Enter the variable name that death date of individual patients; 
%let drugcde=atccde;                * Enter the variable name that specifies the ATC code or NDC code; 
%let trtst=rx_date;                 * Enter the variable name that specifies the prescription start date; 
%let trted=rx_end;                  * Enter the variable name that specifies the prescription end date; 
%let trtday=supply_day;            	* Enter the variable name that specifies the duration of the administration;
%let trtq=supply_quantity;         	* Enter the variable name that specifies the quantity of the drug use;
%let trtdose=dose;                  * Enter the variable name that specifies the dose of the prescribed drug;
%let icdcde=icd9cm;                 * Enter the variable name that specifies the primary diagnosis hospitalisation code (ICD code); 
%let admdt=event_date;             	* Enter the variable name that specifies the hospitalisation admission date; 
%let birth_date=birth_date;         * Enter the variable name of birthday;
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
4. Run programme 1 to 4 one by one. 
Their corresponding analyses are listed below:
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

5. Run programme 5 to generate the final output to be sent to the study coordinator. Outputs created by this programme for the study are available in the output folder.


