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


## List of Tables and Figures
| Exhibit | Script | Output File |
| :--- | :--- | :--- |
| Table 1 | `02_analysis.do` | `tables/table1.tex` |
| Figure 1 | `03_figures.do` | `figures/map_output.png` |

## Contact
For questions regarding this replication package, contact Brad Davis at badhhh@missouri.edu.
