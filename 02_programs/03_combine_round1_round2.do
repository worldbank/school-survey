********************************************************************************
****** Country: Worldwide
****** Purpose: Combine UNESCO_UNICEF_WB rounds 1 & 2 data
****** Created by: Dita Nugroho (anugroho@unicef.org), 2020/09/26
****** Used by: Dita Nugroho,
****** Input  data : "${Data_clean}/JointSurvey2_cleaned.dta"
*******              Survey on National Education Responses to COVID-19 School Closures_IndividualResponses_ToShare.xlsx
****** Output data : UNESCO_UNICEF_WB
****** Language: English
********************************************************************************

* In this do-file:
* Step 1 - Get common variables from survey round 1 data
* Step 2 - Combine rounds 1 & 2 datasets, generate combined variables
* Step 3 - Save combined dataset, drop round 1 variables

*-----------------------------------------------------------------------------
* Step 1 - Get common variables from survey round 1 data
*-----------------------------------------------------------------------------
import delimited "${Data_raw}/un_country_metadata.csv", varnames(1) encoding("utf-8") clear
tempfile un_country_metadata
save `un_country_metadata'

* Note round 1 countries that did not want their individual data disclosed
* are not included in this public file, so aggregate results may match the report

* Reading data has to be fixed
local URL_round1    "http://tcg.uis.unesco.org/wp-content/uploads/sites/4/2020/07/Response_final_20200720.xlsx"
cap confirm file    "${Data_raw}/Response_final_20200720.xlsx"
if _rc copy "`URL_round1'" "${Data_raw}/Response_final_20200720.xlsx", replace
import excel using "${Data_raw}/Response_final_20200720.xlsx", firstrow case(lower) sheet("Dataset") clear

* Cleaning for round 1 data
do "${Do}03_1_JointMoE Survey_Clean.do"

rename country countryname
merge 1:1 countryname using `un_country_metadata', keepusing(iso3) keep(master match)
rename (countryname iso3) (coun countrycode)

* Terrible idea to merge on names. But the Round 1 csv does not have iso3
* Fix this one which was not merging
/*
. list countryname if _merge == 1
     +---------------+
     |   countryname |
     |---------------|
  3. |       Algerie |
 38. | Côte d'Ivoire |
 86. |     Palestine |
*/

replace countrycode = "DZA" if coun == "Algerie"
replace countrycode = "CIV" if coun == "Côte d'Ivoire"
replace countrycode = "PSE" if coun == "Palestine"

rename *, lower
keep coun countrycode q1_* q2_* q3_*

* Note source of variables
foreach i in q1_* q2_* q3_* {
rename `i' r1_`i'
}
*

*-----------------------------------------------------------------------------
* Step 2 - Combine rounds 1 & 2 datasets, and bring in WBG data
*-----------------------------------------------------------------------------
merge 1:1 countrycode using "${Data_clean}JointSurvey2_cleaned.dta"
drop incomelevelname

* Combined income data
merge 1:1 countrycode using "${Data_clean}/wbg_country_metadata.dta", keep(master match) nogen
replace income_num = 1 if incomelevel == "LIC"
replace income_num = 2 if incomelevel == "LMC"
replace income_num = 3 if incomelevel == "UMC"
replace income_num = 4 if incomelevel == "HIC"
//lab def income 1 "Low income" 2 "Lower middle income" 3 "Upper middle income" 4 "High income"
lab val income_num income

* Drop first because population info had already been merged to round2 but not round1
drop year_population population_0417
merge 1:1 countrycode using "${Data_clean}/population.dta", keep(master match) nogen
drop year_enrollment enrollment
merge 1:1 countrycode using "${Data_clean}/enrollment.dta", keep(master match) nogen

*-----------------------------------------------------------------------------
* Step 3 - Generate combined variables
*-----------------------------------------------------------------------------

* R1: Q1 - What are the current plans for reopening schools in your education system? [Select all that apply]
* R2: Q1 - What are the current plans for reopening schools in your education system? [Select all that apply]
** Combine within current/next academic year from round 2 for comparability
** Distinction between current/next academic year also unclear due to long period of data collection and gap to time of publishing
gen q1_prepri_nw = (q1_1nation_widewithinthecurr == 1 | q1_1nation_widenextacademicy == 1)
gen q1_pri_nw = (q1_2nation_widewithinthecurr == 1 | q1_2nation_widenextacademicy == 1)
gen q1_lsec_nw = (q1_3nation_widewithinthecurr == 1 | q1_3nation_widenextacademicy == 1)
gen q1_usec_nw = (q1_4nation_widewithinthecurr == 1 | q1_4nation_widenextacademicy == 1)
gen q1_prepri_pg = (q1_1partialsub_nationalwithin == 1| q1_1partialsub_nationalnexta == 1)
gen q1_pri_pg = (q1_2partialsub_nationalwithin == 1| q1_2partialsub_nationalnexta == 1)
gen q1_lsec_pg = (q1_3partialsub_nationalwithin == 1| q1_3partialsub_nationalnexta == 1)
gen q1_usec_pg = (q1_4partialsub_nationalwithin == 1| q1_4partialsub_nationalnexta == 1)
gen q1_prepri_ps = (q1_1phasingstudentswithinthe == 1 | q1_1phasingstudentsnextacade == 1)
gen q1_pri_ps = (q1_2phasingstudentswithinthe == 1 | q1_2phasingstudentsnextacade == 1)
gen q1_lsec_ps = (q1_3phasingstudentswithinthe == 1 | q1_3phasingstudentsnextacade == 1)
gen q1_usec_ps = (q1_4phasingstudentswithinthe == 1 | q1_4phasingstudentsnextacade == 1)
gen q1_prepri_dk = q1_1donotknow
gen q1_pri_dk = q1_2donotknow
gen q1_lsec_dk = q1_3donotknow
gen q1_usec_dk = q1_4donotknow
gen q1_prepri_nc = q1_1schoolsarenotclosed
gen q1_pri_nc = q1_2schoolsarenotclosed
gen q1_lsec_nc = q1_3schoolsarenotclosed
gen q1_usec_nc = q1_4schoolsarenotclosed

** if missing across one level, consider missing
foreach i in prepri pri lsec usec {
foreach var of varlist r1_q1_`i'_nw-r1_q1_`i'_nc {
replace `var' = .m if `var' == 999
replace `var' = .d if `var' == 998
}
}
foreach i in prepri pri lsec usec {
replace q1_`i'_nw = .m if q1_`i'_nw != 1 &  q1_`i'_pg != 1 & q1_`i'_ps != 1 & q1_`i'_dk != 1 & q1_`i'_nc != 1
replace q1_`i'_pg = .m if q1_`i'_nw != 1 &  q1_`i'_pg != 1 & q1_`i'_ps != 1 & q1_`i'_dk != 1 & q1_`i'_nc != 1
replace q1_`i'_ps = .m if q1_`i'_nw != 1 &  q1_`i'_pg != 1 & q1_`i'_ps != 1 & q1_`i'_dk != 1 & q1_`i'_nc != 1
replace q1_`i'_dk = .m if q1_`i'_nw != 1 &  q1_`i'_pg != 1 & q1_`i'_ps != 1 & q1_`i'_dk != 1 & q1_`i'_nc != 1
replace q1_`i'_nc = .m if q1_`i'_nw != 1 &  q1_`i'_pg != 1 & q1_`i'_ps != 1 & q1_`i'_dk != 1 & q1_`i'_nc != 1
}
** If missing in r2, replace with r1
foreach i of varlist q1_prepri_nw - q1_usec_nc {
replace `i' = r1_`i' if `i' == .
}
* reopening strategy
lab define strategy 1 "nation-wide" 2 "partial/sub-national" 3 "phasing" 4 "combination" 5 "do not know" 6 "schools not closed"
foreach i in prepri pri lsec usec {
gen q1_`i'_strategy = 6 if q1_`i'_nc == 1
replace q1_`i'_strategy = .d if q1_`i'_dk == 1
replace q1_`i'_strategy = 1 if q1_`i'_nw == 1
replace q1_`i'_strategy = 2 if q1_`i'_pg == 1
replace q1_`i'_strategy = 3 if q1_`i'_ps == 1
replace q1_`i'_strategy = 4 if q1_`i'_nw + q1_`i'_pg + q1_`i'_ps > 1
replace q1_`i'_strategy = .m if q1_`i'_nw == .m
lab values q1_`i'_strategy strategy
}
*

* R1: Q1 - Expected re-opening date
* R2: Q1 - Actual or expected re-opening date [dd/mm/yyyy]
gen q1_prepri_dates = date(q1_1actualorexpectedre_openin,"DMY")
gen q1_pri_dates = date(q1_2actualorexpectedre_openin,"DMY")
gen q1_lsec_dates = date(q1_3actualorexpectedre_openin,"DMY")
gen q1_usec_dates = date(q1_4actualorexpectedre_openin,"DMY")
** If all reopen dates missing in r2, replace with r1
replace q1_prepri_dates = date(r1_q1_prepri_dates,"DMY") if q1_prepri_dates == . & q1_pri_dates == . & q1_lsec_dates == . & q1_usec_dates == .
replace q1_pri_dates = date(r1_q1_prepri_dates,"DMY") if q1_prepri_dates == . & q1_pri_dates == . & q1_lsec_dates == . & q1_usec_dates == .
replace q1_lsec_dates = date(r1_q1_prepri_dates,"DMY") if q1_prepri_dates == . & q1_pri_dates == . & q1_lsec_dates == . & q1_usec_dates == .
replace q1_usec_dates = date(r1_q1_prepri_dates,"DMY") if q1_prepri_dates == . & q1_pri_dates == . & q1_lsec_dates == . & q1_usec_dates == .
format q1_prepri_dates-q1_usec_dates %td
** Status of date in round 2, if valid dates provided in round 1
lab define status 0 "unchanged" 1 "later" 2 "earlier"
foreach i in prepri pri lsec usec {
gen q1_`i'_datestatus = 0 if q1_`i'_dates == date(r1_q1_`i'_dates,"DMY")
replace q1_`i'_datestatus = 1 if q1_`i'_dates > date(r1_q1_`i'_dates,"DMY")
replace q1_`i'_datestatus = 2 if q1_`i'_dates < date(r1_q1_`i'_dates,"DMY")
replace q1_`i'_datestatus = . if q1_`i'_dates == . | date(r1_q1_`i'_dates,"DMY") == .
lab values q1_`i'_datestatus status
}
** Reopen date set
foreach i in prepri pri lsec usec {
gen q1_`i'_dateset = (q1_`i'_dates != .) * 100
}
*

* R1: Q3 - Has the current school calendar been adjusted (or are there plans in place to adjust it)?
* R2: Q10 - What kinds of adjustments will be made to the school calendar dates? [Select all that apply]
gen q10_calendar_adjust = (q10extendcurrentacademicyear == "Extend current academic year (If so, please answer Question 10.2)" | ///
q10alterdatesofthenextacade == "Alter dates of the next academic year (If so, please answer Question 10.3)")
** If missing across all main q10, consider missing
replace q10_calendar_adjust = .d if q10_calendar_adjust == 0 & q10donotknow == "Do not know"
replace q10_calendar_adjust = .m if q10therewillbenoadjustments == "" & q10extendcurrentacademicyear == "" & q10alterdatesofthenextacade == "" & q10donotknow == "" & q10other == ""
** If missing in r2, replace with r1
replace q10_calendar_adjust = r1_q3_calendar_adjust if q10_calendar_adjust == .m
replace q10_calendar_adjust = .d if r1_q3_calendar_adjust == 998
replace q10_calendar_adjust = .m if r1_q3_calendar_adjust == 999

* R1: Q3 - Will you increase class time when schools re-open? No/Yes (Q3)
* R1: Q3 - Will you introduce remedial programmes? (Q3)
* R1: Q3 - Will you introduce accelerated learning programmes? (Q3)
* R2: Q11 - What kinds of additional support programmes have been or will be provided? [Select all that apply] (Q11)
**☐ Increase in-person class time in primary education
**☐ Increase in-person class time in lower-secondary education
**☐ Increase in-person class time in upper-secondary education
**☐ Introduce remedial programmes in addition to the normal in-person class time (if so, please answer Question 11.1)
**☐ Introduce accelerated programmes in addition to the normal in person class time (if so, please answer Question 11.2)
gen q11_increase = (q11increaseclasstimeinprimar == 1 | q11increaseclasstimeinlower_ == 1 | q11increaseclasstimeinupper_ == 1)
gen q11_remedial = (q11introduceremedialprogrammes == 1)
gen q11_accelerate = (q11introduceacceleratedprogram == 1)
gen q11_none = (q11none == 1)
** If missing across all main q11, consider missing
foreach var of varlist q11_increase-q11_none {
replace `var' = .m if q11increaseclasstimeinprimar != 1 & q11increaseclasstimeinlower_ != 1 & q11increaseclasstimeinupper_ != 1 ///
& q11introduceremedialprogrammes != 1 & q11introduceacceleratedprogram != 1 & q11none != 1 & q11donotknow != 1
replace `var' = .d if `var' == 0 & q11donotknow == 1
}
** If missing in r2, replace with r1
** Adjusting school calendar considered as additional support
foreach var of varlist r1_q3_calendar_adjust r1_q3_increase r1_q3_remedy r1_q3_accelerate {
replace `var' = .m if `var' == 999
replace `var' = .d if `var' == 998
}
replace q11_increase = r1_q3_increase if _merge == 1
replace q11_remedial = r1_q3_remedy if _merge == 1
replace q11_accelerate = r1_q3_accelerate if _merge == 1
replace q11_none = 1 if _merge == 1 & r1_q3_calendar_adjust == 0 & r1_q3_increase == 0 & r1_q3_remedy == 0 & r1_q3_accelerate == 0
replace q11_none = 0 if _merge == 1 & (r1_q3_calendar_adjust == 1 | r1_q3_increase == 1 | r1_q3_remedy == 1 | r1_q3_accelerate == 1)
replace q11_none = .m if _merge == 1 & r1_q3_calendar_adjust == .m & r1_q3_increase == .m & r1_q3_remedy == .m & r1_q3_accelerate == .m
replace q11_none = 0 if _merge == 1 & q10_calendar_adjust == 1

* R1: Q2 - Are new teachers recruited for reopening?
* R2: Q23 - Are new teachers being recruited for the re-opening?
gen q2_newteachers = 0 if q23 != ""
replace q2_newteachers = 1 if q23 == "Yes (If so, please answer Question 23.1)"
replace q2_newteachers = .m if q23 == ""
replace q2_newteachers = .d if q23 == "Do not know"
** If missing in r2, replace with r1
replace q2_newteachers = r1_q2_new_teacher if _merge == 1
replace q2_newteachers = r1_q2_new_teacher if _merge == 1
replace q2_newteachers = .m if r1_q2_new_teacher == 999 & _merge == 1
replace q2_newteachers = .m if r1_q2_new_teacher == . & _merge == 1
replace q2_newteachers = .d if r1_q2_new_teacher == 998 & _merge == 1

*-----------------------------------------------------------------------------
* Step 3 - Save combined dataset, drop raw round 1 variables
*-----------------------------------------------------------------------------

* Add rounds var to identify participation
gen round = _merge
lab def round 1 "Round 1 only" 2 "Round 2 only" 3 "Both rounds"
lab values round round
label var round  "Participation in rounds"
drop r1_*

* Save combined dataset
label var coun   "UIS Country Name"
order countrycode countryname-lendingtypename coun iso3 round
sort coun
save "${Data_clean}/combined_jointsurvey_rounds1and2.dta", replace

export excel using "${Data_clean}/combined_jointsurvey_rounds1and2.xlsx", firstrow(variables) replace
describe _all, replace clear
export excel using "${Data_clean}/combined_jointsurvey_rounds1and2.xlsx", first(var) sheet("Label") sheetmodify
