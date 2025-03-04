# ADHD-medication-use-and-self-harm

## Introduction
This repository contains the SAS codes used in the study titled, "The use of ADHD medication and the risk of suicide attemptself-harm: A multinational population-based self-controlled case series study". The SAS codes included here were used to analyse data locally at each participating site according to a study-specific common data model (CDM) that standardises the data structures of participating databases. The coordinating centre distributed the common analysis package with SAS codes and output templates, the participating site would generate aggregated results locally and only the final aggregated results from each participating site were shared with the study coordinator. R codes included here were used to pool the aggregated results from each sites by meta-analyses, and generate visualisations of the results. These codes are intended to provide transparency and reproducibility of the study results, and can be used as a reference for similar studies in the future. Please refer to the documentation in the repository for further information on the data used, methods employed, and results obtained. This readme file explains the specification of the SAS and R codes. 

<img width="385" alt="Capture2" src="https://github.com/user-attachments/assets/5a222d29-45a2-421a-bb1e-26608b1d51d6" />


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
2. Add the three tables to library c. Example of directories set:
   - libname a "D:\SAS\sccs_mph\raw"; /*original data*/
   - libname b "D:\SAS\sccs_mph\working library"; /*working library*/
   - libname c "D:\SAS\sccs_mph\common_data_model";  /*Please enter the path which save the coverted CDM*/
   - libname d "D:\SAS\sccs_mph\results";  /*Folder which save the Results*/
4. In programme 1, update the specification of the global macro variables in part 2 SET GLOBAL MACRO VARIABLES. Examples of the macro variables:
   - 	change values on the right of "=";
   - 	%let path=D:\SAS\sccs_mph; 		*Specify the pathname to your data folder*;
   - 	%let datea0='01JAN2001'd;           	*PLEASE UPDATE IF REQUIRED; start date of study period, 01JAN2001'd*;
   - 	%let datea='01JAN2001'd;           	*PLEASE UPDATE IF REQUIRED; start date of observation period, 01JAN2001'd*;
   - 	%let dateb='31DEC2020'd;          	*PLEASE UPDATE IF REQUIRED; end date of observation period, 31DEC2020'd*;
   - 	%let yeare=2000;                    	*PLEASE UPDATE IF REQUIRED; eligible period, for dbs without life-long enrolment*;
5. Do not make changes to any other parts of the code and inform the study coordinator if there is any issues encountered when running the codes.
6. Run programme 1 to 4 one by one. Their corresponding analyses are listed below:
   - 1 Main analysis
   - 2a male
   - 2b female
   - 2c stimulants *
   - 2d non-stimulants *
   - 3 recurrent suicide *
   - 4a without people who died *
   - 4b exposed end date + 1 week *
   - 4c exposed end date + 5 weeks *
   - 4d exposed end date + 10 weeks *
   - 4e adhd rx+ suicide dx + adhd dx *
   - 4f remove ppl with adhd rx 12 months before observation start *
   - **- separate programme files*;

5. Run programme 5 to generate the final output to be sent to the study coordinator. Outputs created by this programme for the study are available in the output folder.


