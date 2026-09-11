cd "C:\Users\badhhh\OneDrive - University of Missouri\Projects\CRC Screening\NHIS"


clear
quietly infix                   ///
  int     year         1-4      ///
  long    serial       5-10     ///
  int     strata       11-14    ///
  int     psu          15-17    ///
  str     nhishid      18-31    ///
  long    hhweight     32-37    ///
  byte    pernum       38-39    ///
  str     nhispid      40-55    ///
  str     hhx          56-62    ///
  str     fmx          63-64    ///
  str     px           65-66    ///
  double  perweight    67-78    ///
  double  sampweight   79-90    ///
  double  longweight   91-101   ///
  double  partweight   102-112  ///
  double  fweight      113-124  ///
  byte    astatflg     125-125  ///
  byte    cstatflg     126-126  ///
  int     age          127-129  ///
  byte    sex          130-130  ///
  byte    marstcur     131-131  ///
  int     racenew      132-134  ///
  byte    hispyn       135-135  ///
  int     educ         136-138  ///
  byte    hiprivatee   139-139  ///
  byte    coltdr1yr    140-140  ///
  byte    colcanbst    141-141  ///
  byte    colcancolg   142-142  ///
  byte    colcancol    143-143  ///
  byte    colcancolct  144-144  ///
  byte    colcansig    145-145  ///
  byte    colcanoth    146-146  ///
  byte    collesty     147-148  ///
  byte    colly        149-149  ///
  byte    siglesty     150-151  ///
  byte    colsigev     152-152  ///
  using `"nhis_00003.dat"'

replace sampweight  = sampweight  / 1000
replace longweight  = longweight  / 1000
replace partweight  = partweight  / 1000
replace fweight     = fweight     / 1000000

format perweight   %12.0f
format sampweight  %12.3f
format longweight  %11.3f
format partweight  %11.3f
format fweight     %12.6f

label var year        `"Survey year"'
label var serial      `"Sequential Serial Number, Household Record"'
label var strata      `"Stratum for variance estimation"'
label var psu         `"Primary sampling unit (PSU) for variance estimation"'
label var nhishid     `"NHIS Unique identifier, household"'
label var hhweight    `"Household weight, final annual"'
label var pernum      `"Person number within family/household (from reformatting)"'
label var nhispid     `"NHIS Unique Identifier, person"'
label var hhx         `"Household number (from NHIS)"'
label var fmx         `"Family number (from NHIS)"'
label var px          `"Person number of respondent (from NHIS)."'
label var perweight   `"Final basic annual weight"'
label var sampweight  `"Sample Person Weight"'
label var longweight  `"Sample adult weight, longitudinal sample"'
label var partweight  `"Sample adult weight, partial sample"'
label var fweight     `"Final annual family weight"'
label var astatflg    `"Sample adult flag"'
label var cstatflg    `"Sample child flag"'
label var age         `"Age"'
label var sex         `"Sex"'
label var marstcur    `"Current marital status"'
label var racenew     `"Self-reported Race (Post-1997 OMB standards)"'
label var hispyn      `"Hispanic ethnicity, dichotomous"'
label var educ        `"Educational attainment"'
label var hiprivatee  `"Covered by private health insurance: Recode"'
label var coltdr1yr   `"Doctor recommended testing for colon or rectal problems, past 12 months"'
label var colcanbst   `"Doctor recommended blood stool test to check for colon cancer"'
label var colcancolg  `"Doctor recommended Cologuard test to check for colon cancer"'
label var colcancol   `"Doctor recommended colonoscopy to check for colon cancer"'
label var colcancolct `"Doctor recommended CT colonoscopy to check for colon cancer"'
label var colcansig   `"Doctor recommended sigmoidoscopy to check for colon cancer"'
label var colcanoth   `"Doctor recommended other test to check for colon cancer"'
label var collesty    `"Time since last colonoscopy: Grouped year estimate"'
label var colly       `"Main reason for last colonoscopy"'
label var siglesty    `"Time since last sigmoidoscopy: Grouped year estimate"'
label var colsigev    `"Ever had colonoscopy, sigmoidoscopy, or both"'

label define astatflg_lbl 0 `"NIU"'
label define astatflg_lbl 1 `"Sample adult, has record"', add
label define astatflg_lbl 2 `"Sample adult, no record"', add
label define astatflg_lbl 3 `"Not selected as sample adult"', add
label define astatflg_lbl 4 `"No one selected as sample adult"', add
label define astatflg_lbl 5 `"Armed forces member"', add
label define astatflg_lbl 6 `"AF member, selected as sample adult"', add
label values astatflg astatflg_lbl

label define cstatflg_lbl 0 `"NIU"'
label define cstatflg_lbl 1 `"Sample child-has record"', add
label define cstatflg_lbl 2 `"Sample child-no record"', add
label define cstatflg_lbl 3 `"Not selected as sample child"', add
label define cstatflg_lbl 4 `"No one selected as sample child"', add
label define cstatflg_lbl 5 `"Emancipated minor"', add
label values cstatflg cstatflg_lbl

label define sex_lbl 1 `"Male"'
label define sex_lbl 2 `"Female"', add
label define sex_lbl 7 `"Unknown-refused"', add
label define sex_lbl 8 `"Unknown-not ascertained"', add
label define sex_lbl 9 `"Unknown-don't know"', add
label values sex sex_lbl

label define marstcur_lbl 0 `"NIU"'
label define marstcur_lbl 1 `"Married, spouse present"', add
label define marstcur_lbl 2 `"Married, spouse absent"', add
label define marstcur_lbl 3 `"Married, spouse in household unknown"', add
label define marstcur_lbl 4 `"Separated"', add
label define marstcur_lbl 5 `"Divorced"', add
label define marstcur_lbl 6 `"Widowed"', add
label define marstcur_lbl 7 `"Living with partner"', add
label define marstcur_lbl 8 `"Never married"', add
label define marstcur_lbl 9 `"Unknown marital status"', add
label values marstcur marstcur_lbl

label define racenew_lbl 100 `"White only"'
label define racenew_lbl 200 `"Black/African American only"', add
label define racenew_lbl 300 `"American Indian/Alaska Native only"', add
label define racenew_lbl 400 `"Asian only"', add
label define racenew_lbl 500 `"Other Race and Multiple Race"', add
label define racenew_lbl 510 `"Other Race and Multiple Race (2019-forward: Excluding American Indian/Alaska Native)"', add
label define racenew_lbl 520 `"Other Race"', add
label define racenew_lbl 530 `"Race Group Not Releasable"', add
label define racenew_lbl 540 `"Multiple Race"', add
label define racenew_lbl 541 `"Multiple Race (1999-2018: Including American Indian/Alaska Native)"', add
label define racenew_lbl 542 `"American Indian/Alaska Native and Any Other Race"', add
label define racenew_lbl 997 `"Unknown-Refused"', add
label define racenew_lbl 998 `"Unknown-Not ascertained"', add
label define racenew_lbl 999 `"Unknown-Don't Know"', add
label values racenew racenew_lbl

label define hispyn_lbl 1 `"No, not of Hispanic ethnicity"'
label define hispyn_lbl 2 `"Yes, of Hispanic ethnicity"', add
label define hispyn_lbl 7 `"Unknown--refused"', add
label define hispyn_lbl 8 `"Unknown--not ascertained"', add
label define hispyn_lbl 9 `"Unknown--don't know"', add
label values hispyn hispyn_lbl

label define educ_lbl 000 `"NIU"'
label define educ_lbl 100 `"Grade 12 or less, no high school diploma or equivalent"', add
label define educ_lbl 101 `"Grade 8 or less (no further detail)"', add
label define educ_lbl 102 `"Never attended/kindergarten only"', add
label define educ_lbl 103 `"Grades 1-11 (no further detail)"', add
label define educ_lbl 104 `"Grade 1"', add
label define educ_lbl 105 `"Grade 2"', add
label define educ_lbl 106 `"Grade 3"', add
label define educ_lbl 107 `"Grade 4"', add
label define educ_lbl 108 `"Grade 5"', add
label define educ_lbl 109 `"Grade 6"', add
label define educ_lbl 110 `"Grade 7"', add
label define educ_lbl 111 `"Grade 8"', add
label define educ_lbl 112 `"Grade 9-12, no diploma (no further detail)"', add
label define educ_lbl 113 `"Grade 9"', add
label define educ_lbl 114 `"Grade 10"', add
label define educ_lbl 115 `"Grade 11"', add
label define educ_lbl 116 `"12th grade, no diploma"', add
label define educ_lbl 200 `"High school diploma or GED"', add
label define educ_lbl 201 `"High school graduate"', add
label define educ_lbl 202 `"GED or equivalent"', add
label define educ_lbl 300 `"Some college, no 4yr degree"', add
label define educ_lbl 301 `"Some college, no degree"', add
label define educ_lbl 302 `"AA degree: technical/vocational/occupational"', add
label define educ_lbl 303 `"AA degree: academic program"', add
label define educ_lbl 400 `"Bachelor's degree (BA,AB,BS,BBA)"', add
label define educ_lbl 500 `"Master's, Professional, or Doctoral Degree"', add
label define educ_lbl 510 `"Master's degree (MA,MS,Med,MBA)"', add
label define educ_lbl 520 `"Professional School or Doctoral degree (MD, DDS, DVM, JD, PhD, EdD)"', add
label define educ_lbl 521 `"Professional (MD,DDS,DVM,JD)"', add
label define educ_lbl 522 `"Doctoral degree (PhD, EdD)"', add
label define educ_lbl 530 `"Other degree"', add
label define educ_lbl 996 `"No degree, years of education unknown"', add
label define educ_lbl 997 `"Unknown--refused"', add
label define educ_lbl 998 `"Unknown--not ascertained"', add
label define educ_lbl 999 `"Unknown--don't know"', add
label values educ educ_lbl

label define hiprivatee_lbl 1 `"No"'
label define hiprivatee_lbl 2 `"Yes, information"', add
label define hiprivatee_lbl 3 `"Yes, but no information"', add
label define hiprivatee_lbl 7 `"Unknown-refused"', add
label define hiprivatee_lbl 8 `"Unknown-not ascertained"', add
label define hiprivatee_lbl 9 `"Unknown-don't know"', add
label values hiprivatee hiprivatee_lbl

label define coltdr1yr_lbl 0 `"NIU"'
label define coltdr1yr_lbl 1 `"No"', add
label define coltdr1yr_lbl 2 `"Yes"', add
label define coltdr1yr_lbl 7 `"Unknown-refused"', add
label define coltdr1yr_lbl 8 `"Unknown-not ascertained"', add
label define coltdr1yr_lbl 9 `"Unknown-don't know"', add
label values coltdr1yr coltdr1yr_lbl

label define colcanbst_lbl 0 `"NIU"'
label define colcanbst_lbl 1 `"Not mentioned"', add
label define colcanbst_lbl 2 `"Mentioned"', add
label define colcanbst_lbl 7 `"Unknown-refused"', add
label define colcanbst_lbl 8 `"Unknown-not ascertained"', add
label define colcanbst_lbl 9 `"Unknown-don't know"', add
label values colcanbst colcanbst_lbl

label define colcancolg_lbl 0 `"NIU"'
label define colcancolg_lbl 1 `"Not mentioned"', add
label define colcancolg_lbl 2 `"Mentioned"', add
label define colcancolg_lbl 7 `"Unknown-refused"', add
label define colcancolg_lbl 8 `"Unknown-not ascertained"', add
label define colcancolg_lbl 9 `"Unknown-don't know"', add
label values colcancolg colcancolg_lbl

label define colcancol_lbl 0 `"NIU"'
label define colcancol_lbl 1 `"Not mentioned"', add
label define colcancol_lbl 2 `"Mentioned"', add
label define colcancol_lbl 7 `"Unknown-refused"', add
label define colcancol_lbl 8 `"Unknown-not ascertained"', add
label define colcancol_lbl 9 `"Unknown-don't know"', add
label values colcancol colcancol_lbl

label define colcancolct_lbl 0 `"NIU"'
label define colcancolct_lbl 1 `"Not mentioned"', add
label define colcancolct_lbl 2 `"Mentioned"', add
label define colcancolct_lbl 7 `"Unknown-refused"', add
label define colcancolct_lbl 8 `"Unknown-not ascertained"', add
label define colcancolct_lbl 9 `"Unknown-don't know"', add
label values colcancolct colcancolct_lbl

label define colcansig_lbl 0 `"NIU"'
label define colcansig_lbl 1 `"Not mentioned"', add
label define colcansig_lbl 2 `"Mentioned"', add
label define colcansig_lbl 7 `"Unknown-refused"', add
label define colcansig_lbl 8 `"Unknown-not ascertained"', add
label define colcansig_lbl 9 `"Unknown-don't know"', add
label values colcansig colcansig_lbl

label define colcanoth_lbl 0 `"NIU"'
label define colcanoth_lbl 1 `"Not mentioned"', add
label define colcanoth_lbl 2 `"Mentioned"', add
label define colcanoth_lbl 7 `"Unknown-refused"', add
label define colcanoth_lbl 8 `"Unknown-not ascertained"', add
label define colcanoth_lbl 9 `"Unknown-don't know"', add
label values colcanoth colcanoth_lbl

label define collesty_lbl 00 `"NIU"'
label define collesty_lbl 10 `"0-1 years"', add
label define collesty_lbl 11 `"A year ago or less"', add
label define collesty_lbl 12 `"Less than a year ago"', add
label define collesty_lbl 20 `"1-2 years"', add
label define collesty_lbl 21 `"Greater than 1 year - 2 years"', add
label define collesty_lbl 22 `"1 year - less than 2 years"', add
label define collesty_lbl 30 `"2-3 years"', add
label define collesty_lbl 31 `"Greater than 2 years - 3 years"', add
label define collesty_lbl 32 `"2 years - less than 3 years"', add
label define collesty_lbl 40 `"3-5 years"', add
label define collesty_lbl 41 `"Greater than 3 years - 5 years"', add
label define collesty_lbl 42 `"3 years - less than 5 years"', add
label define collesty_lbl 50 `"5-10 years"', add
label define collesty_lbl 51 `"Greater than 5 years - 10 years"', add
label define collesty_lbl 52 `"5 years - less than 10 years"', add
label define collesty_lbl 60 `"10+ years"', add
label define collesty_lbl 61 `"Over 10 years ago"', add
label define collesty_lbl 97 `"Unknown-refused"', add
label define collesty_lbl 98 `"Unknown-not ascertained"', add
label define collesty_lbl 99 `"Unknown-don't know"', add
label values collesty collesty_lbl

label define colly_lbl 0 `"NIU"'
label define colly_lbl 1 `"Part of routine exam"', add
label define colly_lbl 2 `"Because of problem"', add
label define colly_lbl 3 `"Follow-up to earlier test or exam"', add
label define colly_lbl 4 `"Other reason"', add
label define colly_lbl 7 `"Unknown-refused"', add
label define colly_lbl 8 `"Unknown-not ascertained"', add
label define colly_lbl 9 `"Unknown-don't know"', add
label values colly colly_lbl

label define siglesty_lbl 00 `"NIU"'
label define siglesty_lbl 10 `"0-1 years"', add
label define siglesty_lbl 11 `"A year ago or less"', add
label define siglesty_lbl 12 `"Less than a year ago"', add
label define siglesty_lbl 20 `"1-2 years"', add
label define siglesty_lbl 21 `"Greater than 1 year - 2 years"', add
label define siglesty_lbl 22 `"1 year - less than 2 years"', add
label define siglesty_lbl 30 `"2-3 years"', add
label define siglesty_lbl 31 `"Greater than 2 years - 3 years"', add
label define siglesty_lbl 32 `"2 years - less than 3 years"', add
label define siglesty_lbl 40 `"3-5 years"', add
label define siglesty_lbl 41 `"Greater than 3 years - 5 years"', add
label define siglesty_lbl 42 `"3 years - less than 5 years"', add
label define siglesty_lbl 50 `"5-10 years"', add
label define siglesty_lbl 51 `"Greater than 5 years - 10 years"', add
label define siglesty_lbl 52 `"5 years - less than 10 years"', add
label define siglesty_lbl 60 `"10+ years"', add
label define siglesty_lbl 61 `"Over 10 years ago"', add
label define siglesty_lbl 97 `"Unknown-refused"', add
label define siglesty_lbl 98 `"Unknown-not ascertained"', add
label define siglesty_lbl 99 `"Unknown-don't know"', add
label values siglesty siglesty_lbl

label define colsigev_lbl 0 `"NIU"'
label define colsigev_lbl 1 `"Colonoscopy"', add
label define colsigev_lbl 2 `"Sigmoidoscopy"', add
label define colsigev_lbl 3 `"Both"', add
label define colsigev_lbl 4 `"Neither"', add
label define colsigev_lbl 7 `"Unknown - refused"', add
label define colsigev_lbl 8 `"Unknown - not ascertained"', add
label define colsigev_lbl 9 `"Unknown - don't know"', add
label values colsigev colsigev_lbl


gen analysis_sample = ///
    inrange(age,40,49) & age != 45 & ///
    astatflg == 1 & ///
    inlist(hiprivatee,2,3) & ///
    colsigev < 7


*Restrict to years with CRC screening questions
keep if year == 2010 | year == 2013 | year == 2015 | year == 2018 | year == 2019 | year == 2021 | year == 2023



* Sample-construction counts


* Ages 40-44 and 46-49, sample adults
count if inrange(age,40,49) & age != 45 & astatflg == 1
local n_age = r(N)

* Restrict to privately insured
count if inrange(age,40,49) & age != 45 & ///
    astatflg == 1 & inlist(hiprivatee,2,3)
local n_private = r(N)
local excluded_private = `n_age' - `n_private'

* Exclude missing/unknown colonoscopy status
* COLSIGEV 0-4 are retained; 7-9 are unknown/refused
count if inrange(age,40,49) & age != 45 & ///
    astatflg == 1 & inlist(hiprivatee,2,3) & ///
    inrange(colsigev,0,4)
local n_final = r(N)
local excluded_colon = `n_private' - `n_final'

display "Ages 40-44 and 46-49:       " %9.0fc `n_age'
display "Privately insured:          " %9.0fc `n_private'
display "Excluded, not private:      " %9.0fc `excluded_private'
display "Non-missing colonoscopy:    " %9.0fc `n_final'
display "Excluded colonoscopy status:" %9.0fc `excluded_colon'
display "NHIS analytic sample:       " %9.0fc `n_final'


tab colsigev year if age>50, missing
tab colsigev year if age<45, missing

tab sex, missing
tab racenew, missing
tab hispyn, missing

*Create covariates
gen race = . 
replace race = 1 if racenew == 100 & hispyn == 1 
replace race = 2 if racenew == 200 & hispyn == 1 
replace race = 3 if hispyn == 2 
replace race = 4 if racenew == 400 & hispyn == 1 
replace race = 5 if race == . 

label var race   `"Race"'

label define race 1 `"Non-Hispanic White"'
label define race 2 `"Non-Hispanic Black"', add
label define race 3 `"Hispanic"', add
label define race 4 `"Non-Hispanic Asian"', add
label define race 5 `"Other"', add
label values race race 

tab race hispyn
tab race racenew
tab racenew race

tab educ, missing

gen education = . 
replace education = 1 if educ <= 116
replace education = 2 if educ == 201 | educ == 202
replace education = 3 if educ >=301 & educ <305
replace education = 4 if educ >=400
replace education = 5 if educ == 997 | educ == 999

label var education   `"Education"'

label define education 1 `"Less Than High School"'
label define education 2 `"High School/GED"', add
label define education 3 `"Some College"', add
label define education 4 `"College"', add
label define education 5 `"Unknown"', add
label values education education


tab educ education, missing

tab marstcur, missing
gen marital_status = . 
replace marital_status = 1 if marstcur <= 3
replace marital_status = 2 if marstcur == 4
replace marital_status = 3 if marstcur == 5 
replace marital_status = 4 if marstcur == 6 
replace marital_status = 5 if marstcur == 7
replace marital_status = 6 if marstcur == 8 
replace marital_status = 7 if marstcur == 9 

label var marital_status  `"Marital Status"'

label define marital_status 1 `"Married"'
label define marital_status 2 `"Separated"', add
label define marital_status 3 `"Divorced"', add
label define marital_status 4 `"Widowed"', add
label define marital_status 5 `"Living with Partner"', add
label define marital_status 6 `"Never Married"', add
label define marital_status 7 `"Unknown"', add
label values marital_status marital_status

tab marstcur marital_status, missing

gen agebin = . 
replace agebin = 1 if age<45 
replace agebin = 2 if age>=45 & age<50


egen group = group(agebin year)

gen colonoscopy = 0 
replace colonoscopy = 1 if colsigev == 1 | colsigev == 3

gen recommendation = 0 
replace recommendation = 1 if year>=2021 & agebin == 2

gen acs = 0 
replace acs = 1 if year>=2018 & agebin == 2


svyset psu [pweight=sampweight], strata(strata)

gen pre_treatment = analysis_sample == 1 & agebin == 2 & year < 2018

svy, subpop(pre_treatment): mean colonoscopy

gen treat_year = 2018 if agebin == 2
gen ttt = year - treat_year


tab ttt
gen ttt_recommendation = ttt
replace ttt_recommendation = -3 if ttt_recommendation == . 
replace ttt_recommendation = ttt_recommendation +8


gen coef = . 
gen se = . 
gen ci_lower = .
gen ci_upper = .

svy, subpop(analysis_sample): regress colonoscopy acs recommendation i.age i.year i.sex i.race i.marital_status i.education
display "ACS b  = " _b[acs]
display "ACS se = " _se[acs]
display "USP b  = " _b[recommendation]
display "USP se = " _se[recommendation]

lincom acs
local att2 : display %5.4f r(estimate)
local se2  : display %5.4f r(se)

lincom recommendation
local att4 : display %5.4f r(estimate)
local se4  : display %5.4f r(se)


svy, subpop(analysis_sample): regress colonoscopy ib5.ttt_recommendation i.year i.age i.sex i.race i.marital_status i.education

local crit = invttail(e(df_r), .025)

foreach t in -8 -5 0 1 3 5 {
    local k = `t' + 8

    quietly lincom `k'.ttt_recommendation
    replace coef     = r(estimate) if ttt == `t'
    replace ci_lower = r(lb)       if ttt == `t'
    replace ci_upper = r(ub)       if ttt == `t'
}

replace coef = 0 if ttt == -3
replace ci_lower = 0 if ttt == -3
replace ci_upper = 0 if ttt == -3

duplicates drop  ttt,force
keep coef ci_lower ci_upper ttt

sort ttt

twoway (scatter coef ttt) (rcap ci_upper ci_lower ttt, color(stc1)), xline(-0.5 2.5) yline(0) graphregion(color(white)) ytitle(Estimated Coefficient) xtitle(Survey Year) note("ACS ATT: {&beta}(SE) = `att2'(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'**(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) xlabel(-8(1)5, nogrid) xlabel(-8 "2010" -7 "2011" -6 "2012" -5 "2013" -4 "2014" -3 "2015" -2 "2016" -1 "2017" 0 "2018" 1 "2019" 2 "2020" 3 "2021" 4 "2022" 5 "2023") text(0.216 -0.5 "ACS") text(0.216 2.5 "USPSTF")

graph export "NHIS_Colonoscopy.pdf", as(pdf) name("Graph") replace

