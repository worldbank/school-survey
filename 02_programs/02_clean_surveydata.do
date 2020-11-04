********************************************************************************
****** Country: Worldwide
****** Purpose: Cleaning of the UNESCO_UNICEF_WB, round 2 data
****** Created by: Akito Kamei (akamei@unicef.org), 2020/08/07
****** Used by: Akito Kamei, Marco Valenza
****** Input  data : covid2_final_20200923_datafull.csv, worskheet "DataFull" in
*******              Survey on National Education Responses to COVID-19 School Closures_IndividualResponses_ToShare.xlsx
****** Output data : UNESCO_UNICEF_WB
****** Language: English
********************************************************************************

* In this do-file:
* Step 1 - Import data
* Step 2 - String to numerical (Yes, No, Select all that apply)
* Step 3 - Variable labeling
* Step 4 - Data cleaning
* Step 5 - Data handling when exporting to excel for others use
* Step 6 - Merge with WBG income and school-aged population by country

************************ Step 1 - Import data ***************************************

*------------------------------------------
* IMPORTING DATA INTO STATA FORMAT
*------------------------------------------
local URL_round2    "http://tcg.uis.unesco.org/wp-content/uploads/sites/4/2020/10/COVID_SchoolSurvey_R2_Data-and-Codebook.xlsx"
cap confirm file "${Data_raw}/COVID_SchoolSurvey_R2_Data-and-Codebook.xlsx"
if _rc copy "`URL_round2'" "${Data_raw}/COVID_SchoolSurvey_R2_Data-and-Codebook.xlsx", replace
import excel "${Data_raw}/COVID_SchoolSurvey_R2_Data-and-Codebook.xlsx", firstrow case(lower) sheet("Data") clear

************************ Step 2 - String to numerical (Yes, No, Select all that apply) ***************************************

***********************************************************************************************
* Cleaning of the raw data based on the "Data cleaning issues - Round 2 UNESCO-UNICEF-WB.doc" *
***********************************************************************************************

* Q13 Replacing to missing variable is none of the choice is selected in the all that apply question
replace q13onlineplatforms_effectiven="999" if q13onlineplatforms_effectiven=="" & q13television_effectiveness=="" & q13radio_effectiveness=="" & q13take_homepackages_effectiv=="" & q13anyotherdistancelearningm=="" & q13pleasespecifyanyotherdis==""
foreach i in q13television_effectiveness q13radio_effectiveness q13take_homepackages_effectiv q13anyotherdistancelearningm {
replace `i' ="999" if q13onlineplatforms_effectiven=="999"
}

* Q16
* If other choice is selected replace "no measure is taken/do not know" as 0.
replace q16nomeasurestaken="" if q16offernegotiateaccesstothe!="" | q16landline!="" | q16mobilephones!="" | q16subsidizedfreedevicesfora!=""
replace q16donotknow=""       if q16offernegotiateaccesstothe!="" | q16landline!="" | q16mobilephones!="" | q16subsidizedfreedevicesfora!=""
* Replace to 999 if none of the choice is selected.
replace q16offernegotiateaccesstothe="999" if q16offernegotiateaccesstothe=="" & q16landline=="" & q16mobilephones=="" & q16subsidizedfreedevicesfora=="" & q16nomeasurestaken=="" & q16donotknow==""
foreach i in q16landline q16mobilephones q16subsidizedfreedevicesfora q16nomeasurestaken q16donotknow {
replace `i' ="999" if q16offernegotiateaccesstothe=="999"
}
* Q17
*What type of online learning platforms are teachers/schools encouraged to use while schools are closed, by education level?
*If the platform is created by the Ministry of Education or education authorities, are all subjects and developmental domains covered in the online learning platform?
foreach var of varlist q17_1platformcreatedbythemin q17_1commercialplatformnotfor q17_1commercialforfreeblackb q17_1opensourceplatformmoodl q17_1donotknow q17_1other {
replace `var' = "1" if `var' != ""
replace `var' = "0" if `var' == ""
replace `var' = "." if q17_1platformcreatedbythemin == "" & q17_1commercialplatformnotfor == "" & q17_1commercialforfreeblackb == "" & q17_1opensourceplatformmoodl == "" & q17_1donotknow == "" & q17_1other == ""
}
foreach var of varlist q17_1platformcreatedbythemin q17_1commercialplatformnotfor q17_1commercialforfreeblackb q17_1opensourceplatformmoodl q17_1other {
replace `var' = "." if q17_1donotknow == "1"
}
foreach var of varlist q17_2platformcreatedbythemin q17_2commercialplatformnotfor q17_2commercialforfreeblackb q17_2opensourceplatformmoodl q17_2donotknow q17_2other {
replace `var' = "1" if `var' != ""
replace `var' = "0" if `var' == ""
replace `var' = "." if q17_2platformcreatedbythemin == "" & q17_2commercialplatformnotfor == "" & q17_2commercialforfreeblackb == "" & q17_2opensourceplatformmoodl == "" & q17_2donotknow == "" & q17_2other == ""
replace `var' = "." if q17_2donotknow == "1"
}
foreach var of varlist q17_2platformcreatedbythemin q17_2commercialplatformnotfor q17_2commercialforfreeblackb q17_2opensourceplatformmoodl q17_2other {
replace `var' = "." if q17_2donotknow == "1"
}
foreach var of varlist q17_1platformcreatedbythemin q17_1commercialplatformnotfor q17_1commercialforfreeblackb q17_1opensourceplatformmoodl q17_1donotknow q17_1other ///
q17_2platformcreatedbythemin q17_2commercialplatformnotfor q17_2commercialforfreeblackb q17_2opensourceplatformmoodl q17_2donotknow q17_2other {
destring `var', replace
}
foreach var of varlist q17_1_1 q17_2_1 {
replace `var' = "1" if `var' == "Yes"
replace `var' = "0" if `var' == "No"
replace `var' = "." if `var' == "Do not know"
replace `var' = "." if `var' == ""
destring `var', replace
}
gen q17_1othersource = q17_1commercialplatformnotfor
replace q17_1othersource = 1 if q17_1commercialforfreeblackb == 1
gen q17_2othersource = q17_2commercialplatformnotfor
replace q17_2othersource = 1 if q17_2commercialforfreeblackb == 1

* Q20
* If other choice is selected replace "no measure is taken/do not know" as 0.
replace q20noadditionalsupportwasoff="" if q20offeredspecialtrainingif!="" | q20providedwithinstructionon!="" | q20providedwithprofessionalp!="" | q20providedwithteachingconten!="" | q20providedwithicttoolsandf!=""
replace q20donotknow=""                 if q20offeredspecialtrainingif!="" | q20providedwithinstructionon!="" | q20providedwithprofessionalp!="" | q20providedwithteachingconten!="" | q20providedwithicttoolsandf!=""
* Replace to 999 if none of the choice is selected.
replace q20offeredspecialtrainingif="999" if q20offeredspecialtrainingif=="" & q20providedwithinstructionon=="" & q20providedwithprofessionalp=="" & q20providedwithteachingconten=="" & q20providedwithicttoolsandf=="" & q20noadditionalsupportwasoff=="" & q20donotknow==""
foreach i in q20providedwithinstructionon q20providedwithprofessionalp q20providedwithteachingconten q20providedwithicttoolsandf q20noadditionalsupportwasoff q20donotknow {
replace `i' ="999" if q20offeredspecialtrainingif=="999"
}

* Q21
* If other choice is selected replace "no measure is taken/do not know" as 0.
replace q21therewerenospecificguidel="" if q21phonecallstostudentsorpa!="" | q21emailstostudents!="" | q21textwhatsappotherapplicati!="" | q21homevisits!=""
replace q21donotknow=""                 if q21phonecallstostudentsorpa!="" | q21emailstostudents!="" | q21textwhatsappotherapplicati!="" | q21homevisits!=""
* Replace to 999 if none of the choice is selected.
replace q21phonecallstostudentsorpa="999" if q21emailstostudents=="" & q21textwhatsappotherapplicati=="" & q21homevisits=="" & q21therewerenospecificguidel=="" & q21donotknow==""
foreach i in q21emailstostudents q21textwhatsappotherapplicati q21homevisits q21therewerenospecificguidel q21donotknow {
replace `i' ="999" if q21phonecallstostudentsorpa=="999"
}

* Q25
* If other choice is selected replace "no measure is taken/do not know" as 0.
replace q25none=""      if q25supporttolearnerswithdisa!="" | q25improvedaccesstoinfrastruc!="" | q25designoflearningmaterials!="" | q25subsidizeddevicesforaccess!="" | q25flexibleandself_pacedplatf!="" | q25specialeffortstomakeonlin!="" | q25additionalsupporttolower_i!=""
replace q25donotknow="" if q25supporttolearnerswithdisa!="" | q25improvedaccesstoinfrastruc!="" | q25designoflearningmaterials!="" | q25subsidizeddevicesforaccess!="" | q25flexibleandself_pacedplatf!="" | q25specialeffortstomakeonlin!="" | q25additionalsupporttolower_i!=""
* Replace to 999 if none of the choice is selected.
replace q25supporttolearnerswithdisa="999" if q25supporttolearnerswithdisa=="" & q25improvedaccesstoinfrastruc=="" & q25designoflearningmaterials=="" & q25subsidizeddevicesforaccess=="" & q25flexibleandself_pacedplatf=="" & q25specialeffortstomakeonlin=="" & q25specialeffortstomakeonlin=="" & q25additionalsupporttolower_i=="" & q25none=="" & q25donotknow==""
foreach i in q25supporttolearnerswithdisa q25improvedaccesstoinfrastruc q25designoflearningmaterials q25subsidizeddevicesforaccess q25flexibleandself_pacedplatf q25specialeffortstomakeonlin q25additionalsupporttolower_i q25none q25donotknow {
replace `i' ="999" if q25supporttolearnerswithdisa=="999"
}

* Q27
* If other choice is selected replace "no measure is taken/do not know" as 0.
replace q27nomeasures="" if q27childcareservicesremaining!="" | q27emergencychildcareservices!="" | q27financialsupporttofamilies!="" | q27augmentedoradvancedcashtr!="" | q27guidancematerialsforhome_b!="" | q27guidancematerialsforpre_pr!="" | q27tipsandmaterialsforcontin!="" | q27mealsfoodrationstofamilie!="" | q27psychosocialcounsellingserv!="" | q27psychosocialsupportforcare!=""  | q27regulartelephonefollow_upb!=""
replace q27donotknow=""  if q27childcareservicesremaining!="" | q27emergencychildcareservices!="" | q27financialsupporttofamilies!="" | q27augmentedoradvancedcashtr!="" | q27guidancematerialsforhome_b!="" | q27guidancematerialsforpre_pr!="" | q27tipsandmaterialsforcontin!="" | q27mealsfoodrationstofamilie!="" | q27psychosocialcounsellingserv!="" | q27psychosocialsupportforcare!=""  | q27regulartelephonefollow_upb!=""
* Replace to 999 if none of the choice is selected.
replace q27childcareservicesremaining="999" if q27emergencychildcareservices=="" & q27financialsupporttofamilies=="" & q27augmentedoradvancedcashtr=="" & q27guidancematerialsforhome_b=="" & q27guidancematerialsforpre_pr=="" & q27tipsandmaterialsforcontin=="" & q27mealsfoodrationstofamilie=="" & q27psychosocialcounsellingserv=="" & q27psychosocialsupportforcare=="" & q27regulartelephonefollow_upb=="" & q27nomeasures=="" & q27donotknow==""
foreach i in q27emergencychildcareservices q27financialsupporttofamilies q27augmentedoradvancedcashtr q27guidancematerialsforhome_b q27guidancematerialsforpre_pr q27tipsandmaterialsforcontin q27mealsfoodrationstofamilie q27psychosocialcounsellingserv q27psychosocialsupportforcare q27regulartelephonefollow_upb q27nomeasures q27donotknow {
replace `i' ="999" if q27childcareservicesremaining=="999"
}

* Q28
* If other choice is selected replace "no measure is taken/do not know" as 0.
replace q28progressisnotbeingtracked="" if q28learningmanagementbythesc!="" | q28learningmanagementbythepr!="" | q28trackingstudentonexcelor!="" | q28trackingstudentonpaper!=""
replace q28donotknow=""                 if q28learningmanagementbythesc!="" | q28learningmanagementbythepr!="" | q28trackingstudentonexcelor!="" | q28trackingstudentonpaper!=""
* Replace to 999 if none of the choice is selected.
replace q28learningmanagementbythesc="999" if q28learningmanagementbythesc=="" & q28learningmanagementbythepr=="" & q28trackingstudentonexcelor=="" & q28trackingstudentonpaper=="" & q28donotknow=="" & q28progressisnotbeingtracked==""
foreach i in q28learningmanagementbythepr q28trackingstudentonexcelor q28trackingstudentonpaper q28donotknow q28progressisnotbeingtracked {
replace `i' ="999" if q28learningmanagementbythesc=="999"
}

local q16 q16offernegotiateaccesstothe q16landline q16mobilephones q16subsidizedfreedevicesfora q16nomeasurestaken q16donotknow
local q20 q20offeredspecialtrainingif q20providedwithinstructionon q20providedwithprofessionalp q20providedwithteachingconten q20providedwithicttoolsandf q20noadditionalsupportwasoff
local q21 q21phonecallstostudentsorpa q21emailstostudents q21textwhatsappotherapplicati q21homevisits q21therewerenospecificguidel
local q25 q25supporttolearnerswithdisa q25improvedaccesstoinfrastruc q25designoflearningmaterials q25subsidizeddevicesforaccess q25flexibleandself_pacedplatf q25specialeffortstomakeonlin q25additionalsupporttolower_i q25none
local q27 q27childcareservicesremaining q27emergencychildcareservices q27financialsupporttofamilies q27augmentedoradvancedcashtr q27guidancematerialsforhome_b q27guidancematerialsforpre_pr q27tipsandmaterialsforcontin q27mealsfoodrationstofamilie q27psychosocialcounsellingserv q27psychosocialsupportforcare q27regulartelephonefollow_upb q27nomeasures q27donotknow
local q28 q28learningmanagementbythesc q28learningmanagementbythepr q28trackingstudentonexcelor q28trackingstudentonpaper q28donotknow q28progressisnotbeingtracked
local q31_local q31_1externaldonors q31_1additionalallocationfrom q31_1reallocationoftheministr q31_1donotknow

foreach i in q16 q20 q21 q25 q27 q28 q31_local {
foreach x of local `i' {
replace `x'="1" if `x'!="" & `x'!="999"
replace `x'="0" if `x'==""
destring `x', replace
gen `x'_p=`x'*100
}
}

foreach x in q31 {
replace `x'="1" if `x'=="Yes (If so, please answer Question 31.1)"
replace `x'="0" if `x'=="No"
replace `x'="998" if `x'=="Do not know"
replace `x'="999" if `x'==""
destring `x', replace
}

// Added by Pragya and Marianne from the analysis on the financing section on 5th October
// recoding q31 to "Yes" if there are category-specific responses
replace q31 = 1 if q31 ~= 1 & (q31_1externaldonors==1 | q31_1additionalallocationfrom==1 | q31_1reallocationoftheministr==1)


// recoding responses for Q32
local Q32	q32currentyearpayingtheexami q32currentyearconditionalcash q32currentyearscholarships ///
			q32nextyearpayingtheschoolf q32nextyearpayingtheexaminat q32nextyearconditionalcashtr ///
			q32nextyearscholarships q32currentyearpayingtheschoo

tab1 `Q32', miss

foreach x of local Q32 {
replace `x'="1" if `x'=="Yes"
replace `x'="0" if `x'=="No"
replace `x'="999" if `x'==""
replace `x'="998" if `x'=="Do not know"
destring `x', replace
}


// recoding responses for Q33
local Q33	q33curyrwagereductionsoutsid q33curyrwagereductionsinclud q33currentyearcutsinschoolf ///
			q33nextyrwagereductionsouts q33nextyrwagereductionsincl ///
			q33nextyear_cutsinschoolf

tab1 `Q33', miss

foreach x of local Q33 {
replace `x'="1" if `x'=="Yes"
replace `x'="0" if `x'=="No"
replace `x'="999" if `x'==""
replace `x'="998" if `x'=="Do not know"
destring `x', replace
}

* Q1 What are the current plans for reopening schools in your education system? [Select all that apply]

forvalue i=1/4 {
gen q1_`i'_miss=0
replace q1_`i'_miss=1 if q1_`i'nation_widewithinthecurr=="" & q1_`i'nation_widenextacademicy=="" & q1_`i'partialsub_nationalwithin=="" ///
				       & q1_`i'partialsub_nationalnexta=="" & q1_`i'phasingstudentswithinthe=="" & q1_`i'phasingstudentsnextacade=="" ///
				       & q1_`i'donotknow=="" & q1_`i'schoolsarenotclosed==""

}

* This dummy takes the value 1 for countries that did not select any answers for each subset of Q1
local Q1_1	q1_1nation_widewithinthecurr q1_1nation_widenextacademicy q1_1partialsub_nationalwithin     ///
			q1_1partialsub_nationalnexta q1_1phasingstudentswithinthe q1_1phasingstudentsnextacade      ///
			q1_1donotknow q1_1schoolsarenotclosed

tab1 `Q1_1', miss
foreach x of local Q1_1 {
replace `x'="1" if `x'!=""
replace `x'="0" if `x'==""
replace `x'="999" if q1_1_miss==1
destring `x', replace
}

local Q1_2	q1_2nation_widewithinthecurr q1_2nation_widenextacademicy q1_2partialsub_nationalwithin     ///
			q1_2partialsub_nationalnexta q1_2phasingstudentswithinthe q1_2phasingstudentsnextacade      ///
			q1_2donotknow q1_2schoolsarenotclosed

tab1 `Q1_2', miss
foreach x of local Q1_2 {
replace `x'="1" if `x'!=""
replace `x'="0" if `x'==""
replace `x'="999" if q1_2_miss==1
destring `x', replace
}

local Q1_3	q1_3nation_widewithinthecurr q1_3nation_widenextacademicy q1_3partialsub_nationalwithin     ///
			q1_3partialsub_nationalnexta q1_3phasingstudentswithinthe q1_3phasingstudentsnextacade      ///
			q1_3donotknow q1_3schoolsarenotclosed

tab1 `Q1_3', miss
foreach x of local Q1_3 {
replace `x'="1" if `x'!=""
replace `x'="0" if `x'==""
replace `x'="999" if q1_3_miss==1
destring `x', replace
}

local Q1_4	q1_4nation_widewithinthecurr q1_4nation_widenextacademicy q1_4partialsub_nationalwithin     ///
			q1_4partialsub_nationalnexta q1_4phasingstudentswithinthe q1_4phasingstudentsnextacade      ///
			q1_4donotknow q1_4schoolsarenotclosed

tab1 `Q1_4', miss
foreach x of local Q1_4 {
replace `x'="1" if `x'!=""
replace `x'="0" if `x'==""
replace `x'="999" if q1_4_miss==1
destring `x', replace
}


* Q1 - Handle inconsistencies re. schools not closed

list coun if q1_1schoolsarenotclosed==1 | q1_2schoolsarenotclosed==1 | ///
	         q1_3schoolsarenotclosed==1 |q1_4schoolsarenotclosed==1

* As per protocols, recode all countries to 0 but Tonga and Niue
		foreach x in q1_1schoolsarenotclosed q1_2schoolsarenotclosed q1_3schoolsarenotclosed q1_4schoolsarenotclosed {
		replace `x'=0 if coun!="Tonga" & coun!="Niue"
		}

* Q1 - other inconsistencies
	forvalue i=1/4 {
	list q1_`i'nation_widewithinthecurr q1_`i'nation_widenextacademicy q1_`i'partialsub_nationalwithin q1_`i'partialsub_nationalnexta q1_`i'phasingstudentswithinthe q1_`i'phasingstudentsnextacade q1_`i'schoolsarenotclosed coun if q1_`i'donotknow==1
	list coun q1_`i'nation_widewithinthecurr q1_`i'partialsub_nationalwithin if q1_`i'nation_widewithinthecurr==1 & q1_`i'partialsub_nationalwithin==q1_`i'nation_widewithinthecurr
	}

	* Lebanon: selected "D/K" and "Nationwide, next academic year" for pre-primary and primary --> recode D/K as 0
		replace q1_1donotknow=0 if coun=="Lebanon"
		replace q1_2donotknow=0 if coun=="Lebanon"

	* Lebanon: selected "D/K" and "Nationwide, within the current year" for upper secondary
		replace q1_4donotknow=0 if coun=="Lebanon"

	* Uruguay: selected "D/K" and 3 other possible answers
		replace q1_3donotknow=0 if coun=="Uruguay"

* Q3 3. Do plans for reopening include the widespread use of any of the following measures [Select all that apply]:
** Each variable contains different text for yes, and blank for no, so set 0 for blank and 1 for else
lab def yn 0 "No" 1 "Yes"
foreach var of varlist q3prioritizationofspecificgra q3prioritizationofspecialinte q3prioritizationofcertaingeog ///
q3studentrotationiestudent q3imposingshiftsinschoolsso q3adjustmentstoschoolandorc q3adjustmentstoschoolfeeding ///
q3expansionofschoolfeedingpr q3noschoolmealsreopeninglim q3additionofmoreteacherstor q3combiningdistancelearningan ///
q3donotknow q3other {
replace `var' = "0" if `var' != ""
replace `var' = "1" if `var' != ""
destring `var', replace
lab val `var' yn
}
** "None" option not provided so not possible to distinguish no measure vs missing (category NOT mutually exclusive)
** Create none variable for all blanks, treat as no missing
gen q3_none = (q3prioritizationofspecificgra == 0 & q3prioritizationofspecialinte == 0 & q3prioritizationofcertaingeog == 0 & ///
q3studentrotationiestudent == 0 & q3imposingshiftsinschoolsso == 0 & q3adjustmentstoschoolandorc == 0 & q3adjustmentstoschoolfeeding == 0 & ///
q3expansionofschoolfeedingpr == 0 & q3noschoolmealsreopeninglim == 0 & q3additionofmoreteacherstor == 0 & q3combiningdistancelearningan == 0 & ///
q3donotknow == 0 & q3other == 0)
** Fortunately, all countries used at least one measure

* Q4 After re-opening, how have teaching and learning been conducted? [Select all that apply]

gen q4_miss=0
replace q4_miss=1 if q4fullyin_personclassesifs=="" & q4acombinationofin_personatt=="" ///
				     & q4differentbyeducationlevela=="" & q4donotknow=="" & q4theacademicyearhasalready==""
tab q4_miss, miss

local Q4 q4fullyin_personclassesifs   q4acombinationofin_personatt ///
		 q4differentbyeducationlevela q4donotknow q4theacademicyearhasalready
foreach x of local Q4 {
replace `x'="1" if `x'!=""
replace `x'="0" if `x'==""
replace `x'="999" if q4_miss==1
destring `x', replace
}

tab1 `Q4', miss
list coun `Q4' if q4donotknow==1 // no inconsistencies

* Q11 What kinds of additional support programmes have been or will be provided? [Select all that apply]

gen q11_miss=0
replace q11_miss=1 if q11increaseclasstimeinprimar=="" & q11increaseclasstimeinlower_=="" ///
					  & q11increaseclasstimeinupper_=="" & q11introduceremedialprogrammes=="" ///
					  & q11introduceacceleratedprogram=="" & q11none=="" & q11donotknow=="" & q11other==""
tab q11_miss, miss

local Q11	q11increaseclasstimeinprimar q11increaseclasstimeinlower_ q11increaseclasstimeinupper_ ///
			q11introduceremedialprogrammes q11introduceacceleratedprogram q11none q11donotknow	   ///
			q11other

tab1 `Q11', miss

foreach x of local Q11 {
replace `x'="1" if `x'!=""
replace `x'="0" if `x'==""
replace `x'="999" if q11_miss==1
destring `x', replace
}

* Q11: handle inconsistencies
	local Q11	q11increaseclasstimeinprimar q11increaseclasstimeinlower_ q11increaseclasstimeinupper_ ///
				q11introduceremedialprogrammes q11introduceacceleratedprogram q11none q11donotknow

	list coun `Q11' if q11none==1
	list coun `Q11' if q11donotknow==1

		* Iceland selected "None" and "Introduced remedial programmes":

			replace q11none=0 if coun=="Iceland"

		* Libya selected "Don't know" and several other options:

			replace q11donotknow=0 if coun=="Libya"

		* One N/D country (row 122) selected "Don't know" and "Introduced remedial programmes"

			replace q11donotknow=0 if coun=="nd" & q11introduceremedialprogrammes==1


* Q5 Has the government produced or endorsed any specific health and hygiene guidelines and measures for schools?

tab q5, miss
levelsof q5
replace q5="0" if q5=="No"
replace q5="1" if q5=="Yes"
replace q5="2" if strpos(q5,"responsibility")
replace q5="999" if q5==""
destring q5, replace

la define q5 0 "No" 1 "Yes" 2 "The responsibility of health and sanitation guidelines falls under other administrative units" 999 "DK", modify
la value q5 q5
tab q5, miss

* Q6 6. What do these guidelines cover?
foreach var of varlist q6* {
replace `var' = "1" if `var' != ""
replace `var' = "0" if `var' == ""
destring `var', replace
lab val `var' yn
}

*Clean q5 variable based on q6 responses
gen q6_anymeasure=0
replace q6_anymeasure=1 if q6promotingphysicaldistancing==1 | q6promotinghand_washingpractic==1 | q6promotinggoodrespiratoryhyg==1 | q6improvedhandwashingfacilitie==1 | q6increasedsurfacefoodprepar==1 | q6improvedmanagementofinfecti==1 | q6self_isolationofstaffandst==1 | q6temperaturechecksinschool==1 | q6testingforcovid_19inschool==1 | q6trackingstaffandstudentswh==1
list coun if q6_anymeasure==1 & q5!=1
replace q5=1 if q6_anymeasure==1

* Q8 Are there enough resources, commodities (e.g. soap, masks) and infrastructure (e.g. clean water, wash facilities) to assure the safety of learners and all school staff?

tab q8, miss
levelsof q8
replace q8="0" if q8=="No"
replace q8="1" if q8=="Yes (If so, answer Question 8.1. Otherwise skip to Question 9)"
replace q8="999" if q8==""
replace q8="998" if q8=="Do not know"
destring q8, replace

la define q8 0 "No" 1 "Yes" 998 "Don't know" 999 "Missing"
la value q8 q8
tab q8, miss


* Q12 How many days of instruction have been missed or projected to be missed (taking into account school breaks, etc.) for the academic year impacted by the COVID-19?

local Q12	q12_1pre_primaryeducation q12_1primaryeducation q12_1lower_secondaryeducation ///
			q12_1upper_secondaryeducation q12_2pre_primaryeducation q12_2primaryeducation ///
			q12_2lower_secondaryeducation q12_2upper_secondaryeducation

tab1 `Q12', miss

destring q12_1pre_primaryeducation-q12_2upper_secondaryeducation, replace

		egen missedppe=rowtotal(q12_1pre_primaryeducation q12_2pre_primaryeducation), missing
		egen missedprim=rowtotal(q12_1primaryeducation q12_2primaryeducation), missing
		egen missedlosec=rowtotal(q12_1lower_secondaryeducation q12_2lower_secondaryeducation), missing
		egen missedupsec=rowtotal(q12_1upper_secondaryeducation q12_2upper_secondaryeducation), missing

		egen totmisseddays=rowtotal(missedppe missedprim missedlosec missedupsec), missing
		egen avgmisseddays=rowmean(missedppe missedprim missedlosec missedupsec)

tab1 missed*, miss
tab1 avgmisseddays totmisseddays, miss

* Issues found:
* 1) High proportion (~27-30%) of missing values for all school levels.
* 2) The following countries reported no missed school days - to be checked:
* 3) The following countries reported more than 100 missed days - to be checked:
list coun missedppe missedprim missedlosec missedupsec if avgmisseddays==0
list coun missedppe missedprim missedlosec missedupsec avgmisseddays if avgmisseddays>100 & avgmisseddays!=.

* Q13 Based on your experience, how effective have distance-learning strategies (online, television, radio, take-home packages or other) been in maintaining or advancing the levels of learning?

local Q13 q13onlineplatforms_effectiven q13television_effectiveness q13radio_effectiveness ///
		  q13take_homepackages_effectiv q13anyotherdistancelearningm

tab1 `Q13', miss


la define q13 0 "Not Effective" 1 "Fairly Effective" 2 "Very Effective" 3 "We do not have such platform" 998 "Don't know" 999 "Missing value"

foreach x of local Q13 {
replace `x'="0" if `x'=="Not Effective"
replace `x'="1" if `x'=="Fairly Effective"
replace `x'="2" if `x'=="Very Effective"
replace `x'="3" if `x'=="We do not have such platform"
replace `x'="998" if `x'=="Do not know"
replace `x'="999" if `x'==""
destring `x', replace
la value `x' q13
}

local Q13 q13onlineplatforms_effectiven q13television_effectiveness q13radio_effectiveness ///
		  q13take_homepackages_effectiv q13anyotherdistancelearningm

tab1 `Q13', miss

* Q14. Will distance learning modalities such as though television, radio, online or take-home packages continue when schools re-open?
* Q15. Is remote learning considered a valid form of delivery to account for official school days?

foreach v of varlist q14 q15 {
replace `v'="0" if `v'=="No"
replace `v'="1" if `v'=="Yes"
replace `v'="999" if `v'==""
replace `v'="998" if `v'=="Do not know"
destring `v', replace

la define `v' 0 "No" 1 "Yes" 998 "Don't know" 999 "Missing"
la value `v' `v'

}


************************ Step 3 - Generating Variable and labeling ***************************************

* Diana has purposefully deleted this section because the original incomegroup var is not matching the latest WBG classification
* it seems that incomegroup and income_rev refer to the 2019 WBG classification (updated in July)
* In the dofile 03_combine_round1_round2, the correct metadata is brought in.
drop incomegroup

/*clonevar income_rev=incomegroup
replace income_rev="Middle income" if incomegroup=="Lower middle income" | incomegroup=="Upper middle income"
gen income_rev_num=.
	replace income_rev_num=1 if income_rev=="Low income"
	replace income_rev_num=2 if income_rev=="Middle income"
	replace income_rev_num=3 if income_rev=="High income"
label define income_rev_numl 1 "Low income" 2 "Middle income" 3 "High income", modify
	label value income_rev_num income_rev_numl
*/

************************ Step 4 - Data cleaning ***************************************
* The policy of data cleaning is based on "UNESCO_UNICEF_WB_Data_Cleaning_Process.docx"

*----------------------------------------------
* CHECKING FOR INCONSISTENCIES, sections 1 to 4
*----------------------------------------------

* Q1 What are the current plans for reopening schools in your education system? [Select all that apply]

forvalue i=1/4 {
list q1_`i'nation_widewithinthecurr q1_`i'nation_widenextacademicy q1_`i'partialsub_nationalwithin q1_`i'partialsub_nationalnexta q1_`i'phasingstudentswithinthe q1_`i'phasingstudentsnextacade q1_`i'schoolsarenotclosed coun if q1_`i'donotknow==1
list coun q1_`i'nation_widewithinthecurr q1_`i'partialsub_nationalwithin if q1_`i'nation_widewithinthecurr==1 & q1_`i'partialsub_nationalwithin==q1_`i'nation_widewithinthecurr
}


* Q4 After re-opening, how have teaching and learning been conducted? [Select all that apply]

local Q4 q4fullyin_personclassesifs   q4acombinationofin_personatt ///
		 q4differentbyeducationlevela q4donotknow q4theacademicyearhasalready

list coun `Q4' if q4donotknow==1 // no inconsistencies

* Q11 What kinds of additional support programmes have been or will be provided? [Select all that apply]

local Q11	q11increaseclasstimeinprimar q11increaseclasstimeinlower_ q11increaseclasstimeinupper_ ///
			q11introduceremedialprogrammes q11introduceacceleratedprogram q11none q11donotknow

list coun `Q11' if q11none==1
list coun `Q11' if q11donotknow==1


************************ Step 5 - Data handling when exporting to excel for others use ***************************************
*Step 5.1 - Recoding missing values ***************************************
* Replace Do not know (998) and missing data (999) TO MISSING
ds, has(type numeric)
foreach x in `r(varlist)' {
replace `x'=.d  if `x'==998
replace `x'=.m  if `x'==999 | `x'==.
}

/*
* Work in progress: Currently missing is coded as 999 and Don't know is 998
decode q5, gen(q5_temp)
drop q5
rename q5_temp q5

ds, has(type numeric)
foreach x in `r(varlist)' {
tostring `x', replace
replace  `x'="Dont't know" if `x'==".d"
replace  `x'="Missing"     if `x'==".m"
}
*/

ds, has(type numeric)
foreach x in `r(varlist)' {
replace `x'=998  if `x'==.d
replace `x'=999  if `x'==.m
}

*************** Step 6 - Merge with income and school-aged population by country ************
gen countrycode = iso3
merge 1:1 countrycode using "${Data_clean}/wbg_country_metadata.dta", keepusing(incomelevel incomelevelname) keep(master match) nogen
gen income_num = (incomelevel == "LIC")
replace income_num = 2 if incomelevel == "LMC"
replace income_num = 3 if incomelevel == "UMC"
replace income_num = 4 if incomelevel == "HIC"
lab def income 1 "Low income" 2 "Lower middle income" 3 "Upper middle income" 4 "High income"
lab val income_num income
*NOTE: countries not in WB list of economies imputted manuallly, see 'download_wbg_api_data' do-file
merge 1:1 countrycode using "${Data_clean}/population.dta", keep(master match) nogen
merge 1:1 countrycode using "${Data_clean}/enrollment.dta", keep(master match) nogen

*************** Step 7 - Added in the process of figure creation 2020/10/15 ************
* Data cleaning reflect back to the cleaning file
replace q31=1 if q31_1reallocationoftheministr==1 | q31_1externaldonors==1


*************** Step 8 - Cleaning conducted by UNESCO 2020/10/15 ************
br q16* if coun=="Angola" | coun=="Liberia"
replace q16other="" if coun=="Angola" // Angola – delete text in “other” / count as “Not applicable”
replace q16other="" if coun=="Liberia" // Liberia – delete text in “other” / count as “Not applicable”

br coun q25* if coun=="Tuvalu" | coun=="Uzbekistan" | coun=="Brazil"
replace q25donotknow=""   if coun=="Tuvalu" // Tuvalu – delete their answer “Do not know” (count as “None” as they already chose “None”)
replace q25other=""       if coun=="Uzbekistan" // Uzbekistan – delete their answers in “other” – count as “Not applicable”
replace q25other=""       if coun=="Brazil" // Brazil – delete their answers in “other” – count as “Not applicable”
foreach i in q25supporttolearnerswithdisa q25improvedaccesstoinfrastruc q25designoflearningmaterials q25subsidizeddevicesforaccess q25flexibleandself_pacedplatf q25specialeffortstomakeonlin q25additionalsupporttolower_i q25none {
replace `i'=999 if coun=="Brazil"
}
foreach i in q25donotknow q25other {
replace `i'="" if coun=="Brazil"
}
foreach i in q25supporttolearnerswithdisa_p q25improvedaccesstoinfrastruc_p q25designoflearningmaterials_p q25subsidizeddevicesforaccess_p q25flexibleandself_pacedplatf_p q25specialeffortstomakeonlin_p q25additionalsupporttolower_i_p q25none_p {
replace `i'=99900 if coun=="Brazil"
}

br coun q20* if coun=="Iceland" | coun=="Kenya"
* Iceland and Kenya - delete their answer “Do not know” (as they already chose other options)
* This tylpe of issue is systematically handled for all the countries not only for Iceland (Cleaning for Q20 above)

save "${Data_clean}/JointSurvey2_cleaned.dta", replace
export excel using "${Data_clean}/JointSurvey2_cleaned.xlsx", firstrow(variables) replace

describe _all, replace clear
export excel using "${Data_clean}/JointSurvey2_cleaned.xlsx", first(var) sheet("Label") sheetmodify
