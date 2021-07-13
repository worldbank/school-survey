*=========================================================================*
* Project information at: https://github.com/worldbank/schoolsurvey-production
****** Country: OECD Data
****** Purpose: Cleaning of the UNESCO-UNICEF-WBG_OECD Survey on National education responses to COVID-19 - Round 3
****** Created by: OECD
****** Used by: OECD
****** Input  data : "${data}\021_2_OECD.dta" , OECD dataset from Covid19Survey_OECDData_forJSW3folder_07June2021.xlsx, sheet 1         
****** Output data : "${data}\022_2_clean_oecd.csv" and "${data}\022_2_clean_oecd.xlsx"
****** Language: English
*=========================================================================*

* In this do file: 
* This do file reads the converted oecd.dta for round 3 survey data and exports a cleaned .csv and .dta. 
* The script divides question sections by the report’s chapters and includes variables that were not included in the final report. 
* For information about cleaning conventions, review our data editing guidelines online.
* This step runs parallel to 021_2_clean_oecd.do
 
** Steps in this do-file:
* 0) Import the raw .dta for OECD
* 1) Clean OECD raw .dta following the structure of the questionnaire
* 2) Export Data

* Questionnaire Sections:
* 1. School Closures
* 2. School Calendar and Curricula
* 3. School Reopening Management
* 4. Distance Education Delivery Systems (including additional questions in S10
* 5. Teachers and Educational Personnel
* 6. Learning Assessments and Examinations
* 7. Financing
* 8. Locus of Decision Making
* 9. Equity Module
* 11. Health Protocol/Guidelines for Prevention and Control of COVID-19
* 12. Planning 2021

* Steps within each section:
* Step A - Variable renaming/dropping
*** RENAMING
*** DROPPING
* Step B - Structural conversions between OECD and UIS format
***Step B.1. "Select all that apply(SA)" v.s  "Select single(SS)"
***Step B.2. Disaggregations
* Step C - Variable labeling *******
* Step D - String to numerical (Yes, No, Select all that apply) *******
* Step E - Data cleaning *******
* Step F - Open section to clean specific interested questions *******

* Note: Each section will have their own Steps A - F.

*=========================================================================*

*---------------------------------------------------------------------------
* 0) Import OECD Data (Do Not Edit these lines)
*---------------------------------------------------------------------------

// put in a different .do file for conversion

	//import excel "", firstrow(variables) clear
	//export delimited "", replace
	//save ".dta", replace //

	use "${Data_raw}jsw3_oecd.dta", clear
  
*---------------------------------------------------------------------------
* 1) Clean OECD raw .dta
*---------------------------------------------------------------------------

* ALL QUESTIONNAIRE SECTIONS
*---------------------------------------------------------------------------
* Section 1. School Closures
*---------------------------------------------------------------------------

******* Step A - Variable renaming/droppin
**** RENAMING
** This is done for variables that can be at least fuzzily matched (usg to us, or simply due to naming inconsistency)
** aq1: usg to us
renvars aq1_usg_closed1 aq1_usg_closed2 aq1_usg_closed3 aq1_usg_fullyopen aq1_usg_open1 aq1_usg_open2 aq1_usg_open3 aq1_usg_open4 aq1_usg_open5 aq1_usg_open6 aq1_usg_open7 aq1_usg_other/aq1_us_closed1 aq1_us_closed2 aq1_us_closed3 aq1_us_fullyopen aq1_us_open1 aq1_us_open2 aq1_us_open3 aq1_us_open4 aq1_us_open5 aq1_us_open6 aq1_us_open7 aq1_us_other
** aq3
rename aq3_usg_periods aq3_us_periods
** aq4
renvars aq4_usg_min aq4_usg_max aq4_usg_typical / aq4_us_min aq4_us_max aq4_us_typical
** aq5
renvars aq5_usg_firststart aq5_usg_secondstart aq5_usg_thirdstart aq5_usg_firstend aq5_usg_secondend aq5_usg_thirdend / aq5_us_firststart aq5_us_secondstart aq5_us_thirdstart aq5_us_firstend aq5_us_secondend aq5_us_thirdend
** aq6
renvars aq6_usg_max aq6_usg_min aq6_usg_total aq6_usg_typical / aq6_us_max aq6_us_min aq6_us_total aq6_us_typical
**** DROPPING
** aq1_usv, ter
drop aq1_ter_closed1 aq1_ter_closed2 aq1_ter_closed3 aq1_ter_fullyopen aq1_ter_open1 aq1_ter_open2 aq1_ter_open3 aq1_ter_open4 aq1_ter_open5 aq1_ter_open6 aq1_ter_open7 aq1_ter_other
**drop aq1_usv_closed1 aq1_usv_closed2 aq1_usv_closed3 aq1_usv_fullyopen aq1_usv_open1 aq1_usv_open2 aq1_usv_open3 aq1_usv_open4 aq1_usv_open5 aq1_usv_open6 aq1_usv_open7 aq1_usv_other
drop aq3_ter_periods aq3_usv_periods
** aq4_usv, ter
drop aq4_usv_min aq4_usv_max aq4_usv_typical aq4_ter_min aq4_ter_max aq4_ter_typical

******* Step B - Structural conversions between OECD and UIS format
*Step B.1. "Select all that apply(SA)" v.s  "Select single(SS)"
*Step B.2. Disaggregations

******* Step C - Variable labeling *******

** Question 1
	foreach i in pp p ls us {
		foreach j in closed1 closed2 closed3 fullyopen open1 open2 open3 open4 open5 open6 open7 other {
				label var aq1_`i'_`j' "`i': `j'"				
		}
	}

** Question 2
	foreach i in all {
		foreach j in diff {
				label var aq2_`i'_`j' "`i': `j'"	
		}
	}

** Question 3 
	foreach i in pp p ls us {
		foreach j in periods {
				label var aq3_`i'_`j' "`i': `j'"	
		}
	}
** Question 4
	foreach i in pp p ls us {
		foreach j in max min typical {
				label var aq4_`i'_`j' "`i': `j'"	
		}
	}
** Question 5
	foreach i in pp p ls us {
		foreach j in firstend firststart secondend secondstart thirdend thirdstart {
				label var aq5_`i'_`j' "`i': `j'"	
		}
	}	
** Question 6
	foreach i in pp p ls us {
		foreach j in max min total typical {
				label var aq6_`i'_`j' "`i': `j'"	
		}
	}
******* Step D - String to numerical (Yes, No, Select all that apply *******

**** Question 1 - What was the status of school opening in the education system as of February 1st 2021?
	foreach i in pp p ls us {
		foreach j in closed1 closed2 closed3 fullyopen open1 open2 open3 open4 open5 open6 open7 other {
		replace aq1_`i'_`j'="997" if aq1_`i'_`j'=="Do not know (m)"
		replace aq1_`i'_`j'="999" if aq1_`i'_`j'=="Include in another column (xc)"
		replace aq1_`i'_`j'="998" if aq1_`i'_`j'=="Not applicable (a)"	
		replace aq1_`i'_`j'="1" if aq1_`i'_`j'=="Yes"
		replace aq1_`i'_`j'="0" if aq1_`i'_`j'=="No"
		destring aq1_`i'_`j', replace

		}
	}

**** Question 2 - Were there any differences between sub-national regions in the number of time periods [time periods of a minimum of one full weeks] when schools were fully closed due to COVID-19 pandemic (excluding school holidays) from January to December 2020 (i.e. government-mandated or recommended school closures affecting most or all of a region's student population)? 

foreach var of varlist aq2_all_diff {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="1" if `var'=="Yes"
		replace `var'="0" if `var'=="No"
		destring `var' , replace
}

**** Question 3 - If there were no differences between sub-national regions, over how many time periods were schools fully closed due to COVID-19 pandemic (excluding school holidays) from January to December 2020 (i.e. government-mandated or/and recommended closures of educational institutions affecting all of the student population)? 
	foreach i in pp p ls us {
		foreach j in periods {
		replace aq3_`i'_`j'="997" if aq3_`i'_`j'=="Do not know (m)"
		replace aq3_`i'_`j'="998" if aq3_`i'_`j'=="Not applicable (a)"
		destring aq3_`i'_`j', replace
		}
	}

**** Question 4 - If there were differences between sub-national regions, please indicate the minimum and maximum number of time periods schools in a region were fully closed due to COVID-19 pandemic (excluding school holidays) from January to December 2020? 
	foreach i in pp p ls us {
		foreach j in max min typical {
		replace aq4_`i'_`j'="997" if aq4_`i'_`j'=="Do not know (m)"
		replace aq4_`i'_`j'="998" if aq4_`i'_`j'=="Not applicable (a)"
		destring aq4_`i'_`j', replace
		}
	}

**** Question 5 - Starting and ending dates of nation-wide school closures in 2020 (from January to december), by ISCED levels
	foreach i in pp p ls us {
		foreach j in firstend firststart secondend secondstart thirdend thirdstart {
	//// Special case for Japan
		replace aq5_`i'_`j'="999" if aq5_`i'_`j'=="The end of  March"
		///
		replace aq5_`i'_`j'="998" if aq5_`i'_`j'=="Not applicable (a)"
		replace aq5_`i'_`j'="999" if aq5_`i'_`j'=="Included in another column"
		replace aq5_`i'_`j'="997" if aq5_`i'_`j'=="Don't know"
		replace aq5_`i'_`j'="997" if aq5_`i'_`j'=="Do not know (m)"
	//// Addressing closure dates in 2021 instead of 2020. aq5_p_secondend NLD, aq5_pp_secondend NLD, aq5_ter_firstend CZE,aq5_ter_secondend FRA. TER variables not relevant here, but coded out of abundance of caution.
		replace aq5_`i'_`j'="31/12/2020" if aq5_`i'_`j'=="08/02/2021" | aq5_`i'_`j'=="07/05/2021"  | aq5_`i'_`j'=="24/01/2021"
//// Additional cleaning for dates not in DD/MM/YYYY format
		replace aq5_`i'_`j'="11/05/2020" if aq5_`i'_`j'=="11th of May 2020" 
		replace aq5_`i'_`j'="16/03/2020" if aq5_`i'_`j'=="16th March 2020" 
		replace aq5_`i'_`j'="16/03/2020" if aq5_`i'_`j'=="16th of March 2020" 
		replace aq5_`i'_`j'="25/05/2020" if aq5_`i'_`j'=="25th May 2020"
		replace aq5_`i'_`j'="25/05/2020" if aq5_`i'_`j'=="25th of May 2020"

								
		}
	}

**** Question 6 - Total number of instruction days between January - December 2020 (excluding school holidays, public holidays and weekends) where schools were fully closed due to COVID-19 pandemic, by ISCED levels 
	foreach i in pp p ls us {
		foreach j in max min total typical {
		replace aq6_`i'_`j'="997" if aq6_`i'_`j'=="(m)"
		replace aq6_`i'_`j'="997" if aq6_`i'_`j'=="Do not know (m)"
		replace aq6_`i'_`j'="998" if aq6_`i'_`j'=="Not applicable (a)"
		destring aq6_`i'_`j', replace
		}
	}
******* Step E - Data cleaning *******

	*** Value labelling
	label define aq1_values 0 "No" 1 "Yes" 999 "Missing" 997 "Do Not Know" 998 "Not Applicable"
	label value aq1_us* aq1_ls* aq1_p* aq1_pp* aq1_values
	
	label define aq2_values 0 "No" 1 "Yes" 997 "Do Not Know" 
	label value aq2_all_diff aq2_values
	
	label define aq3_values 0 "0" 1 "1" 2 "2" 3 "3" 997 "Do Not Know" 998 "Not Applicable"
	label value aq3_us* aq3_ls* aq3_p* aq3_pp* aq3_values

	label define aq4_values 1 "1" 2 "2" 3 "3" 997 "Do Not Know" 998 "Not Applicable"
	label value aq4_us* aq4_ls* aq4_p* aq4_pp* aq4_values
	
	* Question 5 still a string,  so cannot label values.
	
	label define aq6_values 997 "Do Not Know" 998 "Not Applicable" 999 "Missing"
	label value aq6_us* aq6_ls* aq6_p* aq6_pp* aq6_values
	
******* Step F - Open section to clean specific interested questions *******

*---------------------------------------------------------------------------
* Section 2. School Calendar and Curricula
*---------------------------------------------------------------------------


******* Step A - Variable renaming/droppin
**** RENAMING
** This is done for variables that can be at least fuzzily matched (usg to us, or simply due to naming inconsistency)
** bq11
renvars bq11a_usg_subject1 bq11a_usg_subject2 bq11a_usg_subject3 bq11a_usg_subject5 bq11a_usg_subject4 / bq11a_us_subject1 bq11a_us_subject2 bq11a_us_subject3 bq11a_us_subject5 bq11a_us_subject4 
***** DROPPING*
* bq1_usv, ter
drop bq1_ter_2020 bq1_usv_2020

******* Step B - Structural conversions between OECD and UIS format
*Step B.1. "Select all that apply(SA)" v.s  "Select single(SS)"

** bq1 (SA in JSW3; SS in OECD)
	/* bq1_pp_2020 -> bq1_1_pp_academicyearextended bq1_1_pp_prioritizationofcerta bq1_1_pp_depends bq1_1_pp_otheradj bq1_1_pp_no bq1_1_pp_other */
	/* bq1_p_2020 -> bq1_1_p_academicyearextended bq1_1_p_prioritizationofcerta bq1_1_p_depends bq1_1_p_otheradj bq1_1_p_no bq1_1_p_other */
	/* bq1_ls_2020 -> bq1_1_ls_academicyearextended bq1_1_ls_prioritizationofcerta bq1_1_ls_depends bq1_1_ls_otheradj bq1_1_ls_no bq1_1_ls_other */
	/* bq1_usg_2020 -> bq1_1_us_academicyearextended bq1_1_us_prioritizationofcerta bq1_1_us_depends bq1_1_us_otheradj bq1_1_us_no bq1_1_us_other */
	/* bq1_pp_2021 -> bq1_2_pp_academicyearextended bq1_2_pp_prioritizationofcerta bq1_2_pp_depends bq1_2_pp_otheradj bq1_2_pp_no bq1_2_pp_other */
	/* bq1_p_2021 -> bq1_2_p_academicyearextended bq1_2_p_prioritizationofcerta bq1_2_p_depends bq1_2_p_otheradj bq1_2_p_no bq1_2_p_other */
	/* bq1_ls_2021 -> bq1_2_ls_academicyearextended bq1_2_ls_prioritizationofcerta bq1_2_ls_depends bq1_2_ls_otheradj bq1_2_ls_no bq1_2_ls_other */
	/* bq1_usg_2021 -> bq1_2_us_academicyearextended bq1_2_us_prioritizationofcerta bq1_2_us_depends bq1_2_us_otheradj bq1_2_us_no bq1_2_us_other */
	
	** BQ1 - OECD does not have "Other", UIS does not have "Included in another row" or "Do not know"
	 * OECD "Do not know" is an "" empty answer in transformed data here
	 * OECD "Included in another row" is specific to Finland.

	 *** PRE-PRIMARY
gen bq1_1_pp_no="0"
gen bq1_2_pp_no="0"
replace bq1_1_pp_no="1" if bq1_pp_2020=="NO, no adjustment have been / will be made" 
replace bq1_2_pp_no="1" if bq1_pp_2021=="NO, no adjustment have been / will be made" 
replace bq1_1_pp_no="997" if bq1_pp_2020=="Do not know (m)" 
replace bq1_2_pp_no="997" if bq1_pp_2021=="Do not know (m)" 
replace bq1_1_pp_no="999" if bq1_pp_2020=="Include in another row (xr)" 
replace bq1_2_pp_no="999" if bq1_pp_2021=="Include in another row (xr)" 

gen bq1_1_pp_academicyearextended="0"
gen bq1_2_pp_academicyearextended="0"
replace bq1_1_pp_academicyearextended="1" if bq1_pp_2020=="YES, academic year extended  " 
replace bq1_2_pp_academicyearextended="1" if bq1_pp_2021=="YES, academic year extended  " 
replace bq1_1_pp_academicyearextended="997" if bq1_pp_2020=="Do not know (m)" 
replace bq1_2_pp_academicyearextended="997" if bq1_pp_2021=="Do not know (m)" 
replace bq1_1_pp_academicyearextended="999" if bq1_pp_2020=="Include in another row (xr)" 
replace bq1_2_pp_academicyearextended="999" if bq1_pp_2021=="Include in another row (xr)" 

gen bq1_1_pp_depends="0"
gen bq1_2_pp_depends="0"
replace bq1_1_pp_depends="1" if bq1_pp_2020=="YES, depends - Schools/Districts/the most local level of governance could decide at their own discretion" 
replace bq1_2_pp_depends="1" if bq1_pp_2021=="YES, depends - Schools/Districts/the most local level of governance could decide at their own discretion" 
replace bq1_1_pp_depends="997" if bq1_pp_2020=="Do not know (m)" 
replace bq1_2_pp_depends="997" if bq1_pp_2021=="Do not know (m)" 
replace bq1_1_pp_depends="999" if bq1_pp_2020=="Include in another row (xr)" 
replace bq1_2_pp_depends="999" if bq1_pp_2021=="Include in another row (xr)" 	
	
gen bq1_1_pp_otheradj="0"
gen bq1_2_pp_otheradj="0"
replace bq1_1_pp_otheradj="1" if bq1_pp_2020=="YES, other adjustments." 
replace bq1_2_pp_otheradj="1" if bq1_pp_2021=="YES, other adjustments." 
replace bq1_1_pp_otheradj="997" if bq1_pp_2020=="Do not know (m)" 
replace bq1_2_pp_otheradj="997" if bq1_pp_2021=="Do not know (m)" 
replace bq1_1_pp_otheradj="999" if bq1_pp_2020=="Include in another row (xr)" 
replace bq1_2_pp_otheradj="999" if bq1_pp_2021=="Include in another row (xr)" 	
	
gen bq1_1_pp_prioritizationofcerta="0"
gen bq1_2_pp_prioritizationofcerta="0"
replace bq1_1_pp_prioritizationofcerta="1" if bq1_pp_2020=="YES, prioritization of certain areas of the curriculum or certain skills" 
replace bq1_2_pp_prioritizationofcerta="1" if bq1_pp_2021=="YES, prioritization of certain areas of the curriculum or certain skills" 
replace bq1_1_pp_prioritizationofcerta="997" if bq1_pp_2020=="Do not know (m)" 
replace bq1_2_pp_prioritizationofcerta="997" if bq1_pp_2021=="Do not know (m)" 
replace bq1_1_pp_prioritizationofcerta="999" if bq1_pp_2020=="Include in another row (xr)" 
replace bq1_2_pp_prioritizationofcerta="999" if bq1_pp_2021=="Include in another row (xr)" 	
// Other does not exist in OECD
gen bq1_1_pp_other="0"
gen bq1_2_pp_other="0"
replace bq1_1_pp_other="997" if bq1_pp_2020=="Do not know (m)" 
replace bq1_2_pp_other="997" if bq1_pp_2021=="Do not know (m)" 
replace bq1_1_pp_other="999" if bq1_pp_2020=="Include in another row (xr)" 
replace bq1_2_pp_other="999" if bq1_pp_2021=="Include in another row (xr)" 
	
	*** PRIMARY
gen bq1_1_p_no="0"
gen bq1_2_p_no="0"
replace bq1_1_p_no="1" if bq1_p_2020=="NO, no adjustment have been / will be made" 
replace bq1_2_p_no="1" if bq1_p_2021=="NO, no adjustment have been / will be made" 
replace bq1_1_p_no="997" if bq1_p_2020=="Do not know (m)" 
replace bq1_2_p_no="997" if bq1_p_2021=="Do not know (m)" 
replace bq1_1_p_no="999" if bq1_p_2020=="Include in another row (xr)" 
replace bq1_2_p_no="999" if bq1_p_2021=="Include in another row (xr)" 

gen bq1_1_p_academicyearextended="0"
gen bq1_2_p_academicyearextended="0"
replace bq1_1_p_academicyearextended="1" if bq1_p_2020=="YES, academic year extended  " 
replace bq1_2_p_academicyearextended="1" if bq1_p_2021=="YES, academic year extended  " 
replace bq1_1_p_academicyearextended="997" if bq1_p_2020=="Do not know (m)" 
replace bq1_2_p_academicyearextended="997" if bq1_p_2021=="Do not know (m)" 
replace bq1_1_p_academicyearextended="999" if bq1_p_2020=="Include in another row (xr)" 
replace bq1_2_p_academicyearextended="999" if bq1_p_2021=="Include in another row (xr)" 
	
gen bq1_1_p_depends="0"
gen bq1_2_p_depends="0"
replace bq1_1_p_depends="1" if bq1_p_2020=="YES, depends - Schools/Districts/the most local level of governance could decide at their own discretion" 
replace bq1_2_p_depends="1" if bq1_p_2021=="YES, depends - Schools/Districts/the most local level of governance could decide at their own discretion" 
replace bq1_1_p_depends="997" if bq1_p_2020=="Do not know (m)" 
replace bq1_2_p_depends="997" if bq1_p_2021=="Do not know (m)" 
replace bq1_1_p_depends="999" if bq1_p_2020=="Include in another row (xr)" 
replace bq1_2_p_depends="999" if bq1_p_2021=="Include in another row (xr)"	
	
gen bq1_1_p_otheradj="0"
gen bq1_2_p_otheradj="0"
replace bq1_1_p_otheradj="1" if bq1_p_2020=="YES, other adjustments." 
replace bq1_2_p_otheradj="1" if bq1_p_2021=="YES, other adjustments." 
replace bq1_1_p_otheradj="997" if bq1_p_2020=="Do not know (m)" 
replace bq1_2_p_otheradj="997" if bq1_p_2021=="Do not know (m)" 
replace bq1_1_p_otheradj="999" if bq1_p_2020=="Include in another row (xr)" 
replace bq1_2_p_otheradj="999" if bq1_p_2021=="Include in another row (xr)" 

gen bq1_1_p_prioritizationofcerta="0"
gen bq1_2_p_prioritizationofcerta="0"
replace bq1_1_p_prioritizationofcerta="1" if bq1_p_2020=="YES, prioritization of certain areas of the curriculum or certain skills" 
replace bq1_2_p_prioritizationofcerta="1" if bq1_p_2021=="YES, prioritization of certain areas of the curriculum or certain skills" 
replace bq1_1_p_prioritizationofcerta="997" if bq1_p_2020=="Do not know (m)" 
replace bq1_2_p_prioritizationofcerta="997" if bq1_p_2021=="Do not know (m)" 
replace bq1_1_p_prioritizationofcerta="999" if bq1_p_2020=="Include in another row (xr)" 
replace bq1_2_p_prioritizationofcerta="999" if bq1_p_2021=="Include in another row (xr)" 

// Other does not exist in OECD
gen bq1_1_p_other="0"
gen bq1_2_p_other="0"
replace bq1_1_p_other="997" if bq1_p_2020=="Do not know (m)" 
replace bq1_2_p_other="997" if bq1_p_2021=="Do not know (m)" 
replace bq1_1_p_other="999" if bq1_p_2020=="Include in another row (xr)" 
replace bq1_2_p_other="999" if bq1_p_2021=="Include in another row (xr)" 

	 *** LOWER SECONDARY
gen bq1_1_ls_no="0"
gen bq1_2_ls_no="0"
replace bq1_1_ls_no="1" if bq1_ls_2020=="NO, no adjustment have been / will be made" 
replace bq1_2_ls_no="1" if bq1_ls_2021=="NO, no adjustment have been / will be made" 
replace bq1_1_ls_no="997" if bq1_ls_2020=="Do not know (m)" 
replace bq1_2_ls_no="997" if bq1_ls_2021=="Do not know (m)" 
replace bq1_1_ls_no="999" if bq1_ls_2020=="Include in another row (xr)" 
replace bq1_2_ls_no="999" if bq1_ls_2021=="Include in another row (xr)" 

gen bq1_1_ls_academicyearextended="0"
gen bq1_2_ls_academicyearextended="0"
replace bq1_1_ls_academicyearextended="1" if bq1_ls_2020=="YES, academic year extended  " 
replace bq1_2_ls_academicyearextended="1" if bq1_ls_2021=="YES, academic year extended  " 
replace bq1_1_ls_academicyearextended="997" if bq1_ls_2020=="Do not know (m)" 
replace bq1_2_ls_academicyearextended="997" if bq1_ls_2021=="Do not know (m)" 
replace bq1_1_ls_academicyearextended="999" if bq1_ls_2020=="Include in another row (xr)" 
replace bq1_2_ls_academicyearextended="999" if bq1_ls_2021=="Include in another row (xr)" 
	
gen bq1_1_ls_depends="0"
gen bq1_2_ls_depends="0"
replace bq1_1_ls_depends="1" if bq1_ls_2020=="YES, depends - Schools/Districts/the most local level of governance could decide at their own discretion" 
replace bq1_2_ls_depends="1" if bq1_ls_2021=="YES, depends - Schools/Districts/the most local level of governance could decide at their own discretion" 
replace bq1_1_ls_depends="997" if bq1_ls_2020=="Do not know (m)" 
replace bq1_2_ls_depends="997" if bq1_ls_2021=="Do not know (m)" 
replace bq1_1_ls_depends="999" if bq1_ls_2020=="Include in another row (xr)" 
replace bq1_2_ls_depends="999" if bq1_ls_2021=="Include in another row (xr)"	
	
gen bq1_1_ls_otheradj="0"
gen bq1_2_ls_otheradj="0"
replace bq1_1_ls_otheradj="1" if bq1_ls_2020=="YES, other adjustments." 
replace bq1_2_ls_otheradj="1" if bq1_ls_2021=="YES, other adjustments." 
replace bq1_1_ls_otheradj="997" if bq1_ls_2020=="Do not know (m)" 
replace bq1_2_ls_otheradj="997" if bq1_ls_2021=="Do not know (m)" 
replace bq1_1_ls_otheradj="999" if bq1_ls_2020=="Include in another row (xr)" 
replace bq1_2_ls_otheradj="999" if bq1_ls_2021=="Include in another row (xr)" 

gen bq1_1_ls_prioritizationofcerta="0"
gen bq1_2_ls_prioritizationofcerta="0"
replace bq1_1_ls_prioritizationofcerta="1" if bq1_ls_2020=="YES, prioritization of certain areas of the curriculum or certain skills" 
replace bq1_2_ls_prioritizationofcerta="1" if bq1_ls_2021=="YES, prioritization of certain areas of the curriculum or certain skills" 
replace bq1_1_ls_prioritizationofcerta="997" if bq1_ls_2020=="Do not know (m)" 
replace bq1_2_ls_prioritizationofcerta="997" if bq1_ls_2021=="Do not know (m)" 
replace bq1_1_ls_prioritizationofcerta="999" if bq1_ls_2020=="Include in another row (xr)" 
replace bq1_2_ls_prioritizationofcerta="999" if bq1_ls_2021=="Include in another row (xr)" 

// Other does not exist in OECD
gen bq1_1_ls_other="0"
gen bq1_2_ls_other="0"
replace bq1_1_ls_other="997" if bq1_ls_2020=="Do not know (m)" 
replace bq1_2_ls_other="997" if bq1_ls_2021=="Do not know (m)" 
replace bq1_1_ls_other="999" if bq1_ls_2020=="Include in another row (xr)" 
replace bq1_2_ls_other="999" if bq1_ls_2021=="Include in another row (xr)" 

	 *** UPPER SECONDARY
gen bq1_1_us_no="0"
gen bq1_2_us_no="0"
replace bq1_1_us_no="1" if bq1_usg_2020=="NO, no adjustment have been / will be made" 
replace bq1_2_us_no="1" if bq1_usg_2021=="NO, no adjustment have been / will be made" 
replace bq1_1_us_no="997" if bq1_usg_2020=="Do not know (m)" 
replace bq1_2_us_no="997" if bq1_usg_2021=="Do not know (m)" 
replace bq1_1_us_no="999" if bq1_usg_2020=="Include in another row (xr)" 
replace bq1_2_us_no="999" if bq1_usg_2021=="Include in another row (xr)" 

gen bq1_1_us_academicyearextended="0"
gen bq1_2_us_academicyearextended="0"
replace bq1_1_us_academicyearextended="1" if bq1_usg_2020=="YES, academic year extended  " 
replace bq1_2_us_academicyearextended="1" if bq1_usg_2021=="YES, academic year extended  " 
replace bq1_1_us_academicyearextended="997" if bq1_usg_2020=="Do not know (m)" 
replace bq1_2_us_academicyearextended="997" if bq1_usg_2021=="Do not know (m)" 
replace bq1_1_us_academicyearextended="999" if bq1_usg_2020=="Include in another row (xr)" 
replace bq1_2_us_academicyearextended="999" if bq1_usg_2021=="Include in another row (xr)" 
	
gen bq1_1_us_depends="0"
gen bq1_2_us_depends="0"
replace bq1_1_us_depends="1" if bq1_usg_2020=="YES, depends - Schools/Districts/the most local level of governance could decide at their own discretion" 
replace bq1_2_us_depends="1" if bq1_usg_2021=="YES, depends - Schools/Districts/the most local level of governance could decide at their own discretion" 
replace bq1_1_us_depends="997" if bq1_usg_2020=="Do not know (m)" 
replace bq1_2_us_depends="997" if bq1_usg_2021=="Do not know (m)" 
replace bq1_1_us_depends="999" if bq1_usg_2020=="Include in another row (xr)" 
replace bq1_2_us_depends="999" if bq1_usg_2021=="Include in another row (xr)"	
	
gen bq1_1_us_otheradj="0"
gen bq1_2_us_otheradj="0"
replace bq1_1_us_otheradj="1" if bq1_usg_2020=="YES, other adjustments." 
replace bq1_2_us_otheradj="1" if bq1_usg_2021=="YES, other adjustments." 
replace bq1_1_us_otheradj="997" if bq1_usg_2020=="Do not know (m)" 
replace bq1_2_us_otheradj="997" if bq1_usg_2021=="Do not know (m)" 
replace bq1_1_us_otheradj="999" if bq1_usg_2020=="Include in another row (xr)" 
replace bq1_2_us_otheradj="999" if bq1_usg_2021=="Include in another row (xr)" 

gen bq1_1_us_prioritizationofcerta="0"
gen bq1_2_us_prioritizationofcerta="0"
replace bq1_1_us_prioritizationofcerta="1" if bq1_usg_2020=="YES, prioritization of certain areas of the curriculum or certain skills" 
replace bq1_2_us_prioritizationofcerta="1" if bq1_usg_2021=="YES, prioritization of certain areas of the curriculum or certain skills" 
replace bq1_1_us_prioritizationofcerta="997" if bq1_usg_2020=="Do not know (m)" 
replace bq1_2_us_prioritizationofcerta="997" if bq1_usg_2021=="Do not know (m)" 
replace bq1_1_us_prioritizationofcerta="999" if bq1_usg_2020=="Include in another row (xr)" 
replace bq1_2_us_prioritizationofcerta="999" if bq1_usg_2021=="Include in another row (xr)" 

// Other does not exist in OECD
gen bq1_1_us_other="0"
gen bq1_2_us_other="0"
replace bq1_1_us_other="997" if bq1_usg_2020=="Do not know (m)" 
replace bq1_2_us_other="997" if bq1_usg_2021=="Do not know (m)" 
replace bq1_1_us_other="999" if bq1_usg_2020=="Include in another row (xr)" 
replace bq1_2_us_other="999" if bq1_usg_2021=="Include in another row (xr)" 

******* Drop all OECD-only variables once mapping is done
drop bq1_pp_2020 bq1_pp_2021 bq1_p_2020 bq1_p_2021 bq1_ls_2020 bq1_ls_2021 bq1_usg_2020 bq1_usg_2021

*Step B.2. Disaggregations

******* Step C - Variable labeling *******


	foreach i in pp p ls us {
		foreach j in no academicyearextended depends otheradj prioritizationofcerta other{
				label var bq1_1_`i'_`j' "`i': `j'"		
				label var bq1_2_`i'_`j' "`i': `j'"	
		}
	}
	
	
	label var bq2_all_regulation "Plan to revise regulation of time and curriculum after 2020/2021"

	foreach i in p ls us {
		foreach j in subject1 subject2 subject3 subject4 subject5{
				label var bq11a_`i'_`j' "`i': `j'"	
		}
	}
******* Step D - String to numerical (Yes, No, Select all that apply *******

**** Question 7 - Have/will adjustments been/be made to the school calendar dates and curriculum due to COVID-19 in the previous and current school year? 
** Already transformed in other part of code, because of adaptation of OECD structure to UIS structure.

**** Question 7a - If in Q7 you have confirmed prioritization of certain curriculum areas or skills for remote instruction during school closure in the school year 2019/2020, select up to five subjects that were prioritized:.
	foreach i in p ls us {
		foreach j in subject1 subject2 subject3 subject4 subject5{
		replace bq11a_`i'_`j'="997" if bq11a_`i'_`j'=="Do not know (m)"
		replace bq11a_`i'_`j'="999" if bq11a_`i'_`j'=="Include in another column (xc)"
		replace bq11a_`i'_`j'="998" if bq11a_`i'_`j'=="Not applicable (a)"	
		}
	}
	
** String to Numerical
foreach i in p ls us {
  foreach j in subject1 subject2 subject3 subject4 subject5 {
	* remove trailing and leading spaces
	replace bq11a_`i'_`j' = strrtrim(bq11a_`i'_`j')
	replace bq11a_`i'_`j' = strltrim(bq11a_`i'_`j')
		
	replace bq11a_`i'_`j' = "1" if bq11a_`i'_`j' == "Reading, writing and literature"
	replace bq11a_`i'_`j' = "2" if bq11a_`i'_`j' == "Mathematics"
	replace bq11a_`i'_`j' = "3" if bq11a_`i'_`j' == "Information and communication technologies (ICT)"
	replace bq11a_`i'_`j' = "4" if bq11a_`i'_`j' == "Religion/ ethics/ moral education"
	replace bq11a_`i'_`j' = "5" if bq11a_`i'_`j' == "Second or other languages"
	replace bq11a_`i'_`j' = "6" if bq11a_`i'_`j' == "Social studies"
	replace bq11a_`i'_`j' = "7" if bq11a_`i'_`j' == "Natural sciences ;"
	replace bq11a_`i'_`j' = "8" if bq11a_`i'_`j' == "Practical and vocational skills"
	replace bq11a_`i'_`j' = "9" if bq11a_`i'_`j' == "Physical education and health ;"
	replace bq11a_`i'_`j' = "10" if bq11a_`i'_`j' == "Technology;"
	replace bq11a_`i'_`j' = "11" if bq11a_`i'_`j' == "Arts;"		
	replace bq11a_`i'_`j' = "12" if bq11a_`i'_`j' == "Others"		
		
	destring bq11a_`i'_`j', replace
   }
}
**** Question 8 - Is there a plan to revise regulation (at the national level) on the duration of instruction time and content of curriculum regulations after school year 2020/2021 (2021 for countries with calendar year) as a result of the COVID19 pandemic? 
foreach var of varlist bq2_all_regulation {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="0" if `var'=="No"
		replace `var'="1" if `var'=="Yes"
		destring `var', replace
}

***** Variables "bq_1_1" and "bq_1_2" are already treated in another part of the code, so the loops to create "999" are no longer needed in this stage.
	foreach i in pp p ls us {
		foreach j in no academicyearextended depends otheradj prioritizationofcerta other{
		destring bq1_1_`i'_`j', replace
		destring bq1_2_`i'_`j', replace
		}
	}
******* Step E - Data cleaning *******


** Value labelling 

	label define bq1_values 0 "No" 1 "Yes" 999 "Missing" 998 "Not applicable" 997 "Do not know"
	label value bq1_1_us* bq1_1_ls* bq1_1_p* bq1_1_pp* bq1_2_us* bq1_2_ls* bq1_2_p* bq1_2_pp* bq1_values
	
	*S2/bq11a/Q1A
** Label variables
label define bq11a_value 		///
	1 "Reading, Writing, and Literature"					///
	2 "Mathematics"					///
	3 "Information and communication technologies (ICT)"		///
	4 "Religion, Ethics, or Moral Education"		///
	5 "Second or other languages"		///
	6 "Social Studies"	///
	7 "Natural Sciences"					///
	8 "Practical and Vocational Skills"					///
	9 "Physical education and health"					///
	10 "Technology" ///
	11 "Arts" ///
	12 "Others" ///
	997 "Do not know"	
	label value bq11a_p_subject1 bq11a_p_subject2 bq11a_p_subject3 bq11a_p_subject4 bq11a_p_subject5 bq11a_ls_subject1 bq11a_ls_subject2 bq11a_ls_subject3 bq11a_ls_subject4 bq11a_ls_subject5 bq11a_us_subject1 bq11a_us_subject2 bq11a_us_subject3 bq11a_us_subject4 bq11a_us_subject5 bq11a_value
	
	label define bq2_all_values 0 "No" 1 "Yes" 999 "Missing" 998 "Not applicable" 997 "Do not know"
	label value bq2_all_regulation bq2_all_values
	
******* Step F - Open section to clean specific interested questions *******

*---------------------------------------------------------------------------
* Section 3. School Reopening Management
*---------------------------------------------------------------------------

******* Step A - Variable renaming/dropping

**** RENAMING
** cq2
renvars cq2_usg_afterschooltime cq2_usg_duringscheduledschoolh cq2_usg_none cq2_usg_onweekends cq2_usg_other / cq2_us_afterschooltime cq2_us_duringscheduledschoolh cq2_us_none cq2_us_onweekends cq2_us_other
renvars cq2_p_duringscheduledschoolho cq2_pp_duringscheduledschoolho / cq2_p_duringscheduledschoolh cq2_pp_duringscheduledschoolh
** cq3
renvars cq3_usg_first cq3_usg_second cq3_usg_third/ cq3_us_first cq3_us_second cq3_us_third
** cq4
renvars cq4_usg_adjustments1 cq4_usg_adjustments2 cq4_usg_classroomattendance cq4_usg_classroomteaching cq4_usg_combining cq4_usg_immediatereturn cq4_usg_nolunch cq4_usg_none cq4_usg_other cq4_usg_progressivereturn cq4_usg_reducingorsuspendingex cq4_usg_studentandteacherretur/ cq4_us_adjustments1 cq4_us_adjustments2 cq4_us_classroomattendance cq4_us_classroomteaching cq4_us_combining cq4_us_immediatereturn cq4_us_nolunch cq4_us_none cq4_us_other cq4_us_progressivereturn cq4_us_reducingorsuspendingex cq4_us_studentandteacherretur
** cq4 - renaming is to fix end of name, not to rename question number, unlike cases above!
renvars cq4_p_reducingorsuspendingext cq4_p_studentandteacherreturn / cq4_p_reducingorsuspendingex cq4_p_studentandteacherretur

**** DROPPING


******* Step B - Structural conversions between OECD and UIS format

*Step B.1. "Select all that apply(SA)" v.s  "Select single(SS)"
*** None in 3)
*Step B.2. Disaggregations
*** None in 3)

******* Step C - Variable labeling *******
*Q1
foreach i in pp p ls us {
	foreach j in assessment remedial1 remedial2 remedial3 remedial4 remedial5 remedial6 remedial7 remedial8 other none donotknow {
				label var cq1_`i'_`j' "`i': `j'"		
	}
}		
*Q2
foreach i in p ls us {
	foreach j in afterschooltime duringscheduledschoolh none onweekends other {
				label var cq2_`i'_`j' "`i': `j'"		
	}
}	
*Q3
foreach i in pp p ls us {
	foreach j in first second third {
				label var cq3_`i'_`j' "`i': `j'"		
	}
}	
*Q4
foreach i in pp p ls us {
	foreach j in adjustments1 adjustments2 classroomattendance classroomteaching combining immediatereturn nolunch none other progressivereturn reducingorsuspendingex studentandteacherretur {
				label var cq4_`i'_`j' "`i': `j'"		
	}
}			
******* Step D - String to numerical (Yes, No, Select all that apply *******

**** Question 1 - What measures to address learning gaps were widely implemented when schools reopened after the first closure in 2020?
foreach var of varlist cq1_ls_assessment cq1_ls_donotknow cq1_ls_none cq1_ls_other cq1_ls_remedial1 cq1_ls_remedial2 cq1_ls_remedial3 cq1_ls_remedial4 cq1_ls_remedial5 cq1_ls_remedial6 cq1_ls_remedial7 cq1_ls_remedial8 cq1_p_assessment cq1_p_donotknow cq1_p_none cq1_p_other cq1_p_remedial1 cq1_p_remedial2 cq1_p_remedial3 cq1_p_remedial4 cq1_p_remedial5 cq1_p_remedial6 cq1_p_remedial7 cq1_p_remedial8 cq1_pp_assessment cq1_pp_donotknow cq1_pp_none cq1_pp_other cq1_pp_remedial1 cq1_pp_remedial2 cq1_pp_remedial3 cq1_pp_remedial4 cq1_pp_remedial5 cq1_pp_remedial6 cq1_pp_remedial7 cq1_pp_remedial8 cq1_us_assessment cq1_us_donotknow cq1_us_none cq1_us_other cq1_us_remedial1 cq1_us_remedial2 cq1_us_remedial3 cq1_us_remedial4 cq1_us_remedial5 cq1_us_remedial6 cq1_us_remedial7 cq1_us_remedial8 {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="999" if `var'=="Missing"	
		replace `var'="1" if `var'=="Yes"	
		replace `var'="0" if `var'=="No"	
		destring `var', replace
}

**** Question 2 - if introducing remedial measures (for example remedial, accelerated programmes or increased in-person class time) to address learning gaps after schools reopened in 2020, when were those typically scheduled?
/// PATCHED 18 May 2021: the variable "cq_p_none" now exists and "cq_p_donotknow" no longer exists.
foreach var of varlist cq2_ls_afterschooltime cq2_ls_duringscheduledschoolh cq2_ls_none cq2_ls_onweekends cq2_ls_other cq2_p_afterschooltime cq2_p_none cq2_p_duringscheduledschoolh cq2_p_onweekends cq2_p_other cq2_pp_afterschooltime cq2_pp_duringscheduledschoolh cq2_pp_none cq2_pp_onweekends cq2_pp_other cq2_us_afterschooltime cq2_us_duringscheduledschoolh cq2_us_none cq2_us_onweekends cq2_us_other {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"
		replace `var'="1" if `var'=="Yes"	
		replace `var'="0" if `var'=="No"
		destring `var', replace
}

**** Question 3 - What is the approximate share of students who attended school in person after the reopening of schools in 2020? 
foreach i in pp p ls us {
	foreach j in first second third {
		replace cq3_`i'_`j' = "0" if cq3_`i'_`j' == "Do not know/Not monitored"
		replace cq3_`i'_`j' = "1" if cq3_`i'_`j' == "Less than 25% "
		replace cq3_`i'_`j' = "2" if cq3_`i'_`j' == "More than 25% but less than 50%"
		replace cq3_`i'_`j' = "3" if cq3_`i'_`j' == "About half of the students"
		replace cq3_`i'_`j' = "4" if cq3_`i'_`j' == "More than 50% but less than 75%"
		replace cq3_`i'_`j' = "5" if cq3_`i'_`j' == "More than 75% but not all of the students"
		replace cq3_`i'_`j' = "6" if cq3_`i'_`j' == "All of the students"
		/// Question - what to allocate to decide at own discretion below?
		replace cq3_`i'_`j' = "999" if cq3_`i'_`j' == "Schools/Districts/the most local level of governance could decide at their own discretion"
		replace cq3_`i'_`j' = "997" if cq3_`i'_`j' == "Do not know (m)"
		replace cq3_`i'_`j' = "998" if cq3_`i'_`j' == "Not applicable (a)"
		replace cq3_`i'_`j' = "999" if cq3_`i'_`j' == "Include in another column (xc)"
		replace cq3_`i'_`j' = "999" if cq3_`i'_`j' == "Missing"
		destring cq3_`i'_`j', replace
	}
}

**** Question 4 - What strategies for school re-opening (after the first closure) were implemented in your country in 2020?. 
foreach var of varlist cq4_ls_adjustments1 cq4_ls_adjustments2 cq4_ls_classroomattendance cq4_ls_classroomteaching cq4_ls_combining cq4_ls_immediatereturn cq4_ls_nolunch cq4_ls_none cq4_ls_other cq4_ls_progressivereturn cq4_ls_reducingorsuspendingex cq4_ls_studentandteacherretur cq4_p_adjustments1 cq4_p_adjustments2 cq4_p_classroomattendance cq4_p_classroomteaching cq4_p_combining cq4_p_immediatereturn cq4_p_nolunch cq4_p_none cq4_p_other cq4_p_progressivereturn cq4_p_reducingorsuspendingex cq4_p_studentandteacherretur cq4_pp_adjustments1 cq4_pp_adjustments2 cq4_pp_classroomattendance cq4_pp_classroomteaching cq4_pp_combining cq4_pp_immediatereturn cq4_pp_nolunch cq4_pp_none cq4_pp_other cq4_pp_progressivereturn cq4_pp_reducingorsuspendingex cq4_pp_studentandteacherretur cq4_us_adjustments1 cq4_us_adjustments2 cq4_us_classroomattendance cq4_us_classroomteaching cq4_us_combining cq4_us_immediatereturn cq4_us_nolunch cq4_us_none cq4_us_other cq4_us_progressivereturn cq4_us_reducingorsuspendingex cq4_us_studentandteacherretur {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="999" if `var'=="Schools/Districts/the most local level of governance could decide at their own discretion"
		/// RUS OECD questionnaire issue, replace with do not know
		replace `var'="997" if `var'=="More than 75% but not all of the students"
		replace `var'="1" if `var'=="Yes"	
		replace `var'="0" if `var'=="No"	
		destring `var', replace
}
** Rest of Module 3) is not included in UIS, and therefore not appendable.

******* Step E - Data cleaning *******


label define cq1_value 0 "No" 1 "Yes" 997 "Do not know" 998 "Not applicable" 999 "Missing" 
	
label value cq1_ls_assessment cq1_ls_donotknow cq1_ls_none cq1_ls_other cq1_ls_remedial1 cq1_ls_remedial2 cq1_ls_remedial3 cq1_ls_remedial4 cq1_ls_remedial5 cq1_ls_remedial6 cq1_ls_remedial7 cq1_ls_remedial8 cq1_p_assessment cq1_p_donotknow cq1_p_none cq1_p_other cq1_p_remedial1 cq1_p_remedial2 cq1_p_remedial3 cq1_p_remedial4 cq1_p_remedial5 cq1_p_remedial6 cq1_p_remedial7 cq1_p_remedial8 cq1_pp_assessment cq1_pp_donotknow cq1_pp_none cq1_pp_other cq1_pp_remedial1 cq1_pp_remedial2 cq1_pp_remedial3 cq1_pp_remedial4 cq1_pp_remedial5 cq1_pp_remedial6 cq1_pp_remedial7 cq1_pp_remedial8 cq1_us_assessment cq1_us_donotknow cq1_us_none cq1_us_other cq1_us_remedial1 cq1_us_remedial2 cq1_us_remedial3 cq1_us_remedial4 cq1_us_remedial5 cq1_us_remedial6 cq1_us_remedial7 cq1_us_remedial8 cq1_value

label define cq2_value 0 "No" 1 "Yes" 997 "Do not know"  998 "Not applicable"  999 "Missing" 
	
label value cq2_ls_afterschooltime cq2_ls_duringscheduledschoolh cq2_ls_none cq2_ls_onweekends cq2_ls_other cq2_p_afterschooltime cq2_p_none cq2_p_duringscheduledschoolh cq2_p_onweekends cq2_p_other cq2_pp_afterschooltime cq2_pp_duringscheduledschoolh cq2_pp_none cq2_pp_onweekends cq2_pp_other cq2_us_afterschooltime cq2_us_duringscheduledschoolh cq2_us_none cq2_us_onweekends cq2_us_other cq2_value

label define cq3_value 						///
	0 "Do not know/Not monitored"			///
	1 "Less than 25 "						///
	2 "More than 25% but less than 50%"		///
	3 "About half of the students"			///
	4 "More than 50% but less than 75%"		///
	5 "More than 75% but not all of the students"	 ///
	6 "All of the students" 		 ///
	997 "Do not know" 	 ///
	998 "Not applicable" 	 ///
	999 "Missing" 
label value cq3_pp* cq3_p* cq3_ls* cq3_us* cq3_value

label define cq4_value 0 "No" 1 "Yes" 997 "Do not know" 998 "Not applicable" 999 "Missing" 
	
label value cq4_ls_adjustments1 cq4_ls_adjustments2 cq4_ls_classroomattendance cq4_ls_classroomteaching cq4_ls_combining cq4_ls_immediatereturn cq4_ls_nolunch cq4_ls_none cq4_ls_other cq4_ls_progressivereturn cq4_ls_reducingorsuspendingex cq4_ls_studentandteacherretur cq4_p_adjustments1 cq4_p_adjustments2 cq4_p_classroomattendance cq4_p_classroomteaching cq4_p_combining cq4_p_immediatereturn cq4_p_nolunch cq4_p_none cq4_p_other cq4_p_progressivereturn cq4_p_reducingorsuspendingex cq4_p_studentandteacherretur cq4_pp_adjustments1 cq4_pp_adjustments2 cq4_pp_classroomattendance cq4_pp_classroomteaching cq4_pp_combining cq4_pp_immediatereturn cq4_pp_nolunch cq4_pp_none cq4_pp_other cq4_pp_progressivereturn cq4_pp_reducingorsuspendingex cq4_pp_studentandteacherretur cq4_us_adjustments1 cq4_us_adjustments2 cq4_us_classroomattendance cq4_us_classroomteaching cq4_us_combining cq4_us_immediatereturn cq4_us_nolunch cq4_us_none cq4_us_other cq4_us_progressivereturn cq4_us_reducingorsuspendingex cq4_us_studentandteacherretur cq4_value


******* Step F - Open section to clean specific interested questions *******

*---------------------------------------------------------------------------
* Section 4. and 10. Distance Education Delivery Systems 
*---------------------------------------------------------------------------

******* Step A - Variable renaming/dropping

**** RENAMING
** dq1
renvars dq1_usg_mobilephones dq1_usg_none dq1_usg_onlineplatforms dq1_usg_otherdistancelearningm dq1_usg_radio dq1_usg_takehomepackages dq1_usg_television / dq1_us_mobilephones dq1_us_none dq1_us_onlineplatforms dq1_us_otherdistancelearningm dq1_us_radio dq1_us_takehomepackages dq1_us_television
** dq2
renvars dq2_usg_percent/ dq2_us_percent
** dq4
renvars dq4_usg_all / dq4_us_all
**** DROPPING
** dq2 
drop dq2_pp_percentfirst dq2_pp_percentsecond dq2_pp_percentthird dq2_p_percentfirst dq2_p_percentsecond dq2_p_percentthird dq2_ls_percentfirst dq2_ls_percentsecond dq2_ls_percentthird dq2_usg_percentfirst dq2_usg_percentsecond dq2_usg_percentthird 
** dq4 
drop dq4_pp_first dq4_pp_second dq4_pp_third dq4_p_first dq4_p_second dq4_p_third dq4_ls_first dq4_ls_second dq4_ls_third dq4_usg_first dq4_usg_second dq4_usg_third

**** Note to UIS: We should have more conventional variable names renamed when there are inconsistencies for specific education levels
renvars dq1_p_otherdistancelearningmo / dq1_p_otherdistancelearningm

******* Step B - Structural conversions between OECD and UIS format
*Step B.1. "Select all that apply(SA)" v.s  "Select single(SS)"

*Step B.2. Disaggregations
** dq3: dq3_pp_mobilephones dq3_p_mobilephones dq3_ls_mobilephones dq3_usg_mobilephones -> dq3_all_mobilephones; and for other DL modalities , using USG because it is the intended category for all countries, as discussed in OECD team.

gen dq3_all_onlineplatforms=""
replace dq3_all_onlineplatforms=dq3_usg_onlineplatforms
replace dq3_all_onlineplatforms="997" if dq3_usg_onlineplatforms=="Do not know (m)" 
replace dq3_all_onlineplatforms="999" if dq3_usg_onlineplatforms=="Include in another column (xc)" 
replace dq3_all_onlineplatforms="998" if dq3_usg_onlineplatforms=="Not applicable (a)"

gen dq3_all_television=""
replace dq3_all_television=dq3_usg_television
replace dq3_all_television="997" if dq3_usg_television=="Do not know (m)" 
replace dq3_all_television="999" if dq3_usg_television=="Include in another column (xc)"
replace dq3_all_television="998" if dq3_usg_television=="Not applicable (a)"

gen dq3_all_mobilephones=""
replace dq3_all_mobilephones=dq3_usg_mobilephones
replace dq3_all_mobilephones="997" if dq3_usg_mobilephones=="Do not know (m)" 
replace dq3_all_mobilephones="999" if dq3_usg_mobilephones=="Include in another column (xc)"
replace dq3_all_mobilephones="998" if dq3_usg_mobilephones=="Not applicable (a)"

gen dq3_all_radio=""
replace dq3_all_radio=dq3_usg_radio
replace dq3_all_radio="997" if dq3_usg_radio=="Do not know (m)" 
replace dq3_all_radio="999" if dq3_usg_radio=="Include in another column (xc)"
replace dq3_all_radio="998" if dq3_usg_radio=="Not applicable (a)"

gen dq3_all_takehomepackages=""
replace dq3_all_takehomepackages=dq3_usg_takehomepackages
replace dq3_all_takehomepackages="997" if dq3_usg_takehomepackages=="Do not know (m)"
replace dq3_all_takehomepackages="999" if dq3_usg_takehomepackages=="Include in another column (xc)" 
replace dq3_all_takehomepackages="998" if dq3_usg_takehomepackages=="Not applicable (a)"

gen dq3_all_otherdistancelearning=""
replace dq3_all_otherdistancelearning=dq3_usg_otherdistancelearning
replace dq3_all_otherdistancelearning="997" if dq3_usg_otherdistancelearning=="Do not know (m)"
replace dq3_all_otherdistancelearning="999" if dq3_usg_otherdistancelearning=="Include in another column (xc)"
replace dq3_all_otherdistancelearning="998" if dq3_usg_otherdistancelearning=="Not applicable (a)"

**** OECD data also has "NONE" as an option, but UIS does not. Now drop data:
drop dq3_pp* dq3_p* dq3_ls* dq3_usg*

******* Step C - Variable labeling *******

*Q1
foreach i in pp p ls us {
	foreach j in onlineplatforms television mobilephones radio takehomepackages otherdistancelearningm  none {
				label var dq1_`i'_`j' "`i': `j'"	
	}
}
*Q2
foreach i in pp p ls us {
	foreach j in percent {
				label var dq2_`i'_`j' "`i': `j'"	
	}
}
*Q3
foreach i in all {
	foreach j in onlineplatforms television mobilephones radio takehomepackages otherdistancelearning {
				label var dq3_`i'_`j' "`i': `j'"	
	}
}
*Q3a
foreach i in all {
	foreach j in householdsurvey teacherassessment studentassessment other {
				label var dq3a_`i'_`j' "`i': `j'"	
	}
}
*Q4
foreach i in pp p ls us {
	foreach j in all {
				label var dq4_`i'_`j' "`i': `j'"	
	}
}
******* Step D - String to numerical (Yes, No, Select all that apply *******

**** Question 5 - Which distance learning solutions were or are being offered in your country during the pandemic in 2020 and/or 2021 ?
foreach var of varlist dq1_ls_mobilephones dq1_ls_none dq1_ls_onlineplatforms dq1_ls_otherdistancelearningm dq1_ls_radio dq1_ls_takehomepackages dq1_ls_television dq1_p_mobilephones dq1_p_none dq1_p_onlineplatforms dq1_p_otherdistancelearningm dq1_p_radio dq1_p_takehomepackages dq1_p_television dq1_pp_mobilephones dq1_pp_none dq1_pp_onlineplatforms dq1_pp_otherdistancelearningm dq1_pp_radio dq1_pp_takehomepackages dq1_pp_television dq1_us_mobilephones dq1_us_none dq1_us_onlineplatforms dq1_us_otherdistancelearningm dq1_us_radio dq1_us_takehomepackages dq1_us_television {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="1" if `var'=="Yes"
		replace `var'="0" if `var'=="No"	
		destring `var', replace
}

**** Question 6a - What percentage of students (at each level of education), approximately, followed distance education during school closures in 2020 ?
foreach var of varlist dq2_ls_percent dq2_p_percent dq2_pp_percent dq2_us_percent {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"
		replace `var' = "1" if `var' == "Less than 25%;"
		replace `var' = "1" if `var' == "less than 25%;"
		replace `var' = "2" if `var' == "More than 25% but less than 50%"
		replace `var' = "3" if `var' == "About half of the students"
		replace `var' = "4" if `var' == "More than 50% but less than 75%"
		replace `var' = "5" if `var' == "More than 75% but not all of the students"
		replace `var' = "6" if `var' == "All of the students" 
		/// Russia latest questionnaire errors - replace data with "Do not know"
		replace `var'="997" if Country=="RUS"
		destring `var', replace
}

**** Question 7a - Has any study or assessment been carried out (at the regional or national level) in 2020 to assess the effectiveness of distance-learning strategies?
******** NOTE: This already uses the UIS variable names after merging individual OECD education levels into a "general" answer compatible with UIS variables.
foreach var of varlist dq3_all_mobilephones dq3_all_onlineplatforms dq3_all_otherdistancelearning dq3_all_radio dq3_all_takehomepackages dq3_all_television {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="1" if `var'=="Yes"
		replace `var'="0" if `var'=="No"	
		/// Russia latest questionnaire errors - replace data with "Do not know"
		replace `var'="997" if Country=="RUS"
		destring `var', replace
}

**** Question 7b - If answered ‘yes’ to any options, please select the methods of assessment:
foreach var of varlist dq3a_all_householdsurvey dq3a_all_other dq3a_all_studentassessment dq3a_all_teacherassessment {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="1" if `var'=="Yes"
		replace `var'="0" if `var'=="No"
		/// Russia latest questionnaire errors - replace data with "Do not know"
		replace `var'="997" if Country=="RUS"
		destring `var', replace
}

**** Question 8 - Is distance learning considered a valid form of delivery to account for official instruction days in 2020?   
foreach var of varlist dq4_ls_all dq4_p_all dq4_pp_all dq4_us_all {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var' = "1" if `var' == "Not at all "
		replace `var' = "2" if `var' == "Very little"
		replace `var' = "3" if `var' == "To some extent"
		replace `var' = "4" if `var' == "To a great extent"
		destring `var', replace
}

**** Question 9 - Which of the following measures have been taken to ensure the inclusion of populations at risk of being excluded from distance education platforms during the first closure of schools in 2020 ?
************** Question not present in dataset. Skip.


******* Step E - Data cleaning *******
*** Value labels
* Q1
	label define dq1_values 0 "No" 1 "Yes" 997 "Do Not Know" 998 "Not Applicable" 999 "Missing"
	label value dq1_ls_mobilephones dq1_ls_none dq1_ls_onlineplatforms dq1_ls_otherdistancelearningm dq1_ls_radio dq1_ls_takehomepackages dq1_ls_television dq1_p_mobilephones dq1_p_none dq1_p_onlineplatforms dq1_p_otherdistancelearningm dq1_p_radio dq1_p_takehomepackages dq1_p_television dq1_pp_mobilephones dq1_pp_none dq1_pp_onlineplatforms dq1_pp_otherdistancelearningm dq1_pp_radio dq1_pp_takehomepackages dq1_pp_television dq1_us_mobilephones dq1_us_none dq1_us_onlineplatforms dq1_us_otherdistancelearningm dq1_us_radio dq1_us_takehomepackages dq1_us_television dq1_values
* Q2
	label define dq2_values 1 "Less than 25%" 2 "More than 25% but less than 50%" 3 "About half of the students" 4 "More than 50% but less than 75%" 5 "More than 75% but not all of the students" 6 "All of the students" 997 "Do Not Know" 998 "Not Applicable" 999 "Missing"
	label value dq2_ls_percent dq2_p_percent dq2_pp_percent dq2_us_percent dq2_values
* Q3
	label define dq3_values 0 "No" 1 "Yes" 997 "Do Not Know" 998 "Not Applicable" 999 "Missing"
	label value dq3_all_mobilephones dq3_all_onlineplatforms dq3_all_otherdistancelearning dq3_all_radio dq3_all_takehomepackages dq3_all_television dq3_values
* Q3a
	label define dq3a_values 0 "No" 1 "Yes" 997 "Do Not Know" 998 "Not Applicable" 999 "Missing"
	label value dq3a_all_householdsurvey dq3a_all_other dq3a_all_studentassessment dq3a_all_teacherassessment dq3a_values
*Q4 - STILL STRINGS; CAN'T LABEL YET
label define dq4_value  ///
	1 "Not at all"			///
	2 "Very little"		///
	3 "To some extent"			///
	4 "To a great extent"	///
  997 "Do not know"			///
  998 "Not applicable" ///
 	999 "Missing" 
label value dq4_pp_all dq4_p_all dq4_ls_all dq4_us_all dq4_value
  
	
******* Step F - Open section to clean specific interested questions *******

*---------------------------------------------------------------------------
* Section 5. Teachers and Educational Personnel
*---------------------------------------------------------------------------

******* Step A - Variable renaming/dropping

**** RENAMING
** eq1b
rename eq1b_usg_levels eq1b_us_levels
** eq2
rename eq2_usg_pay eq2_us_pay
** eq3
renvars eq3_usg_2020 eq3_usg_2021 / eq3_us_2020 eq3_us_2021
** eq5 - transforming to "eq4" to match UIS
renvars eq5_all_subnatteachingcontent eq5_all_subnatprofessionaldev eq5_all_subnatppe eq5_all_subnatother eq5_all_subnatofferedspecial eq5_all_subnatnoadditionalsup eq5_all_subnatinstruction eq5_all_subnaticttools eq5_all_subnatguidelines eq5_all_schoolteachingcontent eq5_all_schoolprofessionaldev eq5_all_schoolppe eq5_all_schoolother eq5_all_schoolofferedspecial eq5_all_schoolnoadditionalsup eq5_all_schoolinstruction eq5_all_schoolicttools eq5_all_schoolguidelines eq5_all_natteachingcontent eq5_all_natprofessionaldev eq5_all_natppe eq5_all_natother eq5_all_natofferedspecial eq5_all_natnoadditionalsup eq5_all_natinstruction eq5_all_naticttools eq5_all_natguidelines / eq4_all_subnatteachingcontent eq4_all_subnatprofessionaldev eq4_all_subnatppe eq4_all_subnatother eq4_all_subnatofferedspecial eq4_all_subnatnoadditionalsup eq4_all_subnatinstruction eq4_all_subnaticttools eq4_all_subnatguidelines eq4_all_schoolteachingcontent eq4_all_schoolprofessionaldev eq4_all_schoolppe eq4_all_schoolother eq4_all_schoolofferedspecial eq4_all_schoolnoadditionalsup eq4_all_schoolinstruction eq4_all_schoolicttools eq4_all_schoolguidelines eq4_all_natteachingcontent eq4_all_natprofessionaldev eq4_all_natppe eq4_all_natother eq4_all_natofferedspecial eq4_all_natnoadditionalsup eq4_all_natinstruction eq4_all_naticttools eq4_all_natguidelines
** eq7 - transforming to "eq5" to match UIS
renvars eq7_all_specify / eq5_all_specify
** eq8a  - transforming to "eq6" to match UIS
renvars eq8a_all_vaccine eq8a_all_specify / eq6_all_vaccine eq6_all_specify
** eq8b  - transforming to "eq6a" to match UIS
renvars eq8b_all_yesotherpleasespecify eq8b_all_yesbysubnationallevel eq8b_all_yesbylevelofeducation eq8b_all_yesbyagegroup eq8b_all_specify eq8b_all_no / eq6a_all_yesotherpleasespecify eq6a_all_yesbysubnationallevel eq6a_all_yesbylevelofeducation eq6a_all_yesbyagegroup eq6a_all_specify eq6a_all_no
**** DROPPING
** eq6(eq4)
drop eq6a_usv_distance  eq6b_usv_support

******* Step B - Structural conversions between OECD and UIS format
*Step B.1. "Select all that apply(SA)" v.s  "Select single(SS)"
** eq8c (eq6b)
	* eq8c_all_vaccination -> eq6b_all_2021q1 eq6b_all_2021q2 eq6b_all_2021q3 eq6b_all_2021q4 eq6b_all_2022 eq6b_all_stillnotdefined eq6b_all_donotknow */
gen eq6b_all_2021q1="0"
gen eq6b_all_2021q2="0" 
gen eq6b_all_2021q3="0" 
gen eq6b_all_2021q4="0" 
gen eq6b_all_2022="0"
gen eq6b_all_stillnotdefined="0" 
gen eq6b_all_donotknow="0"

replace eq6b_all_2021q1="1" if eq8c_all_vaccination=="2021 Q1"
replace eq6b_all_2021q2="1" if eq8c_all_vaccination=="2021 Q2"
replace eq6b_all_2021q3="1" if eq8c_all_vaccination=="2021 Q3"
replace eq6b_all_2021q4="1" if eq8c_all_vaccination=="2021 Q4"
replace eq6b_all_2022="1" if eq8c_all_vaccination=="2022"
replace eq6b_all_stillnotdefined="1" if eq8c_all_vaccination=="Still not defined"
replace eq6b_all_donotknow="1" if eq8c_all_vaccination=="Do not know (m)"

replace eq6b_all_2021q1="998" if eq8c_all_vaccination=="Not applicable (a)"
replace eq6b_all_2021q2="998" if eq8c_all_vaccination=="Not applicable (a)"
replace eq6b_all_2021q3="998" if eq8c_all_vaccination=="Not applicable (a)"
replace eq6b_all_2021q4="998" if eq8c_all_vaccination=="Not applicable (a)"
replace eq6b_all_2022="998" if eq8c_all_vaccination=="Not applicable (a)"
replace eq6b_all_stillnotdefined="998" if eq8c_all_vaccination=="Not applicable (a)"
replace eq6b_all_donotknow="998" if eq8c_all_vaccination=="Not applicable (a)"

******* Drop all OECD-only variables once mapping is done
drop eq8c_all_vaccination

*Step B.2. Disaggregations
** eq1: eq1_pp_percentage eq1_p_percentage eq1_ls_percentage eq1_usg_percentage -> eq1_all_percentage - Use Lower Secondary for all except Sweden (primary)
gen eq1_all_percentage=""
replace eq1_all_percentage=eq1_ls_percentage
replace eq1_all_percentage=eq1_p_percentage if Country=="SWE"

drop eq1_pp* eq1_p* eq1_ls* eq1_us*
** eq1a: eq1a_pp_premises eq1a_p_premises eq1a_ls_premises eq1a_usg_premises -> eq1a_all_premises  - Use Lower Secondary for all except Sweden (primary)
gen eq1a_all_premises=""
replace eq1a_all_premises=eq1a_ls_premises
replace eq1a_all_premises=eq1a_p_premises if Country=="SWE"
replace eq1a_all_premises="998" if eq1a_ls_premises=="Not applicable (a)"
replace eq1a_all_premises="997" if eq1a_ls_premises=="Do not know (m)" 

**** Now drop data:
drop eq1a_pp* eq1a_p* eq1a_ls* eq1a_us*

** eq6a(eq4a): eq6a_ls_distance eq6a_p_distance eq6a_pp_distance eq6a_usg_distance -> eq4a_all_distance
gen eq4a_all_distance=""
replace eq4a_all_distance=eq6a_ls_distance
replace eq4a_all_distance="998" if eq6a_ls_distance=="Not applicable (a)"
replace eq4a_all_distance="997" if eq6a_ls_distance=="Unknown/not monitored" 
replace eq4a_all_distance = "1" if eq4a_all_distance == "Less than 25% "
replace eq4a_all_distance = "2" if eq4a_all_distance == "More than 25% but less than 50%"
replace eq4a_all_distance = "3" if eq4a_all_distance == "About half of the teachers"
replace eq4a_all_distance = "4" if eq4a_all_distance == "More than 50% but less than 75%"
replace eq4a_all_distance = "5" if eq4a_all_distance == "More than 75% but not all of the teachers"
replace eq4a_all_distance = "6" if eq4a_all_distance== "All of the teachers"
destring eq4a_all_distance, replace
		
**** Now drop data: 
drop eq6a_pp* eq6a_p* eq6a_ls* eq6a_us* 

** eq6b(eq4b): eq6b_pp_support eq6b_p_support eq6b_ls_support eq6b_usg_support -> eq4b_all_support
gen eq4b_all_support=""
replace eq4b_all_support=eq6b_ls_support
replace eq4b_all_support="998" if eq6b_ls_support=="Not applicable (a)"
replace eq4b_all_support="997" if eq6b_ls_support=="Unknown/not monitored"
replace eq4b_all_support = "1" if eq4b_all_support == "Less than 25% "
replace eq4b_all_support = "2" if eq4b_all_support == "More than 25% but less than 50%"
replace eq4b_all_support = "3" if eq4b_all_support == "About half of the teachers"
replace eq4b_all_support = "4" if eq4b_all_support == "More than 50% but less than 75%"
replace eq4b_all_support = "5" if eq4b_all_support == "More than 75% but not all of the teachers"
replace eq4b_all_support = "6" if eq4b_all_support == "All of the teachers"
destring eq4b_all_support, replace

**** Now drop data: 
drop eq6b_pp* eq6b_p* eq6b_ls* eq6b_us* 

** eq7 -> eq5_all 
gen eq5_all_phonecalls=""
gen eq5_all_emails=""
gen eq5_all_textwhatsapp=""
gen eq5_all_videoconference=""
gen eq5_all_homevisits=""
gen eq5_all_communicationoneschool=""
gen eq5_all_useofonlineparentalsurve=""
gen eq5_all_holdingregularconversat=""
gen eq5_all_involvingparents=""
gen eq5_all_other=""
gen eq5_all_nospecificguidelines=""

** Checked that lower secondary matches all wanted answers
replace eq5_all_phonecalls=eq7_ls_phonecalls
replace eq5_all_emails=eq7_ls_emails
replace eq5_all_holdingregularconversat=eq7_ls_holdingregularconversat
replace eq5_all_homevisits=eq7_ls_homevisits
replace eq5_all_involvingparents=eq7_ls_involvingparents
replace eq5_all_other=eq7_ls_other
replace eq5_all_communicationoneschool=eq7_ls_communicationoneschool
replace eq5_all_textwhatsapp=eq7_ls_textwhatsapp
replace eq5_all_nospecificguidelines=eq7_ls_nospecificguidelines
replace eq5_all_videoconference=eq7_ls_videoconference
** Exception: using primary instead of lower secondary, as that level matches all "most common" answers accross education levels
replace eq5_all_useofonlineparentalsurve=eq7_p_useofonlineparentsurv

** Drop variables
drop eq7*

******* Step C - Variable labeling *******


*Q1
	foreach i in all {
		foreach j in percentage {
				label var eq1_`i'_`j' "`i': `j'"			
		}
	}
*Q1a
	foreach i in all {
		foreach j in premises {
				label var eq1a_`i'_`j' "`i': `j'"			
		}
	}
*Q1b
	foreach i in pp p ls us {
		foreach j in levels {
				label var eq1b_`i'_`j' "`i': `j'"			
		}
	}
*Q2
	foreach i in pp p ls us {
		foreach j in pay {
				label var eq2_`i'_`j' "`i': `j'"			
		}
	}
*Q3
	foreach i in pp p ls us {
		foreach j in 2020 2021 {
				label var eq3_`i'_`j' "`i': `j'"			
		}
	}
* Q4
	foreach i in all {
		foreach j in natguidelines naticttools natinstruction natnoadditionalsup natofferedspecial natother natppe natprofessionaldev natteachingcontent schoolguidelines schoolicttools schoolinstruction schoolnoadditionalsup schoolofferedspecial schoolother schoolppe schoolprofessionaldev schoolteachingcontent subnatguidelines subnaticttools subnatinstruction subnatnoadditionalsup subnatofferedspecial subnatother subnatppe subnatprofessionaldev subnatteachingcontent {
				label var eq4_`i'_`j' "`i': `j'"			
		}
	}
* Q5
	foreach i in all {
		foreach j in communicationoneschool emails holdingregularconversat homevisits involvingparents nospecificguidelines other phonecalls textwhatsapp useofonlineparentalsurve videoconference {
				label var eq5_`i'_`j' "`i': `j'"			
		}
	}
* Q6
	foreach i in all {
		foreach j in vaccine {
				label var eq6_`i'_`j' "`i': `j'"			
		}
	}
* Q6a
	foreach i in all {
		foreach j in no yesbyagegroup yesbylevelofeducation yesbysubnationallevel yesotherpleasespecify {
				label var eq6a_`i'_`j' "`i': `j'"			
		}
	}
* Q6b
	foreach i in all {
		foreach j in 2021q1 2021q2 2021q3 2021q4 2022 donotknow stillnotdefined {
				label var eq6b_`i'_`j' "`i': `j'"			
		}
	}
******* Step D - String to numerical (Yes, No, Select all that apply *******
**** Question 1 - What percentage of teachers, approximately, were required to teach (remotely/online) during all school closures in 2020?
******** This question is already cleaned in another part of the code, due to UIS-OECD structural differences.
foreach var of varlist eq1_all_percentage {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="1" if `var'=="All of the teachers"
		replace `var'="2" if `var'=="More than 75% but not all of the teachers"
		destring `var', replace
}
**** Question 1a - If answered “All of the teachers” to Q1, were they able to teach from the school premises? 
foreach var of varlist eq1a_all_premises {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="0" if `var'=="No"
		replace `var'="1" if `var'=="Yes"
		destring `var', replace
}
**** Question 1b - If answered an option that implies a percentage of teachers different from a 100  to question 1, please specify if  they were able to teach from school premises
foreach var of varlist eq1b_ls_levels eq1b_p_levels eq1b_pp_levels eq1b_us_levels {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="0" if `var'=="No"
		replace `var'="1" if `var'=="Yes"
		destring `var', replace
}

**** Question 2 - Have there been changes to teacher pay and benefits due to the period(s) of school closures in 2020? 
foreach var of varlist eq2_ls_pay eq2_p_pay eq2_pp_pay eq2_us_pay {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="2" if `var'=="Yes, an increase of teacher pay or/and benefits"
		replace `var'="3" if `var'=="No change"
		replace `var'="4" if `var'=="Schools/Districts/the most local level of governance could decide at their own discretion"
		destring `var', replace
}

**** Question 3 - Were or are new teachers being recruited for school re-opening during the school year 2019/2020 (2020 for countries with calendar year) and the School year 2020/2021 (2021 for countries with calendar year) in response to the COVID crisis ?
foreach var of varlist eq3_ls_2020 eq3_ls_2021 eq3_p_2020 eq3_p_2021 eq3_pp_2020 eq3_pp_2021 eq3_us_2020 eq3_us_2021 {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="0" if `var'=="No"
		replace `var'="1" if `var'=="Yes, new teachers"
		replace `var'="2" if `var'=="Schools/Districts/the most local level of governance could decide at their own discretion"
		destring `var', replace
}

**** Question 5 - How and at what scale were teachers (in pre-primary to upper secondary levels combined) supported in the transition to remote learning in 2020?
*************** Note: somewhere else in the code this was renamed to "eq4" to match UIS variable names and make appending easier.
foreach var of varlist eq4_all_natguidelines eq4_all_naticttools eq4_all_natinstruction eq4_all_natnoadditionalsup eq4_all_natofferedspecial eq4_all_natother eq4_all_natppe eq4_all_natprofessionaldev eq4_all_natteachingcontent eq4_all_schoolguidelines eq4_all_schoolicttools eq4_all_schoolinstruction eq4_all_schoolnoadditionalsup eq4_all_schoolofferedspecial eq4_all_schoolother eq4_all_schoolppe eq4_all_schoolprofessionaldev eq4_all_schoolteachingcontent eq4_all_subnatguidelines eq4_all_subnaticttools eq4_all_subnatinstruction eq4_all_subnatnoadditionalsup eq4_all_subnatofferedspecial eq4_all_subnatother eq4_all_subnatppe eq4_all_subnatprofessionaldev eq4_all_subnatteachingcontent {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="0" if `var'=="No"
		replace `var'="1" if `var'=="Yes"
		destring `var', replace
}

**** Question 7 - What kind of interactions (other than interactions in online lessons) were encouraged by government between teachers and their students and/or their parents during school closures in 2020?
**************** Note: somewhere else in the code this was renamed to "eq5" to match UIS variable names and make appending easier.
foreach var of varlist eq5_all_communicationoneschool eq5_all_emails eq5_all_holdingregularconversat eq5_all_homevisits eq5_all_involvingparents eq5_all_nospecificguidelines eq5_all_other eq5_all_phonecalls eq5_all_textwhatsapp eq5_all_useofonlineparentalsurve eq5_all_videoconference {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="0" if `var'=="No"
		replace `var'="1" if `var'=="Yes"
		replace `var'="2" if `var'=="Schools/Districts/the most local level of governance could decide at their own discretion"
		destring `var', replace
}

**** Question 8a - Do you have plans to prioritize vaccinations for teachers (in pre-primary to upper secondary levels combined)?  
**************** Note: somewhere else in the code this was renamed to "eq6" to match UIS variable names and make appending easier.
foreach var of varlist eq6_all_vaccine {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="1" if `var'=="No, teachers are considered as general population;"			
		replace `var'="2" if `var'=="Yes, as a national measure prioritizing teachers;"	
		destring `var', replace
}

**** Question 8b - Among teachers, do you have criteria for prioritization? 
**************** Note: somewhere else in the code this was renamed to "eq6a" to match UIS variable names and make appending easier.
foreach var of varlist eq6a_all_no eq6a_all_yesbyagegroup eq6a_all_yesbylevelofeducation eq6a_all_yesbysubnationallevel eq6a_all_yesotherpleasespecify {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="0" if `var'=="No"
		replace `var'="1" if `var'=="Yes"
		destring `var', replace
}


**** Question 8c - When is planned to start the vaccination of teachers?
**************** Note: somewhere else in the code this was renamed to "eq6b" to match UIS variable names and make appending easier.
foreach var of varlist eq6b_all_2021q1 eq6b_all_2021q2 eq6b_all_2021q3 eq6b_all_2021q4 eq6b_all_2022 eq6b_all_donotknow eq6b_all_stillnotdefined {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		destring `var', replace
}

******* Step E - Data cleaning *******

// Given that the choices include "No measure", country that answered no to all choices are considered as missing for this variable
foreach j in nat subnat school {
gen Check=0
replace Check=1 if eq4_all_`j'offeredspecial==0 & eq4_all_`j'instruction==0 & eq4_all_`j'ppe==0 & eq4_all_`j'guidelines==0 & ///
eq4_all_`j'professionaldev==0 & eq4_all_`j'teachingcontent==0 & eq4_all_`j'icttools==0 & eq4_all_`j'noadditionalsup==0 & eq4_all_`j'other==0

foreach i in eq4_all_`j'offeredspecial eq4_all_`j'instruction eq4_all_`j'ppe eq4_all_`j'guidelines eq4_all_`j'professionaldev eq4_all_`j'teachingcontent eq4_all_`j'icttools eq4_all_`j'noadditionalsup eq4_all_`j'other { 
	replace `i'=998 if Check==1
}
drop Check
}

// When some measures are chosen, no additional measure should be replaced to zero
foreach j in nat subnat school {
foreach i in eq4_all_`j'offeredspecial eq4_all_`j'instruction eq4_all_`j'ppe eq4_all_`j'guidelines eq4_all_`j'professionaldev eq4_all_`j'teachingcontent eq4_all_`j'icttools eq4_all_`j'other {
replace eq4_all_`j'noadditionalsup=0 if `i'==1
}
}

*Q1
label define eq1 1 "All of the teachers" 2 "More than 75% but not all of the teachers" 999 "Missing" 998 "Not applicable" 997 "Do not know"
label value eq1_all_percentage eq1

*Q1a
label define eq1a 0 "No" 1 "Yes" 999 "Missing" 998 "Not applicable" 997 "Do not know"
label value eq1a_all_premises eq1a

*Q1b
label define eq1b 0 "No" 1 "Yes" 999 "Missing" 998 "Not applicable" 997 "Do not know"
label value eq1b_ls_levels eq1b_p_levels eq1b_pp_levels eq1b_us_levels eq1b

*Q2
label define eq2_pay_l 1 "Decrease" 2 "Increase" 3 "No change" 4 "discretion of schools/districts" 997 "Do not know", modify
label value eq2_pp_pay eq2_p_pay eq2_ls_pay eq2_us_pay eq2_pay_l

*Q4
label define eq4 0 "No" 1 "Yes" 999 "Missing" 998 "Not applicable" 997 "Do not know"
label value eq4_all_natguidelines eq4_all_naticttools eq4_all_natinstruction eq4_all_natnoadditionalsup eq4_all_natofferedspecial eq4_all_natother eq4_all_natppe eq4_all_natprofessionaldev eq4_all_natteachingcontent eq4_all_schoolguidelines eq4_all_schoolicttools eq4_all_schoolinstruction eq4_all_schoolnoadditionalsup eq4_all_schoolofferedspecial eq4_all_schoolother eq4_all_schoolppe eq4_all_schoolprofessionaldev eq4_all_schoolteachingcontent eq4_all_subnatguidelines eq4_all_subnaticttools eq4_all_subnatinstruction eq4_all_subnatnoadditionalsup eq4_all_subnatofferedspecial eq4_all_subnatother eq4_all_subnatppe eq4_all_subnatprofessionaldev eq4_all_subnatteachingcontent eq4

*S5/eq4a/Q4a:
	label define eq4a_value 			///
			1 "Less than 25%"						///
			2 "More than 25% but less than 50%"		///
			3 "About half of the students"			///
			4 "More than 50% but less than 75%"		///
			5 "More than 75% but not all"	 ///
			6 "All of the teachers" ///
			997 "Unknown/not monitored" ///
			999 "Missing" 
	label value eq4a_all_distance eq4b_all_support eq4a_value
	
*Q5/Q3
label define eq5_value 								///
			0 "No"										///
			1 "Yes"										///
			2 "At discretion of schools/ districts"		///
			997 "Do not know"							///
			998 "Not applicable"						///
			999 "Missing"
label value eq3_ls_2020 eq3_ls_2021 eq3_p_2020 eq3_p_2021 eq3_pp_2020 eq3_pp_2021 eq3_us_2020 eq3_us_2021 eq5_value
label value eq5_all_phonecalls eq5_all_emails eq5_all_textwhatsapp eq5_all_videoconference eq5_all_homevisits eq5_all_communicationoneschool eq5_all_useofonlineparentalsurve eq5_all_holdingregularconversat eq5_all_involvingparents eq5_all_nospecificguidelines eq5_all_other eq5_value
	
*Q6
label define eq6_all_vaccine_l 1 "No, teachers are considered as the general population;" 2 "Yes, as a national measure prioritizing teachers;"  ///
3 "Yes, as part of the COVAX initiative to secure access to the future COVID-19 vaccine in low and middle-income countries" ///
4 "Other, please explain " 997 "Do not know" 998 "Not applicable" 999 "Do not know"
label value eq6_all_vaccine eq6_all_vaccine_l

*Q6a
label define eq6a 0 "No" 1 "Yes" 999 "Missing" 998 "Not applicable" 997 "Do not know"
label value eq6a_all_no eq6a_all_yesbyagegroup eq6a_all_yesbylevelofeducation eq6a_all_yesbysubnationallevel eq6a_all_yesotherpleasespecify eq6a
*Q6b
label define eq6b 0 "No" 1 "Yes" 999 "Missing" 998 "Not applicable" 997 "Do not know"
label value eq6b_all_2021q1 eq6b_all_2021q2 eq6b_all_2021q3 eq6b_all_2021q4 eq6b_all_2022 eq6b_all_donotknow eq6b_all_stillnotdefined eq6b
******* Step F - Open section to clean specific interested questions *******

*---------------------------------------------------------------------------
* Section 6. Learning Assessments and Examinations
*---------------------------------------------------------------------------

******* Step A - Variable renaming/dropping

**** RENAMING
/// To solve any confusion about next lines of code:
// a. FQ2 in OECD is being renamed to FQ1 to match UIS questionnaire
// b. FQ1 in OECD is being renamed to FQ3 to match UIS questionnaire
// c. FQ3 in OECD corresponds to FQ2 in UIS. It is UIS that is supposed to map their questions onto ours in this case.
/// This last bit can cause additional confusion down the line, please have this in mind.
** fq2 - added to OECD dataset after realizing an error in first version omitted this data.
renvars fq2_usg_2020postponed fq2_usg_2020other fq2_usg_2020nochangesweremade fq2_usg_2020introducedaltass fq2_usg_2020introducedaddh fq2_usg_2020canceledexams fq2_usg_2020adjustedthemode fq2_usg_2020adjustedthecontent / fq1_us_2020postponed fq1_us_2020other fq1_us_2020nochangesweremade fq1_us_2020introducedaltass fq1_us_2020introducedaddh fq1_us_2020canceledexams fq1_us_2020adjustedthemode fq1_us_2020adjustedthecontent
** Same for primary education
renvars fq2_p_2020postponed fq2_p_2020other fq2_p_2020nochangesweremade fq2_p_2020introducedaltass fq2_p_2020introducedaddh fq2_p_2020canceledexams fq2_p_2020adjustedthemode fq2_p_2020adjustedthecontent / fq1_p_2020postponed fq1_p_2020other fq1_p_2020nochangesweremade fq1_p_2020introducedaltass fq1_p_2020introducedaddh fq1_p_2020canceledexams fq1_p_2020adjustedthemode fq1_p_2020adjustedthecontent
** Same for lower secondary education
renvars fq2_ls_2020postponed fq2_ls_2020other fq2_ls_2020nochangesweremade fq2_ls_2020introducedaltass fq2_ls_2020introducedaddh fq2_ls_2020canceledexams fq2_ls_2020adjustedthemode fq2_ls_2020adjustedthecontent / fq1_ls_2020postponed fq1_ls_2020other fq1_ls_2020nochangesweremade fq1_ls_2020introducedaltass fq1_ls_2020introducedaddh fq1_ls_2020canceledexams fq1_ls_2020adjustedthemode fq1_ls_2020adjustedthecontent

drop fq1_all_specify
rename fq2_all_specify fq1_all_specify

** fq1 - added to OECD dataset after realizing an error in first version omitted this data.
renvars fq1_p_2020adjustgrade fq1_ls_2020adjustgrade fq1_usg_2020adjustgrade / fq3_p_2020 fq3_ls_2020 fq3_us_2020
**** DROPPING
** fq3 -> fq2 - NOT CHANGING THIS , UIS WILL MAP TO OECD VARIABLES, NOT THE OPPOSITE.

******* Step B - Structural conversions between OECD and UIS format
*Step B.1. "Select all that apply(SA)" v.s  "Select single(SS)"

*Step B.2. Disaggregations

******* Step C - Variable labeling *******


** Question 2
	foreach i in p ls us {
		foreach j in 2020adjustedthecontent 2020adjustedthemode 2020canceledexams 2020introducedaddh 2020introducedaltass 2020nochangesweremade 2020other 2020postponed {
				label var fq1_`i'_`j' "`i': `j'"				
		}
	}

** Question 3
	foreach i in p ls {
		foreach j in classroom noplan notassessed standard {
				label var fq3_`i'_`j' "`i': `j'"				
		}
	}
	
** Question 1
	foreach i in p ls us {
		foreach j in 2020 {
				label var fq3_`i'_`j' "`i': `j'"				
		}
	}
	

******* Step D - String to numerical (Yes, No, Select all that apply *******
**** Question 2 - Have you made any of the following changes to national examinations due to the pandemic?
********* Note: this was renamed to "fq1" to match UIS questionnaire.
foreach var of varlist fq1_ls_2020adjustedthecontent fq1_ls_2020adjustedthemode fq1_ls_2020canceledexams fq1_ls_2020introducedaddh fq1_ls_2020introducedaltass fq1_ls_2020nochangesweremade fq1_ls_2020other fq1_ls_2020postponed fq1_p_2020adjustedthecontent fq1_p_2020adjustedthemode fq1_p_2020canceledexams fq1_p_2020introducedaddh fq1_p_2020introducedaltass fq1_p_2020nochangesweremade fq1_p_2020other fq1_p_2020postponed fq1_us_2020adjustedthecontent fq1_us_2020adjustedthemode fq1_us_2020canceledexams fq1_us_2020introducedaddh fq1_us_2020introducedaltass fq1_us_2020nochangesweremade fq1_us_2020other fq1_us_2020postponed {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="1" if `var'=="Yes"
		replace `var'="0" if `var'=="No"
		destring `var', replace
}

**** Question 3 - Have there been any steps taken to assess whether there have been learning losses as a result of COVID related school closure in 2020?
foreach var of varlist fq3_ls_classroom fq3_ls_noplan fq3_ls_notassessed fq3_ls_standard fq3_p_classroom fq3_p_noplan fq3_p_notassessed fq3_p_standard {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"
		replace `var'="1" if `var'=="Yes"
		replace `var'="0" if `var'=="No"
		destring `var', replace
}

**** Question 1 - Did your plans for school re-opening  include adjustment to graduation criteria at the end of school years 2019/2020 (2020 for countries with calendar year) and 2020/2021 (2021 for countries with calendar year) ? 
*********** NOTE: There are two sets of "fq3" here! One of them will be matched from the UIS side!
foreach var of varlist fq3_p_2020 fq3_ls_2020 fq3_us_2020 {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"
		replace `var'="2" if `var'=="Schools/Districts/the most local level of governance could decide at their own discretion"	
		replace `var'="1" if `var'=="Yes"
		replace `var'="0" if `var'=="No"
		destring `var', replace
}


******* Step E - Data cleaning *******
*Q2
label define fq2 0 "No" 1 "Yes" 999 "Missing" 998 "Not applicable" 997 "Do not know"
label value fq1_ls_2020adjustedthecontent fq1_ls_2020adjustedthemode fq1_ls_2020canceledexams fq1_ls_2020introducedaddh fq1_ls_2020introducedaltass fq1_ls_2020nochangesweremade fq1_ls_2020other fq1_ls_2020postponed fq1_p_2020adjustedthecontent fq1_p_2020adjustedthemode fq1_p_2020canceledexams fq1_p_2020introducedaddh fq1_p_2020introducedaltass fq1_p_2020nochangesweremade fq1_p_2020other fq1_p_2020postponed fq1_us_2020adjustedthecontent fq1_us_2020adjustedthemode fq1_us_2020canceledexams fq1_us_2020introducedaddh fq1_us_2020introducedaltass fq1_us_2020nochangesweremade fq1_us_2020other fq1_us_2020postponed fq2

*Q3
label define fq3steps 0 "No" 1 "Yes" 999 "Missing" 998 "Not applicable" 997 "Do not know"
label value fq3_ls_classroom fq3_ls_noplan fq3_ls_notassessed fq3_ls_standard fq3_p_classroom fq3_p_noplan fq3_p_notassessed fq3_p_standard fq3steps

*Q1
label define fq3_2020 0 "No" 1 "Yes" 2 "This can be done at the discretion of school" 999 "Missing" 998 "Not applicable" 997 "Do not know"
label value fq3_p_2020 fq3_ls_2020 fq3_us_2020  fq3_2020

******* Step F - Open section to clean specific interested questions *******

*---------------------------------------------------------------------------
* Section 7. Financing
*---------------------------------------------------------------------------

******* Step A - Variable renaming/dropping

**** RENAMING
** gq2 - Convert "PSP" variables to "All" as decided by OECD (2020)
renvars gq2_psp_fy2020totalcurrentexp gq2_psp_fy2020compofteac gq2_psp_fy2020compofothe gq2_psp_fy2020schoolsmeals gq2_psp_fy2020condcashtra gq2_psp_fy2020studentsuppgra gq2_psp_fy2020studentloans gq2_psp_fy2020othercurrentexp gq2_psp_fy2020totalcapitalexp / gq2_all_fy2020totalcurrentexp gq2_all_fy2020compofteac gq2_all_fy2020compofothe gq2_all_fy2020schoolsmeals gq2_all_fy2020condcashtra gq2_all_fy2020studentsuppgra gq2_all_fy2020studentloans gq2_all_fy2020othercurrentexp gq2_all_fy2020totalcapitalexp 

** gq2 - Convert "PSP" variables to "All" as decided by OECD (2021)
renvars gq2_psp_fy2021totalcurrentexp gq2_psp_fy2021compofteac gq2_psp_fy2021compofothe gq2_psp_fy2021schoolsmeals gq2_psp_fy2021condcashtra gq2_psp_fy2021studentsuppgra gq2_psp_fy2021studentloans  gq2_psp_fy2021othercurrentexp gq2_psp_fy2021totalcapitalexp / gq2_all_fy2021totalcurrentexp gq2_all_fy2021compofteac gq2_all_fy2021compofothe gq2_all_fy2021schoolsmeals gq2_all_fy2021condcashtra gq2_all_fy2021studentsuppgra gq2_all_fy2021studentloans gq2_all_fy2021othercurrentexp gq2_all_fy2021totalcapitalexp

** gq3 - Convert "PSP" variables to "All" and rename to gq2a
renvars gq3_psp_addfundingfromex gq3_psp_reprogofprevious gq3_psp_addallocationfro gq3_psp_reallocwithintheed / gq2a_all_addfundingfromex gq2a_all_reprogofprevious gq2a_all_addallocationfro gq2a_all_reallocwithintheed

** gq7 - Convert to UIS variable names (convert gq7 to gq3)
renvars gq7_all_geographiccriteria gq7_all_none gq7_all_notapplicable gq7_all_numberofstudentsclass gq7_all_othercriteria gq7_all_socioeconomiccharacter gq7_all_specify gq7_all_studentswithsen / gq3_all_geographiccriteria gq3_all_none gq3_all_notapplicable gq3_all_numberofstudentsclass gq3_all_othercriteria gq3_all_socioeconomiccharacter gq3_all_specify gq3_all_studentswithsen

** gq8 - Rename to UIS name gq3
renvars gq8_all_distribution gq8_all_specify / gq4_all_distribution gq4a_all_specify

**** DROPPING
** gq2
drop gq2_pp*
** gq3
drop gq3_pp*
** gq4
drop gq4_pp* gq4_ls* gq4_p* gq4_usg*
** gq5
drop gq5_all_allocationfunds 
** gq6
drop gq6a_all_criteriafunding gq6b_all_newcriteria gq6c_all_weights

******* Step B - Structural conversions between OECD and UIS format
*Step B.1. "Select all that apply(SA)" v.s  "Select single(SS)"

/// GQ1 - choose lower secondary to create new "ALL" variable, as it is the education level that matches the most common answer (50% or more of education levels)
gen gq1_all_2020=gq1_ls_2020
gen gq1_all_2021=gq1_ls_2021
// Exception is Russia
replace gq1_all_2020=gq1_pp_2020 if Country=="RUS"
replace gq1_all_2021=gq1_pp_2021 if Country=="RUS"

** gq2_ -> gq2_all IS NO LONGER NECESSARY HERE BECAUSE WE RENAMED "PSP" TO "ALL".
** gq3 -> gq2a_all IS NO LONGER NECESSARY HERE BECAUSE WE RENAMED "PSP" TO "ALL".
*Step B.2. Disaggregations

******* Step C - Variable labeling *******

*Q1
	foreach i in all pp p ls us {
		foreach j in 2020 2021 {
				label var gq1_`i'_`j' "`i': `j'"			
		}
	}
*Q2
	foreach i in all {
		foreach j in fy2020compofothe fy2020compofteac fy2020condcashtra fy2020othercurrentexp fy2020schoolsmeals fy2020studentloans fy2020studentsuppgra fy2020totalcapitalexp fy2020totalcurrentexp fy2021compofothe fy2021compofteac fy2021condcashtra fy2021othercurrentexp fy2021schoolsmeals fy2021studentloans fy2021studentsuppgra fy2021totalcapitalexp {
				label var gq2_`i'_`j' "`i': `j'"			
		}
	}
*Q2a
	foreach i in all {
		foreach j in addfundingfromex reprogofprevious addallocationfro reallocwithintheed {
				label var gq2a_`i'_`j' "`i': `j'"			
		}
	}
*Q3
	foreach i in all {
		foreach j in geographiccriteria none notapplicable numberofstudentsclass othercriteria socioeconomiccharacter specify studentswithsen {
				label var gq3_`i'_`j' "`i': `j'"			
		}
	}
*Q4
	foreach i in all {
		foreach j in distribution {
				label var gq4_`i'_`j' "`i': `j'"			
		}
	}
******* Step D - String to numerical (Yes, No, Select all that apply *******
**** Question 1 - Have there been changes planned to the fiscal year education budget (i.e. increases, no changes, decreases) to ensure the response to COVID-19 for education in 2020 and 2021? 
foreach var of varlist gq1_all_2020 gq1_all_2021 gq1_ls_2020 gq1_ls_2021 gq1_p_2020 gq1_p_2021 gq1_pp_2020 gq1_pp_2021 gq1_us_2020 gq1_us_2021 {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'= "1" if `var'== "Increases"
		replace `var'= "2" if `var'== "No changes" | `var' == "No changes "
		replace `var'= "3" if `var'== "Decreased"  | `var' == "Decreases"
		replace `var'= "4" if `var'== "No change in the total amount, but significant changes in the distribution of expenditures"
		replace `var'= "5" if `var'== "Schools/Districts/the most local level of governance could decide at their own discretion"
		replace `var'= "6" if `var'== "No changes at all (i.e total and distribution of expenditures)"	
		destring `var', replace
}

**** Question 2 - Has the distribution of education spending between current and capital expenditures changed/is planned to change as a result of the education response to COVID-19? 
foreach var of varlist gq2_all_fy2020compofothe gq2_all_fy2020compofteac gq2_all_fy2020condcashtra gq2_all_fy2020othercurrentexp gq2_all_fy2020schoolsmeals gq2_all_fy2020studentloans gq2_all_fy2020studentsuppgra gq2_all_fy2020totalcapitalexp gq2_all_fy2020totalcurrentexp gq2_all_fy2021totalcurrentexp gq2_all_fy2021compofothe gq2_all_fy2021compofteac gq2_all_fy2021condcashtra gq2_all_fy2021othercurrentexp gq2_all_fy2021schoolsmeals gq2_all_fy2021studentloans gq2_all_fy2021studentsuppgra gq2_all_fy2021totalcapitalexp {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'= "1" if `var'== "Increases"
		replace `var'= "2" if `var'== "No changes" | `var' == "No changes "
		replace `var'= "3" if `var'== "Decreased"  | `var' == "Decreases"
		replace `var'= "4" if `var'== "No change in the total amount, but significant changes in the distribution of expenditures"
		replace `var'= "5" if `var'== "Schools/Districts/the most local level of governance could decide at their own discretion"
		replace `var'= "6" if `var'== "No changes at all (i.e total and distribution of expenditures)"
		destring `var', replace
}

**** Question 2a - If answered ‘increase’ to any of the categories in Q2, how were they funded? 
foreach var of varlist gq2a_all_addfundingfromex gq2a_all_reprogofprevious gq2a_all_addallocationfro gq2a_all_reallocwithintheed {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="1" if `var'=="Yes"
		replace `var'="0" if `var'=="No"
		replace `var'= "999" if `var'== "Schools/Districts/the most local level of governance could decide at their own discretion"
		destring `var', replace
}

**** Question 3 
foreach var of varlist gq3_all_geographiccriteria gq3_all_none gq3_all_notapplicable gq3_all_numberofstudentsclass gq3_all_othercriteria gq3_all_socioeconomiccharacter gq3_all_studentswithsen {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="999" if `var'=="Schools can decide at their own discretion"
		replace `var'="1" if `var'=="Yes"
		replace `var'="0" if `var'=="No"
		destring `var', replace
	}

**** Question 4
foreach var of varlist gq4_all_distribution {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="1" if `var'=="Yes"
		replace `var'="0" if `var'=="No"
		destring `var', replace
	}
	
******* Step E - Data cleaning *******
** Data labels

** Q1
	label define gq1_values 997 "Do Not Know" 998 "Not Applicable" 999 "Missing" 1 "Increased" 2 "No changes" 3 "Decreased" 4 "No change in the total amount, but significant changes in the distribution of expenditures" 5 "Schools/Districts/the most local level of governance could decide at their own discretion" 6 "No changes at all (i.e total and distribution of expenditures)"
	label value gq1_all_2020 gq1_all_2021 gq1_ls_2020 gq1_ls_2021 gq1_p_2020 gq1_p_2021 gq1_pp_2020 gq1_pp_2021 gq1_us_2020 gq1_us_2021 gq1_values

** Q2
	label define gq2_values 997 "Do Not Know" 998 "Not Applicable" 999 "Missing" 1 "Increased" 2 "No changes" 3 "Decreased" 4 "No change in the total amount, but significant changes in the distribution of expenditures" 5 "Schools/Districts/the most local level of governance could decide at their own discretion" 6 "No changes at all (i.e total and distribution of expenditures)"
	label value gq2_all_fy2020compofothe gq2_all_fy2020compofteac gq2_all_fy2020condcashtra gq2_all_fy2020othercurrentexp gq2_all_fy2020schoolsmeals gq2_all_fy2020studentloans gq2_all_fy2020studentsuppgra gq2_all_fy2020totalcapitalexp gq2_all_fy2020totalcurrentexp gq2_all_fy2021totalcurrentexp gq2_all_fy2021compofothe gq2_all_fy2021compofteac gq2_all_fy2021condcashtra gq2_all_fy2021othercurrentexp gq2_all_fy2021schoolsmeals gq2_all_fy2021studentloans gq2_all_fy2021studentsuppgra gq2_all_fy2021totalcapitalexp gq2_values
** Q2a
	label define gq2a_values 0 "No" 1 "Yes" 997 "Do Not Know" 998 "Not Applicable" 999 "Missing"
	label value gq2a_all_addfundingfromex gq2a_all_reprogofprevious gq2a_all_addallocationfro gq2a_all_reallocwithintheed gq2a_values
** Q3
	label define gq3_values 0 "No" 1 "Yes" 997 "Do Not Know" 998 "Not Applicable" 999 "Missing"
	label value gq3_all_geographiccriteria gq3_all_none gq3_all_notapplicable gq3_all_numberofstudentsclass gq3_all_othercriteria gq3_all_socioeconomiccharacter gq3_all_studentswithsen gq3_values
** Q4
	label define gq4_values 0 "No" 1 "Yes" 997 "Do Not Know" 998 "Not Applicable" 999 "Missing"
	label value gq4_all_distribution gq4_values
******* Step F - Open section to clean specific interested questions *******

*---------------------------------------------------------------------------
* Section 8. Locus of Decision Making
*---------------------------------------------------------------------------

******* Step A - Variable renaming/dropping

**** RENAMING

**** DROPPING
** hq2
drop hq2*

******* Step B - Structural conversions between OECD and UIS format
*Step B.1. "Select all that apply(SA)" v.s  "Select single(SS)"
** hq1_all_aq1-4 -> hq1_all_*

	*1 School closure and reopening
gen hq1_all_schoolcentral="0"
gen hq1_all_schoolprovincial="0"
gen hq1_all_schoolsubreg="0"
gen hq1_all_schoollocal="0"
gen hq1_all_schoolschool="0"

replace hq1_all_schoolcentral="1" if hq1_all_aq1=="(1) Central government"
replace hq1_all_schoolprovincial="1" if hq1_all_aq1=="(2) State governments"
replace hq1_all_schoolprovincial="1" if hq1_all_aq1=="(3) Provincial/Regional authorities or governments"
replace hq1_all_schoolsubreg="1" if hq1_all_aq1=="(4) Sub-regional or inter-municipal authorities or government "
replace hq1_all_schoollocal="1" if hq1_all_aq1=="(5) Local authorities or governments or owner of government-dependent private institutions"
replace hq1_all_schoolschool="1" if hq1_all_aq1=="(6) School, school board or committee"
*** Note: OECD also has option "(7) Multiple levels (please provide details in comments)"
replace hq1_all_schoolcentral="999" if hq1_all_aq1=="(m) Missing"  & Country!="SWE"
replace hq1_all_schoolcentral="998" if hq1_all_aq1=="Not applicable (a)"  & Country!="SWE"
replace hq1_all_schoolprovincial="999" if hq1_all_aq1=="(m) Missing"   & Country!="SWE"
replace hq1_all_schoolprovincial="998" if hq1_all_aq1=="Not applicable (a)" & Country!="SWE"
replace hq1_all_schoolsubreg="999" if hq1_all_aq1=="(m) Missing"   & Country!="SWE"
replace hq1_all_schoolsubreg="998" if hq1_all_aq1=="Not applicable (a)" & Country!="SWE"
replace hq1_all_schoollocal="999" if hq1_all_aq1=="(m) Missing"   & Country!="SWE"
replace hq1_all_schoollocal="998" if hq1_all_aq1=="Not applicable (a)" & Country!="SWE"
replace hq1_all_schoolschool="999" if hq1_all_aq1=="(m) Missing" & Country!="SWE"
replace hq1_all_schoolschool="998" if hq1_all_aq1=="Not applicable (a)"  & Country!="SWE"

***** Country specific exceptions to this rule:
**** 1) Norway - selected (7) Multiple levels  - at Primary Levels , central government. At lower secondary levels, multiple levels. No further comment, other than the framework being set up by the central government. On that basis, assign to "central government"
replace hq1_all_schoolcentral="1" if Country=="NOR"
**** 2) Sweden - select (6) School, school board or committee
replace hq1_all_schoolschool="1" if Country=="SWE"
**** 3) Lithuania exception, originally (7) Multiple levels. The decision over the closure of schools was made by Lithuania's government. Later, as Lithuania's government allowed schools to resume classes for primary education, the majority of schools or councils of municipalities decided to continue the remote education process only. Q2. Lithuania's Ministry of Education suggested ending the academic year on June 1, but schools were free to decide whether to continue educational activities later into this term. 
replace hq1_all_schoolschool="1" if Country=="LTU"
replace hq1_all_schoollocal="1" if Country=="LTU"
replace hq1_all_schoolcentral="1" if Country=="LTU"
**** 4) Korea exception, originally (7) Multiple levels. The locus of decision was made at multiple levels: The central government (Ministry of Health and Welfare, Ministry of Education) and provincial/regional authorities or governments made decisions regarding the education response to the COVID-19 crisis in 2020.
replace hq1_all_schoolprovincial="1" if Country=="KOR"
replace hq1_all_schoolcentral="1" if Country=="KOR"

	*2 Adjustments to school calendar
gen hq1_all_adjustmentscentral="0"
gen hq1_all_adjustmentsprovincial="0"
gen hq1_all_adjustmentssubreg="0"
gen hq1_all_adjustmentslocal="0"
gen hq1_all_adjustmentsschool="0"

replace hq1_all_adjustmentscentral="1" if hq1_all_aq2=="(1) Central government"
replace hq1_all_adjustmentsprovincial="1" if hq1_all_aq2=="(2) State governments"
replace hq1_all_adjustmentsprovincial="1" if hq1_all_aq2=="(3) Provincial/Regional authorities or governments"
replace hq1_all_adjustmentssubreg="1" if hq1_all_aq2=="(4) Sub-regional or inter-municipal authorities or government "
replace hq1_all_adjustmentslocal="1" if hq1_all_aq2=="(5) Local authorities or governments or owner of government-dependent private institutions"
replace hq1_all_adjustmentsschool="1" if hq1_all_aq2=="(6) School, school board or committee"
*** Note: OECD also has option "(7) Multiple levels (please provide details in comments)"
replace hq1_all_adjustmentscentral="999" if hq1_all_aq2=="(m) Missing"  & (Country!="SWE" & Country!="AUT")
replace hq1_all_adjustmentscentral="998" if hq1_all_aq2=="Not applicable (a)" & (Country!="SWE" & Country!="AUT")
replace hq1_all_adjustmentsprovincial="999" if hq1_all_aq2=="(m) Missing"   & (Country!="SWE" & Country!="AUT")
replace hq1_all_adjustmentsprovincial="998" if hq1_all_aq2=="Not applicable (a)"  & (Country!="SWE" & Country!="AUT")
replace hq1_all_adjustmentssubreg="999" if hq1_all_aq2=="(m) Missing"   & (Country!="SWE" & Country!="AUT")
replace hq1_all_adjustmentssubreg="998" if hq1_all_aq2=="Not applicable (a)"   & (Country!="SWE" & Country!="AUT")
replace hq1_all_adjustmentslocal="999" if hq1_all_aq2=="(m) Missing"   & (Country!="SWE" & Country!="AUT")
replace hq1_all_adjustmentslocal="998" if hq1_all_aq2=="Not applicable (a)"   & (Country!="SWE" & Country!="AUT")
replace hq1_all_adjustmentsschool="999" if hq1_all_aq2=="(m) Missing"   & (Country!="SWE" & Country!="AUT")
replace hq1_all_adjustmentsschool="998" if hq1_all_aq2=="Not applicable (a)"  & (Country!="SWE" & Country!="AUT")

***** Country specific exceptions to this rule:
**** 1) Austria - Central government
replace hq1_all_adjustmentscentral="1" if Country=="AUT"
**** 2) Sweden - select (6) School, school board or committee
replace hq1_all_adjustmentsschool="1" if Country=="SWE"
**** 3) Lithuania exception, originally (7) Multiple levels. The decision over the closure of schools was made by Lithuania's government. Later, as Lithuania's government allowed schools to resume classes for primary education, the majority of schools or councils of municipalities decided to continue the remote education process only. Q2. Lithuania's Ministry of Education suggested ending the academic year on June 1, but schools were free to decide whether to continue educational activities later into this term. 
******** On this basis, both central government and schools
replace hq1_all_adjustmentsschool="1" if Country=="LTU"
replace hq1_all_adjustmentslocal="1" if Country=="LTU"
replace hq1_all_adjustmentscentral="1" if Country=="LTU"
**** 4) Korea exception, originally (7) Multiple levels. The locus of decision was made at multiple levels: The central government (Ministry of Health and Welfare, Ministry of Education) and provincial/regional authorities or governments made decisions regarding the education response to the COVID-19 crisis in 2020.
replace hq1_all_adjustmentsprovincial="1" if Country=="KOR"
replace hq1_all_adjustmentscentral="1" if Country=="KOR"

	*3 Resources to continue learning during school closures
gen hq1_all_resourcescentral="0"
gen hq1_all_resourcesprovincial="0"
gen hq1_all_resourcessubreg="0"
gen hq1_all_resourceslocal="0"
gen hq1_all_resourcesschool="0"

replace hq1_all_resourcescentral="1" if hq1_all_aq3=="(1) Central government"
replace hq1_all_resourcesprovincial="1" if hq1_all_aq3=="(2) State governments"
replace hq1_all_resourcesprovincial="1" if hq1_all_aq3=="(3) Provincial/Regional authorities or governments"
replace hq1_all_resourcessubreg="1" if hq1_all_aq3=="(4) Sub-regional or inter-municipal authorities or government "
replace hq1_all_resourceslocal="1" if hq1_all_aq3=="(5) Local authorities or governments or owner of government-dependent private institutions"
replace hq1_all_resourcesschool="1" if hq1_all_aq3=="(6) School, school board or committee"
*** Note: OECD also has option "(7) Multiple levels (please provide details in comments)"
**** Resources to continue learning during school closures. Many countries selected this option. Select all of them as "999"
replace hq1_all_resourcescentral="999" if hq1_all_aq3=="(m) Missing" | hq1_all_aq3=="(7) Multiple levels (please provide details in comments)"  & Country!="SWE"
replace hq1_all_resourcescentral="998" if hq1_all_aq3=="Not applicable (a)" & (Country!="SWE" & Country!="KOR")
replace hq1_all_resourcesprovincial="999" if hq1_all_aq3=="(m) Missing" | hq1_all_aq3=="(7) Multiple levels (please provide details in comments)"  & Country!="SWE"
replace hq1_all_resourcesprovincial="998" if hq1_all_aq3=="Not applicable (a)"  & (Country!="SWE" & Country!="KOR")
replace hq1_all_resourcessubreg="999" if hq1_all_aq3=="(m) Missing" | hq1_all_aq3=="(7) Multiple levels (please provide details in comments)"  & Country!="SWE"
replace hq1_all_resourcessubreg="998" if hq1_all_aq3=="Not applicable (a)" & (Country!="SWE" & Country!="KOR")
replace hq1_all_resourceslocal="999" if hq1_all_aq3=="(m) Missing" | hq1_all_aq3=="(7) Multiple levels (please provide details in comments)"  & Country!="SWE"
replace hq1_all_resourceslocal="998" if hq1_all_aq3=="Not applicable (a)" & (Country!="SWE" & Country!="KOR")
replace hq1_all_resourcesschool="999" if hq1_all_aq3=="(m) Missing" | hq1_all_aq3=="(7) Multiple levels (please provide details in comments)"  & Country!="SWE"
replace hq1_all_resourcesschool="998" if hq1_all_aq3=="Not applicable (a)" & (Country!="SWE" & Country!="KOR")

***** Country specific exceptions to this rule:
**** 1) Sweden - select (6) School, school board or committee
replace hq1_all_resourcesschool="1" if Country=="SWE"

**** 2) Korea - originally (7) Multiple levels. The locus of decision was made at multiple levels: The central government (Ministry of Health and Welfare, Ministry of Education) and provincial/regional authorities or governments made decisions regarding the education response to the COVID-19 crisis in 2020.
replace hq1_all_resourcescentral="1" if Country=="KOR"
replace hq1_all_resourcesprovincial="1" if Country=="KOR"

	*4 Additional support programs for students after schools reopened
gen hq1_all_addsupcentral="0"
gen hq1_all_addsupprovincial="0"
gen hq1_all_addsupsubreg="0"
gen hq1_all_addsuplocal="0"
gen hq1_all_addsupschool="0"

replace hq1_all_addsupcentral="1" if hq1_all_aq4=="(1) Central government"
replace hq1_all_addsupprovincial="1" if hq1_all_aq4=="(2) State governments"
replace hq1_all_addsupprovincial="1" if hq1_all_aq4=="(3) Provincial/Regional authorities or governments"
replace hq1_all_addsupsubreg="1" if hq1_all_aq4=="(4) Sub-regional or inter-municipal authorities or government "
replace hq1_all_addsuplocal="1" if hq1_all_aq4=="(5) Local authorities or governments or owner of government-dependent private institutions"
replace hq1_all_addsupschool="1" if hq1_all_aq4=="(6) School, school board or committee"
*** Note: OECD also has option "(7) Multiple levels (please provide details in comments)"	
**** Additional support programs. Many countries selected this option. Select all of them as "999"
replace hq1_all_addsupcentral="999" if hq1_all_aq4=="(m) Missing"  | hq1_all_aq4=="(7) Multiple levels (please provide details in comments)"   & (Country!="SVK" & Country!="KOR")
replace hq1_all_addsupcentral="998" if hq1_all_aq4=="Not applicable (a)" & (Country!="SVK" & Country!="KOR")
replace hq1_all_addsupprovincial="999" if hq1_all_aq4=="(m) Missing"  | hq1_all_aq4=="(7) Multiple levels (please provide details in comments)"   & (Country!="SVK" & Country!="KOR")
replace hq1_all_addsupprovincial="998" if hq1_all_aq4=="Not applicable (a)" & (Country!="SVK" & Country!="KOR")
replace hq1_all_addsupsubreg="999" if hq1_all_aq4=="(m) Missing"  | hq1_all_aq4=="(7) Multiple levels (please provide details in comments)"    & (Country!="SVK" & Country!="KOR")
replace hq1_all_addsupsubreg="998" if hq1_all_aq4=="Not applicable (a)" & (Country!="SVK" & Country!="KOR")
replace hq1_all_addsuplocal="999" if hq1_all_aq4=="(m) Missing"  | hq1_all_aq4=="(7) Multiple levels (please provide details in comments)"    & (Country!="SVK" & Country!="KOR")
replace hq1_all_addsuplocal="998" if hq1_all_aq4=="Not applicable (a)" & (Country!="SVK" & Country!="KOR")
replace hq1_all_addsupschool="999" if hq1_all_aq4=="(m) Missing"  | hq1_all_aq4=="(7) Multiple levels (please provide details in comments)"    & (Country!="SVK" & Country!="KOR")
replace hq1_all_addsupschool="998" if hq1_all_aq4=="Not applicable (a)" & (Country!="SVK" & Country!="KOR")

***** Country specific exceptions to this rule:
**** 1) Slovakia - select (6) School, school board or committee
replace hq1_all_addsupschool="1" if Country=="SVK"
**** 2) Korea exception, originally (7) Multiple levels. The locus of decision was made at multiple levels: The central government (Ministry of Health and Welfare, Ministry of Education) and provincial/regional authorities or governments made decisions regarding the education response to the COVID-19 crisis in 2020. However, this is the ONLY case in hq1_all_aq1 to hq1_all_aq8 where the answer is (6) School, school board or committee.

	*5 Working requirements for teachers
gen hq1_all_workingreqcentral="0"
gen hq1_all_workingreqprovincial="0"
gen hq1_all_workingreqsubreg="0"
gen hq1_all_workingreqlocal="0"
gen hq1_all_workingreqschool="0"

replace hq1_all_workingreqcentral="1" if hq1_all_aq5=="(1) Central government"
replace hq1_all_workingreqprovincial="1" if hq1_all_aq5=="(2) State governments"
replace hq1_all_workingreqprovincial="1" if hq1_all_aq5=="(3) Provincial/Regional authorities or governments"
replace hq1_all_workingreqsubreg="1" if hq1_all_aq5=="(4) Sub-regional or inter-municipal authorities or government "
replace hq1_all_workingreqlocal="1" if hq1_all_aq5=="(5) Local authorities or governments or owner of government-dependent private institutions"
replace hq1_all_workingreqschool="1" if hq1_all_aq5=="(6) School, school board or committee"
*** Note: OECD also has option "(7) Multiple levels (please provide details in comments)"	
replace hq1_all_workingreqcentral="999" if hq1_all_aq5=="(m) Missing" | hq1_all_aq5=="(7) Multiple levels (please provide details in comments)" & (Country!="SWE" & Country!="KOR")
replace hq1_all_workingreqcentral="998" if hq1_all_aq5=="Not applicable (a)" & (Country!="SWE" & Country!="KOR")
replace hq1_all_workingreqprovincial="999" if hq1_all_aq5=="(m) Missing" | hq1_all_aq5=="(7) Multiple levels (please provide details in comments)" & (Country!="SWE" & Country!="KOR")
replace hq1_all_workingreqprovincial="998" if hq1_all_aq5=="Not applicable (a)" & (Country!="SWE" & Country!="KOR")
replace hq1_all_workingreqsubreg="999" if hq1_all_aq5=="(m) Missing" | hq1_all_aq5=="(7) Multiple levels (please provide details in comments)" & (Country!="SWE" & Country!="KOR")
replace hq1_all_workingreqsubreg="998" if hq1_all_aq5=="Not applicable (a)" & (Country!="SWE" & Country!="KOR")
replace hq1_all_workingreqlocal="999" if hq1_all_aq5=="(m) Missing" | hq1_all_aq5=="(7) Multiple levels (please provide details in comments)" & (Country!="SWE" & Country!="KOR")
replace hq1_all_workingreqlocal="998" if hq1_all_aq5=="Not applicable (a)" & (Country!="SWE" & Country!="KOR")
replace hq1_all_workingreqschool="999" if hq1_all_aq5=="(m) Missing" | hq1_all_aq5=="(7) Multiple levels (please provide details in comments)" & (Country!="SWE" & Country!="KOR")
replace hq1_all_workingreqschool="998" if hq1_all_aq5=="Not applicable (a)" & (Country!="SWE" & Country!="KOR")

***** Country specific exceptions to this rule:
**** 1) Sweden - select (6) School, school board or committee
replace hq1_all_workingreqschool="1" if Country=="SWE"
**** 2) Korea exception, originally (7) Multiple levels. The locus of decision was made at multiple levels: The central government (Ministry of Health and Welfare, Ministry of Education) and provincial/regional authorities or governments made decisions regarding the education response to the COVID-19 crisis in 2020.
replace hq1_all_workingreqprovincial="1" if Country=="KOR"
replace hq1_all_workingreqcentral="1" if Country=="KOR"

	*6 Compensation of teachers (due to the impact of the pandemic on teachers workload) - Number 7 in OECD
gen hq1_all_compensationcentral="0"
gen hq1_all_compensationprovincial="0"
gen hq1_all_compensationsubreg="0"
gen hq1_all_compensationlocal="0"
gen hq1_all_compensationschool="0"

replace hq1_all_compensationcentral="1" if hq1_all_aq7=="(1) Central government"
replace hq1_all_compensationprovincial="1" if hq1_all_aq7=="(2) State governments"
replace hq1_all_compensationprovincial="1" if hq1_all_aq7=="(3) Provincial/Regional authorities or governments"
replace hq1_all_compensationsubreg="1" if hq1_all_aq7=="(4) Sub-regional or inter-municipal authorities or government "
replace hq1_all_compensationlocal="1" if hq1_all_aq7=="(5) Local authorities or governments or owner of government-dependent private institutions"
replace hq1_all_compensationschool="1" if hq1_all_aq7=="(6) School, school board or committee"
*** Note: OECD also has option "(7) Multiple levels (please provide details in comments)"	
replace hq1_all_compensationcentral="998" if hq1_all_aq7=="Not applicable (a)" 
replace hq1_all_compensationprovincial="998" if hq1_all_aq7=="Not applicable (a)" 
replace hq1_all_compensationprovincial="998" if hq1_all_aq7=="Not applicable (a)" 
replace hq1_all_compensationsubreg="998" if hq1_all_aq7=="Not applicable (a)" 
replace hq1_all_compensationlocal="998" if hq1_all_aq7=="Not applicable (a)" 
replace hq1_all_compensationschool="998" if hq1_all_aq7=="Not applicable (a)" 

replace hq1_all_compensationcentral="999" if hq1_all_aq7=="(m) Missing" 
replace hq1_all_compensationprovincial="999" if hq1_all_aq7=="(m) Missing"
replace hq1_all_compensationprovincial="999" if hq1_all_aq7=="(m) Missing"
replace hq1_all_compensationsubreg="999" if hq1_all_aq7=="(m) Missing"
replace hq1_all_compensationlocal="999" if hq1_all_aq7=="(m) Missing"
replace hq1_all_compensationschool="999" if hq1_all_aq7=="(m) Missing"

	*7 Hygiene measures for school reopening - Number 8 in OECD
gen hq1_all_hygienecentral="0"
gen hq1_all_hygieneprovincial="0"
gen hq1_all_hygienesubreg="0"
gen hq1_all_hygienelocal="0"
gen hq1_all_hygieneschool="0"

replace hq1_all_hygienecentral="1" if hq1_all_aq8=="(1) Central government"
replace hq1_all_hygieneprovincial="1" if hq1_all_aq8=="(2) State governments"
replace hq1_all_hygieneprovincial="1" if hq1_all_aq8=="(3) Provincial/Regional authorities or governments"
replace hq1_all_hygienesubreg="1" if hq1_all_aq8=="(4) Sub-regional or inter-municipal authorities or government "
replace hq1_all_hygienelocal="1" if hq1_all_aq8=="(5) Local authorities or governments or owner of government-dependent private institutions"
replace hq1_all_hygieneschool="1" if hq1_all_aq8=="(6) School, school board or committee"
*** Note: OECD also has option "(7) Multiple levels (please provide details in comments)"
replace hq1_all_hygienecentral="998" if hq1_all_aq8=="Not applicable (a)" & Country!="SWE"
replace hq1_all_hygieneprovincial="998" if hq1_all_aq8=="Not applicable (a)" & Country!="SWE"
replace hq1_all_hygieneprovincial="998" if hq1_all_aq8=="Not applicable (a)" & Country!="SWE"
replace hq1_all_hygienesubreg="998" if hq1_all_aq8=="Not applicable (a)" & Country!="SWE"
replace hq1_all_hygienelocal="998" if hq1_all_aq8=="Not applicable (a)" & Country!="SWE"
replace hq1_all_hygieneschool="998" if hq1_all_aq8=="Not applicable (a)" & Country!="SWE"

replace hq1_all_hygienecentral="999" if hq1_all_aq8=="(m) Missing" & Country!="SWE"
replace hq1_all_hygieneprovincial="999" if hq1_all_aq8=="(m) Missing" & Country!="SWE"
replace hq1_all_hygieneprovincial="999" if hq1_all_aq8=="(m) Missing" & Country!="SWE"
replace hq1_all_hygienesubreg="999" if hq1_all_aq8=="(m) Missing" & Country!="SWE"
replace hq1_all_hygienelocal="999" if hq1_all_aq8=="(m) Missing" & Country!="SWE"
replace hq1_all_hygieneschool="999" if hq1_all_aq8=="(m) Missing" & Country!="SWE"

***** Country specific exceptions to this rule:
**** 1) Sweden - select (6) School, school board or committee
replace hq1_all_hygieneschool="1" if Country=="SWE"

	*8 how were decisions on changes in funding of schools (due to the pandemic) taken? - Number 9 in OECD
gen hq1_all_changescentral="0"
gen hq1_all_changesprovincial="0"
gen hq1_all_changessubreg="0"
gen hq1_all_changeslocal="0"
gen hq1_all_changesschool="0"

replace hq1_all_changescentral="1" if hq1_all_aq9=="(1) Central government"
replace hq1_all_changesprovincial="1" if hq1_all_aq9=="(2) State governments"
replace hq1_all_changesprovincial="1" if hq1_all_aq9=="(3) Provincial/Regional authorities or governments"
replace hq1_all_changessubreg="1" if hq1_all_aq9=="(4) Sub-regional or inter-municipal authorities or government "
replace hq1_all_changeslocal="1" if hq1_all_aq9=="(5) Local authorities or governments or owner of government-dependent private institutions"
replace hq1_all_changesschool="1" if hq1_all_aq9=="(6) School, school board or committee"
*** Note: OECD also has option "(7) Multiple levels (please provide details in comments)"
replace hq1_all_changescentral="998" if hq1_all_aq9=="Not applicable (a)" & Country!="SWE"
replace hq1_all_changesprovincial="998" if hq1_all_aq9=="Not applicable (a)" & Country!="SWE"
replace hq1_all_changesprovincial="998" if hq1_all_aq9=="Not applicable (a)" & Country!="SWE"
replace hq1_all_changessubreg="998" if hq1_all_aq9=="Not applicable (a)" & Country!="SWE"
replace hq1_all_changeslocal="998" if hq1_all_aq9=="Not applicable (a)" & Country!="SWE"
replace hq1_all_changesschool="998" if hq1_all_aq9=="Not applicable (a)" & Country!="SWE"

replace hq1_all_changescentral="999" if hq1_all_aq9=="(m) Missing"  & Country!="SWE"
replace hq1_all_changesprovincial="999" if hq1_all_aq9=="(m) Missing" & Country!="SWE"
replace hq1_all_changesprovincial="999" if hq1_all_aq9=="(m) Missing" & Country!="SWE"
replace hq1_all_changessubreg="999" if hq1_all_aq9=="(m) Missing" & Country!="SWE"
replace hq1_all_changeslocal="999" if hq1_all_aq9=="(m) Missing" & Country!="SWE"
replace hq1_all_changesschool="999" if hq1_all_aq9=="(m) Missing" & Country!="SWE"

***** Country specific exceptions to this rule:
**** 1) Sweden - choose (6) School, school board or committee
replace hq1_all_changesschool="1" if Country=="SWE"

******* Drop all OECD-only variables once mapping is done
drop hq1_all_aq1 hq1_all_aq2 hq1_all_aq3 hq1_all_aq4 hq1_all_aq5  hq1_all_aq7 hq1_all_aq8 hq1_all_aq9
*Step B.2. Disaggregations

******* Step C - Variable labeling *******

******* Step D - String to numerical (Yes, No, Select all that apply *******

foreach v of varlist hq1_all_schoolcentral hq1_all_schoolprovincial hq1_all_schoolsubreg hq1_all_schoollocal hq1_all_schoolschool hq1_all_adjustmentscentral hq1_all_adjustmentsprovincial hq1_all_adjustmentssubreg hq1_all_adjustmentslocal hq1_all_adjustmentsschool hq1_all_resourcescentral hq1_all_resourcesprovincial hq1_all_resourcessubreg hq1_all_resourceslocal hq1_all_resourcesschool hq1_all_addsupcentral hq1_all_addsupprovincial hq1_all_addsupsubreg hq1_all_addsuplocal hq1_all_addsupschool hq1_all_workingreqcentral hq1_all_workingreqprovincial hq1_all_workingreqsubreg hq1_all_workingreqlocal hq1_all_workingreqschool hq1_all_compensationcentral hq1_all_compensationprovincial hq1_all_compensationsubreg hq1_all_compensationlocal hq1_all_compensationschool hq1_all_hygienecentral hq1_all_hygieneprovincial hq1_all_hygienesubreg hq1_all_hygienelocal hq1_all_hygieneschool hq1_all_changescentral hq1_all_changesprovincial hq1_all_changessubreg hq1_all_changeslocal hq1_all_changesschool {
	destring `v', replace
}

*** This module has different structure between questionnaires and has already been addressed in other code - Step B.

******* Step E - Data cleaning *******
foreach var of varlist hq1_all_schoolcentral hq1_all_schoolprovincial hq1_all_schoolsubreg hq1_all_schoollocal hq1_all_schoolschool hq1_all_adjustmentscentral hq1_all_adjustmentsprovincial hq1_all_adjustmentssubreg hq1_all_adjustmentslocal hq1_all_adjustmentsschool hq1_all_resourcescentral hq1_all_resourcesprovincial hq1_all_resourcessubreg hq1_all_resourceslocal hq1_all_resourcesschool hq1_all_addsupcentral hq1_all_addsupprovincial hq1_all_addsupsubreg hq1_all_addsuplocal hq1_all_addsupschool hq1_all_workingreqcentral hq1_all_workingreqprovincial hq1_all_workingreqsubreg hq1_all_workingreqlocal hq1_all_workingreqschool hq1_all_compensationcentral hq1_all_compensationprovincial hq1_all_compensationsubreg hq1_all_compensationlocal hq1_all_compensationschool hq1_all_hygienecentral hq1_all_hygieneprovincial hq1_all_hygienesubreg hq1_all_hygienelocal hq1_all_hygieneschool hq1_all_changescentral hq1_all_changesprovincial hq1_all_changessubreg hq1_all_changeslocal hq1_all_changesschool {
	replace `var'=999 if Country=="BRA"
} 

label define hq1_value 						///
	0 "No"			///
	1 "Yes"						///
	999 "Missing"			///
	998 "Not applicable"	
	
label value hq1_all_schoolcentral hq1_all_schoolprovincial hq1_all_schoolsubreg hq1_all_schoollocal hq1_all_schoolschool hq1_all_adjustmentscentral hq1_all_adjustmentsprovincial hq1_all_adjustmentssubreg hq1_all_adjustmentslocal hq1_all_adjustmentsschool hq1_all_resourcescentral hq1_all_resourcesprovincial hq1_all_resourcessubreg hq1_all_resourceslocal hq1_all_resourcesschool hq1_all_addsupcentral hq1_all_addsupprovincial hq1_all_addsupsubreg hq1_all_addsuplocal hq1_all_addsupschool hq1_all_workingreqcentral hq1_all_workingreqprovincial hq1_all_workingreqsubreg hq1_all_workingreqlocal hq1_all_workingreqschool hq1_all_compensationcentral hq1_all_compensationprovincial hq1_all_compensationsubreg hq1_all_compensationlocal hq1_all_compensationschool hq1_all_hygienecentral hq1_all_hygieneprovincial hq1_all_hygienesubreg hq1_all_hygienelocal hq1_all_hygieneschool hq1_all_changescentral hq1_all_changesprovincial hq1_all_changessubreg hq1_all_changeslocal hq1_all_changesschool hq1_value


******* Step F - Open section to clean specific interested questions *******

*---------------------------------------------------------------------------
* Section 9. Equity Module
*---------------------------------------------------------------------------


******* Step A - Variable renaming/dropping

**** RENAMING

**** DROPPING

******* Step B - Structural conversions between OECD and UIS format
*Step B.1. "Select all that apply(SA)" v.s  "Select single(SS)"

*Step B.2. Disaggregations

******* Step C - Variable labeling *******

** Question 1
	foreach i in all {
		foreach j in follow {
				label var iq1_`i'_`j' "`i': `j'"				
		}
	}

** Question 1a
		foreach i in all {
		foreach j in distancelearnmod healthsafestandard mandatoryattend other planclosereopen {
				label var iq1a_`i'_`j' "`i': `j'"				
		}
	}
	
** Question 2
	foreach i in all {
		foreach j in follow {
				label var iq2_`i'_`j' "`i': `j'"				
		}
	}
	
** Question 2a
		foreach i in all {
		foreach j in distancelearnmod healthsafestandard mandatoryattend other planclosereopen {
				label var iq2a_`i'_`j' "`i': `j'"				
		}
	}
	
** Question 3
		foreach i in all {
		foreach j in addfinancechildren addfinanceethnic addfinancegirls addfinanceother addfinancerefugees flexiblechildren flexibleethnic flexiblegirls flexibleother flexiblerefugees nonechildren noneethnic nonegirls noneother nonerefugees otherchildren otherethnic othergirls otherother otherrefugees specialeffortchildren specialeffortethnic specialeffortgirls specialeffortother specialeffortrefugees subsdevicechildren subsdeviceethnic subsdevicegirls subsdeviceother subsdevicerefugees tailorlearnchildren tailorlearnethnic tailorlearngirls tailorlearnother tailorlearnrefugees {
				label var iq3_`i'_`j' "`i': `j'"				
		}
	}

** Question 4
 		foreach i in all {
		foreach j in comchildren comethnic comgirls comother comrefugees makemodchildren makemodethnic makemodgirls makemodother makemodrefugees nonechildren noneethnic nonegirls noneother nonerefugees otherchildren otherethnic othergirls otherother otherrefugees provofficialchildren provofficialethnic provofficialgirls provofficialother provofficialrefugee reviewingchildren reviewingethnic reviewinggirls reviewingother reviewingrefugees schoolbasedchildren schoolbasedethnic schoolbasedgirls schoolbasedother schoolbasedrefugees {
				label var iq4_`i'_`j' "`i': `j'"
		}
	}
	
	foreach var of varlist iq* {
	replace `var'="999" if Country=="BRA"
}

******* Step D - String to numerical (Yes, No, Select all that apply *******
**** Question 1 - Do government-dependent private schools (ISCED 0 to ISCED 3) follow the same COVID regulations as public schools?
foreach var of varlist iq1_all_follow {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="1" if `var'=="Yes"	
		replace `var'="0" if `var'=="No"
		destring `var', replace
}

**** Question 1a - If the answer is ‘no’ to Q1, in what aspect(s) do the regulations apply equally? 
foreach var of varlist iq1a_all_distancelearnmod iq1a_all_healthsafestandard iq1a_all_mandatoryattend iq1a_all_other iq1a_all_planclosereopen {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"		
		replace `var'="1" if `var'=="Yes"	
		replace `var'="0" if `var'=="No"
		destring `var', replace
}

**** Question 2 - Do independent private schools (ISCED 0 to ISCED 3) follow the same COVID regulations as public schools?
foreach var of varlist iq2_all_follow {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="1" if `var'=="Yes"	
		replace `var'="0" if `var'=="No"
		destring `var', replace
}
**** Question 2a - If the answer is ‘no’ to Q2, in what aspect(s) do the regulations apply equally? 
foreach var of varlist iq2a_all_distancelearnmod iq2a_all_healthsafestandard iq2a_all_mandatoryattend iq2a_all_other iq2a_all_planclosereopen {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"	
		replace `var'="1" if `var'=="Yes"	
		replace `var'="0" if `var'=="No"
		destring `var', replace
}

**** Question 3 - Which of the following measures have been taken to support the education (ISCED 0 to ISCED 3) of vulnerable groups during the pandemic?
foreach var of varlist iq3_all_addfinancechildren iq3_all_addfinanceethnic iq3_all_addfinancegirls iq3_all_addfinanceother iq3_all_addfinancerefugees iq3_all_flexiblechildren iq3_all_flexibleethnic iq3_all_flexiblegirls iq3_all_flexibleother iq3_all_flexiblerefugees iq3_all_nonechildren iq3_all_noneethnic iq3_all_nonegirls iq3_all_noneother iq3_all_nonerefugees iq3_all_otherchildren iq3_all_otherethnic iq3_all_othergirls iq3_all_otherother iq3_all_otherrefugees iq3_all_specialeffortchildren iq3_all_specialeffortethnic iq3_all_specialeffortgirls iq3_all_specialeffortother iq3_all_specialeffortrefugees iq3_all_subsdevicechildren iq3_all_subsdeviceethnic iq3_all_subsdevicegirls iq3_all_subsdeviceother iq3_all_subsdevicerefugees iq3_all_tailorlearnchildren iq3_all_tailorlearnethnic iq3_all_tailorlearngirls iq3_all_tailorlearnother iq3_all_tailorlearnrefugees {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"		
		replace `var'="1" if `var'=="Yes"	
		replace `var'="0" if `var'=="No"
		destring `var', replace
}

**** Question 4 - What outreach / support measures have been taken to encourage the return to school (ISCED 0 to ISCED 3) for vulnerable populations? 
foreach var of varlist iq4_all_comchildren iq4_all_comethnic iq4_all_comgirls iq4_all_comother iq4_all_comrefugees iq4_all_makemodchildren iq4_all_makemodethnic iq4_all_makemodgirls iq4_all_makemodother iq4_all_makemodrefugees iq4_all_nonechildren iq4_all_noneethnic iq4_all_nonegirls iq4_all_noneother iq4_all_nonerefugees iq4_all_otherchildren iq4_all_otherethnic iq4_all_othergirls iq4_all_otherother iq4_all_otherrefugees iq4_all_provofficialchildren iq4_all_provofficialethnic iq4_all_provofficialgirls iq4_all_provofficialother iq4_all_provofficialrefugee iq4_all_reviewingchildren iq4_all_reviewingethnic iq4_all_reviewinggirls iq4_all_reviewingother iq4_all_reviewingrefugees iq4_all_schoolbasedchildren iq4_all_schoolbasedethnic iq4_all_schoolbasedgirls iq4_all_schoolbasedother iq4_all_schoolbasedrefugees {
		replace `var'="997" if `var'=="Do not know (m)"
		replace `var'="999" if `var'=="Include in another column (xc)"
		replace `var'="998" if `var'=="Not applicable (a)"		
		replace `var'="1" if `var'=="Yes"	
		replace `var'="0" if `var'=="No"
		destring `var', replace
}


******* Step E - Data cleaning *******

	label define iq_values 0 "No" 1 "Yes" 999 "Missing" 998 "Not applicable" 997 "Do not know" 
	*Q1
	label value iq1_all_follow iq1a_all_distancelearnmod iq1a_all_healthsafestandard iq1a_all_mandatoryattend iq1a_all_other iq1a_all_planclosereopen iq_values
	*Q2
	label value iq2_all_follow iq2a_all_distancelearnmod iq2a_all_healthsafestandard iq2a_all_mandatoryattend iq2a_all_other iq2a_all_planclosereopen iq_values
	*Q3
	label value iq3_all_addfinancechildren iq3_all_addfinanceethnic iq3_all_addfinancegirls iq3_all_addfinanceother iq3_all_addfinancerefugees iq3_all_flexiblechildren iq3_all_flexibleethnic iq3_all_flexiblegirls iq3_all_flexibleother iq3_all_flexiblerefugees iq3_all_nonechildren iq3_all_noneethnic iq3_all_nonegirls iq3_all_noneother iq3_all_nonerefugees iq3_all_otherchildren iq3_all_otherethnic iq3_all_othergirls iq3_all_otherother iq3_all_otherrefugees iq3_all_specialeffortchildren iq3_all_specialeffortethnic iq3_all_specialeffortgirls iq3_all_specialeffortother iq3_all_specialeffortrefugees iq3_all_subsdevicechildren iq3_all_subsdeviceethnic iq3_all_subsdevicegirls iq3_all_subsdeviceother iq3_all_subsdevicerefugees iq3_all_tailorlearnchildren iq3_all_tailorlearnethnic iq3_all_tailorlearngirls iq3_all_tailorlearnother iq3_all_tailorlearnrefugees iq_values
	*Q4
	label value iq4_all_comchildren iq4_all_comethnic iq4_all_comgirls iq4_all_comother iq4_all_comrefugees iq4_all_makemodchildren iq4_all_makemodethnic iq4_all_makemodgirls iq4_all_makemodother iq4_all_makemodrefugees iq4_all_nonechildren iq4_all_noneethnic iq4_all_nonegirls iq4_all_noneother iq4_all_nonerefugees iq4_all_otherchildren iq4_all_otherethnic iq4_all_othergirls iq4_all_otherother iq4_all_otherrefugees iq4_all_provofficialchildren iq4_all_provofficialethnic iq4_all_provofficialgirls iq4_all_provofficialother iq4_all_provofficialrefugee iq4_all_reviewingchildren iq4_all_reviewingethnic iq4_all_reviewinggirls iq4_all_reviewingother iq4_all_reviewingrefugees iq4_all_schoolbasedchildren iq4_all_schoolbasedethnic iq4_all_schoolbasedgirls iq4_all_schoolbasedother iq4_all_schoolbasedrefugees iq_values
******* Step F - Open section to clean specific interested questions *******

*---------------------------------------------------------------------------
* Section 11. Health Protocol/Guidelines for Prevention and Control of COVID-19
*---------------------------------------------------------------------------

*---------------------------------------------------------------------------
* Section 12. 2021 Planning
*---------------------------------------------------------------------------


*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
* 2) Export Data (Do Not Edit these lines)
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------

save "${Data_clean}jsw3_oecd_clean.dta", replace

export excel "${Data_clean}jsw3_oecd_clean.xlsx", firstrow(variables) replace
