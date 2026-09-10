
*Load Physcian Claims
import sas using  "$data\phys_crc_det.sas7bdat",clear
gen phys = 1 
tempfile phys_claims
save `phys_claims'

*Load Outpatient Claims
import sas using  "$data\op_crc_det.sas7bdat",clear
gen op = 1 
tempfile op_claims
save `op_claims'

append using `phys_claims'
drop if calc_allwd<=0

tempfile total_claims
save `total_claims'

destring proc_cd, replace

*Create identifiers for each procedure by cpt code
gen dna_test = 0 
replace dna_test = 1 if proc_cd ==81528 

gen colonoscopy = 0
replace colonoscopy = 1 if proc_cd == 45378 |proc_cd == 45379 |proc_cd == 45380 |proc_cd == 45381 |proc_cd == 45382 |proc_cd == 45383 |proc_cd == 45384 |proc_cd == 45385 |proc_cd == 45386 |proc_cd == 45387 |proc_cd == 45388 |proc_cd == 45389 |proc_cd == 45390 |proc_cd == 45391 |proc_cd == 45392 |proc_cd == 45393 |proc_cd == 45394 |proc_cd == 45395 |proc_cd == 45396 |proc_cd == 45397 |proc_cd == 45398

gen colonoscopy_removal = 0 if colonoscopy == 1 
replace colonoscopy_removal = 1 if proc_cd == 45384 | proc_cd == 45385 | proc_cd == 45388 | proc_cd == 45390

gen fecal_blood_test = 0 
replace fecal_blood_test = 1 if proc_cd ==82270 | proc_cd ==82274

gen sigmoidoscopy = 0 
replace sigmoidoscopy = 1 if proc_cd == 45330 | proc_cd == 45331 | proc_cd == 45332 | proc_cd == 45333  | proc_cd == 45334  | proc_cd == 45335  | proc_cd == 45336  | proc_cd == 45337  | proc_cd == 45338  | proc_cd == 45339  | proc_cd == 45340  | proc_cd == 45341  | proc_cd == 45342  | proc_cd == 45343  | proc_cd == 45344  | proc_cd == 45345  | proc_cd == 45346  | proc_cd == 45347  | proc_cd == 45348  | proc_cd == 45349  | proc_cd == 45350

gen crc_claim = 1 if dna_test == 1 | colonoscopy == 1 | fecal_blood_test == 1 | sigmoidoscopy == 1

keep if dna_test == 1 | colonoscopy == 1 | fecal_blood_test == 1 | sigmoidoscopy == 1

drop if yr == "2012"
drop if yr == "2013"
drop if yr == "2014"

save total_claims.dta, replace
use total_claims.dta,replace 

gen total_cost_colonoscopy =   calc_allwd*colonoscopy
gen    insurer_colonoscopy = amt_net_paid*colonoscopy
gen        oop_colonoscopy =   tot_mem_cs*colonoscopy  
gen      coins_colonoscopy =        coins*colonoscopy
gen      copay_colonoscopy =        copay*colonoscopy 
gen     deduct_colonoscopy =       deduct*colonoscopy

gen total_cost_dna =   calc_allwd*dna_test
gen    insurer_dna = amt_net_paid*dna_test
gen        oop_dna =   tot_mem_cs*dna_test  
gen      coins_dna =        coins*dna_test
gen      copay_dna =        copay*dna_test 
gen     deduct_dna =       deduct*dna_test

gen total_cost_fecal_blood =   calc_allwd*fecal_blood_test
gen    insurer_fecal_blood = amt_net_paid*fecal_blood_test
gen        oop_fecal_blood =   tot_mem_cs*fecal_blood_test  
gen      coins_fecal_blood =        coins*fecal_blood_test
gen      copay_fecal_blood =        copay*fecal_blood_test 
gen     deduct_fecal_blood =       deduct*fecal_blood_test

gen total_cost_sigmoidoscopy =   calc_allwd*sigmoidoscopy
gen    insurer_sigmoidoscopy = amt_net_paid*sigmoidoscopy
gen        oop_sigmoidoscopy =   tot_mem_cs*sigmoidoscopy  
gen      coins_sigmoidoscopy =        coins*sigmoidoscopy
gen      copay_sigmoidoscopy =        copay*sigmoidoscopy 
gen     deduct_sigmoidoscopy =       deduct*sigmoidoscopy

gen total_cost_colonoscopy_op = calc_allwd*colonoscopy*op
gen total_cost_colonoscopy_phys = calc_allwd*colonoscopy*phys

gen insurer_colonoscopy_op = amt_net_paid*colonoscopy*op
gen insurer_colonoscopy_phys = amt_net_paid*colonoscopy*phys

gen oop_colonoscopy_op = tot_mem_cs*colonoscopy*op
gen oop_colonoscopy_phys = tot_mem_cs*colonoscopy*phys

gen colonoscopy_out_network = 0 if colonoscopy == 1 
replace  colonoscopy_out_network = 1 if colonoscopy == 1 & ntwrk_ind == "2"

gen col_phys_out = 1 if colonoscopy == 1 & phys == 1 & ntwrk_ind == "2"
gen col_op_out = 1 if colonoscopy == 1 & op == 1 & ntwrk_ind == "2"

//Clean Cost Data for Analytic Sample
preserve

gen procedure = . 
replace procedure = 1 if colonoscopy == 1 
replace procedure = 2 if dna_test == 1 
replace procedure = 3 if fecal_blood_test == 1 
replace procedure = 4 if sigmoidoscopy == 1 

//Collapse to patient admission level to gather cost information
collapse (max) op phys dna_test colonoscopy colonoscopy_removal sigmoidoscopy fecal_blood_test crc_claim colonoscopy_out_network  (sum) total_cost_colonoscopy insurer_colonoscopy oop_colonoscopy coins_colonoscopy copay_colonoscopy deduct_colonoscopy total_cost_dna insurer_dna oop_dna coins_dna copay_dna deduct_dna total_cost_fecal_blood insurer_fecal_blood oop_fecal_blood coins_fecal_blood copay_fecal_blood deduct_fecal_blood total_cost_sigmoidoscopy insurer_sigmoidoscopy oop_sigmoidoscopy coins_sigmoidoscopy copay_sigmoidoscopy deduct_sigmoidoscopy total_cost_colonoscopy_op total_cost_colonoscopy_phys insurer_colonoscopy_op insurer_colonoscopy_phys oop_colonoscopy_op oop_colonoscopy_phys, by(z_patid fst_dt mnth yr procedure) 

gen colonoscopy_no_removal = 0 if colonoscopy == 1 
replace colonoscopy_no_removal = 1 if colonoscopy_removal == 0 

gen colonoscopy_in_network = 0 if colonoscopy == 1
replace colonoscopy_in_network = 1 if colonoscopy_out_network == 0 

//Make sure cost is missing if procedure doesn't match cost variable
replace total_cost_colonoscopy =  . if colonoscopy == 0
replace    insurer_colonoscopy =  . if colonoscopy == 0
replace        oop_colonoscopy =  . if colonoscopy == 0
replace      coins_colonoscopy =  . if colonoscopy == 0
replace      copay_colonoscopy =  . if colonoscopy == 0
replace     deduct_colonoscopy =  . if colonoscopy == 0

replace total_cost_dna = . if dna_test == 0 
replace    insurer_dna = . if dna_test == 0 
replace        oop_dna = . if dna_test == 0 
replace      coins_dna = . if dna_test == 0 
replace      copay_dna = . if dna_test == 0 
replace     deduct_dna = . if dna_test == 0 

replace total_cost_fecal_blood =  . if fecal_blood_test == 0 
replace    insurer_fecal_blood =  . if fecal_blood_test == 0 
replace        oop_fecal_blood =  . if fecal_blood_test == 0 
replace      coins_fecal_blood =  . if fecal_blood_test == 0 
replace      copay_fecal_blood =  . if fecal_blood_test == 0 
replace     deduct_fecal_blood =  . if fecal_blood_test == 0 

replace total_cost_sigmoidoscopy = . if sigmoidoscopy == 0 
replace    insurer_sigmoidoscopy = . if sigmoidoscopy == 0
replace        oop_sigmoidoscopy = . if sigmoidoscopy == 0
replace      coins_sigmoidoscopy = . if sigmoidoscopy == 0
replace      copay_sigmoidoscopy = . if sigmoidoscopy == 0
replace     deduct_sigmoidoscopy = . if sigmoidoscopy == 0

replace total_cost_colonoscopy_op = . if  colonoscopy == 0
replace total_cost_colonoscopy_phys = . if colonoscopy == 0 
replace insurer_colonoscopy_op = . if  colonoscopy == 0
replace insurer_colonoscopy_phys = . if  colonoscopy == 0
replace oop_colonoscopy_op = . if colonoscopy == 0
replace oop_colonoscopy_phys = . if colonoscopy == 0

gen total_cost_polyp = total_cost_colonoscopy if colonoscopy_removal == 1 
gen oop_polyp = oop_colonoscopy if colonoscopy_removal == 1
gen insurer_polyp = insurer_colonoscopy if colonoscopy_removal == 1

gen total_cost_no_polyp = total_cost_colonoscopy if colonoscopy_no_removal == 1
gen oop_no_polyp = oop_colonoscopy if colonoscopy_no_removal == 1
gen insurer_no_polyp = insurer_colonoscopy if colonoscopy_no_removal == 1

gen zero_oop_colonoscopy = 0 if colonoscopy == 1
replace zero_oop_colonoscopy = 1 if oop_colonoscopy == 0

gen zero_oop_dna = 0 if dna_test == 1 
replace zero_oop_dna = 1 if oop_dna == 0 

gen zero_oop_fecal_blood = 0 if fecal_blood_test == 1 
replace zero_oop_fecal_blood = 1 if oop_fecal_blood == 0 

gen zero_oop_sigmoidoscopy = 0 if sigmoidoscopy == 1 
replace zero_oop_sigmoidoscopy = 1 if oop_sigmoidoscopy == 0 

*Merge with patient information
merge m:1 z_patid yr using "$temp\den_cost_mbr_40_55",keepusing(hdhp* age mbr_cbsa eligbility_month)

keep if _merge == 3

*Restrict to beneficiaries enrolled for the full year
keep if eligbility_month == 12

//Create Winsorized Cost Variables
gen total_cost_colonoscopy_win = total_cost_colonoscopy
gen oop_colonoscopy_win = oop_colonoscopy
gen insurer_colonoscopy_win = insurer_colonoscopy

gen total_cost_dna_win = total_cost_dna
gen oop_dna_win = oop_dna
gen insurer_dna_win = insurer_dna

gen total_cost_fecal_blood_win = total_cost_fecal_blood
gen oop_fecal_blood_win = oop_fecal_blood
gen insurer_fecal_blood_win = insurer_fecal_blood

gen total_cost_sigmoidoscopy_win = total_cost_sigmoidoscopy
gen oop_sigmoidoscopy_win = oop_sigmoidoscopy
gen insurer_sigmoidoscopy_win = insurer_sigmoidoscopy

destring yr, gen(year)
*Winsorize Cost Variables by procedure and year

 forvalues i = 2015/2022{
	
display `i'
sum total_cost_colonoscopy if year == `i', detail
replace total_cost_colonoscopy_win = r(p1) if total_cost_colonoscopy<r(p1) & colonoscopy == 1 & year == `i' & total_cost_colonoscopy_win != . 
replace total_cost_colonoscopy_win = r(p99) if total_cost_colonoscopy>r(p99) & colonoscopy == 1 & year == `i' & total_cost_colonoscopy_win != .

sum oop_colonoscopy if year == `i', detail
replace oop_colonoscopy_win = r(p1)  if oop_colonoscopy<r(p1) & colonoscopy == 1 & year == `i'  & oop_colonoscopy_win != .
replace oop_colonoscopy_win = r(p99) if oop_colonoscopy>r(p99) & colonoscopy == 1 & year == `i' & oop_colonoscopy_win != .

sum insurer_colonoscopy if year == `i', detail
replace insurer_colonoscopy_win = r(p1)  if insurer_colonoscopy<r(p1) & colonoscopy == 1 & year == `i'  & insurer_colonoscopy_win != .
replace insurer_colonoscopy_win = r(p99) if insurer_colonoscopy>r(p99) & colonoscopy == 1 & year == `i' & insurer_colonoscopy_win != .


sum total_cost_dna if year == `i', detail
replace total_cost_dna_win = r(p1)  if total_cost_dna<r(p1)  & dna_test == 1 & year == `i' & total_cost_dna_win != . 
replace total_cost_dna_win = r(p99) if total_cost_dna>r(p99) & dna_test == 1 & year == `i' & total_cost_dna_win != . 

sum oop_dna if year == `i', detail
replace oop_dna_win = r(p1)  if oop_dna<r(p1)  & dna_test == 1 & year == `i' & oop_dna_win != . 
replace oop_dna_win = r(p99) if oop_dna>r(p99) & dna_test == 1 & year == `i' & oop_dna_win != . 

sum insurer_dna if year == `i', detail
replace insurer_dna_win = r(p1)  if insurer_dna<r(p1)  & dna_test == 1 & year == `i' & insurer_dna_win != . 
replace insurer_dna_win = r(p99) if insurer_dna>r(p99) & dna_test == 1 & year == `i' & insurer_dna_win != . 


sum total_cost_fecal_blood if year == `i', detail
replace total_cost_fecal_blood_win = r(p1)  if total_cost_fecal_blood<r(p1)  & fecal_blood_test == 1 & year == `i' & total_cost_fecal_blood_win !=. 
replace total_cost_fecal_blood_win = r(p99) if total_cost_fecal_blood>r(p99) & fecal_blood_test == 1 & year == `i' & total_cost_fecal_blood_win !=.

sum oop_fecal_blood if year == `i', detail
replace oop_fecal_blood_win = r(p1)  if oop_fecal_blood<r(p1)  & fecal_blood_test == 1 & year == `i' & oop_fecal_blood_win !=.
replace oop_fecal_blood_win = r(p99) if oop_fecal_blood>r(p99) & fecal_blood_test == 1 & year == `i' & oop_fecal_blood_win !=.

sum insurer_fecal_blood if year == `i', detail
replace insurer_fecal_blood_win = r(p1)  if insurer_fecal_blood<r(p1)  & fecal_blood_test == 1 & year == `i' & insurer_fecal_blood_win !=.
replace insurer_fecal_blood_win = r(p99) if insurer_fecal_blood>r(p99) & fecal_blood_test == 1 & year == `i' & insurer_fecal_blood_win !=.

sum total_cost_sigmoidoscopy if year == `i', detail
replace total_cost_sigmoidoscopy_win = r(p1)  if total_cost_sigmoidoscopy<r(p1)  & sigmoidoscopy == 1 & year == `i' & total_cost_sigmoidoscopy_win != . 
replace total_cost_sigmoidoscopy_win = r(p99) if total_cost_sigmoidoscopy>r(p99) & sigmoidoscopy == 1 & year == `i' & total_cost_sigmoidoscopy_win != .

sum oop_sigmoidoscopy if year == `i', detail
replace oop_sigmoidoscopy_win = r(p1)  if oop_sigmoidoscopy<r(p1)  & sigmoidoscopy == 1 & year == `i' & oop_sigmoidoscopy_win != .
replace oop_sigmoidoscopy_win = r(p99) if oop_sigmoidoscopy>r(p99) & sigmoidoscopy == 1 & year == `i' & oop_sigmoidoscopy_win != .

sum insurer_sigmoidoscopy if year == `i', detail
replace insurer_sigmoidoscopy_win = r(p1)  if insurer_sigmoidoscopy<r(p1)  & sigmoidoscopy == 1 & year == `i' & insurer_sigmoidoscopy_win != .
replace insurer_sigmoidoscopy_win = r(p99) if insurer_sigmoidoscopy>r(p99) & sigmoidoscopy == 1 & year == `i' & insurer_sigmoidoscopy_win != .

}

destring yr, replace
destring mnth, replace

*Collapse procedure-level to age-month-year level. 
collapse (mean) total_cost_colonoscopy total_cost_colonoscopy_win insurer_colonoscopy insurer_colonoscopy_win oop_colonoscopy oop_colonoscopy_win coins_colonoscopy copay_colonoscopy deduct_colonoscopy total_cost_dna total_cost_dna_win insurer_dna insurer_dna_win oop_dna oop_dna_win coins_dna copay_dna deduct_dna total_cost_fecal_blood total_cost_fecal_blood_win insurer_fecal_blood insurer_fecal_blood_win oop_fecal_blood oop_fecal_blood_win coins_fecal_blood copay_fecal_blood deduct_fecal_blood total_cost_sigmoidoscopy total_cost_sigmoidoscopy_win insurer_sigmoidoscopy insurer_sigmoidoscopy_win oop_sigmoidoscopy oop_sigmoidoscopy_win coins_sigmoidoscopy copay_sigmoidoscopy deduct_sigmoidoscopy total_cost_polyp oop_polyp insurer_polyp total_cost_no_polyp oop_no_polyp insurer_no_polyp zero_oop_colonoscopy zero_oop_dna zero_oop_fecal_blood zero_oop_sigmoidoscopy total_cost_colonoscopy_op total_cost_colonoscopy_phys insurer_colonoscopy_op insurer_colonoscopy_phys oop_colonoscopy_op oop_colonoscopy_phys, by(mnth yr age) 

save cost_analytic.dta, replace 

restore 

*Create indicator for stool based test in previous 6 months
gen stool = 1 if fecal_blood_test == 1 | dna_test == 1 

sort z_patid fst_dt

rangestat (max) stool, by(z_patid) interval(fst_dt -180 -1)

*Collpase procedure-level to patient-month-year level. 
collapse (max) op phys dna_test colonoscopy colonoscopy_removal sigmoidoscopy fecal_blood_test crc_claim colonoscopy_out_network stool_max col_op_out col_phys_out, by(z_patid mnth yr) 

gen colonoscopy_no_removal = 0 if colonoscopy == 1 
replace colonoscopy_no_removal = 1 if colonoscopy_removal == 0 

gen colonoscopy_in_network = 0 if colonoscopy == 1
replace colonoscopy_in_network = 1 if colonoscopy_out_network == 0 

save claims_collapsed.dta, replace


****************Create numerator at age-mnth-yr*****************
use claims_collapsed.dta, replace

*Merge with patient information
merge m:1 z_patid yr using "$temp\den_cost_mbr_40_55",keepusing(hdhp* age mbr_cbsa eligbility_month)
keep if _merge == 3
keep if eligbility_month == 12
destring yr, replace
destring mnth, replace

*Collapse to age-month-year level
collapse (sum) dna_test fecal_blood_test sigmoidoscopy colonoscopy colonoscopy_removal colonoscopy_no_removal crc_claim colonoscopy_in_network colonoscopy_out_network col_phys_out col_op_out, by(mnth yr age) 

save utilization_all.dta, replace

//Create numerator for heterogenous analysis (by sex, insurance type, beneficiary type, metropolitan status)
use claims_collapsed.dta, replace

collapse (max) dna_test fecal_blood_test sigmoidoscopy colonoscopy crc_claim, by(z_patid mnth yr) 

merge m:1 z_patid yr using "$temp\den_cost_mbr_40_55",keepusing(hdhp* age mbr_cbsa sex prod rel_cd eligbility_month)
keep if _merge == 3
keep if eligbility_month == 12
gen geography = "urban"
replace geography = "rural" if mbr_cbsa == "99999"
destring yr, replace
destring mnth, replace

save temp_het.dta,replace 

collapse (sum) dna_test fecal_blood_test sigmoidoscopy colonoscopy crc_claim, by(mnth yr age sex) 

reshape wide colonoscopy dna_test fecal_blood_test sigmoidoscopy crc_claim, i(mnth yr age) j(sex) string
save het_sex.dta,replace

use temp_het.dta,replace
collapse (sum) dna_test fecal_blood_test sigmoidoscopy colonoscopy crc_claim, by(mnth yr age prod) 
reshape wide colonoscopy dna_test fecal_blood_test sigmoidoscopy crc_claim, i(mnth yr age) j(prod) string
save het_prod.dta,replace 


use temp_het.dta,replace 
collapse (sum) dna_test fecal_blood_test sigmoidoscopy colonoscopy crc_claim, by(mnth yr age rel_cd) 
reshape wide colonoscopy dna_test fecal_blood_test sigmoidoscopy crc_claim, i(mnth yr age) j(rel_cd) string
save het_rel.dta,replace 

use temp_het.dta,replace 
collapse (sum) dna_test fecal_blood_test sigmoidoscopy colonoscopy crc_claim, by(mnth yr age geography)


reshape wide colonoscopy dna_test fecal_blood_test sigmoidoscopy crc_claim, i(mnth yr age) j(geography) string

egen total_crc_rural = sum(crc_claimrural)
egen total_colonoscopy_rural = sum(colonoscopyrural)
egen total_dna_rural = sum(dna_testrural)
egen total_blood_rural = sum(fecal_blood_testrural)

egen total_crc_urban = sum(crc_claimurban)
egen total_colonoscopy_urban = sum(colonoscopyurban)
egen total_dna_urban = sum(dna_testurban)
egen total_blood_urban = sum(fecal_blood_testurban)

save het_geo.dta, replace

use het_sex.dta, replace 
merge 1:1 mnth age yr using "K:\Research\Team57\ACS Project\Colorectal_cancer project\data\het_prod.dta"
merge 1:1 mnth age yr using "K:\Research\Team57\ACS Project\Colorectal_cancer project\data\het_rel.dta", generate(_merge2)
merge 1:1 mnth age yr using "K:\Research\Team57\ACS Project\Colorectal_cancer project\data\het_geo.dta", generate(_merge3)

save utilization_het.dta, replace

**************Create Denominator**********
use "$temp\den_cost_mbr_40_55", clear
destring yr, replace
count if age<50

//Total Denominator Count - Dropping 2020
preserve
drop if age>49
drop if age == 50 | age == 45
drop if yr == 2020
keep if eligbility_month == 12
duplicates drop z_patid, force
count 
restore 

//Denominator for Pre-treatment Means
preserve
drop if age>49
drop if age<46
drop if yr >2018
keep if eligbility_month == 12
bysort z_patid: egen total_months = sum(eligbility_month)
duplicates drop z_patid, force
count 
restore 

keep if eligbility_month == 12

//Table 1 Panel A: Summary Statistics
preserve 
drop if age>49
drop if age == 50 | age == 45
keep if eligbility_month == 12

bysort z_patid: egen total_months = sum(eligbility_month)

replace male = 0 if male == . 
replace male = male*100

gen ppo = 0 
gen pos = 0
gen hmo = 0
gen dependent = 0
gen metro = 0

replace ppo = 1 if prod == "PPO"
replace pos = 1 if prod == "POS"
replace hmo = 1 if prod == "HMO"
replace dependent = 1 if rel_cd == "DEP"
replace metro = 1 if mbr_cbsa != "99999"

replace ppo = ppo*100
replace pos = pos*100
replace hmo = hmo*100
replace dependent = dependent*100
replace metro = metro*100

sum male ppo pos hmo dependent metro total_months

tab age, missing
tab sex, missing
tab prod, missing
tab rel_cd, missing 

duplicates drop z_patid, force
count

restore


replace male = 0 if male == . 

gen dependent = 0 
replace dependent = 1 if rel_cd == "DEP"

gen ppo = 0 
replace ppo = 1 if prod == "PPO"

gen pos = 0 
replace pos = 1 if prod == "POS"

gen hmo = 0 
replace hmo = 1 if prod == "HMO"

gen people = 1 

collapse (sum) people (mean) male dependent ppo pos hmo, by(yr age)

egen total_people = sum(people)

save denominator_people_all.dta, replace

use "$temp\den_cost_mbr_40_55", clear
keep if eligbility_month == 12
gen hmo = 1 if prod == "HMO"
gen pos = 1 if prod == "POS"
gen ppo = 1 if prod == "PPO"
gen other = 1 if prod == "EPO" | prod == "IND" | prod == "UNK"
gen dep = 1 if rel_cd == "DEP"
gen sub = 1 if rel_cd == "SUB"
gen rural = 1 if mbr_cbsa == "99999"
gen urban = 1 if mbr_cbsa != "99999"


	gen hmo_male = .
replace hmo_male = 0 if prod == "HMO" & male == . 
replace hmo_male = 1 if prod == "HMO" & male == 1 

	gen ppo_male = .
replace ppo_male = 0 if prod == "PPO" & male == . 
replace ppo_male = 1 if prod == "PPO" & male == 1 

	gen pos_male = .
replace pos_male = 0 if prod == "POS" & male == . 
replace pos_male = 1 if prod == "POS" & male == 1 

gen dep_male = .
replace dep_male = 0 if rel_cd == "DEP" & male == . 
replace dep_male = 1 if rel_cd == "DEP" & male == 1 

gen sub_male = .
replace sub_male = 0 if rel_cd == "SUB" & male == . 
replace sub_male = 1 if rel_cd == "SUB" & male == 1


gen male_dep = . 
replace male_dep = 0 if male == 1 & rel_cd == "SUB"
replace male_dep = 1 if male == 1 & rel_cd == "DEP"

    gen female_dep = . 
replace female_dep = 0 if female == 1 & rel_cd == "SUB"
replace female_dep = 1 if female == 1 & rel_cd == "DEP"

    gen hmo_dep = . 
replace hmo_dep = 0 if prod == "HMO" & rel_cd == "SUB"
replace hmo_dep = 1 if prod == "HMO" & rel_cd == "DEP"

    gen ppo_dep = . 
replace ppo_dep = 0 if prod == "PPO" & rel_cd == "SUB"
replace ppo_dep = 1 if prod == "PPO" & rel_cd == "DEP"

    gen pos_dep = . 
replace pos_dep = 0 if prod == "POS" & rel_cd == "SUB"
replace pos_dep = 1 if prod == "POS" & rel_cd == "DEP"

	gen rural_male = . 
replace rural_male = 0 if rural == 1 & male == . 
replace rural_male = 1 if rural == 1 & male == 1 

	gen rural_dep = . 
replace rural_dep = 0 if rural == 1 & rel_cd == "SUB"
replace rural_dep = 1 if rural == 1 & rel_cd == "DEP"

	gen urban_male = . 
replace urban_male = 0 if urban == 1 & male == . 
replace urban_male = 1 if urban == 1 & male == 1 

	gen urban_dep = . 
replace urban_dep = 0 if urban == 1 & rel_cd == "SUB"
replace urban_dep = 1 if urban == 1 & rel_cd == "DEP"

collapse (mean) hmo_male ppo_male pos_male dep_male sub_male male_dep female_dep hmo_dep ppo_dep pos_dep rural_male rural_dep urban_male urban_dep (sum) male female hmo pos ppo other dep sub rural urban, by(yr age)

destring yr, replace

rename male male_denom
rename female female_denom 
rename hmo hmo_denom 
rename pos pos_denom
rename ppo ppo_denom
rename dep dep_denom
rename sub sub_denom
rename rural rural_denom
rename urban urban_denom

save denominator_hetergenous.dta, replace

*************Add Denominator to Numerator*****************
use utilization_all.dta, replace
merge m:1 yr age using denominator_people_all.dta
drop _merge 

gen crc_claim_rate = crc_claim/people*1000
gen dna_claim_rate = dna_test/people*1000
gen colonoscopy_claim_rate = colonoscopy/people*1000
gen sigmoidoscopy_claim_rate = sigmoidoscopy/people*1000
gen fecal_blood_test_claim_rate = fecal_blood_test/people*1000
gen col_removal_claim_rate = colonoscopy_removal/people*1000
gen col_no_removal_claim_rate = colonoscopy_no_removal/people*1000
gen col_in_netork_claim_rate = colonoscopy_in_network/people*1000
gen col_out_network_claim_rate = colonoscopy_out_network/people*1000
gen col_phys_out_claim_rate = col_phys_out/people*1000
gen col_op_out_claim_rate = col_op_out/people*1000


gen time = ym(yr, mnth)

//USPSTF treatment variable
gen recommendation = 0 
replace recommendation = 1 if age>44 & age<50 & time>=736

//ACS treatment variable
gen acs = 0 
replace acs = 1 if age>44 & age<50 & time>=700

merge 1:1 yr mnth age using "K:\Research\Team57\ACS Project\Colorectal_cancer project\data\cost_analytic.dta"

//Create variables to store results
gen coef = . 
gen ci_lower = . 
gen ci_upper = . 

forvalues i = 1/7{
	
gen coef`i' = . 
gen ci_lower`i' = .
gen ci_upper`i' = .
gen coef`i'b = . 
gen ci_lower`i'b = .
gen ci_upper`i'b = .
	
}

gen treat_time = 700 if age>44 & age<50
gen ttt = time - treat_time

xtset age time

*Impute values for missing DNA cost values
replace total_cost_dna_win = l.total_cost_dna_win if total_cost_dna_win == . 
replace oop_dna_win = l.oop_dna_win if oop_dna_win == .
replace insurer_dna_win = l.insurer_dna_win if insurer_dna_win == .

forvalue i = 1/45{
	
	replace total_cost_dna_win = f.total_cost_dna_win if total_cost_dna_win == . 
	replace oop_dna_win = f.oop_dna_win if oop_dna_win == .
	replace insurer_dna_win = f.insurer_dna_win if insurer_dna_win == . 
}

replace total_cost_dna = l.total_cost_dna if total_cost_dna == . 
replace oop_dna = l.oop_dna if oop_dna == .
replace insurer_dna = l.insurer_dna if insurer_dna == .

forvalue i = 1/45{
	
	replace total_cost_dna = f.total_cost_dna if total_cost_dna == . 
	replace oop_dna = f.oop_dna if oop_dna == .
	replace insurer_dna = f.insurer_dna if insurer_dna == . 
}


save analytic_full_sample.dta,replace 

use utilization_het.dta, replace
drop _merge
merge m:1 yr age using denominator_hetergenous.dta

gen crc_claim_rate_M = crc_claimM/male_denom*1000
gen crc_claim_rate_F = crc_claimF/female_denom*1000
gen crc_claim_rate_HMO = crc_claimHMO/hmo_denom*1000
gen crc_claim_rate_PPO = crc_claimPPO/ppo_denom*1000
gen crc_claim_rate_POS = crc_claimPOS/pos_denom*1000
gen crc_claim_rate_DEP = crc_claimDEP/dep_denom*1000
gen crc_claim_rate_SUB = crc_claimSUB/sub_denom*1000
gen crc_claim_rate_urban = crc_claimurban/urban_denom*1000
gen crc_claim_rate_rural = crc_claimrural/rural_denom*1000

gen colonoscopies_claim_rate_M = colonoscopyM/male_denom*1000
gen colonoscopies_claim_rate_F = colonoscopyF/female_denom*1000
gen colonoscopies_claim_rate_HMO = colonoscopyHMO/hmo_denom*1000
gen colonoscopies_claim_rate_PPO = colonoscopyPPO/ppo_denom*1000
gen colonoscopies_claim_rate_POS = colonoscopyPOS/pos_denom*1000
gen colonoscopies_claim_rate_DEP = colonoscopyDEP/dep_denom*1000
gen colonoscopies_claim_rate_SUB = colonoscopySUB/sub_denom*1000
gen colonoscopies_claim_rate_urban = colonoscopyurban/urban_denom*1000
gen colonoscopies_claim_rate_rural = colonoscopyrural/rural_denom*1000

gen dna_claim_rate_M = dna_testM/male_denom*1000
gen dna_claim_rate_F = dna_testF/female_denom*1000
gen dna_claim_rate_HMO = dna_testHMO/hmo_denom*1000
gen dna_claim_rate_PPO = dna_testPPO/ppo_denom*1000
gen dna_claim_rate_POS = dna_testPOS/pos_denom*1000
gen dna_claim_rate_SUB = dna_testSUB/sub_denom*1000
gen dna_claim_rate_DEP = dna_testDEP/dep_denom*1000
gen dna_claim_rate_urban = dna_testurban/urban_denom*1000
gen dna_claim_rate_rural = dna_testrural/rural_denom*1000

gen fecal_blood_test_claim_rate_M = fecal_blood_testM/male_denom*1000
gen fecal_blood_test_claim_rate_F = fecal_blood_testF/female_denom*1000
gen fecal_blood_test_claim_rate_HMO = fecal_blood_testHMO /hmo_denom*1000
gen fecal_blood_test_claim_rate_PPO = fecal_blood_testPPO /ppo_denom*1000
gen fecal_blood_test_claim_rate_POS = fecal_blood_testPOS /pos_denom*1000
gen fecal_blood_test_claim_rate_SUB = fecal_blood_testSUB /sub_denom*1000
gen fecal_blood_test_claim_rate_DEP = fecal_blood_testDEP /dep_denom*1000
gen fecal_blood_test_claim_rate_urb = fecal_blood_testurban /urban_denom*1000
gen fecal_blood_test_claim_rate_rur = fecal_blood_testrural /rural_denom*1000

gen time = ym(yr, mnth)

gen recommendation = 0 
replace recommendation = 1 if age>44 & age<50 & time>=736

gen acs = 0 
replace acs = 1 if age>44 & age<50 & time>=700

//Create variables to store results

forvalues i = 1/7{
	
gen coef`i' = . 
gen ci_lower`i' = .
gen ci_upper`i' = .
gen coef`i'b = . 
gen ci_lower`i'b = .
gen ci_upper`i'b = .
}

save analytic_heterogenous.dta, replace 

log close


sort age time

log using "K:\Research\Team57\ACS Project\Colorectal_cancer project\output\Analyses.log", replace


*******Figure 1 -  Utilization Time Trends******* 
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50

gen group = . 
replace group = 1 if age<45
replace group = 2 if age>45 & age<50
replace group = 3 if age>50


collapse (sum) crc_claim people (mean) crc_claim_rate colonoscopy_claim_rate dna_claim_rate oop_colonoscopy total_cost_dna total_cost_dna_win, by(group yr mnth time) 


twoway (line crc_claim_rate time if group == 1, lpattern(longdash))(line crc_claim_rate time if group == 2)(line crc_claim_rate time if group == 3, lpattern(dash_dot)), xline(699.5 735.5) xlabel(660 "1/15" 672 "1/16" 684 "1/17" 696 "1/18" 708 "1/19" 720 "1/20" 732 "1/21" 744 "1/22", nogrid)legend(order(1 "40-44 Years" 2 "46-49 Years" 3 "51-55 Years" ) position(6) col(3)) xtitle("Month/Year") ytitle(CRC Screening Claim Rate) text(21 699.5 "ACS") text(21 735.5 "USPSTF")

twoway (line crc_claim_rate time if group == 1, lpattern(longdash))(line crc_claim_rate time if group == 2), xline(699.5 735.5) xlabel(660 "1/15" 672 "1/16" 684 "1/17" 696 "1/18" 708 "1/19" 720 "1/20" 732 "1/21" 744 "1/22", nogrid)legend(order(1 "40-44 Years" 2 "46-49 Years") position(6) col(3)) xtitle("Month/Year") ytitle(CRC Screening Claim Rate) text(16.65 699.5 "ACS") text(16.65 735.5 "USPSTF")


***************Figure 2a - CRC Claim Rate************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

sum ttt
gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40

regress crc_claim_rate acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress crc_claim_rate ib39.ttt_rec i.time i.age male dependent, cluster(age)

forvalues i = 0/100{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") ylabel(-5(5)10) note("ACS ATT: {&beta}(SE) = `att2'(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'***(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) ylabel(-2(2)12) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ytitle("Estimated Coefficient") text(13 -1 "ACS") text(13 35.5 "USPSTF")

***************Figure 2b - Colonoscopy Claim Rate************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

sum ttt
gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40
tab ttt_rec

regress colonoscopy_claim_rate acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress colonoscopy_claim_rate ib39.ttt_rec i.time i.age male dependent, cluster(age)

forvalues i = 0/90{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") ylabel(-5(5)10) note("ACS ATT: {&beta}(SE) = `att2'(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'***(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) ylabel(-2(2)12) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ytitle("Estimated Coefficient") text(12.9 -1 "ACS") text(12.9 35.5 "USPSTF")

***************Figure 2c - DNA Claim Rate************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

sum ttt
gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40
tab ttt_rec

regress dna_claim_rate acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress dna_claim_rate ib39.ttt_rec i.time i.age male dependent, cluster(age)

forvalues i = 0/100{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") ylabel(-5(5)10) note("ACS ATT: {&beta}(SE) = `att2'(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'***(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) ylabel(-2(2)12) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ytitle("Estimated Coefficient") text(12.9 -1 "ACS") text(12.9 35.5 "USPSTF")

*******Figure 2d - Stool-Based Blood Test********
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

sum ttt
gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40
tab ttt_rec

regress fecal_blood_test_claim_rate acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress fecal_blood_test_claim_rate ib39.ttt_rec i.time i.age male dependent, cluster(age)

forvalues i = 0/120{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") ylabel(-5(5)10) note("ACS ATT: {&beta}(SE) = `att2'**(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'***(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) ylabel(-2(2)12) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ytitle("Estimated Coefficient") text(12.9 -1 "ACS") text(12.9 35.5 "USPSTF")


*********Figure 3 - Alternate Specifications**************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50

gen specification = runiformint(0,24)
regress crc_claim_rate recommendation acs male dependent i.time i.age if age<50, cluster(age)
    replace coef1 = r(table)[1,1] if specification == 1 
replace ci_lower1 = r(table)[5,1] if specification == 1
replace ci_upper1 = r(table)[6,1] if specification == 1

    replace coef1b = r(table)[1,2] if specification == 1 
replace ci_lower1b = r(table)[5,2] if specification == 1
replace ci_upper1b = r(table)[6,2] if specification == 1

regress crc_claim_rate recommendation acs i.time i.age if age<50, cluster(age)

    replace coef1 = r(table)[1,1] if specification == 2 
replace ci_lower1 = r(table)[5,1] if specification == 2
replace ci_upper1 = r(table)[6,1] if specification == 2

    replace coef1b = r(table)[1,2] if specification == 2 
replace ci_lower1b = r(table)[5,2] if specification == 2
replace ci_upper1b = r(table)[6,2] if specification == 2

regress crc_claim_rate recommendation acs male dependent i.time i.age if yr != 2020 & age<50, cluster(age)

replace coef1 = r(table)[1,1]     if specification == 3
replace ci_lower1 = r(table)[5,1] if specification == 3
replace ci_upper1 = r(table)[6,1] if specification == 3

    replace coef1b = r(table)[1,2] if specification == 3
replace ci_lower1b = r(table)[5,2] if specification == 3
replace ci_upper1b = r(table)[6,2] if specification == 3

sdid crc_claim_rate age time recommendation if age<50, vce(bootstrap) covariates(male dependent) reps(10)
replace     coef1 = e(ATT)              if specification == 4
replace ci_lower1 = e(ATT)-(1.96*e(se)) if specification == 4
replace ci_upper1 = e(ATT)+(1.96*e(se)) if specification == 4

sdid crc_claim_rate age time acs if time<736 & age<50, vce(bootstrap) covariates(male dependent) reps(500)
replace     coef1b = e(ATT)              if specification == 4
replace ci_lower1b = e(ATT)-(1.96*e(se)) if specification == 4
replace ci_upper1b = e(ATT)+(1.96*e(se)) if specification == 4

sdid crc_claim_rate age time recommendation, vce(bootstrap) covariates(male dependent) reps(10)
replace     coef1 = e(ATT)              if specification == 5
replace ci_lower1 = e(ATT)-(1.96*e(se)) if specification == 5
replace ci_upper1 = e(ATT)+(1.96*e(se)) if specification == 5

sdid crc_claim_rate age time acs if time<736, vce(bootstrap) covariates(male dependent) reps(500)
replace     coef1b = e(ATT)              if specification == 5
replace ci_lower1b = e(ATT)-(1.96*e(se)) if specification == 5
replace ci_upper1b = e(ATT)+(1.96*e(se)) if specification == 5



regress colonoscopy_claim_rate recommendation acs male dependent i.time i.age if age<50, cluster(age)
replace coef2 = r(table)[1,1]     if specification == 7 
replace ci_lower2 = r(table)[5,1] if specification == 7
replace ci_upper2 = r(table)[6,1] if specification == 7

    replace coef2b = r(table)[1,2] if specification == 7 
replace ci_lower2b = r(table)[5,2] if specification == 7
replace ci_upper2b = r(table)[6,2] if specification == 7

regress colonoscopy_claim_rate recommendation acs i.time i.age if age<50, cluster(age)

replace coef2 = r(table)[1,1]     if specification == 8 
replace ci_lower2 = r(table)[5,1] if specification == 8
replace ci_upper2 = r(table)[6,1] if specification == 8

    replace coef2b = r(table)[1,2] if specification == 8 
replace ci_lower2b = r(table)[5,2] if specification == 8
replace ci_upper2b = r(table)[6,2] if specification == 8

regress colonoscopy_claim_rate recommendation acs male dependent i.time i.age if yr != 2020 & age<50, cluster(age)

replace coef2 = r(table)[1,1]     if specification == 9
replace ci_lower2 = r(table)[5,1] if specification == 9
replace ci_upper2 = r(table)[6,1] if specification == 9

    replace coef2b = r(table)[1,2] if specification == 9
replace ci_lower2b = r(table)[5,2] if specification == 9
replace ci_upper2b = r(table)[6,2] if specification == 9

sdid colonoscopy_claim_rate age time recommendation if age<50, vce(bootstrap) covariates(male dependent acs) reps(500)
replace     coef2 = e(ATT)              if specification == 10
replace ci_lower2 = e(ATT)-(1.96*e(se)) if specification == 10
replace ci_upper2 = e(ATT)+(1.96*e(se)) if specification == 10

sdid colonoscopy_claim_rate age time acs if time<736 & age<50, vce(bootstrap) covariates(male dependent) reps(500)
replace     coef2b = e(ATT)              if specification == 10
replace ci_lower2b = e(ATT)-(1.96*e(se)) if specification == 10
replace ci_upper2b = e(ATT)+(1.96*e(se)) if specification == 10

sdid colonoscopy_claim_rate age time recommendation, vce(bootstrap) covariates(male dependent acs) reps(500)
replace     coef2 = e(ATT)              if specification == 11
replace ci_lower2 = e(ATT)-(1.96*e(se)) if specification == 11
replace ci_upper2 = e(ATT)+(1.96*e(se)) if specification == 11

sdid colonoscopy_claim_rate age time acs if time<736, vce(bootstrap) covariates(male dependent) reps(500)
replace     coef2b = e(ATT)              if specification == 11
replace ci_lower2b = e(ATT)-(1.96*e(se)) if specification == 11
replace ci_upper2b = e(ATT)+(1.96*e(se)) if specification == 11

regress dna_claim_rate recommendation acs male dependent i.time i.age if age<50, cluster(age)
replace coef3 = r(table)[1,1]     if specification == 13 
replace ci_lower3 = r(table)[5,1] if specification == 13
replace ci_upper3 = r(table)[6,1] if specification == 13

    replace coef3b = r(table)[1,2] if specification == 13 
replace ci_lower3b = r(table)[5,2] if specification == 13
replace ci_upper3b = r(table)[6,2] if specification == 13

regress dna_claim_rate recommendation acs i.time i.age if age<50, cluster(age)

    replace coef3 = r(table)[1,1] if specification == 14 
replace ci_lower3 = r(table)[5,1] if specification == 14
replace ci_upper3 = r(table)[6,1] if specification == 14

    replace coef3b = r(table)[1,2] if specification == 14 
replace ci_lower3b = r(table)[5,2] if specification == 14
replace ci_upper3b = r(table)[6,2] if specification == 14

regress dna_claim_rate recommendation acs male dependent i.time i.age if yr != 2020 & age<50, cluster(age)

    replace coef3 = r(table)[1,1] if specification == 15
replace ci_lower3 = r(table)[5,1] if specification == 15
replace ci_upper3 = r(table)[6,1] if specification == 15

    replace coef3b = r(table)[1,2] if specification == 15
replace ci_lower3b = r(table)[5,2] if specification == 15
replace ci_upper3b = r(table)[6,2] if specification == 15

sdid dna_claim_rate age time recommendation if age<50, vce(bootstrap) covariates(male dependent acs) reps(500)
replace     coef3 = e(ATT)              if specification == 16
replace ci_lower3 = e(ATT)-(1.96*e(se)) if specification == 16
replace ci_upper3 = e(ATT)+(1.96*e(se)) if specification == 16

sdid dna_claim_rate age time acs if time<736 & age<50, vce(bootstrap) covariates(male dependent) reps(500)
replace     coef3b = e(ATT)              if specification == 16
replace ci_lower3b = e(ATT)-(1.96*e(se)) if specification == 16
replace ci_upper3b = e(ATT)+(1.96*e(se)) if specification == 16

sdid dna_claim_rate age time recommendation, vce(bootstrap) covariates(male dependent acs) reps(500)
replace     coef3 = e(ATT)              if specification == 17
replace ci_lower3 = e(ATT)-(1.96*e(se)) if specification == 17
replace ci_upper3 = e(ATT)+(1.96*e(se)) if specification == 17

sdid dna_claim_rate age time acs if time<736, vce(bootstrap) covariates(male dependent) reps(500)
replace     coef3b = e(ATT)              if specification == 17
replace ci_lower3b = e(ATT)-(1.96*e(se)) if specification == 17
replace ci_upper3b = e(ATT)+(1.96*e(se)) if specification == 17

regress fecal_blood_test_claim_rate recommendation acs male dependent i.time i.age if age<50, cluster(age)
replace coef4 = r(table)[1,1]     if specification == 19 
replace ci_lower4 = r(table)[5,1] if specification == 19
replace ci_upper4 = r(table)[6,1] if specification == 19

    replace coef4b = r(table)[1,2] if specification == 19 
replace ci_lower4b = r(table)[5,2] if specification == 19
replace ci_upper4b = r(table)[6,2] if specification == 19

regress fecal_blood_test_claim_rate recommendation acs i.time i.age if age<50, cluster(age)

    replace coef4 = r(table)[1,1] if specification == 20 
replace ci_lower4 = r(table)[5,1] if specification == 20
replace ci_upper4 = r(table)[6,1] if specification == 20

    replace coef4b = r(table)[1,2] if specification == 20 
replace ci_lower4b = r(table)[5,2] if specification == 20
replace ci_upper4b = r(table)[6,2] if specification == 20

regress fecal_blood_test_claim_rate recommendation acs male dependent i.time i.age if yr != 2020 & age<50, cluster(age)
    replace coef4 = r(table)[1,1] if specification == 21
replace ci_lower4 = r(table)[5,1] if specification == 21
replace ci_upper4 = r(table)[6,1] if specification == 21
   
    replace coef4b = r(table)[1,2] if specification == 21
replace ci_lower4b = r(table)[5,2] if specification == 21
replace ci_upper4b = r(table)[6,2] if specification == 21

sdid fecal_blood_test_claim_rate age time recommendation if age<50, vce(bootstrap) covariates(male dependent acs) reps(500)
replace     coef4 = e(ATT)              if specification == 22
replace ci_lower4 = e(ATT)-(1.96*e(se)) if specification == 22
replace ci_upper4 = e(ATT)+(1.96*e(se)) if specification == 22

sdid fecal_blood_test_claim_rate age time acs if time<736 & age<50, vce(bootstrap) covariates(male dependent) reps(500)
replace     coef4b = e(ATT)              if specification == 22
replace ci_lower4b = e(ATT)-(1.96*e(se)) if specification == 22
replace ci_upper4b = e(ATT)+(1.96*e(se)) if specification == 22

sdid fecal_blood_test_claim_rate age time recommendation, vce(bootstrap) covariates(male dependent acs) reps(500)
replace     coef4 = e(ATT)              if specification == 23
replace ci_lower4 = e(ATT)-(1.96*e(se)) if specification == 23
replace ci_upper4 = e(ATT)+(1.96*e(se)) if specification == 23

sdid fecal_blood_test_claim_rate age time acs if time<736, vce(bootstrap) covariates(male dependent) reps(500)
replace     coef4b = e(ATT)              if specification == 23
replace ci_lower4b = e(ATT)-(1.96*e(se)) if specification == 23
replace ci_upper4b = e(ATT)+(1.96*e(se)) if specification == 23


duplicates drop specification, force

twoway (scatter coef1 specification, msize(medium) color(navy) msize(medsmall) ) ///
	   (rcap ci_lower1 ci_upper1 specification, lwidth(medium) color(navy)) ///
	   (scatter coef2 specification, msize(medium) color(dkgreen) symbol(triangle) msize(medsmall)) ///
	   (rcap ci_lower2 ci_upper2 specification, lwidth(medium) color(dkgreen)) ///
	   (scatter coef3 specification, msize(medium) color(sand) symbol(diamond) msize(medsmall)) ///
	   (rcap ci_lower3 ci_upper3 specification, lwidth(medium) color(sand)) ///
	   (scatter coef4 specification, msize(medium) color(maroon) symbol(square) msize(small)) ///
	   (rcap ci_lower4 ci_upper4 specification, lwidth(medium) color(maroon)), ///
	   xlabel(1 "Baseline" 2"No Covariates" 3"Drop 2020" 4 "Synthetic DiD" 5 "Synthetic DiD - Add 51-55" 7 "Baseline" 8 "No Covariates" 9 "Drop 2020" 10 "Synthetic DiD" 11 "Synthetic DiD - Add 51-55" 13 "Baseline" 14 "No Covariates" 15 "Drop 2020" 16 "Synthetic DiD" 17 "Synthetic DiD - Add 51-55" 19 "Baseline" 20 "No Covariates" 21 "Drop 2020" 22 "Synthetic DiD" 23 "Synthetic DiD - Add 51-55", angle(20) labsize(small) nogrid) legend(order(1 "Any CRC Screening" 3 "Colonoscopy" 5 "Stool-Based DNA Test" 7 "Stool-Based Blood Test") pos(6) col(2)) ///
	   yline(0) ///
	   xtitle("") ///
	   ylabel(-1(1)7) ///
	   ytitle("Estimated Coefficient")

twoway (scatter coef1b specification, msize(medium) color(navy) msize(medsmall)) ///
	   (rcap ci_lower1b ci_upper1b specification, lwidth(medium) color(navy)) ///
	   (scatter coef2b specification, msize(medium) color(dkgreen) symbol(triangle) msize(medsmall)) ///
	   (rcap ci_lower2b ci_upper2b specification, lwidth(medium) color(dkgreen)) ///
	   (scatter coef3b specification, msize(medium) color(sand) symbol(diamond) msize(small)) ///
	   (rcap ci_lower3b ci_upper3b specification, lwidth(medium) color(sand)) ///
	   (scatter coef4b specification, msize(medium) color(maroon) symbol(square) msize(small)) ///
	   (rcap ci_lower4b ci_upper4b specification, lwidth(medium) color(maroon)), ///
	   xlabel(1 "Baseline" 2"No Covariates" 3"Drop 2020" 4 "Synthetic DiD" 5 "Synthetic DiD - Add 51-55" 7 "Baseline" 8 "No Covariates" 9 "Drop 2020" 10 "Synthetic DiD" 11 "Synthetic DiD - Add 51-55" 13 "Baseline" 14 "No Covariates" 15 "Drop 2020" 16 "Synthetic DiD" 17 "Synthetic DiD - Add 51-55" 19 "Baseline" 20 "No Covariates" 21 "Drop 2020" 22 "Synthetic DiD" 23 "Synthetic DiD - Add 51-55", angle(20) labsize(small) nogrid) legend(order(1 "Any CRC Screening" 3 "Colonoscopy" 5 "Stool-Based DNA Test" 7 "Stool-Based Blood Test") pos(6) col(2)) ///
	   yline(0) ///
	   xtitle("") ///
	   ylabel(-1(1)7) ///
	   ytitle("Estimated Coefficient")

**************Figure 4 - Randomization Inference************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

xtset age time

local outcomes "crc_claim_rate colonoscopy_claim_rate dna_claim_rate fecal_blood_test_claim_rate"

tempfile original trt
save `original'

preserve 
	keep if inrange(age, 46,49)
	keep age time acs recommendation
	duplicates drop
	egen treat_slot = group(age)
	drop age 
	rename (acs recommendation) (acs_p rec_p)
	save `trt', replace
restore


levelsof age, local(ages)
local A : word count `ages' 

foreach y of local outcomes{
	use `original', clear
	regress `y' acs recommendation male dependent i.time i.age, cluster(age)
	
	scalar b_acs0 = _b[acs]
	scalar se_acs0 = _se[acs]
	scalar t_acs0 = _b[acs]/_se[acs]
	
	scalar b_rec0 = _b[recommendation]
	scalar se_rec0 = _se[recommendation]
	scalar t_rec0 = _b[recommendation]/_se[recommendation]
	
	tempfile out 
	capture postclose ph 
	postfile ph i a1 a2 a3 a4 b_acs t_acs b_rec t_rec using `out', replace
	
	local iter = 0
	forvalues i1 = 1/`=`A'-3'{
	forvalues i2 = `=`i1'+1'/`=`A'-2' {
	forvalues i3 = `=`i2'+1'/`=`A'-1' {
	forvalues i4 = `=`i3'+1'/`A'{
	local ++iter
	local a1 : word `i1' of `ages'
	local a2 : word `i2' of `ages'
	local a3 : word `i3' of `ages'
	local a4 : word `i4' of `ages'

    use `original', clear
	gen treat_slot = . 
	replace treat_slot = 1 if age == `a1'
	replace treat_slot = 2 if age == `a2'
	replace treat_slot = 3 if age == `a3'
	replace treat_slot = 4 if age == `a4'
	
	drop acs recommendation
	merge m:1 treat_slot time using `trt', nogen keep(master match)
	replace acs_p = 0 if missing(acs_p)
	replace rec_p = 0 if missing(rec_p)
	
	regress `y' acs_p rec_p male dependent i.time i.age, cluster(age)
	post ph (`iter') (`a1') (`a2') (`a3') (`a4') ///
	(_b[acs_p]) (_b[acs_p]/_se[acs_p]) ///
	(_b[rec_p]) (_b[rec_p]/_se[rec_p])
	

}
}
}
}
postclose ph

use `out', clear
di _newline "+++ Outcome: `y' ==="

foreach v in b_acs t_acs b_rec t_rec {
	local act = `v'0
	count if abs(`v') >= abs(`act')
	local p_`v' : di %5.3f r(N)/_N
	display "`v': " %5.2f r(N)/_N*100 "% of placebos >= |actual|" ///
	" (actual = " %7.4f `act' ")"
}
save "placebos_`y'.dta", replace 


twoway (histogram b_acs, frequency fcolor(navy%40) lcolor(navy)), ///
	xtitle("Placebo Coefficients") ///
	xlabel(,nogrid) ///
	xline(`=b_acs0', lcolor(red) lwidth(medthick)) ///
	note("Red line - actual coefficient (se): `:di %5.3f `=b_acs0'' (`:di %5.3f `=se_acs0'')" ///
	"RI-beta two tailed p-value = `p_b_acs'", size(medium))

graph save "placebo_acs_`y'.gph", replace 

twoway (histogram b_rec, frequency fcolor(navy%40) lcolor(navy)), ///
	xtitle("Placebo Coefficients") ///
	xlabel(, nogrid) ///
	xline(`=b_rec0', lcolor(red) lwidth(medthick)) ///
	note("Red line - actual coefficient (se): `:di %5.3f `=b_rec0'' (`:di %5.3f `=se_rec0'')" ///
	"RI-beta two tailed p-value = `p_b_rec'", size(medium))

	graph save "placebo_uspstf_`y'.gph", replace 

}


histogram b_rec, freq xline(`=b_rec0', lcolor(red) lwidth(medthick))
histogram b_acs, freq xline(`=b_acs0', lcolor(red) lwidth(medthick))



capture postclose ph 
postfile ph b_acs t_acs b_rec t_rec using `out', replace

set seed 12345
local nreps 1000

forvalues i = 1/`nreps' {
use `original', clear

preserve
	keep age 
	duplicates drop
	sort age
	gen rnd = runiform()
	sort rnd 
	gen new_idx = _n
	sort age
	gen new_age = age[new_idx]
	keep age new_age
	save `map', replace
restore
qui merge m:1 age using `map', nogen


preserve	
	keep age time acs recommendation 
	duplicates drop
	rename (age acs recommendation) (new_age acs_p rec_p)
	save `trt', replace
restore

qui merge m:1 new_age time using `trt', nogen
qui regress crc_claim_rate acs_p rec_p male dependent i.time i.age, cluster(age)

post ph (_b[acs_p]) (_b[acs_p]/_se[acs_p]) (_b[rec_p]) (_b[rec_p]/_se[rec_p])
	
}	   
	
postclose ph 

*******Figure 5a - Colonoscopy with Polyp Removal********
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

sum ttt
gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40
tab ttt_rec

regress col_removal_claim_rate acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress col_removal_claim_rate ib39.ttt_rec i.time i.age male dependent, cluster(age)

forvalues i = 0/120{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") ylabel(-5(5)10) note("ACS ATT: {&beta}(SE) = `att2'(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'***(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) ylabel(-1(1)5) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ytitle("Estimated Coefficient") text(5.4 -1 "ACS") text(5.4 35.5 "USPSTF")

*******Figure 5b - Colonoscopy without Polyp Removal********
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

sum ttt
gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40
tab ttt_rec

regress col_no_removal_claim_rate acs recommendation male dependent ppo hmo i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress col_no_removal_claim_rate ib39.ttt_rec i.time i.age male dependent ppo hmo, cluster(age)

forvalues i = 0/120{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") ylabel(-5(5)10) note("ACS ATT: {&beta}(SE) = `att2'(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'***(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) ylabel(-1(1)5) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ytitle("Estimated Coefficient") text(5.4 -1 "ACS") text(5.4 35.5 "USPSTF")

************Figure 6 - Heterogenous Analysis************************
use analytic_heterogenous.dta,replace

gen specification = runiformint(0,39)
replace specification = 39.5 if age == 53

drop if age == 45 | age == 50
drop if age>50
gen treat_time = 736 if age>44 & age<50

regress colonoscopies_claim_rate_M recommendation acs male_dep i.age i.time
est store male

regress colonoscopies_claim_rate_F recommendation acs female_dep i.age i.time
est store female

suest male female, cluster(age)

test [male_mean]recommendation = [female_mean]recommendation

regress crc_claim_rate_M recommendation acs male_dep i.age i.time, cluster(age)
replace     coef1 = r(table)[1,1] if specification == 1 
replace ci_lower1 = r(table)[5,1] if specification == 1 
replace ci_upper1 = r(table)[6,1] if specification == 1 

replace     coef1b = r(table)[1,2] if specification == 1 
replace ci_lower1b = r(table)[5,2] if specification == 1 
replace ci_upper1b = r(table)[6,2] if specification == 1 

regress crc_claim_rate_F recommendation acs female_dep i.age i.time, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 2 
replace ci_lower2 = r(table)[5,1] if specification == 2 
replace ci_upper2 = r(table)[6,1] if specification == 2 

replace     coef2b = r(table)[1,2] if specification == 2 
replace ci_lower2b = r(table)[5,2] if specification == 2 
replace ci_upper2b = r(table)[6,2] if specification == 2 

regress crc_claim_rate_HMO recommendation acs hmo_male hmo_dep i.age i.time, cluster(age)

replace     coef3 = r(table)[1,1] if specification == 4 
replace ci_lower3 = r(table)[5,1] if specification == 4 
replace ci_upper3 = r(table)[6,1] if specification == 4 

replace     coef3b = r(table)[1,2] if specification == 4 
replace ci_lower3b = r(table)[5,2] if specification == 4 
replace ci_upper3b = r(table)[6,2] if specification == 4 

regress crc_claim_rate_POS recommendation acs pos_male pos_dep i.age i.time, cluster(age)

replace     coef4 = r(table)[1,1] if specification == 5 
replace ci_lower4 = r(table)[5,1] if specification == 5 
replace ci_upper4 = r(table)[6,1] if specification == 5 

replace     coef4b = r(table)[1,2] if specification == 5 
replace ci_lower4b = r(table)[5,2] if specification == 5 
replace ci_upper4b = r(table)[6,2] if specification == 5 

regress crc_claim_rate_PPO recommendation acs ppo_male ppo_dep i.age i.time, cluster(age)

replace     coef5 = r(table)[1,1] if specification == 6 
replace ci_lower5 = r(table)[5,1] if specification == 6 
replace ci_upper5 = r(table)[6,1] if specification == 6 

replace     coef5b = r(table)[1,2] if specification == 6 
replace ci_lower5b = r(table)[5,2] if specification == 6 
replace ci_upper5b = r(table)[6,2] if specification == 6 

regress crc_claim_rate_SUB recommendation acs sub_mal i.age i.time, cluster(age)

replace     coef6 = r(table)[1,1] if specification == 8 
replace ci_lower6 = r(table)[5,1] if specification == 8 
replace ci_upper6 = r(table)[6,1] if specification == 8 

replace     coef6b = r(table)[1,2] if specification == 8 
replace ci_lower6b = r(table)[5,2] if specification == 8 
replace ci_upper6b = r(table)[6,2] if specification == 8 

regress crc_claim_rate_DEP recommendation acs dep_male i.age i.time, cluster(age)

replace     coef7 = r(table)[1,1] if specification == 9 
replace ci_lower7 = r(table)[5,1] if specification == 9 
replace ci_upper7 = r(table)[6,1] if specification == 9 

replace     coef7b = r(table)[1,2] if specification == 9 
replace ci_lower7b = r(table)[5,2] if specification == 9 
replace ci_upper7b = r(table)[6,2] if specification == 9 

regress colonoscopies_claim_rate_M recommendation acs male_dep i.age i.time, cluster(age)
est store male
replace     coef1 = r(table)[1,1] if specification == 11 
replace ci_lower1 = r(table)[5,1] if specification == 11 
replace ci_upper1 = r(table)[6,1] if specification == 11 

replace     coef1b = r(table)[1,2] if specification == 11 
replace ci_lower1b = r(table)[5,2] if specification == 11 
replace ci_upper1b = r(table)[6,2] if specification == 11 

regress colonoscopies_claim_rate_F recommendation acs female_dep i.age i.time, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 12 
replace ci_lower2 = r(table)[5,1] if specification == 12 
replace ci_upper2 = r(table)[6,1] if specification == 12 

replace     coef2b = r(table)[1,2] if specification == 12 
replace ci_lower2b = r(table)[5,2] if specification == 12 
replace ci_upper2b = r(table)[6,2] if specification == 12 

regress colonoscopies_claim_rate_HMO recommendation acs hmo_male hmo_dep i.age i.time, cluster(age)

replace     coef3 = r(table)[1,1] if specification == 14 
replace ci_lower3 = r(table)[5,1] if specification == 14 
replace ci_upper3 = r(table)[6,1] if specification == 14 

replace     coef3b = r(table)[1,2] if specification == 14 
replace ci_lower3b = r(table)[5,2] if specification == 14 
replace ci_upper3b = r(table)[6,2] if specification == 14 

regress colonoscopies_claim_rate_POS recommendation acs pos_male pos_dep i.age i.time, cluster(age)

replace     coef4 = r(table)[1,1] if specification == 15 
replace ci_lower4 = r(table)[5,1] if specification == 15 
replace ci_upper4 = r(table)[6,1] if specification == 15 

replace     coef4b = r(table)[1,2] if specification == 15 
replace ci_lower4b = r(table)[5,2] if specification == 15 
replace ci_upper4b = r(table)[6,2] if specification == 15

regress colonoscopies_claim_rate_PPO recommendation acs ppo_male ppo_dep i.age i.time, cluster(age)

replace     coef5 = r(table)[1,1] if specification == 16 
replace ci_lower5 = r(table)[5,1] if specification == 16 
replace ci_upper5 = r(table)[6,1] if specification == 16

replace     coef5b = r(table)[1,2] if specification == 16 
replace ci_lower5b = r(table)[5,2] if specification == 16 
replace ci_upper5b = r(table)[6,2] if specification == 16

regress colonoscopies_claim_rate_SUB recommendation acs sub_male i.age i.time, cluster(age)

replace     coef6 = r(table)[1,1] if specification == 18 
replace ci_lower6 = r(table)[5,1] if specification == 18 
replace ci_upper6 = r(table)[6,1] if specification == 18

replace     coef6b = r(table)[1,2] if specification == 18 
replace ci_lower6b = r(table)[5,2] if specification == 18 
replace ci_upper6b = r(table)[6,2] if specification == 18

regress colonoscopies_claim_rate_DEP recommendation acs dep_male i.age i.time, cluster(age)

replace     coef7 = r(table)[1,1] if specification == 19 
replace ci_lower7 = r(table)[5,1] if specification == 19 
replace ci_upper7 = r(table)[6,1] if specification == 19

replace     coef7b = r(table)[1,2] if specification == 19 
replace ci_lower7b = r(table)[5,2] if specification == 19 
replace ci_upper7b = r(table)[6,2] if specification == 19

regress dna_claim_rate_M recommendation acs male_dep i.age i.time, cluster(age)

replace     coef1 = r(table)[1,1] if specification == 21 
replace ci_lower1 = r(table)[5,1] if specification == 21 
replace ci_upper1 = r(table)[6,1] if specification == 21

replace     coef1b = r(table)[1,2] if specification == 21 
replace ci_lower1b = r(table)[5,2] if specification == 21 
replace ci_upper1b = r(table)[6,2] if specification == 21

regress dna_claim_rate_F recommendation acs female_dep i.age i.time, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 22 
replace ci_lower2 = r(table)[5,1] if specification == 22 
replace ci_upper2 = r(table)[6,1] if specification == 22

replace     coef2b = r(table)[1,2] if specification == 22 
replace ci_lower2b = r(table)[5,2] if specification == 22 
replace ci_upper2b = r(table)[6,2] if specification == 22

regress dna_claim_rate_HMO recommendation acs hmo_male hmo_dep i.age i.time, cluster(age)

replace     coef3 = r(table)[1,1] if specification == 24 
replace ci_lower3 = r(table)[5,1] if specification == 24 
replace ci_upper3 = r(table)[6,1] if specification == 24

replace     coef3b = r(table)[1,2] if specification == 24 
replace ci_lower3b = r(table)[5,2] if specification == 24 
replace ci_upper3b = r(table)[6,2] if specification == 24

regress dna_claim_rate_POS recommendation acs pos_male pos_dep i.age i.time, cluster(age)

replace     coef4 = r(table)[1,1] if specification == 25 
replace ci_lower4 = r(table)[5,1] if specification == 25 
replace ci_upper4 = r(table)[6,1] if specification == 25

replace     coef4b = r(table)[1,2] if specification == 25 
replace ci_lower4b = r(table)[5,2] if specification == 25 
replace ci_upper4b = r(table)[6,2] if specification == 25

regress dna_claim_rate_PPO recommendation acs ppo_male ppo_dep i.age i.time, cluster(age)

replace     coef5 = r(table)[1,1] if specification == 26 
replace ci_lower5 = r(table)[5,1] if specification == 26 
replace ci_upper5 = r(table)[6,1] if specification == 26

replace     coef5b = r(table)[1,2] if specification == 26 
replace ci_lower5b = r(table)[5,2] if specification == 26 
replace ci_upper5b = r(table)[6,2] if specification == 26

regress dna_claim_rate_SUB recommendation acs sub_male i.age i.time, cluster(age)

replace     coef6 = r(table)[1,1] if specification == 28 
replace ci_lower6 = r(table)[5,1] if specification == 28 
replace ci_upper6 = r(table)[6,1] if specification == 28

replace     coef6b = r(table)[1,2] if specification == 28 
replace ci_lower6b = r(table)[5,2] if specification == 28 
replace ci_upper6b = r(table)[6,2] if specification == 28

regress dna_claim_rate_DEP recommendation acs dep_male i.age i.time, cluster(age)

replace     coef7 = r(table)[1,1] if specification == 29 
replace ci_lower7 = r(table)[5,1] if specification == 29 
replace ci_upper7 = r(table)[6,1] if specification == 29

replace     coef7b = r(table)[1,2] if specification == 29 
replace ci_lower7b = r(table)[5,2] if specification == 29 
replace ci_upper7b = r(table)[6,2] if specification == 29

regress fecal_blood_test_claim_rate_M recommendation acs male_dep i.age i.time, cluster(age)

replace     coef1 = r(table)[1,1] if specification == 31 
replace ci_lower1 = r(table)[5,1] if specification == 31 
replace ci_upper1 = r(table)[6,1] if specification == 31

replace     coef1b = r(table)[1,2] if specification == 31 
replace ci_lower1b = r(table)[5,2] if specification == 31 
replace ci_upper1b = r(table)[6,2] if specification == 31

regress fecal_blood_test_claim_rate_F recommendation acs female_dep i.age i.time, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 32 
replace ci_lower2 = r(table)[5,1] if specification == 32 
replace ci_upper2 = r(table)[6,1] if specification == 32

replace     coef2b = r(table)[1,2] if specification == 32 
replace ci_lower2b = r(table)[5,2] if specification == 32 
replace ci_upper2b = r(table)[6,2] if specification == 32

regress fecal_blood_test_claim_rate_HMO recommendation acs hmo_male hmo_dep i.age i.time, cluster(age)

replace     coef3 = r(table)[1,1] if specification == 34 
replace ci_lower3 = r(table)[5,1] if specification == 34 
replace ci_upper3 = r(table)[6,1] if specification == 34

replace     coef3b = r(table)[1,2] if specification == 34 
replace ci_lower3b = r(table)[5,2] if specification == 34 
replace ci_upper3b = r(table)[6,2] if specification == 34

regress fecal_blood_test_claim_rate_POS recommendation acs pos_male pos_dep i.age i.time, cluster(age)

replace     coef4 = r(table)[1,1] if specification == 35 
replace ci_lower4 = r(table)[5,1] if specification == 35 
replace ci_upper4 = r(table)[6,1] if specification == 35

replace     coef4b = r(table)[1,2] if specification == 35 
replace ci_lower4b = r(table)[5,2] if specification == 35 
replace ci_upper4b = r(table)[6,2] if specification == 35

regress fecal_blood_test_claim_rate_PPO recommendation acs ppo_male ppo_dep i.age i.time, cluster(age)

replace     coef5 = r(table)[1,1] if specification == 36 
replace ci_lower5 = r(table)[5,1] if specification == 36 
replace ci_upper5 = r(table)[6,1] if specification == 36

replace     coef5b = r(table)[1,2] if specification == 36 
replace ci_lower5b = r(table)[5,2] if specification == 36 
replace ci_upper5b = r(table)[6,2] if specification == 36

regress fecal_blood_test_claim_rate_SUB recommendation acs sub_male i.age i.time, cluster(age)

replace     coef6 = r(table)[1,1] if specification == 38 
replace ci_lower6 = r(table)[5,1] if specification == 38 
replace ci_upper6 = r(table)[6,1] if specification == 38

replace     coef6b = r(table)[1,2] if specification == 38 
replace ci_lower6b = r(table)[5,2] if specification == 38 
replace ci_upper6b = r(table)[6,2] if specification == 38

regress fecal_blood_test_claim_rate_DEP recommendation acs dep_male i.age i.time, cluster(age)

replace     coef7 = r(table)[1,1] if specification == 39 
replace ci_lower7 = r(table)[5,1] if specification == 39 
replace ci_upper7 = r(table)[6,1] if specification == 39

replace     coef7b = r(table)[1,2] if specification == 39 
replace ci_lower7b = r(table)[5,2] if specification == 39 
replace ci_upper7b = r(table)[6,2] if specification == 39

duplicates drop specification, force

twoway (scatter coef1 specification, msize(medium) mcolor(blue) msymbol(circle)) ///
	   (rcap ci_lower1 ci_upper1 specification, lwidth(medium) lcolor(blue)) ///
	   (scatter coef2 specification, msize(medium) mcolor(cranberry) msymbol(diamond)) ///
	   (rcap ci_lower2 ci_upper2 specification, lwidth(medium) lcolor(cranberry)) ///
	   (scatter coef3 specification, msize(medium) mcolor(dkgreen) msymbol(triangle)) ///
	   (rcap ci_lower3 ci_upper3 specification, lwidth(medium) lcolor(dkgreen)) ///
	   (scatter coef4 specification, msize(medium) mcolor(orange) msymbol(square)) ///
	   (rcap ci_lower4 ci_upper4 specification, lwidth(medium) lcolor(orange)) ///
	   (scatter coef5 specification, msize(medium) mcolor(brown) msymbol(plus)) ///
	   (rcap ci_lower5 ci_upper5 specification, lwidth(medium) lcolor(brown)) ///
	   (scatter coef6 specification, msize(medium) mcolor(eltblue) msymbol(arrow)) ///
	   (rcap ci_lower6 ci_upper6 specification, lwidth(medium) lcolor(eltblue)) ///
	   (scatter coef7 specification, msize(medium) mcolor(purple) msymbol(V)) ///
	   (rcap ci_lower7 ci_upper7 specification, lwidth(medium) lcolor(purple)), ///
	   xlabel(5 "Any CRC Screening" 15 "Colonoscopy" 25 "Stool-Based DNA Test" 35 "Stool-Based Blood Test", angle(0) labsize(small) nogrid) ///
	   xline(-0.6 10 20 30 40.1, lpattern(line)) ///
	   yline(0) ///
	   ylabel(-1(1)7) ///
	   ytitle("Estimated Coefficient") ///
	   legend(order(1 "Male" 3 "Female" 5 "HMO" 7 "POS" 9 "PPO" 11 "Subscriber" 13 "Dependent") pos(6) col(7)) ///
	   xtitle("")

	   
twoway (scatter coef1b specification, msize(medium) mcolor(blue) msymbol(circle)) ///
	   (rcap ci_lower1b ci_upper1b specification, lwidth(medium) lcolor(blue)) ///
	   (scatter coef2b specification, msize(medium) mcolor(cranberry) msymbol(diamond)) ///
	   (rcap ci_lower2b ci_upper2b specification, lwidth(medium) lcolor(cranberry)) ///
	   (scatter coef3b specification, msize(medium) mcolor(dkgreen) msymbol(triangle)) ///
	   (rcap ci_lower3b ci_upper3b specification, lwidth(medium) lcolor(dkgreen)) ///
	   (scatter coef4b specification, msize(medium) mcolor(orange) msymbol(square)) ///
	   (rcap ci_lower4b ci_upper4b specification, lwidth(medium) lcolor(orange)) ///
	   (scatter coef5b specification, msize(medium) mcolor(brown) msymbol(plus)) ///
	   (rcap ci_lower5b ci_upper5b specification, lwidth(medium) lcolor(brown)) ///
	   (scatter coef6b specification, msize(medium) mcolor(eltblue) msymbol(arrow)) ///
	   (rcap ci_lower6b ci_upper6b specification, lwidth(medium) lcolor(eltblue)) ///
	   (scatter coef7b specification, msize(medium) mcolor(purple) msymbol(V)) ///
	   (rcap ci_lower7b ci_upper7b specification, lwidth(medium) lcolor(purple)), ///
	   xlabel(5 "Any CRC Screening" 15 "Colonoscopy" 25 "Stool-Based DNA Test" 35 "Stool-Based Blood Test", angle(0) labsize(small) nogrid) ///
	   xline(-0.6 10 20 30 40.1, lpattern(line)) ///
	   ylabel(-1(1)7) ///
	   yline(0) ///
	   ytitle("Estimated Coefficient") ///
	   legend(order(1 "Male" 3 "Female" 5 "HMO" 7 "POS" 9 "PPO" 11 "Subscriber" 13 "Dependent") pos(6) col(7)) xtitle("")

************Figure 7 - Heterogenous Analysis by Metropolitan Status************************
use analytic_heterogenous.dta,replace

gen specification = runiformint(0,12)
replace specification = 39.5 if age == 53

drop if age == 45 | age == 50
drop if age>50
gen treat_time = 736 if age>44 & age<50

regress crc_claim_rate_urban recommendation acs urban_male urban_dep i.age i.time, cluster(age)
replace     coef1 = r(table)[1,1] if specification == 1 
replace ci_lower1 = r(table)[5,1] if specification == 1 
replace ci_upper1 = r(table)[6,1] if specification == 1 

replace     coef1b = r(table)[1,2] if specification == 1 
replace ci_lower1b = r(table)[5,2] if specification == 1 
replace ci_upper1b = r(table)[6,2] if specification == 1 

regress crc_claim_rate_rural recommendation acs rural_male rural_dep i.age i.time, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 2 
replace ci_lower2 = r(table)[5,1] if specification == 2 
replace ci_upper2 = r(table)[6,1] if specification == 2 

replace     coef2b = r(table)[1,2] if specification == 2 
replace ci_lower2b = r(table)[5,2] if specification == 2 
replace ci_upper2b = r(table)[6,2] if specification == 2 

regress colonoscopies_claim_rate_urban recommendation acs urban_male urban_dep i.age i.time, cluster(age)

replace     coef1 = r(table)[1,1] if specification == 4 
replace ci_lower1 = r(table)[5,1] if specification == 4 
replace ci_upper1 = r(table)[6,1] if specification == 4 

replace     coef1b = r(table)[1,2] if specification == 4 
replace ci_lower1b = r(table)[5,2] if specification == 4 
replace ci_upper1b = r(table)[6,2] if specification == 4 

regress colonoscopies_claim_rate_rural recommendation acs rural_male rural_dep i.age i.time, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 5 
replace ci_lower2 = r(table)[5,1] if specification == 5 
replace ci_upper2 = r(table)[6,1] if specification == 5 

replace     coef2b = r(table)[1,2] if specification == 5 
replace ci_lower2b = r(table)[5,2] if specification == 5 
replace ci_upper2b = r(table)[6,2] if specification == 5 

regress dna_claim_rate_urban recommendation acs urban_male urban_dep i.age i.time, cluster(age)

replace     coef1 = r(table)[1,1] if specification == 7 
replace ci_lower1 = r(table)[5,1] if specification == 7 
replace ci_upper1 = r(table)[6,1] if specification == 7 

replace     coef1b = r(table)[1,2] if specification == 7 
replace ci_lower1b = r(table)[5,2] if specification == 7 
replace ci_upper1b = r(table)[6,2] if specification == 7 

regress dna_claim_rate_rural recommendation acs rural_male rural_dep i.age i.time, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 8 
replace ci_lower2 = r(table)[5,1] if specification == 8 
replace ci_upper2 = r(table)[6,1] if specification == 8 

replace     coef2b = r(table)[1,2] if specification == 8 
replace ci_lower2b = r(table)[5,2] if specification == 8 
replace ci_upper2b = r(table)[6,2] if specification == 8 

regress fecal_blood_test_claim_rate_urb recommendation acs urban_male urban_dep i.age i.time, cluster(age)

replace     coef1 = r(table)[1,1] if specification == 10 
replace ci_lower1 = r(table)[5,1] if specification == 10
replace ci_upper1 = r(table)[6,1] if specification == 10

replace     coef1b = r(table)[1,2] if specification == 10 
replace ci_lower1b = r(table)[5,2] if specification == 10
replace ci_upper1b = r(table)[6,2] if specification == 10 

regress fecal_blood_test_claim_rate_rur recommendation acs rural_male rural_dep i.age i.time, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 11 
replace ci_lower2 = r(table)[5,1] if specification == 11
replace ci_upper2 = r(table)[6,1] if specification == 11

replace     coef2b = r(table)[1,2] if specification == 11 
replace ci_lower2b = r(table)[5,2] if specification == 11
replace ci_upper2b = r(table)[6,2] if specification == 11

duplicates drop specification, force

twoway (scatter coef1 specification, msize(medium) mcolor(navy) msymbol(circle)) ///
	   (rcap ci_lower1 ci_upper1 specification, lwidth(medium) lcolor(navy)) ///
	   (scatter coef2 specification, msize(medium) mcolor(orange) msymbol(diamond)) ///
	   (rcap ci_lower2 ci_upper2 specification, lwidth(medium) lcolor(orange)), ///
	   xlabel(1.5 "Any CRC Screening" 4.5 "Colonoscopy" 7.5 "Stool-Based DNA Test" 10.5 "Stool-Based Blood Test", angle(0) labsize(small) nogrid) ///
	   xline( 3 6 9 12.17, lpattern(line)) ///
	   yline(0) ///
	   ylabel(-1(1)7) ///
	   ytitle("Estimated Coefficient") ///
	   legend(order(1 "Metropolitan" 3 "Nonmetropolitan" 5) pos(6) col(2)) ///
	   xtitle("")

	   
twoway (scatter coef1b specification, msize(medium) mcolor(navy) msymbol(circle)) ///
	   (rcap ci_lower1b ci_upper1b specification, lwidth(medium) lcolor(navy)) ///
	   (scatter coef2b specification, msize(medium) mcolor(orange) msymbol(diamond)) ///
	   (rcap ci_lower2b ci_upper2b specification, lwidth(medium) lcolor(orange)), ///
	   xlabel(1.5 "Any CRC Screening" 4.5 "Colonoscopy" 7.5 "Stool-Based DNA Test" 10.5 "Stool-Based Blood Test", angle(0) labsize(small) nogrid) ///
	   xline( 3 6 9 12.17, lpattern(line)) ///
	   yline(0) ///
	   ylabel(-1(1)7) ///
	   ytitle("Estimated Coefficient") ///
	   legend(order(1 "Metropolitan" 3 "Nonmetropolitan" 5) pos(6) col(2)) ///
	   xtitle("")
	   

****************Figure 8a - Colonoscopy In-Network************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40
tab ttt_rec

regress col_in_netork_claim_rate acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress col_in_netork_claim_rate ib39.ttt_rec i.time i.age male dependent, cluster(age)

forvalues i = 0/120{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") ylabel(-5(5)10) note("ACS ATT: {&beta}(SE) = `att2'(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'***(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) ylabel(-2(2)12) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ytitle("Estimated Coefficient") text(12.9 -1 "ACS") text(12.9 35.5 "USPSTF")


****************Figure 8b - Colonoscopy Out-Network************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

sum ttt
gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40
tab ttt_rec

regress col_out_network_claim_rate acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress col_out_network_claim_rate ib39.ttt_rec i.time i.age male dependent, cluster(age)

forvalues i = 0/120{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") ylabel(-5(5)10) note("ACS ATT: {&beta}(SE) = `att2'(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'***(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) ylabel(-0.2(0.05)0.2) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ytitle("Estimated Coefficient") text(12.9 -1 "ACS") text(12.9 35.5 "USPSTF") ylabel(-2(2)12)

*********Figure 9 - Costs Estimates***********
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50
gen specification = runiformint(0,12)

sort age time

regress total_cost_colonoscopy recommendation acs male dependent i.time i.age, cluster(age)

replace coef1 = r(table)[1,1] if specification == 1 
replace ci_lower1 = r(table)[5,1] if specification == 1
replace ci_upper1 = r(table)[6,1] if specification == 1

replace     coef1b = r(table)[1,2] if specification == 1 
replace ci_lower1b = r(table)[5,2] if specification == 1
replace ci_upper1b = r(table)[6,2] if specification == 1

regress oop_colonoscopy recommendation acs male dependent i.time i.age, cluster(age)

replace     coef1 = r(table)[1,1] if specification == 2 
replace ci_lower1 = r(table)[5,1] if specification == 2
replace ci_upper1 = r(table)[6,1] if specification == 2

replace     coef1b = r(table)[1,2] if specification == 2 
replace ci_lower1b = r(table)[5,2] if specification == 2
replace ci_upper1b = r(table)[6,2] if specification == 2

regress insurer_colonoscopy recommendation acs male dependent i.time i.age, cluster(age)

replace     coef1 = r(table)[1,1] if specification == 3 
replace ci_lower1 = r(table)[5,1] if specification == 3
replace ci_upper1 = r(table)[6,1] if specification == 3

replace     coef1b = r(table)[1,2] if specification == 3 
replace ci_lower1b = r(table)[5,2] if specification == 3
replace ci_upper1b = r(table)[6,2] if specification == 3

regress total_cost_dna recommendation acs male dependent i.time i.age, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 5 
replace ci_lower2 = r(table)[5,1] if specification == 5
replace ci_upper2 = r(table)[6,1] if specification == 5

replace     coef2b = r(table)[1,2] if specification == 5 
replace ci_lower2b = r(table)[5,2] if specification == 5
replace ci_upper2b = r(table)[6,2] if specification == 5

regress oop_dna recommendation acs male dependent i.time i.age, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 6 
replace ci_lower2 = r(table)[5,1] if specification == 6
replace ci_upper2 = r(table)[6,1] if specification == 6

replace     coef2b = r(table)[1,2] if specification == 6 
replace ci_lower2b = r(table)[5,2] if specification == 6
replace ci_upper2b = r(table)[6,2] if specification == 6

regress insurer_dna recommendation acs male dependent i.time i.age, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 7 
replace ci_lower2 = r(table)[5,1] if specification == 7
replace ci_upper2 = r(table)[6,1] if specification == 7

replace     coef2b = r(table)[1,2] if specification == 7 
replace ci_lower2b = r(table)[5,2] if specification == 7
replace ci_upper2b = r(table)[6,2] if specification == 7


regress total_cost_fecal_blood recommendation acs male dependent i.time i.age, cluster(age)

replace     coef3 = r(table)[1,1] if specification == 9 
replace ci_lower3 = r(table)[5,1] if specification == 9
replace ci_upper3 = r(table)[6,1] if specification == 9

replace     coef3b = r(table)[1,2] if specification == 9 
replace ci_lower3b = r(table)[5,2] if specification == 9
replace ci_upper3b = r(table)[6,2] if specification == 9

regress oop_fecal_blood recommendation acs male dependent i.time i.age, cluster(age)

replace     coef3 = r(table)[1,1] if specification == 10 
replace ci_lower3 = r(table)[5,1] if specification == 10
replace ci_upper3 = r(table)[6,1] if specification == 10

replace     coef3b = r(table)[1,2] if specification == 10 
replace ci_lower3b = r(table)[5,2] if specification == 10
replace ci_upper3b = r(table)[6,2] if specification == 10

regress insurer_fecal_blood recommendation acs male dependent i.time i.age, cluster(age)

replace     coef3 = r(table)[1,1] if specification == 11 
replace ci_lower3 = r(table)[5,1] if specification == 11
replace ci_upper3 = r(table)[6,1] if specification == 11

replace     coef3b = r(table)[1,2] if specification == 11 
replace ci_lower3b = r(table)[5,2] if specification == 11
replace ci_upper3b = r(table)[6,2] if specification == 11

duplicates drop specification, force

twoway (scatter coef1 specification, msize(medium) color(dkgreen) symbol(triangle) ) ///
	   (rcap ci_lower1 ci_upper1 specification, lwidth(medium) color(dkgreen)) ///
	   (scatter coef2 specification, msize(medium) color(sand) symbol(diamond)) ///
	   (rcap ci_lower2 ci_upper2 specification, lwidth(medium) color(sand)) ///
	   (scatter coef3 specification, msize(medium) color(maroon) symbol(square)) ///
	   (rcap ci_lower3 ci_upper3 specification, lwidth(medium) color(maroon)), ///
	   xlabel(1 "Total Cost" 2"Patient Cost" 3"Insurer Cost" 5 "Total Cost" 6"Patient Cost" 7 "Insurer Cost" 9 "Total Cost" 10"Patient Cost" 11"Insurer Cost", angle(20) labsize(small) nogrid) ///
	   legend(order(1 "Colonoscopy" 3 "Stool-Based DNA Test" 5 "Stool-Based Blood Test") pos(6) col(3)) ///
	   yline(0) ///
	   xtitle("") ///
	   ylabel(-550(50)250) ///
	   ytitle("Estimated Coefficient")

twoway (scatter coef1b specification, msize(medium) color(dkgreen) symbol(triangle) ) ///
	   (rcap ci_lower1b ci_upper1b specification, lwidth(medium) color(dkgreen)) ///
	   (scatter coef2b specification, msize(medium) color(sand) symbol(diamond)) ///
	   (rcap ci_lower2b ci_upper2b specification, lwidth(medium) color(sand)) ///
	   (scatter coef3b specification, msize(medium) color(maroon) symbol(square)) ///
	   (rcap ci_lower3b ci_upper3b specification, lwidth(medium) color(maroon)), ///
	   xlabel(1 "Total Cost" 2"Patient Cost" 3"Insurer Cost" 5 "Total Cost" 6"Patient Cost" 7 "Insurer Cost" 9 "Total Cost" 10"Patient Cost" 11"Insurer Cost", angle(20) labsize(small) nogrid) ///
	   legend(order(1 "Colonoscopy" 3 "Stool-Based DNA Test" 5 "Stool-Based Blood Test") pos(6) col(3)) ///
	   yline(0) ///
	   xtitle("") ///
	   ylabel(-550(50)250) ///
	   ytitle("Estimated Coefficient")

*********Figure 10 - Zero OOP Share Estimates***********
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50
gen specification = runiformint(0,3)

sort age time

tab zero_oop_dna, missing

xtset age time
replace zero_oop_dna = l.zero_oop_dna if zero_oop_dna == . 
tab zero_oop_dna, missing

forvalue i = 1/45{
	
	replace zero_oop_dna = f.zero_oop_dna if zero_oop_dna == .
}


regress zero_oop_colonoscopy recommendation acs male dependent i.time i.age, cluster(age)

replace     coef1 = r(table)[1,1] if specification == 1 
replace ci_lower1 = r(table)[5,1] if specification == 1
replace ci_upper1 = r(table)[6,1] if specification == 1

replace     coef1b = r(table)[1,2] if specification == 1 
replace ci_lower1b = r(table)[5,2] if specification == 1
replace ci_upper1b = r(table)[6,2] if specification == 1

regress zero_oop_dna recommendation acs male dependent i.time i.age, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 2 
replace ci_lower2 = r(table)[5,1] if specification == 2
replace ci_upper2 = r(table)[6,1] if specification == 2

replace     coef2b = r(table)[1,2] if specification == 2 
replace ci_lower2b = r(table)[5,2] if specification == 2
replace ci_upper2b = r(table)[6,2] if specification == 2

regress zero_oop_fecal_blood recommendation acs male dependent i.time i.age, cluster(age)

replace     coef3 = r(table)[1,1] if specification == 3 
replace ci_lower3 = r(table)[5,1] if specification == 3
replace ci_upper3 = r(table)[6,1] if specification == 3

replace     coef3b = r(table)[1,2] if specification == 3 
replace ci_lower3b = r(table)[5,2] if specification == 3
replace ci_upper3b = r(table)[6,2] if specification == 3

duplicates drop specification, force

twoway (scatter coef1 specification, msize(medium) color(dkgreen) symbol(triangle) ) ///
	   (rcap ci_lower1 ci_upper1 specification, lwidth(medium) color(dkgreen)) ///
	   (scatter coef2 specification, msize(medium) color(sand) symbol(diamond)) ///
	   (rcap ci_lower2 ci_upper2 specification, lwidth(medium) color(sand)) ///
	   (scatter coef3 specification, msize(medium) color(maroon) symbol(square)) ///
	   (rcap ci_lower3 ci_upper3 specification, lwidth(medium) color(maroon)), ///
	   xlabel(none, nogrid) ///
	   xscale(range(0 4)) ///
	   legend(order(1 "Colonoscopy" 3 "Stool-Based DNA Test" 5 "Stool-Based Blood Test") pos(6) col(3)) ///
	   yline(0) ///
	   xtitle("") ///
	   ylabel(-0.8(0.1)0.5) ///
	   ytitle("Estimated Coefficient")

twoway (scatter coef1b specification, msize(medium) color(dkgreen) symbol(triangle) ) ///
	   (rcap ci_lower1b ci_upper1b specification, lwidth(medium) color(dkgreen)) ///
	   (scatter coef2b specification, msize(medium) color(sand) symbol(diamond)) ///
	   (rcap ci_lower2b ci_upper2b specification, lwidth(medium) color(sand)) ///
	   (scatter coef3b specification, msize(medium) color(maroon) symbol(square)) ///
	   (rcap ci_lower3b ci_upper3b specification, lwidth(medium) color(maroon)), ///
	   xlabel(none, nogrid) ///
	   xscale(range(0 4)) ///
	   legend(order(1 "Colonoscopy" 3 "Stool-Based DNA Test" 5 "Stool-Based Blood Test") pos(6) col(3)) ///
	   yline(0) ///
	   xtitle("") ///
	   	ylabel(-0.8(0.1)0.5) ///
	   ytitle("Estimated Coefficient")
	   
*********Figure 11 - Costs Estimates - OP vs. PHYS***********
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50
gen specification = runiformint(0,8)

regress total_cost_colonoscopy_phys recommendation acs male dependent i.time i.age, cluster(age)

replace     coef1 = r(table)[1,1] if specification == 1 
replace ci_lower1 = r(table)[5,1] if specification == 1
replace ci_upper1 = r(table)[6,1] if specification == 1

replace     coef1b = r(table)[1,2] if specification == 1 
replace ci_lower1b = r(table)[5,2] if specification == 1
replace ci_upper1b = r(table)[6,2] if specification == 1

regress oop_colonoscopy_phys recommendation acs male dependent i.time i.age, cluster(age)

replace     coef1 = r(table)[1,1] if specification == 2 
replace ci_lower1 = r(table)[5,1] if specification == 2
replace ci_upper1 = r(table)[6,1] if specification == 2

replace     coef1b = r(table)[1,2] if specification == 2 
replace ci_lower1b = r(table)[5,2] if specification == 2
replace ci_upper1b = r(table)[6,2] if specification == 2

regress insurer_colonoscopy_phys recommendation acs male dependent i.time i.age, cluster(age)

replace     coef1 = r(table)[1,1] if specification == 3 
replace ci_lower1 = r(table)[5,1] if specification == 3
replace ci_upper1 = r(table)[6,1] if specification == 3

replace     coef1b = r(table)[1,2] if specification == 3 
replace ci_lower1b = r(table)[5,2] if specification == 3
replace ci_upper1b = r(table)[6,2] if specification == 3

regress total_cost_colonoscopy_op recommendation acs male dependent i.time i.age, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 5 
replace ci_lower2 = r(table)[5,1] if specification == 5
replace ci_upper2 = r(table)[6,1] if specification == 5

replace     coef2b = r(table)[1,2] if specification == 5 
replace ci_lower2b = r(table)[5,2] if specification == 5
replace ci_upper2b = r(table)[6,2] if specification == 5

regress oop_colonoscopy_op recommendation acs male dependent i.time i.age, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 6 
replace ci_lower2 = r(table)[5,1] if specification == 6
replace ci_upper2 = r(table)[6,1] if specification == 6

replace     coef2b = r(table)[1,2] if specification == 6 
replace ci_lower2b = r(table)[5,2] if specification == 6
replace ci_upper2b = r(table)[6,2] if specification == 6

regress insurer_colonoscopy_op recommendation acs male dependent i.time i.age, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 7 
replace ci_lower2 = r(table)[5,1] if specification == 7
replace ci_upper2 = r(table)[6,1] if specification == 7

replace     coef2b = r(table)[1,2] if specification == 7 
replace ci_lower2b = r(table)[5,2] if specification == 7
replace ci_upper2b = r(table)[6,2] if specification == 7

duplicates drop specification, force

twoway (scatter coef1 specification, msize(medium) color(dkgreen) symbol(triangle) ) ///
	   (rcap ci_lower1 ci_upper1 specification, lwidth(medium) color(dkgreen)) ///
	   (scatter coef2 specification, msize(medium) color(sand) symbol(diamond)) ///
	   (rcap ci_lower2 ci_upper2 specification, lwidth(medium) color(sand)), ///
	   xlabel(1 "Total Cost" 2"Patient Cost" 3"Insurer Cost" 5 "Total Cost" 6"Patient Cost" 7 "Insurer Cost", angle(20) labsize(small) nogrid) ///
	   legend(order(1 "Physician" 3 "Outpatient") pos(6) col(3)) ///
	   yline(0) ///
	   xtitle("") ///
	   ylabel(-60(10)70) ///
	   ytitle("Estimated Coefficient")

twoway (scatter coef1b specification, msize(medium) color(dkgreen) symbol(triangle) ) ///
	   (rcap ci_lower1b ci_upper1b specification, lwidth(medium) color(dkgreen)) ///
	   (scatter coef2b specification, msize(medium) color(sand) symbol(diamond)) ///
	   (rcap ci_lower2b ci_upper2b specification, lwidth(medium) color(sand)), ///
	   xlabel(1 "Total Cost" 2"Patient Cost" 3"Insurer Cost" 5 "Total Cost" 6"Patient Cost" 7 "Insurer Cost", angle(20) labsize(small) nogrid) ///
	   legend(order(1 "Physician" 3 "Outpatient") pos(6) col(3)) ///
	   yline(0) ///
	   xtitle("") ///
	   ylabel(-60(10)70) ///
	   ytitle("Estimated Coefficient")	   

*****Table 1 Panel B & C - Summary Statistics*********
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>49 

sum crc_claim_rate colonoscopy_claim_rate col_removal_claim_rate col_no_removal_claim_rate dna_claim_rate fecal_blood_test_claim_rate sigmoidoscopy_claim_rate

sum oop_colonoscopy insurer_colonoscopy total_cost_colonoscopy zero_oop_colonoscopy
sum oop_dna insurer_dna total_cost_dna zero_oop_dna
sum oop_fecal_blood insurer_fecal_blood total_cost_fecal_blood zero_oop_fecal_blood

   
*******Figure A2 - Sigmoidoscopy********
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

sum ttt
gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40
tab ttt_rec

regress sigmoidoscopy_claim_rate acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress sigmoidoscopy_claim_rate ib39.ttt_rec i.time i.age male dependent, cluster(age)

forvalues i = 0/100{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") ylabel(-5(5)10) note("ACS ATT: {&beta}(SE) = `att2'(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'***(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) ylabel(-0.3(0.1)0.3) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ytitle("Estimated Coefficient") text(0.335 -1 "ACS") text(0.335 35.5 "USPSTF")

************Figure A3a - Share of Colonoscopie with Polyp Removal Trends************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50

gen group = . 
replace group = 1 if age<45
replace group = 2 if age>45 & age<50
replace group = 3 if age>50

gen share_polyp = colonoscopy_removal/colonoscopy*100

collapse (sum) colonoscopy colonoscopy_removal (mean) share_polyp zero_oop_colonoscopy, by(group yr mnth time)

replace share_poly = . if yr == 2020 & mnth == 4
gen pct_pre = share_polyp if time < tm(2020m4)
gen pct_post = share_polyp if time > tm(2020m4)

twoway (line pct_pre time if group == 1, lpattern(longdash) pstyle(p1)) ///
	   (line pct_post time if group == 1, lpattern(longdash) pstyle(p1)) ///
	   (line pct_pre  time if group == 2, pstyle(p2)) ///
	   (line pct_post time if group == 2, pstyle(p2)) /// 
	   (line pct_pre  time if group == 3, lpattern(dash_dot) pstyle(p3)) ///
	   (line pct_post time if group == 3, lpattern(dash_dot) pstyle(p3)) ///
	   , xline(699.5 735.5) xlabel(660 "1/15" 672 "1/16" 684 "1/17" 696 "1/18" 708 "1/19" 720 "1/20" 732 "1/21" 744 "1/22", nogrid)legend(order(1 "40-44 Years" 3 "46-49 Years" 5 "51-55 Years" ) position(6) col(3)) xtitle("Month/Year") ytitle(Percent of Colonscopies with Polylp Removal) text(46.4 699.5 "ACS") text(46.4 735.5 "USPSTF")

twoway (line pct_pre time if group == 1, lpattern(longdash) pstyle(p1)) ///
	   (line pct_post time if group == 1, lpattern(longdash) pstyle(p1)) ///
	   (line pct_pre  time if group == 2, pstyle(p2)) ///
	   (line pct_post time if group == 2, pstyle(p2)) /// 
	   , xline(699.5 735.5) xlabel(660 "1/15" 672 "1/16" 684 "1/17" 696 "1/18" 708 "1/19" 720 "1/20" 732 "1/21" 744 "1/22", nogrid)legend(order(1 "40-44 Years" 3 "46-49 Years" 5 "51-55 Years" ) position(6) col(3)) xtitle("Month/Year") ytitle(Percent of Colonscopies with Polylp Removal) text(46.4 699.5 "ACS") text(46.4 735.5 "USPSTF")

	   
*************Figure A3b - Share of Colonscopies with Polyp Removal************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40
tab ttt_rec 

gen share_polyp = colonoscopy_removal/colonoscopy*100

regress share_polyp acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress share_polyp ib39.ttt_rec i.time i.age male dependent, cluster(age)

forvalues i = 0/120{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") note("ACS ATT: {&beta}(SE) = `att2'(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'***(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ytitle("Estimated Coefficient") text(11.3 -1 "ACS") text(11.3 35.5 "USPSTF")



***************Figure A4a - Colonoscopy Total Cost************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

sum ttt
gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40
tab ttt_rec 

regress total_cost_colonoscopy acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress total_cost_colonoscopy ib39.ttt_rec i.time i.age male dependent, cluster(age)

forvalues i = 0/120{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") note("ACS ATT: {&beta}(SE) = `att2'(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'**(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ylabel(-200(50)300) ytitle("Estimated Coefficient") text(335 -1 "ACS") text(335 35.5 "USPSTF")
	   

	  
***************Figure - A4b Colonoscopy OOP************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

sum ttt
gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40
tab ttt_rec 

regress oop_colonoscopy acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress oop_colonoscopy ib39.ttt_rec i.time i.age male dependent, cluster(age)

forvalues i = 0/120{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") note("ACS ATT: {&beta}(SE) = `att2'***(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'***(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ylabel(-200(50)300) ytitle("Estimated Coefficient") text(335 -1 "ACS") text(335 35.5 "USPSTF")


***************Figure A4c - Colonoscopy Insurer************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

sum ttt
gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40

regress insurer_colonoscopy acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress insurer_colonoscopy ib39.ttt_rec i.time i.age male dependent, cluster(age)


forvalues i = 0/100{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}


duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") note("ACS ATT: {&beta}(SE) = `att2'***(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'***(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ylabel(-200(50)300) ytitle("Estimated Coefficient") text(335 -1 "ACS") text(335 35.5 "USPSTF") 
	   	 
	 
***************Figure A5a - Total Cost DNA************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40
tab ttt_rec

regress total_cost_dna acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress total_cost_dna ib39.ttt_rec i.time i.age male dependent, cluster(age)

forvalues i = 0/100{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") note("ACS ATT: {&beta}(SE) = `att2'***(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ylabel(-1500(250)1000) ytitle("Estimated Coefficient") text(1150 -1 "ACS") text(1150 35.5 "USPSTF") 	   
	    
**************Figure A5b - OOP DNA************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

xtset age time

gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40
tab ttt_rec

regress oop_dna acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress oop_dna ib39.ttt_rec i.time i.age male dependent, cluster(age)

forvalues i = 0/100{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") note("ACS ATT: {&beta}(SE) = `att2'(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ylabel(-1500(250)1000) ytitle("Estimated Coefficient") text(1150 -1 "ACS") text(1150 35.5 "USPSTF") 	   
	
	
	
**************Figure A5c - Insurer Cost DNA************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

xtset age time

gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40
tab ttt_rec

regress insurer_dna acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress insurer_dna ib39.ttt_rec i.time i.age male dependent, cluster(age)

forvalues i = 0/100{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") note("ACS ATT: {&beta}(SE) = `att2'*(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ylabel(-1500(250)1000) ytitle("Estimated Coefficient") text(1150 -1 "ACS") text(1150 35.5 "USPSTF") 


**************Figure A6a - Total Cost Blood Test************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

xtset age time

gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40
tab ttt_rec

regress total_cost_fecal_blood acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress total_cost_fecal_blood ib39.ttt_rec i.time i.age male dependent, cluster(age)

forvalues i = 0/100{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") note("ACS ATT: {&beta}(SE) = `att2'(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'***(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ytitle("Estimated Coefficient") text(11.35 -1 "ACS") text(11.35 35.5 "USPSTF")

**************Figure A6b - OOP Cost Blood Test************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

xtset age time

gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40
tab ttt_rec

regress oop_fecal_blood acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress oop_fecal_blood ib39.ttt_rec i.time i.age male dependent, cluster(age)

forvalues i = 0/100{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") note("ACS ATT: {&beta}(SE) = `att2'*(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ylabel(-10(5)10) ytitle("Estimated Coefficient") text(11.35 -1 "ACS") text(11.35 35.5 "USPSTF") 
 
**************Figure A6c - Insurer Cost Blood Test************
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

xtset age time

gen ttt_rec = ttt
replace ttt_rec = -1 if ttt_rec == . 
replace ttt_rec = ttt_rec + 40
tab ttt_rec

regress insurer_fecal_blood acs recommendation male dependent i.time i.age, cluster(age)
local att1 = e(b)[1,1]
local att2 : display %4.3f `att1'
local se1 = sqrt(e(V)[1,1])
local se2 : display %4.3f `se1'

local att3 = e(b)[1,2]
local att4 : display %4.3f `att3'
local se3 = sqrt(e(V)[2,2])
local se4 : display %4.3f `se3'

regress insurer_fecal_blood ib39.ttt_rec i.time i.age male dependent, cluster(age)

forvalues i = 0/100{
	display `i'
	replace coef = r(table)[1, `i'] if ttt == (`i'-41)
	replace ci_lower = r(table)[5, `i'] if ttt == (`i'-41)
	replace ci_upper = r(table)[6, `i'] if ttt == (`i'-41)
}

duplicates drop ttt, force 

twoway (scatter coef ttt, msize(small)) (rcap ci_upper ci_lower ttt, lwidth(thin)), xline(-1 35.5) yline(0) graphregion(color(white)) xtitle("Month/Year") note("ACS ATT: {&beta}(SE) = `att2'(`se2')" "USPSTF ATT: {&beta}(SE) = `att4'***(`se4')", pos(6) size(12pt)) legend(off) scale(1.2) xlab( -40 "1/15" -28 "1/16" -16 "1/17" -4 "1/18" 8 "1/19" 20 "1/20" 32 "1/21" 44 "1/22",nogrid) ylabel(-10(5)10) ytitle("Estimated Coefficient") text(11.35 -1 "ACS") text(11.35 35.5 "USPSTF") 
	  
*********Figure A7 - Costs Estimates (Winsorized)***********
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50
gen specification = runiformint(0,12)

sort age time
order age time dna_test total_cost_dna insurer_dna oop_dna

tab dna_test

xtset age time

regress total_cost_colonoscopy_win recommendation acs male dependent i.time i.age, cluster(age)

replace coef1 = r(table)[1,1] if specification == 1 
replace ci_lower1 = r(table)[5,1] if specification == 1
replace ci_upper1 = r(table)[6,1] if specification == 1

replace coef1b = r(table)[1,2] if specification == 1 
replace ci_lower1b = r(table)[5,2] if specification == 1
replace ci_upper1b = r(table)[6,2] if specification == 1


regress oop_colonoscopy_win recommendation acs dependent male dependent i.time i.age, cluster(age)

replace     coef1 = r(table)[1,1] if specification == 2 
replace ci_lower1 = r(table)[5,1] if specification == 2
replace ci_upper1 = r(table)[6,1] if specification == 2

replace     coef1b = r(table)[1,2] if specification == 2 
replace ci_lower1b = r(table)[5,2] if specification == 2
replace ci_upper1b = r(table)[6,2] if specification == 2

regress insurer_colonoscopy_win recommendation acs male dependent i.time i.age, cluster(age)

replace     coef1 = r(table)[1,1] if specification == 3 
replace ci_lower1 = r(table)[5,1] if specification == 3
replace ci_upper1 = r(table)[6,1] if specification == 3

replace     coef1b = r(table)[1,2] if specification == 3 
replace ci_lower1b = r(table)[5,2] if specification == 3
replace ci_upper1b = r(table)[6,2] if specification == 3

regress total_cost_dna_win recommendation acs male dependent i.time i.age, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 5 
replace ci_lower2 = r(table)[5,1] if specification == 5
replace ci_upper2 = r(table)[6,1] if specification == 5

replace     coef2b = r(table)[1,2] if specification == 5 
replace ci_lower2b = r(table)[5,2] if specification == 5
replace ci_upper2b = r(table)[6,2] if specification == 5

regress oop_dna_win recommendation acs male dependent i.time i.age, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 6 
replace ci_lower2 = r(table)[5,1] if specification == 6
replace ci_upper2 = r(table)[6,1] if specification == 6

replace     coef2b = r(table)[1,2] if specification == 6 
replace ci_lower2b = r(table)[5,2] if specification == 6
replace ci_upper2b = r(table)[6,2] if specification == 6

regress insurer_dna_win recommendation acs male dependent i.time i.age, cluster(age)

replace     coef2 = r(table)[1,1] if specification == 7 
replace ci_lower2 = r(table)[5,1] if specification == 7
replace ci_upper2 = r(table)[6,1] if specification == 7

replace     coef2b = r(table)[1,2] if specification == 7 
replace ci_lower2b = r(table)[5,2] if specification == 7
replace ci_upper2b = r(table)[6,2] if specification == 7

regress total_cost_fecal_blood_win recommendation acs male dependent i.time i.age, cluster(age)

replace     coef3 = r(table)[1,1] if specification == 9 
replace ci_lower3 = r(table)[5,1] if specification == 9
replace ci_upper3 = r(table)[6,1] if specification == 9

replace     coef3b = r(table)[1,2] if specification == 9 
replace ci_lower3b = r(table)[5,2] if specification == 9
replace ci_upper3b = r(table)[6,2] if specification == 9

regress oop_fecal_blood_win recommendation acs male dependent i.time i.age, cluster(age)

replace     coef3 = r(table)[1,1] if specification == 10 
replace ci_lower3 = r(table)[5,1] if specification == 10
replace ci_upper3 = r(table)[6,1] if specification == 10

replace     coef3b = r(table)[1,2] if specification == 10 
replace ci_lower3b = r(table)[5,2] if specification == 10
replace ci_upper3b = r(table)[6,2] if specification == 10

regress insurer_fecal_blood_win recommendation acs male dependent i.time i.age, cluster(age)

replace     coef3 = r(table)[1,1] if specification == 11 
replace ci_lower3 = r(table)[5,1] if specification == 11
replace ci_upper3 = r(table)[6,1] if specification == 11

replace     coef3b = r(table)[1,2] if specification == 11 
replace ci_lower3b = r(table)[5,2] if specification == 11
replace ci_upper3b = r(table)[6,2] if specification == 11

duplicates drop specification, force

twoway (scatter coef1 specification, msize(medium) color(dkgreen) symbol(triangle) ) ///
	   (rcap ci_lower1 ci_upper1 specification, lwidth(medium) color(dkgreen)) ///
	   (scatter coef2 specification, msize(medium) color(sand) symbol(diamond)) ///
	   (rcap ci_lower2 ci_upper2 specification, lwidth(medium) color(sand)) ///
	   (scatter coef3 specification, msize(medium) color(maroon) symbol(square)) ///
	   (rcap ci_lower3 ci_upper3 specification, lwidth(medium) color(maroon)), ///
	   xlabel(1 "Total Cost" 2"Patient Cost" 3"Insurer Cost" 5 "Total Cost" 6"Patient Cost" 7 "Insurer Cost" 9 "Total Cost" 10"Patient Cost" 11"Insurer Cost", angle(20) labsize(small) nogrid) ///
	   legend(order(1 "Colonoscopy" 3 "Stool-Based DNA Test" 5 "Stool-Based Blood Test") pos(6) col(3)) ///
	   yline(0) ///
	   xtitle("") ///
	   ylabel(-300(50)150) ///
	   ytitle("Estimated Coefficient")
	   
twoway (scatter coef1b specification, msize(medium) color(dkgreen) symbol(triangle) ) ///
	   (rcap ci_lower1b ci_upper1b specification, lwidth(medium) color(dkgreen)) ///
	   (scatter coef2b specification, msize(medium) color(sand) symbol(diamond)) ///
	   (rcap ci_lower2b ci_upper2b specification, lwidth(medium) color(sand)) ///
	   (scatter coef3b specification, msize(medium) color(maroon) symbol(square)) ///
	   (rcap ci_lower3b ci_upper3b specification, lwidth(medium) color(maroon)), ///
	   xlabel(1 "Total Cost" 2"Patient Cost" 3"Insurer Cost" 5 "Total Cost" 6"Patient Cost" 7 "Insurer Cost" 9 "Total Cost" 10"Patient Cost" 11"Insurer Cost", angle(20) labsize(small) nogrid) ///
	   legend(order(1 "Colonoscopy" 3 "Stool-Based DNA Test" 5 "Stool-Based Blood Test") pos(6) col(3)) ///
	   yline(0) ///
	   xtitle("") ///
	   ylabel(-300(50)150) ///
	   ytitle("Estimated Coefficient")
	   
	 	
	  
log off 

*******Disclosure - Numerators********  
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
drop if age>50

egen total_crc  = sum(crc_claim)
egen total_colnoscopy = sum(colonoscopy)
egen total_cologuard = sum(dna_test)
egen total_fecal_test = sum(fecal_blood_test)
egen total_sigmoidoscopy = sum(sigmoidoscopy)

egen total_col_polyp = sum(colonoscopy_removal)
egen total_col_no_polyp = sum(colonoscopy_no_removal)
egen total_col_in_network = sum(colonoscopy_in_network)
egen total_col_out_network = sum(colonoscopy_out_network)


sum total_crc total_colnoscopy total_cologuard total_fecal_test total_sigmoidoscopy total_col_polyp total_col_no_polyp total_col_in_network total_col_out_network

egen total_crc_drop_2020  = sum(crc_claim) if yr != 2020
egen total_colnoscopy_drop_2020 = sum(colonoscopy) if yr != 2020
egen total_cologuard_drop_2020 = sum(dna_test) if  yr != 2020
egen total_fecal_test_drop_2020 = sum(fecal_blood_test) if yr != 2020

sum total_crc_drop_2020 total_colnoscopy_drop_2020 total_cologuard_drop_2020 total_fecal_test_drop_2020

egen total_colonoscopy_removal = sum(colonoscopy_removal)
egen total_colonoscopy_no_removal = sum(colonoscopy_no_removal)

sum total_colonoscopy_removal total_colonoscopy_no_removal


*****Statistics for Pre-treatment Mean******
use analytic_full_sample.dta, replace
drop if age == 45 | age == 50
keep if age>45 & age<50
keep if time<700 & time>663

//Utilization Rate
sum crc_claim_rate colonoscopy_claim_rate dna_claim_rate fecal_blood_test_claim_rate col_removal_claim_rate col_no_removal_claim_rate col_out_network_claim_rate

//Cost
sum total_cost_colonoscopy oop_colonoscopy insurer_colonoscopy total_cost_fecal_blood oop_fecal_blood insurer_fecal_blood zero_oop_colonoscopy zero_oop_fecal_blood 

//Numerators
egen total_crc  = sum(crc_claim)
egen total_colonoscopy = sum(colonoscopy)
egen total_cologuard = sum(dna_test)
egen total_fecal_test = sum(fecal_blood_test)
egen total_colonoscopy_removal = sum(colonoscopy_removal)
egen total_colonoscopy_no_removal = sum(colonoscopy_no_removal)
sum total_crc total_colonoscopy total_cologuard total_fecal_test total_colonoscopy_removal total_colonoscopy_no_removal



