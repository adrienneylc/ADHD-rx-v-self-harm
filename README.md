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

## Common data approach
We will apply a distributed network approach with a common data model (CDM).27 Briefly, the coordination centre will distribute the common analysis package, generating aggregated results based on the CDM that standardises the data structures of participating databases. Each site will conduct the analysis locally and only the final aggregated results from each participating site will be shared with the study coordinator.28 This approach will allow preservation of data confidentiality since the patient-level data will stay in the local site and the analyses will be executed respectively by each site.27 Moreover, we will be able to maintain the consistency of analysis among sites with the common analysis program.29 The mapping codes for diagnosis and prescription are presented in Table 2.


## Input data demo
The demo of the input data can be found in the data folder, where the data structures and a synthetic demo of the inputs are provided. Before running the preprocessing codes, make sure the input data format is same to the provided input demo.

Three data tables were used in this study, namely:
1. Demographics table
2. Drug table
3. Diagnosis table
<img width="547" alt="Capture" src="https://github.com/user-attachments/assets/4d4cd999-a399-484c-96d8-6b782433a247" />

## Instructions for use
Detailed step-by-step explanation of the R codes is available from https://adrienneylc.github.io/R script/. Outputs created by this programme for the study are available in the output folder.
