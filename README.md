# ADHD-medication-use-and-self-harm

## Introduction
This repository contains the SAS codes used in the study titled, "The use of ADHD medication and the risk of suicide attemptself-harm: A multinational population-based self-controlled case series study". The SAS codes included here were used to analyse data locally at each participating site according to a study-specific common data model (CDM) that standardises the data structures of participating databases. The coordinating centre distributed the common analysis package with SAS codes and output templates, the participating site would generate aggregated results locally and only the final aggregated results from each participating site were shared with the study coordinator. R codes included here were used to pool the aggregated results from each sites by meta-analyses, and generate visualisations of the results. These codes are intended to provide transparency and reproducibility of the study results, and can be used as a reference for similar studies in the future. Please refer to the documentation in the repository for further information on the data used, methods employed, and results obtained. This readme file explains the specification of the SAS and R codes. 

## System requirements
SAS codes: 
SAS Version 9.4 or above

R codes:
R version 4.0.4 (2021-02-15) -- "Lost Library Book"
Copyright (C) 2021 The R Foundation for Statistical Computing
Platform: x86_64-w64-mingw32/x64 (64-bit)

## Input data demo
The demo of the input data can be found in the data folder, where the data structures and a synthetic demo of the inputs are provided. Before running the preprocessing codes, make sure the input data format is same to the provided input demo.

Four datasets were used in this study, namely:
1. Drug table
2. Diagnosis table
3. Demographics table

## Instructions for use
Detailed step-by-step explanation of the R codes is available from https://adrienneylc.github.io/R script/. Outputs created by this programme for the study are available in the output folder.
