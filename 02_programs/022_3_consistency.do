*=========================================================================*
* Project information at: https://github.com/worldbank/schoolsurvey-production
****** Country: Worldwide
****** Purpose: Cleaning of the UNESCO-UNICEF-WBG_OECD Survey on National education responses to COVID-19 - Round 3
****** Created by: UNESCO-UNICEF-WBG_OECD
****** Used by: UNESCO-UNICEF-WBG_OECD
****** Input  data : jsw3_oecd_clean.dta           
****** Output data: jsw3_oecd_clean_for_append.dta
****** Language: English
*=========================================================================*

** In this do file: 
* This do file creates a new OECD cleaned dataset that matches UIS cleaning conventions before appending the two datasets. 
* It also adds a “Source” variable that lists all responses as OECD. 
* This step should be run after 022_1_clean_uis.do and 022_2_clean_oecd.do
** THIS DO IS ORGANIZED ACCORDING TO SECTIONS OF THE QUESTIONNAIRE

** Steps in this do-file:
* 0) Import the raw .dta for UIS
* 1) Before merge: Select the variables to merge and Check the consistency (Applying to the same cleaning code with UIS if neccesary)
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
*=========================================================================*

*---------------------------------------------------------------------------
* 0) Import Data (Do Not Edit these lines)
*---------------------------------------------------------------------------
												
use "${Data_clean}jsw3_oecd_clean.dta", clear
rename Country countrycode

keep countrycode cq1* eq1* eq5* gq* hq*   eq3* eq2_* eq4_* eq6_* iq4* aq1* aq3* aq4* aq6* bq2_all_regulation bq1_1_* fq3_* eq3* fq1* fq3* dq1* dq3a* iq* 

*---------------------------------------------------------------------------
* 1) Select the variables to merge and Check the consistency
*---------------------------------------------------------------------------

* ALL QUESTIONNAIRE SECTIONS                 
*---------------------------------------------------------------------------
* Section 1. School Closures
*---------------------------------------------------------------------------

*---------------------------------------------------------------------------
* Section 2. School Calendar and Curricula
*---------------------------------------------------------------------------

*---------------------------------------------------------------------------
* Section 3. School Reopening Management
*---------------------------------------------------------------------------

*S3/cq1/CQ1. What measures to address learning gaps were widely implemented when schools reopened after the first/second/third closure in 2020? 
foreach i in pp p ls us {
	foreach j in assessment remedial1 remedial2 remedial3 remedial4 remedial5 remedial6 remedial7 remedial8 other none donotknow {
		replace cq1_`i'_`j' =. if cq1_`i'_`j' == 997
		replace cq1_`i'_`j' =. if cq1_`i'_`j' == 998
		replace cq1_`i'_`j' =. if cq1_`i'_`j' == 999
	}
}

*---------------------------------------------------------------------------
* Section 4. Distance Education Delivery Systems (including additional questions in S10)
*---------------------------------------------------------------------------

*---------------------------------------------------------------------------
* Section 5. Teachers and Educational Personnel
*---------------------------------------------------------------------------

*S5/eq1/Q1:
		replace eq1_all_percentage = 5 if eq1_all_percentage == 2 // changing OECD value label of "More than 75% but not all of the teachers" to match UIS
		replace eq1_all_percentage = 6 if eq1_all_percentage == 1 // changing OECD value label of "All of the teachers" to match UIS

*S5/eq3/Q5 (Q7 in OECD): What kind of interactions were encouraged by government between teachers and their students and/or their parents during school closures in 2020 (in pre-primary to upper secondary levels combined)?	// changing value labels to match UIS

rename eq5_all_holdingregularconversat eq5_all_holdingregularconversati // one character difference in variable names

*---------------------------------------------------------------------------
* Section 6. Learning Assessments and Examinations
*---------------------------------------------------------------------------

*---------------------------------------------------------------------------
* Section 7. Financing
*---------------------------------------------------------------------------
** gq1_all: added 28th May to OECD data, no longer need to create artificial variable with "999" here
					
** gq1: combining "No changes at all (i.e total and distribution of expenditures)"	with  "No changes"
foreach var of varlist gq1_all_2020 gq1_all_2021 gq1_ls_2020 gq1_ls_2021 gq1_p_2020 gq1_p_2021 gq1_pp_2020 gq1_pp_2021 gq1_us_2020 gq1_us_2021 {
	replace `var' = 2 if `var'==6
}

** gq2
foreach var of varlist gq2_all_fy2020compofothe gq2_all_fy2020compofteac gq2_all_fy2020condcashtra gq2_all_fy2020othercurrentexp gq2_all_fy2020schoolsmeals gq2_all_fy2020studentloans gq2_all_fy2020studentsuppgra gq2_all_fy2020totalcapitalexp gq2_all_fy2020totalcurrentexp gq2_all_fy2021totalcurrentexp gq2_all_fy2021compofothe gq2_all_fy2021compofteac gq2_all_fy2021condcashtra gq2_all_fy2021othercurrentexp gq2_all_fy2021schoolsmeals gq2_all_fy2021studentloans gq2_all_fy2021studentsuppgra gq2_all_fy2021totalcapitalexp {
	replace `var' = 2 if `var'==6
}

** gq2a
gen gq2a_all_donotknow = 0
* logic patch: if NA but an option is chosen in gq2a (eg. EST)
local gq2a "gq2a_all_addfundingfromex gq2a_all_reprogofprevious gq2a_all_addallocationfro gq2a_all_reallocwithintheed"
foreach v of local gq2a{
	replace `v' =998 if (gq2_all_fy2020totalcapitalexp!=1 & gq2_all_fy2020totalcurrentexp!=1 & gq2_all_fy2020compofteac!=1 & gq2_all_fy2020compofothe!=1 & gq2_all_fy2020schoolsmeals!=1 & gq2_all_fy2020condcashtra!=1 & gq2_all_fy2020studentsuppgra!=1 & gq2_all_fy2020studentloans!=1 & gq2_all_fy2020othercurrentexp!=1 & gq2_all_fy2021totalcapitalexp!=1 & gq2_all_fy2021totalcurrentexp!=1 & gq2_all_fy2021compofteac!=1 & gq2_all_fy2021compofothe!=1 & gq2_all_fy2021schoolsmeals!=1 & gq2_all_fy2021condcashtra!=1 & gq2_all_fy2021studentsuppgra!=1 & gq2_all_fy2021studentloans!=1 & gq2_all_fy2021othercurrentexp!=1)
	replace `v' =0 if `v' ==998 & (gq2_all_fy2020totalcapitalexp==1 | gq2_all_fy2020totalcurrentexp==1 | gq2_all_fy2020compofteac==1 | gq2_all_fy2020compofothe==1 | gq2_all_fy2020schoolsmeals==1 | gq2_all_fy2020condcashtra==1 | gq2_all_fy2020studentsuppgra==1 | gq2_all_fy2020studentloans==1 | gq2_all_fy2020othercurrentexp==1 | gq2_all_fy2021totalcapitalexp==1 | gq2_all_fy2021totalcurrentexp==1 | gq2_all_fy2021compofteac==1 | gq2_all_fy2021compofothe==1 | gq2_all_fy2021schoolsmeals==1 | gq2_all_fy2021condcashtra==1 | gq2_all_fy2021studentsuppgra==1 | gq2_all_fy2021studentloans==1 | gq2_all_fy2021othercurrentexp==1)
}

*---------------------------------------------------------------------------
* Section 8. Locus of Decision Making
*---------------------------------------------------------------------------

*---------------------------------------------------------------------------
* Section 9. Equity Module
*---------------------------------------------------------------------------


*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
* 2) Export Data (Do Not Edit these lines)
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------

gen Source=2
save "${Data_clean}/jsw3_oecd_clean_for_append.dta", replace

