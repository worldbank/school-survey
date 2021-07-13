*=========================================================================* 
* Project information at: https://github.com/worldbank/schoolsurvey-production
****** Country: Worldwide
****** Purpose: producing figures for report 2 - UNESCO-UNICEF-WBG_OECD Survey on National education responses to COVID-19 - Round 3
****** Created by: UNESCO, UNICEF, WORLD BANK, OECD
****** Used by: UNESCO, UNICEF, WORLD BANK, OECD
****** Input data : jsw3_uis_oecd_clean.dta             
****** Output data : sheets in TEMPLATE.xlsx, tables_for_figures_original_JSW3.xlsx
****** Language: English
*=========================================================================*
** In this do file: 
* This do file exports question-level output to individual sheets in a template excel file of the report figures. 
* The template in the excel is pre-configured and this do file populates the numbers in each sheet. 
* The script divides question sections by the report’s chapters and only includes variables that were made to graphs in the final report. 
* The sheet names correspond to figure titles in the report. Each question is also appended to the annex table which includes the number of country responded by income group and % of population coverage. 

** Steps in this do-file:
* 0) Import data
* 1) Figure production
* 2) ANNEX: country sample, and population and enrolment coverage

*THIS DO FILE IS ORGANIZED BY THE REPORT SECTIONS:
*Section 1: Learning Loss School closures & School calendar and curricula 
*Section 2: Learning assessment and examinations
*Section 3: Distance education delivery systems
*Section 4: Teachers and educational personnel
*Section 5: School reopening management
*Section 6: Financing 
*Section 7: Locus of decision making of public institutions

*** Steps for each figure production:
* Step 0 - Import data
* Step A - Define locals and adjust aggregation levels as needed for analysis
* Step B - Create collapsed table that will go into excel
* Step C - Beautify table

*=========================================================================*


*---------------------------------------------------------------------------
* 0) Import Data (Do Not Edit these lines)
*---------------------------------------------------------------------------

* Copy the Template Excel file (which has just the index and blank graphs)
* then copy ranges from which graphs draw one by one
global template   "${Table}TEMPLATE.xlsx"
global excelfile  "${Table}tables_for_figures_original_JSW3.xlsx"
copy `"${template}"' `"${excelfile}"', replace

* Save to avoid repeating this options that are always used when exporting to excel
global excelopt   "firstrow(varlabels) cell(A3)"

* Saves empty file where N countries and population coverage will be appended
* for every questions used to create a table or figure (for Annex)
clear
save "${Table}/annex1.dta", replace emptyok
save "${Table}/annex2.dta", replace emptyok

global annex_var  enrollment population_0417 income_num

*-----------------------------------------------------------------------------
* Short auxiliary programs to avoid repeating lines many times
*-----------------------------------------------------------------------------
{
* After creating a table, add info on country and population coverage to Annex1
cap program drop add_to_annex1
program define   add_to_annex1
  syntax, figure_number(string) question_number(string)
  keep N income_num population_0417 enrollment 
  label define income_numl 1 "Low income" 2 "Lower middle income" 3 "Upper middle income" 4 "High income" 5 "Global" ///
  6 "Low income(pp)" 7 "Low income(p)" 8 "Low income(ls)" 9 "Low income(us)" 10 "Lower middle(pp)" 11 "Lower middle(p)" ///
  12 "Lower middle(ls)" 13 "Lower middle(us)" 14 "Upper middle(pp)" 15 "Upper middle(p)" 16 "Upper middle(ls)" 17 "Upper middle(us)" ///
  18 "High income(pp)" 19 "High income(p)" 20 "High income(ls)" 21 "High income(us)" 22 "Global(pp)" 23 "Global(p)" 24 "Global(ls)" 25 "Global(us)", modify
  label value income_num income_numl
  duplicates drop
  gen  figure_number   = "`figure_number'"
  gen  question_number = "`question_number'"
  append using "${Table}/annex1.dta"
  save "${Table}/annex1.dta", replace
end


* After creating a table, add info on country and population coverage to Annex2
cap program drop add_to_annex2
program define   add_to_annex2
  syntax, figure_number(string) question_number(string)
  keep income_num N_* 
  label define income_numl 1 "Low income" 2 "Lower middle income" 3 "Upper middle income" 4 "High income" 5 "Global", modify
  label value income_num income_numl
  duplicates drop
  gen  figure_number   = "`figure_number'"
  gen  question_number = "`question_number'"
  append using "${Table}/annex2.dta"
  save "${Table}/annex2.dta", replace
end

* Concatenate label (incomelevel and N)
cap program drop concatenate_label_income_N
program define   concatenate_label_income_N

replace incomelevelname="4.High income"  if incomelevelname=="High income"
replace incomelevelname="3.Upper middle" if incomelevelname=="Upper middle income"
replace incomelevelname="2.Lower middle" if incomelevelname=="Lower middle income"
replace incomelevelname="1.Low income"   if incomelevelname=="Low income"

  gen   concat_label = incomelevelname + " (N=" + strofreal(N) + ")"
  order concat_label
  label var concat_label  "Label"
end

* Opens clean dataset, by default the one combining both rounds
* but can open round2only if specified
cap program drop start_from_clean_file
program define   start_from_clean_file

 * syntax , [round2only]

  * Open clean file
  use "${Data_clean}jsw3_uis_oecd_clean.dta", clear

  * Expand dataset prior to collapse so that Global becomes a category
  expand 2, gen(expanded)
  replace income_num = 5              if expanded == 1
  replace incomelevelname  = "Global" if expanded == 1

  * Will become a country counter if no observation was missing
 // replace N = 1   if // should be adjusted/replaced accordingly later
  

end
}

*---------------------------------------------------------------------------
* 1) Figure Production 
*---------------------------------------------------------------------------

* ALL REPORT SECTIONS
*---------------------------------------------------------------------------
* Section 1. School Closures
*---------------------------------------------------------------------------

**S1/Q6/aq6: Q6. Total instruction days lost from Jan 2020 - Dec 2020?

	// without grade level aggregations 
	start_from_clean_file

  local figure    "Figure 1-1" // Figure number
  *local figure    "F1.1a" // Figure number
  local fig_q     "AQ6"   // List all questions used
  *local fig_q     "AQ6a"   // List all questions used

//	drop if q_consent == ""
	
  keep  aq6_*_total countrycode income_num N incomelevelname population_0417 enrollment
		
		local variables aq6_pp_total aq6_p_total aq6_ls_total aq6_us_total
	 
	 foreach v in `variables' {
	 	replace `v' = . if `v' == 997 | `v' == 998 | `v' == 999 
	 }
	 
	 missings dropobs `variables', force

	// further collapse for annex1
 	collapse (mean) aq6_pp_total aq6_p_total aq6_ls_total aq6_us_total (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
	
	 concatenate_label_income_N
	
  label var aq6_pp_total "PrePrimary"
  label var aq6_p_total "Primary"
  label var aq6_ls_total  "Lower Secondary"
  label var aq6_us_total "Upper Secondary"
	
  *C Beautify table
  format `variables' %3.0f
	foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
 
  * Create sheet in excel file for this table
  export excel concat_label aq6_pp_total aq6_p_total aq6_ls_total aq6_us_total using `"${excelfile}"', sheet("`figure'", modify) firstrow(varlabels) cell(A3)

  * Add country and population coverage to Annex1
  add_to_annex1, figure_number(`figure') question_number(`fig_q')
  

*********************************************************************
**S1/Q6/aq6: Q6. Total instruction days lost from Jan 2020 - Dec 2020? (Upper School Only)

********	Step A - Define locals and adjust aggregation levels as needed for analysis
start_from_clean_file

  local figure    "Figure 1-2" // Figure number
 * local figure    "F1.1b" // Figure number
  local fig_q     "AQ6"   // List all questions used
	
//	drop if q_consent == ""
	
  keep  aq6_us_total countrycode income_num N incomelevelname population_0417 enrollment hd_hci* 
	
	 local variables aq6_us_total
	 
	 foreach v in `variables' {
	 	replace `v' = . if `v' == 997 | `v' == 998 | `v' == 999 
	 }

* Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
	duplicates drop countrycode, force
		
	drop if hd_hci_hlos == .		
	drop if income_num == 5
	
	label var aq6_us_total "Upper School"
	label var income_num "Income Level"
	label var hd_hci_hlos "HLO"
	
 //put in chart excel
	export excel countrycode aq6_us_total incomelevelname hd_hci_hlos using `"${excelfile}"', sheet("`figure'", modify) firstrow(varlabels) cell(A2)
  
  
*********************************************************************
**S1/Q1/aq1: What is the status of schooling as of Feb 2021?

********	Step A - Define locals and adjust aggregation levels as needed for analysis
start_from_clean_file 
  
  local figure    "Figure 1-3a" // Figure number
 * local figure    "F1.2a" // Figure number
  local fig_q     "AQ1"   // List all questions used
  *local fig_q     "AQ1a"   // List all questions used
  
keep  aq1_* countrycode income_num N incomelevelname population_0417 enrollment
drop *_specify
drop aq1_pp*

// convert all to "Yes only" format
foreach i in p ls us {
	foreach j in open1 open2 open3 open4 open5 open6 open7 fullyopen closed1 closed2 closed3 {
	replace aq1_`i'_`j' = 0 if aq1_`i'_`j' == . 
	}
}

foreach i in p ls us {
	
		// aggregate partially closed
		gen aq1_`i'_partial = aq1_`i'_open1 + aq1_`i'_open2 + aq1_`i'_open3 + aq1_`i'_open4 + aq1_`i'_open5 + aq1_`i'_open6 + aq1_`i'_open7
		replace aq1_`i'_partial = 1 if aq1_`i'_partial > 1
		replace aq1_`i'_partial = 0 if aq1_`i'_partial == .
		
		// aggregate breaks
		gen aq1_`i'_breaks = aq1_`i'_closed1 + aq1_`i'_closed2
		replace aq1_`i'_breaks = 1 if aq1_`i'_breaks > 1
		replace aq1_`i'_breaks = 0 if aq1_`i'_breaks == .

		
		// drop original options that's now been aggregated
		drop aq1_`i'_closed1 aq1_`i'_closed2 aq1_`i'_open* 
	}

		// if all options are 0, make missing.
	foreach i in p ls us {
		foreach j in partial closed3 fullyopen breaks other {
				replace aq1_`i'_`j' = 0 if aq1_`i'_`j' == .				
					replace aq1_`i'_`j' = . if aq1_`i'_partial == 0 & aq1_`i'_fullyopen == 0 & aq1_`i'_closed3 == 0 & aq1_`i'_breaks == 0 & aq1_`i'_other == 0
		}
	}
	
	 // aggregate grades p ls and us
		foreach j in partial closed3 fullyopen breaks other {			
			gen all_`j' = aq1_p_`j' + aq1_ls_`j' + aq1_us_`j'
			
		// make conditional 100 if all grades said yes 
		replace all_`j' = 0 if all_`j' != 3 & all_`j' != .
		replace all_`j' = 100 if all_`j' != 0 & all_`j' != .
		}


  local variables all_closed3 all_fullyopen all_breaks all_partial

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  
		label var all_partial   "Partially Open"
    label var all_breaks   "Closed for Break"
    label var all_fullyopen   "Fully Open"
    label var all_closed3		"Fully closed due to COVID"
 
  * Beautify table
  format `variables' %3.0f
	
	foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
	
	// only keep fully closed as an option 
	drop *_breaks *_fullyopen *_partial 
	
  * Create sheet in excel file for this table
  export excel concat_label all_closed3 using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex1
  add_to_annex1, figure_number(`figure') question_number(`fig_q')
	
*********************************************************************  
	**** Aggregate by Grade
	** Includes pre primary
	// Q1 By Grade
	start_from_clean_file 

   local figure    "Figure 1-3b" // Figure number
   *local figure    "F1.2b" // Figure number
   local fig_q     "AQ1"   // List all questions used
   *local fig_q     "AQ1b"   // List all questions used
  
keep  aq1_* countrycode income_num N incomelevelname population_0417 enrollment
drop *_specify

foreach i in pp p ls us {
	
		// aggregate partially closed
		gen aq1_`i'_partial = aq1_`i'_open1 + aq1_`i'_open2 + aq1_`i'_open3 + aq1_`i'_open4 + aq1_`i'_open5 + aq1_`i'_open6 + aq1_`i'_open7
		replace aq1_`i'_partial = 1 if aq1_`i'_partial > 1
		replace aq1_`i'_partial = 0 if aq1_`i'_partial == .
		
		// aggregate breaks
		gen aq1_`i'_breaks = aq1_`i'_closed1 + aq1_`i'_closed2
		replace aq1_`i'_breaks = 1 if aq1_`i'_breaks > 1
		replace aq1_`i'_breaks = 0 if aq1_`i'_breaks == .
		
		// drop original options that's now been aggregated
		drop aq1_`i'_closed1 aq1_`i'_closed2 aq1_`i'_open* 
	}
	 
		// make all missing to 0 to follow yes only format
		foreach i in pp p ls us {
			foreach j in partial closed3 fullyopen breaks other {
					replace aq1_`i'_`j' = 0 if aq1_`i'_`j' == .
					// if all options are 0, make missing.
					replace aq1_`i'_`j' = . if aq1_`i'_partial == 0 & aq1_`i'_fullyopen == 0 & aq1_`i'_closed3 == 0 & aq1_`i'_breaks == 0 & aq1_`i'_other == 0
			}
		}

	keep countrycode incomelevelname income_num enrollment population_0417 *_closed3 N
	
	collapse (mean) aq1_pp_closed3 aq1_p_closed3 aq1_ls_closed3 aq1_us_closed3 (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
	
	 concatenate_label_income_N
	 
	 foreach v in aq1_pp_closed3 aq1_p_closed3 aq1_ls_closed3 aq1_us_closed3 {
	   replace `v' = 100*`v'
	 }
	
	// Beautify Tables
	foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
	 
	label var aq1_pp_closed3   "PrePrimary"	
	label var aq1_p_closed3   "Primary"
  label var aq1_ls_closed3   "Lower Secondary"
  label var aq1_us_closed3   "Upper Secondary"

 // add it to existing excel
	export excel concat_label aq1_p_closed3 aq1_ls_closed3 aq1_us_closed3 using `"${excelfile}"', sheet("`figure'") cell(A3) sheetmodify keepcellfmt firstrow(varlabels)
  
  
********************************************************************
** S6/Q2/fq2 Have there been any steps taken to assess whether there have been learning losses as a result of COVID related school closure in 2020?
********	Step A - Define locals and adjust aggregation levels as needed for analysis
start_from_clean_file

  local figure    "Figure 1-4" // Figure number
  *local figure    "F1.3" // Figure number
  local fig_q     "FQ2"   // List all questions used

  keep  fq3_* countrycode income_num N incomelevelname  population_0417 enrollment
	drop *_2020

	// only looking at "if they did do something"
  local variables fq3_p_classroom fq3_p_standard fq3_ls_classroom fq3_ls_standard fq3_ls_noplan fq3_p_noplan 
	
	missings dropobs `variables', force

  foreach i of local variables {
  replace   `i' =. if `i' ==997 | `i' == 998 | `i' == 999
  replace   `i' =`i'*100
  }
	
	// if at least 1 grade said yes, count it
 	foreach j in classroom standard {			
 			gen all_`j' = fq3_p_`j' + fq3_ls_`j'
 			replace all_`j' = 100 if all_`j' > 100
 		}
		
	// for NO PLAN: count if both grades said yes
 		gen all_noplan = fq3_p_noplan + fq3_ls_noplan
		replace all_noplan = 0 if all_noplan == 100
 		replace all_noplan = 100 if all_noplan > 100
 		
  local variables fq3_p_classroom fq3_p_standard fq3_ls_classroom fq3_ls_standard all_classroom all_standard all_noplan
		
  *B Create the collapsed table that will go into the Excel
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  
	label var fq3_p_classroom "Assessed at Classroom Primary"
	label var fq3_ls_classroom "Assessed at Classroom Lower Secondary"
	label var fq3_ls_standard "Standard Assessments Lower Secondary"
	label var fq3_p_standard "Standard Assessments Primary"
  label var all_classroom "Formative assessments by teachers"
  label var all_standard	"Standardized assessments at the national or sub-national level"
 
  *C Beautify table
  format `variables' %3.0f
	foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
  
  * Create sheet in excel file for this table
  export excel concat_label  all_classroom all_standard using `"${excelfile}"', sheet("`figure'", modify) $excelopt

	* annex1
	add_to_annex1, figure_number(`figure') question_number(`fig_q') 
	

*********************************************************************
*S2/Q1/bq1_1: Q1-1. Have/will adjustments been/be made to the school calendar dates and curriculum due to COVID-19 in the school year 2019/2020 (2020 for countries with the calendar year)? 

  local figure    "Figure 1-5" // Figure number
 * local figure    "F1.4" // Figure number
  local fig_q     "BQ1"   // List all questions used
	
	start_from_clean_file 
	
	keep bq1_1* countrycode income_num N incomelevelname population_0417 enrollment
	drop *miss

  local variables bq1_1_pp_academicyearextended bq1_1_pp_prioritizationofcerta bq1_1_pp_depends bq1_1_pp_otheradj bq1_1_pp_no bq1_1_pp_other bq1_1_p_academicyearextended bq1_1_p_prioritizationofcerta bq1_1_p_depends bq1_1_p_otheradj bq1_1_p_no bq1_1_p_other bq1_1_ls_academicyearextended bq1_1_ls_prioritizationofcerta bq1_1_ls_depends bq1_1_ls_otheradj bq1_1_ls_no bq1_1_ls_other bq1_1_us_academicyearextended bq1_1_us_prioritizationofcerta bq1_1_us_depends bq1_1_us_otheradj bq1_1_us_no bq1_1_us_other
  
  foreach i of local variables {
  replace   `i' =. if `i' ==997 | `i' == 998 | `i' == 999
  replace   `i' =`i'*100
  }
	
		// aggregate the other options
	foreach i in pp p ls us {
		gen bq1_1_`i'_others = bq1_1_`i'_other + bq1_1_`i'_otheradj
		replace bq1_1_`i'_others = 100 if bq1_1_`i'_others >= 100
	}
	drop bq1_1*_other bq1_1*_otheradj
	
	foreach j in prioritizationofcerta depends others academicyearextended no {			
			gen all_`j' = bq1_1_p_`j' + bq1_1_ls_`j' + bq1_1_us_`j' + bq1_1_pp_`j'
			replace all_`j' = 100 if all_`j' > 0
		}
		
		local variables all_prioritizationofcerta all_depends all_others all_academicyearextended all_no
		
  *B Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  
  label var all_prioritizationofcerta "Prioritize Certain Skills or Areas of the Curriculum"
  label var all_depends "Schools/Districts/the most local level of governance could decide at their own discretion"
  label var all_others "Other"
  label var all_academicyearextended "Academic Year extended"
  label var all_no "No"
 
  *C Beautify table
  format `variables' %3.0f
	foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
	
		local variables all_prioritizationofcerta all_depends all_academicyearextended
  
  * Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt
  
*---------------------------------------------------------------------------
* Section 2. Learning Assessments and Examinations
*---------------------------------------------------------------------------
********************************************************************
*S6/fq1/Q1. Have you made any of the following changes to national examinations due to the pandemic during the school year 2019/2020 2020 for countries with calendar year)? (Select all that apply)

  local figure    "Figure 2-1" // Figure number
  *local figure    "F2.1" // Figure number
  local fig_q     "FQ1"   // List all questions used
	*local fig_q     "FQ1_A"   // List all questions used
  
	start_from_clean_file 
	
	keep fq1_* countrycode income_num N incomelevelname population_0417 enrollment
	tempfile table1 table2 table3
		
	 *****Cleaning for education level: In each variable if country selected misisng or don't know, change it to missing
   foreach i in p ls us {
	 /*do not know is  "." for all countries*/
	foreach j in postponed adjustedthecontent adjustedthemode introducedaddh introducedaltass canceledexams other nochangesweremade notapplicable {
		replace fq1_`i'_2020`j' =. if fq1_`i'_2020`j' ==997| fq1_`i'_2020`j' ==999|fq1_`i'_2020`j' ==998
	}
}
 
 ******If a country responded 'not applicable' for a level, it should be missing 
 foreach i in p ls us {
	 /*do not know is  "." for all countries*/
	foreach j in postponed adjustedthecontent adjustedthemode introducedaddh introducedaltass canceledexams other nochangesweremade {
		replace fq1_`i'_2020`j' =. if fq1_`i'_2020notapplicable==1
	}
}

	 ****Generating variable to count for number of changes countries introduced to national examinations
foreach i in p ls us {
gen sum_`i'=.
 replace sum_`i'= fq1_`i'_2020postponed + fq1_`i'_2020adjustedthecontent + fq1_`i'_2020adjustedthemode +fq1_`i'_2020introducedaddh + fq1_`i'_2020introducedaltass + fq1_`i'_2020canceledexams + fq1_`i'_2020other
 replace sum_`i'=2 if sum_`i'>=2&sum_`i'<=6
 replace sum_`i'=. if sum_`i'>7
 replace sum_p=2 if countrycode=="LVA" /*Manually change for LVA, LVA introduced two changes in primary but the code above does not catch it*/
 label var sum_`i' "`i': Number of changes"
 }

 ****Changing it to dummy variable to calculate means
 foreach i in p ls us {
 gen no_change_`i'=0 if sum_`i'!=.
 replace no_change_`i'=1 if sum_`i'==0 
 gen one_change_`i'=0 if sum_`i'!=.
 replace one_change_`i'=1 if sum_`i'==1
 gen two_plus_change_`i'=0 if sum_`i'!=.
 replace two_plus_change_`i'=1 if sum_`i'==2
 *gen N_`i'= 1 if sum_`i'!=.
 label var no_change_`i' "No change"
 label var one_change_`i' "One change"
 label var two_plus_change_`i' "Two or more changes"
 }
 
****
*Primary Changes
*
****
preserve
  local variables no_change_p one_change_p two_plus_change_p
  
  foreach i of local variables {
  replace   `i' =`i'*100
  }
		
  *B Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  keep if income_num==5
  gen level= "Primary" + " (N=" + strofreal(N) + ")"
  rename no_change_p no_change
  rename one_change_p one_change
  rename two_plus_change_p two_plus_change
  save `table1', replace
 restore
 
****
*Lower secondary Changes
*
****  
preserve
  local variables no_change_ls one_change_ls two_plus_change_ls 
  
  foreach i of local variables {
  replace   `i' =`i'*100
  }
		
  *B Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  keep if income_num==5
  gen level= "Lower secondary"+ " (N=" + strofreal(N) + ")"
  rename no_change_ls no_change
  rename one_change_ls one_change
  rename two_plus_change_ls two_plus_change
  save `table2', replace
 restore
 
****
*Upper secondary Changes
*
****  
preserve
  local variables no_change_us one_change_us two_plus_change_us 
  
  foreach i of local variables {
  replace   `i' =`i'*100
  }
		
  *B Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  keep if income_num==5
  gen level= "Upper Secondary" + " (N=" + strofreal(N) + ")"
  rename no_change_us no_change
  rename one_change_us one_change
  rename two_plus_change_us two_plus_change
  save `table3', replace
 restore
 use `table1', clear
 ap using `table2'
 ap using `table3'
 
 local variables no_change one_change two_plus_change
 
 label var no_change "No policy changes"
 label var one_change "One policy change"
 label var two_plus_change "Two or more policy changes"
  
  *C Beautify table
  format `variables' %3.0f
  
  * Create sheet in excel file for this table
  export excel level `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt
  *  leave the maximun global number for annex 
  keep if  N>=N[_n-1]
  drop if  N<=N[_n-1]
  
  * Add country and population coverage to Annex1
  add_to_annex1, figure_number(`figure') question_number(`fig_q')
  
 ******************************************************************** 
*S6/fq1/Q1. Have you made any of the following changes to national examinations due to the pandemic during the school year 2019/2020 2020 for countries with calendar year)? (Select all that apply)

  local figure    "Figure 2-2" // Figure number
  *local figure    "F2.2" // Figure number
  local fig_q     "FQ1"   // List all questions used
	*local fig_q     "FQ1_B"   // List all questions used
  
	start_from_clean_file 
	
	keep fq1_* countrycode income_num N incomelevelname population_0417 enrollment
	tempfile table1 table2 table3
  
	 *****Cleaning for education level: In each variable if country selected misisng or don't know, change it to missing
   foreach i in p ls us {
	 /*do not know is  "." for all countries*/
	foreach j in postponed adjustedthecontent adjustedthemode introducedaddh introducedaltass canceledexams other nochangesweremade notapplicable {
		replace fq1_`i'_2020`j' =. if fq1_`i'_2020`j' ==997| fq1_`i'_2020`j' ==999|fq1_`i'_2020`j' ==998
	}
}

 ******If a country responded 'not applicable' for a level, it should be missing 
 foreach i in p ls us {
	 /*do not know is  "." for all countries*/
	foreach j in postponed adjustedthecontent adjustedthemode introducedaddh introducedaltass canceledexams other nochangesweremade {
		replace fq1_`i'_2020`j' =. if fq1_`i'_2020notapplicable==1
	}	
}

****
*Primary Changes
*
****
preserve
  local variables fq1_p_2020postponed fq1_p_2020canceledexams fq1_p_2020introducedaltass
  
  foreach i of local variables {
  replace   `i' =`i'*100
  }
		
  *B Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  gen level= "Primary"
  gen N_primary = N 
  rename fq1_p_2020postponed Rescheduled_exam
  rename fq1_p_2020canceledexams Canceled_exam
  rename fq1_p_2020introducedaltass Introduce_alternative_assessment
  save `table1', replace
 restore
 
****
*Lower secondary Changes
*
****  
preserve
  local variables fq1_ls_2020postponed fq1_ls_2020canceledexams fq1_ls_2020introducedaltass
  
  foreach i of local variables {
  replace   `i' =`i'*100
  }
		
  *B Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  gen level= "Lower secondary"
  gen N_lsecondary = N
  rename fq1_ls_2020postponed Rescheduled_exam
  rename fq1_ls_2020canceledexams Canceled_exam
  rename fq1_ls_2020introducedaltass Introduce_alternative_assessment
  save `table2', replace
 restore
 
****
*Upper secondary Changes
*
****  
preserve
  local variables fq1_us_2020postponed fq1_us_2020canceledexams fq1_us_2020introducedaltass
  
  foreach i of local variables {
  replace   `i' =`i'*100
  }	

  *B Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  gen level= "Upper Secondary"
  gen N_usecondary = N 
  rename fq1_us_2020postponed Rescheduled_exam
  rename fq1_us_2020canceledexams Canceled_exam
  rename fq1_us_2020introducedaltass Introduce_alternative_assessment
  save `table3', replace
 restore
 
 use `table1', clear
 ap using `table2'
 ap using `table3'
 
 local variables Rescheduled_exam Canceled_exam Introduce_alternative_assessment
 label var Rescheduled_exam "Rescheduled/postponed exam"
 label var Canceled_exam "Canceled Exam"
 label var Introduce_alternative_assessment "Introduced alternative assessment"
 
  *C Beautify table
  format `variables' %3.0f
  
  foreach i in 1 2 3 4 {
  replace incomelevelname = subinstr(incomelevelname, "`i'.", "",.)
  }
  
  * Create sheet in excel file for this table
  export excel level incomelevelname `variables'  using `"${excelfile}"', sheet("`figure'", modify) $excelopt
  
  * Add country and population coverage to Annex2
  keep income_num incomelevelname N_primary N_lsecondary N_usecondary
  
  collapse (sum) N_*  (first) incomelevelname, by(income_num)
  local vars4excel "income_num incomelevelname N_primary N_lsecondary N_usecondary"
  order `vars4excel' 
  
  add_to_annex2, figure_number(`figure') question_number(`fig_q')

********************************************************************
*S6/fq1/Q1. Have you made any of the following changes to national examinations due to the pandemic during the school year 2019/2020 2020 for countries with calendar year)? (Select all that apply)

  local figure    "Figure 2-3" // Figure number
  *local figure    "F2.3" // Figure number
  local fig_q     "FQ1"   // List all questions used
	*local fig_q     "FQ1_C"   // List all questions used
  
	start_from_clean_file 
	
	keep fq1_* countrycode income_num N incomelevelname population_0417 enrollment
	tempfile table1 table2 table3
	
	 *****Cleaning for education level: In each variable if country selected misisng or don't know, change it to missing
   foreach i in p ls us {
	 /*do not know is  "." for all countries*/
	foreach j in postponed adjustedthecontent adjustedthemode introducedaddh introducedaltass canceledexams other nochangesweremade notapplicable {
		replace fq1_`i'_2020`j' =. if fq1_`i'_2020`j' ==997| fq1_`i'_2020`j' ==999|fq1_`i'_2020`j' ==998
	}
}

 ******If a country responded 'not applicable' for a level, it should be missing 
 foreach i in p ls us {
	 /*do not know is  "." for all countries*/
	foreach j in postponed adjustedthecontent adjustedthemode introducedaddh introducedaltass canceledexams other nochangesweremade {
		replace fq1_`i'_2020`j' =. if fq1_`i'_2020notapplicable==1
	}
}

****
*Primary Changes
*
****
preserve
  local variables fq1_p_2020introducedaddh fq1_p_2020adjustedthecontent fq1_p_2020adjustedthemode
  
  foreach i of local variables {
  replace   `i' =`i'*100
  }
		
  *B Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  gen level= "Primary"
  gen N_primary = N 
  rename fq1_p_2020introducedaddh Introduced_health_measures
  rename fq1_p_2020adjustedthecontent Adjusted_content
  rename fq1_p_2020adjustedthemode Adjusted_mode
  save `table1', replace
 restore
 
****
*Lower secondary Changes
*
****  
preserve
  local variables fq1_ls_2020introducedaddh fq1_ls_2020adjustedthecontent fq1_ls_2020adjustedthemode
  
  foreach i of local variables {
  replace   `i' =`i'*100
  }
		
  *B Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  gen level= "Lower secondary"
  gen N_lsecondary = N 
  rename fq1_ls_2020introducedaddh Introduced_health_measures
  rename fq1_ls_2020adjustedthecontent Adjusted_content
  rename fq1_ls_2020adjustedthemode Adjusted_mode
  save `table2', replace
 restore
 
****
*Upper secondary Changes
*
****  
preserve
  local variables fq1_us_2020introducedaddh fq1_us_2020adjustedthecontent fq1_us_2020adjustedthemode
  
  foreach i of local variables {
  replace   `i' =`i'*100
  }
  
  *B Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  gen level= "Upper Secondary"
  gen N_usecondary = N 
  rename fq1_us_2020introducedaddh Introduced_health_measures
  rename fq1_us_2020adjustedthecontent Adjusted_content
  rename fq1_us_2020adjustedthemode Adjusted_mode
  save `table3', replace
 restore
 
 use `table1', clear
 ap using `table2'
 ap using `table3'
 
 local variables Introduced_health_measures Adjusted_content Adjusted_mode
 label var Introduced_health_measures "Introduced additional health and safety measures"
 label var Adjusted_content "Adjusted the content"
 label var Adjusted_mode "	Adjusted the mode"
 
  foreach i in 1 2 3 4 {
  replace incomelevelname = subinstr(incomelevelname, "`i'.", "",.)
  }

  *C Beautify table
  format `variables' %3.0f
  
  * Create sheet in excel file for this table
  export excel level incomelevelname `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex2
  keep income_num incomelevelname N_primary N_lsecondary N_usecondary
  
collapse (sum) N_*  (first) incomelevelname, by(income_num)
local vars4excel "income_num incomelevelname N_primary N_lsecondary N_usecondary"
order `vars4excel' 
  
  add_to_annex2, figure_number(`figure') question_number(`fig_q')

  
********************************************************************
*S6/fq3/Q3: Did your plans for school re-opening in 2020 include adjustment to graduation criteria at the end of school year  2019/2020 (or end of 2020)?
start_from_clean_file

  local figure    "Figure 2-4" // Figure number
  *local figure    "F2.4" // Figure number
  local fig_q     "FQ3"   // List all questions used
  *local fig_q     "FQ3"   // List all questions used
	
	keep fq3_p_2020 fq3_ls_2020 fq3_us_2020 countrycode income_num N incomelevelname population_0417 enrollment
	tempfile table1 table2 table3

	foreach i in p ls us {
	replace fq3_`i'_2020=. if fq3_`i'_2020==997|fq3_`i'_2020==998
	gen national_level_`i'= 0 if fq3_`i'_2020!=.
	replace national_level_`i'= 100 if fq3_`i'_2020==1
	label var national_level_`i' "`i' :Introduced change to graduation criteria at national level"
	}
  
****
*Primary Changes
*
****
preserve	
  *B Create the collapsed table that will go into the Excel
  missings dropobs national_level_p, force

  collapse (mean) national_level_p (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  gen level= "Primary"
  gen N_primary = N 
 * gen pop_0417_primary = population_0417 
 * gen enrol_primary = enrollment  
  rename national_level_p national_level
  save `table1', replace
 restore
 
****
*Lower secondary Changes
*
****  
preserve
  *B Create the collapsed table that will go into the Excel
  missings dropobs national_level_ls, force
  collapse (mean) national_level_ls (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  gen level= "Lower Secondary"
  gen N_lsecondary = N
 * gen pop_0417_lsecondary = population_0417 
 * gen enrol_lsecondary = enrollment  
	rename national_level_ls national_level
  save `table2', replace
 restore
 
****
*Upper secondary Changes
*
****  
preserve
  *B Create the collapsed table that will go into the Excel
  missings dropobs national_level_us, force
  collapse (mean) national_level_us (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
	gen level= "Upper Secondary"
  gen N_usecondary = N
  gen pop_0417_usecondary = population_0417 
  gen enrol_usecondary = enrollment  
	rename national_level_us national_level
  save `table3', replace
 restore
 
 use `table1', clear
 ap using `table2'
 ap using `table3'
  
 replace level="p"  if level=="Primary"
 replace level="ls" if level=="Lower Secondary"
 replace level="us" if level=="Upper Secondary"
 keep level national_level income_num incomelevelname N_primary N_lsecondary N_usecondary
 reshape wide national_level, i(income_num incomelevelname N_primary N_lsecondary N_usecondary) j(level) string

 local variables national_levelp national_levells national_levelus
 label var national_levelp  "Primary"
 label var national_levells "Lower secondary"
 label var national_levelus "Upper secondary"
 
 foreach i in N_primary N_lsecondary N_usecondary national_levells national_levelp national_levelus {
 bys income_num: replace `i'=  `i'[_n-2] if  `i'==.
 bys income_num: replace `i'=  `i'[_n-1] if  `i'==.
 bys income_num: replace `i'=  `i'[_n+1] if  `i'==.
 bys income_num: replace `i'=  `i'[_n+2] if  `i'==.
 }
 duplicates drop
 
 foreach i in 1 2 3 4 {
 replace incomelevelname = subinstr(incomelevelname, "`i'.", "",.)
 }
 
  *C Beautify table
  format `variables' %3.0f
  
  * Create sheet in excel file for this table
  export excel incomelevelname `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex2
  keep income_num N_*
  
  add_to_annex2, figure_number(`figure') question_number(`fig_q')
  
  
*---------------------------------------------------------------------------
* Section 3. Distance Education Delivery Systems 
*---------------------------------------------------------------------------

*****------------*****
*****   Graphs   *****
*****------------*****
****************************************************************
* DQ1:  Which distance learning solutions were or are being offered in your country during the pandemic in 2020 and/or 2021? (Select all that apply)”
* Figure 3.1: Percent of countries offering a remote learning modality across at least one education level 

* Open clean file
start_from_clean_file

  local figure    "Figure 3-1" // Figure number
 * local figure    "F3.1" // Figure number
  local fig_q     "DQ1"   // List all questions used

*drop when all missing for that question
gen missing = 1

foreach var of varlist dq1_pp_onlineplatforms dq1_pp_television dq1_pp_mobilephones ///
						dq1_pp_radio dq1_pp_takehomepackages dq1_pp_otherdistancelearningm ///
						dq1_pp_none dq1_p_onlineplatforms dq1_p_television dq1_p_mobilephones ///
						dq1_p_radio dq1_p_takehomepackages dq1_p_otherdistancelearningm ///
						dq1_p_none dq1_ls_onlineplatforms dq1_ls_television dq1_ls_mobilephones ///
						dq1_ls_radio dq1_ls_takehomepackages dq1_ls_otherdistancelearningm ///
						dq1_ls_none dq1_us_onlineplatforms dq1_us_television dq1_us_mobilephones ///
						dq1_us_radio dq1_us_takehomepackages dq1_us_otherdistancelearningm ///
						dq1_us_none {
    	replace missing = 0 if `var' != . 
}

*tab missing
drop if missing == 1
   
keep  dq1_pp_onlineplatforms dq1_pp_television dq1_pp_mobilephones ///
		dq1_pp_radio dq1_pp_takehomepackages dq1_pp_otherdistancelearningm ///
		dq1_pp_none dq1_p_onlineplatforms dq1_p_television dq1_p_mobilephones ///
		dq1_p_radio dq1_p_takehomepackages dq1_p_otherdistancelearningm ///
		dq1_p_none dq1_ls_onlineplatforms dq1_ls_television dq1_ls_mobilephones ///
		dq1_ls_radio dq1_ls_takehomepackages dq1_ls_otherdistancelearningm ///
		dq1_ls_none dq1_us_onlineplatforms dq1_us_television dq1_us_mobilephones ///
		dq1_us_radio dq1_us_takehomepackages dq1_us_otherdistancelearningm ///
		dq1_us_none dq1_all_specify missing ///
		countrycode income_num N incomelevelname population_0417 enrollment

********	Step A - Define locals and adjust aggregation levels as needed for analysis

* Creating new dummies / vars as required
	* 1. somedl_*educlevel* : Country providing some modality of DL at each *educ level*

  	foreach i in onlineplatforms television mobilephones radio takehomepackages otherdistancelearningm none {
		gen dl_`i' = 1 if dq1_pp_`i' == 1 | dq1_p_`i' == 1| dq1_ls_`i' == 1| dq1_us_`i' == 1
		replace dl_`i' = 0 if dq1_pp_`i' == 0 & dq1_p_`i' == 0 & dq1_ls_`i' == 0 & dq1_us_`i' == 0
		}

	* local for all variables needed for the graph
	local variablesgph dl_onlineplatforms dl_television dl_mobilephones dl_radio dl_takehomepackages dl_otherdistancelearningm
  
   foreach i of local variablesgph {
  replace   `i' =`i'*100
  }

******** 	Step B - Create collapsed table that will go into excel *******

*missings dropobs `variables', force

collapse (mean) `variablesgph'  (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
	concatenate_label_income_N

*install labvars package
	labvars dl_onlineplatforms dl_television dl_mobilephones dl_radio ///
			dl_takehomepackages dl_otherdistancelearningm ///
			"Online platforms" ///
			"Television" ///
			"Mobile phones" ///
			"Radio" /// 
			"Take home packages" ///
			"Other distance learning"

  * Beautify table
  format `variablesgph' %3.0f	
  
  * Sorting in the right order for the fiugre production
  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }

* Create sheet in excel file for this table
  export excel concat_label `variablesgph' using `"${excelfile}"', sheet("`figure'", modify) $excelopt
  
* Add country and population coverage to Annex1
  add_to_annex1, figure_number(`figure') question_number(`fig_q') 

  
********************************************************************
* DQ2:  What percentage of students (at each level of education), approximately, followed distance education during school closures in 2020?
* Figure 3.3: Percent of ocuntries with over 75 students following remote education by education level
  
* open clean file
start_from_clean_file

  local figure    "Figure 3-2" // Figure number
  *local figure    "F3.2" // Figure number
  local fig_q     "DQ2"   // List all questions used

keep dq2_pp_percent dq2_p_percent dq2_ls_percent dq2_us_percent ///
	countrycode income_num N incomelevelname population_0417 enrollment

********	Step A - Define locals and adjust aggregation levels as needed for analysis
foreach j in pp p ls us {
	foreach cat in 1 2 3 4 5 6 {
		gen dq2_`j'_`cat' = 1 if dq2_`j'_percent == `cat'
		replace dq2_`j'_`cat' = 0 if dq2_`j'_percent  != `cat' & dq2_`j'_percent  != .
			}
	}

drop *_percent

  *** Creating the new graph
foreach lev in p pp ls us {	
	gen dq2_`lev'_75ormore = 1 if dq2_`lev'_5 == 1 | dq2_`lev'_6 == 1
    replace dq2_`lev'_75ormore = 0 if dq2_`lev'_1 == 1 | dq2_`lev'_2 == 1 | dq2_`lev'_3 == 1 | dq2_`lev'_4 == 1
  }

 local variables dq2_pp_75ormore dq2_p_75ormore dq2_ls_75ormore dq2_us_75ormore 
				                 
  foreach i of local variables {
  replace   `i' =`i'*100
  }
 
******** 	Step B - Create collapsed table that will go into excel *******
missings dropobs `variables', force

collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
 
  la var dq2_p_75ormore "Primary: 75% of students or more"
  la var dq2_pp_75ormore "Pre primary: 75% of students or more"
  la var dq2_ls_75ormore "Lower secondary: 75% of students or more"
  la var dq2_us_75ormore "Upper secondary: 75% of students or more"
  
  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
 
* Beautify table
  format `variables' %3.0f		

* Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

* Add country and population coverage to Annex1
  add_to_annex1, figure_number(`figure') question_number(`fig_q') 

  
****************************************************************
* LQ2:  Which measures have been/will be taken to facilitate access to connectivity of students to online distance learning infrastructure in 2021 or beyond?
* Figure 3.4: Percent of ocuntries with over 75 students following remote education by education level
   
* open clean file
start_from_clean_file

  local figure    "Figure 3-3" // Figure number
  *local figure    "F3.3" // Figure number
  local fig_q     "LQ2"   // List all questions used

keep lq2*_nationwide ///
	countrycode income_num N incomelevelname population_0417 enrollment

gen lq2intordev_nationwide = 1 if lq2offer_nationwide == 1 | lq2subsidized_nationwide == 1
	replace lq2intordev_nationwide = 0 if (lq2offer_nationwide == 0 & lq2subsidized_nationwide == 0) | lq2nomeasures_nationwide == 1

local variables lq2offer_nationwide lq2subsidized_nationwide lq2nomeasures_nationwide lq2other_nationwide 

foreach i of local variables {
  replace   `i' =`i'*100
  }	
  
*br lq2offer_nationwide lq2subsidized_nationwide lq2nomeasures_nationwide lq2 other_nationwide lq2donotknow_nationwide lq2intordev_nationwide
  
missings dropobs `variables', force

collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
concatenate_label_income_N
 
la var lq2offer_nationwide "Subsidized/free internet"
la var lq2subsidized_nationwide "Subsidized/free devices"
la var lq2nomeasures_nationwide "No measures"
la var lq2other_nationwide "Other"
*la var lq2donotknow_nationwide "Do not know"

* Beautify table
  format `variables' %3.0f		
  
  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }

* Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

* Add country and population coverage to Annex1
  add_to_annex1, figure_number(`figure') question_number(`fig_q') 

*---------------------------------------------------------------------------
* Section 4. Teachers 
*---------------------------------------------------------------------------
******Figure 1: Work requirement, by income group
*Eq1 S5Q1: What percentage of teachers (primary to upper-secondary levels combined), approximately, were required to teach (remotely/online) during all school closures in 2020?

start_from_clean_file
  local figure    "Figure 4-1" // Figure number
  *local figure    "F4.1" // Figure number
  local fig_q     "EQ1"   // List all questions used
  
  keep eq1_all_percentage countrycode income_num N incomelevelname population_0417 enrollment
  replace eq1_all_percentage=. if eq1_all_percentage==997 | eq1_all_percentage==998 | eq1_all_percentage==999

  gen eq1_percentage_cat=.
  replace eq1_percentage_cat=1 if eq1_all_percentage==1
  replace eq1_percentage_cat=2 if eq1_all_percentage==2 | eq1_all_percentage==3 | eq1_all_percentage==4
  replace eq1_percentage_cat=3 if eq1_all_percentage==5
  replace eq1_percentage_cat=4 if eq1_all_percentage==6
  
  drop eq1_all_percentage
  missings dropobs eq1_percentage_cat, force

 * Gen dummy variables: 0-100 for figure 
  *S5Q1.
	foreach v in eq1_percentage_cat {
	levelsof `v'
	foreach value in `r(levels)' {
	gen     `v'_`value'=0
	replace `v'_`value'=100 if `v'==`value'
	replace `v'_`value'=. if `v'==.
	label var `v'_`value' "`: label (`v') `value''"
	}
	}
  
  local variables eq1_percentage_cat_1 eq1_percentage_cat_2 eq1_percentage_cat_3 eq1_percentage_cat_4 	
    
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  
  label var eq1_percentage_cat_1 "Less than 25%"
  label var eq1_percentage_cat_2 "More than 25% but less than 75%"
  label var eq1_percentage_cat_3 "More than 75% but not all"
  label var eq1_percentage_cat_4 "All of the teachers"
  
  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
  
    * Create sheet in excel file for this table
    export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt
	
    * Add country and population coverage to Annex1
    add_to_annex1, figure_number(`figure') question_number(`fig_q')
	
****************************************************************
******Figure 2: Recruitment of teachers and other educational personnel, by income group 
*Eq3: Were or are new teachers being recruited for school re-opening during the previous or current school year?
start_from_clean_file

  local figure    "Figure 4-2" // Figure number
  *local figure    "F4.2" // Figure number
  local fig_q     "EQ3 LQ3"   // List all questions used
  
  keep  eq3_pp_2020 eq3_p_2020 eq3_ls_2020 eq3_us_2020 eq3_pp_2021 eq3_p_2021 eq3_ls_2021 eq3_us_2021 lq3 countrycode income_num N incomelevelname population_0417 enrollment
  foreach i in eq3_pp_2020 eq3_p_2020 eq3_ls_2020 eq3_us_2020 eq3_pp_2021 eq3_p_2021 eq3_ls_2021 eq3_us_2021 lq3 {
  replace `i'=. if `i'==997 | `i'==998 | `i'==999
  }
  
* generating new variables to combine education levels
	gen eq3_all_2020=.
	replace eq3_all_2020=1 if eq3_pp_2020 ==1 | eq3_p_2020 ==1 | eq3_ls_2020 ==1 | eq3_us_2020 ==1 // "yes" if any of the levels are 1
	replace eq3_all_2020=2 if (eq3_pp_2020 ==2 | eq3_p_2020 ==2 | eq3_ls_2020 ==2 | eq3_us_2020 ==2) & eq3_all_2020!=1 // "at discretion if any of the levels are 2"
	replace eq3_all_2020=0 if eq3_pp_2020 ==0 & eq3_p_2020 ==0 & eq3_ls_2020 ==0 & eq3_us_2020 ==0 // "no" if all of levels are 0
		replace eq3_all_2020=0 if (eq3_pp_2020 ==0 | eq3_p_2020 ==0 | eq3_ls_2020 ==0 | eq3_us_2020 == 0) & (eq3_all_2020!=1 | eq3_all_2020!=2) // "0" if any of the levels are 0
	replace eq3_all_2020=. if eq3_pp_2020 ==. & eq3_p_2020 ==. & eq3_ls_2020 ==. & eq3_us_2020 ==. // "." if all of levels are .

	gen eq3_all_2021=.
	replace eq3_all_2021=1 if eq3_pp_2021 ==1 | eq3_p_2021 ==1 | eq3_ls_2021 ==1 | eq3_us_2021 ==1 // "yes" if any of the levels are 1
	replace eq3_all_2021=2 if (eq3_pp_2021 ==2 | eq3_p_2021 ==2 | eq3_ls_2021 ==2 | eq3_us_2021 ==2) & eq3_all_2021!=1 // "at discretion if any of the levels are 2"
	replace eq3_all_2021=0 if eq3_pp_2021 ==0 & eq3_p_2021 ==0 & eq3_ls_2021 ==0 & eq3_us_2021 ==0 // "no" if all of levels are 0
		replace eq3_all_2021=0 if (eq3_pp_2021 ==0 | eq3_p_2021 ==0 | eq3_ls_2021 ==0 | eq3_us_2021 == 0) & (eq3_all_2021!=1 | eq3_all_2021!=2) // "0" if any of the levels are 0 (but not 1/2)
	replace eq3_all_2021=. if eq3_pp_2021 ==. & eq3_p_2021 ==. & eq3_ls_2021 ==. & eq3_us_2021 ==. // "." if all of levels are .

	gen eq3_nonteacher_2021=.
	replace eq3_nonteacher_2021=1 if lq3==1 // "yes" if yes in question lq3 in the planning section
	replace eq3_nonteacher_2021=0 if lq3==0 // "no" if no in question lq3 in the planning section
  
  	label define eq3_value 								///
			0 "No"										///
			1 "Yes"										///
			2 "At discretion of schools/ districts"	
	label value eq3_all_2020 eq3_all_2021 eq3_nonteacher_2021 eq3_value
	
	save "${Data_clean}Temp_0.dta", replace
	
	foreach i in  all_2020 all_2021 {
	use "${Data_clean}Temp_0.dta", clear
	keep eq3_`i' countrycode income_num population_0417 enrollment N incomelevelname
	
	reshape long eq3_, i(countrycode income_num population_0417 enrollment N incomelevelname) j(Level) string
	 
    * Gen dummy variabls: 0-100 for figure 
    *S5/Q3/eq3 + S12/Q3/lq3
	foreach v in eq3_ {
	levelsof `v'
	foreach value in `r(levels)' {
	gen     `v'_`value'=0
	replace `v'_`value'=100 if `v'==`value'
	replace `v'_`value'=. if `v'==.
	label var `v'_`value' "`: label (`v') `value''"
	}
	}
			
	local variables eq3__0 eq3__1 eq3__2 
	missings dropobs eq3__0 eq3__1 eq3__2 , force
	
	collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num Level)
    concatenate_label_income_N
	save "${Data_clean}Temp_`i'.dta", replace
    }
	
	* This one is for none teachers (The same loop did not apply)
	use "${Data_clean}Temp_0.dta", clear
	keep eq3_nonteacher_2021 countrycode income_num population_0417 enrollment N incomelevelname
	
	reshape long eq3_, i(countrycode income_num population_0417 enrollment N incomelevelname) j(Level) string
	 
    * Gen dummy variabls: 0-100 for figure 
    *S5/Q3/eq3 + S12/Q3/lq3
	foreach v in eq3_ {
	levelsof `v'
	foreach value in `r(levels)' {
	gen     `v'_`value'=0
	replace `v'_`value'=100 if `v'==`value'
	replace `v'_`value'=. if `v'==.
	label var `v'_`value' "`: label (`v') `value''"
	}
	}
  		
	local variables eq3__0 eq3__1 
	missings dropobs eq3__0 eq3__1 , force
	
	collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num Level)
    concatenate_label_income_N
	save "${Data_clean}Temp_nonteacher_2021.dta", replace
  
  use "${Data_clean}Temp_all_2020.dta", clear
  append using "${Data_clean}Temp_all_2021.dta"
  append using "${Data_clean}Temp_nonteacher_2021.dta"
  
  foreach i in  all_2020 all_2021 nonteacher_2021 {
  erase "${Data_clean}Temp_`i'.dta"
  }
  erase "${Data_clean}Temp_0.dta"
    
  gen Level_num=.
  replace Level_num=1 if Level=="all_2020"
  replace Level_num=2 if Level=="all_2021"
  replace Level_num=3 if Level=="nonteacher_2021"
 	
  label define Level_numl 1 "Recruitment of teachers 2020" 2 "Recruitment of teachers 2021" 3 "Recruitment of Non Teacher Personnel 2021", modify
  label value Level_num Level_numl
  
  label var eq3__0 "No"
  label var eq3__1 "Yes at all/some levels"
  label var eq3__2 "Discretion of schools/districs at all/some level"  
	
  sort Level_num concat_label
	foreach i in 1 2 3 4 {
    replace concat_label = subinstr(concat_label, "`i'.", "",.)
    }
	* Create sheet in excel file for this table
    export excel concat_label eq3__1 eq3__2 `variables' using `"${excelfile}"', sheet("`figure'", modify) firstrow(varlabels) cell(B3)
	  
	* Add country and population coverage to Annex1
	save "${Data_clean}Temp_0.dta", replace
  
	use "${Data_clean}Temp_0.dta", clear
	keep if Level_num==1
	add_to_annex1, figure_number(Figure 4-2) question_number(ALL_2020)	
 * add_to_annex1, figure_number(F4.2) question_number(all_2020)	
 
	use "${Data_clean}Temp_0.dta", clear
	keep if Level_num==2
	add_to_annex1, figure_number(Figure 4-2) question_number(ALL_2021)	
 * add_to_annex1, figure_number(F4.2) question_number(all_2021)	
 
	use "${Data_clean}Temp_0.dta", clear
	keep if Level_num==3
	add_to_annex1, figure_number(Figure 4-2) question_number(NONTEACHER_2021)	
 * add_to_annex1, figure_number(F4.2) question_number(nonteacher_2021)	

	erase "${Data_clean}Temp_0.dta"
	
****************************************************************
******Figure 3: Number of interactions encouraged between teachers and parents and/or students during school closures
*Eq5: What kind of interactions (other than interactions in online lessons) were encouraged by government between teachers and their students and/or their parents during school closures in 2020 (in pre-primary to upper secondary levels combined)?   
  start_from_clean_file

  local figure    "Figure 4-3" // Figure number
  *local figure    "F4.3" // Figure number
  local fig_q     "EQ5"   // List all questions used
  
  keep  eq5_all_phonecalls eq5_all_emails eq5_all_textwhatsapp eq5_all_videoconference eq5_all_homevisits eq5_all_communicationoneschool ///
  eq5_all_useofonlineparentalsurve eq5_all_holdingregularconversati eq5_all_involvingparents  eq5_all_other ///
  countrycode income_num N incomelevelname population_0417 enrollment
  
  foreach i in eq5_all_phonecalls eq5_all_emails eq5_all_textwhatsapp eq5_all_videoconference eq5_all_homevisits eq5_all_communicationoneschool ///
  eq5_all_useofonlineparentalsurve eq5_all_holdingregularconversati eq5_all_involvingparents  eq5_all_other {
  replace `i'=. if `i'==997 | `i'==998 | `i'==999
  }
  
  ****Generating new variables for eq5
	*Count of no. of interactions
	gen eq5_count = 0
	replace eq5_count=. if eq5_all_phonecalls==. & eq5_all_emails==. &  eq5_all_textwhatsapp==. & eq5_all_videoconference==. & eq5_all_homevisits==. & ///
	eq5_all_communicationoneschool==. & eq5_all_useofonlineparentalsurve==. & eq5_all_holdingregularconversati==. & eq5_all_involvingparents==. &  eq5_all_other==.
	
	qui foreach v of varlist eq5_all_phonecalls eq5_all_emails eq5_all_textwhatsapp eq5_all_videoconference eq5_all_homevisits eq5_all_communicationoneschool ///
		eq5_all_useofonlineparentalsurve eq5_all_holdingregularconversati eq5_all_involvingparents eq5_all_other {
		replace eq5_count = eq5_count + `v' if inlist(`v', 1) // only including "yes" responses for this analysis
	}
	label variable eq5_count "Total count interactions"

	// combining total categories
	gen eq5_count_category=.
		replace eq5_count_category=0 if eq5_count==0
		replace eq5_count_category=1 if eq5_count>=1 & eq5_count<4
		replace eq5_count_category=2 if eq5_count>=4 & eq5_count<7
		replace eq5_count_category=3 if eq5_count>=7 & eq5_count<8
		replace eq5_count_category=4 if eq5_count>=8
		replace eq5_count_category=. if eq5_count ==.
		
		label variable eq5_count_category "No. of interactions grouped"
		label define eq5_count_category ///
		0 "No interactions" ///
		1 "Between 1-3" ///
		2 "Between 4-6" ///
		3 "Between 7-8" ///
		4 "Greater than 8"
		
		label values eq5_count_category eq5_count_category

  * Create the collapsed table that will go into the Excel
	missings dropobs eq5_count_category, force
	
	drop eq5_all_* eq5_count
	 
 * Gen dummy variabls: 0-100 for figure 
  *S5/Q5/eq5.
	foreach v in eq5_count_category {
	levelsof `v'
	foreach value in `r(levels)' {
	gen     `v'_`value'=0
	replace `v'_`value'=100 if `v'==`value'
	replace `v'_`value'=. if `v'==.
	label var `v'_`value' "`: label (`v') `value''"
	}
	}
  
  local variables eq5_count_category_0 eq5_count_category_1 eq5_count_category_2 eq5_count_category_3 eq5_count_category_4	
  
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  
  label var eq5_count_category_0 "No interactions"
  label var eq5_count_category_1 "Between 1-3"
  label var eq5_count_category_2 "Between 4-6"
  label var eq5_count_category_3 "Between 7-8"
  label var eq5_count_category_4 "Greater than 8"
  
  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
  
    * Create sheet in excel file for this table
    export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt
	
    * Add country and population coverage to Annex1
    add_to_annex1, figure_number(`figure') question_number(`fig_q')
    
****************************************************************
******Figure 4: Support provided to teachers nationwide, by type of support and income group 	
* EQ4: How and at what scale were teachers (in pre-primary to upper secondary levels combined) supported in the transition to remote learning in 2020? [Select all that apply] 
start_from_clean_file

  local figure    "Figure 4-4" // Figure number
  *local figure    "F4.4" // Figure number
  local fig_q     "EQ4"   // List all questions used
  
  local variables eq4_all_natofferedspecial eq4_all_natinstruction eq4_all_natppe eq4_all_natguidelines eq4_all_natprofessionaldev eq4_all_natteachingcontent eq4_all_naticttools eq4_all_natother
  
  foreach i of local variables {
  replace   `i' =. if `i' ==997
  replace   `i' =`i'*100
  }

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  
  label var eq4_all_natofferedspecial "Special training"
  label var eq4_all_natinstruction "Instruction on distance instruction"
  label var eq4_all_natppe "Professional, psychosocial, and emotional support"
  label var eq4_all_natguidelines "Guidelines to eff"
  label var eq4_all_natprofessionaldev "Professional development activities"
  label var eq4_all_natteachingcontent "Teaching content for remote teaching"
  label var eq4_all_naticttools "Provision of ICT tools and connectivity"
  label var eq4_all_natother "Other supports"
 
  * Beautify table
  format `variables' %3.0f
  
  * Sorting in the right order for the fiugre production
  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
  
  * Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex1
  add_to_annex1, figure_number(`figure') question_number(`fig_q')
    
*---------------------------------------------------------------------------
* Section 5. Reopening
*---------------------------------------------------------------------------

***Figure 1: Complex measures included in Ministry-endorsed school health and hygiene guidelines for schools
* Kq2: What do these guidelines cover? [Select all that apply] & Kq4: Which of the following measures to ensure the health and safety of students/learners on their journey to and from school are included in school reopening plans / are being implemented as schools reopen

start_from_clean_file

  local figure    "Figure 5-1" // Figure number
  *local figure    "F5.1" // Figure number
  local fig_q     "KQ2 KQ2B KQ4"   // List all questions used

  keep kq2testingforcovid19inschoo kq2trackingstaffandstudentsw kq2selfscreeningformapp_ kq4ensurephysicaldistancingdu ///
  kq4treatschoolbusesasextensi kq4promotesafetyandhygieneon kq2b countrycode income_num N incomelevelname population_0417 enrollment
		
  gen kq2b_allschools=.
	replace kq2b_allschools=1 if kq2b==6
	replace kq2b_allschools=0 if kq2b<6 | kq2b==997
	
	label define kq2b_all	///
	1 "Yes"					///
	0 "No"					
	lab val kq2b_allschools kq2b_all
	
  drop kq2b
  
  local variables kq2testingforcovid19inschoo kq2trackingstaffandstudentsw kq2selfscreeningformapp_ ///
  kq2b_allschools kq4ensurephysicaldistancingdu kq4treatschoolbusesasextensi kq4promotesafetyandhygieneon
  
  foreach i of local variables {
	  replace `i' =. if `i' ==997
	  replace `i' =`i'*100
  }
  
  save "${Data_clean}Temp_0.dta", replace
  
   * Create the collapsed table that will go into the Excel
  local variables_KQ2  kq2testingforcovid19inschoo kq2trackingstaffandstudentsw kq2selfscreeningformapp_
  local variables_KQ2B kq2b_allschools
  local variables_KQ4 kq4ensurephysicaldistancingdu kq4treatschoolbusesasextensi kq4promotesafetyandhygieneon
  
  foreach i in KQ2 KQ2B KQ4 {
  use "${Data_clean}Temp_0.dta", clear
  missings dropobs `variables_`i'', force
  collapse (mean)  `variables_`i'' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  save "${Data_clean}Temp_variables_`i'.dta", replace
  add_to_annex1, figure_number(`figure') question_number(`i')
  }
  
  use "${Data_clean}Temp_variables_KQ2.dta", clear
  merge 1:1 income_num using "${Data_clean}Temp_variables_KQ2B.dta" , nogen
  merge 1:1 income_num using "${Data_clean}Temp_variables_KQ4.dta", nogen
  
  erase "${Data_clean}Temp_0.dta"
  erase "${Data_clean}Temp_variables_KQ2.dta"
  erase "${Data_clean}Temp_variables_KQ2B.dta"
  erase "${Data_clean}Temp_variables_KQ4.dta"
  replace N=.
  concatenate_label_income_N
  
  	label var kq2testingforcovid19inschoo     "Testing for COVID-19 in schools "
	label var kq2trackingstaffandstudentsw    "Tracking staff/ students infected or exposed to COVID-19"
    label var kq2selfscreeningformapp_   	  "Self-screening form/ app"
    label var kq2b_allschools    			  "Implementation of guidelines in all of the schools"
    label var kq4ensurephysicaldistancingdu   "Ensure physical distancing during school drop-off and pick-up"
    label var kq4treatschoolbusesasextensi    "Treat school buses as extensions of the classroom"
	label var kq4promotesafetyandhygieneon    "Promote safety and hygiene on public and shared transport"
  
  * Beautify table
  format `variables' %3.0f
  
  * Sorting in the right order for the figure production
  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  replace concat_label = subinstr(concat_label, "(N=.)", "",.)
  }
  
  * Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

****************************************************************
****Figure 2: Estimated share of schools implementing school health and hygiene guidelines
* Kq2b: If monitoring information is available, what proportion of schools or other educational institutions are implementing the health and hygiene guidelines? 

start_from_clean_file

  local figure    "Figure 5-2" // Figure number
  *local figure    "F5.2" // Figure number
  local fig_q     "KQ2B"   // List all questions used
  
  keep kq2b countrycode income_num N incomelevelname population_0417 enrollment
  replace kq2b = 0 if kq2b == 997
  replace kq2b=. if kq2b==998 | kq2b==999
  missings dropobs kq2b, force
  
  gen kq2b_categ=kq2b
  recode kq2b_categ 0=0 2/5=1 6=2

 * Gen dummy variables: 0-100 for figure 
  *S5Q1.
	foreach v in kq2b_categ {
	levelsof `v'
	foreach value in `r(levels)' {
	gen     `v'_`value'=0
	replace `v'_`value'=100 if `v'==`value'
	replace `v'_`value'=. if `v'==.
	label var `v'_`value' "`: label (`v') `value''"
	}
	}
  
  local variables kq2b_categ_0 kq2b_categ_1 kq2b_categ_2
  
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  
  label var kq2b_categ_0 "Unknown/not monitored"
  label var kq2b_categ_1 "Not all schools"
  label var kq2b_categ_2 "All of the schools"
  
  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
    * Create sheet in excel file for this table
	export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

	* Add country and population coverage to Annex1
	add_to_annex1, figure_number(`figure') question_number(`fig_q')

  
****************************************************************
****Figure 3: Bottlenecks for implementation of health and hygiene guidelines
* Kq2c: What are the challenges and bottlenecks faced in implementing the specific measures? (Select all that apply)

start_from_clean_file

  local figure    "Figure 5-3" // Figure number
  *local figure    "F5.3" // Figure number
  local fig_q     "KQ2C"   // List all questions used
  
  local variables kq2clackofsafetycommitmentfr  kq2clackofresourcesforimplem   kq2cpoorsafetyculture_ kq2clackofmedicalfacilitiesa kq2clackofdoortodoorservice ///
                  kq2clackofstrictenforcemento  kq2cpublicstigmatization_  kq2clackofadministrativecommi kq2clackofpropercommunication ///
                  kq2clackofgovernmentpolicies_

  foreach i of local variables {
  replace   `i' =. if `i' ==997
  replace   `i' =`i'*100
  }

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
 
 label var kq2clackofsafetycommitmentfr "Lack of safety commitment from public"
 label var kq2cpoorsafetyculture_ "Poor safety culture"
 label var kq2clackofadministrativecommi "Lack of administrative commitment & support at community level"
 label var kq2clackofstrictenforcemento "Lack of strict enforcement of WHO regulations"
 label var kq2clackofresourcesforimplem "Lack of resources for implementing public health and social measures"
 label var kq2clackofmedicalfacilitiesa "Lack of medical facilities at community level"
 label var kq2clackofdoortodoorservice "Lack of door to door services during quarantine period"
 label var kq2clackofpropercommunication "Lack of proper communication between health advisors and public"
 label var kq2clackofgovernmentpolicies_ "Lack of government policies"
 label var kq2cpublicstigmatization_ "Public stigmatization"
  
  * Beautify table
  format `variables' %3.0f
  
  * Sorting in the right order for the fiugre production
  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
  
  * Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex1
  add_to_annex1, figure_number(`figure') question_number(`fig_q')
  
  
****************************************************************  
****Figure 4: Estimated share of students who attended school in-person after the reopening of schools, by school level and country income group 
* CQ3: What is the approximate share of students who attended school in-person after the reopening of schools in 2020?
* Items to discuss
* What does missing varibale mean here (never reopened?)
  local figure    "Figure 5-4" // Figure number
  *local figure    "F5.4" // Figure number
  local fig_q     "CQ3"   // List all questions used
  
  foreach i in pp p ls us {
  start_from_clean_file
  gen     cq3_`i'_first_1_4=0
  replace cq3_`i'_first_1_4=100 if cq3_`i'_first_1==100 | cq3_`i'_first_2==100 | cq3_`i'_first_3==100 | cq3_`i'_first_4==100

  local variables cq3_`i'_first 
  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) cq3_`i'_first_0 cq3_`i'_first_1_4 cq3_`i'_first_5 cq3_`i'_first_6 (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  gen     Level=""
  replace Level="`i'"
  gen N_`i' = N
  rename cq3_`i'_first_0 cq3_first_0
  rename cq3_`i'_first_1_4 cq3_first_1_4
  rename cq3_`i'_first_5 cq3_first_5
  rename cq3_`i'_first_6 cq3_first_6
  save "${Data_clean}Temp_`i'.dta", replace
  }
  
  use "${Data_clean}Temp_pp.dta", clear
  append using "${Data_clean}Temp_p.dta"
  append using "${Data_clean}Temp_ls.dta"
  append using "${Data_clean}Temp_us.dta"
  
  foreach i in pp p ls us {
  erase "${Data_clean}Temp_`i'.dta"
  }
  
  * Provide column heading for each variable here
  label var cq3_first_0       "Do not know/Not monitored"
  label var cq3_first_1_4     "Less than 75% of students"
  label var cq3_first_5       "More than 75% but not all the students"
  label var cq3_first_6       "All of the students"
  
  rename Level Level_string
  
  gen     Level=0
  
  replace Level=1 if Level_string=="pp"
  replace Level=2 if Level_string=="p"
  replace Level=3 if Level_string=="ls"
  replace Level=4 if Level_string=="us"
  
  label define Levell 1 "Pre-primary" 2 "Primary" 3 "Lower secondary" 4 "Upper secondary", modify
  label values Level Levell
  sort income_num Level
  
  * Create sheet in excel file for this table
  export excel              Level cq3_first_0 cq3_first_1_4 cq3_first_5 cq3_first_6 using `"${excelfile}"', sheet("`figure'", modify) firstrow(varlabels) cell(B3)
  
  * Add country and population coverage to Annex2 
  rename N_pp N_preprimary
  rename N_p  N_primary
  rename N_ls N_lsecondary
  rename N_us N_usecondary

  keep income_num incomelevelname N_preprimary N_primary N_lsecondary N_usecondary
  
collapse (sum) N_*  (first) incomelevelname, by(income_num)

local vars4excel "incomelevelname N_preprimary N_primary N_lsecondary N_usecondary"
order `vars4excel' 
  
  add_to_annex2, figure_number(`figure') question_number(`fig_q')


****************************************************************
*****Figure 5: Outreach/support measures to encourage return to school -for vulnerable populations, by school level and country income group (% of reporting countries)
 start_from_clean_file

  local figure    "Figure 5-5" // Figure number
  *local figure    "F5.5" // Figure number
  local fig_q     "IQ4"   // List all questions used
  
  local variables ///
  iq4_all_comchildren iq4_all_comrefugees iq4_all_comethnic iq4_all_comgirls iq4_all_comother ///
  iq4_all_provofficialchildren iq4_all_provofficialrefugees iq4_all_provofficialethnic iq4_all_provofficialgirls iq4_all_provofficialother ///
  iq4_all_schoolbasedchildren iq4_all_schoolbasedrefugees iq4_all_schoolbasedethnic iq4_all_schoolbasedgirls iq4_all_schoolbasedother ///
  iq4_all_reviewingchildren iq4_all_reviewingrefugees iq4_all_reviewingethnic iq4_all_reviewinggirls iq4_all_reviewingother ///
  iq4_all_makemodchildren iq4_all_makemodrefugees iq4_all_makemodethnic iq4_all_makemodgirls iq4_all_makemodother
  
  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  
  reshape long  iq4_all_, i(income_num) j(String) string
  
  gen Type=""
  gen ID=""
  
  foreach i in children refugees ethnic girls other {
  replace ID="`i'" if strpos(String, "`i'")
  }
  foreach i in com make provofficial review schoolbase {
  replace Type="`i'" if strpos(String, "`i'")
  }
  drop String
  replace iq4_all_=iq4_all_*100
  
  reshape wide iq4_all_, i(ID concat_label) j(Type) string
  
  rename ID ID_string
  
  gen ID=.
  
  replace ID=1 if ID_string=="children"
  replace ID=2 if ID_string=="ethnic"
  replace ID=3 if ID_string=="girls"
  replace ID=4 if ID_string=="refugees"
  replace ID=5 if ID_string=="other"
  
  label define IDl 1 "Disability" 2 "Ethnicity" 3 "Girls" 4 "Refugee" 5 "Other", modify
  label values ID IDl

  label var iq4_all_make "Modifications to WASH services"
  label var iq4_all_com  "Community engagement"
  label var iq4_all_schoolbase  "School-based tracking"
  label var iq4_all_provofficial  "Financial incentives/waived fees"
  label var iq4_all_review  "Review/revise access policies"
       
  * Sorting in the right order for the fiugre production
  sort concat_label ID
  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
  
  local variables iq4_all_make iq4_all_com iq4_all_schoolbase iq4_all_provofficial iq4_all_review
  
  * Create sheet in excel file for this table
  export excel concat_label ID `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex1
  add_to_annex1, figure_number(`figure') question_number(`fig_q')
 
 
****************************************************************
****Figure 6: Remedial measures to address learning gaps implemented when schools reopened, by school level and country income group 
*CQ1. What measures to address learning gaps were widely implemented when schools reopened after the first/second/third closure in 2020? 

  local figure    "Figure 5-6" // Figure number
  *local figure    "F5.6" // Figure number
  local fig_q     "CQ1"   // List all questions used

  foreach i in pp p ls us {
  start_from_clean_file
  local variables cq1_`i'_remedial1 cq1_`i'_remedial2 cq1_`i'_remedial3 cq1_`i'_remedial4 cq1_`i'_remedial5 cq1_`i'_remedial6 cq1_`i'_remedial7 cq1_`i'_remedial8
  * Create the collapsed table that will go into the Excel  
  missings dropobs `variables', force
  gen     cq1_`i'_any=0
  replace cq1_`i'_any=100 if cq1_`i'_remedial1==1 | cq1_`i'_remedial2==1 | cq1_`i'_remedial3==1 | cq1_`i'_remedial4==1 | cq1_`i'_remedial5==1 | cq1_`i'_remedial6==1 | cq1_`i'_remedial7==1 | cq1_`i'_remedial8==1
  collapse (mean) cq1_`i'_any (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  *rename N N`i'
  gen N_`i' = N
  save "${Data_clean}Temp_`i'.dta", replace
  }
  
  use "${Data_clean}Temp_pp.dta", clear
  merge 1:1 income_num using "${Data_clean}Temp_p.dta", nogen
  merge 1:1 income_num using "${Data_clean}Temp_ls.dta", nogen
  merge 1:1 income_num using "${Data_clean}Temp_us.dta", nogen
  
  foreach i in pp p ls us {
  erase "${Data_clean}Temp_`i'.dta"
  }

  label var cq1_pp_any "Some measure pre-primary"
  label var cq1_p_any  "Some measure primary"
  label var cq1_ls_any "Some measure lower secondary"
  label var cq1_us_any "Some measure upper secondary"
  
  local variables cq1_pp_any cq1_p_any cq1_ls_any cq1_us_any
  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
  
  * Beautify table
  format `variables' %3.0f
  
  replace concat_label="Low income" if incomelevelname=="1.Low income"
  replace concat_label="Lower middle" if incomelevelname=="2.Lower middle"
  replace concat_label="Upper middle" if incomelevelname=="3.Upper middle"
  replace concat_label="High income" if incomelevelname=="4.High income"
  replace concat_label="Global" if incomelevelname=="Global"
  
  * Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt
  
  * Add country and population coverage to Annex2
  rename N_pp N_preprimary
  rename N_p  N_primary
  rename N_ls N_lsecondary
  rename N_us N_usecondary
  
  keep income_num incomelevelname N_preprimary N_primary N_lsecondary N_usecondary
  
  add_to_annex2, figure_number(`figure') question_number(`fig_q')

*---------------------------------------------------------------------------
* Section 6. Financing
*---------------------------------------------------------------------------

********	Step A - Define locals and adjust aggregation levels as needed for analysis
start_from_clean_file

  local figure    "Figure 6-1a" // Figure number
  *local figure    "F6.1a" // Figure number
  local fig_q     "GQ1_2020"   // List all questions used
  
  keep  gq1_all_2020 gq1_pp_2020 gq1_p_2020 gq1_ls_2020 gq1_us_2020 countrycode income_num N incomelevelname population_0417 enrollment
  local variables gq1_all_2020 gq1_pp_2020 gq1_p_2020 gq1_ls_2020 gq1_us_2020  

* Create the collapsed table that will go into the Excel
  foreach v in `variables'{
      replace `v' =. if `v' ==999 |`v' ==998 |`v' ==997
  }
  missings dropobs `variables', force
  
  reshape long gq1_, i(countrycode income_num population_0417 enrollment) j(Level) string

  * Gen dummy variabls: 0-100 for figure 
	*S7/gq1/Q1.
	foreach v in gq1_ {
	levelsof `v'
	foreach value in `r(levels)' {
	gen     `v'_`value'=0
	replace `v'_`value'=100 if `v'==`value'
	replace `v'_`value'=. if `v'==.
	label var `v'_`value' "`: label (`v') `value''"
	}
}
  
	gen Level_num=.
	replace Level_num=1 if Level=="pp_2020"
	replace Level_num=2 if Level=="p_2020"
	replace Level_num=3 if Level=="ls_2020"
	replace Level_num=4 if Level=="us_2020"
	replace Level_num=5 if Level=="all_2020"
	
	label define Level_numl 1 "pp" 2 "p" 3 "ls" 4 "us" 5 "all", modify
	label value Level_num Level_numl
	
	local variables gq1__1 gq1__2 gq1__3 gq1__4 gq1__5 
  
collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num Level_num)

concatenate_label_income_N
	
label var gq1__1   "Increase"
label var gq1__2   "No change"
label var gq1__3   "Decrease"
label var gq1__4   "No change in total amount, but change in distribution"
label var gq1__5   "Discretion of schools/districts"
// 	label var gq1__997 "Do not know"

  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
	
******** 	Step B - Create collapsed table that will go into excel *******
    * Create sheet in excel file for this table
    export excel concat_label `variables' if Level_num==5 using `"${excelfile}"', sheet("`figure'", modify) $excelopt
	
********		Step C - Beautify table*******
    * Add country and population coverage to Annex1
    add_to_annex1, figure_number(`figure') question_number(`fig_q')

****************************************************************
********	Step A - Define locals and adjust aggregation levels as needed for analysis
start_from_clean_file

  local figure    "Figure 6-1b" // Figure number
  *local figure    "F6.1b" // Figure number
  local fig_q     "GQ1_2021"   // List all questions used
  
  keep  gq1_all_2021 gq1_pp_2021 gq1_p_2021 gq1_ls_2021 gq1_us_2021 countrycode income_num N incomelevelname population_0417 enrollment
  local variables gq1_all_2021 gq1_pp_2021 gq1_p_2021 gq1_ls_2021 gq1_us_2021  

* Create the collapsed table that will go into the Excel
  foreach v in `variables'{
      replace `v' =. if `v' ==999 |`v' ==998 |`v' ==997
  }
  missings dropobs `variables', force
  
  reshape long gq1_, i(countrycode income_num population_0417 enrollment) j(Level) string

  * Gen dummy variabls: 0-100 for figure 
	*S7/gq1/Q1.
	foreach v in gq1_ {
	levelsof `v'
	foreach value in `r(levels)' {
	gen     `v'_`value'=0
	replace `v'_`value'=100 if `v'==`value'
	replace `v'_`value'=. if `v'==.
	label var `v'_`value' "`: label (`v') `value''"
	}
}
  
	gen Level_num=.
	replace Level_num=1 if Level=="pp_2021"
	replace Level_num=2 if Level=="p_2021"
	replace Level_num=3 if Level=="ls_2021"
	replace Level_num=4 if Level=="us_2021"
	replace Level_num=5 if Level=="all_2021"
	
	label define Level_numl 1 "pp" 2 "p" 3 "ls" 4 "us" 5 "all", modify
	label value Level_num Level_numl
	
	local variables gq1__1 gq1__2 gq1__3 gq1__4 gq1__5
  
	collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num Level_num)
    concatenate_label_income_N
	
	label var gq1__1   "Increase"
	label var gq1__2   "No change"
    label var gq1__3   "Decrease"
	label var gq1__4   "No change in total amount, but change in distribution"
    label var gq1__5   "Discretion of schools/districts"
// 	label var gq1__997 "Do not know"

  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
	
******** 	Step B - Create collapsed table that will go into excel *******
    * Create sheet in excel file for this table
    export excel concat_label `variables' if Level_num==5 using `"${excelfile}"', sheet("`figure'", modify) $excelopt
	
********		Step C - Beautify table*******
    * Add country and population coverage to Annex1
    add_to_annex1, figure_number(`figure') question_number(`fig_q')


****************************************************************
******** GQ2a
start_from_clean_file

  local figure    "Figure 6-2" // Figure number
  *local figure    "F6.2" // Figure number
  local fig_q     "GQ2A"   // List all questions used
  
  local variables gq2a_all_addfundingfromex gq2a_all_addallocationfro gq2a_all_reprogofprevious gq2a_all_reallocwithintheed
  
  keep `variables' countrycode income_num N incomelevelname population_0417 enrollment
  
  * Create the collapsed table that will go into the Excel
  foreach v in `variables'{
      replace `v' =. if `v' ==999 |`v' ==998 |`v' ==997
  }
  missings dropobs `variables', force
  
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  reshape long  gq2a_all_, i(income_num population_0417 enrollment) j(String) string
  
  replace gq2a_all_=gq2a_all_*100
  
  reshape wide gq2a_all_, i(concat_label) j(String) string
  sort concat_label
  
  	label var gq2a_all_addallocationfro     "Additional allocation from the Government"
	label var gq2a_all_addfundingfromex     "Additional funding from external donors"
    label var gq2a_all_reallocwithintheed   "Reallocation within the education budget"
    label var gq2a_all_reprogofprevious     "Re-programming of previously earmarked/restricted funding"
	
  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
  
  local variables gq2a_all_addfundingfromex gq2a_all_addallocationfro gq2a_all_reprogofprevious gq2a_all_reallocwithintheed
  order gq2a_all_addallocationfro  gq2a_all_reprogofprevious gq2a_all_addfundingfromex gq2a_all_reallocwithintheed
  
  * Create sheet in excel file for this table
  export excel concat_label gq2a* using `"${excelfile}"', sheet("`figure'", modify) $excelopt
  
  * Add country and population coverage to Annex1
  add_to_annex1, figure_number(`figure') question_number(`fig_q')

  
****************************************************************
******* GQ3
start_from_clean_file
 
  local figure    "Figure 6-3" // Figure number
  *local figure    "F6.3" // Figure number
  local fig_q     "GQ3"   // List all questions used
  
  local variables gq3_all_numberofstudentsclass gq3_all_socioeconomiccharacter gq3_all_geographiccriteria gq3_all_studentswithsen gq3_all_othercriteria gq3_all_none gq3_all_notapplicable
  keep `variables' countrycode income_num N incomelevelname population_0417 enrollment
  * Create the collapsed table that will go into the Excel
  foreach v in `variables'{
      replace `v' =. if `v' ==999 |`v' ==998 |`v' ==997
  }
  missings dropobs `variables', force
  
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  reshape long  gq3_all_, i(income_num population_0417 enrollment) j(String) string
  
  replace gq3_all_=gq3_all_*100
  
  reshape wide gq3_all_, i(concat_label) j(String) string
  sort concat_label

    label var gq3_all_geographiccriteria     "Geographic criteria"
	label var gq3_all_numberofstudentsclass  "Number of students / classes"
    label var gq3_all_socioeconomiccharacter     "Socio-economic characteristics"
	label var gq3_all_studentswithsen  "Students with SEN"
    label var gq3_all_othercriteria          "Other criteria"
    label var gq3_all_none 					 "None"
    label var gq3_all_notapplicable       "Not applicable"
  
  local variables gq3_all_numberofstudentsclass gq3_all_socioeconomiccharacter gq3_all_geographiccriteria gq3_all_studentswithsen gq3_all_othercriteria gq3_all_none gq3_all_notapplicable
  order gq3_all_numberofstudentsclass gq3_all_socioeconomiccharacter gq3_all_geographiccriteria gq3_all_studentswithsen gq3_all_othercriteria gq3_all_none gq3_all_notapplicable
  
  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
  
  * Create sheet in excel file for this table
  export excel concat_label gq3_all_numberofstudentsclass gq3_all_socioeconomiccharacter gq3_all_geographiccriteria gq3_all_studentswithsen using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex1
  add_to_annex1, figure_number(`figure') question_number(`fig_q')

*---------------------------------------------------------------------------
* Section 7. Locus of Decision Making
*---------------------------------------------------------------------------

start_from_clean_file
 
local figure    "Figure 7-1" // Figure number

  local fig_q1a     "HQ1_School closure and reopening"   // List all questions used
  local fig_q1b     "HQ1_Working requirements for teachers"   // List all questions used
  local fig_q1c     "HQ1_Adjustments to school calendar"   // List all questions used
  local fig_q1d     "HQ1_Resources to continue learning during school closures"   // List all questions used
  local fig_q1e     "HQ1_Additional support programs for students after schools reopened"   // List all questions used
  local fig_q1f     "HQ1_Compensation of teachers"   // List all questions used	
  local fig_q1g     "HQ1_Hygiene measures for school reopening"   // List all questions used	
  local fig_q1h     "HQ1_Changes in funding to schools"   // List all questions used
  
local figure3    "Figure 7-3" // Figure number

  
local variables ///
hq1_all_schoolcentral hq1_all_schoolprovincial hq1_all_schoolsubreg hq1_all_schoollocal hq1_all_schoolschool ///
hq1_all_adjustmentscentral hq1_all_adjustmentsprovincial hq1_all_adjustmentssubreg hq1_all_adjustmentslocal hq1_all_adjustmentsschool ///
hq1_all_resourcescentral hq1_all_resourcesprovincial hq1_all_resourcessubreg hq1_all_resourceslocal hq1_all_resourcesschool ///
hq1_all_addsupcentral hq1_all_addsupprovincial hq1_all_addsupsubreg hq1_all_addsuplocal hq1_all_addsupschool ///
hq1_all_workingreqcentral hq1_all_workingreqprovincial hq1_all_workingreqsubreg hq1_all_workingreqlocal hq1_all_workingreqschool ///
hq1_all_compensationcentral hq1_all_compensationprovincial hq1_all_compensationsubreg hq1_all_compensationlocal hq1_all_compensationschool ///
hq1_all_hygienecentral hq1_all_hygieneprovincial hq1_all_hygienesubreg hq1_all_hygienelocal hq1_all_hygieneschool ///
hq1_all_changescentral hq1_all_changesprovincial hq1_all_changessubreg hq1_all_changeslocal hq1_all_changesschool
keep `variables' countrycode income_num N incomelevelname population_0417 enrollment
  
* Create the collapsed table that will go into the Excel
foreach v in `variables'{
   replace `v' =. if `v' ==999 |`v' ==998 |`v' ==997
}
missings dropobs `variables', force
  
* Creating 'Multiple' 
foreach i in school adjustments resources addsup workingreq compensation hygiene changes{
  	gen hq1_all_`i'multi = 0
	replace hq1_all_`i'multi = 1 if hq1_all_`i'central + hq1_all_`i'provincial + hq1_all_`i'subreg + hq1_all_`i'local + hq1_all_`i'school >=2
		replace hq1_all_`i'multi = . if hq1_all_`i'central ==.
  }

* Creating 'Only'
foreach i in school adjustments resources addsup workingreq compensation hygiene changes{
  	gen hq1_all_`i'central_o = hq1_all_`i'central
  	gen hq1_all_`i'provincial_o = hq1_all_`i'provincial
  	gen hq1_all_`i'subreg_o = hq1_all_`i'subreg
  	gen hq1_all_`i'local_o = hq1_all_`i'local
  	gen hq1_all_`i'school_o = hq1_all_`i'school
	
	replace hq1_all_`i'central_o = 0     if hq1_all_`i'central ==1    & (hq1_all_`i'provincial  ==1 |   hq1_all_`i'subreg ==1 |   hq1_all_`i'local ==1 | hq1_all_`i'school ==1)
	replace hq1_all_`i'provincial_o = 0  if hq1_all_`i'provincial ==1 & (hq1_all_`i'central     ==1 |  hq1_all_`i'subreg ==1 |  hq1_all_`i'local ==1 |  hq1_all_`i'school ==1) 
	replace hq1_all_`i'subreg_o = 0      if hq1_all_`i'subreg     ==1 & (hq1_all_`i'central     ==1 |  hq1_all_`i'provincial ==1 |  hq1_all_`i'local ==1 |  hq1_all_`i'school ==1 )
	replace hq1_all_`i'local_o = 0       if hq1_all_`i'local      ==1 & (hq1_all_`i'central     ==1 |  hq1_all_`i'provincial ==1 |  hq1_all_`i'subreg ==1 |  hq1_all_`i'school ==1 )
	replace hq1_all_`i'school_o = 0      if hq1_all_`i'school    ==1 & (hq1_all_`i'central     ==1 |  hq1_all_`i'provincial ==1 |  hq1_all_`i'subreg ==1 |  hq1_all_`i'local ==1 )
}
    
local variables ///
hq1_all_schoolcentral_o hq1_all_schoolprovincial_o hq1_all_schoolsubreg_o hq1_all_schoollocal_o hq1_all_schoolschool_o ///
hq1_all_adjustmentscentral_o hq1_all_adjustmentsprovincial_o hq1_all_adjustmentssubreg_o hq1_all_adjustmentslocal_o hq1_all_adjustmentsschool_o ///
hq1_all_resourcescentral_o hq1_all_resourcesprovincial_o hq1_all_resourcessubreg_o hq1_all_resourceslocal_o hq1_all_resourcesschool_o ///
hq1_all_addsupcentral_o hq1_all_addsupprovincial_o hq1_all_addsupsubreg_o hq1_all_addsuplocal_o hq1_all_addsupschool_o ///
hq1_all_workingreqcentral_o hq1_all_workingreqprovincial_o hq1_all_workingreqsubreg_o hq1_all_workingreqlocal_o hq1_all_workingreqschool_o ///
hq1_all_compensationcentral_o hq1_all_compensationprovincial_o hq1_all_compensationsubreg_o hq1_all_compensationlocal_o hq1_all_compensationschool_o ///
hq1_all_hygienecentral_o hq1_all_hygieneprovincial_o hq1_all_hygienesubreg_o hq1_all_hygienelocal_o hq1_all_hygieneschool_o ///
hq1_all_changescentral_o hq1_all_changesprovincial_o hq1_all_changessubreg_o hq1_all_changeslocal_o hq1_all_changesschool_o ///
hq1_all_schoolmulti hq1_all_adjustmentsmulti hq1_all_resourcesmulti hq1_all_addsupmulti hq1_all_workingreqmulti hq1_all_compensationmulti hq1_all_hygienemulti hq1_all_changesmulti

* Counting by each decision type
foreach i in school adjustments resources addsup workingreq compensation hygiene changes{
	tempfile hq1`i'
	preserve
	replace N = 0 if hq1_all_`i'central ==. &  hq1_all_`i'provincial ==. &  hq1_all_`i'subreg ==. &  hq1_all_`i'local ==. &  hq1_all_`i'school ==. 
  
	local variables hq1_all_`i'central_o hq1_all_`i'provincial_o hq1_all_`i'subreg_o hq1_all_`i'local_o hq1_all_`i'school_o hq1_all_`i'multi
	keep `variables' N population_0417 enrollment incomelevelname income_num

	collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
	concatenate_label_income_N
  
		foreach v in `variables'{
			replace `v'=`v'*100	
		}
	gen ISCED = "`i'"

	renvars hq1_all_`i'central_o hq1_all_`i'provincial_o hq1_all_`i'subreg_o hq1_all_`i'local_o hq1_all_`i'school_o hq1_all_`i'multi / central_o provincial_o subreg_o local_o school_o multi
	save `hq1`i''
	restore
}

drop _all
foreach i in school adjustments resources addsup workingreq compensation hygiene changes{
    append using `hq1`i''
}

    gen decision = "" 
  replace decision = "School closure and reopening" if strpos(ISCED, "school")
  replace decision = "Working requirements for teachers" if strpos(ISCED, "workingreq")
  replace decision = "Adjustments to school calendar" if strpos(ISCED, "adjustments")
  replace decision = "Resources to continue learning during school closures" if strpos(ISCED, "resources")
  replace decision = "Additional support programs for students after schools reopened" if strpos(ISCED, "addsup")
  replace decision = "Compensation of teachers" if strpos(ISCED, "compensation")
  replace decision = "Hygiene measures for school reopening" if strpos(ISCED, "hygiene")
  replace decision = "Changes in funding to schools" if strpos(ISCED, "changes")
  
order concat_label income_num decision

    label var central_o      		"Central Only"
	label var local_o   			"Local Only"
    label var provincial_o    	"Provincial/ Regional/ State Only"
	label var school_o  			"School Only"
    label var subreg_o         	"Sub-Regional/ Inter-Municipal only"
    label var multi        	"Multiple"
	
  * Create sheet in excel file for this table
  local variables central_o provincial_o subreg_o local_o school_o multi
  export excel concat_label decision `variables' if income_num==5 using `"${excelfile}"', sheet("`figure'", modify) $excelopt
  
    * Add country and population coverage to Annex
  preserve
  keep if income_num==5
  keep if decision == "School closure and reopening" 
  add_to_annex1, figure_number(`figure') question_number(`fig_q1a')
  restore
  
  preserve
  keep if income_num==5
  keep if decision == "Working requirements for teachers"
  add_to_annex1, figure_number(`figure') question_number(`fig_q1b')
  restore

  preserve
  keep if income_num==5
  keep if decision == "Adjustments to school calendar"
  add_to_annex1, figure_number(`figure') question_number(`fig_q1c')
  restore

  preserve
  keep if income_num==5
  keep if decision == "Resources to continue learning during school closures"
  add_to_annex1, figure_number(`figure') question_number(`fig_q1d')
  restore
  
  preserve
  keep if income_num==5
  keep if decision == "Additional support programs for students after schools reopened" 
  add_to_annex1, figure_number(`figure') question_number(`fig_q1e')
  restore
  
  preserve
  keep if income_num==5
  keep if decision == "Compensation of teachers" 
  add_to_annex1, figure_number(`figure') question_number(`fig_q1f')
  restore

  preserve
  keep if income_num==5
  keep if decision == "Hygiene measures for school reopening"
  add_to_annex1, figure_number(`figure') question_number(`fig_q1g')
  restore

  preserve
  keep if income_num==5
  keep if decision == "Changes in funding to schools"
  add_to_annex1, figure_number(`figure') question_number(`fig_q1h')
  restore
  
  keep if decision == "School closure and reopening" | decision == "Working requirements for teachers"
  
  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
  export excel concat_label decision `variables'  using `"${excelfile}"', sheet("`figure3'", modify) $excelopt

  * Add country and population coverage to Annex
  preserve
    keep if decision == "School closure and reopening" 
  add_to_annex1, figure_number(`figure3') question_number(`fig_q1a')
  restore
  
  keep if  decision == "Working requirements for teachers"
  add_to_annex1, figure_number(`figure3') question_number(`fig_q1b')  
****************************************************************
start_from_clean_file
 
  local figure2    "Figure 7-2" // Figure number
  *local figure    "F7.2" // Figure number
//   local fig_q     "HQ1"   // List all questions used

  local fig_q1a     "HQ1_School closure and reopening"   // List all questions used
  local fig_q1b     "HQ1_Working requirements for teachers"   // List all questions used
  
la def who 0 "None" ///
1 "Only Central" ///
2 "Only Regional" ///
3 "Only Sub-Regional" ///
4 "Only Local" ///
5 "Only School" ///
6 "Central & Regional" ///
7 "Central & Sub-Regional" ///
8 "Central & Local" ///
9 "Central & School" ///
10 "Regional & Sub-Regional" ///
11 "Regional & Local" ///
12 "Regional & School" ///
13 "Sub-Regional & Local" ///
14 "Sub-Regional & School" ///
15 "Local & School" ///
16 "Central & Regional & Sub-Regional" ///
17 "Central & Regional & Local" ///
18 "Central & Regional & School" ///
19 "Central & Sub-Regional & Local" ///
20 "Central & Sub-Regional & School" ///
21 "Central & Local & School" ///
22 "Regional & Sub-Regional & Local" ///
23 "Regional & Sub-Regional & School" ///
24 "Regional & Local & School" ///
25 "Sub-Regional & Local & School" ///
26 "Central & Regional & Sub-Regional & Local" ///
27 "Central & Regional & Sub-Regional & School" ///
28 "Central & Regional & Local & School" ///
29 "Central & Sub-Regional & Local & School" ///
30 "Regional & Sub-Regional & Local & School" ///
31 "Central & Regional & Sub-Regional & Local & School"

*adding in order to create variable name
glo string all_school all_adjustments all_resources all_addsup ///
 all_workingreq all_compensation all_hygiene all_changes

foreach l of global string{
gen cat_`l'=.

replace cat_`l'=0 if hq1_`l'central==0 &  ///
 hq1_`l'provincial==0 & /// 
 hq1_`l'subreg==0 & ///
 hq1_`l'local==0 & ///
 hq1_`l'school==0 

replace cat_`l'=1 if hq1_`l'central!=0 &  ///
 hq1_`l'provincial==0 & /// 
 hq1_`l'subreg==0 & ///
 hq1_`l'local==0 & ///
 hq1_`l'school==0 
 
replace cat_`l'=2 if  hq1_`l'central==0 & ///
 hq1_`l'provincial!=0 & /// 
 hq1_`l'subreg==0 & ///
 hq1_`l'local==0 & ///
 hq1_`l'school==0 
 
replace cat_`l'=3 if  hq1_`l'central==0 & ///
 hq1_`l'provincial==0 & /// 
 hq1_`l'subreg!=0 & ///
 hq1_`l'local==0 & ///
 hq1_`l'school==0 
 
replace cat_`l'=4 if  hq1_`l'central==0 & ///
 hq1_`l'provincial==0 & /// 
 hq1_`l'subreg==0 & ///
 hq1_`l'local!=0 & ///
 hq1_`l'school==0 
 
replace cat_`l'=5 if hq1_`l'central==0 & ///
 hq1_`l'provincial==0 & /// 
 hq1_`l'subreg==0 & ///
 hq1_`l'local==0 & ///
 hq1_`l'school!=0 
 
replace cat_`l'=6 if hq1_`l'central!=0 & ///
 hq1_`l'provincial!=0 & /// 
 hq1_`l'subreg==0 & ///
 hq1_`l'local==0 & ///
 hq1_`l'school==0 
 
replace cat_`l'=7 if hq1_`l'central!=0 & ///
 hq1_`l'provincial==0 & /// 
 hq1_`l'subreg!=0 & ///
 hq1_`l'local==0 & ///
 hq1_`l'school==0 
 
replace cat_`l'=8 if hq1_`l'central!=0 & ///
 hq1_`l'provincial==0 & /// 
 hq1_`l'subreg==0 & ///
 hq1_`l'local!=0 & ///
 hq1_`l'school==0 
 
replace cat_`l'=9 if hq1_`l'central!=0 & ///
 hq1_`l'provincial==0 & /// 
 hq1_`l'subreg==0 & ///
 hq1_`l'local==0 & ///
 hq1_`l'school!=0 
 
replace cat_`l'=10 if hq1_`l'central==0 & ///
 hq1_`l'provincial!=0 & /// 
 hq1_`l'subreg!=0 & ///
 hq1_`l'local==0 & ///
 hq1_`l'school==0 
 
replace cat_`l'=11 if hq1_`l'central==0 & ///
 hq1_`l'provincial!=0 & /// 
 hq1_`l'subreg==0 & ///
 hq1_`l'local!=0 & ///
 hq1_`l'school==0 
 
replace cat_`l'=12 if hq1_`l'central==0 & ///
 hq1_`l'provincial!=0 & /// 
 hq1_`l'subreg==0 & ///
 hq1_`l'local==0 & ///
 hq1_`l'school!=0 
 
replace cat_`l'=13 if hq1_`l'central==0 & ///
 hq1_`l'provincial==0 & /// 
 hq1_`l'subreg!=0 & ///
 hq1_`l'local!=0 & ///
 hq1_`l'school==0 
 
replace cat_`l'=14 if hq1_`l'central==0 & ///
 hq1_`l'provincial==0 & /// 
 hq1_`l'subreg!=0 & ///
 hq1_`l'local==0 & ///
 hq1_`l'school!=0 
 
replace cat_`l'=15 if hq1_`l'central==0 & ///
 hq1_`l'provincial==0 & /// 
 hq1_`l'subreg==0 & ///
 hq1_`l'local!=0 & ///
 hq1_`l'school!=0 
 
 replace cat_`l'=16 if hq1_`l'central!=0 & ///
 hq1_`l'provincial!=0 & /// 
 hq1_`l'subreg!=0 & ///
 hq1_`l'local==0 & ///
 hq1_`l'school==0 
 
replace cat_`l'=17 if hq1_`l'central!=0 & ///
 hq1_`l'provincial!=0 & /// 
 hq1_`l'subreg==0 & ///
 hq1_`l'local!=0 & ///
 hq1_`l'school==0 
 
replace cat_`l'=18 if hq1_`l'central!=0 & ///
 hq1_`l'provincial!=0 & /// 
 hq1_`l'subreg==0 & ///
 hq1_`l'local==0 & ///
 hq1_`l'school!=0 
 
replace cat_`l'=19 if hq1_`l'central!=0 & ///
 hq1_`l'provincial==0 & /// 
 hq1_`l'subreg!=0 & ///
 hq1_`l'local!=0 & ///
 hq1_`l'school==0 

replace cat_`l'=20 if hq1_`l'central!=0 & ///
 hq1_`l'provincial==0 & /// 
 hq1_`l'subreg!=0 & ///
 hq1_`l'local==0 & ///
 hq1_`l'school!=0 
 
replace cat_`l'=21 if hq1_`l'central!=0 & ///
 hq1_`l'provincial==0 & /// 
 hq1_`l'subreg==0 & ///
 hq1_`l'local!=0 & ///
 hq1_`l'school!=0 
 
replace cat_`l'=22 if hq1_`l'central==0 & ///
 hq1_`l'provincial!=0 & /// 
 hq1_`l'subreg!=0 & ///
 hq1_`l'local!=0 & ///
 hq1_`l'school==0 
 
replace cat_`l'=23 if hq1_`l'central==0 & ///
 hq1_`l'provincial!=0 & /// 
 hq1_`l'subreg!=0 & ///
 hq1_`l'local==0 & ///
 hq1_`l'school!=0 
 
replace cat_`l'=24 if hq1_`l'central==0 & ///
 hq1_`l'provincial!=0 & /// 
 hq1_`l'subreg==0 & ///
 hq1_`l'local!=0 & ///
 hq1_`l'school!=0 
 
replace cat_`l'=25 if hq1_`l'central==0 & ///
 hq1_`l'provincial==0 & /// 
 hq1_`l'subreg!=0 & ///
 hq1_`l'local!=0 & ///
 hq1_`l'school!=0 
 
replace cat_`l'=26 if hq1_`l'central!=0 & ///
 hq1_`l'provincial!=0 & /// 
 hq1_`l'subreg!=0 & ///
 hq1_`l'local!=0 & ///
 hq1_`l'school==0 
 
replace cat_`l'=27 if hq1_`l'central!=0  & ///
 hq1_`l'provincial!=0 & /// 
 hq1_`l'subreg!=0 & ///
 hq1_`l'local==0 & ///
 hq1_`l'school!=0 
 
replace cat_`l'=28 if hq1_`l'central!=0 & ///
 hq1_`l'provincial!=0 & /// 
 hq1_`l'subreg==0 & ///
 hq1_`l'local!=0 & ///
 hq1_`l'school!=0 
 
replace cat_`l'=29 if hq1_`l'central!=0 & ///
 hq1_`l'provincial==0 & /// 
 hq1_`l'subreg!=0 & ///
 hq1_`l'local!=0 & ///
 hq1_`l'school!=0 
 
replace cat_`l'=30 if hq1_`l'central==0 & ///
 hq1_`l'provincial!=0 & /// 
 hq1_`l'subreg!=0 & ///
 hq1_`l'local!=0 & ///
 hq1_`l'school!=0 
 
replace cat_`l'=31 if hq1_`l'central!=0 & ///
 hq1_`l'provincial!=0 & /// 
 hq1_`l'subreg!=0 & ///
 hq1_`l'local!=0 & ///
 hq1_`l'school!=0 
la val cat_`l' who
}
*labeling of the variables
la var cat_all_school "School closure and reopening"
la var cat_all_adjustments "Adjustments to school calendar"
la var cat_all_resources "Resources to continue learning during school closures"
la var cat_all_addsup "Additional support programs"
la var cat_all_workingreq "Working requirements for teachers"
la var cat_all_compensation "Compensation of teachers"
la var cat_all_hygiene "Hygiene measures for school reopening"
la var cat_all_changes "Changes in funding to schools"

la def who2 0 "None" ///
1 "Only Central" ///
2 "Only Regional" ///
3 "Only Sub-Regional" ///
4 "Only Local" ///
5 "Only School" ///
6 "Multiple"
foreach l of global string{
gen cat_1_`l'=cat_`l'
replace cat_1_`l'=6 if cat_`l'>=6
la val cat_1_`l' who2
}

la var cat_1_all_school "School closure and reopening"
la var cat_1_all_adjustments "Adjustments to school calendar"
la var cat_1_all_resources "Resources to continue learning during school closures"
la var cat_1_all_addsup "Additional support programs for students after schools reopened"
la var cat_1_all_workingreq "Working requirements for teachers"
la var cat_1_all_compensation "Compensation of teachers"
la var cat_1_all_hygiene "Hygiene measures for school reopening"
la var cat_1_all_changes "Changes in funding to schools"

foreach l of global string{
 tab cat_`l'
 tab cat_1_`l'
}
        
// keep cat_all_school  countrycode incomelevelname income_num enrollment population_0417 N

keep if income_num ==5

preserve
** schools
keep cat_all_school  cat_1_all_school  countrycode incomelevelname income_num enrollment population_0417 N

keep if cat_1_all_school ==6
drop  cat_1_all_school


spread cat_all_school N

foreach v of varlist N*{
replace `v'  =0 if `v'==.
}
gen uno=1
collapse (mean) N* (sum) uno population_0417 enrollment (first) incomelevelname, by(income_num)

gather N*, variable(cat)
rename uno N
replace cat = subinstr(cat, "N", "",.)
destring cat, replace

la def who 0 "None" ///
1 "Only Central" ///
2 "Only Regional" ///
3 "Only Sub-Regional" ///
4 "Only Local" ///
5 "Only School" ///
6 "Central & Regional" ///
7 "Central & Sub-Regional" ///
8 "Central & Local" ///
9 "Central & School" ///
10 "Regional & Sub-Regional" ///
11 "Regional & Local" ///
12 "Regional & School" ///
13 "Sub-Regional & Local" ///
14 "Sub-Regional & School" ///
15 "Local & School" ///
16 "Central & Regional & Sub-Regional" ///
17 "Central & Regional & Local" ///
18 "Central & Regional & School" ///
19 "Central & Sub-Regional & Local" ///
20 "Central & Sub-Regional & School" ///
21 "Central & Local & School" ///
22 "Regional & Sub-Regional & Local" ///
23 "Regional & Sub-Regional & School" ///
24 "Regional & Local & School" ///
25 "Sub-Regional & Local & School" ///
26 "Central & Regional & Sub-Regional & Local" ///
27 "Central & Regional & Sub-Regional & School" ///
28 "Central & Regional & Local & School" ///
29 "Central & Sub-Regional & Local & School" ///
30 "Regional & Sub-Regional & Local & School" ///
31 "Central & Regional & Sub-Regional & Local & School"

lab values cat who

gen decision = "School closure and reopening"
tempfile f7_3_school
save `f7_3_school'
restore

preserve
** working requirements
keep cat_all_workingreq  cat_1_all_workingreq  countrycode incomelevelname income_num enrollment population_0417 N

keep if cat_1_all_workingreq  ==6
drop  cat_1_all_workingreq 

spread cat_all_workingreq N

foreach v of varlist N*{
replace `v'  =0 if `v'==.
}
gen uno=1
collapse (mean) N* (sum) uno population_0417 enrollment (first) incomelevelname, by(income_num)

gather N*, variable(cat)
rename uno N
replace cat = subinstr(cat, "N", "",.)
destring cat, replace

la def who 0 "None" ///
1 "Only Central" ///
2 "Only Regional" ///
3 "Only Sub-Regional" ///
4 "Only Local" ///
5 "Only School" ///
6 "Central & Regional" ///
7 "Central & Sub-Regional" ///
8 "Central & Local" ///
9 "Central & School" ///
10 "Regional & Sub-Regional" ///
11 "Regional & Local" ///
12 "Regional & School" ///
13 "Sub-Regional & Local" ///
14 "Sub-Regional & School" ///
15 "Local & School" ///
16 "Central & Regional & Sub-Regional" ///
17 "Central & Regional & Local" ///
18 "Central & Regional & School" ///
19 "Central & Sub-Regional & Local" ///
20 "Central & Sub-Regional & School" ///
21 "Central & Local & School" ///
22 "Regional & Sub-Regional & Local" ///
23 "Regional & Sub-Regional & School" ///
24 "Regional & Local & School" ///
25 "Sub-Regional & Local & School" ///
26 "Central & Regional & Sub-Regional & Local" ///
27 "Central & Regional & Sub-Regional & School" ///
28 "Central & Regional & Local & School" ///
29 "Central & Sub-Regional & Local & School" ///
30 "Regional & Sub-Regional & Local & School" ///
31 "Central & Regional & Sub-Regional & Local & School"

lab values cat who

gen decision = "Working requirements for teachers"
tempfile f7_3_wreq
save `f7_3_wreq'
restore

drop _all
append using `f7_3_wreq'  `f7_3_school'
replace value = value*100

  concatenate_label_income_N
  
  * Create sheet in excel file for this table
  export excel concat_label decision cat value if income_num==5 using `"${excelfile}"', sheet("`figure2'", modify) $excelopt

  * Add country and population coverage to Annex
  preserve
    keep if decision == "School closure and reopening" 
  add_to_annex1, figure_number(`figure2') question_number(`fig_q1a')
  restore
  
  keep if  decision == "Working requirements for teachers"
  add_to_annex1, figure_number(`figure2') question_number(`fig_q1b')  

  
  
  
  
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
* 2) ANNEX OF COUNTRY AND POPULATION COVERAGE 
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------  

****************for annex 0 // the general tables showing N for valid answers and total world

*CHECK IF NECESSARY TO ADD
/*use "${Data_clean}/save_all_countries.dta", clear

tab income_num

collapse (sum) N_total = N pop_total = population_0417 enr_total = enrollment, by(income_num)

label var N_total    "Total number of countries in the world"
label var pop_total  "Total population coverage (total population aged 4-17)"
label var enr_total  "Total enrollment coverage"

tempfile full_coverage
save `full_coverage', replace
*/
use  "${Data_clean}jsw3_uis_oecd_clean.dta", clear

 * Expand dataset prior to collapse so that Global becomes a category
  expand 2, gen(expanded)
  replace income_num = 5              if expanded == 1
  replace incomelevelname  = "Global" if expanded == 1
  
tab income_num

label define income_numl 1 "Low income" 2 "Lower middle income" 3 "Upper middle income" 4 "High income" 5 "Global", modify
label value income_num income_numl

collapse (sum)  N population_0417 enrollment, by(income_num)

label var income_num       "Income Level"
label var N                "Number of countries that participated"
label var population_0417  "Total population aged 4-17"
label var enrollment       "Enrollment"

*merge 1:1 income_num using `full_coverage', nogen

export excel using `"${excelfile}"', sheet("Annex 0", modify) cell(A4) firstrow(varlabels)

****************for annex 1

use "${Data_clean}/save_all_countries.dta", clear

* What full coverage would look like (question-invatiant)
collapse (sum) N_total = N pop_total = population_0417 enr_total = enrollment , by(income_num)

tempfile full_coverage
save `full_coverage', replace

* Start with the appended values of N and pop from all tables
use "${Table}/annex1.dta", clear

rename population_0417 pop_covered
rename enrollment enr_covered

label var figure_number   "Figure number"
label var question_number "Question(s) used for this figure"
label var income_num      "Income level name"
label var N               "Number of countries with valid answers"
label var pop_covered     "Population ages 04-17 covered by valid answers"  
label var enr_covered     "Students in basic education covered by valid answers"  

* Bring in what full coverage looks like
merge m:1 income_num using `full_coverage', nogen

* Country & population coverage in relative terms
gen cty_coverage = 100 * N / N_total
gen pop_coverage = 100 * pop_covered / pop_total
gen enr_coverage = 100 * enr_covered / enr_total
label var cty_coverage "Share of countries covered (%)"
label var pop_coverage "Population coverage (% of population 04-17)"
label var enr_coverage "Student coverage (% of pre-primary, primary and secondary enrollment)"

replace pop_coverage = round(pop_coverage,1) 
replace enr_coverage = round(enr_coverage,1) 

*this can be added when the figure naming changes 
*gen aux_sort = real(substr(figure_number, 7, .))
*sort aux_sort income_num

* Export into Annex1
local vars4excel "figure_number question_number income_num N pop_coverage enr_coverage"
order `vars4excel'  
 
sort figure_number income_num question_number

export excel `vars4excel' using `"${excelfile}"', sheet("Annex 1", modify) cell(A4)

****************for annex 2

* Start with the appended values of N and pop from all tables
use "${Table}/annex2.dta", clear

label var figure_number   "Figure Number"
label var question_number "Questions"
label var income_num      "Income Level"
label var N_preprimary    "Number of Countries with a valid answer for Pre-Primary education"
label var N_primary       "Number of Countries with a valid answer for Primary education"
label var N_lsecondary    "Number of Countries with a valid answer for Lower Secondary education"
label var N_usecondary    "Number of Countries with a valid answer for Upper Secondary education"

*replace pop_coverage = round(pop_coverage,1) 
*replace enr_coverage = round(enr_coverage,1) 

* Export into Annex2
local vars4excel "figure_number question_number income_num N_preprimary N_primary N_lsecondary N_usecondary"
order `vars4excel'  

sort figure_number income_num question_number

export excel `vars4excel' using `"${excelfile}"', sheet("Annex 2", modify) cell(A4) firstrow(varlabels)

erase "${Table}/annex1.dta"
erase "${Table}/annex2.dta"

