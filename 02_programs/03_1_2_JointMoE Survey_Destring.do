******************************
* Change string to numerical * 
******************************
* Avoid using encode. Replace string into number and destring.
local Q4_Reduce_content  "Reduce content covered within subjects"
local Q4_Reduce_subjects  "Reduce number of subjects"
local Q4_School_discretion  "Leave it to the discretion of schools"

local Q12_online_Minist  "Ministry of Education"
local Q12_online_Private "Platforms hosted by private sector"
local Q15_Onlinetraining "Online training seminars"
local Q15_tools          "Provision of ICT tools and free connectivity (PC, mobile device, voucher for mobile broadband, etc.)"
local Q15_emotion        "Professional, psychosocial and emotional support (e.g. chat groups, online forums to share ideas and educational content)"
local Q15_content        "Teaching content (e.g. use of open educational resources (OERs), sample lesson plans etc.)"
local Q15_dontknow       "Don’t know"
local Q17_disability     "Support to learners with disabilities (e.g. sign language in online learning programmes)"
local Q17_access         "Improved access to infrastructure for learners in remote areas; and in urban high-density areas"
local Q17_language       "Design of learning materials for speakers of minority languages"
local Q17_device         "Subsidized devices for access"
local Q17_none           "None"
local Q17_dontknow       "Don’t know"
local Q18_mental         "Psychosocial and mental health support to learners (e.g. online counselling)"
local Q18_protection     "Additional child protection services"
local Q18_meal           "Support to counter interrupted school meal services (e.g. distribution of meals, food banks, vouchers)"
local Q18_welbe          "Mechanisms for monitoring student well-being (e.g. regular calls from teachers, etc.)"
local Q18_none           "No measures"

local Q19_childcare           "Childcare services remaining open for children who cannot be looked after by the parents/caretakers"
local Q19_emergency_childcare "Emergency childcare services available and open for frontline workers"
local Q19_finance             "Financial support to families to pay for private childcare services"
local Q19_guide_prisec        "Guidance materials for home-based learning for primary and secondary education"
local Q19_guide_prepri        "Guidance materials for pre-primary education"
local Q19_tips                "Tips and materials for continued stimulation and play for young children"
local Q19_meal                "Meals/food rations to families of students"
local Q19_counsel_Child       "Psychosocial counselling services for children"
local Q19_counsel_caregiver   "Psychosocial support for caregivers"
local Q19_telephone           "Regular telephone follow-up by school (teacher, principal…)."
local Q19_none                "No measures"

foreach i in Q4_Reduce_content Q4_Reduce_subjects Q4_School_discretion ///
	         Q12_online_Minist Q12_online_Private ///
             Q15_Onlinetraining Q15_tools Q15_emotion Q15_content Q15_dontknow ///
             Q17_disability Q17_access Q17_language Q17_device Q17_none Q17_dontknow ///
			 Q18_mental Q18_protection Q18_meal Q18_welbe Q18_none ///
			 Q19_childcare Q19_emergency_childcare Q19_finance Q19_guide_prisec Q19_guide_prepri ///
			 Q19_tips Q19_meal Q19_counsel_Child Q19_counsel_caregiver Q19_telephone Q19_none ///
			 {
replace  `i'="0"  if `i'==""      // Select all that apply: If cell is missing, the value takes zero (for select all that apply entry). 
replace  `i'="1"  if `i'=="``i''" // Select all that apply: If label matches to the above string, the value takes one. 
destring `i',  replace
}

foreach i in PrePri Pri Lsec Usec {
local PrePri "Pre-primary"
local Pri    "Primary"
local Lsec   "Lower Secondary"
local Usec   "Upper Secondary"
replace  Q12_teacher_`i'_Online="0"  if Q12_teacher_`i'_Online==""
replace  Q12_teacher_`i'_Online="1"  if Q12_teacher_`i'_Online=="Online"
replace  Q12_teacher_`i'_TVRadio="0" if Q12_teacher_`i'_TVRadio==""
replace  Q12_teacher_`i'_TVRadio="1" if Q12_teacher_`i'_TVRadio=="Support to TV/radio based learning"
replace  Q12_teacher_`i'_Phone="0"   if Q12_teacher_`i'_Phone==""
replace  Q12_teacher_`i'_Phone="1"   if Q12_teacher_`i'_Phone=="Mobile phone"
replace  Q12_teacher_`i'_Paper="0"   if Q12_teacher_`i'_Paper==""
replace  Q12_teacher_`i'_Paper="1"   if Q12_teacher_`i'_Paper=="Take-home/paper based"

destring Q12_teacher_`i'_Online,  replace
destring Q12_teacher_`i'_TVRadio, replace
destring Q12_teacher_`i'_Phone,  replace
destring Q12_teacher_`i'_Paper, replace

label var Q12_teacher_`i'_Online "Required to teach with Online (``i'')"
label var Q12_teacher_`i'_TVRadio "Required to teach with TV/Radio (``i'')"
label var Q12_teacher_`i'_Phone "Required to teach with Phone (``i'')"
label var Q12_teacher_`i'_Paper "Required to teach with Take-home/paper based (``i'')"
}

foreach i in PrePri Pri Lsec Usec {
local PrePri "Pre-primary"
local Pri    "Primary"
local Lsec   "Lower Secondary"
local Usec   "Upper Secondary"
replace  Q1_`i'_NW="999" if Q1_`i'_NW=="" & Q1_`i'_PG=="" & Q1_`i'_PS=="" & Q1_`i'_DK=="" & Q1_`i'_NC==""
replace  Q1_`i'_NW="0" if Q1_`i'_NW==""
replace  Q1_`i'_NW="1" if Q1_`i'_NW=="Nation-wide"
replace  Q1_`i'_PG="999" if Q1_`i'_NW=="999"
replace  Q1_`i'_PG="0" if Q1_`i'_PG==""
replace  Q1_`i'_PG="1" if Q1_`i'_PG=="Partial/Gradual"
replace  Q1_`i'_PS="999" if Q1_`i'_NW=="999"
replace  Q1_`i'_PS="0" if Q1_`i'_PS==""
replace  Q1_`i'_PS="1" if Q1_`i'_PS=="Phasing students"
replace  Q1_`i'_DK="999" if Q1_`i'_NW=="999"
replace  Q1_`i'_DK="0" if Q1_`i'_DK==""
replace  Q1_`i'_DK="1" if Q1_`i'_DK=="Do not know"
replace  Q1_`i'_NC="999" if Q1_`i'_NW=="999"
replace  Q1_`i'_NC="0" if Q1_`i'_NC==""
replace  Q1_`i'_NC="1" if Q1_`i'_NC=="Schools are not closed"
replace  Q1_`i'_NC="999" if Q1_`i'_NW=="999"

label var Q1_`i'_NW "``i'' (Nation-wide)"
label var Q1_`i'_PG "``i'' (Partial/Gradual)"
label var Q1_`i'_PS "``i'' (Phasing students)"
label var Q1_`i'_DK "``i'' (Do not know)"
label var Q1_`i'_NC "``i'' (Schools are not closed)"

label var Q11_All_covered_`i'     "All subject covered (``i'')"
label var Q11_OER_used_`i'        "OER used (``i'')"
label var Q13_Instruct_`i'        "Instruction provided (``i'')"
label var Q14_Train_`i'           "Training provided (``i'')"

destring Q1_`i'_NW, replace
destring Q1_`i'_PG, replace
destring Q1_`i'_PS, replace
destring Q1_`i'_DK, replace
destring Q1_`i'_NC, replace
}

foreach i in Q2_New_Teacher Q3_Calendar_Adjust Q3_New_start_date Q3_New_end_date Q3_Increase Q3_Remedy Q3_Accelerate ///
             Q4_Scope_adjust Q5_calendar_affect ///
			 Q6_Radio_PrePri_deployed Q6_Radio_Pri_deployed Q6_Radio_Lsec_deployed Q6_Radio_Usec_deployed ///
			 Q6_TV_PrePri_deployed Q6_TV_Pri_deployed Q6_TV_Lsec_deployed Q6_TV_Usec_deployed ///
			 Q6_Online_PrePri_deployed Q6_Online_Pri_deployed Q6_Online_Lsec_deployed Q6_Online_Usec_deployed ///
			 Q6_Paper_PrePri_deployed Q6_Paper_Pri_deployed Q6_Paper_Lsec_deployed Q6_Paper_Usec_deployed ///
			 Q7_Radio_monitor Q7_TV_monitor Q7_Online_monitor Q7_Paper_monitor ///
			 Q9_Open_platform Q9_Domestic_platform Q9_Commercial_free Q9_Commercial ///
			 Q10_MinEdu_Maint Q10_MinEdu_Creat Q10_O_Source_Maint Q10_O_Source_Creat Q10_Teaher_Maint Q10_Teaher_Creat ///
			 Q10_Broad_Maint Q10_Broad_Creat Q10_Other_Maint Q10_Other_Creat ///
			 Q11_All_covered_PrePri Q11_All_covered_Pri Q11_All_covered_Lsec Q11_All_covered_Usec ///
			 Q11_OER_used_PrePri Q11_OER_used_Pri Q11_OER_used_Lsec Q11_OER_used_Usec ///
			 Q13_Instruct_PrePri Q13_Instruct_Pri Q13_Instruct_Lsec Q13_Instruct_Usec ///
			 Q14_Train_PrePri Q14_Train_Pri Q14_Train_Lsec Q14_Train_Usec ///
			 Q15_Support ///
			 Q21_exam_Pri Q21_exam_Sec Q21_exam_Univ ///
{
replace `i'="1"  if `i'=="Yes"
replace `i'="1"  if `i'=="Yes. How? (specify dates, if any):"
replace `i'="0"  if `i'=="No"
replace `i'="998" if `i'=="Do not know"
replace `i'="999" if `i'==""
destring `i', replace
}

label define sync_Q11_Modality_PrePril 1 "Asynchronous (Pre-primary)" 2 "Synchronous (Pre-primary)" 998 "Do not know (Pre-primary)" , modify
label define sync_Q11_Modality_Pril    1 "Asynchronous (Primary)" 2 "Synchronous (Primary)" 998 "Do not know (Primary)" , modify
label define sync_Q11_Modality_Lsecl    1 "Asynchronous (Lower Secondary)" 2 "Synchronous (Lower Secondary)" 998 "Do not know (Lower Secondary)" , modify
label define sync_Q11_Modality_Usecl    1 "Asynchronous (per Secondary)" 2 "Synchronous (per Secondary)" 998 "Do not know (per Secondary)" , modify
foreach i in Q11_Modality_PrePri Q11_Modality_Pri Q11_Modality_Lsec Q11_Modality_Usec {
replace `i'="1"   if `i'=="Asynchronous"
replace `i'="2"   if `i'=="Synchronous"
replace `i'="998"  if `i'=="Do not know"
replace `i'="999" if `i'==""
destring `i', replace
label values `i' sync_`i'l
}
 
label define Q8_Accessl 1 "Internet at subsidized or zero cost" 2 "Make access available via landline" ///
                   3 "Make access available via mobile phones" 4 "Subsidized/free devices for access" ///
				   5 "No measures taken" 6 "Other" 999 "999" , modify
replace Q8_Access="1"   if Q8_Access=="Offer/negotiate access to internet at subsidized or zero cost"
replace Q8_Access="2"   if Q8_Access=="Make access to distance learning platforms available through landline"
replace Q8_Access="3"   if Q8_Access=="Make access to distance learning platforms available through mobile phones"
replace Q8_Access="4"   if Q8_Access=="Subsidized/free devices for access"
replace Q8_Access="5"   if Q8_Access=="No measures taken"
replace Q8_Access="6"   if Q8_Access=="Other (please specify):"
replace Q8_Access="999" if Q8_Access==""
replace Q8_Access="999" if Q8_Access=="Not recorded"
destring Q8_Access, replace
label values Q8_Access Q8_Accessl

replace Q16_salary="1"  if Q16_salary=="Full-salary"
replace Q16_salary="2"  if Q16_salary=="Yes, with some cuts"
replace Q16_salary="3"  if Q16_salary=="Yes, with supplements"
replace Q16_salary="4"  if Q16_salary=="No"
replace Q16_salary="999" if Q16_salary==""
destring Q16_salary, replace
label define Q16_salaryl 1 "Full-salary" 2 "Yes, with some cuts" 3 "Yes, with supplements" 4 "No" 999 "No response" , modify
label values Q16_salary Q16_salaryl

label define Q20_assess_learn_radiol  0 "Radio: No" 1 "Radio: Yes" 2 "Radio: Up to the district, school and/or teacher" , modify
label define Q20_assess_learn_TVl     0 "TV: No" 1 "TV: Yes" 2 "TV: Up to the district, school and/or teacher" , modify
label define Q20_assess_learn_Onlinel 0 "Online: No" 1 "Online: Yes" 2 "Online: Up to the district, school and/or teacher" , modify
label define Q20_assess_learn_Phonel  0 "Phone: No" 1 "Phone: Yes" 2 "Phone: Up to the district, school and/or teacher" , modify
label define Q20_assess_learn_Paperl  0 "Paper: No" 1 "Paper: Yes" 2 "Paper: Up to the district, school and/or teacher" , modify

foreach i in Q20_assess_learn_radio Q20_assess_learn_TV Q20_assess_learn_Online Q20_assess_learn_Phone Q20_assess_learn_Paper {
replace `i'="0"  if `i'=="No"
replace `i'="1"  if `i'=="Yes"
replace `i'="2"  if `i'=="Up to the district, school and/or teacher"
replace `i'="999"  if `i'==""
destring `i', replace
label values `i' `i'l
}

foreach k in Pri Sec Univ {
local Pri    "Primary"
local Sec    "Secondary"
local Univ    "University"
local Q21_exam_`k'_Cont      "Continued on planned dates"
local Q21_exam_`k'_Stag      "Staggered examinations"
local Q21_exam_`k'_Dist      "Distancing students"
local Q21_exam_`k'_Post      "Postponed/rescheduled examinations"
local Q21_exam_`k'_Online    "Online examinations implemented/scheduled"
local Q21_exam_`k'_Redu      "Reduced curriculum content to be assessed"
local Q21_exam_`k'_Intr      "Introduced alternative assessment/validation of learning (e.g. appraisal of student learning portfolio)"
local Q21_exam_`k'_Canc      "Cancelled"

foreach i in Q21_exam_`k'_Cont Q21_exam_`k'_Stag Q21_exam_`k'_Dist Q21_exam_`k'_Post ///
             Q21_exam_`k'_Online Q21_exam_`k'_Redu Q21_exam_`k'_Intr Q21_exam_`k'_Canc ///
			 {
replace  `i'="0"  if `i'==""
replace  `i'="1"  if `i'=="``i''"
destring `i',  replace

label var Q21_exam_`k' "High stake exam exists (``k'')"
label var Q21_exam_`k'_Cont "Continued on planned dates (``k'')"
label var Q21_exam_`k'_Stag "Staggered examinations (``k'')"
label var Q21_exam_`k'_Dist "Distancing students (``k'')"
label var Q21_exam_`k'_Post   "Postponed/rescheduled examinations (``k'')"
label var Q21_exam_`k'_Online "Online examinations implemented/scheduled (``k'')"
label var Q21_exam_`k'_Redu   "Reduced curriculum content to be assessed (``k'')"
label var Q21_exam_`k'_Intr   "Introduced alternative assessment/validation of learning (``k'')"
label var Q21_exam_`k'_Canc   "Cancelled  (``k'')"
}
}

destring Q3_Increase_hours Q6_Radio_PrePri_hours Q6_Radio_Pri_hours Q6_Radio_Lsec_hours Q6_Radio_Usec_hours Q6_TV_PrePri_hours Q6_TV_Pri_hours Q6_TV_Lsec_hours Q6_TV_Usec_hours , replace
destring Q7_Share_PrePri_Radio Q7_Share_PrePri_TV Q7_Share_PrePri_Online Q7_Share_PrePri_Paper Q7_Share_Pri_Radio Q7_Share_Pri_TV Q7_Share_Pri_Online Q7_Share_Pri_Paper Q7_Share_Lsec_Radio Q7_Share_Lsec_TV Q7_Share_Lsec_Online Q7_Share_Lsec_Paper Q7_Share_Usec_Radio Q7_Share_Usec_TV Q7_Share_Usec_Online Q7_Share_Usec_Paper, replace

* Variable that is alreay numerical: Change no record to missing
foreach i in Q3_Increase_hours ///
             Q6_Radio_PrePri_hours Q6_Radio_Pri_hours Q6_Radio_Lsec_hours Q6_Radio_Usec_hours ///
			 Q6_TV_PrePri_hours Q6_TV_Pri_hours Q6_TV_Lsec_hours Q6_TV_Usec_hours ///
	{
	replace `i'=999 if `i'==.
	}

