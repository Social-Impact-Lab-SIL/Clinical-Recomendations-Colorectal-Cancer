# Clinical Recommendations, Cost Sharing, and Preventive Care: Evidence from Colorectal Cancer Screening

**Status:** Under Review  
**Maintainer:** Brad Davis, Postdoctoral Fellow 
**Last Updated:** September 2026

## Overview

[This project studies how changes in colorectal cancer screening recommendations and associated insurance coverage requirements affected screening utilization and patient cost sharing. We study the 2018 American Cancer Society recommendation and the 2021 U.S. Preventive Services Task Force recommendation using commercial claims data from HCCI and nationally representative NHIS survey data.]

## Repository Structure
├── data/           # Raw and processed data (not committed — see .gitignore)
├── code/           # Analysis scripts
├── output/         # Tables, figures, and results
├── docs/           # Notes, meeting summaries, documentation
└── README.md

## Requirements

Stata 17

## How to Run

NHIS Analysis

The NHIS data used in the analysis are obtained from IPUMS NHIS and are not included in this repository. To reproduce the NHIS results:

1. Obtain an IPUMS NHIS extract for survey years 2010, 2013, 2015, 2018, 2019, 2021, and 2023 using the variables listed below.
2. Download the extract as a fixed-width `.dat` file and place it in the appropriate data directory.
3. Update the working directory and data-file name in the NHIS Stata do-file as needed.
4. Run the do-file from start to finish.

The NHIS data can be obtained from IPUMS NHIS.

## Data Sources

Health Care Cost Institute (HCCI) - The primary analysis uses commercial health insurance claims data from the Health Care Cost Institute (HCCI) for 2015–2022. These data include claims from large commercial insurers across the United States. The HCCI data are restricted and cannot be redistributed by the authors.

National Health Interview Survey (NHIS) - The supplementary analysis uses data from the National Health Interview Survey (NHIS) for 2010, 2013, 2015, 2018, 2019, 2021, and 2023. The data were obtained through IPUMS NHIS and are available at https://nhis.ipums.org/nhis/

NHIS Variables

The IPUMS NHIS extract used in the analysis includes the following variables:

- YEAR
- STRATA
- PSU
- SAMPWEIGHT
- ASTATFLG
- AGE
- SEX
- MARSTCUR
- RACENEW
- HISPYN
- EDUC
- HIPRIVATEE
- COLSIGEV

The extract includes survey years 2010, 2013, 2015, 2018, 2019, 2021, and 2023.

## Contact

[Brad Davis] — [badhhh@missouri] — Social Impact Lab, University of Missouri
