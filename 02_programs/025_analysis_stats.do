*=========================================================================*
* Project information at: https://github.com/worldbank/schoolsurvey-production
****** Country: Worldwide
****** Purpose: producing stats for report 2- UNESCO-UNICEF-WBG_OECD Survey on National education responses to COVID-19 - Round 3
****** Created by: UNESCO, UNICEF, WORLD BANK, OECD
****** Used by: UNESCO, UNICEF, WORLD BANK, OECD
****** Input  data : jsw3_uis_oecd_clean.dta            
****** Output data : TEMPLATE.xlsx, tables_for_figures_original_JSW3.xlsx, annex1, annex2 
****** Language: English
*=========================================================================*

** Steps in this do-file:

* 0) Import data
* 1) Stats production
* 2) ANNEX: country sample, and population and enrolment coverage

*THIS DO FILE IS ORGANIZED BY THE REPORT SECTIONS:
*Section 1: Learning Loss School closures & School calendar and curricula 
*Section 2: Learning assessment and examinations
*Section 3: Distance education delivery systems
*Section 4: Teachers and educational personnel
*Section 5: School reopening management
*Section 6: Financing 
*Section 7: Locus of decision making of public institutions

*** Steps for stat production:
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
* 1) Stats Production 
*---------------------------------------------------------------------------

* ALL Report SECTIONS
*---------------------------------------------------------------------------
* Section 1. School Closures
*---------------------------------------------------------------------------
	// Export another sheet with all the referenced text
  local figure    "R1.BQ1" // Figure number
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
	
  local variables all_prioritizationofcerta all_depends all_academicyearextended all_no all_others
    
   export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt
	
********************************************************************
*S2/bq2/Q2. Is there a plan to revise regulation (at the national level) on the duration of instruction time and content of curriculum regulations after school year 2020/2021 (2021 for countries with calendar year) as a result of the COVID19 pandemic? 

	start_from_clean_file 

  local figure    "R1.BQ2" // Figure number
  local fig_q     "BQ2"   // List all questions used
	
	keep bq2_all_regulation countrycode income_num N incomelevelname population_0417 enrollment
 
	replace bq2_all_regulation = . if bq2_all_regulation == 999 | bq2_all_regulation == 997 | bq2_all_regulation == 998
	replace bq2_all_regulation = bq2_all_regulation * 100
	
 
 	local variables bq2_all_regulation

  *B Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
	
	sort income_num 

  *C Beautify table
  format `variables' %3.0f
	foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
  
  * Create sheet in excel file for this table
  export excel concat_label bq2_all_regulation using `"${excelfile}"', sheet("`figure'", modify) $excelopt

*---------------------------------------------------------------------------
* Section 2. Learning Assessments and Examinations
*---------------------------------------------------------------------------  
  
*---------------------------------------------------------------------------
* Section 3. Distance Education Delivery Systems 
*---------------------------------------------------------------------------
* DQ1:  Which distance learning solutions were or are being offered in your country during the pandemic in 2020 and/or 2021? (Select all that apply)”
* Figure 3.2:  Number of DL modalities provided per country

  start_from_clean_file
  
  local figure    "R. 3.2 DQ1" // Figure number
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
	* somedl_*educlevel* : Country providing some modality of DL at each *educ level*
	foreach i in pp p ls us {
		gen somedl_`i' = 1 if dq1_`i'_onlineplatforms == 1 | dq1_`i'_television  == 1 | dq1_`i'_mobilephones == 1 | dq1_`i'_radio == 1 | dq1_`i'_takehomepackages == 1 | dq1_`i'_otherdistancelearningm == 1
		replace somedl_`i' = 0 if dq1_`i'_onlineplatforms != 1 & dq1_`i'_television  != 1  & dq1_`i'_mobilephones != 1 & dq1_`i'_radio != 1 & dq1_`i'_takehomepackages != 1 & dq1_`i'_otherdistancelearningm != 1
		replace somedl_`i' = . if dq1_`i'_onlineplatforms == . & dq1_`i'_television  == . & dq1_`i'_mobilephones == . & dq1_`i'_radio == . & dq1_`i'_takehomepackages == . & dq1_`i'_otherdistancelearningm == .
		}
	
	gen somedl_all = 1 if somedl_pp == 1 | somedl_p == 1 | somedl_ls == 1 | somedl_us == 1 
	replace somedl_all = 0 if somedl_pp == 0 & somedl_p == 0 & somedl_ls == 0 & somedl_us == 0

	* local for all variables used in analysis
	local variablestxt somedl_all somedl_pp somedl_p somedl_ls somedl_us
  
   foreach i of local variablestxt {
  replace   `i' =`i'*100
  }

    * list of variables outputted for text
	local variablestxt somedl_all somedl_pp somedl_p somedl_ls somedl_us
	
******** 	Step B - Create collapsed table that will go into excel *******

collapse (mean) `variablestxt'  (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
	concatenate_label_income_N

*install labvars package
	labvars somedl_all somedl_pp somedl_p somedl_ls somedl_us ///
			"Some DL: Across levels" ///
			"Some DL: Pre primary" ///
			"Some DL: Primary" ///
			"Some DL: Lower secondary" ///
			"Some DL: Upper secondary" 

  * Beautify table
  format `variablestxt' %3.0f	
  
  * Sorting in the right order for the fiugre production
  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }

* Create sheet in excel file for this table
  export excel concat_label `variablestxt' using `"${excelfile}"', sheet("`figure'", modify) firstrow(varlabels) cell(A20)

  
****************************************************************
* S10 Q1:If the country’s national distance strategy included broadcasting lessons on television or radio, what proportion of the population is reached by television and radio?
* Report section: "The mere supply of remote learning will not automatically ensure take-up"

* open clean file
start_from_clean_file

  local figure    "R Sec 3 JQ1" // Figure number
  local fig_q     "JQ1"   // List all questions used

keep jq1_pp jq1_p jq1_ls jq1_us jq2a jq2b jq2c jq2d ///
	countrycode income_num N incomelevelname population_0417 enrollment

********	Step A - Define locals and adjust aggregation levels as needed for analysis
foreach j in pp p ls us {
	foreach cat in 1 2 3 4 5 6 {
		gen jq1_`j'_`cat' = 1 if jq1_`j' == `cat'
		replace jq1_`j'_`cat' = 0 if jq1_`j'  != `cat' & jq1_`j'  != .
			}
	}

* local for all variables used in analysis
  local variables jq1_pp_1 jq1_pp_2 jq1_pp_3 jq1_pp_4 jq1_pp_5 jq1_pp_6 ///
		jq1_p_1 jq1_p_2 jq1_p_3 jq1_p_4 jq1_p_5 jq1_p_6 ///
		jq1_ls_1 jq1_ls_2 jq1_ls_3 jq1_ls_4 jq1_ls_5 jq1_ls_6 ///
		jq1_us_1 jq1_us_2 jq1_us_3 jq1_us_4 jq1_us_5 jq1_us_6
                  
  foreach i of local variables {
  replace   `i' =`i'*100
  }
  
******** 	Step B - Create collapsed table that will go into excel *******
missings dropobs `variables', force

collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  la var jq1_p_1 "Primary: Less than 25%"
  la var jq1_p_2 "Primary: More than 25% but less than 50%"
  la var jq1_p_3 "Primary: About half of the students"
  la var jq1_p_4 "Primary: More than 50% but less than 75%"
  la var jq1_p_5 "Primary: More than 75% but not all of the students"
  la var jq1_p_6 "Primary: All of the students"

  la var jq1_pp_1 "Pre Primary: Less than 25%"
  la var jq1_pp_2 "Pre Primary: More than 25% but less than 50%"
  la var jq1_pp_3 "Pre Primary: About half of the students"
  la var jq1_pp_4 "Pre Primary: More than 50% but less than 75%"
  la var jq1_pp_5 "Pre Primary: More than 75% but not all of the students"
  la var jq1_pp_6 "Pre Primary: All of the students"
  
  la var jq1_ls_1 "Lower secondary: Less than 25%"
  la var jq1_ls_2 "Lower secondary: More than 25% but less than 50%"
  la var jq1_ls_3 "Lower secondary: About half of the students"
  la var jq1_ls_4 "Lower secondary: More than 50% but less than 75%"
  la var jq1_ls_5 "Lower secondary: More than 75% but not all of the students"
  la var jq1_ls_6 "Lower secondary: All of the students"
  
  la var jq1_us_1 "Upper secondary: Less than 25%"
  la var jq1_us_2 "Upper secondary: More than 25% but less than 50%"
  la var jq1_us_3 "Upper secondary: About half of the students"
  la var jq1_us_4 "Upper secondary: More than 50% but less than 75%"
  la var jq1_us_5 "Upper secondary: More than 75% but not all of the students"
  la var jq1_us_6 "Upper secondary: All of the students"

* Beautify table
  format `variables' %3.0f		

* Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt
  
  
****************************************************************
* S4 Q3: Has any study or assessment been carried out (at the regional or national level) in 2020 to assess the effectiveness of distance-learning strategies
* Report section: "It is critical to generate better evidence on the effectiveness of remote learning "

* open clean file
start_from_clean_file

  local figure    "R Sec 3 DQ3" // Figure number
  local fig_q     "DQ3"   // List all questions used

keep dq3_all_onlineplatforms dq3_all_television dq3_all_mobilephones ///
	dq3_all_radio dq3_all_takehomepackages dq3_all_otherdistancelearning ///
	countrycode income_num N incomelevelname population_0417 enrollment

gen dq3_any = 1 if dq3_all_onlineplatforms == 1 | dq3_all_television == 1 | dq3_all_mobilephones == 1 | dq3_all_radio == 1 | dq3_all_takehomepackages == 1 | dq3_all_otherdistancelearning== 1 
replace dq3_any = 0 if 	dq3_all_onlineplatforms == 0 & dq3_all_television ==  0 & dq3_all_mobilephones ==  0 & dq3_all_radio ==  0 & dq3_all_takehomepackages ==  0 & dq3_all_otherdistancelearning== 0 

local variables dq3_all_onlineplatforms dq3_all_television dq3_all_mobilephones ///
	dq3_all_radio dq3_all_takehomepackages dq3_all_otherdistancelearning dq3_any

missings dropobs `variables', force

collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
    
* Beautify table
  format `variables' %3.0f		

* Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  
****************************************************************
* S5 Q4: How and at what scale were teachers (in pre-primary to upper secondary levels combined) supported in the transition to remote learning in 2020? [Select all that apply]
* Report section: "Support teachers to transition to remote learning "
 
start_from_clean_file

  local figure    "R Sec 3 EQ4" // Figure number
  local fig_q     "EQ4"   // List all questions used
  
  local variables eq4_all_natofferedspecial eq4_all_natinstruction eq4_all_natppe eq4_all_natguidelines eq4_all_natprofessionaldev eq4_all_natteachingcontent eq4_all_naticttools eq4_all_natother eq4_all_natnoadditionalsup
  
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
  label var eq4_all_natguidelines "Guideline for efficiency in remote teaching"
  label var eq4_all_natprofessionaldev "Professional development activities"
  label var eq4_all_natteachingcontent "Teaching content for remote teaching"
  label var eq4_all_naticttools "Provision of ICT tools and connectivity"
  label var eq4_all_natother "Other supports"
  la var eq4_all_natnoadditionalsup "No additional support"
 
  * Beautify table
  format `variables' %3.0f
  
  * Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  
****************************************************************
* S9 Q3: Which of the following measures have been taken to support the education (ISCED 0 to ISCED 3) of vulnerable groups during the pandemic?
* Report section: "Facilitate access and take-up of remote learning among the most marginalized students "

* open clean file
start_from_clean_file

  local figure    "R Sec 3 IQ3" // Figure number
  local fig_q     "IQ3"   // List all questions used

keep iq3_all_addfinancechildren iq3_all_addfinancerefugees iq3_all_addfinanceethnic ///
	iq3_all_addfinancegirls iq3_all_addfinanceother iq3_all_specialeffortchildren ///
	iq3_all_specialeffortrefugees iq3_all_specialeffortethnic iq3_all_specialeffortgirls ///
	iq3_all_specialeffortother iq3_all_subsdevicechildren iq3_all_subsdevicerefugees ///
	iq3_all_subsdeviceethnic iq3_all_subsdevicegirls iq3_all_subsdeviceother ///
	iq3_all_tailorlearnchildren iq3_all_tailorlearnrefugees iq3_all_tailorlearnethnic ///
	iq3_all_tailorlearngirls iq3_all_tailorlearnother iq3_all_flexiblechildren ///
	iq3_all_flexiblerefugees iq3_all_flexibleethnic iq3_all_flexiblegirls iq3_all_flexibleother ///
	iq3_all_donotknowchildren iq3_all_donotknowrefugees iq3_all_donotknowethnic ///
	iq3_all_donotknowgirls iq3_all_donotknowother iq3_all_nonechildren iq3_all_nonerefugees ///
	iq3_all_noneethnic iq3_all_nonegirls iq3_all_noneother iq3_all_otherchildren ///
	iq3_all_otherrefugees iq3_all_otherethnic iq3_all_othergirls iq3_all_otherother ///
	countrycode income_num N incomelevelname population_0417 enrollment

foreach grp in children refugees ethnic girls other {
	gen iq3_any_`grp' = 1 if iq3_all_addfinance`grp' == 1 | iq3_all_specialeffort`grp' == 1 | iq3_all_subsdevice`grp' == 1 | iq3_all_tailorlearn`grp' == 1 | iq3_all_flexible`grp' == 1 | iq3_all_other`grp' == 1 
	replace iq3_any_`grp' = 0 if iq3_all_none`grp' == 1
	}

local variables iq3_any_children iq3_any_refugees iq3_any_ethnic iq3_any_girls iq3_any_other iq3_all_nonechildren iq3_all_nonerefugees iq3_all_noneethnic iq3_all_nonegirls iq3_all_noneother
foreach i of local variables {
  replace   `i' =`i'*100
  }	
  
missings dropobs `variables', force

collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
 
la var iq3_any_children "Any measure: CwD"
la var iq3_any_refugees "Any measure: Refugees"
la var iq3_any_ethnic "Any measure: Ethnic minorities"
la var iq3_any_girls "Any measure: Girls"
la var iq3_any_other "Any measure: Other"
la var iq3_all_nonegirls "No measures: Girls"

local variablesrep iq3_any_* iq3_all_nonegirls

* Beautify table
  format `variablesrep' %3.0f		

* Create sheet in excel file for this table
  export excel concat_label `variablesrep' using `"${excelfile}"', sheet("`figure'", modify) $excelopt
  
  
****************************************************************
* S10 Q2: [Policy/Funding/PPP/M&E] For each of the below categories please select from 1-4 which statement best reflects the state of digital learning and ICT in your country.* Report section: "Facilitate access and take-up of remote learning among the most marginalized students "

start_from_clean_file

  local figure    "R Sec3 JQ2" // Figure number
  local fig_q     "JQ2"   // List all questions used
  
foreach var in a b c d {
	foreach lev in 1 2 3 4 {
		gen jq2`var'_`lev' = 1 if jq2`var' == `lev' 
		replace jq2`var'_`lev' = 0 if jq2`var' != `lev' & jq2`var' !=.
		}
		}
		
local variables jq2a_1 jq2a_2 jq2a_3 jq2a_4 jq2b_1 jq2b_2 jq2b_3 jq2b_4 jq2c_1 jq2c_2 jq2c_3 jq2c_4 jq2d_1 jq2d_2 jq2d_3 jq2d_4
foreach i of local variables {
  replace   `i' =`i'*100
  }	
  
missings dropobs `variables', force

collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
foreach lev in 1 2 3 4 {
	la var jq2a_`lev' "Policy: level `lev'"
	la var jq2b_`lev' "Funding: level `lev'"
	la var jq2c_`lev' "PPP: level `lev'"
	la var jq2d_`lev' "M&E: level `lev'"
		}
    
  * Beautify table
  format `variables' %3.0f		

* Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt
  

*---------------------------------------------------------------------------
* Section 4. Teachers 
*---------------------------------------------------------------------------

* EQ4: How and at what scale were teachers (in pre-primary to upper secondary levels combined) supported in the transition to remote learning in 2020? [Select all that apply] 
start_from_clean_file

local variables ///
eq4_all_natofferedspecial eq4_all_natinstruction eq4_all_natppe eq4_all_natguidelines eq4_all_natprofessionaldev eq4_all_natteachingcontent eq4_all_naticttools eq4_all_natnoadditionalsup eq4_all_natother  ///
eq4_all_subnatofferedspecial eq4_all_subnatinstruction eq4_all_subnatppe eq4_all_subnatguidelines eq4_all_subnatprofessionaldev eq4_all_subnatteachingcontent eq4_all_subnaticttools eq4_all_subnatother eq4_all_subnatnoadditionalsup ///
eq4_all_schoolofferedspecial eq4_all_schoolinstruction eq4_all_schoolppe eq4_all_schoolguidelines eq4_all_schoolprofessionaldev eq4_all_schoolteachingcontent eq4_all_schoolicttools eq4_all_schoolnoadditionalsup eq4_all_schoolother

* Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  
  foreach i of local variables {
  gen     V_`i' =.
  replace V_`i' =1 if `i' ==1 | `i' ==0 
  gen     Y_`i' =.
  replace Y_`i' =1 if `i' ==1
  replace   `i' =. if `i' ==997
  }
 
  collapse (mean)  eq4_all_* (sum) N V_* Y_* population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  save "${Data_clean}Temp_1.dta", replace
  
  foreach Answer in V Y {
  use "${Data_clean}Temp_1.dta", clear
  local figure    "R. EQ4 (`Answer')" // Figure number
  local fig_q     "EQ4"   // List all questions used
  * Output the number of valid answer for each questions
  keep `Answer'_* income_num concat_label
  reshape long `Answer'_, i(income_num concat_label) j(String) string
  gen Area=""
  gen ID=""
  foreach i in offeredspecial guidelines icttools instruction noadditionalsup other ppe professionaldev teachingcontent {
  replace ID="`i'" if strpos(String, "`i'")
  }
  foreach i in nat subnat school {
  replace Area="`i'" if strpos(String, "`i'")
  }
  drop String
  reshape wide  `Answer'_, i(ID concat_label) j(Area) string
  drop if ID=="other"
  drop if ID=="noadditionalsup"
  
  * Create sheet in excel file for this table
  export excel concat_label ID `Answer'_* using `"${excelfile}"', sheet("`figure'", modify) $excelopt
  }

****************************************************************  
  local figure    "R. 4.XX" // Figure number
  local fig_q     "EQ4"   // List all questions used

  * Output mean answer for this question
  use "${Data_clean}Temp_1.dta", clear
  reshape long eq4_all_, i(income_num concat_label) j(String) string
  
  gen Area=""
  gen ID=""
  foreach i in offeredspecial guidelines icttools instruction noadditionalsup other ppe professionaldev teachingcontent {
  replace ID="`i'" if strpos(String, "`i'")
  }
  foreach i in nat subnat school {
  replace Area="`i'" if strpos(String, "`i'")
  }
  drop String
  replace eq4_all_=eq4_all_*100
  
  reshape wide  eq4_all_, i(ID concat_label) j(Area) string
  drop if ID=="other"
  drop if ID=="noadditionalsup"
  
  label var eq4_all_nat "National"
  label var eq4_all_subnat "Sub national"
  label var eq4_all_school "School-by-school basis"
 
  * Beautify table
  format eq4_all_nat eq4_all_subnat eq4_all_school %3.0f
  
  * Create sheet in excel file for this table
  export excel concat_label ID eq4_all_nat eq4_all_subnat eq4_all_school using `"${excelfile}"', sheet("`figure'", modify) $excelopt
  
  erase "${Data_clean}Temp_1.dta"
  
**************************************************************
********Other figures/ statistics for section 4
* Eq1a: eq1a_all_premises If answered “yes , all teachers” to question 1, are or were they able to teach from the school premises? 
start_from_clean_file

  local figure    "R.4.Eq1a" // Figure number
  local fig_q     "EQ1a_all_premises"   // List all questions used
  
  keep  eq1a_all_premises countrycode income_num N incomelevelname population_0417 enrollment
  replace eq1a_all_premises=. if eq1a_all_premises==997 | eq1a_all_premises==998 | eq1a_all_premises==999
  
  local variables eq1a_all_premises 
  missings dropobs `variables', force
  
  * Gen dummy variables: 0-100 for figure 
  *S5Q1a.
	foreach v in eq1a_all_premises {
	levelsof `v'
	foreach value in `r(levels)' {
	gen     `v'_`value'=0
	replace `v'_`value'=100 if `v'==`value'
	replace `v'_`value'=. if `v'==.
	label var `v'_`value' "`: label (`v') `value''"
	}
	}
  
  local variables eq1a_all_premises_0 eq1a_all_premises_1
   
  * Create the collapsed table that will go into the Excel 
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
    
  label var eq1a_all_premises_0 "Yes"
  label var eq1a_all_premises_1 "No"

    * Beautify table
  format `variables' %3.0f

  * Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

*EQ2: S5Q2. Have there been changes to teacher pay and, benefits due to the period(s) of school closures in 2020?
* Items to discuss
start_from_clean_file

  local figure    "R. 4.X" // Figure number
  local fig_q     "EQ2"   // List all questions used
  
  keep  eq2_pp_pay eq2_p_pay eq2_ls_pay eq2_us_pay countrycode income_num N incomelevelname population_0417 enrollment
  foreach i in eq2_pp_pay eq2_p_pay eq2_ls_pay eq2_us_pay {
  replace `i'=. if `i'==997
  }
  
  missings dropobs eq2_pp_pay eq2_p_pay eq2_ls_pay eq2_us_pay, force
  
  gen eq2_pay=3
  
  replace eq2_pay=4 if eq2_pp_pay==4 | eq2_p_pay==4 |eq2_ls_pay==4 | eq2_us_pay==4 // Discretion of schools/districs
  replace eq2_pay=1 if eq2_pp_pay==1 | eq2_p_pay==1 |eq2_ls_pay==1 | eq2_us_pay==1 // Decrease 
  replace eq2_pay=2 if eq2_pp_pay==2 | eq2_p_pay==2 |eq2_ls_pay==2 | eq2_us_pay==2 // Increase
  drop eq2_pp_pay eq2_p_pay eq2_ls_pay eq2_us_pay
  
  * Gen dummy variabls: 0-100 for figure 
  *S3/cq3/Q3.
	foreach v in eq2_pay {
	levelsof `v'
	foreach value in `r(levels)' {
	gen     `v'_`value'=0
	replace `v'_`value'=100 if `v'==`value'
	replace `v'_`value'=. if `v'==.
	label var `v'_`value' "`: label (`v') `value''"
	}
	}
  
  local variables eq2_pay_1 eq2_pay_2 eq2_pay_3 eq2_pay_4
    
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  
  label var eq2_pay_1 "Decrease at all/some level"
  label var eq2_pay_2 "Increase at all/some level"
  label var eq2_pay_3 "No change"
  label var eq2_pay_4 "Discretion of schools/districs at all/some level"
  
    * Create sheet in excel file for this table
    export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt
    
* EQ2: S5Q2. Have there been changes to teacher pay and, benefits due to the period(s) of school closures in 2020?
/* Items to discuss
start_from_clean_file
  local figure    "Figure 4.X" // Figure number
  local fig_q     "EQ2"   // List all questions used
  
  keep  eq2_pp_pay eq2_p_pay eq2_ls_pay eq2_us_pay countrycode income_num N incomelevelname
  local variables eq2_pp_pay eq2_p_pay eq2_ls_pay eq2_us_pay

* Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  
  reshape long eq2_, i(countrycode income_num) j(Level) string
  
  * Gen dummy variabls: 0-100 for figure 
	*S3/cq3/Q3.
	foreach v in eq2_ {
	levelsof `v'
	foreach value in `r(levels)' {
	gen     `v'_`value'=0
	replace `v'_`value'=100 if `v'==`value'
	replace `v'_`value'=. if `v'==.
	label var `v'_`value' "`: label (`v') `value''"
	}
	}
	gen Level_num=.
	replace Level_num=1 if Level=="pp_pay"
	replace Level_num=2 if Level=="p_pay"
	replace Level_num=3 if Level=="ls_pay"
	replace Level_num=4 if Level=="us_pay"
	
	label define Level_numl 1 "pp" 2 "p" 3 "ls" 4 "us", modify
	label value Level_num Level_numl
	
	local variables eq2__1 eq2__2 eq2__3 eq2__4 eq2__997
	collapse (mean) `variables' (sum) N (first) incomelevelname, by(income_num Level_num)
    concatenate_label_income_N
	
	label var eq2__1   "Decrease"
    label var eq2__2   "Increase"
    label var eq2__3   "No change"
    label var eq2__4   "Discretion of schools/districts"
	label var eq2__997 "Do not know"
	
    * Create sheet in excel file for this table
    export excel concat_label Level_num `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

    * Add country and population coverage to Annex1
    add_to_annex1, figure_number(`figure') question_number(`fig_q')
*/
****************************************************************

*Eq5: Type of interactions (What kind of interactions (other than interactions in online lessons) were encouraged by government between teachers and their students and/or their parents during school closures in 2020 (in pre-primary to upper secondary levels combined)? 

start_from_clean_file

  local figure    "R.4.Eq5" // Figure number
  local fig_q     "EQ5"   // List all questions used
  
  keep  eq5_all_phonecalls eq5_all_emails eq5_all_textwhatsapp eq5_all_videoconference eq5_all_homevisits eq5_all_communicationoneschool ///
  eq5_all_useofonlineparentalsurve eq5_all_holdingregularconversati eq5_all_involvingparents eq5_all_other ///
  countrycode income_num N incomelevelname population_0417 enrollment

  gen eq5_all_phoneorvideo=0
  replace eq5_all_phoneorvideo=1 if eq5_all_phonecalls==1 | eq5_all_videoconference==1 // "yes" if either is 1
  replace eq5_all_phoneorvideo=2 if (eq5_all_phonecalls==2 | eq5_all_videoconference==2) & eq5_all_phoneorvideo!=1 // 2 if either is "at discretion"
  replace eq5_all_phoneorvideo=0 if eq5_all_phonecalls==0 & eq5_all_videoconference==0 // "no" if both options are 0
  replace eq5_all_phoneorvideo=0 if (eq5_all_phonecalls==0 | eq5_all_videoconference==0) & (eq5_all_phoneorvideo!=1 | eq5_all_phoneorvideo!=2) // "no" if both options are 0
  replace eq5_all_phoneorvideo=. if eq5_all_phonecalls ==. & eq5_all_videoconference ==. // "." if both options are .
	
  local variables eq5_all_phonecalls eq5_all_emails eq5_all_textwhatsapp eq5_all_videoconference eq5_all_phoneorvideo eq5_all_homevisits eq5_all_communicationoneschool ///
  eq5_all_useofonlineparentalsurve eq5_all_holdingregularconversati eq5_all_involvingparents eq5_all_other
  
  foreach i in `variables' {
  replace `i'=. if `i'==997 | `i'==998 | `i'==999
  }

  missings dropobs `variables', force
	
  reshape long eq5_all_, i(countrycode income_num population_0417 enrollment) j(Level) string
	 
  * Gen dummy variabls: 0-100 for figure 
  *S5/eq5
	foreach v in eq5_all_ {
	levelsof `v'
	foreach value in `r(levels)' {
	gen     `v'_`value'=0
	replace `v'_`value'=100 if `v'==`value'
	replace `v'_`value'=. if `v'==.
	label var `v'_`value' "`: label (`v') `value''"
	}
	}
  
    gen Level_num=.
		replace Level_num=1 if Level=="phonecalls"
		replace Level_num=2 if Level=="emails"
		replace Level_num=3 if Level=="textwhatsapp"
		replace Level_num=4 if Level=="videoconference"
		replace Level_num=5 if Level=="phoneorvideo"
		replace Level_num=6 if Level=="homevisits"
		replace Level_num=7 if Level=="communicationoneschool"
		replace Level_num=8 if Level=="useofonlineparentalsurve"
		replace Level_num=9 if Level=="holdingregularconversati"
		replace Level_num=10 if Level=="involvingparents"
		replace Level_num=11 if Level=="other"
		
	label define Level_numl 1 "Phone calls to students or parents" 2 "Emails to students or parents" 3 "Text/ WhatsApp/ other application messaging" ///
	4 "Videoconference technologies" 5 "Phone calls or videoconference" 6 "Home visits" 7 "Communication on E-school platforms" 8 "Online parental surveys" ///
	9 "Regular conversations about student progress" 10 "Involving parents in planning teaching content" 11 "Other", modify
	label value Level_num Level_numl

	local variables eq5_all__0 eq5_all__1 eq5_all__2 
	
	collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num Level_num)
    concatenate_label_income_N
  
	label var eq5_all__0 "No"
	label var eq5_all__1 "Yes"
	label var eq5_all__2 "At discretion of schools/ districts"

    * Beautify table
    format `variables' %3.0f
  
	* Create sheet in excel file for this table
    export excel concat_label Level_num `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

* EQ6: Do you have plans to prioritize vaccinations for teachers (in pre-primary to upper secondary levels combined)?
start_from_clean_file

  local figure    "R. EQ6" // Figure number
  local fig_q     "EQ6"   // List all questions used
  
  foreach i in eq6_all_vaccine_1 eq6_all_vaccine_2 eq6_all_vaccine_3 eq6_all_vaccine_4 {
  replace `i'=. if eq6_all_vaccine_997==100
  }
  
  local variables eq6_all_vaccine_1 eq6_all_vaccine_2 eq6_all_vaccine_3 eq6_all_vaccine_4
  
  * Create the collapsed table that will go into the Excel  
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  
  label var eq6_all_vaccine_1 "Teachers are considered as the general population"
  label var eq6_all_vaccine_2 "National measure prioritizing teachers"
  label var eq6_all_vaccine_3 "As part of the COVAX initiative"
  label var eq6_all_vaccine_4 "Others"
  * label var eq6_all_vaccine_997 "Do not know"

    * Beautify table
  format `variables' %3.0f

  * Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt
  
*---------------------------------------------------------------------------
* Section 5. Reopening
*---------------------------------------------------------------------------
*Kq1/S11/Q1: Has the Ministry of Education produced or endorsed any specific health and hygiene guidelines and measures for schools?
start_from_clean_file
  local figure    "R5 kq1" // Figure number
  local fig_q     "KQ1"   // List all questions used
  
  keep kq1 countrycode income_num N incomelevelname population_0417 enrollment
  replace kq1=. if kq1==997 | kq1==998 | kq1==999
 
  missings dropobs kq1, force

 * Gen dummy variables: 0-100 for figure 
  *S11Q1
	foreach v in kq1 {
	levelsof `v'
	foreach value in `r(levels)' {
	gen     `v'_`value'=0
	replace `v'_`value'=100 if `v'==`value'
	replace `v'_`value'=. if `v'==.
	label var `v'_`value' "`: label (`v') `value''"
	}
	}
  
  local variables kq1_0 kq1_1	
    
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  
  label var kq1_0 "No"
  label var kq1_1 "Yes"
  
  * Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

*Kq3/S11/Q3. Are there enough resources, commodities (e.g. soap, masks) and infrastructure (e.g. clean water, WASH facilities) to assure the safety of learners and all school staff? 
start_from_clean_file
  local figure    "R5 kq3" // Figure number
  local fig_q     "KQ3"   // List all questions used
  
  keep kq3 countrycode income_num N incomelevelname population_0417 enrollment
  replace kq3=. if kq3==997 | kq3==998 | kq3==999
 
  missings dropobs kq3, force

 * Gen dummy variables: 0-100 for figure 
  *S11Q1
	foreach v in kq3 {
	levelsof `v'
	foreach value in `r(levels)' {
	gen     `v'_`value'=0
	replace `v'_`value'=100 if `v'==`value'
	replace `v'_`value'=. if `v'==.
	label var `v'_`value' "`: label (`v') `value''"
	}
	}
  
  local variables kq3_0 kq3_1	
    
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  
  label var kq3_0 "No"
  label var kq3_1 "Yes"
  
  * Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt
  
*Kq3a/S11/Q3.A How are the resources for the safety of learners and school staff funded? [Select all that apply] 
 start_from_clean_file

  local figure    "R5 kq3a" // Figure number
  local fig_q     "kq3a"   // List all questions used
  
  keep kq3aexternaldonors kq3aadditionalallocationfromt kq3areallocationwithineducatio kq3areallocationofthegovernme ///
  kq3aotherpleasespecify countrycode income_num N incomelevelname population_0417 enrollment
  
  local variables kq3aexternaldonors kq3aadditionalallocationfromt kq3areallocationwithineducatio kq3areallocationofthegovernme kq3aotherpleasespecify
  
  foreach i of local variables {
  replace   `i' =. if `i'==997 | `i'==998 | `i'==999
  replace   `i' =`i'*100
  }

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
 
 label var kq3aexternaldonors "External donors"
 label var kq3aadditionalallocationfromt "Additional allocation from the Government"
 label var kq3areallocationwithineducatio "Reallocation within education budget"
 label var kq3areallocationofthegovernme "Reallocation of the Government budget across ministries"
 label var kq3aotherpleasespecify "Other"
  
  * Beautify table
  format `variables' %3.0f
  
  * Sorting in the right order for the fiugre production
  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
  
  * Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

*Kq5/S11/Q5: Have any measures been taken to minimize the impact of school closures on the wellbeing of students? Please select all the measures that apply
 start_from_clean_file

  local figure    "R5 kq5" // Figure number
  local fig_q     "kq5"   // List all questions used
  
  keep kq5_psychosocial kq5_additional kq5_supporttocounter kq5_regularcall kq5_other kq5_nomeasures /// 
  countrycode income_num N incomelevelname population_0417 enrollment
  
  local variables kq5_psychosocial kq5_additional kq5_supporttocounter kq5_regularcall kq5_other kq5_nomeasures
  
  foreach i of local variables {
  replace   `i' =. if `i'==997 | `i'==998 | `i'==999
  replace   `i' =`i'*100
  }

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
 
 label var kq5_psychosocial "Psychosocial and mental health support to learners"
 label var kq5_additional "Additional child protection services"
 label var kq5_supporttocounter "Support to counter interrupted school meal services"
 label var kq5_regularcall "Regular calls from teachers or school principals"
 label var kq5_other "Other"
 label var kq5_nomeasures "No measures"
  
  * Beautify table
  format `variables' %3.0f
  
  * Sorting in the right order for the fiugre production
  foreach i in 1 2 3 4 {
  replace concat_label = subinstr(concat_label, "`i'.", "",.)
  }
  
  * Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt


*****Figure 5: Outreach/support measures to encourage return to school -for vulnerable populations, by school level and country income group (% of reporting countries)
*IQ4.  What outreach / support measures have been taken to encourage the return to school for vulnerable populations (ISCED 0 to ISCED 3)? [Select all that apply] Community engagement to encourage return to school

* Items to discuss
* Apply rurl
start_from_clean_file

  local figure    "R. IQ4 Meausre" // Figure number
  local fig_q     "IQ4"   // List all questions used
  
  foreach i in iq4_all_nonechildren iq4_all_nonerefugees iq4_all_noneethnic iq4_all_nonegirls iq4_all_noneother {
  gen `i'_reverse=`i'
  recode `i'_reverse 1=0 0=100
  }
 
  local variables iq4_all_nonechildren_reverse iq4_all_nonerefugees_reverse iq4_all_noneethnic_reverse iq4_all_nonegirls_reverse iq4_all_noneother_reverse
  
  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N  
  
  label var iq4_all_nonechildren_reverse "Any measure for children with diabilities"
  label var iq4_all_nonerefugees_reverse "Any measure for refugees"
  label var iq4_all_noneethnic_reverse "Any measure for ethnic"
  label var iq4_all_nonegirls_reverse "Any measure for girls"
  label var  iq4_all_noneother_reverse "Any measure for other"
  
  * Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt


****************************************************************
start_from_clean_file

  local figure    "R. CQ1 Meausre" // Figure number
  local fig_q     "CQ1"   // List all questions used
  
  local variables ///
  cq1_pp_assessment cq1_pp_remedial1 cq1_pp_remedial2 cq1_pp_remedial3 cq1_pp_remedial4 cq1_pp_remedial5 cq1_pp_remedial6 cq1_pp_remedial7 cq1_pp_remedial8 ///
  cq1_p_assessment cq1_p_remedial1 cq1_p_remedial2 cq1_p_remedial3 cq1_p_remedial4 cq1_p_remedial5 cq1_p_remedial6 cq1_p_remedial7 cq1_p_remedial8 ///
  cq1_ls_assessment cq1_ls_remedial1 cq1_ls_remedial2 cq1_ls_remedial3 cq1_ls_remedial4 cq1_ls_remedial5 cq1_ls_remedial6 cq1_ls_remedial7 cq1_ls_remedial8 ///
  cq1_us_assessment cq1_us_remedial1 cq1_us_remedial2 cq1_us_remedial3 cq1_us_remedial4 cq1_us_remedial5 cq1_us_remedial6 cq1_us_remedial7 cq1_us_remedial8
  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
  reshape long cq1_, i(income_num) j(String) string
  
  split String, parse(_) 
  rename (String?) (ISCED Action) 
  drop String
  
  reshape wide cq1_, i(ISCED concat_label) j(Action) string
  foreach i in cq1_assessment cq1_remedial1 cq1_remedial2 cq1_remedial3 cq1_remedial4 cq1_remedial5 cq1_remedial6 cq1_remedial7 cq1_remedial8 {
  replace `i'=`i'*100	
  }
  
  replace ISCED="1. pp" if ISCED=="pp"
  replace ISCED="2. p" if ISCED=="p"
  replace ISCED="3. ls" if ISCED=="ls"
  replace ISCED="4. us" if ISCED=="us"
  sort concat_label ISCED
  
  local variables cq1_assessment cq1_remedial1 cq1_remedial2 cq1_remedial3 cq1_remedial4 cq1_remedial5 cq1_remedial6 cq1_remedial7 cq1_remedial8
  
  * Create sheet in excel file for this table
  export excel concat_label ISCED `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt


****************************************************************
  start_from_clean_file

  local figure    "R. CQ1 Any remedy" // Figure number
  local fig_q     "CQ1"   // List all questions used
  
  local variables ///
  cq1_pp_assessment cq1_pp_remedial1 cq1_pp_remedial2 cq1_pp_remedial3 cq1_pp_remedial4 cq1_pp_remedial5 cq1_pp_remedial6 cq1_pp_remedial7 cq1_pp_remedial8 ///
  cq1_p_assessment cq1_p_remedial1 cq1_p_remedial2 cq1_p_remedial3 cq1_p_remedial4 cq1_p_remedial5 cq1_p_remedial6 cq1_p_remedial7 cq1_p_remedial8 ///
  cq1_ls_assessment cq1_ls_remedial1 cq1_ls_remedial2 cq1_ls_remedial3 cq1_ls_remedial4 cq1_ls_remedial5 cq1_ls_remedial6 cq1_ls_remedial7 cq1_ls_remedial8 ///
  cq1_us_assessment cq1_us_remedial1 cq1_us_remedial2 cq1_us_remedial3 cq1_us_remedial4 cq1_us_remedial5 cq1_us_remedial6 cq1_us_remedial7 cq1_us_remedial8
  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
    
  foreach i in pp p ls us {
  gen cq1_`i'_remedial=0
  replace cq1_`i'_remedial=100 if cq1_`i'_remedial1==1 | cq1_`i'_remedial2==1 | cq1_`i'_remedial3==1 | cq1_`i'_remedial4==1 | cq1_`i'_remedial5==1 | cq1_`i'_remedial6==1 | cq1_`i'_remedial7==1 | cq1_`i'_remedial8==1
  }
  
  local variables cq1_pp_remedial cq1_p_remedial cq1_ls_remedial cq1_us_remedial

  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N
 
  * Create sheet in excel file for this table
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt


*---------------------------------------------------------------------------
* Section 6. Financing
*---------------------------------------------------------------------------
  
// *---------------------------------------------------------------------------
// ***  gq2_2020
// ********	Step A - Define locals and adjust aggregation levels as needed for analysis
// start_from_clean_file
//   local figure    "Figure 7.s7q2_2020" // Figure number
//   local fig_q     "gq2_2020"   // List all questions used
//  
//   keep  gq2_all_fy2020totalcapitalexp gq2_all_fy2020totalcurrentexp gq2_all_fy2020compofteac gq2_all_fy2020compofothe gq2_all_fy2020schoolsmeals gq2_all_fy2020condcashtra gq2_all_fy2020studentsuppgra gq2_all_fy2020studentloans gq2_all_fy2020othercurrentexp countrycode income_num N incomelevelname population_0417 enrollment
//   local variables gq2_all_fy2020totalcapitalexp gq2_all_fy2020totalcurrentexp gq2_all_fy2020compofteac gq2_all_fy2020compofothe gq2_all_fy2020schoolsmeals gq2_all_fy2020condcashtra gq2_all_fy2020studentsuppgra gq2_all_fy2020studentloans gq2_all_fy2020othercurrentexp
//
// * Create the collapsed table that will go into the Excel
//   foreach v in `variables'{
//       replace `v' =. if `v' ==999 |`v' ==998 |`v' ==997
//   }
//   missings dropobs `variables', force
//  
//   reshape long gq2_all_, i(countrycode income_num population_0417 enrollment) j(Level) string
//
//   * Gen dummy variabls: 0-100 for figure 
// 	*S7/gq2/Q2.
// 	foreach v in gq2_all_ {
// 	levelsof `v'
// 	foreach value in `r(levels)' {
// 	gen     `v'_`value'=0
// 	replace `v'_`value'=100 if `v'==`value'
// 	replace `v'_`value'=. if `v'==.
// 	label var `v'_`value' "`: label (`v') `value''"
// 	}
// 	}
// 	gen Level_num=.
// 	replace Level_num=1 if Level=="fy2020totalcapitalexp"
// 	replace Level_num=2 if Level=="fy2020totalcurrentexp"
// 	replace Level_num=3 if Level=="fy2020compofteac"
// 	replace Level_num=4 if Level=="fy2020compofothe"
// 	replace Level_num=5 if Level=="fy2020schoolsmeals"
// 	replace Level_num=6 if Level=="fy2020condcashtra"
// 	replace Level_num=7 if Level=="fy2020studentsuppgra"
// 	replace Level_num=8 if Level=="fy2020studentloans"
// 	replace Level_num=9 if Level=="fy2020othercurrentexp"
//	
// 	label define Level_numl 1 "Capital" 2 "Current" 3 "Teachers" 4 "Other Staff" 5 "Meals" 6 "Transfer" 7 "Support" 8 "Loans" 9 "OtherCurrent", modify
// 	label value Level_num Level_numl
//	
// 	local variables gq2_all__1 gq2_all__2 gq2_all__3 gq2_all__5
// 	collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num Level_num)
//     concatenate_label_income_N
//	
// 	label var gq2_all__1   "Increase"
// 	label var gq2_all__2   "No change"
//     label var gq2_all__3   "Decrease"
//     label var gq2_all__5   "Discretion of schools/districts"
// // 	label var gq2_all__997 "Do not know"
// // 	label var gq2_all__999 "Missing"
//	
// ******** 	Step B - Create collapsed table that will go into excel *******
//     * Create sheet in excel file for this table
//     export excel concat_label Level_num `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt
//	
// ********		Step C - Beautify table*******
//     * Add country and population coverage to Annex1
//     add_to_annex1, figure_number(`figure') question_number(`fig_q')
//
//
// ***  gq2_2021
// ********	Step A - Define locals and adjust aggregation levels as needed for analysis
// start_from_clean_file
//   local figure    "Figure 7.s7q2_2021" // Figure number
//   local fig_q     "gq2_2021"   // List all questions used
//  
//   keep  gq2_all_fy2021totalcapitalexp gq2_all_fy2021totalcurrentexp gq2_all_fy2021compofteac gq2_all_fy2021compofothe gq2_all_fy2021schoolsmeals gq2_all_fy2021condcashtra gq2_all_fy2021studentsuppgra gq2_all_fy2021studentloans gq2_all_fy2021othercurrentexp countrycode income_num N incomelevelname population_0417 enrollment
//   local variables gq2_all_fy2021totalcapitalexp gq2_all_fy2021totalcurrentexp gq2_all_fy2021compofteac gq2_all_fy2021compofothe gq2_all_fy2021schoolsmeals gq2_all_fy2021condcashtra gq2_all_fy2021studentsuppgra gq2_all_fy2021studentloans gq2_all_fy2021othercurrentexp
//
// * Create the collapsed table that will go into the Excel
// 	  foreach v in `variables'{
//       replace `v' =. if `v' ==999 |`v' ==998 |`v' ==997
//   }
//   missings dropobs `variables', force
//  
//   reshape long gq2_all_, i(countrycode income_num population_0417 enrollment) j(Level) string
//
//   * Gen dummy variabls: 0-100 for figure 
// 	*S7/gq2/Q2.
// 	foreach v in gq2_all_ {
// 	levelsof `v'
// 	foreach value in `r(levels)' {
// 	gen     `v'_`value'=0
// 	replace `v'_`value'=100 if `v'==`value'
// 	replace `v'_`value'=. if `v'==.
// 	label var `v'_`value' "`: label (`v') `value''"
// 	}
// 	}
// 	gen Level_num=.
// 	replace Level_num=1 if Level=="fy2021totalcapitalexp"
// 	replace Level_num=2 if Level=="fy2021totalcurrentexp"
// 	replace Level_num=3 if Level=="fy2021compofteac"
// 	replace Level_num=4 if Level=="fy2021compofothe"
// 	replace Level_num=5 if Level=="fy2021schoolsmeals"
// 	replace Level_num=6 if Level=="fy2021condcashtra"
// 	replace Level_num=7 if Level=="fy2021studentsuppgra"
// 	replace Level_num=8 if Level=="fy2021studentloans"
// 	replace Level_num=9 if Level=="fy2021othercurrentexp"
//	
// 	label define Level_numl 1 "Capital" 2 "Current" 3 "Teachers" 4 "Other Staff" 5 "Meals" 6 "Transfer" 7 "Support" 8 "Loans" 9 "OtherCurrent", modify
// 	label value Level_num Level_numl
//	
// 	local variables gq2_all__1 gq2_all__2 gq2_all__3 gq2_all__5
// 	collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num Level_num)
//     concatenate_label_income_N
//	
// 	label var gq2_all__1   "Increase"
// 	label var gq2_all__2   "No change"
//     label var gq2_all__3   "Decrease"
//     label var gq2_all__5   "Discretion of schools/districts"
// // 	label var gq2_all__997 "Do not know"
// // 	label var gq2_all__999 "Missing"
//	
// ******** 	Step B - Create collapsed table that will go into excel *******
//     * Create sheet in excel file for this table
//     export excel concat_label Level_num `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt
//	
// ********		Step C - Beautify table*******
//     * Add country and population coverage to Annex1
//     add_to_annex1, figure_number(`figure') question_number(`fig_q')
//	
//	

*---------------------------------------------------------------------------
* Section 7. Locus of Decision Making
*---------------------------------------------------------------------------


*---------------------------------------------------------------------------
* 2) ANNEX OF COUNTRY AND POPULATION COVERAGE 
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

erase "${Table}/annex1.dta"
erase "${Table}/annex2.dta"
