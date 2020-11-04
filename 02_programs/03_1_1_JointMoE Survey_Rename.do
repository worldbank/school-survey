**************************
* Rename: Systematically *
**************************
* No firstrow is used as the first row as some row has the same label
rename countryname            country
rename sdg_region B

rename q1_pp_nw Q1_PrePri_NW
rename q1_pp_pg Q1_PrePri_PG 
rename q1_pp_ps Q1_PrePri_PS
rename q1_pp_dnk Q1_PrePri_DK
rename q1_pp_nc Q1_PrePri_NC

rename q1_p_nw Q1_Pri_NW
rename q1_p_pg Q1_Pri_PG 
rename q1_p_ps Q1_Pri_PS
rename q1_p_dnk Q1_Pri_DK
rename q1_p_nc Q1_Pri_NC

rename q1_ls_nw Q1_Lsec_NW
rename q1_ls_pg Q1_Lsec_PG 
rename q1_ls_ps Q1_Lsec_PS
rename q1_ls_dnk Q1_Lsec_DK
rename q1_ls_nc Q1_Lsec_NC

rename q1_us_nw Q1_Usec_NW
rename q1_us_pg Q1_Usec_PG 
rename q1_us_ps Q1_Usec_PS
rename q1_us_dnk Q1_Usec_DK
rename q1_us_nc Q1_Usec_NC

rename  q1_pp_eo Q1_PrePri_dates
rename  q1_p_eo Q1_Pri_dates
rename  q1_ls_eo Q1_Lsec_dates
rename  q1_us_eo Q1_Usec_dates

rename q2 Q2_New_Teacher
rename q3_remedical Q3_Remedy
rename q3_adj Q3_Calendar_Adjust
rename q3_increasewhenopen Q3_Increase
rename q3_accelerate Q3_Accelerate
rename q3_adj_newend   Q3_New_end_date
rename q3_adj_newstart Q3_New_start_date
rename q3_increasewhenopen_specify   Q3_Increase_hours

rename q4 Q4_Scope_adjust
rename q4_reduce Q4_Reduce_content
rename q4_number Q4_Reduce_subjects
rename q4_leave Q4_School_discretion
rename q4_other Q4_other_specify

rename q5 Q5_calendar_affect

rename q6_radio_pp     Q6_Radio_PrePri_deployed 
rename q6_radio_pp_yes Q6_Radio_PrePri_hours
rename q6_radio_p      Q6_Radio_Pri_deployed
rename q6_radio_p_yes  Q6_Radio_Pri_hours
rename q6_radio_ls     Q6_Radio_Lsec_deployed
rename q6_radio_ls_yes Q6_Radio_Lsec_hours
rename q6_radio_us     Q6_Radio_Usec_deployed
rename q6_radio_us_yes Q6_Radio_Usec_hours

rename q6_tv_pp     Q6_TV_PrePri_deployed 
rename q6_tv_pp_yes Q6_TV_PrePri_hours
rename q6_tv_p  Q6_TV_Pri_deployed
rename q6_tv_p_yes Q6_TV_Pri_hours
rename q6_tv_ls Q6_TV_Lsec_deployed
rename q6_tv_ls_yes Q6_TV_Lsec_hours
rename q6_tv_us Q6_TV_Usec_deployed
rename q6_tv_us_yes Q6_TV_Usec_hours

rename q6_online_pp Q6_Online_PrePri_deployed 
rename q6_online_p  Q6_Online_Pri_deployed
rename q6_online_ls Q6_Online_Lsec_deployed
rename q6_online_us Q6_Online_Usec_deployed

rename q6_paper_pp Q6_Paper_PrePri_deployed 
rename q6_paper_p  Q6_Paper_Pri_deployed
rename q6_paper_ls Q6_Paper_Lsec_deployed
rename q6_paper_us Q6_Paper_Usec_deployed

rename q7_radio Q7_Radio_monitor
rename q7_tv Q7_TV_monitor
rename q7_online Q7_Online_monitor
rename q7_paper Q7_Paper_monitor

rename q7_radio_yes_pp  Q7_Share_PrePri_Radio
rename q7_tv_yes_pp     Q7_Share_PrePri_TV
rename q7_online_yes_pp Q7_Share_PrePri_Online
rename q7_paper_yes_pp  Q7_Share_PrePri_Paper

rename q7_radio_yes_p  Q7_Share_Pri_Radio
rename q7_tv_yes_p     Q7_Share_Pri_TV
rename q7_online_yes_p Q7_Share_Pri_Online
rename q7_paper_yes_p  Q7_Share_Pri_Paper

rename q7_radio_yes_ls  Q7_Share_Lsec_Radio
rename q7_tv_yes_ls     Q7_Share_Lsec_TV
rename q7_online_yes_ls Q7_Share_Lsec_Online
rename q7_paper_yes_ls  Q7_Share_Lsec_Paper

rename q7_radio_yes_us  Q7_Share_Usec_Radio
rename q7_tv_yes_us     Q7_Share_Usec_TV
rename q7_online_yes_us Q7_Share_Usec_Online
rename q7_paper_yes_us  Q7_Share_Usec_Paper

rename q8_measures Q8_Access

rename q9_open Q9_Open_platform
rename q9_domestic Q9_Domestic_platform
rename q9_commercialfree Q9_Commercial_free
rename q9_commercial Q9_Commercial

rename q10_maintain_moe Q10_MinEdu_Maint
rename q10_create_moe Q10_MinEdu_Creat
rename q10_maintain_os Q10_O_Source_Maint
rename q10_create_os Q10_O_Source_Creat
rename q10_maintain_teachers Q10_Teaher_Maint
rename q10_create_teachers Q10_Teaher_Creat
rename q10_maintain_bc Q10_Broad_Maint
rename q10_create_bc Q10_Broad_Creat
rename q10_maintain_other Q10_Other_Maint
rename q10_create_other Q10_Other_Creat
rename q10_comments Q10_comment
rename q11_cover_pp  Q11_All_covered_PrePri
rename q11_cover_p Q11_All_covered_Pri
rename q11_cover_ls Q11_All_covered_Lsec 
rename q11_cover_us Q11_All_covered_Usec
rename q11_oer_pp Q11_OER_used_PrePri
rename q11_oer_p Q11_OER_used_Pri
rename q11_oer_ls Q11_OER_used_Lsec
rename q11_oer_us Q11_OER_used_Usec 

rename q11_modality_pp Q11_Modality_PrePri
rename q11_modality_p  Q11_Modality_Pri 
rename q11_modality_ls Q11_Modality_Lsec
rename q11_modality_us Q11_Modality_Usec 

rename q12_pp_paper   Q12_teacher_PrePri_Paper
rename q12_pp_online  Q12_teacher_PrePri_Online
rename q12_pp_tvradio Q12_teacher_PrePri_TVRadio
rename q12_pp_phone   Q12_teacher_PrePri_Phone
rename q12_pp_other   Q12_teacher_PrePri_other_specify

rename q12_p_paper   Q12_teacher_Pri_Paper
rename q12_p_online  Q12_teacher_Pri_Online
rename q12_p_tvradio Q12_teacher_Pri_TVRadio
rename q12_p_phone   Q12_teacher_Pri_Phone
rename q12_p_other   Q12_teacher_Pri_other_specify

rename q12_ls_paper   Q12_teacher_Lsec_Paper
rename q12_ls_online  Q12_teacher_Lsec_Online
rename q12_ls_tvradio Q12_teacher_Lsec_TVRadio
rename q12_ls_phone   Q12_teacher_Lsec_Phone
rename q12_ls_other   Q12_teacher_Lsec_other_specify

rename q12_us_paper   Q12_teacher_Usec_Paper
rename q12_us_online  Q12_teacher_Usec_Online
rename q12_us_tvradio Q12_teacher_Usec_TVRadio
rename q12_us_phone   Q12_teacher_Usec_Phone
rename q12_us_other   Q12_teacher_Usec_other_specify

rename q12_online_yes_moe Q12_online_Minist
rename q12_online_yes_private Q12_online_Private

rename q13_pp Q13_Instruct_PrePri 
rename q13_p Q13_Instruct_Pri
rename q13_ls Q13_Instruct_Lsec
rename q13_us Q13_Instruct_Usec
rename q14_pp Q14_Train_PrePri
rename q14_p Q14_Train_Pri
rename q14_ls Q14_Train_Lsec
rename q14_us Q14_Train_Usec

rename q15 Q15_Support
rename q15_yes_online Q15_Onlinetraining 
rename q15_yes_ict Q15_tools
rename q15_yes_professional Q15_emotion
rename q15_yes_content Q15_content
rename q15_yes_dnk Q15_dontknow

rename q16 Q16_salary
rename q17_disability Q17_disability
rename q17_improvedaccess Q17_access
rename q17_materialdesign Q17_language
rename q17_subsidizedaccess Q17_device
rename q17_none  Q17_none
rename q17_dnk Q17_dontknow 
rename q17_other Q17_other_specify 

rename q18_psy Q18_mental
rename q18_protection Q18_protection
rename q18_meal Q18_meal
rename q18_monitor Q18_welbe
rename q18_none Q18_none
rename q18_other Q18_other_specify 

rename q19_childcareservicesremaining Q19_childcare
rename q19_emergencychildcareservices Q19_emergency_childcare
rename q19_financialsupporttofamilie Q19_finance
rename q19_guidancematerialsforhome  Q19_guide_prisec 
rename q19_guidancematerialsforprep Q19_guide_prepri
rename q19_tipsandmaterialsforconti Q19_tips
rename q19_mealsfoodrationstofamili Q19_meal
rename q19_psychosocialcounsellingser Q19_counsel_Child 
rename q19_psychosocialsupportforcar Q19_counsel_caregiver
rename q19_regulartelephonefollowup Q19_telephone
rename q19_nomeasures  Q19_none
rename q19_otherpleasespecify Q19_other_specify 

rename q20_radio Q20_assess_learn_radio
rename q20_tv Q20_assess_learn_TV
rename q20_online Q20_assess_learn_Online
rename q20_phone Q20_assess_learn_Phone
rename q20_paper Q20_assess_learn_Paper
rename q21_p Q21_exam_Pri
rename q21_p_yes_continuedonplannedd Q21_exam_Pri_Cont
rename q21_p_yes_staggeredexaminations Q21_exam_Pri_Stag
rename q21_p_yes_distancingstudents Q21_exam_Pri_Dist
rename q21_p_yes_postponedrescheduled Q21_exam_Pri_Post
rename q21_p_yes_onlineexaminationsim Q21_exam_Pri_Online 
rename q21_p_yes_reducedcurriculumcon Q21_exam_Pri_Redu
rename q21_p_yes_introducedalternative Q21_exam_Pri_Intr
rename q21_p_yes_cancelled Q21_exam_Pri_Canc

rename q21_s Q21_exam_Sec
rename q21_s_yes_continuedonplannedd Q21_exam_Sec_Cont
rename q21_s_yes_staggeredexaminations Q21_exam_Sec_Stag
rename q21_s_yes_distancingstudents Q21_exam_Sec_Dist
rename q21_s_yes_postponedrescheduled Q21_exam_Sec_Post
rename q21_s_yes_onlineexaminationsim Q21_exam_Sec_Online 
rename q21_s_yes_reducedcurriculumcon Q21_exam_Sec_Redu
rename q21_s_yes_introducedalternative Q21_exam_Sec_Intr
rename q21_s_yes_cancelled Q21_exam_Sec_Canc

rename q21_univ Q21_exam_Univ
rename q21_univ_yes_continuedonplanne Q21_exam_Univ_Cont
rename q21_univ_yes_staggeredexaminati Q21_exam_Univ_Stag
rename q21_univ_yes_distancingstudents Q21_exam_Univ_Dist
rename q21_univ_yes_postponedreschedul Q21_exam_Univ_Post
rename q21_univ_yes_onlineexaminations Q21_exam_Univ_Online 
rename q21_univ_yes_reducedcurriculum Q21_exam_Univ_Redu
rename q21_univ_yes_introducedalternat Q21_exam_Univ_Intr
rename q21_univ_yes_cancelled Q21_exam_Univ_Canc

* Creating dummy variable of if other is filled or not
foreach i in Q12_teacher_PrePri_other Q12_teacher_Pri_other Q12_teacher_Lsec_other Q12_teacher_Usec_other Q17_other Q18_other Q19_other {
gen `i'=0
replace `i'=1 if `i'_specify!=""
order `i', before(`i'_specify)
}

