*=========================================================================*
* Project information at: https://github.com/worldbank/schoolsurvey-production
****** Country: Worldwide
****** Purpose: Cleaning of the UNESCO-UNICEF-WBG_OECD Survey on National education responses to COVID-19 - Round 3
****** Created by: UNICEF, UNESCO, WORLD BANK, OECD
****** Used by: UNICEF, UNESCO, WORLD BANK, OECD
****** Input  data : jsw3_uis_clean.dta, jsw_oecd_clean_for_append.dta, wbg_country_metadata.dta, enrollment.dta, population.dta, wbopendata (hd.hci.hlos)           
****** Output data : jsw3_uis_oecd_clean_original.dta, jsw3_uis_oecd_clean.dta
****** Language: English
*=========================================================================*

** In this do file: 
* This do file appends cleaned UIS and OECDs and selects questionnaire source for countries that have duplicate responses. 
* It then merges enrollment, population, and harmonized learning outcomes.

** Steps in this do-file:
* 1) Appends the clean 022_1 (UIS) and 022_2 (OECD)
* 2) Replacing 997 and 998 to missing 
* 3) Clean and Merge Country Metadata
* 4) Creates a harmonized output with merged variables and a BASE output with OECD, UIS, and appended variable names.

*=========================================================================*

*---------------------------------------------------------------------------
* 1) Append the clean 022_1 and 022_2
*---------------------------------------------------------------------------
***save data section 11 and 12 for 3 UIS countries that will be dropped as duplicates
use "${Data_clean}jsw3_uis_clean.dta", clear
keep if ISO3 == "RUS" | ISO3 == "SWE" | ISO3 == "COL"

rename ISO3 countrycode

keep countrycode kq1 kq2* kq3* kq4* kq5_psychosocial kq5_* kq5_specify kq6 lq3

tempfile uis_clean_supplemental
save `uis_clean_supplemental'

*****merge data with oecd observations for 3 countries
use "${Data_clean}jsw3_oecd_clean_for_append.dta", clear
merge 1:1 countrycode using `uis_clean_supplemental'
drop _merge
save "${Data_clean}jsw3_oecd_clean_for_append.dta", replace

use "${Data_clean}jsw3_uis_clean.dta", clear
gen Source=1

*drop in UIS duplicated answers for RUS, SWE, COL
drop if ISO3 == "RUS" | ISO3 == "SWE" | ISO3 == "COL"

rename ISO3 countrycode

****append
append using "${Data_clean}/jsw3_oecd_clean_for_append.dta"


drop __000*

*drop in OECD duplicated answers for CRI, BRA, POL, TUR
drop if countrycode == "CRI" & Source==2
drop if countrycode == "POL" & Source==2
drop if countrycode == "TUR" & Source==2

*Select Flemish region for Belgium:
replace countrycode = "BEL" if countrycode == "BFL" 
drop if countrycode == "BFR" 

replace q_consent="YES" if Source==2 //give consent to OECD countries

save "${Data_clean}jsw3_uis_oecd_clean_original.dta", replace

*---------------------------------------------------------------------------

*---------------------------------------------------------------------------
* 2) Replacing 997 and 998 to missing *
*---------------------------------------------------------------------------
* Variables that you want to replace Don't know, not applicable, and missing to ".".

*S1/aq1/Q1. What was the status of school opening in the education system as of February 1st, 2021? [Select all that apply]
foreach i in pp p ls us {
		foreach j in closed1 closed2 closed3 fullyopen open1 open2 open3 open4 open5 open6 open7 other {
			* Step C: String to numerical
			replace aq1_`i'_`j' = . if aq1_`i'_`j' == 999	| aq1_`i'_`j' == 998 | aq1_`i'_`j' == 997 		
		}
	}
	
*S1/aq3/Q3  If there were no differences between sub-national regions, over how many time periods were schools fully closed  (excluding schoolholidays) from January to December 2020 (i.e. government-mandated or/and recommended closures of educational institutions affectingall of the student population)?  

// Keeping do not know (997)

foreach i in pp p ls us {
		replace aq3_`i'_periods = . if aq3_`i'_periods == 999
	}

*S1/aq4/Q4 If there were differences between subnational regions, please indicate the minimum and maximum number of time periods schools in a region were fully closed (exclusing holidays) from Jannuary to December 2020
//keeping do not know (997)

foreach i in pp p ls us {
	foreach j in min max typical {
		replace aq4_`i'_`j' = . if aq4_`i'_`j' == 999
	}
}


foreach i in pp p ls us {
		foreach j in total min max typical {
			replace aq6_`i'_`j' = . if aq6_`i'_`j' == 999 | aq6_`i'_`j' == 998 
		}
}

foreach i in  ///
        bq2_all_regulation cq1_pp_assessment cq1_pp_remedial1 cq1_pp_remedial2 cq1_pp_remedial3 cq1_pp_remedial4 cq1_pp_remedial5 cq1_pp_remedial6 cq1_pp_remedial7 cq1_pp_remedial8 cq1_pp_other cq1_pp_none cq1_pp_donotknow ///
		cq1_p_assessment cq1_p_remedial1 cq1_p_remedial2 cq1_p_remedial3 cq1_p_remedial4 cq1_p_remedial5 cq1_p_remedial6 cq1_p_remedial7 cq1_p_remedial8 cq1_p_other cq1_p_none cq1_p_donotknow ///
		cq1_ls_assessment cq1_ls_remedial1 cq1_ls_remedial2 cq1_ls_remedial3 cq1_ls_remedial4 cq1_ls_remedial5 cq1_ls_remedial6 cq1_ls_remedial7 cq1_ls_remedial8 cq1_ls_other cq1_ls_none cq1_ls_donotknow ///
		cq1_us_assessment cq1_us_remedial1 cq1_us_remedial2 cq1_us_remedial3 cq1_us_remedial4 cq1_us_remedial5 cq1_us_remedial6 cq1_us_remedial7 cq1_us_remedial8 cq1_us_other cq1_us_none cq1_us_donotknow ///		
    dq1_pp_onlineplatforms dq1_pp_television dq1_pp_mobilephones dq1_pp_radio dq1_pp_takehomepackages dq1_pp_otherdistancelearningm dq1_pp_none ///	
    dq1_p_onlineplatforms dq1_p_television dq1_p_mobilephones dq1_p_radio dq1_p_takehomepackages dq1_p_otherdistancelearningm dq1_p_none ///	
    dq1_ls_onlineplatforms dq1_ls_television dq1_ls_mobilephones dq1_ls_radio dq1_ls_takehomepackages dq1_ls_otherdistancelearningm dq1_ls_none ///	
    dq1_us_onlineplatforms dq1_us_television dq1_us_mobilephones dq1_us_radio dq1_us_takehomepackages dq1_us_otherdistancelearningm dq1_us_none ///	
    dq2_pp_percent dq2_p_percent dq2_ls_percent dq2_us_percent ///	
    dq3_all_onlineplatforms dq3_all_television dq3_all_mobilephones dq3_all_radio dq3_all_takehomepackages dq3_all_otherdistancelearning dq3a_all_householdsurvey dq3a_all_teacherassessment dq3a_all_studentassessment dq3a_all_other ///
    dq3a_all_householdsurvey dq3a_all_teacherassessment dq3a_all_studentassessment dq3a_all_other ///
    eq1_all_percentage eq1a_all_premises eq1b_pp_levels eq1b_p_levels eq1b_ls_levels eq1b_us_levels /// 
 eq3_pp_2020 eq3_p_2020 eq3_ls_2020 eq3_us_2020 eq3_pp_2021 eq3_p_2021 eq3_ls_2021 eq3_us_2021 /// 
 eq5_all_phonecalls eq5_all_emails	eq5_all_textwhatsapp eq5_all_videoconference eq5_all_homevisits eq5_all_communicationoneschool eq5_all_useofonlineparentalsurve eq5_all_holdingregularconversati ///
	eq5_all_involvingparents eq5_all_nospecificguidelines eq5_all_other lq3 ///
		iq4_all_comchildren iq4_all_comethnic iq4_all_comgirls iq4_all_comother iq4_all_comrefugees ///
		iq4_all_makemodchildren iq4_all_makemodethnic iq4_all_makemodgirls iq4_all_makemodother iq4_all_makemodrefugees ///
		iq4_all_nonechildren iq4_all_noneethnic iq4_all_nonegirls iq4_all_noneother iq4_all_nonerefugees ///
		iq4_all_otherchildren iq4_all_otherethnic iq4_all_othergirls iq4_all_otherother iq4_all_otherrefugees ///
		iq4_all_provofficialchildren iq4_all_provofficialethnic iq4_all_provofficialgirls iq4_all_provofficialother iq4_all_provofficialrefugees ///
		iq4_all_reviewingchildren iq4_all_reviewingethnic iq4_all_reviewinggirls iq4_all_reviewingother iq4_all_reviewingrefugees ///
		iq4_all_schoolbasedchildren iq4_all_schoolbasedethnic iq4_all_schoolbasedgirls iq4_all_schoolbasedother iq4_all_schoolbasedrefugees ///
     jq2a jq2b jq2c jq2d ///
     kq1 kq2promotingphysicaldistancing kq2promotinghandwashingpracti kq2promotinggoodrespiratoryhy kq2improvedhandwashingfaciliti ///
	kq2increasedsurfacefoodprepa kq2improvedmanagementofinfect kq2selfisolationofstaffands kq2temperaturechecksinschool kq2testingforcovid19inschoo /// 
	kq2trackingstaffandstudentsw kq2selfscreeningformapp_ kq2other_ kq2anationalorsubnationalsurv kq2ainspectionsbynationalors kq2ainspectionsbylocaleducati ///
	kq2athroughaschoollevelcommi kq2aotherpleasespecify_ kq2anomonitoringoftheapplica kq2clackofsafetycommitmentfr kq2cpoorsafetyculture_ kq2clackofadministrativecommi ///
	kq2clackofstrictenforcemento kq2clackofresourcesforimplem kq2clackofmedicalfacilitiesa kq2clackofdoortodoorservice kq2clackofpropercommunication ///
	kq2clackofgovernmentpolicies_ kq2cpublicstigmatization_ kq2cdonotknow_ kq2cotherpleasespecify_ kq4engagetheentireschoolcomm kq4ensurephysicaldistancingdu kq4prioritizeactivenonmotori ///
	kq4makeitsafetowalkcycle kq4helpstudentswhocycleands kq4reduceprivatevehicleuse kq4treatschoolbusesasextensi kq4promotesafetyandhygieneon ///
	kq4ensureequalaccessonthejo kq4noneoftheabovemeasures kq4donotknow {
		replace `i' =. if `i' == 997 // Don't know
		replace `i' =. if `i' == 998 // Not applicable
		replace `i' =. if `i' == 999 // Missing
}
   
* Variables that you want to keep "Don't know" as one option to show in figures
foreach i in  ///
		eq2_pp_pay eq2_p_pay eq2_ls_pay eq2_us_pay ///
		eq4_all_natofferedspecial eq4_all_natinstruction eq4_all_natppe eq4_all_natguidelines eq4_all_natprofessionaldev eq4_all_natteachingcontent eq4_all_naticttools eq4_all_natnoadditionalsup eq4_all_natother ///
		eq4_all_subnatofferedspecial eq4_all_subnatinstruction eq4_all_subnatppe eq4_all_subnatguidelines eq4_all_subnatprofessionaldev eq4_all_subnatteachingcontent eq4_all_subnaticttools eq4_all_subnatother eq4_all_subnatnoadditionalsup ///
		eq4_all_schoolofferedspecial eq4_all_schoolinstruction eq4_all_schoolppe eq4_all_schoolguidelines eq4_all_schoolprofessionaldev eq4_all_schoolteachingcontent eq4_all_schoolicttools eq4_all_schoolnoadditionalsup eq4_all_schoolother ///
		eq6_all_vaccine ///
    jq1_pp jq1_p jq1_us jq1_ls kq2b ///
		{
		replace `i' =. if `i' == 998 // Not applicable
		replace `i' =. if `i' == 999 // Missing
	}

* We want option of "do not know" to appear as one option: 0
foreach i in  ///
        cq3_pp_first cq3_p_first cq3_ls_first cq3_us_first ///
		cq3_pp_second cq3_p_second cq3_ls_second cq3_us_second ///
		cq3_pp_third cq3_p_third cq3_ls_third cq3_us_third {
		replace `i' =0 if `i' == 997 | `i' == 998 | `i' == 999
	}
	
*** lq*
ds lq*, not(type string)
foreach v in `r(varlist)' {
	replace `v' = 999 if `v' ==.
}

** LQ4
foreach i in pp p ls us {
	foreach j in first second third {
		replace lq4_`i'_`j' = . if lq4_`i'_`j'== 999
	}
}

******* Step E - Data cleaning *******
*S9/iq4/IQ4: 
* Replacing don't know to zero if some options are chosen
* Replace no action to zero if some actions are taken
foreach i in children refugees ethnic girls other {
replace iq4_all_donotknow`i'=0 if iq4_all_com`i'==1 | iq4_all_provofficial`i'==1 | iq4_all_schoolbased`i'==1 | iq4_all_reviewing`i'==1 | iq4_all_makemod`i'==1 | iq4_all_none`i'==1
replace iq4_all_none`i'     =0 if iq4_all_com`i'==1 | iq4_all_provofficial`i'==1 | iq4_all_schoolbased`i'==1 | iq4_all_reviewing`i'==1 | iq4_all_makemod`i'==1
}

* If do not is chosen, other choices are replaced to 997 from 0. By changing this to be 997, this country will not appear in the denominator of the percent calculation in the figure 
foreach i in children refugees ethnic girls other {
foreach j in com provofficial schoolbased reviewing makemod none {
replace iq4_all_`j'`i'=. if iq4_all_donotknow`i'==1
}
}

* CQ1:
foreach j in pp p ls us {
foreach i in cq1_`j'_assessment cq1_`j'_remedial1 cq1_`j'_remedial2 cq1_`j'_remedial3 cq1_`j'_remedial4 cq1_`j'_remedial5 cq1_`j'_remedial6 cq1_`j'_remedial7 cq1_`j'_remedial8 {
replace `i'=0 if cq1_`j'_none==1
}
}


*---------------------------------------------------------------------------
* section 9. Equity Module
*---------------------------------------------------------------------------

*S9/iq1/Q1.
replace iq1_all_follow = . if iq1_all_follow == 999
replace iq1_all_follow = . if iq1_all_follow == 998
replace iq1_all_follow = . if iq1_all_follow == 997


*S9/iq1a/Q1A.
foreach i in planclosereopen healthsafestandard mandatoryattend distancelearnmod other {
	replace iq1a_all_`i' = . if iq1a_all_`i' == 999
	replace iq1a_all_`i' = . if iq1a_all_`i' == 998
	replace iq1a_all_`i' = . if iq1a_all_`i' == 997
}

*S9/iq2/Q2.
replace iq2_all_follow = . if iq2_all_follow == 999
replace iq2_all_follow = . if iq2_all_follow == 998
replace iq2_all_follow = . if iq2_all_follow == 997

*S9/iq2a/Q2A.
foreach i in planclosereopen healthsafestandard mandatoryattend distancelearnmod other {
	replace iq2a_all_`i' = . if iq2a_all_`i' == 999
	replace iq2a_all_`i' = . if iq2a_all_`i' == 998
	replace iq2a_all_`i' = . if iq2a_all_`i' == 997
}


*S9/iq3/Q3. 
foreach j in children refugees ethnic girls other {
	    foreach i in addfinance specialeffort subsdevice tailorlearn flexible none other {
			replace iq3_all_`i'`j' = . if iq3_all_`i'`j' == 999
			replace iq3_all_`i'`j' = . if iq3_all_`i'`j' == 998
			replace iq3_all_`i'`j' = . if iq3_all_`i'`j' == 997
	}
}


*S9/iq4/Q4. 
foreach j in children refugees refugee ethnic girls other {
	    foreach i in com provofficial schoolbased reviewing makemod donotknow none other {
		cap noi:	replace iq4_all_`i'`j' = . if iq4_all_`i'`j' == 997
		cap noi:	replace iq4_all_`i'`j' = . if iq4_all_`i'`j' == 998
		cap noi:	replace iq4_all_`i'`j' = . if iq4_all_`i'`j' == 999
	}
}


*---------------------------------------------------------------------------
* section 12. 2021 Planning
*---------------------------------------------------------------------------
*S12/lq1/Q1.
replace lq1 = . if lq1 == 999
replace lq1 = . if lq1 == 998
replace lq1 = . if lq1 == 997

*S12/lq1a/Q1A.
foreach i in nationalprevalencerates localprevalencerates inschooloutbreak otherpleasespecify {
	replace lq1a_`i' = . if lq1a_`i' == 999
	replace lq1a_`i' = . if lq1a_`i' == 998	
	replace lq1a_`i' = . if lq1a_`i' == 997
}

*S12/lq2/Q2.
foreach i in nationwide byregion schoolbyschool schoolbyschoolb schoolbyschoolbasis {
	foreach j in offer subsidized nomeasures other donotknow {
		cap noi: replace lq2`j'_`i' = . if lq2`j'_`i' == 999
		cap noi: replace lq2`j'_`i' = . if lq2`j'_`i' == 998
		cap noi: replace lq2`j'_`i' = . if lq2`j'_`i' == 997
	}
}

*S12/lq3/Q3.
replace lq3 = . if lq3 == 999
replace lq3 = . if lq3 == 998
replace lq3 = . if lq3 == 997

*S12/lq4/Q4.
foreach i in pp p ls us {
	foreach j in first second third { 
			replace lq4_`i'_`j' = . if lq4_`i'_`j' == 999
			replace lq4_`i'_`j' = . if lq4_`i'_`j' == 998
			replace lq4_`i'_`j' = . if lq4_`i'_`j' == 997
	}
} 

*S12/lq5/Q5.
foreach i in digitalskillstraining fosteringsocialandemotiona developingattitudesknowled healtheducationandlearning other none donotknow {
	replace lq5`i' = . if lq5`i' == 999
	replace lq5`i' = . if lq5`i' == 998
	replace lq5`i' = . if lq5`i' == 997
}

*S12/lq6/Q6.
replace lq6 = . if lq6 == 999
replace lq6 = . if lq6 == 998
replace lq6 = . if lq6 == 997

*---------------------------------------------------------------------------


*---------------------------------------------------------------------------
* 3)  Clean and Merge Country Metadata
*---------------------------------------------------------------------------
** Gen dummy variabls: 0-100 for figure 
	*S3/cq3/Q3.
	foreach v in cq3_pp_first cq3_p_first cq3_ls_first cq3_us_first ///
	             eq2_pp_pay eq2_p_pay eq2_ls_pay eq2_us_pay ///
				 eq6_all_vaccine  {
	levelsof `v'
	foreach value in `r(levels)' {
	gen     `v'_`value'=0
	replace `v'_`value'=100 if `v'==`value'
	replace `v'_`value'=. if `v'==.
	label var `v'_`value' "`: label (`v') `value''"
	}
	}
	
*****************************
* Merge country level data *
*****************************

merge 1:1 countrycode using "${Data_raw}/wbg_country_metadata.dta"

*****************************
* Merge Enrollment data     *
*****************************
merge 1:1 countrycode using "${Data_raw}/enrollment.dta", nogen keep(match master)

*****************************
* Merge population data      *
*****************************
merge 1:1 countrycode using "${Data_raw}/population.dta", nogen keep(match master)

*****************************
* Merge HLO	 data (for aq6) *
*****************************
gen income_num = (incomelevel == "LIC")

replace income_num = 2 if incomelevel == "LMC"
replace income_num = 3 if incomelevel == "UMC"
replace income_num = 4 if incomelevel == "HIC"
lab def income 1 "Low income" 2 "Lower middle income" 3 "Upper middle income" 4 "High income"
lab val income_num income

gen N=1 

 * Expand dataset prior to collapse so that Global becomes a category
expand 2, gen(expanded)
replace income_num = 5              if expanded == 1
replace incomelevelname  = "Global" if expanded == 1

save "${Data_clean}/save_all_countries.dta", replace

drop if expanded == 1
drop if _merge == 2

drop _merge expanded

tempfile appended_data
save `appended_data', replace
wbopendata, indicator(hd.hci.hlos) long clear
		
		keep if year == 2020
		drop countryname region* admin* income* lending*
		
		merge 1:m countrycode using `appended_data', nogen
    
    keep if income_num !=. 
    
*---------------------------------------------------------------------------


*---------------------------------------------------------------------------
* 4)  Create Harmonized and Base Output
*---------------------------------------------------------------------------
drop countryname
order countrycode country q_consent region_wbg regionname_wbg incomelevel incomelevelname lendingtype lendingtype lendingtypename income_num year_enrollment enrollment year_population population_0417 hd_hci_hlos

save "${Data_clean}jsw3_uis_oecd_clean.dta", replace
*---------------------------------------------------------------------------


