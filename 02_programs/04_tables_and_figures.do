********************************************************************************
****** Country: Worldwide
****** Purpose: Create figures for school reopening 2-pager
****** Created by: Dita Nugroho (anugroho@unicef.org), 2020/09/28
****** Used by: Dita Nugroho, Marco Valenza
****** Input  data : "${Data_clean}/jointsurvey_2rounds.dta" and
******               "${Data_clean}/combined_jointsurvey_rounds1and2.dta"
****** Output data : Figures for joint brief
****** Language: English
********************************************************************************

* Copy the Template Excel file (which has just the index and blank graphs)
* then copy ranges from which graphs draw one by one
global template   "${Table}TEMPLATE.xlsx"
global excelfile  "${Table}tables_for_figures_original.xlsx"
copy `"${template}"' `"${excelfile}"', replace
* Save to avoid repeating this options that are always used when exporting to excel
global excelopt   "firstrow(varlabels) cell(A3)"

* Saves empty file where N countries and population coverage will be appended
* for every questions used to create a table or figure (for Annex)
clear
save "${Table}/annex.dta", replace emptyok

*-----------------------------------------------------------------------------
* Short auxiliary programs to avoid repeating lines many times
*-----------------------------------------------------------------------------
{
* After creating a table, add info on country and population coverage to Annex
cap program drop add_to_annex
program define   add_to_annex
  syntax, figure_number(string) question_number(string)
  keep N population_0417 enrollment incomelevelname income_num
  gen  figure_number   = "`figure_number'"
  gen  question_number = "`question_number'"
  append using "${Table}/annex.dta"
  save "${Table}/annex.dta", replace
end

* Concatenate label (incomelevel and N)
cap program drop concatenate_label_income_N
program define   concatenate_label_income_N
  gen   concat_label = incomelevelname + " (N=" + strofreal(N) + ")"
  order concat_label
  label var concat_label  "Label"
end

* Opens clean dataset, by default the one combining both rounds
* but can open round2only if specified
cap program drop start_from_clean_file
program define   start_from_clean_file

  syntax , [round2only]

  * Open clean file
  if "`round2only'" == "round2only" ///
    use "${Data_clean}JointSurvey2_cleaned.dta", clear
  else use "${Data_clean}/combined_jointsurvey_rounds1and2.dta", clear

  * Expand dataset prior to collapse so that Global becomes a category
  expand 2, gen(expanded)
  replace income_num = 5              if expanded == 1
  replace incomelevelname  = "Global" if expanded == 1

  * Will become a country counter if no observation was missing
  gen N = 1  // should be adjusted/replaced accordingly later

end
}

*-----------------------------------------------------------------------------
* CHAPTER 1 - LEARNING LOSS
*-----------------------------------------------------------------------------
{

	start_from_clean_file

  * Q15. Is remote learning considered a valid form of delivery to account for official school days?
  * As share of all countries in round2 (including don't know and missing)
  bys incomelevelname : tab q15 if expanded == 0
  * Recode missing and don't know
  recode q15 (998=.) (999=.), gen(nq15)
  * As share of all valid answers in round2 (in the text of the chapter)
  bys incomelevelname : tab nq15 if expanded == 0

  ** TABLE FOR FIGURE 1.1: SEPARATE FILE (FIGURE CREATED IN TABLEAU)

  ** TABLE FOR FIGURES 1.2 and 1.3 share some residual cleaning

  * Q2. USUAL LENGHT OF SCHOOL YEAR
  * Change non-sensical values and average across cycles
  foreach var in q2primaryeducation q2lower_secondaryeducation q2upper_secondaryeducation {
    destring `var', replace
    clonevar n`var' = `var'
    replace  n`var' = . if `var' < 150 | `var' > 300
    egen    nm`var' = mean(n`var')
    replace nm`var' = n`var' if !missing(n`var')
  }
  egen nmq2 = rowmean(nmq2primaryeducation nmq2lower_secondaryeducation nmq2upper_secondaryeducation)

  * Q12. How many days of instruction have been missed or projected to be missed
  * (taking into account school breaks) for the academic year impacted by COVID_19?
  foreach var of varlist q12_1* q12_2* {
  	replace  `var' = . if `var' == 999
  }

  * Aux variables to explore how different answers were by educational level
  * and by moment in the academic year
  foreach opt in mean sd {
  	foreach i in 1 2 {
      egen q12_`i'_`opt' = row`opt'(q12_`i'pre_primaryeducation     q12_`i'primaryeducation ///
                                    q12_`i'lower_secondaryeducation q12_`i'upper_secondaryeducation)
    }
    * For whichever subquestion (1 or 2)
    egen q12_`opt' = row`opt'(q12_1pre_primaryeducation     q12_1primaryeducation ///
                              q12_1lower_secondaryeducation q12_1upper_secondaryeducation ///
                              q12_2pre_primaryeducation     q12_2primaryeducation ///
                              q12_2lower_secondaryeducation q12_2upper_secondaryeducation)
  }

  * Number of days loss as share of the school year
  gen lostshare = q12_mean / nmq2

  preserve

    ** TABLE FOR FIGURE 1.2: Average days of school closure
    local figure   "Figure 1.2" // Figure number
    local fig_q    "Q12"        // List all questions used for this figure
    local variables q12_1_mean q12_2_mean q12_mean // List variables for inclusion here

    * Corrects country counter in this case (it's okay to miss q12_1_mean or q12_2_mean so cant use missings drop)
    replace N = 0 if missing(q12_mean)
    * Correct population coverage according to country counter
    replace population_0417 = 0 if N != 1
    replace enrollment      = 0 if N != 1

    * Create the collapsed table that will go into the Excel
    collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
    concatenate_label_income_N

    * Provide column heading for each variable here
    label var q12_1_mean       "Days of instruction missed (finished academic year)"
    label var q12_2_mean       "Days of instruction missed (ongoing academic year)"
    label var q12_mean         "Days of instruction missed (any academic year)"

    * Create sheet in excel file for this table
    export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

    * Add country and population coverage to Annex
    add_to_annex, figure_number(`figure') question_number(`fig_q')

  restore


  ** TABLE FOR FIGURE 1.3: Share of instruction days missed, by income level
  local figure   "Figure 1.3" // Figure number
  local fig_q    "Q2, Q12"    // List all questions used for this figure
  local variables lostshare  // List variables for inclusion here

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  gen complement = 1 - lostshare
  * Provide column heading for each variable here
  label var lostshare        "Share of instruction days missed (%)"
  label var complement       "Share not missed (%)"

  * Create sheet in excel file for this table
  export excel concat_label lostshare complement using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

}

*-----------------------------------------------------------------------------
* CHAPTER 2 - LEARNING ASSESSMENT
*** THIS COVERAGE IS NOT OKAY in 2.1
*** Still manual table in 2.2
*** Can the old code be deleted? old 6.1 and old 6.2
*-----------------------------------------------------------------------------
{

start_from_clean_file
  ** TABLE FOR FIGURE 2.1: Learning monitoring by teachers, % of countries where student learning is not tracked, by income group
  local figure    "Figure 2.1" // Figure number
  local fig_q     "Q28"   // List all questions used
  local variables q28progressisnotbeingtracked_p
  replace q28progressisnotbeingtracked_p=. if q28progressisnotbeingtracked_p==99900

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) q28progressisnotbeingtracked_p (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f
  label var q28progressisnotbeingtracked_p  "Student learning is not tracked"			// Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

start_from_clean_file
drop if round==1
  ** TABLE FOR FIGURE 2.2: Assessment of student learning as schools reopen, by level of education and level of the assessment
  local figure    "Figure 2.2" // Figure number
  local fig_q     "Q30"   // List all questions used

  local variables q30pnationallevel q30psub_nationallevel q30pschoollevel q30lsnationallevel q30lssub_nationallevel q30lsschoollevel q30usnationallevel q30ussub_nationallevel q30usschoollevel

  foreach x of varlist q30* {
    replace `x'="100" if `x'=="Yes"
    replace `x'="0" if `x'=="No"
    replace `x'="0" if `x'=="Do not know"
	replace `x'="0" if `x'==""
    destring `x', replace
	}

  foreach i in snationallevel ssub_nationallevel sschoollevel {
  gen     q30`i'=0
  replace q30`i'=100 if q30l`i'
  replace q30`i'=100 if q30u`i'
  }

  local variables q30pnationallevel q30psub_nationallevel q30pschoollevel q30snationallevel q30ssub_nationallevel q30sschoollevel

  * Create the collapsed table that will go into the Excel
	missings dropobs `variables', force
	collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
	concatenate_label_income_N

* Beautify table
	format `variables' %3.0f
	label var q30pnationallevel 	"National Level: Primary"			    // Provide column heading for each variable here
	label var q30psub_nationallevel "Sub-National Level: Primary"				// Provide column heading for each variable here
	label var q30pschoollevel       "School Level: Primary"			// Provide column heading for each variable here
	label var q30snationallevel   	"National Level: Secondary"					// Provide column heading for each variable here
	label var q30ssub_nationallevel "Sub-National Level: Primary"				// Provide column heading for each variable here
	label var q30sschoollevel       "School Level: Primary"			// Provide column heading for each variable here

* Create sheet in excel file
export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

* Add country and population coverage to Annex
add_to_annex, figure_number(`figure') question_number(`fig_q')

}

*-----------------------------------------------------------------------------
* CHAPTER 3 - APPROACHES TO MITIGATING LEARNING LOSSES
* Marco: tried including q11other in table 3.1 but this variable seems to need further cleaning in 03_combine_round1_round2 (it was left out). Left this as is for now
*-----------------------------------------------------------------------------
{
start_from_clean_file

** TABLE 3.1 Different approaches to limiting learning loss, by income group
local figure    "Figure 3.1" // Figure number
local fig_q     "Q11"   // List all questions used

* Tiny bit of cleaning
foreach var of varlist q11increaseclasstimeinprimar q11increaseclasstimeinlower_ ///
                       q11increaseclasstimeinupper_ q11introduceremedialprogrammes ///
                       q11introduceacceleratedprogram  q11none q11donotknow q11other {

 recode `var' (998 999 = .), gen(n`var')

}

* Basic cross tabs findings
* - q11none q11donotknow q11other are mutually exclusive
* - q11increaseclasstime* are not exactly the same but 95% overlap
* - this 1 obs makes no sense but whatever
tab q11introduceremedialprogrammes  q11donotknow if expanded == 0

gen nq11increaseclasstime = .
replace nq11increaseclasstime = 1 if (q11increaseclasstimeinprimar == 1| q11increaseclasstimeinlower_ == 1 | q11increaseclasstimeinupper_ == 1 )
replace nq11increaseclasstime = 0 if (q11increaseclasstimeinprimar == 0| q11increaseclasstimeinlower_ == 0 | q11increaseclasstimeinupper_ == 0 )

 * Create the collapsed table that will go into the Excel
  preserve
  local variables nq11increaseclasstime nq11introduceacceleratedprogram nq11introduceremedialprogrammes nq11other nq11none
  missings dropobs `variables', force

  collapse (sum) `variables' N population_0417 enrollment (first) incomelevelname, by(income_num)

    foreach var of varlist nq11* {
  	replace `var' = `var' / N
  }

  concatenate_label_income_N

  format `variables' %3.0f
  label var nq11increaseclasstime           "Increase class time"
  label var nq11introduceremedialprogrammes "Remedial Programmes"
  label var nq11introduceacceleratedprogram "Accelerated Programmes"
  label var nq11other                       "Other strategies"
  label var nq11none                        "None"

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore
}

*-----------------------------------------------------------------------------
* CHAPTER 4 - REMOTE LEARNING MODES AND EFFECTIVENESS
* TABLE 4.2 not in here
*-----------------------------------------------------------------------------
{

start_from_clean_file

preserve

  ** TABLE FOR FIGURE 4.1: Use of remote modalities, by income group
  local figure    "Figure 4.1" // Figure number
  local fig_q     "Q13"        // List all questions used
  local variables q13onlineplatforms_effectiven q13television_effectiveness q13radio_effectiveness q13take_homepackages_effectiv  // List variables for inclusion here

  * Residual cleaning
  foreach var of varlist `variables'{
    recode `var' (0=1) (2=1) (3=0) (998=.) (999=.)
    replace `var' = `var' * 100
  }

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f
  label var q13onlineplatforms_effectiven 		"Online platform"			// Provide column heading for each variable here
  label var q13television_effectiveness 		"Television"				// Provide column heading for each variable here
  label var q13radio_effectiveness   			"Radio"						// Provide column heading for each variable here
  label var q13take_homepackages_effectiv   	"Take-home packages"		// Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore

start_from_clean_file

preserve

  ** TABLE FOR FIGURE 4.2: Effectiveness of remote modalities, by income group
  local figure    "Figure 4.2" // Figure number
  local fig_q     "Q13"        // List all questions used
  local variables q13onlineplatforms_effectiven q13television_effectiveness q13radio_effectiveness q13take_homepackages_effectiv  // List variables for inclusion here

  * Residual cleaning
  foreach var of varlist `variables'{
    recode `var' (3=.) (998=.) (999=.)
    }

	foreach x in `variables' {
		tab `x', gen(`x'_)
		}

	foreach x of varlist q13onlineplatforms_effectiven_1-q13take_homepackages_effectiv_3 {
	replace `x'=`x'*100
	}

	gen n_online=q13onlineplatforms_effectiven_1!=.
	gen n_television=q13television_effectiveness_1!=.
	gen n_radio=q13radio_effectiveness_1!=.
	gen n_takehome=q13take_homepackages_effectiv_1!=.

  * Create the collapsed table that will go into the Excel
  local variables q13onlineplatforms_effectiven_1 q13onlineplatforms_effectiven_2 q13onlineplatforms_effectiven_3 q13television_effectiveness_1 q13television_effectiveness_2 q13television_effectiveness_3 q13radio_effectiveness_1 q13radio_effectiveness_2 q13radio_effectiveness_3 q13take_homepackages_effectiv_1 q13take_homepackages_effectiv_2 q13take_homepackages_effectiv_3
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) n_online n_television n_radio n_takehome N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f

  label var q13onlineplatforms_effectiven_1 	"Online platform - Not effective"			// Provide column heading for each variable here
  label var q13onlineplatforms_effectiven_2 	"Online platform - Fairly effective"			// Provide column heading for each variable here
  label var q13onlineplatforms_effectiven_3 	"Online platform - Very effective"			// Provide column heading for each variable here

  label var q13television_effectiveness_1		"Television - Not effective"				// Provide column heading for each variable here
  label var q13television_effectiveness_2		"Television - Fairly effective"				// Provide column heading for each variable here
  label var q13television_effectiveness_3		"Television - Very effective"				// Provide column heading for each variable here

  label var q13radio_effectiveness_1   			"Radio - Not effective"						// Provide column heading for each variable here
  label var q13radio_effectiveness_2   			"Radio - Fairly effective"						// Provide column heading for each variable here
  label var q13radio_effectiveness_3   			"Radio - Very effective"						// Provide column heading for each variable here

  label var q13take_homepackages_effectiv_1   	"Take-home packages - Not effective"		// Provide column heading for each variable here
  label var q13take_homepackages_effectiv_2   	"Take-home packages - Fairly effective"		// Provide column heading for each variable here
  label var q13take_homepackages_effectiv_3   	"Take-home packages - Very effective"		// Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' n_* using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore


preserve

  ** TABLE FOR FIGURE 4.3: Remote learning considered as school days and due to continue, by income group
  local figure    "Figure 4.3" // Figure number
  local fig_q     "Q14, Q15"   // List all questions used
  local variables q14 q15 		 // List variables for inclusion here

  * Residual cleaning
  foreach var of varlist `variables'{
    recode `var' (998=.) (999=.)
    replace `var' = `var' * 100
  }

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment  (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f
  label var q14 			"Remote learning will continue when schools reopen"		// Provide column heading for each variable here
  label var q15 			"Remote learning considered official school days"		// Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore
}

*-----------------------------------------------------------------------------
* CHAPTER 5 - POLICIES TO INCREASE ACCESS TO REMOTE LEARNING
*-----------------------------------------------------------------------------
{

start_from_clean_file

preserve

  ** TABLE FOR FIGURE 5.1: Actions taken to improve connectivity, by income group
  local figure    "Figure 5.1" // Figure number
  local fig_q     "Q16"   // List all questions used
  local variables q16offernegotiateaccesstothe q16subsidizedfreedevicesfora q16mobilephones q16landline q16nomeasurestaken 		// List variables for inclusion here

  * Residual cleaning
  foreach var of varlist `variables'{
    recode `var' (998=.) (999=.)
    replace `var' = `var' * 100
  }

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f
  label var q16offernegotiateaccesstothe 		"Subsidized/free internet access"		// Provide column heading for each variable here
  label var q16subsidizedfreedevicesfora 		"Subsidized/free devices "				// Provide column heading for each variable here
  label var q16mobilephones   					"Access available through mobile phones"	// Provide column heading for each variable here
  label var q16landline   						"Access available through landline"		// Provide column heading for each variable here
  label var q16nomeasurestaken   				"No measures taken"						// Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore

preserve

  ** TABLE FOR FIGURE 5.2: Types of online platform
  local figure    "Figure 5.2" // Figure number
  local fig_q     "Q17"   // List all questions used
  local variables q17_1platformcreatedbythemin q17_1othersource q17_1_1 q17_2platformcreatedbythemin 	q17_2othersource q17_2_1	// List variables for inclusion here

  * Residual cleaning
  foreach var of varlist `variables'{
    recode `var' (998=.) (999=.)
    replace `var' = `var' * 100
  }

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment  (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f
  label var q17_1platformcreatedbythemin 	"Platform developed by Ministry of National Education Primary"		// Provide column heading for each variable here
  label var q17_1othersource 				"Using existing commercial or open source platform Primary"				// Provide column heading for each variable here
  label var q17_1_1   						"All subjects and developmental domains covered in the online platform Primary"	// Provide column heading for each variable here
  label var q17_2platformcreatedbythemin   	"Platform developed by Ministry of National Education Secondary"		// Provide column heading for each variable here
  label var q17_2othersource   				"Using existing commercial or open source platform Secondary"						// Provide column heading for each variable here
  label var q17_2_1   						"All subjects and developmental domains covered in the online platform Secondary"					// Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore


preserve

  ** TABLE FOR FIGURE 5.3: Measures for students at risk of exclusion, by income group
  local figure    "Figure 5.3" // Figure number
  local fig_q     "Q25"   // List all questions used
  local variables q25supporttolearnerswithdisa q25improvedaccesstoinfrastruc q25designoflearningmaterials q25specialeffortstomakeonlin q25flexibleandself_pacedplatf q25none 		// List variables for inclusion here

  * Residual cleaning
  foreach var of varlist `variables'{
    recode `var' (998=.) (999=.)
    replace `var' = `var' * 100
  }

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f
  label var q25supporttolearnerswithdisa 		"Support to learners with disabilities"		// Provide column heading for each variable here
  label var q25improvedaccesstoinfrastruc 		"Improved access to infrastructure for learners in remote areas"				// Provide column heading for each variable here
  label var q25designoflearningmaterials   		"Design of learning materials for speakers of minority languages"	// Provide column heading for each variable here
  label var q25specialeffortstomakeonlin   		"Special efforts to make online learning more accessible to migrant and displaced children"		// Provide column heading for each variable here
  label var q25flexibleandself_pacedplatf   	"Flexible and self-paced platforms"						// Provide column heading for each variable here
  label var q25none   							"No measures taken"						// Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore
}

*-----------------------------------------------------------------------------
* CHAPTER 6 - TEACHERS
*-----------------------------------------------------------------------------
{

start_from_clean_file

preserve

  ** TABLE FOR FIGURE 6.1: Work schedules and recruitment of teachers and educational staff
  local figure    "Figure 6.1" // Figure number
  local fig_q     "Q18, Q19, Q23, Q24"   // List all questions used
	local variables q18 q19 q23 q24

  * They recoded answers for q18 to simplify - reproducing here:
  foreach x in q18 q19 q23 q24 {
    replace `x'="Yes" if strpos(`x',"Yes")
    replace `x'="1" if `x'=="Yes"
    replace `x'="0" if `x'=="No"
    replace `x'=""  if `x'=="Do not know"
    destring `x', replace
  }

  * Residual cleaning
	foreach var of varlist `variables'{
    replace `var' = `var' * 100
	}

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f
  label var q18 								"Teachers required to teach during school closures"		// Provide column heading for each variable here
  label var q19 						 		"Other educational personnel required to work during school closure"				// Provide column heading for each variable here
  label var q23   								"New teachers being recruited for the re-opening"	// Provide column heading for each variable here
  label var q24 		   						"Other new educational personnel recruited for the re-opening"		// Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore


preserve

  ** TABLE FOR FIGURE 6.2: Support to teachers
  local figure    "Figure 6.2" // Figure number
  local fig_q     "Q20"   // List all questions used
  local variables q20offeredspecialtrainingif_p q20providedwithinstructionon_p q20providedwithprofessionalp_p q20providedwithteachingconten_p q20providedwithicttoolsandf_p q20noadditionalsupportwasoff_p

  * Residual cleaning
  foreach var of varlist `variables'{
    recode `var' (99900=.)
  }

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment  (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f
  label var q20offeredspecialtrainingif_p 		"Offered special training"		// Provide column heading for each variable here
  label var q20providedwithinstructionon_p 		"Provided with instruction on distance instruction"				// Provide column heading for each variable here
  label var q20providedwithprofessionalp_p   	"Provided with professional, psychosocial and emotional support"	// Provide column heading for each variable here
  label var q20providedwithteachingconten_p   	"Provided with teaching content adapted to remote teaching"		// Provide column heading for each variable here
  label var q20providedwithicttoolsandf_p   	"Provided with ICT tools and free connectivity"						// Provide column heading for each variable here
  label var q20noadditionalsupportwasoff_p   	"No support provided"						// Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore



preserve

  ** TABLE FOR FIGURE 6.3: Modes of communication between teachers, students and parents
  local figure    "Figure 6.3" // Figure number
  local fig_q     "Q21"   // List all questions used
  local variables q21phonecallstostudentsorpa_p q21emailstostudents_p q21textwhatsappotherapplicati_p q21homevisits_p q21therewerenospecificguidel_p


  * Residual cleaning
  foreach var of varlist `variables'{
    recode `var' (99900=.)
  }

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f
  label var concat_label     					"Label"
  label var q21phonecallstostudentsorpa_p		"Phone calls"		// Provide column heading for each variable here
  label var q21emailstostudents_p 				"Emails"				// Provide column heading for each variable here
  label var q21textwhatsappotherapplicati_p   	"Whatsapp/messaging apps"	// Provide column heading for each variable here
  label var q21homevisits_p   					"Home visits"		// Provide column heading for each variable here
  label var q21therewerenospecificguidel_p   	"No specific guidelines"						// Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore
}

*-----------------------------------------------------------------------------
* CHAPTER 7 - PARENTAL SUPPORT
*-----------------------------------------------------------------------------
{

start_from_clean_file

** TABLE FOR FIGURES 7.1 and 7.2 share some residual cleaning

ds, has(type numeric)
foreach x in `r(varlist)' {
replace `x'=.d  if `x'==998
replace `x'=.m  if `x'==999 | `x'==. | `x'==99900
}

* title("Training/support for teachers") ///
* Omit:  q27donotknow_p
gen Childcare_p=.m
gen Financial_Support_p=.m
gen Guidance_Support_p=.m
gen Phychological_p=.m
replace Childcare_p=100         if q27childcareservicesremaining_p==100 | q27emergencychildcareservices_p==100
replace Childcare_p=0           if q27childcareservicesremaining_p==0   & q27emergencychildcareservices_p==0
replace Financial_Support_p=100 if q27financialsupporttofamilies_p==100 | q27augmentedoradvancedcashtr_p==100
replace Financial_Support_p=0   if q27financialsupporttofamilies_p==0   & q27augmentedoradvancedcashtr_p==0
replace Guidance_Support_p=100  if q27guidancematerialsforhome_b_p==100 | q27guidancematerialsforpre_pr_p==100
replace Guidance_Support_p=0    if q27guidancematerialsforhome_b_p==0   & q27guidancematerialsforpre_pr_p==0
replace Phychological_p=100     if q27psychosocialcounsellingserv_p==100 | q27psychosocialsupportforcare_p==100
replace Phychological_p=0       if q27psychosocialcounsellingserv_p==0   & q27psychosocialsupportforcare_p==0

local q27_p Childcare_p Financial_Support_p Guidance_Support_p q27mealsfoodrationstofamilie_p Phychological_p q27regulartelephonefollow_upb_p q27nomeasures_p
tab1 `q27_p'

gen     No_measure_1=0
replace No_measure_1=100 if q27nomeasures_p==0 & Childcare_p==0 & Financial_Support_p==0 & q27mealsfoodrationstofamilie_p==0 & Phychological_p==0
replace No_measure_1=.m  if q27nomeasures_p==.m
gen     No_measure_2=0
replace No_measure_2=100 if Guidance_Support_p==0 & q27regulartelephonefollow_upb_p==0 & q27tipsandmaterialsforcontin_p==0
replace No_measure_2=.m  if Guidance_Support_p==.m


preserve

  ** TABLE FOR FIGURE 7.1: Education-related support to parents
  local figure    "Figure 7.1" // Figure number
  local fig_q     "Q27"        // List all questions used
  local variables Guidance_Support_p q27regulartelephonefollow_upb_p q27tipsandmaterialsforcontin_p No_measure_2

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f
  label var Guidance_Support_p						"Guidance materials"		// Provide column heading for each variable here
  label var q27regulartelephonefollow_upb_p 		"Regular phone follow-up by schools"				// Provide column heading for each variable here
  label var q27tipsandmaterialsforcontin_p   		"Tips for continued stimulation/play"	// Provide column heading for each variable here
  label var No_measure_2  							"No learning-related measures"						// Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore

preserve

  ** TABLE FOR FIGURE 7.2: Economic & wellbeing-related support to parents
  local figure    "Figure 7.2" // Figure number
  local fig_q     "Q27"        // List all questions used
  local variables Childcare_p Financial_Support_p q27mealsfoodrationstofamilie_p Phychological_p No_measure_1

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f
  label var Childcare_p								"Childcare services including emergency"		// Provide column heading for each variable here
  label var Financial_Support_p 					"Financial support and cash transfer"				// Provide column heading for each variable here
  label var q27mealsfoodrationstofamilie_p   		"Measl/food rations"	// Provide column heading for each variable here
  label var Phychological_p 						"Psychological support"						// Provide column heading for each variable here
  label var No_measure_1 							"None of these measures"						// Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore
}

*-----------------------------------------------------------------------------
* CHAPTER 8 - SCHOOL REOPENING
*** TABLE 8.1 not here
*** THIS COVERAGE IS SUSPICIOUSLY HIGH in 8.2 CHECK
*-----------------------------------------------------------------------------


** TABLE FOR FIGURE 8.1: School reopening status, by income group
  local figure    "Figure 8.1" // Figure number
  local fig_q     "Q1"   // List all questions used

* get unesco school closure monitoring data
cap confirm file "${Data_raw}/covid_impact_education.csv"
if _rc import delimited "https://en.unesco.org/sites/default/files/covid_impact_education.csv", varnames(1) case(lower) encoding("UTF-8") clear
else   import delimited "${Data_raw}/covid_impact_education.csv", varnames(1) case(lower) encoding("UTF-8") clear
keep if date == "15/09/2020"

gen     open=0
replace open=1 if status=="Fully open" | status=="Partially open"
gen countrycode = iso
keep countrycode open

* merge with income and survey data
merge 1:1 countrycode using "${Data_clean}/wbg_country_metadata.dta", keepusing(incomelevel incomelevelname) keep(master match) nogen
gen income_num = (incomelevel == "LIC")
replace income_num = 2 if incomelevel == "LMC"
replace income_num = 3 if incomelevel == "UMC"
replace income_num = 4 if incomelevel == "HIC"
lab def income 1 "Low income" 2 "Lower middle income" 3 "Upper middle income" 4 "High income"
lab val income_num income
*NOTE: countries not in WB list of economies imputted manuallly, see 'download_wbg_api_data' do-file
merge 1:1 countrycode using "${Data_clean}/combined_jointsurvey_rounds1and2.dta", keep(master match) nogen
drop if income_num == 0 // one territory (Svalbard and Jan Mayen) not matched or used

* generate variable to indicate latest reopening date between q1_1actualorexpectedre_openin q1_2actualorexpectedre_openin q1_3actualorexpectedre_openin q1_4actualorexpectedre_openin
gen reopen_pre = date(q1_1actualorexpectedre_openin,"DMY")
gen reopen_pri = date(q1_2actualorexpectedre_openin,"DMY")
gen reopen_ls = date(q1_3actualorexpectedre_openin,"DMY")
gen reopen_us = date(q1_4actualorexpectedre_openin,"DMY")
gen latest_reopen = max( reopen_pre, reopen_pri, reopen_ls, reopen_us)
gen monitoring_date = date("15/09/2020","DMY")

* generate reopen_status
gen reopen_status = open
replace reopen_status = 2 if latest_reopen > monitoring_date & open == 0
replace reopen_status = 3 if latest_reopen <= monitoring_date & open == 0
replace reopen_status = 4 if latest_reopen == . & open == 0
replace reopen_status = . if open == 0 & round == .
lab def rs 1 "Open (fully or partially)" 2 "Reopen date set in the future" 3 "Reopen date missed" 4 "No date"
lab val reopen_status rs

tab reopen_status, gen(reopen_)

local variables reopen_1 reopen_2 reopen_3 reopen_4
foreach x in `variables' {
replace `x' = `x' * 100
	}

*PRODUCE TABLE

  * Expand dataset prior to collapse so that Global becomes a category
  expand 2, gen(expanded)
  replace income_num = 5              if expanded == 1
  replace incomelevelname  = "Global" if expanded == 1

  * Will become a country counter if no observation was missing
  gen N = 1  // should be adjusted/replaced accordingly later

missings dropobs `variables', force
collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f
  label var reopen_1 	"Open (fully or partially)"			    // Provide column heading for each variable here
  label var reopen_2 	"Reopen date set in the future"			    // Provide column heading for each variable here
  label var reopen_3 	"Reopen date missed"			    // Provide column heading for each variable here
  label var reopen_4 	"No date"			    // Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')


start_from_clean_file

preserve

  ** TABLE FOR FIGURE 8.2: Percentage of countries that have set reopening dates, by income group and school level
  local figure    "Figure 8.2" // Figure number
  local fig_q     "Q1"   // List all questions used
  local variables q1_prepri_dateset q1_pri_dateset q1_lsec_dateset q1_usec_dateset  // List variables for inclusion here

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  drop if q1_1schoolsarenotclosed == 1
  collapse (mean) `variables' (sum) N population_0417 enrollment  (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f
  label var q1_prepri_dateset "Pre-primary"			    // Provide column heading for each variable here
  label var q1_pri_dateset 		"Primary"			    // Provide column heading for each variable here
  label var q1_lsec_dateset 	"Lower-secondary"			    // Provide column heading for each variable here
  label var q1_usec_dateset 	"Upper-secondary"			    // Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore

preserve

** TABLE FOR FIGURE 8.3: Teaching and learning approach as schools reopen, by income group
  local figure    "Figure 8.3" // Figure number
  local fig_q     "Q4"   // List all questions used
  local variables q4fullyin_personclassesifs q4acombinationofin_personatt q4differentbyeducationlevela q4theacademicyearhasalready  // List variables for inclusion here

  * FIGURE: Teaching and learning post reopening
  foreach var of varlist q4fullyin_personclassesifs q4acombinationofin_personatt q4differentbyeducationlevela q4theacademicyearhasalready {
  replace `var' = . if `var' == 999
  replace `var' = `var' * 100
  }

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment  (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f
  label var q4fullyin_personclassesifs 	"Fully in-person"			    // Provide column heading for each variable here
  label var q4acombinationofin_personatt 	"Combine distance and in-person"			    // Provide column heading for each variable here
  label var q4differentbyeducationlevela 	"Different by level/grade"			    // Provide column heading for each variable here
  label var q4theacademicyearhasalready 	"Academic year ended"			    // Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore

* Too many variables - distracting, check which should be included
foreach var of varlist q3prioritizationofspecificgra q3prioritizationofspecialinte q3prioritizationofcertaingeog ///
q3studentrotationiestudent q3imposingshiftsinschoolsso q3adjustmentstoschoolandorc q3adjustmentstoschoolfeeding ///
q3expansionofschoolfeedingpr q3noschoolmealsreopeninglim q3additionofmoreteacherstor q3combiningdistancelearningan ///
q3donotknow q3other {
replace `var' = 0 if `var' == 999
//logistic `var' i.income_num
replace `var' = `var' * 100
}

** TABLE FOR FIGURE 8.4: Measures used in school reopening plans, by income group (% of countries)
local figure    "Figure 8.4" // Figure number
local fig_q     "Q3"   // List all questions used
local variables q3adjustmentstoschoolandorc q3prioritizationofspecificgra q3studentrotationiestudent q3imposingshiftsinschoolsso q3prioritizationofcertaingeog  // List variables for inclusion here

* Create the collapsed table that will go into the Excel
missings dropobs `variables', force
collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
concatenate_label_income_N

* Beautify table
format `variables' %3.0f
label var q3adjustmentstoschoolandorc 	"Adjust physical arrangements"			    // Provide column heading for each variable here
label var q3prioritizationofspecificgra 	"Prioritize grades"			    // Provide column heading for each variable here
label var q3studentrotationiestudent 	"Student rotation"			    // Provide column heading for each variable here
label var q3imposingshiftsinschoolsso 	"Impose shifts"			    // Provide column heading for each variable here
label var q3prioritizationofcertaingeog 	"Prioritize geography"			    // Provide column heading for each variable here

* Create sheet in excel file
export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

* Add country and population coverage to Annex
add_to_annex, figure_number(`figure') question_number(`fig_q')



*-----------------------------------------------------------------------------
* CHAPTER 9 - HEALTH
*-----------------------------------------------------------------------------
{
start_from_clean_file
drop if round==1

preserve

  * Sample selection for the figure
  keep if q5==1

  ** TABLE FOR FIGURE 9.1: Percentage of countries including ten safety measures in their health protocols
  local figure    "Figure 9.1" // Figure number
  local fig_q     "Q6"   // List all questions used
  local variables q6promotingphysicaldistancing q6promotinghand_washingpractic q6promotinggoodrespiratoryhyg q6improvedhandwashingfacilitie q6increasedsurfacefoodprepar q6improvedmanagementofinfecti q6self_isolationofstaffandst q6temperaturechecksinschool q6testingforcovid_19inschool q6trackingstaffandstudentswh  // List variables for inclusion here

  * Create the collapsed table that will go into the Excel
  foreach var of varlist `variables'{
  replace `var' = `var' * 100
  }

  * Create the collapsed table that will go into the Excel (GLOBAL LEVEL ONLY)
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment  (first) incomelevelname, by(income_num)

  * Beautify table
  format `variables' %3.0f
  label var q6promotingphysicaldistancing 	"Promoting physical distancing"			    // Provide column heading for each variable here
  label var q6promotinghand_washingpractic 	"Promoting hand-washing practices with water and soap or alcohol-based hand sanitizer"			    // Provide column heading for each variable here
  label var q6promotinggoodrespiratoryhyg 	"Promoting good respiratory hygiene (e.g. use of masks)"			    // Provide column heading for each variable here
  label var q6improvedhandwashingfacilitie 	"Improved handwashing facilities"			    // Provide column heading for each variable here
  label var q6increasedsurfacefoodprepar 	"Increased surface, food preparation and handling equipment cleaning and disinfection"			    // Provide column heading for each variable here
  label var q6improvedmanagementofinfecti 	"Improved management of infectious wastes"			    // Provide column heading for each variable here
  label var q6self_isolationofstaffandst 	"Self-isolation of staff and students"			    // Provide column heading for each variable here
  label var q6temperaturechecksinschool 	"Temperature checks in school"			    // Provide column heading for each variable here
  label var q6testingforcovid_19inschool 	"Testing for COVID-19 in schools"			    // Provide column heading for each variable here
  label var q6trackingstaffandstudentswh 	"Tracking staff and students who are infected with or exposed to COVID-19"			    // Provide column heading for each variable here

  * Only keep global in this case
  keep if income_num == 5

  * Create sheet in excel file
  export excel `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore

preserve

  * Sample selection for the figure
  keep if q8==1 | q8==0

  ** TABLE FOR FIGURE 9.2: Percentage of countries with enough resources to ensure school safety, by income level
  local figure    "Figure 9.2" // Figure number
  local fig_q     "Q8"   // List all questions used
  local variables q8 // List variables for inclusion here

  * Create the collapsed table that will go into the Excel
  foreach var of varlist `variables'{
  replace `var' = `var' * 100
  }

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment  (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f
  label var q8 		"Enough resources to ensure school safety"	    // Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore
}

*------------------------------------------------------------------------------
* CHAPTER 10 - FINANCING
*-----------------------------------------------------------------------------
{

start_from_clean_file
drop if round==1

preserve

  ** TABLE FOR FIGURE 10.1: Percentage of countries that received additional funding, by source and income group
  local figure    "Figure 10.1" // Figure number
  local fig_q     "Q31"   // List all questions used
  local variables q31_1externaldonors q31_1additionalallocationfrom q31_1reallocationoftheministr  // List variables for inclusion here

  keep if q31==1

  * Create the collapsed table that will go into the Excel
  foreach var of varlist `variables'{
    replace `var' = `var' * 100
  }

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f
  label var q31_1externaldonors 		"External Donors"			    // Provide column heading for each variable here
  label var q31_1additionalallocationfrom 		"Additional Domestic"				// Provide column heading for each variable here
  label var q31_1reallocationoftheministr   	"Education Budget Reallocation"			// Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore

preserve

  ** TABLE FOR FIGURE 10.2: Percentage of countries that indicated budget declines in 2020-2021, by component and income group
  local figure    "Figure 10.2" // Figure number
  local fig_q     "Q33"   // List all questions used
  local variables q33_Bill q33_Feed // List variables for inclusion here

  * Sample selection for the figure
  drop if q33curyrwagereductionsoutsid==999 & q33curyrwagereductionsinclud==999 & q33currentyearcutsinschoolf==999 & q33currentyeardonotknow==999 & q33nextyrwagereductionsouts==999 & q33nextyrwagereductionsincl==999 & q33nextyear_cutsinschoolf==999
  drop if q33curyrwagereductionsoutsid==998 & q33curyrwagereductionsinclud==998 & q33currentyearcutsinschoolf==998 & q33currentyeardonotknow==999 & q33nextyrwagereductionsouts==998 & q33nextyrwagereductionsincl==998 & q33nextyear_cutsinschoolf==998
  drop if q33curyrwagereductionsoutsid==999 & q33curyrwagereductionsinclud==999 & q33currentyearcutsinschoolf==998 & q33currentyeardonotknow==999 & q33nextyrwagereductionsouts==999 & q33nextyrwagereductionsincl==999 & q33nextyear_cutsinschoolf==999
  drop if q33curyrwagereductionsoutsid==998 & q33curyrwagereductionsinclud==999 & q33currentyearcutsinschoolf==999 & q33currentyeardonotknow==999 & q33nextyrwagereductionsouts==998 & q33nextyrwagereductionsincl==999 & q33nextyear_cutsinschoolf==999

  gen q33_Bill=0
  replace q33_Bill=1 if q33curyrwagereductionsoutsid==1 | q33curyrwagereductionsinclud==1 | q33nextyrwagereductionsouts==1 | q33nextyrwagereductionsincl==1
  gen q33_Feed=0
  replace q33_Feed=1 if q33currentyearcutsinschoolf==1 | q33nextyear_cutsinschoolf==1

  * Create the collapsed table that will go into the Excel
  foreach var of varlist `variables'{
  replace `var' = `var' * 100
  }

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  label var q33_Bill 		"Wage Bill"			    // Provide column heading for each variable here
  label var q33_Feed 		"School Feeding"	    // Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore

preserve

  ** TABLE FOR FIGURE 10.3: Percentage of countries that indicated budget declines in 2020-2021, by component and income group
  local figure    "Figure 10.3" // Figure number
  local fig_q     "Q33"   // List all questions used
  local variables q33_GovSup_Inc // List variables for inclusion here

  * Sample selection for the figure
  drop if q32currentyearconditionalcash==999 & q32currentyearscholarships==999 & q32nextyearconditionalcashtr==999 & q32nextyearscholarships==999
  drop if q32currentyearconditionalcash==998 & q32currentyearscholarships==999 & q32nextyearconditionalcashtr==999 & q32nextyearscholarships==999
  drop if q32currentyearconditionalcash==998 & q32currentyearscholarships==998 & q32nextyearconditionalcashtr==998 & q32nextyearscholarships==998
  drop if q32currentyearconditionalcash==999 & q32currentyearscholarships==999 & q32nextyearconditionalcashtr==998 & q32nextyearscholarships==998

  gen q33_GovSup_Inc=0
  replace q33_GovSup_Inc=1 if q32currentyearconditionalcash==1 | q32currentyearscholarships==1 | q32nextyearconditionalcashtr==1 | q32nextyearscholarships==1

  foreach var of varlist `variables'{
  replace `var' = `var' * 100
  }

  * Create the collapsed table that will go into the Excel
  missings dropobs `variables', force
  collapse (mean) `variables' (sum) N population_0417 enrollment (first) incomelevelname, by(income_num)
  concatenate_label_income_N

  * Beautify table
  format `variables' %3.0f
  label var q33_GovSup_Inc 		"increased government support"			    // Provide column heading for each variable here

  * Create sheet in excel file
  export excel concat_label `variables' using `"${excelfile}"', sheet("`figure'", modify) $excelopt

  * Add country and population coverage to Annex
  add_to_annex, figure_number(`figure') question_number(`fig_q')

restore
}

*-----------------------------------------------------------------------------
* ANNEX OF COUNTRY AND POPULATION COVERAGE
*-----------------------------------------------------------------------------
{
* All the countries with population
* note that since we added to wbg_country_metadata some units that the WBG
* does not consider countries, the total N is above our usual 218
use "${Data_clean}/wbg_country_metadata.dta", clear
merge 1:1 countrycode using "${Data_clean}/population.dta", keep(match master) nogen
merge 1:1 countrycode using "${Data_clean}/enrollment.dta", keep(match master) nogen
gen N = 1
expand 2, gen(expanded)
replace incomelevelname  = "Global" if expanded == 1

* What full coverage would look like (question-invatiant)
collapse (sum) N_total = N pop_total = population_0417 enr_total = enrollment , by(incomelevelname)
tempfile full_coverage
save `full_coverage', replace

* Start with the appended values of N and pop from all tables
use "${Table}/annex.dta", clear
rename population_0417 pop_covered
rename enrollment      enr_covered
label var N               "Number of countries with valid answers"
label var pop_covered     "Population ages 04-17 covered by valid answers"
label var enr_covered     "Students in basic education covered by valid answers"
label var figure_number   "Figure number"
label var question_number "Question(s) used for this figure"
label var incomelevelname "Income level name"

* Bring in what full coverage looks like
merge m:1 incomelevelname using `full_coverage', assert(match) nogen

* Country & population coverage in relative terms
gen cty_coverage = 100 * N / N_total
gen pop_coverage = 100 * pop_covered / pop_total
gen enr_coverage = 100 * enr_covered / enr_total
label var cty_coverage "Share of countries covered (%)"
label var pop_coverage "Population coverage (% of population 04-17)"
label var enr_coverage "Student coverage (% of pre-primary, primary and secondary enrollment)"

gen aux_sort = real(substr(figure_number, 7, .))
sort aux_sort income_num

* Export into Annex
local vars4excel "figure_number question_number incomelevelname N pop_coverage enr_coverage"
order `vars4excel'
export excel `vars4excel' using `"${excelfile}"', sheet("Annex", modify) $excelopt
}
