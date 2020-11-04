import excel using "${Data_raw}/Response_final_20200720.xlsx", firstrow case(lower) sheet("Dataset") clear
************************Step 3 - Rename     ***************************************
* Country code: 118
gen ID_Survey=_n
do "${Do}03_1_1_JointMoE Survey_Rename.do"

*reclink country using "${Data_Cleaned}Countrycodes,WB&UNICEF_shared.dta", idm(ID_Survey) idu(Ccode) g(Match_Score_Income) mins(0.98) _merge(Merge_Income)

* Region code
gen region=.
replace region=1 if B=="Africa (Northern)"
replace region=2 if B=="Africa (Sub-Saharan) "
replace region=3 if B=="Asia (Central and Southern)"
replace region=4 if B=="Asia (Eastern and South-eastern)"
replace region=5 if B=="Asia (Western)"
replace region=6 if B=="Europe"
replace region=7 if B=="Latin America and the Caribbean"
replace region=8 if B=="Oceania"

label define region 1 "Africa (Northern)" 2 "Africa (Sub-Saharan)" 3 "Asia (Central and Southern)" ///
4 "Asia (Eastern and South-eastern)" 5 "Asia (Western)" 6 "Europe" 7 "Latin America and the Caribbean" 8 "Oceania", modify
label values region region
drop B

foreach i in Q2_New_Teacher Q3_Remedy Q3_Calendar_Adjust Q3_Increase Q3_Accelerate Q4_Scope_adjust Q7_Radio_monitor Q7_TV_monitor Q7_Online_monitor Q7_Paper_monitor ///
             Q10_MinEdu_Maint Q10_MinEdu_Creat Q10_O_Source_Maint Q10_O_Source_Creat Q10_Teaher_Maint Q10_Teaher_Creat Q10_Broad_Maint Q10_Broad_Creat Q10_Other_Maint Q10_Other_Creat Q10_comment ///
             Q11_Modality_PrePri Q11_Modality_Pri Q11_Modality_Lsec Q11_Modality_Usec ///
             Q15_Support Q16_salary ///
             Q20_assess_learn_radio Q20_assess_learn_TV Q20_assess_learn_Online Q20_assess_learn_Phone Q20_assess_learn_Paper ///
			 Q21_exam_Pri Q21_exam_Sec Q21_exam_Univ ///
			 Q5_calendar_affect Q11_All_covered_PrePri Q11_All_covered_Pri Q11_All_covered_Lsec Q11_All_covered_Usec Q11_OER_used_PrePri Q11_OER_used_Pri Q11_OER_used_Lsec Q11_OER_used_Usec ///
			 Q13_Instruct_PrePri Q13_Instruct_Pri Q13_Instruct_Lsec Q13_Instruct_Usec Q14_Train_PrePri Q14_Train_Pri Q14_Train_Lsec Q14_Train_Usec {
replace `i'="999" if `i'=="Not recorded"
}

************************Step 4 - String to numerical (Yes, No, Select all that apply) ***************************************
do "${Do}03_1_2_JointMoE Survey_Destring.do"

************************Step 5 - Variable labeling ***************************************
do "${Do}03_1_3_JointMoE Survey_Labeling.do"

************************Step 6 - Data cleaning ***************************************
* The policy of data cleaning is based on "UNESCO_UNICEF_WB_Data_Cleaning_Process.docx"

*************** List of the questions that did not follow the skipping pattern ********
* Q1: What are the current plans for reopening schools in your education system?
* Expected re-opening date:
* Replace to Do not know if the date is recorded in the following question.
foreach i in PrePri Pri Lsec Usec {
replace Q1_`i'_NW=0 if Q1_`i'_dates!="" & Q1_`i'_NW==999
replace Q1_`i'_PG=0 if Q1_`i'_dates!="" & Q1_`i'_PG==999
replace Q1_`i'_PS=0 if Q1_`i'_dates!="" & Q1_`i'_PS==999
replace Q1_`i'_DK=1 if Q1_`i'_dates!="" & Q1_`i'_DK==999
replace Q1_`i'_NC=0 if Q1_`i'_dates!="" & Q1_`i'_NC==999
}
* In Question 1(Q1) Subquestion Pre-primary(PP)-Expected re-opening date(EO), the variable associated with this subquestion is "Q1_PP_EO" in the dataset. The option "Not recorded" will be added into the variable  "Q1_PP_EO". The variable will thus be replaced as "not recorded" if at least one of the top three options ("Nation-wide", "Partial/Gradual", "Phasing students") of the response to preceding questions "Q1_PP_*" is selected.
foreach i in PrePri Pri Lsec Usec {
replace Q1_`i'_dates="999" if Q1_`i'_dates=="" & (Q1_`i'_NW==1 | Q1_`i'_PG==1 | Q1_`i'_PS==1 | Q1_`i'_DK==1 | Q1_`i'_NC==1)
}

* Q3: Has the current school calendar been adjusted (or are there plans in place to adjust it)?
* Following question: If "Yes", specify: Is there a new end date?, Is there a new starting date for the next school year?
* Replace to Yes if the following question is recorded as Yes.
list country if Q3_Calendar_Adjust==0 & (Q3_New_end_date==1 | Q3_New_start_date==1)
replace Q3_Calendar_Adjust=1 if (Q3_New_end_date==1 | Q3_New_start_date==1) 

***** UNESCO FIXED *****
* Q3: Will you increase class time when schools re-open?
* Following question: Specify how many hours per day:
* Replace to Yes if the positive hours is recorded
tab Q3_Increase if Q3_Increase!=999
list country if Q3_Increase==0 & (Q3_Increase_hours>0 & Q3_Increase_hours!=999)
replace Q3_Increase=1 if (Q3_Increase_hours>0 & Q3_Increase_hours!=999)
tab Q3_Increase if Q3_Increase!=999

* Q3: Has the current school calendar been adjusted (or are there plans in place to adjust it)?
* If "Yes", specify
* Replace No (=0) to missing if the calendar is not adjusted, but new start/end data is recorded as No
* Otherwise, the mean statistics would be affected by response that did not follow the skipping pattern
replace Q3_New_end_date=999   if Q3_Calendar_Adjust==0 & Q3_New_end_date==0
replace Q3_New_start_date=999 if Q3_Calendar_Adjust==0 & Q3_New_start_date==0

***** UNESCO FIXED *****
* Q4: Is there a plan to adjust the scope of contents to be covered?
* Following question: if "Yes", specify:
* Replace to Yes if the following question is recorded
tab Q4_Scope_adjust if Q4_Scope_adjust!=999
list country if Q4_Scope_adjust==0 & (Q4_Reduce_content==1 | Q4_Reduce_subjects==1 | Q4_School_discretion==1)
list country if Q4_Scope_adjust==999 & (Q4_Reduce_content==1 | Q4_Reduce_subjects==1 | Q4_School_discretion==1)
replace Q4_Scope_adjust=1 if (Q4_Reduce_content==1 | Q4_Reduce_subjects==1 | Q4_School_discretion==1) 
tab Q4_Scope_adjust if Q4_Scope_adjust!=999

* Replace No (=0) to missing if the adjustment did not occur
* Otherwise, the mean statistics would be affected by response that did not follow the skipping pattern
foreach i in Q4_Reduce_content Q4_Reduce_subjects Q4_School_discretion {
replace      `i'=999 if Q4_Scope_adjust==999 | Q4_Scope_adjust==0
}

* Q6. Types of delivery systems: Which of the following education delivery systems have been deployed as part of the national
*    (or subnational) distance education strategy for different levels of education?
* Following question: If "Yes", how many hours per week:
foreach i in Q6_Radio_PrePri Q6_Radio_Pri Q6_Radio_Lsec Q6_Radio_Usec Q6_TV_PrePri Q6_TV_Pri Q6_TV_Lsec Q6_TV_Usec {
* List of countries with missing information about deployment, but recorded 0 for hours: Deployment is changed to No
list country if `i'_deployed==. & `i'_hours==0
replace `i'_deployed=0 if `i'_deployed==. & `i'_hours==0

* List of countries with missing information about deployment, but recorded >0 for hours: Deployment is changed to Yes
list country if `i'_deployed==. & (`i'_hours>0 & `i'_hours!=.) 
replace `i'_deployed=1 if `i'_deployed==. & (`i'_hours>0 & `i'_hours!=.) 

* List of countries with Yes for deployment, but hours is zero: Replace to missing
list country if `i'_deployed==1 & `i'_hours==0
replace `i'_hours=999 if `i'_deployed==1 & `i'_hours==0
}

***** UNESCO FIXED *****
* Replace No (=0) to missing if the Radio/TV is not deployed, but hour is recorded as zero hours
* Otherwise, the mean statistics would be affected by response that did not follow the skipping pattern
foreach i in PrePri Pri Lsec Usec {
replace Q6_Radio_`i'_hours=999 if Q6_Radio_`i'_deployed==999 & Q6_Radio_`i'_hours==0
replace Q6_Radio_`i'_hours=999 if Q6_Radio_`i'_deployed==0   & Q6_Radio_`i'_hours==0
replace    Q6_TV_`i'_hours=999 if Q6_TV_`i'_deployed==999    & Q6_TV_`i'_hours==0
replace    Q6_TV_`i'_hours=999 if Q6_TV_`i'_deployed==0      & Q6_TV_`i'_hours==0
}

*** Q7: Coverage of distance education delivery systems: Is the actual use monitored?
*** Following question: If yes, please indicate estimated share (%) of children/youth accessing each distance learning system:
foreach k in Radio TV Online Paper {
foreach i in PrePri Pri Lsec Usec {
* Fixing skipping pattern
list country if (Q7_`k'_monitor==0) & Q7_Share_`i'_`k'>0 & Q7_Share_`i'_`k'!=.
list country if (Q7_`k'_monitor==999) & Q7_Share_`i'_`k'>0 & Q7_Share_`i'_`k'!=.
list country if (Q7_`k'_monitor==998) & Q7_Share_`i'_`k'>0 & Q7_Share_`i'_`k'!=.
replace Q7_`k'_monitor=1 if Q7_Share_`i'_`k'>0 & Q7_Share_`i'_`k'!=. & Q7_`k'_monitor==0
replace Q7_`k'_monitor=1 if Q7_Share_`i'_`k'>0 & Q7_Share_`i'_`k'!=. & Q7_`k'_monitor==998
replace Q7_`k'_monitor=1 if Q7_Share_`i'_`k'>0 & Q7_Share_`i'_`k'!=. & Q7_`k'_monitor==999

* Replace percentage of children as missing if the share reached is recoreded as zero 
* Most likely the service is not provided,
list country if Q7_Share_`i'_`k'==0
replace Q7_Share_`i'_`k'=999 if Q7_Share_`i'_`k'==0
replace Q7_Share_`i'_`k'=999 if Q7_Share_`i'_`k'==.
}
}

* Q12: Are teachers required to continue teaching while schools are closed?
* Following question: If online, through which platform:
* List of countries with no online use, but responded to "If online, which platform". 
* No replacement is conducted becuase we do not know which oneline use was available (pre-pri, pri, secondary) 
list country if (Q12_online_Minist==1 | Q12_online_Private==1) & (Q12_teacher_PrePri_Online!=1 & Q12_teacher_Pri_Online!=1 & Q12_teacher_Lsec_Online!=1 & Q12_teacher_Usec_Online!=1)

* Q15: Have teachers been provided with any additional support in the specific context of Covid-19 to help them with the transition to remote learning?
* [If yes, select all that apply]
* Replace to Yes if some support is recorded.
list country if Q15_Support==0 & (Q15_Onlinetraining==1 | Q15_tools==1 | Q15_emotion==1 | Q15_content==1)
replace Q15_Support=1 if (Q15_Onlinetraining==1 | Q15_tools==1 | Q15_emotion==1 | Q15_content==1)

* Replace No (=0) to missing if the adjustment did not occur
* Otherwise, the mean statistics would be affected by response that did not follow the skipping pattern
foreach i in Q15_Onlinetraining Q15_tools Q15_emotion Q15_content {
replace      `i'=999 if Q15_Support==999 | Q15_Support==0
}

* Q21: High stake examinations, Do high stake examinations exist?
* Following question: If yes, which of the following measures have been taken with respect to high-stakes examinations? [Select all that apply]
* If any of the following question is recorded as yes, exam exist is changed to Yes
foreach i in Pri Sec Univ {
list country if (Q21_exam_`i'==0) & (Q21_exam_`i'_Cont==1 | Q21_exam_`i'_Stag==1 | Q21_exam_`i'_Dist==1 | Q21_exam_`i'_Post==1 | Q21_exam_`i'_Online==1 | Q21_exam_`i'_Redu==1 | Q21_exam_`i'_Intr==1 | Q21_exam_`i'_Canc==1)
replace Q21_exam_`i'=1 if (Q21_exam_`i'_Cont==1 | Q21_exam_`i'_Stag==1 | Q21_exam_`i'_Dist==1 | Q21_exam_`i'_Post==1 | Q21_exam_`i'_Online==1 | Q21_exam_`i'_Redu==1 | Q21_exam_`i'_Intr==1 | Q21_exam_`i'_Canc==1)

foreach v in Q21_exam_`i'_Cont Q21_exam_`i'_Stag Q21_exam_`i'_Dist Q21_exam_`i'_Post Q21_exam_`i'_Online Q21_exam_`i'_Redu  Q21_exam_`i'_Intr Q21_exam_`i'_Canc {
replace `v'=999 if Q21_exam_`i'==0 | Q21_exam_`i'==999
}
}

* Q8-Q12 refers to countries that provide online distance learning. If they do not provide online distance learning, skip to Question 12.
* List of countries where online is not deployed at any level
* No action taken
gen     No_online=0
replace No_online=1 if Q6_Online_PrePri_deployed==0 & Q6_Online_Pri_deployed==0 & Q6_Online_Lsec_deployed==0 & Q6_Online_Usec_deployed==0    
list country if No_online==1

*****************************************
* Clearning policy with all thata apply *
* For all that apply (with none as a choice), response with no answer selected for any choice is considered as missing (Don't know)
*****************************************
replace Q17_disability=. if Q17_disability==0 & Q17_access==0 & Q17_language==0 & Q17_device==0 & Q17_none==0 & Q17_dontknow==0 
foreach i in Q17_access Q17_language Q17_device Q17_none Q17_dontknow {
replace `i'=. if Q17_disability==.
}

replace Q18_mental=. if Q18_protection==0 & Q18_meal==0 & Q18_welbe==0 & Q18_none==0 
foreach i in Q18_protection Q18_meal Q18_welbe Q18_none {
replace `i'=. if Q18_mental==.
}

replace Q19_childcare=. if Q19_emergency_childcare==0 & Q19_finance==0 & Q19_guide_prisec==0 & Q19_guide_prepri==0 & Q19_tips==0 & Q19_meal==0 & ///
                           Q19_counsel_Child==0 & Q19_counsel_caregiver==0 & Q19_telephone==0 & Q19_none==0 
foreach i in Q19_emergency_childcare Q19_finance Q19_guide_prisec Q19_guide_prepri Q19_tips Q19_meal Q19_counsel_Child Q19_counsel_caregiver Q19_telephone Q19_none {
replace `i'=. if Q19_childcare==.
}

*unique country

* Replacing the missing information as No: 
* Online remote learning use is monitored, but the assessment was kept as missing
replace Q20_assess_learn_Online=0 if Q7_Online_monitor==1 & Q20_assess_learn_Online==999
replace Q20_assess_learn_Online=0 if Q7_Online_monitor==0 & Q20_assess_learn_Online==999

 *****Q2: teachers for reopening*****
 // generating variables for countries where schools didnt close
 gen     schools_nc=1 if (Q1_PrePri_NC==1 & Q1_Pri_NC==1 & Q1_Lsec_NC==1 & Q1_Usec_NC==1)
 replace schools_nc=0 if schools_nc==.

* save "${Data_Cleaned}UNESCO_UNICEF_WB.dta", replace
* export excel using "${Data_Cleaned}UNESCO_UNICEF_WB.xlsx", firstrow(variables) replace
* describe _all, replace clear
* export excel using "${Data_Cleaned}UNESCO_UNICEF_WB.xlsx", first(var) sheet("Label") sheetmodify


