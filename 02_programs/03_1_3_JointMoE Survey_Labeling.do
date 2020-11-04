label var Q2_New_Teacher     "New teacher recruited"
label var Q3_Calendar_Adjust "School calendar adjusted"
label var Q3_New_end_date    "New end date"
label var Q3_New_start_date  "New start date"
label var Q3_Increase "Increase class time"
label var Q3_Remedy "Introduce remedial program"
label var Q3_Accelerate "Accelerate learning program"
label var Q4_Scope_adjust "Adjust the scope of the program"
label var Q4_Reduce_content "Reduce content covered within subjects"
label var Q4_Reduce_subjects "Reduce number of subjects"
label var Q4_School_discretion "Leave it to the discretion of schools"
label var Q4_other_specify "Others"

label var Q5_calendar_affect "Next year school calendar affected"

foreach k in PrePri Pri Lsec Usec {
foreach i in Radio TV Online Paper {
local PrePri "Pre-primary"
local Pri    "Primary"
local Lsec   "Lower Secondary"
local Usec   "Upper Secondary"

local Online "Online"
local TV "TV"
local Radio "Radio"
local Paper "Paper-based"
label var Q6_`i'_`k'_deployed "``i'' learning deployed at ``k''"
label var Q7_Share_`k'_`i' "Share of children reached by ``i'' (``k'')"
label var Q7_`i'_monitor "``i'' monitored"
}
}

foreach k in PrePri Pri Lsec Usec {
foreach i in Radio TV {
local TV "TV"
local Radio "Radio"
label var Q6_`i'_`k'_hours "``i'' learning at ``k''(hours)"
}
}

label var Q9_Open_platform     "Open source platform"
label var Q9_Domestic_platform "Domestic platform"
label var Q9_Commercial_free   "Commercial (Free)"
label var Q9_Commercial        "Commercial"

label var Q12_online_Minist  "Online platform (Ministry of Education)"
label var Q12_online_Private "Online platform (Private sector)"

label var Q15_Support        "Additional support"
label var Q15_Onlinetraining "Additional support: Online training"
label var Q15_tools          "Additional support: Provision of tools"
label var Q15_emotion        "Additional support: Emotional support"
label var Q15_content        "Additional support: Teaching content"
label var Q15_dontknow       "Additional support: Don't know"

label var Q17_disability "Support to learners with disabilities"
label var Q17_access "Improved access to infrastructure"
label var Q17_language "learning materials for minority languages"
label var Q17_device "Subsidized devices for access"
label var Q17_none "None"
label var Q17_dontknow "Don't know"
label var Q18_mental "Psychosocial/mental health support"
label var Q18_protection "Additional child protection services"
label var Q18_meal "School meal services"
label var Q18_welbe "Mechanisms for monitoring student well-being"
label var Q18_none "No measure"
       
label var Q19_childcare "Childcare services remaining open"
label var Q19_emergency_childcare "Childcare services available for frontline workers"
label var Q19_finance "Financial support"
label var Q19_guide_prisec "Guidance materials for primary/secondary"
label var Q19_guide_prepri "Guidance materials for pre-primary education"
label var Q19_tips "Tips and materials for continued stimulation"
label var Q19_meal "Meals/food rations to families of students"
label var Q19_counsel_Child "Psychosocial counselling services"
label var Q19_counsel_caregiver "Psychosocial support for caregivers"
label var Q19_telephone "Regular telephone follow-up by school"
label var Q19_none "No measures"
