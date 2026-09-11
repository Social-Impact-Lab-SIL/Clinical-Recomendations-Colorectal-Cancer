# Replication Package: Clinical Recommendations, Cost Sharing, and Preventive Care: Evidence from Colorectal Cancer Screening

This folder contains the code and instructions to replicate the findings of "Clinical Recommendations, Cost Sharing, and Preventive Care: Evidence from Colorectal Cancer Screening."

## Data Availability Statement
- **HCCI Data:** The primary analysis uses restricted commercial health insurance claims data from the Health Care Cost Institute (HCCI) for 2015–2022. These data cannot be redistributed by the authors and are not included in this repository.

- **NHIS Data:** The supplementary analysis uses publicly available National Health Interview Survey (NHIS) data obtained through IPUMS NHIS for survey years 2010, 2013, 2015, 2018, 2019, 2021, and 2023. The NHIS data are not included in this repository. Researchers can construct the required extract through IPUMS NHIS using the variables specified in `NHIS Analysis.do`.

## Software Requirements
- **Primary Software:** Stata 17

## Instructions
1. Obtain an IPUMS NHIS extract for survey years 2010, 2013, 2015, 2018, 2019, 2021, and 2023 using the variables specified in `NHIS Analysis.do`.
2. Download the extract as a fixed-width `.dat` file.
3. Name the file `nhis_00003.dat` and place it in the same working directory as `NHIS Analysis.do`, or modify the file path in the do-file as needed.
4. Run `NHIS Analysis.do` from start to finish.


## List of Figures

| Exhibit | Script | Output File |
| :--- | :--- | :--- |
| Figure 1 | HCCI analysis code | `figures/Figure 1 - Unadjusted CRC Utilization Trends.png` |
| Figure 2 | HCCI analysis code | `figures/Figure 2a - Any CRC Event Study.png`<br>`figures/Figure 2b - Colonoscopy Event Study.png`<br>`figures/Figure 2c - DNA Test Event Study.png`<br>`figures/Figure 2d - Blood Test Event Study.png` |
| Figure 3 | HCCI analysis code | `figures/Figure 3a - ACS Altnerative.png`<br>`figures/Figure 3b - USPSTF Alternative.png` |
| Figure 4 | HCCI analysis code | `figures/Figure 4a - Randomization Inference ACS Any CRC Screening.png`<br>`figures/Figure 4b - Randomization Inference USPSTF Any CRC Screening.png`<br>`figures/Figure 4c - Randomization Inference ACS Colonoscopy.png`<br>`figures/Figure 4d - Randomization Inference USPSTF Colonoscopy.png`<br>`figures/Figure 4e - Randomization Inference ACS DNA Test.png`<br>`figures/Figure 4f - Randomization Inference USPSTF DNA Test.png`<br>`figures/Figure 4g - Randomization Inference ACS Blood Test.png`<br>`figures/Figure 4h - Randomization Inference USPSTF Blood Test.png` |
| Figure 5 | HCCI analysis code | `figures/Figure 5a Colonoscopy Polyp Removal Event Study.png`<br>`figures/Figure 5b - Colonoscopy No Polyp Removal Event Study.png` |
| Figure 6 | HCCI analysis code | `figures/Figure 6a - ACS Heterogenous Analysis.png`<br>`figures/Figure 6b - USPSTF Heterogenous Analysis.png` |
| Figure 7 | HCCI analysis code | `figures/Figure 7a - ACS by Metropolitan Status.png`<br>`figures/Figure 7b - USPSTF by Metropolitan Status.png` |
| Figure 8 | HCCI analysis code | `figures/Figure 8a - In Network Colonoscopy Event Study.png`<br>`figures/Figure 8b - Out Network Colonoscopy Event Study.png` |
| Figure 9 | HCCI analysis code | `figures/Figure 9a - ACS Cost.png`<br>`figures/Figure 9b - USPSTF Cost.png` |
| Figure 10 | HCCI analysis code | `figures/Figure 10a - ACS Zero OOP Share.png`<br>`figures/Figure 10b - USPSTF Zero OOP Share.png` |
| Figure 11 | HCCI analysis code | `figures/Figure 11a - ACS Cost by Claim Type.png`<br>`figures/Figure 11b - USPSTF Cost by Claim Type.png` |
| Figure 12 | NHIS analysis code | `figures/NHIS_Colonoscopy.pdf` |
| Figure A1 | HCCI/NHIS sample construction | `figures/Figure A1 - Sample Construction.png` |
| Figure A2 | HCCI analysis code | `figures/Figure A2 - Sigmoidoscopy Event Study.png` |
| Figure A3 | HCCI analysis code | `figures/Figure A3a - Share of Colonoscopies with Polyp Trends.png`<br>`figures/Figure A3b - Share of Colonoscopies with Polyp Event Study.png` |
| Figure A4 | HCCI analysis code | `figures/Figure A4a - Colonoscopy Total Cost Event Study.png`<br>`figures/Figure A4b - Patient Cost Event Study.png`<br>`figures/Figure A4c - Colonoscopy Insurer Cost Event Study.png` |
| Figure A5 | HCCI analysis code | `figures/Figure A5a - DNA Cost Event Study.png`<br>`figures/Figure A5b - DNA Patient Cost Event Study.png`<br>`figures/Figure A5c - DNA Insurer Cost.png` |
| Figure A6 | HCCI analysis code | `figures/Figure A6a - Blood Test Cost Event Study.png`<br>`figures/Figure A6b - Blood Test Patient Cost Event Study.png`<br>`figures/Figure A6c - Blood Test Insurer Cost Event Study.png` |
| Figure A7 | HCCI analysis code | `figures/Figure A7a - ACS Cost Winsorized.png`<br>`figures/Figure A7b - USPSTF Cost Winsorized.png` |

## Contact
For questions regarding this replication package, contact Brad Davis at badhhh@missouri.edu.
