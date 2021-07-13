*=========================================================================*
* Project information at: https://github.com/worldbank/schoolsurvey-production
****** Country: Worldwide
****** Purpose: Cleaning of the UNESCO-UNICEF-WBG_OECD Survey on National education responses to COVID-19 - Round 3
****** Created by: UNESCO, UNICEF, WORLD BANK
****** Used by: UNESCO, UNICEF, WORLD BANK
****** Input  data : jsw3_uis.dta           
****** Output data : jsw3_uis_clean.dta, jsw3_uis_clean.csv
****** Language: English
*=========================================================================*
** In this do file: 
* This do file reads the converted UIS.dta for round 3 survey data and exports a cleaned .csv and .dta. 
* The script divides question sections by the report’s chapters and includes variables that were not in the final report. 
* For information about cleaning conventions, review our data editing guidelines online. 
* This step runs parallel to 021_2_clean_oecd.do

** Steps in this do file:
* 0) Import the raw .dta for UIS
* 1) Clean the raw .dta following the structure of the questionnaire, where each section will have the following Steps (C – F):
* 2) Export Data

** Questionnaire Sections:
* 1. School Closures
* 2. School Calendar and Curricula
* 3. School Reopening Management
* 4. Distance Education Delivery Systems (including additional questions in S10)
* 5. Teachers and Educational Personnel
* 6. Learning Assessments and Examinations
* 7. Financing
* 8. Locus of Decision Making
* 9. Equity Module
* 11. Health Protocol/Guidelines for Prevention and Control of COVID-19
* 12. Planning 2021

* Steps Within each section:
* Step A - Variable renaming/dropping (OECD cleaning mostly)
* Step B - Structural conversions between OECD and UIS format (OECD cleaning mostly)
*   Step B.1. "Select all that apply(SA)" v.s  "Select single(SS)"
*   Step B.2. Disaggregations
* Step C - String to numerical (Yes, No, Select all that apply) - cite text of the question.
* Step D - Variable labeling 
* Step E - Data cleaning 
* Step F - Open section to clean specific interested questions 

*=========================================================================*

*---------------------------------------------------------------------------
* 0) Import Data (Do Not Edit these lines)
*---------------------------------------------------------------------------

use "${Data_raw}jsw3_uis.dta", clear


* decomment the following line if you want to revert the data to JUNE 7
drop if ISO3 =="OMN"

* decomment the following line if you want to revert the data to May 27
* drop if ISO3 =="MLI" | ISO3 =="OMN"


*---------------------------------------------------------------------------
* 1) Clean the raw .dta
*---------------------------------------------------------------------------

* ALL QUESTIONNAIRE SECTIONS
*---------------------------------------------------------------------------
* Section 1. School Closures
*---------------------------------------------------------------------------
*QUESTIONS IN THIS SECTION:

*S1/aq1/Q1. What was the status of school opening in the education system as of February 1st, 2021? [Select all that apply]
*S1/aq3/Q3  If there were no differences between sub-national regions, over how many time periods were schools fully closed  (excluding schoolholidays) from January to December 2020 (i.e. government-mandated or/and recommended closures of educational institutions affectingall of the student population)?  
*S1/aq4/Q4 If there were differences between subnational regions, please indicate the minimum and maximum number of time periods schools in a region were fully closed (exclusing holidays) from Jannuary to December 2020
*S1/aq5/Q5. Starting and ending dates [DD/MM/YYYY] of nation-wide school closures in 2020 (from January to December), by ISCED levels. 
*S1/aq6/Q6. Total number of instruction days between January - December 2020 (excluding school holidays, public holidays and weekends) where schools were fully closed, by ISCED levels 

******* Step C  - String to numerical (Yes, No, Select all that apply) *******

*S1/aq1/Q1. 
foreach i in pp p ls us {
		foreach j in closed1 closed2 closed3 fullyopen open1 open2 open3 open4 open5 open6 open7 other {
			* Step C: String to numerical
			replace aq1_`i'_`j' = "1" if aq1_`i'_`j' != ""
			replace aq1_`i'_`j' = "0" if aq1_`i'_`j' == ""
			destring aq1_`i'_`j', replace
			* Step D: Variable Labeling
				label var aq1_`i'_`j' "`i': `j'"				
		}
	}
	
*S1/aq3/Q3  
foreach i in pp p ls us {
		replace aq3_`i'_periods = "999" if aq3_`i'_periods == ""
		replace aq3_`i'_periods = "997" if aq3_`i'_periods == "Do not know"
		replace aq3_`i'_periods = "4" if aq3_`i'_periods == "More than 3"
		destring aq3_`i'_periods, replace
		label var aq3_`i'_periods "`j' time periods fully closed"
	}

	
*S1/aq4/Q4

foreach i in pp p ls us {
	foreach j in min max typical {
		replace aq4_`i'_`j' = "999" if aq4_`i'_`j' == ""
		replace aq4_`i'_`j' = "997" if aq4_`i'_`j' == "Do not know"
		replace aq4_`i'_`j' = "4" if aq4_`i'_`j' == "More than 3"
		destring aq4_`i'_`j', replace
		label var aq4_`i'_`j' "`j' time periods fully closed"
	}
}


*S1/aq5/Q5. 
* Dropped this selection 
*foreach i in pp p ls us {
*	foreach j in firststart secondstart thirdstart firstend secondend thirdend {
*	}
*}

*S1/aq6/Q6. 
		replace aq6_pp_total = "999" if aq6_pp_total == "En esta pregunta no hay opción de repuesta para Nicaragua "
		replace aq6_pp_min = "999" if aq6_pp_min == "En grado Preescolar de los círculos infantiles y de las escuelas primarias (53) "
		replace aq6_ls_total = "999" if aq6_ls_total == "In the period from 17 March 2020 until the end of the school year  59 teaching days.  For second-cycle students in the period from 30th Nov. until 18th Dec. 2020 15 teaching days"

foreach i in pp p ls us {
		foreach j in total min max typical  {
    	replace aq6_`i'_`j' = strrtrim(aq6_`i'_`j')
			replace aq6_`i'_`j' = subinstr(aq6_`i'_`j', "*", "", .)
			replace aq6_`i'_`j' = subinstr(aq6_`i'_`j', "days", "", .)
			replace aq6_`i'_`j' = subinstr(aq6_`i'_`j', "dias", "", .)
			replace aq6_`i'_`j' = subinstr(aq6_`i'_`j', "ي", "", .)
			replace aq6_`i'_`j' = subinstr(aq6_`i'_`j', " وم", "", .)
			replace aq6_`i'_`j' = "999" if aq6_`i'_`j' == ""
			replace aq6_`i'_`j' = "999" if aq6_`i'_`j' == "NA"
			replace aq6_`i'_`j' = "999" if aq6_`i'_`j' == "x"
			replace aq6_`i'_`j' = "59" if aq6_`i'_`j' == "In the period from 17 March 2020 until the endo of the school year  59 teaching days"
			replace aq6_`i'_`j' = "59" if aq6_`i'_`j' == "In the period from 17 March 2020 until the endo of the school year  59 teaching "
			replace aq6_`i'_`j' = "74" if aq6_`i'_`j' == "In the period from 17 March 2020 until the end of the school year  59 teaching .  For second-cycle students in the period from 30th Nov. until 18th Dec. 2020 15 teaching "
			replace aq6_`i'_`j' = "53" if aq6_`i'_`j' == "En grado Preescolar de los círculos infantiles y de las escuelas primarias (53)"
			replace aq6_`i'_`j' = "53" if aq6_`i'_`j' == "En grado Preescolar de los círculos infantiles y de las escuelas primarias (53)"
      replace aq6_`i'_`j' = "98" if aq6_`i'_`j' == "98  (PP-Grade 3)"
      replace aq6_`i'_`j' = "113" if aq6_`i'_`j' == "113 (Grade 4,5,6 &8)"
      replace aq6_`i'_`j' = "108" if aq6_`i'_`j' == "108 (Grade 7&9)"
      replace aq6_`i'_`j' = "10" if aq6_`i'_`j' == "10 (Grade 10 -12)"
			replace aq6_`i'_`j' = "90" if aq6_`i'_`j' == "As above"
			replace aq6_`i'_`j' = "90" if aq6_`i'_`j' == "Aa above"
			replace aq6_`i'_`j' = "88" if aq6_`i'_`j' == "4 months"
			replace aq6_`i'_`j' = "11" if aq6_`i'_`j' == "5 months"			
			replace aq6_`i'_`j' = "110" if aq6_`i'_`j' == "252 hrs"

			** Step C string to numerical
			destring aq6_`i'_`j', replace
			** add labels
			label var aq6_`i'_`j' "`j' instruction days fully closed Jan to Dec 2020"
		}
}
	
******* Step D: Variable Labeling *******

*S1/aq1/Q1.
label define aq1_values 0 "No" 1 "Yes" 999 "Missing" 
label value aq1_us* aq1_ls* aq1_p* aq1_pp* aq1_values

*S1/aq3/q3
label define aq3_value 						///
	0 "0"			///
	1 "1 "						///
	2 "2"		///
	3 "3"			///
	4 "More than 3"		///
	999 "Missing" 			///
	997 "Do not know" 			
label value aq3_pp* aq3_p* aq3_ls* aq3_us* aq3_value

*S1/aq4/q4
label define aq4_value 						///
	0 "0"			///
	1 "1 "						///
	2 "2"		///
	3 "3"			///
	4 "More than 3"		///
	999 "Missing" 			///
	997 "Do not know" 			
label value aq4_pp* aq4_p* aq4_ls* aq4_us* aq4_value

  
******* Step E - Data cleaning *******
  
******* Step F - Open section to clean specific interested questions *******

* Question not used in the Survey
*S1/aq5/Q5 (DD/MM/YYYY)
foreach i in pp p ls us {
   foreach j in firststart firstend secondstart secondend thirdstart thirdend {
       * Remove special characters
        replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "*", "",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "?", "",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "r.", "",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', " r.", "",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', " r", "",.)
			
	* transate non-english dates
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "février", "02",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "de marzo", "03",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', " de ", "",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "marzo", "03",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "mars", "03",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "Mars", "03",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "de abril", "04",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "abril", "04",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "mai", "05",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "Juin", "06",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "juin", "06",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "juillet", "07",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "de septiembre", "09",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "septiembre", "09",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "Septembre", "09",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "novembre", "11",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "Décembre", "12",.)
			
	* For Arabic, the whole string needs to be called
	replace aq5_`i'_`j' = "09/03/2020" if aq5_`i'_`j' == "9 مارس 2020"
	replace aq5_`i'_`j' = "15/03/2020" if aq5_`i'_`j' == "15 آذار 2020"
	replace aq5_`i'_`j' = "21/05/2020" if aq5_`i'_`j' == "21 أيار 2020"
	replace aq5_`i'_`j' = "19/08/2020" if aq5_`i'_`j' == " 19 أغسطس 2020"
	replace aq5_`i'_`j' = "20/12/2020" if aq5_`i'_`j' == "20 كانون الاول 2020"
	
	* The same case for french sentences
	replace aq5_`i'_`j' = "31/07/2020" if aq5_`i'_`j' == "Jusqu’à la fin de l’année scolaire (31 juillet 2020)"
	replace aq5_`i'_`j' = "31/07/2020" if aq5_`i'_`j' == "Jusqu’à la fin de l’année scolaire (31 07 2020)"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "Seuls les élèves des classes d’examen (classes1ère et Terminale) ontepris en présentiel en 06 2020"
			

	* Remove sentences that are part of actual response dates
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "For second-cycle students ", "",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', " (Grade 4,5,6)","", .)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', " (Grade 1 -3)","", .)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', " for grades 5 and 6","", .)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', " (7-12)","", .)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "From","", .)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "No ha finalizado el cierre","", .)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', " only","", .)
	replace aq5_`i'_`j' = "01/09/2021" if aq5_`i'_`j' == "First on September"

	* Make NA sentences to missing
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "hasta el inicio de alternancia en cada establecimiento" | aq5_`i'_`j' == "hasta el inicioalternancia en cada establecimiento"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "schools not closed"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "Schools not closed"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "Nevere-opened"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "n/a"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "NA"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "N/A"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "X"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "x"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "ملاحظة"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "لا يوجد"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "still closed until this time for face-to-face classes"
        replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "Till now"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "No ha finalizado el cierre" | aq5_`i'_`j' == "No ha finalizado el cierre	"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "No sereabrieron" | aq5_`i'_`j' == "No seeabrieron"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "En esta pregunta no hay opción deespuesta para Nicaragua"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "Конец учебного года"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "Closed apart from small groups"

	* Change "as above" to the reference number
	replace aq5_`i'_`j' = "13 June 2020" if aq5_`i'_`j' == "As above"
				
	* Change "X Week of March" to first day of that week.
	replace aq5_`i'_`j' = "08/03/2020" if aq5_`i'_`j' == "Second week of March"
	replace aq5_`i'_`j' = "01/09/2020" if aq5_`i'_`j' == "1 and 7 September"
	replace aq5_`i'_`j' = "01/02/2020" if aq5_`i'_`j' == "The first week of February"
	replace aq5_`i'_`j' = "01/02/2020" if aq5_`i'_`j' == "First week of February"
	replace aq5_`i'_`j' = "04/01/2020" if aq5_`i'_`j' == "The second week of January"
	replace aq5_`i'_`j' = "11/01/2020" if aq5_`i'_`j' == "The third week of January"
	replace aq5_`i'_`j' = "22/05/2020" if aq5_`i'_`j' == "The fourth week of May"
	replace aq5_`i'_`j' = "25/06/2020" if aq5_`i'_`j' == "The forth week of June"
	replace aq5_`i'_`j' = "25/06/2020" if aq5_`i'_`j' == "Forth week of June"
			
	* Remove responses that only have months 
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "March 2020"	| aq5_`i'_`j' == "March 2020 "	
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "03 2020"			
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "May 2020"			
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "June 2020"	| aq5_`i'_`j' == "June"	| aq5_`i'_`j' == "June "
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "September 2020"			
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "November 2020"	
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "March" | aq5_`i'_`j' == "March "
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "August"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "September"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "September"
	replace aq5_`i'_`j' = "" if aq5_`i'_`j' == "October and November 2020"
			

	* Remove double space bars
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "  ", "",.)
			
	** Add years for dates with missing years
	replace aq5_`i'_`j' = "10/02/2020" if aq5_`i'_`j' == "February 10"
	replace aq5_`i'_`j' = "16/03/2020" if aq5_`i'_`j' == "16th March" | aq5_`i'_`j' == "16 March" 
	replace aq5_`i'_`j' = "16/03/2020" if aq5_`i'_`j' == "March 19"
	replace aq5_`i'_`j' = "23/03/2020" if aq5_`i'_`j' == "March 23"
	replace aq5_`i'_`j' = "25/03/2020" if aq5_`i'_`j' == "25 March " | aq5_`i'_`j' == "25 March"
	replace aq5_`i'_`j' = "11/05/2020" if aq5_`i'_`j' == "11th May"
	replace aq5_`i'_`j' = "18/05/2020" if aq5_`i'_`j' == "18th May"
	replace aq5_`i'_`j' = "04/06/2020" if aq5_`i'_`j' == "4 June"
	replace aq5_`i'_`j' = "29/06/2020" if aq5_`i'_`j' == "June 29"
	replace aq5_`i'_`j' = "07/07/2020" if aq5_`i'_`j' == "7 July"
	replace aq5_`i'_`j' = "06/08/2020" if aq5_`i'_`j' == "August 6"
	replace aq5_`i'_`j' = "05/10/2020" if aq5_`i'_`j' == "October 5"
	replace aq5_`i'_`j' = "26/10/2020" if aq5_`i'_`j' == "October 26"
			
	** Include only first date for date ranges
	replace aq5_`i'_`j' = "19/03/2020" if aq5_`i'_`j' == "19 March 2020 - 6 April 2020"
	replace aq5_`i'_`j' = "07/04/2020" if aq5_`i'_`j' == "7 April 2020 - 17 April 2020"
	replace aq5_`i'_`j' = "18/04/2020" if aq5_`i'_`j' == "18 April 2020 - 13 June 2020"
			
	** Switch Date orders 
	replace aq5_`i'_`j' = "05/01/2021" if aq5_`i'_`j'  == "January 05th, 2021 "
	replace aq5_`i'_`j' = "05/03/2020" if aq5_`i'_`j'  == "March 5, 2020"
	replace aq5_`i'_`j'  = "11/03/2020" if aq5_`i'_`j'  == "March 11, 2020"
	replace aq5_`i'_`j'  = "16/03/2020" if aq5_`i'_`j'  == "March 16, 2020"
	replace aq5_`i'_`j'  = "26/03/2020" if aq5_`i'_`j'  == "March 26,2020"
	replace aq5_`i'_`j'  = "25/04/2020" if aq5_`i'_`j' == "April 25th, 2020 "
	replace aq5_`i'_`j' = "30/04/2020" if aq5_`i'_`j' == "April 30th, 2020" | aq5_`i'_`j' == "April 30th, 2020 "
	replace aq5_`i'_`j' = "20/05/2020" if aq5_`i'_`j' == "May 20, 2020"
	replace aq5_`i'_`j' = "17/08/2020" if aq5_`i'_`j'  == "August 17"
	replace aq5_`i'_`j'  = "25/04/2020" if aq5_`i'_`j'  == "April 25th, 2020"
	replace aq5_`i'_`j'  = "30/04/2020" if aq5_`i'_`j'  == "April 30th, 2020"
	replace aq5_`i'_`j'  = "17/08/2020" if aq5_`i'_`j' == "August 17th, 2020" | aq5_`i'_`j' == "August 17th, 2020 " 
	replace aq5_`i'_`j'  = "21/08/2020" if aq5_`i'_`j'  == "August 21st, 2020" | aq5_`i'_`j' == "August 21st, 2020"
	replace aq5_`i'_`j'  = "19/12/2020" if aq5_`i'_`j'  == "December 19th, 2020" | aq5_`i'_`j'  == "December 19th, 2020 "
	replace aq5_`i'_`j' = "07/09/2020" if aq5_`i'_`j'  == "September 7, 2020"
	replace aq5_`i'_`j'  = "04/10/2020" if aq5_`i'_`j'  == "October 4, 2020"		
			
	* Make Written Months to Numbers
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "March", "03",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "march", "03",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "February", "02",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "May", "05",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "December", "12",.)

	*Other consistency fixes
	replace aq5_`i'_`j' = "06/04/2020" if aq5_`i'_`j' == "604 2021"
	replace aq5_`i'_`j' = "16/03/2020" if aq5_`i'_`j' == "1603 2021"
	replace aq5_`i'_`j' = "03/08/2020" if aq5_`i'_`j' == "3 August 202"
	replace aq5_`i'_`j'  = "14/09/2020" if aq5_`i'_`j'  == "14.09.2020 г" | aq5_`i'_`j' == "14.09.2020 г."
	replace aq5_`i'_`j'  = "18/03/2020" if aq5_`i'_`j' == "18.03.2020 г." | aq5_pp_firststart == "18.03.2020 г."
	replace aq5_`i'_`j' = "14/03/2020" if aq5_`i'_`j' == "14.03.2020 г."
	replace aq5_`i'_`j' = "14/03/2020" if aq5_`i'_`j'== "14.03.2020 г."
	replace aq5_`i'_`j' = "14/03/2020" if aq5_`i'_`j' == "14.03.2020 г."
	replace aq5_`i'_`j' = "15/06/2020" if aq5_`i'_`j'== "15.06.2020 г."
	replace aq5_`i'_`j' = "16/03/2020" if aq5_`i'_`j' == "16.03.2020 г."
	replace aq5_`i'_`j' = "12/03/2020" if aq5_`i'_`j' == "12March 2020"


 }
}
			
* Need to clean outside loop
replace aq5_pp_firstend = "" if aq5_pp_firstend == "لم ينتهي (تعليم عن بعد" | aq5_pp_firstend == "إغلاق إلى بداية العام الدراسي الحالي" | aq5_pp_firstend == "لم ينتهي( فقط تعليم عن بعد"
replace aq5_p_firstend = "" if aq5_p_firstend == "لم ينتهي (تعليم عن بعد"
replace aq5_p_secondstart = "" if aq5_p_secondstart == "بواسطةon line"
replace aq5_pp_secondend = "" if aq5_pp_secondend == "رغم اغلاق المدارس للفترة المشار "
replace aq5_us_firstend = "" if aq5_us_firstend == "لم ينتهي ( تعليم عن بعد)"
replace aq5_us_firstend = subinstr(aq5_us_firstend, "الشهادة الثانوية", "", .)
replace aq5_us_firstend = subinstr(aq5_us_firstend, "الأول والثاني ثانوي", "", .)
replace aq5_us_firstend = subinstr(aq5_us_firstend, " 13/09/2020", "", .)
replace aq5_us_firstend = "31/08/2020" if strpos(strlower(aq5_us_firstend),"31/08/2020")>0
replace aq5_ls_firstend = subinstr(aq5_ls_firstend, "لم ينتهي (تعليم عن بعد)", "",.)
replace aq5_p_firstend = "19/08/2020" if aq5_p_firstend == "19 أغسطس 2020"
replace aq5_us_firstend = "19/08/2020" if aq5_us_firstend == "19 أغسطس 2020"
replace aq5_ls_firstend = "19/08/2020" if aq5_ls_firstend == "19 أغسطس 2020"
replace aq5_pp_firststart = "16/03/2020" if aq5_pp_firststart == "16 March"
replace aq5_pp_firststart = "" if aq5_pp_firststart == "March"
replace aq5_pp_firstend= "" if aq5_pp_firstend == "No ha finalizado el cierre	"
replace aq5_p_firstend = "31/07/2020" if aq5_p_firstend == "Jusqu’à la finl’année scolaire (31 07 2020)"
replace aq5_ls_firstend = "" if aq5_ls_firstend == "Seuls les élèves des classes d’examen (classes3ème) ontepris en présentiel en 06 2020"			
replace aq5_pp_thirdend = "" if aq5_pp_thirdend == "اليها ولكن اجريت الامتحانات النهائية"			
		
* Remove Remaining Leading/Trailing Spaces
foreach i in pp p ls us {
  foreach j in firstend firststart secondend secondstart thirdend thirdstart {
	replace aq5_`i'_`j' = strrtrim(aq5_`i'_`j')
	replace aq5_`i'_`j' = strltrim(aq5_`i'_`j')
	*replace middle spaces to slashes
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', " ", "/",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', ".", "/",.)
	replace aq5_`i'_`j' = subinstr(aq5_`i'_`j', "//", "/",.)
						
	* turn to date format
	gen date_`i'_`j' = date(aq5_`i'_`j', "DMY")
	format date_`i'_`j' %tdDD/nn/YY
						
	* rename to original var
	drop aq5_`i'_`j'
	rename date_`i'_`j' aq5_`i'_`j'

  }
}
			
*---------------------------------------------------------------------------
* Section 2. School Calendar and Curricula
*---------------------------------------------------------------------------
*QUESTIONS IN THIS SECTION:

*S2/bq1/Q1. Have/will adjustments been/be made to the school calendar dates and curriculum due to COVID-19 in the school year 2019/2020 (2020 for countries with the calendar year)? [Select all that apply]
*S2/bq2/Q2. Is there a plan to revise regulation (at the national level) on the duration of instruction time and content of curriculum regulations after school year 2020/2021 (2021 for countries with calendar year) as a result of the COVID19 pandemic? 

******* Step C - String to numerical (Yes, No, Select all that apply) *******

*S2/bq1/Q1.
* Check conducted: None of the country that choose "No action" chose some action.
rename bq1_1_p_prioritizationofcertai bq1_1_p_prioritizationofcerta
rename bq1_2_p_prioritizationofcertai bq1_2_p_prioritizationofcerta

foreach i in pp p ls us {
	foreach j in academicyearextended prioritizationofcerta depends otheradj no other {
		replace bq1_1_`i'_`j' = "1" if bq1_1_`i'_`j' != ""
		replace bq1_1_`i'_`j' = "0" if bq1_1_`i'_`j' == ""
		destring bq1_1_`i'_`j', replace
	}
}

*S2/bq2/Q2. 
replace bq2_all_regulation = "999" if bq2_all_regulation == "" 
replace bq2_all_regulation = "997" if bq2_all_regulation == "Do not know"
replace bq2_all_regulation = "1" if bq2_all_regulation == "Yes" 
replace bq2_all_regulation = "0" if bq2_all_regulation == "No" 
destring bq2_all_regulation, replace
		
******* Step D: Variable Labeling *******

*S2/bq2/Q2.
label var bq2_all_regulation "Plan to revise regulation of time and curriculum after 2020/2021"
label define bq2_all_regulationl 0 "No" 1 "Yes" 999 "Missing" , modify
label value bq2_all_regulation bq2_all_regulationl
				
**bq2a_all_regulation has to do with specifying the answer  

******* Step E - Data cleaning *******

*S2/bq1/Q1.
* Cleaning Missing: Countries with zero for all are considered as missing
foreach i in pp p ls us {
		gen bq1_1_`i'miss = (bq1_1_`i'_academicyearextended + bq1_1_`i'_prioritizationofcerta + bq1_1_`i'_depends + bq1_1_`i'_otheradj + bq1_1_`i'_no + bq1_1_`i'_other == 0)
		foreach j in academicyearextended prioritizationofcerta depends otheradj no other {
		replace bq1_1_`i'_`j' = 999 if bq1_1_`i'miss == 1
	}
}

******* Step F - Open section to clean specific interested questions *******

* Questions not used in the Survey:

*S2/bq11a/Q1A
** String to Numerical
foreach i in p ls us {
  foreach j in subject1 subject2 subject3 subject4 subject5 {
	* remove trailing and leading spaces
	replace bq11a_`i'_`j' = strrtrim(bq11a_`i'_`j')
	replace bq11a_`i'_`j' = strltrim(bq11a_`i'_`j')
		
	replace bq11a_`i'_`j' = "997" if bq11a_`i'_`j' == "Do not know"
	replace bq11a_`i'_`j' = "1" if bq11a_`i'_`j' == "Reading, writing and literature"
	replace bq11a_`i'_`j' = "2" if bq11a_`i'_`j' == "Mathematics"
	replace bq11a_`i'_`j' = "3" if bq11a_`i'_`j' == "Information and communication technologies (ICT)"
	replace bq11a_`i'_`j' = "4" if bq11a_`i'_`j' == "Religion/ ethics/ moral education"
	replace bq11a_`i'_`j' = "5" if bq11a_`i'_`j' == "Second or other languages"
	replace bq11a_`i'_`j' = "6" if bq11a_`i'_`j' == "Social studies"
	replace bq11a_`i'_`j' = "7" if bq11a_`i'_`j' == "Natural sciences;"
	replace bq11a_`i'_`j' = "8" if bq11a_`i'_`j' == "Practical and vocational skills"
	replace bq11a_`i'_`j' = "9" if bq11a_`i'_`j' == "Physical education and health;"
	replace bq11a_`i'_`j' = "10" if bq11a_`i'_`j' == "Technology;"
	replace bq11a_`i'_`j' = "11" if bq11a_`i'_`j' == "Arts;"		
	replace bq11a_`i'_`j' = "12" if bq11a_`i'_`j' == "Others"		
		
	destring bq11a_`i'_`j', replace
   }
}
	
*S2/bq11a/Q1A
** Label variables
label define bq11a_value 		///
	1 "Reading, Writing, and Literature"					///
	2 "Mathematics"					///
	3 "Information and communication technologies (ICT)"		///
	4 "Religion, Ethics, or Moral Education"		///
	5 "Second or other languages"		///
	6 "Social Studies"	///
	7 "Natural Sciences"					///
	8 "Practical and Vocational Skills"					///
	9 "Physical education and health"					///
	10 "Technology" ///
	11 "Arts" ///
	12 "Others" ///
	997 "Do not know"	

label value bq11a_p_subject1 bq11a_p_subject2 bq11a_p_subject3 bq11a_p_subject4 bq11a_p_subject5 bq11a_ls_subject1 bq11a_ls_subject2 bq11a_ls_subject3 bq11a_ls_subject4 bq11a_ls_subject5 bq11a_us_subject1 bq11a_us_subject2 bq11a_us_subject3 bq11a_us_subject4 bq11a_us_subject5 bq11a_value


*---------------------------------------------------------------------------
* Section 3. School Reopening Management
*---------------------------------------------------------------------------
*QUESTIONS IN THIS SECTION: 
*S3/cq1/Q1. What measures to address learning gaps were widely implemented when schools reopened after the first/second/third closure in 2020?
*S3/cq2/Q2. If introducing remedial measures (for example remedial, accelerated programmes or increased in-person class time) in addition to the normal in-person class time or to address learning gaps, after schools reopened in 2020, when were those typically scheduled?
*S3/cq3/Q3. What is the approximate share of students who attended school in-person after the reopening of schools in 2020?
*S3/cq4/Q4. What strategies for school re-opening (after the first closure) were implemented in your country in 2020?

******* Step C - String to numerical (Yes, No, Select all that apply) *******

*S3/cq1/CQ1. 
foreach i in pp p ls us {
	foreach j in assessment remedial1 remedial2 remedial3 remedial4 remedial5 remedial6 remedial7 remedial8 other none donotknow {
		replace cq1_`i'_`j' = "0" if cq1_`i'_`j' == ""
		replace cq1_`i'_`j' = "1" if cq1_`i'_`j' == "Assessment of gaps in student learning that may have accumulated during school closures"
		replace cq1_`i'_`j' = "1" if cq1_`i'_`j' == "Remedial measures to reduce student learning gaps (for all students who need it)"
		replace cq1_`i'_`j' = "1" if cq1_`i'_`j' == "Remedial measures with a special focus on disadvantaged students"
		replace cq1_`i'_`j' = "1" if cq1_`i'_`j' == "Remedial measures with a special focus on students who were unable to access distance learning"
		replace cq1_`i'_`j' = "1" if cq1_`i'_`j' == "Remedial measures with a special focus on students at risk of drop-out or grade repetition"
		replace cq1_`i'_`j' = "1" if cq1_`i'_`j' == "Remedial measures with a special focus on immigrant and refugee students, ethnic minorities or indigenous students"
		replace cq1_`i'_`j' = "1" if cq1_`i'_`j' == "Remedial measures with a special focus on students in programmes with a vocational orientation "
		replace cq1_`i'_`j' = "1" if cq1_`i'_`j' == "Remedial measures with a special focus on students in upper secondary grades with a national examination at the end of 2019/20 or 2020 calendar year) "
		replace cq1_`i'_`j' = "1" if cq1_`i'_`j' == "Remedial measures with a special focus on all students transitioning from one ISCED level to the next"
		replace cq1_`i'_`j' = "1" if cq1_`i'_`j' == "Other"
		replace cq1_`i'_`j' = "1" if cq1_`i'_`j' == "None/Not Applicable"
		replace cq1_`i'_`j' = "1" if cq1_`i'_`j' == "Do not know"
		destring cq1_`i'_`j', replace
	}
}

*S3/cq2/CQ2
rename  cq2_p_duringscheduledschoolho cq2_p_duringscheduledschoolh

foreach i in p ls us {
	foreach j in duringscheduledschoolh onweekends afterschooltime notapplicable other donotknow {
		replace cq2_`i'_`j' = "0" if cq2_`i'_`j' == ""
		replace cq2_`i'_`j' = "1" if cq2_`i'_`j' == "During scheduled school holidays"
		replace cq2_`i'_`j' = "1" if cq2_`i'_`j' == "On weekends"
		replace cq2_`i'_`j' = "1" if cq2_`i'_`j' == "After school time (after the normal class time)"
		replace cq2_`i'_`j' = "1" if cq2_`i'_`j' == "Not applicable"
		replace cq2_`i'_`j' = "1" if cq2_`i'_`j' == "Other"
		replace cq2_`i'_`j' = "997" if cq2_`i'_`j' == "Do not know"
		destring cq2_`i'_`j', replace
	}
}

*S3/cq3/Q3. 
foreach i in pp p ls us {
	foreach j in first second third {
		replace cq3_`i'_`j' = "997" if cq3_`i'_`j' == "Do not know/Not monitored"
		replace cq3_`i'_`j' = "1" if cq3_`i'_`j' == "Less than 25% "
		replace cq3_`i'_`j' = "2" if cq3_`i'_`j' == "More than 25% but less than 50%"
		replace cq3_`i'_`j' = "3" if cq3_`i'_`j' == "About half of the students"
		replace cq3_`i'_`j' = "4" if cq3_`i'_`j' == "More than 50% but less than 75%"
		replace cq3_`i'_`j' = "5" if cq3_`i'_`j' == "More than 75% but not all of the students"
		replace cq3_`i'_`j' = "6" if cq3_`i'_`j' == "All of the students"
		/*These option do not exist for UIS data
		replace cq3_`i'_`j' = "999" if cq3_`i'_`j' == "Schools/Districts/the most local level of governance could decide at their own discretion"
		replace cq3_`i'_`j' = "997" if cq3_`i'_`j' == "Do not know (m)"
		replace cq3_`i'_`j' = "998" if cq3_`i'_`j' == "Not applicable (a)"
		replace cq3_`i'_`j' = "999" if cq3_`i'_`j' == "Include in another column (xc)"
		replace cq3_`i'_`j' = "999" if cq3_`i'_`j' == "Missing"
		replace cq3_`i'_`j' = "999" if cq3_`i'_`j' == ""
		*/
		destring cq3_`i'_`j', replace
	}
}

*S3/cq4/Q4. 
rename  cq4_pp_studentandteacherretur cq4_pp_studentandteacherreturn
rename  cq4_p_reducingorsuspendingext cq4_p_reducingorsuspendingex
rename  cq4_ls_studentandteacherretur cq4_ls_studentandteacherreturn
rename  cq4_us_classroomattendancesche cq4_us_classroomattendance
rename  cq4_us_classroomteachingconduc cq4_us_classroomteaching
rename  cq4_us_studentandteacherretur cq4_us_studentandteacherreturn

foreach i in pp p ls us {
	foreach j in immediatereturn progressivereturn adjustments1 adjustments2 nolunch combining classroomattendance classroomteaching studentandteacherreturn reducingorsuspendingex other none donotknow {
		replace cq4_`i'_`j' = "0" if cq4_`i'_`j' == ""
		replace cq4_`i'_`j' = "1" if cq4_`i'_`j' == "Immediate return to normal scheduling and student attendance, taking the necessary sanitary precautions"
		replace cq4_`i'_`j' = "1" if cq4_`i'_`j' == "Progressive return of students (e.g. by age cohorts)"
		replace cq4_`i'_`j' = "1" if cq4_`i'_`j' == "Adjustments to school and/or classroom’s physical arrangements "
		replace cq4_`i'_`j' = "1" if cq4_`i'_`j' == "Adjustments to school feeding programmes"
		replace cq4_`i'_`j' = "1" if cq4_`i'_`j' == "No lunch or meals at school (reopening limited to classes and learning activities only) "
		replace cq4_`i'_`j' = "1" if cq4_`i'_`j' == "Combining distance learning and in-person classes"
		replace cq4_`i'_`j' = "1" if cq4_`i'_`j' == "Classroom attendance scheduled in shifts "
		replace cq4_`i'_`j' = "1" if cq4_`i'_`j' == "Classroom teaching conducted in schools’ outdoor spaces"
		replace cq4_`i'_`j' = "1" if cq4_`i'_`j' == "Student and teacher returns contingent upon results of COVID-19 testing"
		replace cq4_`i'_`j' = "1" if cq4_`i'_`j' == "Reducing or suspending extracurricular activities"
		replace cq4_`i'_`j' = "1" if cq4_`i'_`j' == "Other (please specify)"
		replace cq4_`i'_`j' = "1" if cq4_`i'_`j' == "None of the above measures/strategies"
		replace cq4_`i'_`j' = "997" if cq4_`i'_`j' == "Do not know"
		destring cq4_`i'_`j', replace
	}
}

******* Step D - Variable labeling *******

*S3/cq3/Q3. 
label define cq3_value 						///
	997 "Do not know/Not monitored"			///
	1 "Less than 25 "						///
	2 "More than 25% but less than 50%"		///
	3 "About half of the students"			///
	4 "More than 50% but less than 75%"		///
	5 "More than 75% but not all of the students"	 ///
	6 "All of the students" 			
label value cq3_pp* cq3_p* cq3_ls* cq3_us* cq3_value


******* Step E - Data cleaning *******
*S3/cq1/Q1. 
* Cleaning Missing: Countries with zero for all are considered as missing
foreach i in pp p ls us {
		gen cq1_`i'_missing = (cq1_`i'_assessment + cq1_`i'_remedial1 + cq1_`i'_remedial2 + cq1_`i'_remedial3 + cq1_`i'_remedial4 + cq1_`i'_remedial5 + cq1_`i'_remedial6 + cq1_`i'_remedial7 + cq1_`i'_remedial8 + cq1_`i'_other + cq1_`i'_none == 0)		
	foreach j in assessment remedial1 remedial2 remedial3 remedial4 remedial5 remedial6 remedial7 remedial8 other none donotknow {		
		replace cq1_`i'_`j' = 999 if cq1_`i'_missing == 1
	}
}

*S3/cq2/Q2. 

foreach i in p ls us {
		gen cq2_`i'_missing = (cq2_`i'_duringscheduledschoolh + cq2_`i'_onweekends + cq2_`i'_afterschooltime + cq2_`i'_notapplicable +cq2_`i'_other + cq2_`i'_donotknow == 0)
	foreach j in duringscheduledschoolh onweekends afterschooltime notapplicable other donotknow {
		replace cq2_`i'_`j' = 999 if cq2_`i'_missing == 1
	}
}

*S3/cq4/Q4. 

foreach i in pp p ls us {
		gen cq4_`i'_missing = (cq4_`i'_immediatereturn + cq4_`i'_progressivereturn + cq4_`i'_adjustments1 + cq4_`i'_adjustments2 + cq4_`i'_nolunch + cq4_`i'_combining + cq4_`i'_classroomattendance + cq4_`i'_classroomteaching + cq4_`i'_studentandteacherreturn + cq4_`i'_reducingorsuspendingex + cq4_`i'_other + cq4_`i'_none + cq4_`i'_donotknow == 0)
	foreach j in immediatereturn progressivereturn adjustments1 adjustments2 nolunch combining classroomattendance classroomteaching studentandteacherreturn reducingorsuspendingex other none donotknow {
		replace cq4_`i'_`j' = 999 if cq4_`i'_missing == 1
	}
}

******* Step F - Open section to clean specific interested questions *******

*---------------------------------------------------------------------------
* Section 4. and 10. Distance Education Delivery Systems 
*---------------------------------------------------------------------------
*QUESTIONS IN THIS SECTION:

*S4/dq1/Q1. Which distance learning solutions were or are being offered in your country during the pandemic in 2020 and/or 2021 ? (Select all that apply)
*S4/dq2/Q2. What percentage of students (at each level of education), approximately, followed distance education during school closures in 2020 ? 
*S4/dq3/Q3. Has any study or assessment been carried out (at the regional or national level) in 2020 to assess the effectiveness of distancelearning strategies?
*S4/dq3a/Q3a. If answered ‘yes’ to any options, please select the methods of assessment [Select all that apply]:
*S4/dq3a/Q4. Is distance learning considered a valid form of delivery to account for of􀁿cial instruction days in 2020?

*S10/jq1/Q1. If the country’s national distance strategy included broadcasting lessons on television or radio, what proportion of the population is reached by television and radio?   
*S10/jq2a/Q2A.[Policy] For each of the below categories please select from 1-4 which statement best reflects the state of digital learning and ICT in your country.
*S10/jq2b/Q2B.[Funding] For each of the below categories please select from 1-4 which statement best reflects the state of digital learning and ICT in your country.
*S10/jq2c/Q2C.[Partnerships] For each of the below categories please select from 1-4 which statement best reflects the state of digital learning and ICT in your country.
*S10/jq2d/Q2D.[Monitoring and Evaluation] For each of the below categories please select from 1-4 which statement best reflects the state of digital learning and ICT in your country.

******* Step C - String to numerical (Yes, No, Select all that apply) *******

*S4/dq1/Q1.
foreach i in pp ls us {
	foreach j in onlineplatforms television mobilephones radio takehomepackages otherdistancelearningm  none {
     replace dq1_`i'_`j' = "1" if dq1_`i'_`j' !=""
     replace dq1_`i'_`j' = "0" if dq1_`i'_`j' == ""
	   destring dq1_`i'_`j', replace
	}
}

foreach i in p_onlineplatforms p_television p_mobilephones p_radio p_takehomepackages    p_otherdistancelearningmo p_none {
     replace dq1_`i' = "1"   if dq1_`i' !=""
     replace dq1_`i' = "0" if dq1_`i' == ""
	   destring dq1_`i', replace
}

*S4/dq2/Q2.
foreach var of varlist dq2_pp_percent dq2_p_percent dq2_ls_percent dq2_us_percent {
		replace `var' = "1" if `var' == "Less than 25%;"
		replace `var' = "1" if `var' == "less than 25%;"
		replace `var' = "2" if `var' == "More than 25% but less than 50%"
		replace `var' = "3" if `var' == "About half of the students"
		replace `var' = "4" if `var' == "More than 50% but less than 75%"
		replace `var' = "5" if `var' == "More than 75% but not all of the students"
		replace `var' = "6" if `var' == "All of the students"   
		replace `var' = "997" if `var' == "Do not know " 
		replace `var' = "998" if `var' == "Not applicable" 
		replace `var' = "999" if `var' == ""
		destring `var', replace
}

*S4/dq3/Q3. 
foreach var of varlist dq3_all_onlineplatforms dq3_all_television dq3_all_mobilephones dq3_all_radio dq3_all_takehomepackages dq3_all_otherdistancelearning  {
   replace `var' = ustrtrim(`var') 
   replace `var' = "1" if `var' == "Yes"
   replace `var' = "0" if `var' == "No"
   replace `var' = "999" if `var' == "" 
   replace `var' = "997" if `var' == "Do not know" 
   replace `var' = "998" if `var' == "Not applicable"
   destring `var', replace
}

*S4/dq3a/Q3a. 
foreach var of varlist dq3a_all_householdsurvey dq3a_all_teacherassessment dq3a_all_studentassessment dq3a_all_other {
   replace `var' = "1"   if `var' !=""
   replace `var' = "0" if `var' ==""
   destring `var', replace
}

*S4/dq4/Q4.
foreach var of varlist dq4_pp_all dq4_p_all dq4_ls_all dq4_us_all {
		replace `var' = "1" if `var' == "Not at all "
		replace `var' = "2" if `var' == "Very little"
		replace `var' = "3" if `var' == "To some extent"
    replace `var' = "4" if `var' == "To a great extent"
		replace `var' = "997" if `var' == "Do not know " 
		replace `var' = "998" if `var' == "Not applicable" 
		replace `var' = "999" if `var' == ""
		destring `var', replace
}

*S10/jq1/Q1. 
foreach var of varlist jq1_pp jq1_p jq1_ls jq1_us {
		replace `var' = "1" if `var' == "less than 25%;"
		replace `var' = "2" if `var' == "More than 25% but less than 50%" 
		replace `var' = "3" if `var' == "About half of the population" 
		replace `var' = "4" if `var' == "More than 50% but less than 75%"
		replace `var' = "5" if `var' == "More than 75% but not all of the population"
		replace `var' = "6" if `var' == "All of the population"
		replace `var' = "997" if `var' == "Do not know " 
		replace `var' = "998" if `var' == "Not Applicable" 
		replace `var' = "999" if `var' == ""
		destring `var', replace
}

*S10/jq2a/Q2A.
replace jq2a  = ustrtrim(jq2a) 
replace jq2a = "1" if jq2a == "1. There is no policy supporting Digital learning education; no Introduction of ICT into select educational processes and activities"
replace jq2a = "2" if jq2a == "2. There is a draft policy on ICT in education; some ICT integrated into select educational processes and activities"
replace jq2a = "3" if jq2a == "3. The policy on ICT in education has been approved/draft serving as a de facto policy Integrate ICT in education at all education levels"
replace jq2a = "4" if jq2a == "4. There is explicit policy guidance related to ICT/education topics; ICT in education policy is fully operationalized and seeks to transform learning environments, teaching practices and administrative processes with the aid of ICT"
replace jq2a = "999" if jq2a == ""
destring jq2a, replace

*S10/jq2b/Q2B.
replace jq2b  = ustrtrim(jq2b) 
replace jq2b = "1" if jq2b == "1. There is no or minimal regular expenditure for ICT/DL"
replace jq2b = "2" if jq2b == "2. There is occasional, nonregular public expenditure on ICT/DL"
replace jq2b = "3" if jq2b == "3. There is regular public expenditure on ICT/DL, on infrastructure and non-infrastructure items"
replace jq2b = "4" if jq2b == "4. There is extra (on top of regular) public expenditure on ICT/DL on infrastructure and non-infrastructure itemso"
replace jq2b = "999" if jq2b == ""
destring jq2b, replace

*S10/jq2c/Q2C.
replace jq2c = ustrtrim(jq2c) 
replace jq2c = "1" if jq2c == "1. No Public–private partnership (PPPs) enabling or supporting digital learning initiatives"
replace jq2c = "2" if jq2c == "2. Some PPPs enabling or supporting digital learning initiatives"
replace jq2c = "3" if jq2c == "3. Commitment to coordinating PPP initiatives related to digital learning"
replace jq2c = "4" if jq2c == "4. Explicit commitment to integrating, coordinating and monitoring PPP initiatives related to digital learning"
replace jq2c = "999" if jq2c == ""
destring jq2c, replace

*S10/jq2d/Q2D.
replace jq2d = ustrtrim(jq2d) 
replace jq2d = "1" if jq2d == "1. There is little or no monitoring; when existing, monitoring is irregular, incomplete and relates primarily to access to infrastructure; impact of DL use is not measured"
replace jq2d = "2" if jq2d == "2. Most monitoring is of inputs; Impact of DL is measured irregularly; most impact measurements relates to changes in attitudes and perceptions of changes in activity"
replace jq2d = "3" if jq2d == "3. There is regular monitoring of system inputs; Impact of DL is measured regularly; some measures relate to learning outcomes; some regular or systematic independent M&E of DL activities are carried out"
replace jq2d = "4" if jq2d == "4. There is a robust M&E system in place to measure the use and impact of DL, including learning outcomes Policy choices and decisions related to DL are evidence based; M&E function independent of project implementers"
replace jq2d = "999" if jq2d == ""
destring jq2d, replace

******* Step E - Data cleaning *******

*S4/dq1/Q1. 
* Cleaning Missing: Countries with zero for all are considered as missing
foreach i in pp ls us {
	gen dq1_`i'_missing = (dq1_`i'_onlineplatforms + dq1_`i'_television + dq1_`i'_mobilephones + dq1_`i'_radio + dq1_`i'_takehomepackages + dq1_`i'_otherdistancelearningm + dq1_`i'_none == 0)	
	foreach j in onlineplatforms television mobilephones radio takehomepackages otherdistancelearningm  none {
     replace dq1_`i'_`j' = 999 if dq1_`i'_missing == 1
	}
}

gen dq1_p_missing = (dq1_p_onlineplatforms + dq1_p_television + dq1_p_mobilephones + dq1_p_radio + dq1_p_takehomepackages + dq1_p_otherdistancelearningmo + dq1_p_none == 0)

foreach i in p_onlineplatforms p_television p_mobilephones p_radio p_takehomepackages    p_otherdistancelearningmo p_none {
     replace dq1_`i' = 999 if dq1_p_missing == 1
}

*S4/dq1/Q1. 
*Logic check: replacing none to 0 if one of the measures is selected
foreach i in pp ls us {
	replace dq1_`i'_none = 0 if dq1_`i'_onlineplatforms ==1  | dq1_`i'_television ==1  | dq1_`i'_mobilephones ==1  | dq1_`i'_radio ==1  | dq1_`i'_takehomepackages ==1  | dq1_`i'_otherdistancelearningm ==1  
}

replace dq1_p_none = 0 if dq1_p_onlineplatforms ==1  | dq1_p_television ==1  | dq1_p_mobilephones ==1  | dq1_p_radio ==1  | dq1_p_takehomepackages ==1  | dq1_p_otherdistancelearningmo ==1

*S4/dq3a/Q3a.
*logic check: variable dq3a exists if dQ3 is 1/yes
foreach i of varlist dq3a_all_householdsurvey dq3a_all_teacherassessment dq3a_all_studentassessment dq3a_all_other {
   replace `i' = 998 if  dq3_all_onlineplatforms !=1 & dq3_all_television !=1 & dq3_all_mobilephones !=1 & dq3_all_radio !=1 & dq3_all_takehomepackages  !=1 &  dq3_all_otherdistancelearning !=1 
}

******* Step D - Variable labeling *******

*S4/dq1/Q1.
label define dq1_value						///
	1 "Yes"						///
	0 "No"	///
  999 "Missing"
  label value dq1_pp* dq1_p* dq1_ls* dq1_us* dq1_value

*S4/dq2/Q2.
label define dq2_value 	///
	1 "Less than 25%"			///
	2 "More than 25% but less than 50%"		///
	3 "About half of the students"			///
	4 "More than 50% but less than 75%"		///
	5 "More than 75% but not all of the students"	 ///
	6 "All of the students" ///
  997 "Do not know"			///
  998 "Not applicable" ///
 	999 "Missing" 
label value dq2_pp* dq2_p* dq2_ls* dq2_us* dq2_value

*S4/dq3/Q3.
label define dq3_value	///
  0 "No"    ///
	1 "Yes"						///
  997 "Do not know" ///
  998 "Not applicable" ///
	999 "Missing"			
label value dq3_all* dq3_value
  
*S4/dq3a/Q3A.
label define dq3a_value						///
	1 "Yes"						///
	0 "No"		///
  998 "Not applicable"
label value dq3a_all_householdsurvey dq3a_all_teacherassessment dq3a_all_studentassessment dq3a_all_other dq3a_value

*S4/dq4/Q4.
label define dq4_value  ///
	1 "Not at all"			///
	2 "Very little"		///
	3 "To some extent"			///
	4 "To a great extent"	///
  997 "Do not know"			///
  998 "Not applicable" ///
 	999 "Missing" 
label value dq4_pp_all dq4_p_all dq4_ls_all dq4_us_all dq4_value
  
*S10/jq1/Q1.
label define jq1_value 						///
	1 "Less than 25%"						///
	2 "More than 25% but less than 50%"		///
	3 "About half of the students"			///
	4 "More than 50% but less than 75%"		///
	5 "More than 75% but not all of the students"	 ///
	6 "All of the students" 	///
  997 "Do not know"			///
  998 "Not applicable" ///
	999 "Missing"	
label value jq1_pp jq1_p jq1_ls jq1_us jq1_value

*S10/jq2a/Q2A.
label define jq2a_value 	///
	1 "1. There is no policy supporting Digital learning education; no Introduction of ICT into select educational processes and activities" ///
	2 "2. There is a draft policy on ICT in education; some ICT integrated into select educational processes and activities" ///
	3 "3. The policy on ICT in education has been approved/draft serving as a de facto policy Integrate ICT in education at all education levels"	///
	4 "4. There is explicit policy guidance related to ICT/education topics; ICT in education policy is fully operationalized and seeks to transform learning environments, teaching practices and administrative processes with the aid of ICT"		///
  999 "Missing"	
label value jq2a jq2a_value

*S10/jq2b/Q2B.
label define jq2b_value	///
	1 "1. There is no or minimal regular expenditure for ICT/DL"	///
	2 "2. There is occasional, nonregular public expenditure on ICT/DL"		///
	3 "3. There is regular public expenditure on ICT/DL, on infrastructure and non-infrastructure items"	///
	4 "4. There is extra (on top of regular) public expenditure on ICT/DL on infrastructure and non-infrastructure itemso"		 ///
  999 "Missing"	
label value jq2b jq2b_value

*S10/jq2c/Q2C.
label define jq2c_value 	///
	1 "1. No Public–private partnership (PPPs) enabling or supporting digital learning initiatives"	///
	2 "2. Some PPPs enabling or supporting digital learning initiatives"	///
	3 "3. Commitment to coordinating PPP initiatives related to digital learning"	 ///
	4 "4. Explicit commitment to integrating, coordinating and monitoring PPP initiatives related to digital learning" ///
  999 "Missing"
label value jq2c jq2c_value

*S10/jq2d/Q2D.
label define jq2d_value 	///
	1 "1. There is little or no monitoring; when existing, monitoring is irregular, incomplete and relates primarily to access to infrastructure; impact of DL use is not measured"	///
	2 "2. Most monitoring is of inputs; Impact of DL is measured irregularly; most impact measurements relates to changes in attitudes and perceptions of changes in activity"	///
	3 "3. There is regular monitoring of system inputs; Impact of DL is measured regularly; some measures relate to learning outcomes; some regular or systematic independent M&E of DL activities are carried out"	 ///
	4 "4. There is a robust M&E system in place to measure the use and impact of DL, including learning outcomes Policy choices and decisions related to DL are evidence based; M&E function independent of project implementers" ///
  999 "Missing"
label value jq2d jq2d_value

*******  Step A - Variable renaming/dropping ******* 

*S4/dq1/Q1.
*rename variable to match OECD one
renvars dq1_p_otherdistancelearningmo / dq1_p_otherdistancelearningm

******* Step F - Open section to clean specific interested questions *******


*---------------------------------------------------------------------------
* Section 5. Teachers and Educational Personnel
*---------------------------------------------------------------------------
*QUESTIONS IN THIS SECTION:
*S5/eq1/Q1: Q1. What percentage of teachers, approximately, were required to teach (remotely/online) during all school closures in 2020? 
*S5/eq1a/Q1a: If answered “All of the teachers” to Q1, were they able to teach from the school premises? (Pragya)
*S5/eq1b/Q1b: please specify in which levels of educations were teachers required to teach and whether they were teaching from school premises 
*S5/eq2/Q2. Have there been changes to teacher pay and, benefits due to the period(s) of school closures in 2020?
*S5/eq3/Q3:Eq3: Were or are new teachers being recruited for school re-opening during the previous or current school year? 
*S5/eq4/Q4. How and at what scale were teachers (in pre-primary to upper secondary levels combined) supported in the transition to remote learning in 2020? [Select all that apply]
*S5/eq4/Q4a. Please provide any estimation of the percentage of teachers trained in 2020 in using distance learning methods :     
*S5/eq4/Q4b. Please provide any estimation of the percentage of teachers that received materials to support distance learning in 2020 :  
*S5/eq5/Q5 : What kind of interactions were encouraged by government between teachers and their students and/or their parents during school closures in 2020 (in pre-primary to upper secondary levels combined)? 
*S5/eq6/Q6. Do you have plans to prioritize vaccinations for teachers (in pre-primary to upper secondary levels combined)?  //
* Note: COVAX initiative refers to the WHO initiative to secure access to the future COVID-19 vaccine in low and middle-income countries (https://www.who.int/initiatives/act-accelerator/covax)
*S5/eq6/Q6a. Among teachers, do you have criteria for prioritization? [select all that apply]
*S5/eq6/Q6b. When is planned to start the vaccination of teachers? (Extensive cleaning is conducted: Keeping the information from the original response with [variablename]_raw)

******* Step C - String to numerical (Yes, No, Select all that apply) *******

*S5/eq1/Q1:
		replace eq1_all_percentage = "1" if eq1_all_percentage == "Less than 25%; (If so, please answer Question 1.B)"
		replace eq1_all_percentage = "2" if eq1_all_percentage == "More than 25% but less than 50% (If so, please answer Question 1.B)"
		replace eq1_all_percentage = "3" if eq1_all_percentage == "About half of the teachers (If so, please answer Question 1.B)"
		replace eq1_all_percentage = "4" if eq1_all_percentage == "More than 50% but less than 75% (If so, please answer Question 1.B)"
		replace eq1_all_percentage = "5" if eq1_all_percentage == "More than 75% but not all of the teachers (If so, please answer Question 1.B)"
		replace eq1_all_percentage = "6" if eq1_all_percentage == "All of the teachers (If so, please answer Question 1.A)"
		replace eq1_all_percentage = "998" if eq1_all_percentage == "Not applicable (If so, please answer Question 2)"
		replace eq1_all_percentage = "997" if eq1_all_percentage == "Do not know (If so, please answer Question 2)"
		replace eq1_all_percentage = "999" if eq1_all_percentage == ""
		destring eq1_all_percentage, replace

*S5/eq1a/Q1a:
		
		replace eq1a_all_premises = "0" if eq1a_all_premises == "No "
		replace eq1a_all_premises = "1" if eq1a_all_premises == "Yes "
		replace eq1a_all_premises = "997" if eq1a_all_premises == "Do not know"
    *added line to make it numerical:
    replace eq1a_all_premises = "999" if eq1a_all_premises == ""
		destring eq1a_all_premises, replace
		
*S5/eq1b/Q1b
	foreach var of varlist eq1b_ls_levels eq1b_p_levels eq1b_pp_levels eq1b_us_levels {
		replace `var'="0" if `var'=="Teachers were required to teach, but not from the school premises."
		replace `var'="1" if `var'=="Teachers were required to teach from the school premises."
		replace `var'="999" if `var'== ""
		replace `var'="998" if `var'=="Teachers were not required to teach at this level of education."
		destring `var', replace
}

*S5/eq2/Q2.
foreach i in eq2_pp_pay eq2_p_pay eq2_ls_pay eq2_us_pay {
   replace `i' = "1" if `i' == "Yes, a decrease of teacher pay and/or benefits"
   replace `i' = "2" if `i' =="Yes, an increase of teacher pay and/or benefits"
   replace `i' = "3" if `i' =="No change"
   replace `i' = "4" if `i' =="This can be done at the discretion of schools/districts"  
   replace `i' = "997" if `i' =="Do not know" 
   replace `i' = "999" if `i' =="" 
   destring `i', replace
}

*S5/eq3/Q3
	foreach var of varlist eq3_ls_2020 eq3_ls_2021 eq3_p_2020 eq3_p_2021 eq3_pp_2020 eq3_pp_2021 eq3_us_2020 eq3_us_2021 {
		replace `var'="0" if `var'=="No"
		replace `var'="1" if `var'=="Yes"
		replace `var'="2" if `var'=="This can be done at the discretion of schools/districts"
		replace `var'="997" if `var'=="Do not know"
		replace `var'="998" if `var'=="Not applicable"
		replace `var'="999" if `var'==""
		destring `var', replace
}

*S5/eq4/Q4.
foreach i in eq4_all_natofferedspecial eq4_all_natinstruction eq4_all_natppe eq4_all_natguidelines eq4_all_natprofessionaldev eq4_all_natteachingcontent eq4_all_naticttools eq4_all_natnoadditionalsup eq4_all_natother eq4_all_subnatofferedspecial eq4_all_subnatinstruction eq4_all_subnatppe eq4_all_subnatguidelines eq4_all_subnatprofessionaldev eq4_all_subnatteachingcontent eq4_all_subnaticttools eq4_all_subnatother eq4_all_subnatnoadditionalsup eq4_all_schoolofferedspecial eq4_all_schoolinstruction eq4_all_schoolppe eq4_all_schoolguidelines eq4_all_schoolprofessionaldev eq4_all_schoolteachingcontent eq4_all_schoolicttools eq4_all_schoolnoadditionalsup eq4_all_schoolother {
   replace `i' = "0" if `i' =="No"
   replace `i' = "1" if `i' =="Yes"
   replace `i' = "997" if `i' =="Do not know" 
   replace `i' = "999" if `i' =="" 
   destring `i', replace
}

*S5/eq4a/Q4a:
		replace eq4a_all_distance = "1" if eq4a_all_distance == "Less than 25% "
		replace eq4a_all_distance = "2" if eq4a_all_distance == "More than 25% but less than 50%"
		replace eq4a_all_distance = "3" if eq4a_all_distance == "About half of the teachers"
		replace eq4a_all_distance = "4" if eq4a_all_distance == "More than 50% but less than 75%"
		replace eq4a_all_distance = "5" if eq4a_all_distance == "More than 75% but not all; "
		replace eq4a_all_distance = "6" if eq4a_all_distance== "All of the teachers; "
		replace eq4a_all_distance = "997" if eq4a_all_distance == "Unknown/not monitored"
		replace eq4a_all_distance = "999" if eq4a_all_distance == ""
		destring eq4a_all_distance, replace
		
*S5/eq4b/Q4b:
		replace eq4b_all_support = "1" if eq4b_all_support == "Less than 25% "
		replace eq4b_all_support = "2" if eq4b_all_support == "More than 25% but less than 50%"
		replace eq4b_all_support = "3" if eq4b_all_support == "About half of the teachers"
		replace eq4b_all_support = "4" if eq4b_all_support == "More than 50% but less than 75%"
		replace eq4b_all_support = "5" if eq4b_all_support == "More than 75% but not all; "
		replace eq4b_all_support = "6" if eq4b_all_support == "All of the teachers; "
		replace eq4b_all_support = "997" if eq4b_all_support == "Unknown/not monitored"
		replace eq4b_all_support = "999" if eq4b_all_support == ""
		destring eq4b_all_support, replace

*S5/eq5/Q5
	
	*Replace to 999 (missing) if none of the choices is selected
	replace eq5_all_phonecalls= "999" if eq5_all_phonecalls=="" & eq5_all_emails=="" & eq5_all_textwhatsapp =="" & eq5_all_videoconference =="" & ///
		eq5_all_homevisits =="" & eq5_all_communicationoneschool=="" & eq5_all_useofonlineparentalsurve=="" & eq5_all_holdingregularconversati=="" & eq5_all_involvingparents =="" ///
		& eq5_all_other=="" & eq5_all_nospecificguidelines==""

	foreach i in eq5_all_emails eq5_all_textwhatsapp eq5_all_videoconference eq5_all_homevisits eq5_all_communicationoneschool ///
		eq5_all_useofonlineparentalsurve eq5_all_involvingparents eq5_all_holdingregularconversati eq5_all_nospecificguidelines eq5_all_other {
		replace `i' = "999" if eq5_all_phonecalls=="999"
			}
			
	*Recode
	foreach var of varlist eq5_all_communicationoneschool eq5_all_emails eq5_all_holdingregularconversati eq5_all_homevisits eq5_all_involvingparents eq5_all_nospecificguidelines ///
		eq5_all_other eq5_all_phonecalls eq5_all_textwhatsapp eq5_all_useofonlineparentalsurve eq5_all_videoconference {
		replace `var'="0" if `var'=="No"
		replace `var'="1" if `var'=="Yes"
		replace `var'="2" if `var'=="This can be done at the discretion of schools/districts"
		replace `var'="997" if `var'=="Do not Know"
		replace `var'="998" if `var'=="Not applicable (a)"
		replace `var'="999" if `var'==""
		destring `var', replace
}
	
*S5/eq6/Q6.
foreach i in eq6_all_vaccine {
   replace `i' = "1" if `i' =="No, teachers are considered as the general population;"
   replace `i' = "2" if `i' =="Yes, as a national measure prioritizing teachers;"
   replace `i' = "3" if `i' =="Yes, as part of the COVAX initiative to secure access to the future COVID-19 vaccine in low and middle-income countries"
   replace `i' = "4" if `i' =="Other, please explain " 
   replace `i' = "997" if `i' =="Do not know" 
   replace `i' = "999" if `i' =="" 
   destring `i', replace
}

*S5/eq6a/Q6a:
		replace eq6a_all_yesbyagegroup = "0" if eq6a_all_yesbyagegroup == ""
		replace eq6a_all_yesbyagegroup = "1" if eq6a_all_yesbyagegroup == "Yes, by age group"
		replace eq6a_all_yesbylevelofeducation = "0" if eq6a_all_yesbylevelofeducation == ""
		replace eq6a_all_yesbylevelofeducation = "1" if eq6a_all_yesbylevelofeducation == "Yes, by level of education"
		replace eq6a_all_yesbysubnationallevel = "0" if eq6a_all_yesbysubnationallevel == ""
		replace eq6a_all_yesbysubnationallevel = "1" if eq6a_all_yesbysubnationallevel == "Yes, by sub-national level"
		replace eq6a_all_yesotherpleasespecify = "0" if eq6a_all_yesotherpleasespecify == ""
		replace eq6a_all_yesotherpleasespecify = "1" if eq6a_all_yesotherpleasespecify == "Yes, other. Please specify:____________"
		replace eq6a_all_no = "0" if eq6a_all_no == ""
		replace eq6a_all_no = "1" if eq6a_all_no == "No"
		replace eq6a_all_donotknow = "0" if eq6a_all_donotknow == ""
		replace eq6a_all_donotknow = "1" if eq6a_all_donotknow == "Do not know"
		destring eq6a*, replace
		
*S5/eq6/Q6b:

* Classifying answer to one of the answer choise: Given the question asks the start date, the earliest date will be chosen as their response whatever the other variable indicates
gen      eq6b_all_categ=.
replace  eq6b_all_categ=1 if eq6b_all_2021q1=="X" | eq6b_all_2021q1=="XXX" | eq6b_all_2021q1=="x" | eq6b_all_2021q1=="yes" | eq6b_all_2021q1=="Yes" | eq6b_all_2021q1=="Si" | eq6b_all_2021q1=="Already conducted" | eq6b_all_2021q1=="1/3/2021" | eq6b_all_2021q1=="30 de marzo 2021" | eq6b_all_2021q1=="February 2021" | eq6b_all_2021q1=="March 2021" | eq6b_all_2021q1=="March or April, 2021" | eq6b_all_2021q1=="March, 2021" | eq6b_all_2021q1=="from 22 Feb 2021" | eq6b_all_2021q1=="started from the end of 2020 and rolled on to 2021" | eq6b_all_2021q1=="в первом квартале " | eq6b_all_2021q1=="نعم" | eq6b_all_2021q1=="С января 2021 года" 
replace  eq6b_all_categ=2 if eq6b_all_2021q1=="06/02/21" | eq6b_all_2021q1=="April and onward"
replace  eq6b_all_categ=2 if eq6b_all_2021q2=="X" | eq6b_all_2021q2=="x"  | eq6b_all_2021q2=="Yes "  | eq6b_all_2021q2=="Vaccination is scheduled to start in this period" | eq6b_all_2021q2=="Fase 2 Grupo 1"
replace  eq6b_all_categ=1 if eq6b_all_2021q2=="20 march 2020"
replace  eq6b_all_categ=3 if eq6b_all_2021q3=="September 2021"
replace  eq6b_all_categ=6 if eq6b_all_stillnotdefined!=""
replace  eq6b_all_categ=997 if eq6b_all_donotknow!=""

* Preserving the ifnormation from the original answer as _raw
foreach i in eq6b_all_2021q1 eq6b_all_2021q2 eq6b_all_2021q3 eq6b_all_2021q4 eq6b_all_2022 eq6b_all_stillnotdefined eq6b_all_donotknow {
rename `i' `i'_raw
gen `i'=0
}

* Inserting the cleaned response to the original variable
replace eq6b_all_2021q1=1 if eq6b_all_categ==1
replace eq6b_all_2021q2=1 if eq6b_all_categ==2
replace eq6b_all_2021q3=1 if eq6b_all_categ==3
replace eq6b_all_2021q4=1 if eq6b_all_categ==4
replace eq6b_all_2022=1 if eq6b_all_categ==5
replace eq6b_all_stillnotdefined=1 if eq6b_all_categ==6
replace eq6b_all_donotknow=1 if eq6b_all_categ==997

* Replacing the answer to missing if they did not answer to any of the options
gen eq6b_all_missing=eq6b_all_2021q1+eq6b_all_2021q2+eq6b_all_2021q3+eq6b_all_2021q4+eq6b_all_2022+eq6b_all_stillnotdefined+eq6b_all_donotknow
foreach i in eq6b_all_2021q1 eq6b_all_2021q2 eq6b_all_2021q3 eq6b_all_2021q4 eq6b_all_2022 eq6b_all_stillnotdefined eq6b_all_donotknow {
replace `i'=999 if eq6b_all_missing==0
}

drop eq6b_all_categ eq6b_all_missing

******* Step D - Variable labeling *******

*S5/eq1/Q1:
	label define eq1_percentage_value 			///
			1 "Less than 25%"						///
			2 "More than 25% but less than 50%"		///
			3 "About half of the students"			///
			4 "More than 50% but less than 75%"		///
			5 "More than 75% but not all of the teachers"	 ///
			6 "All of the teachers" ///
			997 "Do not know" ///
			998 "Not applicable" ///
			999 "Missing" 
	label value eq1_all_percentage eq1_percentage_value 

*S5/eq1a/Q1a & *S5/eq1b/Q1b &:	
	label define eq1a_value 						///
	0 "No"			///
	1 "Yes"		///
	997 "Do not know" ///
	998 "Not applicable" ///
	999 "Missing"
	label value eq1a_all_premises eq1b* eq1a_value 
	
*S5/eq2/Q2.
	label define eq2_pay_l 1 "Decrease" 2 "Increase" 3 "No change" 4 "discretion of schools/districts" 997 "Do not know", modify
	label value eq2_pp_pay eq2_p_pay eq2_ls_pay eq2_us_pay eq2_pay_l

*S5/eq3/Q3 & S5/eq3/Q5 (Q7 OECD)
	label define eq5_value 								///
			0 "No"										///
			1 "Yes"										///
			2 "At discretion of schools/ districts"		///
			997 "Do not know"							///
			998 "Not applicable"						///
			999 "Missing"
	label value eq3_ls_2020 eq3_ls_2021 eq3_p_2020 eq3_p_2021 eq3_pp_2020 eq3_pp_2021 eq3_us_2020 eq3_us_2021 eq5_value
	label value eq5_all_phonecalls eq5_all_emails eq5_all_textwhatsapp eq5_all_videoconference eq5_all_homevisits eq5_all_communicationoneschool eq5_all_useofonlineparentalsurve ///
	eq5_all_holdingregularconversati eq5_all_involvingparents eq5_all_nospecificguidelines eq5_all_other eq5_value
	
*S5/eq4/Q4.
	label define eq4_value	///
	0 "No"			///
	1 "Yes"		///
	997 "Do not know" ///
	998 "Not applicable" ///
	999 "Missing"
	label value eq4* eq4_value
	
*S5/eq4a/Q4a:
	label define eq4a_value 			///
			1 "Less than 25%"						///
			2 "More than 25% but less than 50%"		///
			3 "About half of the students"			///
			4 "More than 50% but less than 75%"		///
			5 "More than 75% but not all"	 ///
			6 "All of the teachers" ///
			997 "Unknown/not monitored" ///
			999 "Missing" 
	label value eq4a_all_distance eq4b_all_support eq4a_value
	
*S5/eq6/Q6.
	label define eq6_all_vaccine_l  ///
  1 "No, teachers are considered as the general population;"  ///
  2 "Yes, as a national measure prioritizing teachers;"  ///
  3 "Yes, as part of the COVAX initiative to secure access to the future COVID-19 vaccine in low and middle-income countries" ///
  4 "Other, please explain " ///
  997 "Do not know" 
	label value eq6_all_vaccine eq6_all_vaccine_l
	
*S5/eq6a/Q6a.
	label define eq6a_value ///
  0 "No"	///
  1 "Yes"
	label value eq6a_all_yesbyagegroup eq6a_all_yesbylevelofeducation eq6a_all_yesbysubnationallevel eq6a_all_yesotherpleasespecify eq6a_all_no eq6a_all_donotknow eq6a_value
	
*S5/eq6a/Q6b.
	label define eq6b_value 0 "No" 1 "Yes" 999 "Missing"
    label value eq6b_all_2021q1 eq6b_all_2021q2 eq6b_all_2021q3 eq6b_all_2021q4 eq6b_all_2022 eq6b_all_stillnotdefined eq6b_all_donotknow eq6b_value
    
******* Step E - Data cleaning *******

*S5/eq1a/Q1A.
*eq1a_all_premises
	replace eq1a_all_premises=998 if eq1_all_percentage!=6 // question only valid if all teachers teaching, replacing to not applicable if eq1_all_percentage!=all teachers

*S5/eq1b/Q1b.
foreach var of varlist eq1b_ls_levels eq1b_p_levels eq1b_pp_levels eq1b_us_levels {
		replace `var'=998 if eq1_all_percentage>6 // eq1b not applicable if eq1_all_percentage is dont know or missing or NA		
}	

*S5/eq4/Q4
* Given that the choices include "No measure", country that answered no to all choices are considered as missing for this variable
foreach j in nat subnat school {
gen     Check=0
replace Check=1 if eq4_all_`j'offeredspecial==0 & eq4_all_`j'instruction==0 & eq4_all_`j'ppe==0 & eq4_all_`j'guidelines==0 & ///
                   eq4_all_`j'professionaldev==0 & eq4_all_`j'teachingcontent==0 & eq4_all_`j'icttools==0 & eq4_all_`j'noadditionalsup==0 & eq4_all_`j'other==0

foreach i in eq4_all_`j'offeredspecial eq4_all_`j'instruction eq4_all_`j'ppe eq4_all_`j'guidelines eq4_all_`j'professionaldev eq4_all_`j'teachingcontent eq4_all_`j'icttools eq4_all_`j'noadditionalsup eq4_all_`j'other {
replace `i'=998 if Check==1
}
drop Check
}

* When some measures are chosen, no additional measure should be replaced to zero
foreach j in nat subnat school {
foreach i in eq4_all_`j'offeredspecial eq4_all_`j'instruction eq4_all_`j'ppe eq4_all_`j'guidelines eq4_all_`j'professionaldev eq4_all_`j'teachingcontent eq4_all_`j'icttools eq4_all_`j'other {
replace  eq4_all_`j'noadditionalsup=0 if `i'==1
}
}
	
*S5/eq5/Q5.
	replace eq5_all_nospecificguidelines=0 if (eq5_all_phonecalls==1 | eq5_all_emails==1 | eq5_all_textwhatsapp==1 | eq5_all_videoconference==1 | eq5_all_homevisits==1 | 	///	
	eq5_all_communicationoneschool==1 | eq5_all_useofonlineparentalsurve==1 | eq5_all_holdingregularconversati==1 | eq5_all_involvingparents==1 | eq5_all_other ==1)
	// changing value of no specific guidelines if any of the other guidelines selected in eq5
	
*S5/eq6a/EQ6a
* Cleaning Missing: No responses in all sub-parts of eq6a considered as "missing"
gen eq6a_all_miss = (eq6a_all_yesbyagegroup + eq6a_all_yesbylevelofeducation + eq6a_all_yesbysubnationallevel + eq6a_all_yesotherpleasespecify + eq6a_all_no + eq6a_all_donotknow == 0)
foreach i in yesbyagegroup yesbylevelofeducation yesbysubnationallevel yesotherpleasespecify no donotknow {
	replace eq6a_all_`i' = 999 if eq6a_all_miss == 1
	}

*---------------------------------------------------------------------------
* Section 6. Learning Assessments and Examinations
*---------------------------------------------------------------------------
*QUESTIONS IN THIS SECTION:

*S6/fq1/Q1. Have you made any of the following changes to national examinations due to the pandemic during the school year 2019/2020 2020 for countries with calendar year)? (Select all that apply)
*S6/fq2/Q2. Have there been any steps taken to assess whether there have been learning losses as a result of COVID related school closure in 2020? 
*S6/fq3/Q3: Did your plans for school re-opening in 2020 include adjustment to graduation criteria at the end of school year  2019/2020 (or end of 2020)?

******* Step C - String to numerical (Yes, No, Select all that apply) *******

*S6/fq1/Q1.
foreach i in p ls us {
	foreach j in postponed adjustedthecontent adjustedthemode introducedaddh introducedaltass canceledexams other nochangesweremade notapplicable donotknow {
		replace fq1_`i'_2020`j' = "1" if fq1_`i'_2020`j' != ""
		replace fq1_`i'_2020`j' = "0" if fq1_`i'_2020`j' == ""
		destring fq1_`i'_2020`j', replace
	}
/*do not know is  "." for all countries*/
}

*Missing country: For each level of education, a country is assumed to be missing if it did not select any of the options listed
foreach i in p ls us {
	  gen fq1_`i'_missing = (fq1_`i'_2020postponed + fq1_`i'_2020adjustedthecontent + fq1_`i'_2020adjustedthemode/*
	  */+ fq1_`i'_2020introducedaddh + fq1_`i'_2020introducedaltass + fq1_`i'_2020canceledexams + fq1_`i'_2020other/*
	  */+ fq1_`i'_2020nochangesweremade + fq1_`i'_2020notapplicable   == 0)
    foreach j in postponed adjustedthecontent adjustedthemode introducedaddh introducedaltass canceledexams other nochangesweremade notapplicable {
		replace fq1_`i'_2020`j' = 999 if fq1_`i'_missing == 1
	}
}

*fq2 in UIS corresponds to FQ3 in OECD.  UIS is supposed to map FQ2 questions onto FQ3 in OECD.
/// This bit can cause additional confusion down the line, please have this in mind.

/*

Notes on transformation: In UIS question FQ2 is categorical variable with 5 choices whereas in OECD each UIS category is a variable with 
yes/no/don't know options. In transforming UIS to OECD, it is assumed that a countries default respose is "No", which is then 
replaced with 'yes', don't know' and missing based on responses to UIS. 
This is done because it is difficult to transform "no" between the two answer types. 
While OECD has 'not applicable' as an option, it is impossible to define this in UIS
Trnasformation rule: 
fq3_`i'_classroom is if students in ls/p were assessed at the classroom level
fq3_`i'_noplan is if no plan to assess students
fq3_`i'_notassessed is not yet but there is a plan to assess students
fq3_`i'_standard is plan to assess students in a standardized way (but no national/sub-national level
*/

foreach var in fq3_p_classroom fq3_p_noplan fq3_p_notassessed fq3_p_standard fq3_ls_classroom fq3_ls_noplan fq3_ls_notassessed fq3_ls_standard  {
	gen `var' = "0"  
}


foreach i in p ls {
	replace fq3_`i'_classroom = "1" if fq2_`i'_losses == "Yes, students were assessed at the classroom level (formative assessment by teachers)"
	replace fq3_`i'_noplan = "1" if fq2_`i'_losses == "No plan to assess students in a standardized way"
	replace fq3_`i'_notassessed = "1" if fq2_`i'_losses == "Not yet but there is a plan to assess students in a standardized way"
	replace fq3_`i'_standard  = "1" if fq2_`i'_losses == "Yes, students were assessed in a standardized way at the national level "|fq2_`i'_losses == "Yes, students were assessed in a standardized way at the sub-national level"
}
	
**Do not know and missing	
foreach i in p ls {
	foreach j in classroom noplan notassessed standard {
		replace fq3_`i'_`j' = "997" if fq2_`i'_losses == "Do not know"
		replace fq3_`i'_`j' = "999" if fq2_`i'_losses == ""
		destring fq3_`i'_`j', replace
	}
}


*S6/fq3/Q3.
foreach i in p ls us {
	foreach var of varlist fq3_`i'_2020  {
		replace `var' = "0" if `var' == "No"
		replace `var' = "1" if `var' == "Yes"
		replace `var' = "2" if `var' == "This can be done at the discretion of school"
		replace `var' = "997" if `var' == "Do not know"
		replace `var' = "998" if `var' == "Not applicable"
		replace `var' = "999" if `var' == "Missing"	
		destring `var', replace
		}
}



******* Step D - Variable labeling *******

*S6/fq1/Q1.
	foreach i in p ls us {
		foreach j in postponed adjustedthecontent adjustedthemode introducedaddh introducedaltass canceledexams other nochangesweremade notapplicable {
				label var fq1_`i'_2020`j' "`i': `j'"				
		}
	}

*S6/fq2/Q2 (which is now fq3 to follow OECD)	
foreach i in p ls {
		foreach j in classroom noplan notassessed standard {
				label var fq3_`i'_`j' "`i': `j'"				
		}
		}

*S6/fq3/Q3.		
foreach i in p ls us {
		foreach j in 2020 {
				label var fq3_`i'_`j' "`i': `j'"				
		}
}

******************Defining the labels

*S6/fq1/Q1.
label define fq1_value 0 "No" 1 "Yes" 999 "Missing"
label value  fq1_p_2020* fq1_ls_2020* fq1_us_2020* fq1_value

*S6/fq2/Q2. 
label define fq3steps 0 "No" 1 "Yes" 999 "Missing" 997 "Do not know"
label value fq3_ls_classroom fq3_ls_noplan fq3_ls_notassessed fq3_ls_standard fq3_p_classroom fq3_p_noplan fq3_p_notassessed fq3_p_standard fq3steps

*S6/fq3/Q3. 
label define fq3_2020 						///
	0 "No"			///
	1 "Yes"						///
	2 "This can be done at the discretion of school"		///
	997 "Do not know"	 ///
	998 "Not applicable" ///
	999 "Missing" 			
label value fq3_p_2020 fq3_ls_2020 fq3_us_2020  fq3_2020
    
******* Step E - Data cleaning *******

*S6/fq1/Q1. 
*Logic check: Country should not have selected 'no changes were made' if any other option was selected for that specific level

* Addressed the issue here

foreach i in p ls us {
	foreach j in postponed adjustedthecontent adjustedthemode introducedaddh introducedaltass canceledexams other  {
		replace fq1_`i'_2020nochangesweremade =0 if fq1_`i'_2020`j' == 1 
		}
}

******* Step F - Open section to clean specific interested questions *******


*---------------------------------------------------------------------------
* Section 7. Financing
*---------------------------------------------------------------------------
*QUESTIONS IN THIS SECTION:

*S7/gq1/Q1.Have there been changes planned to the 􀁿scal year education budget to ensure the response to COVID-19 for education in 2020 and 2021? [Select one option in each cell]
*S7/gq2/Q2. Has the distribution of education spending between current and capital expenditures (pre-primary to upper secondary levels combined) changed/is planned to change as a result of the education response to COVID-19?
*S7/gq2a/Q2a. If answered ‘increase’ to any of the categories in Q2, how were they funded? [Select all that apply]
*S7/gq3/Q3.What criteria were used to allocate additional public funds/resources in primary and secondary education to ensure the response to COVID-19 for education? [Select all that apply]
*S7/gq4/Q4.Has the distribution of public spending between primary and secondary education changed as a result of the education response to COVID-19 in 2020?

******* Step E - Data cleaning *******

*S7/gq1/Q1.
* Missing 
local gq1 "gq1_all_2020 gq1_pp_2020 gq1_p_2020 gq1_ls_2020 gq1_us_2020 gq1_all_2021 gq1_pp_2021 gq1_p_2021 gq1_ls_2021 gq1_us_2021"
foreach v of local gq1{
	replace `v' = "999" if `v' ==""
}

*S7/gq2/Q2.
local gq2 "gq2_all_fy2020totalcapitalexp gq2_all_fy2020totalcurrentexp gq2_all_fy2020compofteac gq2_all_fy2020compofothe gq2_all_fy2020schoolsmeals gq2_all_fy2020condcashtra gq2_all_fy2020studentsuppgra gq2_all_fy2020studentloans gq2_all_fy2020othercurrentexp gq2_all_fy2021totalcapitalexp gq2_all_fy2021totalcurrentexp gq2_all_fy2021compofteac gq2_all_fy2021compofothe gq2_all_fy2021schoolsmeals gq2_all_fy2021condcashtra gq2_all_fy2021studentsuppgra gq2_all_fy2021studentloans gq2_all_fy2021othercurrentexp"
foreach v of local gq2{
	replace `v' = "999" if `v' ==""
}

*S7/gq2a/Q2a. 
* logic check for 'dnk'
local gq2a "gq2a_all_addfundingfromex gq2a_all_reprogofprevious gq2a_all_addallocationfro gq2a_all_reallocwithintheed"
foreach v of local gq2a{
	replace  gq2a_all_donotknow = "" if `v' !="" 
}
*match 'dnk' with OECD (eg.JPN, PRT, NLD )
local gq2a "gq2a_all_addfundingfromex gq2a_all_reprogofprevious gq2a_all_addallocationfro gq2a_all_reallocwithintheed"
foreach v of local gq2a{
	replace `v' ="Do not know" if  gq2a_all_donotknow !="" & `v' ==""
}
drop  gq2a_all_donotknow

* defining missing
tempvar gq2a_all

gen `gq2a_all' = "Missing" if gq2a_all_addfundingfromex =="" & gq2a_all_reprogofprevious=="" & gq2a_all_addallocationfro=="" & gq2a_all_reallocwithintheed==""

local gq2a "gq2a_all_addfundingfromex gq2a_all_reprogofprevious gq2a_all_addallocationfro gq2a_all_reallocwithintheed"
foreach v of local gq2a{
	replace `v' ="999" if `gq2a_all' == "Missing" & (gq2_all_fy2020totalcapitalexp=="increases" |gq2_all_fy2020totalcurrentexp=="increases" |gq2_all_fy2020compofteac=="increases" |gq2_all_fy2020compofothe=="increases" |gq2_all_fy2020schoolsmeals=="increases" |gq2_all_fy2020condcashtra=="increases" |gq2_all_fy2020studentsuppgra=="increases" |gq2_all_fy2020studentloans=="increases" |gq2_all_fy2020othercurrentexp=="increases" |gq2_all_fy2021totalcapitalexp=="increases" |gq2_all_fy2021totalcurrentexp=="increases" |gq2_all_fy2021compofteac=="increases" |gq2_all_fy2021compofothe=="increases" |gq2_all_fy2021schoolsmeals=="increases" |gq2_all_fy2021condcashtra=="increases" |gq2_all_fy2021studentsuppgra=="increases" |gq2_all_fy2021studentloans=="increases" |gq2_all_fy2021othercurrentexp=="increases")
	replace `v' ="NA" if (gq2_all_fy2020totalcapitalexp!="increases" & gq2_all_fy2020totalcurrentexp!="increases" & gq2_all_fy2020compofteac!="increases" & gq2_all_fy2020compofothe!="increases" & gq2_all_fy2020schoolsmeals!="increases" & gq2_all_fy2020condcashtra!="increases" & gq2_all_fy2020studentsuppgra!="increases" & gq2_all_fy2020studentloans!="increases" & gq2_all_fy2020othercurrentexp!="increases" & gq2_all_fy2021totalcapitalexp!="increases" & gq2_all_fy2021totalcurrentexp!="increases" & gq2_all_fy2021compofteac!="increases" & gq2_all_fy2021compofothe!="increases" & gq2_all_fy2021schoolsmeals!="increases" & gq2_all_fy2021condcashtra!="increases" & gq2_all_fy2021studentsuppgra!="increases" & gq2_all_fy2021studentloans!="increases" & gq2_all_fy2021othercurrentexp!="increases")
}


*S7/gq3/Q3.
* logic checking for 'none' & 'dnk' & 'NA'
local gq3 "gq3_all_numberofstudentsclass gq3_all_socioeconomiccharacter gq3_all_geographiccriteria gq3_all_studentswithsen gq3_all_othercriteria"
foreach v of local gq3{
    replace gq3_all_none = "" if `v' !=""
	replace gq3_all_donotknow ="" if  `v' !=""
	replace gq3_all_notapplicable ="" if  `v' !=""
}
* match 'dnk' with OECD (eg. )
local gq3 "gq3_all_numberofstudentsclass gq3_all_socioeconomiccharacter gq3_all_geographiccriteria gq3_all_studentswithsen gq3_all_othercriteria gq3_all_none gq3_all_notapplicable"
foreach v of local gq3{
	replace `v' ="Do not know" if  gq3_all_donotknow !="" & `v' ==""
}
drop gq3_all_donotknow

* marking NA
local gq3 "gq3_all_numberofstudentsclass gq3_all_socioeconomiccharacter gq3_all_geographiccriteria gq3_all_studentswithsen gq3_all_othercriteria gq3_all_none "
foreach v of local gq3{
	replace `v' = "Not applicable" if gq3_all_notapplicable =="Not applicable"
}

* defining missing
tempvar gq3_all

gen `gq3_all' = "Missing" if gq3_all_numberofstudentsclass=="" & gq3_all_socioeconomiccharacter=="" & gq3_all_geographiccriteria=="" & gq3_all_studentswithsen=="" & gq3_all_othercriteria=="" & gq3_all_none=="" & gq3_all_notapplicable=="" 

local gq3 "gq3_all_numberofstudentsclass gq3_all_socioeconomiccharacter gq3_all_geographiccriteria gq3_all_studentswithsen gq3_all_othercriteria gq3_all_none gq3_all_notapplicable"
foreach v of local gq3{
	replace `v' ="999" if `gq3_all' == "Missing"
}


*S7/gq4/Q4.
replace gq4_all_distribution = "999" if gq4_all_distribution ==""


******* Step C - String to numerical (Yes, No, Select all that apply) *******

*S7/gq1/Q1.
* NOTE: When OECD clean the variable make sure they use the same variable name to UNESCO data
foreach i in all pp p ls us {
	foreach j in 2020 2021 {
		replace gq1_`i'_`j' = "1" if gq1_`i'_`j' == "Increased"
		replace gq1_`i'_`j' = "2" if gq1_`i'_`j' == "No changes" | gq1_`i'_`j' == "No changes "
		replace gq1_`i'_`j' = "3" if gq1_`i'_`j' == "Decreased"  | gq1_`i'_`j' == "Decreases"
		replace gq1_`i'_`j' = "4" if gq1_`i'_`j' == "No change in the total amount, but significant changes in the distribution of expenditures"
		replace gq1_`i'_`j' = "5" if gq1_`i'_`j' == "Schools can decide at their own discretion"
		replace gq1_`i'_`j' = "997" if gq1_`i'_`j' == "Do Not Know"
		replace gq1_`i'_`j' = "999" if gq1_`i'_`j' == "999" 

		destring gq1_`i'_`j', replace
	}
}

*S7/gq2/Q2.
local gq2 "gq2_all_fy2020totalcapitalexp gq2_all_fy2020totalcurrentexp gq2_all_fy2020compofteac gq2_all_fy2020compofothe gq2_all_fy2020schoolsmeals gq2_all_fy2020condcashtra gq2_all_fy2020studentsuppgra gq2_all_fy2020studentloans gq2_all_fy2020othercurrentexp gq2_all_fy2021totalcapitalexp gq2_all_fy2021totalcurrentexp gq2_all_fy2021compofteac gq2_all_fy2021compofothe gq2_all_fy2021schoolsmeals gq2_all_fy2021condcashtra gq2_all_fy2021studentsuppgra gq2_all_fy2021studentloans gq2_all_fy2021othercurrentexp"
foreach v of local gq2{
	replace `v' = "1" if `v' =="increases"
	replace `v' = "2" if `v' =="no changes " |`v' =="no changes"
	replace `v' = "3" if `v' =="decreases"
	replace `v' = "999" if `v' =="999"
	
	destring `v', replace
}

*S7/gq2a/Q2a.
local gq2a "gq2a_all_addfundingfromex gq2a_all_reprogofprevious gq2a_all_addallocationfro gq2a_all_reallocwithintheed"
foreach v of local gq2a{
	replace `v' ="999" if `v' == "999"
	replace `v' ="998" if `v' == "NA"
	replace `v' ="997" if `v' == "Do not know"
	replace `v' ="1" if `v' != "" & `v' != "NA" & `v' != "999" & `v' != "998" & `v' != "997"
	replace `v' ="0" if `v' == ""
	destring `v', replace
}

*S7/gq3/Q3.
local gq3 "gq3_all_numberofstudentsclass gq3_all_socioeconomiccharacter gq3_all_geographiccriteria gq3_all_studentswithsen gq3_all_othercriteria gq3_all_none gq3_all_notapplicable "
foreach v of local gq3{
	replace `v' ="999" if `v' == "999"
	replace `v' ="998" if `v' == "Not applicable"
	replace `v' ="997" if `v' == "Do not know"
	replace `v' ="1" if `v' != "" & `v' != "NA" & `v' != "999" & `v' != "998" & `v' != "997"
	replace `v' ="0" if `v' == ""
	destring `v', replace
}

*S7/gq4/Q4.
local gq4 "gq4_all_distribution"
foreach v of local gq4{
	replace `v' ="0" if `v' == "No"
	replace `v' ="1" if `v' == "Yes"
	replace `v' ="997" if `v' == "Do not know"
	replace `v' ="998" if `v' == "Not applicable"
	replace `v' ="999" if `v' == "999"
	destring `v', replace
}

******* Step D - Variable labeling *******

*S7/gq1/Q1.
label define gq1_value 						///
	1 "Increased"						///
	2 "No changes"		///
	3 "Decreased"			///
	4 "No change in the total amount, but significant changes in the distribution of expenditures"		///
	5 "Schools can decide at their own discretion"	 ///
	997 "Do Not Nnow"			///
	998 "Not applicable" ///
	999 "Missing"	 
  
label value gq1_all_2020 gq1_pp_2020 gq1_p_2020 gq1_ls_2020 gq1_us_2020 gq1_all_2021 gq1_pp_2021 gq1_p_2021 gq1_ls_2021 gq1_us_2021 gq1_value

*S7/gq2/Q2.
label define gq2_value 						///
	1 "Increased"						///
	2 "No changes"		///
	3 "Decreased"	///
	5 "Schools/Districts/the most local level of governance could decide at their own discretion" ///
	997 "Do Not Nnow"			///
	998 "Not applicable" ///
	999 "Missing"			
  
label value gq2_all_fy2020totalcapitalexp gq2_all_fy2020totalcurrentexp gq2_all_fy2020compofteac gq2_all_fy2020compofothe gq2_all_fy2020schoolsmeals gq2_all_fy2020condcashtra gq2_all_fy2020studentsuppgra gq2_all_fy2020studentloans gq2_all_fy2020othercurrentexp gq2_all_fy2021totalcapitalexp gq2_all_fy2021totalcurrentexp gq2_all_fy2021compofteac gq2_all_fy2021compofothe gq2_all_fy2021schoolsmeals gq2_all_fy2021condcashtra gq2_all_fy2021studentsuppgra gq2_all_fy2021studentloans gq2_all_fy2021othercurrentexp gq2_value

*S7/gq2a/Q2a.
label define gq2a_value 						///
	0 "No"			///
	1 "Yes"		///
	997 "Do not know" ///
	998 "Not applicable" ///
	999 "Missing"				
  
label value gq2a_all_addfundingfromex gq2a_all_reprogofprevious gq2a_all_addallocationfro gq2a_all_reallocwithintheed gq2a_value

*S7/gq3/Q3.
label define gq3_value 						///
	0 "No"			///
	1 "Yes"		///
	997 "Do not know" ///
	998 "Not applicable" ///
	999 "Missing"				
  
label value gq3_all_numberofstudentsclass gq3_all_socioeconomiccharacter gq3_all_geographiccriteria gq3_all_studentswithsen gq3_all_othercriteria gq3_all_none gq3_all_notapplicable gq3_value

*S7/gq4/Q4.
label define gq4_value 						///
	0 "No"			///
	1 "Yes"		///
	997 "Do not know" ///
	998 "Not applicable" ///
	999 "Missing"			
  
label value gq4_all_distribution gq4_value

******* Step F - Open section to clean specific interested questions *******



*---------------------------------------------------------------------------
* Section 8. Locus of Decision Making
*---------------------------------------------------------------------------
*QUESTIONS IN THIS SECTION:

*S8/hq1/Q1.At what level were the following decisions made in public primary and lower secondary educational institutions during the pandemic? [Select all that apply]

******* Step E - Data cleaning *******

*S8/hq1/Q1.
tempvar hq1_all_school hq1_all_adjustments hq1_all_resources hq1_all_addsup hq1_all_workingreq  hq1_all_compensation hq1_all_hygiene hq1_all_changes 

gen `hq1_all_school' = "Missing" if hq1_all_schoolcentral =="" & hq1_all_schoolprovincial=="" & hq1_all_schoolsubreg=="" & hq1_all_schoollocal=="" & hq1_all_schoolschool=="" 
local hq1_school "hq1_all_schoolcentral hq1_all_schoolprovincial hq1_all_schoolsubreg hq1_all_schoollocal hq1_all_schoolschool"
foreach v of local hq1_school{
	replace `v' ="999" if `hq1_all_school' == "Missing"
}

gen `hq1_all_adjustments' = "Missing" if hq1_all_adjustmentscentral =="" & hq1_all_adjustmentsprovincial=="" & hq1_all_adjustmentssubreg=="" & hq1_all_adjustmentslocal=="" & hq1_all_adjustmentsschool=="" 
local hq1_adjustments "hq1_all_adjustmentscentral hq1_all_adjustmentsprovincial hq1_all_adjustmentssubreg hq1_all_adjustmentslocal hq1_all_adjustmentsschool"
foreach v of local hq1_adjustments{
	replace `v' ="999" if `hq1_all_adjustments' == "Missing"
}

gen `hq1_all_resources' = "Missing" if hq1_all_resourcescentral =="" & hq1_all_resourcesprovincial=="" & hq1_all_resourcessubreg=="" & hq1_all_resourceslocal=="" & hq1_all_resourcesschool=="" 
local hq1_resources "hq1_all_resourcescentral hq1_all_resourcesprovincial hq1_all_resourcessubreg hq1_all_resourceslocal hq1_all_resourcesschool"
foreach v of local hq1_resources{
	replace `v' ="999" if `hq1_all_resources' == "Missing"
}

gen `hq1_all_addsup' = "Missing" if hq1_all_addsupcentral =="" & hq1_all_addsupprovincial=="" & hq1_all_addsupsubreg=="" & hq1_all_addsuplocal=="" & hq1_all_addsupschool=="" 
local hq1_addsup "hq1_all_addsupcentral hq1_all_addsupprovincial hq1_all_addsupsubreg hq1_all_addsuplocal hq1_all_addsupschool"
foreach v of local hq1_addsup{
	replace `v' ="999" if `hq1_all_addsup' == "Missing"
}

gen `hq1_all_workingreq' = "Missing" if hq1_all_workingreqcentral =="" & hq1_all_workingreqprovincial=="" & hq1_all_workingreqsubreg=="" & hq1_all_workingreqlocal=="" & hq1_all_workingreqschool=="" 
local hq1_workingreq "hq1_all_workingreqcentral hq1_all_workingreqprovincial hq1_all_workingreqsubreg hq1_all_workingreqlocal hq1_all_workingreqschool"
foreach v of local hq1_workingreq{
	replace `v' ="999" if `hq1_all_workingreq' == "Missing"
}

gen `hq1_all_compensation' = "Missing" if hq1_all_compensationcentral =="" & hq1_all_compensationprovincial=="" & hq1_all_compensationsubreg=="" & hq1_all_compensationlocal=="" & hq1_all_compensationschool=="" 
local hq1_compensation "hq1_all_compensationcentral hq1_all_compensationprovincial hq1_all_compensationsubreg hq1_all_compensationlocal hq1_all_compensationschool"
foreach v of local hq1_compensation{
	replace `v' ="999" if `hq1_all_compensation' == "Missing"
}

gen `hq1_all_hygiene' = "Missing" if hq1_all_hygienecentral =="" & hq1_all_hygieneprovincial=="" & hq1_all_hygienesubreg=="" & hq1_all_hygienelocal=="" & hq1_all_hygieneschool=="" 
local hq1_hygiene "hq1_all_hygienecentral hq1_all_hygieneprovincial hq1_all_hygienesubreg hq1_all_hygienelocal hq1_all_hygieneschool"
foreach v of local hq1_hygiene{
	replace `v' ="999" if `hq1_all_hygiene' == "Missing"
}

gen `hq1_all_changes' = "Missing" if hq1_all_changescentral =="" & hq1_all_changesprovincial=="" & hq1_all_changessubreg=="" & hq1_all_changeslocal=="" & hq1_all_changesschool=="" 
local hq1_changes "hq1_all_changescentral hq1_all_changesprovincial hq1_all_changessubreg hq1_all_changeslocal hq1_all_changesschool"
foreach v of local hq1_changes{
	replace `v' ="999" if `hq1_all_changes' == "Missing"
}

******* Step C - String to numerical (Yes, No, Select all that apply *******

*S8/hq1/Q1.
local hq1 "hq1_all_schoolcentral hq1_all_schoolprovincial hq1_all_schoolsubreg hq1_all_schoollocal hq1_all_schoolschool hq1_all_adjustmentscentral hq1_all_adjustmentsprovincial hq1_all_adjustmentssubreg hq1_all_adjustmentslocal hq1_all_adjustmentsschool hq1_all_resourcescentral hq1_all_resourcesprovincial hq1_all_resourcessubreg hq1_all_resourceslocal hq1_all_resourcesschool hq1_all_addsupcentral hq1_all_addsupprovincial hq1_all_addsupsubreg hq1_all_addsuplocal hq1_all_addsupschool hq1_all_workingreqcentral hq1_all_workingreqprovincial hq1_all_workingreqsubreg hq1_all_workingreqlocal hq1_all_workingreqschool hq1_all_compensationcentral hq1_all_compensationprovincial hq1_all_compensationsubreg hq1_all_compensationlocal hq1_all_compensationschool hq1_all_hygienecentral hq1_all_hygieneprovincial hq1_all_hygienesubreg hq1_all_hygienelocal hq1_all_hygieneschool hq1_all_changescentral hq1_all_changesprovincial hq1_all_changessubreg hq1_all_changeslocal hq1_all_changesschool"
foreach v of local hq1{
	replace `v' ="999" if `v' == "999"
	replace `v' ="1" if `v' != ""
  *replace `v' ="999" if `v' == ""?
	replace `v' ="0" if `v' == ""
	destring `v', replace
}

******* Step D - Variable labeling *******

*S8/hq1/Q1.
label define hq1_value 						///
	0 "No"			///
	1 "Yes"		///
	997 "Do not know" ///
	998 "Not applicable" ///
	999 "Missing"	
		
label value hq1_all_schoolcentral hq1_all_schoolprovincial hq1_all_schoolsubreg hq1_all_schoollocal hq1_all_schoolschool hq1_all_adjustmentscentral hq1_all_adjustmentsprovincial hq1_all_adjustmentssubreg hq1_all_adjustmentslocal hq1_all_adjustmentsschool hq1_all_resourcescentral hq1_all_resourcesprovincial hq1_all_resourcessubreg hq1_all_resourceslocal hq1_all_resourcesschool hq1_all_addsupcentral hq1_all_addsupprovincial hq1_all_addsupsubreg hq1_all_addsuplocal hq1_all_addsupschool hq1_all_workingreqcentral hq1_all_workingreqprovincial hq1_all_workingreqsubreg hq1_all_workingreqlocal hq1_all_workingreqschool hq1_all_compensationcentral hq1_all_compensationprovincial hq1_all_compensationsubreg hq1_all_compensationlocal hq1_all_compensationschool hq1_all_hygienecentral hq1_all_hygieneprovincial hq1_all_hygienesubreg hq1_all_hygienelocal hq1_all_hygieneschool hq1_all_changescentral hq1_all_changesprovincial hq1_all_changessubreg hq1_all_changeslocal hq1_all_changesschool hq1_value

******* Step F - Open section to clean specific interested questions *******




*---------------------------------------------------------------------------
* Section 9. Equity Module
*---------------------------------------------------------------------------
*QUESTIONS IN THIS SECTION:

*S9/iq1/Q1. Do government-dependent private schools (ISCED 0 to ISCED 3) follow the same COVID regulations as public schools?
*S9/iq1a/Q1.A If the answer is ‘no’, are there some regulations that equally apply to government-dependent private and public schools? (Select all that apply)
*S9/iq2/Q2. Do independent private schools (ISCED 0 to ISCED 3) follow the same COVID regulations as public schools?
*S9/iq2a/Q2.A If the answer is ‘no’, are there some regulations that equally apply to independent private and public schools? (Select all that apply)
*S9/iq3/Q3. Which of the following measures have been taken to support the education (ISCED 0 to ISCED 3) of vulnerable groups during the pandemic?
*S9/iq4/Q4.  What outreach / support measures have been taken to encourage the return to school for vulnerable populations (ISCED 0 to ISCED 3)? [Select all that apply] 

******* Step C - String to numerical (Yes, No, Select all that apply *******

* s9/iq1/Q1. 
replace iq1_all_follow = "1" if iq1_all_follow == "Yes"
replace iq1_all_follow = "0" if iq1_all_follow == "No"
replace iq1_all_follow = "997" if iq1_all_follow == "Do not know"
replace iq1_all_follow = "999" if iq1_all_follow == ""
destring iq1_all_follow, replace


* s9/iq1a/Q1.A 
foreach i in planclosereopen healthsafestandard mandatoryattend distancelearnmod other {
	replace iq1a_all_`i' = "1" if iq1a_all_`i' != ""
	replace iq1a_all_`i' = "0" if iq1a_all_`i' == ""
	destring iq1a_all_`i', replace
	}

	
* s9/iq2/Q2. 
replace iq2_all_follow = "1" if iq2_all_follow == "Yes"
replace iq2_all_follow = "0" if iq2_all_follow == "No"
replace iq2_all_follow = "997" if iq2_all_follow == "Do not know"
replace iq2_all_follow = "999" if iq2_all_follow == ""
destring iq2_all_follow, replace


* s9/iq2a/Q2.A 
foreach i in planclosereopen healthsafestandard mandatoryattend distancelearnmod other {
	replace iq2a_all_`i' = "1" if iq2a_all_`i' != ""
	replace iq2a_all_`i' = "0" if iq2a_all_`i' == ""
	destring iq2a_all_`i', replace
	}

*S9/iq3/Q3. 
foreach i in addfinance specialeffort subsdevice tailorlearn flexible donotknow none other {
	foreach j in children refugees ethnic girls other {
		replace iq3_all_`i'`j' = "1" if iq3_all_`i'`j' != ""
		replace iq3_all_`i'`j' = "0" if iq3_all_`i'`j' == ""
		destring iq3_all_`i'`j', replace
	}
}

*S9/iq4/Q4.  
rename iq4_all_provofficialrefugee iq4_all_provofficialrefugees
foreach i in com provofficial schoolbased reviewing makemod donotknow none other {
	foreach j in children refugees ethnic girls other {
		replace iq4_all_`i'`j' = "1" if iq4_all_`i'`j' != ""
  		replace iq4_all_`i'`j' = "0" if iq4_all_`i'`j' == ""
		destring iq4_all_`i'`j', replace
	}
}

******* Step D - Variable labeling *******

*S9/iq1/Q1.
label def iq1_val	///
		1 "Yes" 	///
		0 "No"  	///
		997 "Don't know" ///
		998 "Not applicable" ///
		999 "Missing"
label val iq1_all_follow iq1_val

*S9/iq1a/Q1A.
label val iq1a_all_* iq1_val

*S9/iq2/Q2.
label val iq2_all_follow iq1_val

*S9/iq2a/Q2A.
label value iq2a_all_planclosereopen iq2a_all_healthsafestandard iq2a_all_mandatoryattend iq2a_all_distancelearnmod iq2a_all_other iq1_val

*S9/iq3/Q3.
label def iq3_val	///
		1 "Yes" 	///
		0 "No"  	///
		997 "Don't know" ///
		998 "Not applicable" ///
		999 "Missing"
cap noi: label value iq3* iq3_val

*S9/iq4/Q4.
cap noi: label value iq4* iq3_val


******* Step E - Data cleaning *******

* Cleaning Missing: Countries with zero for all are considered as missing
*S9/iq1a/Q1A.
gen iq1a_missing = (iq1a_all_planclosereopen + iq1a_all_healthsafestandard + iq1a_all_mandatoryattend + iq1a_all_distancelearnmod + iq1a_all_other == 0)

foreach i in planclosereopen healthsafestandard mandatoryattend distancelearnmod other {
	replace iq1a_all_`i' = 999 if iq1a_missing == 1
}

*logic check: variable iq1a exists if iq1 is 0/no
foreach i of varlist iq1a_all_planclosereopen iq1a_all_healthsafestandard iq1a_all_mandatoryattend iq1a_all_distancelearnmod iq1a_all_other {
   replace `i' = 998 if  iq1_all_follow  !=0 
}


*S9/iq2a/Q2A.
gen iq2a_missing = (iq2a_all_planclosereopen + iq2a_all_healthsafestandard + iq2a_all_mandatoryattend + iq2a_all_distancelearnmod + iq2a_all_other == 0)

foreach i in planclosereopen healthsafestandard mandatoryattend distancelearnmod other {
	replace iq2a_all_`i' = 999 if iq2a_missing == 1
}

foreach i of varlist iq2a_all_planclosereopen iq2a_all_healthsafestandard iq2a_all_mandatoryattend iq2a_all_distancelearnmod iq2a_all_other {
    replace `i' = 998 if iq2_all_follow != 0
	
}


*S9/iq3/Q3. 
foreach j in children refugees ethnic girls other {
		gen iq3_all_`j'miss = (iq3_all_addfinance`j' + iq3_all_specialeffort`j' + iq3_all_subsdevice`j' + iq3_all_tailorlearn`j' + iq3_all_flexible`j' + iq3_all_donotknow`j' + iq3_all_none`j' + iq3_all_other`j' == 0)
	    foreach i in addfinance specialeffort subsdevice tailorlearn flexible donotknow none other {
			replace iq3_all_`i'`j' = 999 if iq3_all_`j'miss == 1
	}
}

*Logic check: replacing none to 0 if one of the measures is selected
foreach j in children refugees ethnic girls other {
	foreach i in addfinance specialeffort subsdevice tailorlearn flexible donotknow other {
		replace iq3_all_none`j' = 0 if iq3_all_`i'`j' == 1
	}
}


*S9/iq4/Q4. 
foreach j in children refugees ethnic girls other {
		gen iq4_all_`j'miss = (iq4_all_com`j' + iq4_all_provofficial`j' + iq4_all_schoolbased`j' + iq4_all_reviewing`j' + iq4_all_makemod`j' + iq4_all_donotknow`j' + iq4_all_none`j' + iq4_all_other`j' == 0)
	    foreach i in com provofficial schoolbased reviewing makemod donotknow none other {
			replace iq4_all_`i'`j' = 999 if iq4_all_`j'miss == 1
	}
}

*Logic check: replacing none to 0 if one of the measures is selected
foreach j in children refugees ethnic girls other {
	foreach i in com provofficial schoolbased reviewing makemod donotknow other {
		replace iq4_all_none`j' = 0 if iq4_all_`i'`j' == 1
	}
}

* Needs to be all zero: If countries chose none: the other answer has to be zero
foreach i in children refugees ethnic girls other {
sum iq4_all_com`i' iq4_all_provofficial`i' iq4_all_schoolbased`i' iq4_all_reviewing`i' iq4_all_makemod`i' iq4_all_donotknow`i' iq4_all_other`i'  if iq4_all_none`i'==1
}

******* Step F - Open section to clean specific interested questions *******



*---------------------------------------------------------------------------
* Section 11. Health Protocol/Guidelines for Prevention and Control of COVID-19
*---------------------------------------------------------------------------
*QUESTIONS IN THIS SECTION:

*S11/kq1/Q1. Has the Ministry of Education produced or endorsed any specific health and hygiene guidelines and measures for schools?
*S11/kq2/Q2. What do these guidelines cover? [Select all that apply]  (<< If question 1 = Yes) 
*S11/kq2a/Q2A. How is the application of these guidelines monitored? [select all that apply] 
*S11/kq2b/Q2B. If monitoring information is available, what proportion of schools or other educational institutions are implementing the health and hygiene guidelines?
*S11/kq2c/Q2C. What are the challenges and bottlenecks faced in implementing the specific measures? (Select all that apply) 
*S11/kq3/Q3. Are there enough resources, commodities (e.g. soap, masks) and infrastructure (e.g. clean water, WASH facilities) to assure the safety of learners and all school staff? 
*S11/kq3a/Q3a. How are the resources for the safety of learners and school staff funded? [Select all that apply] 
*S11/kq4/Q4. Which of the following measures to ensure the health and safety of students/learners on their journey to and from school are included in school reopening plans / are being implemented as schools reopen? [Select all that apply] 
*S11/kq5/Q5. Have any measures been taken to minimize the impact of school closures on the wellbeing of students? Please select all the measures that apply

******* Step C - String to numerical (Yes, No, Select all that apply) *******

*S11/kq1/Q1. 
	replace kq1 = "1" if kq1 == "Yes"
	replace kq1 = "0" if kq1 == "No"
	replace kq1 = "998" if kq1 == "Not applicable, as the responsibility for health and sanitation guidelines falls under other administrative units"
	replace kq1 = "997" if kq1 == "Do not know"
	replace kq1 = "999" if kq1 == ""
	destring kq1, replace

*S11/kq2/Q2.
		* 1. Replace to 999 if none of the choices is selected
			replace kq2promotingphysicaldistancing= "999" if (kq2promotingphysicaldistancing=="" &  kq2promotinghandwashingpracti=="" & kq2promotinggoodrespiratoryhy=="" & ///
			kq2improvedhandwashingfaciliti=="" & kq2increasedsurfacefoodprepa=="" & kq2improvedmanagementofinfect=="" & kq2selfisolationofstaffands=="" & ///
			kq2temperaturechecksinschool=="" & kq2testingforcovid19inschoo=="" & kq2trackingstaffandstudentsw=="" & kq2selfscreeningformapp_=="" & kq2other_=="")

			foreach i in promotinghandwashingpracti promotinggoodrespiratoryhy improvedhandwashingfaciliti ///
			increasedsurfacefoodprepa improvedmanagementofinfect selfisolationofstaffands temperaturechecksinschool testingforcovid19inschoo /// 
			trackingstaffandstudentsw selfscreeningformapp_ other_ {
			
			replace kq2`i' = "999" if kq2promotingphysicaldistancing=="999"
			}
			
		* 2. Recode		
		foreach j in promotingphysicaldistancing promotinghandwashingpracti promotinggoodrespiratoryhy improvedhandwashingfaciliti ///
			increasedsurfacefoodprepa improvedmanagementofinfect selfisolationofstaffands temperaturechecksinschool testingforcovid19inschoo /// 
			trackingstaffandstudentsw selfscreeningformapp_ other_ {
				
			replace kq2`j' = "1" if kq2`j' != "" & kq2`j'!= "999" 
			replace kq2`j' = "0" if kq2`j' == ""
			destring kq2`j', replace
}
		
*S11/kq2a/Q2A. 
		
		* 1. Replace to 999 if none of the choices is selected
			replace kq2anationalorsubnationalsurv= "999" if (kq2anationalorsubnationalsurv=="" & kq2ainspectionsbynationalors=="" & ///
			kq2ainspectionsbylocaleducati=="" & kq2athroughaschoollevelcommi=="" & kq2aotherpleasespecify_== "" & kq2anomonitoringoftheapplica=="")

			foreach i in nationalorsubnationalsurv inspectionsbynationalors inspectionsbylocaleducati throughaschoollevelcommi ///
			otherpleasespecify_ nomonitoringoftheapplica {
			
			replace kq2a`i' = "999" if kq2anationalorsubnationalsurv=="999"
			}
		
		* 2. Recode	
		foreach j in nationalorsubnationalsurv inspectionsbynationalors inspectionsbylocaleducati throughaschoollevelcommi ///
		otherpleasespecify_ nomonitoringoftheapplica {
			replace kq2a`j' = "1" if kq2a`j' != "" & kq2a`j'!= "999" 
			replace kq2a`j' = "0" if kq2a`j' == ""
			destring kq2a`j', replace
		}
		
*S11/kq2b/Q2B.
		
		replace kq2b = "1" if kq2b == "Less than 25%"
		replace kq2b = "2" if kq2b == "More than 25% but less than 50%Around half of the schools"
		replace kq2b = "3" if kq2b == "Around half of the schools"
		replace kq2b = "4" if kq2b == "More than 50% but less than 75%"
		replace kq2b = "5" if kq2b == "More than 75% but not all of the schools"
		replace kq2b = "6" if kq2b == "All of the schools"
		replace kq2b = "997" if kq2b == "unknown/not monitored. "
		replace kq2b = "998" if kq2b == "Not Applicable"
		replace kq2b = "999" if kq2b == ""
		destring kq2b, replace 

*S11/kq2c/Q2C. 
	
		* 1. Replace to 999 if none of the choices is selected
			replace kq2clackofsafetycommitmentfr= "999" if kq2clackofsafetycommitmentfr =="" & kq2cpoorsafetyculture_=="" & kq2clackofadministrativecommi=="" & ///
			kq2clackofstrictenforcemento=="" & kq2clackofresourcesforimplem=="" & kq2clackofmedicalfacilitiesa=="" & kq2clackofdoortodoorservice=="" & ///
			kq2clackofpropercommunication=="" & kq2clackofgovernmentpolicies_=="" & kq2cpublicstigmatization_=="" & kq2cdonotknow_=="" & kq2cotherpleasespecify_==""

			foreach i in kq2cpoorsafetyculture_ kq2clackofadministrativecommi kq2clackofstrictenforcemento ///
			kq2clackofresourcesforimplem kq2clackofmedicalfacilitiesa kq2clackofdoortodoorservice kq2clackofpropercommunication ///
			kq2clackofgovernmentpolicies_ kq2cpublicstigmatization_ kq2cdonotknow_ kq2cotherpleasespecify_ {
				
				replace `i' = "999" if kq2clackofsafetycommitmentfr=="999"
				}
					
		* 2. Recode
		foreach j in kq2clackofsafetycommitmentfr kq2cpoorsafetyculture_ kq2clackofadministrativecommi kq2clackofstrictenforcemento ///
		kq2clackofresourcesforimplem kq2clackofmedicalfacilitiesa kq2clackofdoortodoorservice kq2clackofpropercommunication ///
		kq2clackofgovernmentpolicies_ kq2cpublicstigmatization_ kq2cdonotknow_ kq2cotherpleasespecify_ {
			replace `j' = "1" if `j' != "" & `j'!= "999" 
			replace `j' = "0" if `j' == ""
			destring `j', replace
		}

*S11/kq3/Q3. 
replace kq3 = "1" if kq3 == "Yes   "
replace kq3 = "0" if kq3 == "No "
replace kq3 = "997" if kq3 == "Do not know"
replace kq3 = "999" if kq3 == ""
destring kq3, replace

*S11/kq3a/Q3a. 

		* 1. Replace to 999 if none of the choices is selected
			replace kq3aexternaldonors= "999" if kq3aexternaldonors=="" & kq3aadditionalallocationfromt=="" & kq3areallocationwithineducatio=="" & ///
			kq3areallocationofthegovernme=="" & kq3adonotknow=="" & kq3aotherpleasespecify==""

			foreach i in kq3aadditionalallocationfromt kq3areallocationwithineducatio kq3areallocationofthegovernme kq3adonotknow kq3aotherpleasespecify {	
			replace `i' = "999" if kq3aexternaldonors=="999"
				}

		*2. Recode
			foreach j in kq3aexternaldonors kq3aadditionalallocationfromt kq3areallocationwithineducatio kq3areallocationofthegovernme kq3adonotknow kq3aotherpleasespecify {
				replace `j' = "1" if `j' != "" & `j'!= "999" 
				replace `j' = "0" if `j' == ""
				destring `j', replace
			}
			
*S11/kq4/Q4.  

		* 1. Replace to 999 if none of the choices is selected
			replace kq4engagetheentireschoolcomm= "999" if kq4engagetheentireschoolcomm=="" & kq4ensurephysicaldistancingdu=="" & kq4prioritizeactivenonmotori=="" & ///
			kq4makeitsafetowalkcycle=="" & kq4helpstudentswhocycleands=="" & kq4reduceprivatevehicleuse=="" & kq4treatschoolbusesasextensi=="" & kq4promotesafetyandhygieneon=="" & ///
			kq4ensureequalaccessonthejo=="" & kq4noneoftheabovemeasures=="" & kq4donotknow==""

			foreach i in kq4ensurephysicaldistancingdu kq4prioritizeactivenonmotori kq4makeitsafetowalkcycle ///
			kq4helpstudentswhocycleands kq4reduceprivatevehicleuse kq4treatschoolbusesasextensi kq4promotesafetyandhygieneon ///
			kq4ensureequalaccessonthejo kq4noneoftheabovemeasures kq4donotknow {	
			replace `i' = "999" if kq4engagetheentireschoolcomm=="999"
				}

		*2. Recode
			foreach j in kq4engagetheentireschoolcomm kq4ensurephysicaldistancingdu kq4prioritizeactivenonmotori kq4makeitsafetowalkcycle ///
			kq4helpstudentswhocycleands kq4reduceprivatevehicleuse kq4treatschoolbusesasextensi kq4promotesafetyandhygieneon ///
			kq4ensureequalaccessonthejo kq4noneoftheabovemeasures kq4donotknow {
				replace `j' = "1" if `j' != "" & `j'!= "999" 
				replace `j' = "0" if `j' == ""
				destring `j', replace
			}
			
*S11/kq5/Q5. 
		
		* 1. Replace to 999 if none of the choices is selected
			replace kq5_psychosocial= "999" if kq5_psychosocial=="" & kq5_additional=="" & kq5_supporttocounter=="" & kq5_regularcall=="" & ///
			kq5_nomeasures=="" & kq5_donotknow=="" & kq5_other==""

			foreach i in kq5_additional kq5_supporttocounter kq5_regularcall kq5_nomeasures kq5_donotknow kq5_other {	
			replace `i' = "999" if kq5_psychosocial=="999"
				}
		
		*2. Recode
			foreach j in kq5_psychosocial kq5_additional kq5_supporttocounter kq5_regularcall kq5_nomeasures kq5_donotknow kq5_other {
			replace `j' = "1" if `j' != "" & `j'!= "999" 
			replace `j' = "0" if `j' == ""
			destring `j', replace
		}	
		
******* Step D - Variable labeling *******

*S11/kq1/Q1. *S11/kq2a/Q2A. *S11/kq2c/Q2C. *S11/kq3/Q3. 

label define kq1_value 						///
	0 "No"			///
	1 "Yes"		///
	997 "Do not know" ///
	998 "Not applicable" ///
	999 "Missing"	
	
label value kq1 kq1_value
label value kq2anationalorsubnationalsurv kq2ainspectionsbynationalors kq2ainspectionsbylocaleducati kq2athroughaschoollevelcommi ///
kq2aotherpleasespecify_ kq2anomonitoringoftheapplica kq1_value
label value kq2clackofsafetycommitmentfr kq2cpoorsafetyculture_ kq2clackofadministrativecommi kq2clackofstrictenforcemento kq2clackofresourcesforimplem ///
kq2clackofmedicalfacilitiesa kq2clackofdoortodoorservice kq2clackofpropercommunication kq2clackofgovernmentpolicies_ kq2cpublicstigmatization_ kq2cdonotknow_ kq2cotherpleasespecify_ kq1_value
label value kq3 kq1_value

*S11/kq2/Q2. & *S11/kq3a/Q3a. & *S11/kq4/Q4.  
label define kq2_value 		///
	0 "No"					///
	1 "Yes"					///
	999 "Missing"	
	label value kq2promoting* kq2improvedhandwashingfaciliti* kq2increasedsurfacefoodprepa kq2improvedmanagementofinfect kq2selfisolationofstaffands ///
	kq2temperaturechecksinschool kq2testingforcovid19inschoo kq2trackingstaffandstudentsw kq2selfscreeningformapp_ kq2other_ kq2_value
	label value kq3aexternaldonors kq3aadditionalallocationfromt kq3areallocationwithineducatio kq3areallocationofthegovernme kq3adonotknow kq3aotherpleasespecify kq2_value
	label value kq4* kq2_value
	label value kq5_psychosocial kq5_additional kq5_supporttocounter kq5_regularcall kq5_nomeasures kq5_donotknow kq5_other kq2_value
	
*S11/kq2b/Q2B.
	label define kq2b_value 					///
		1 "Less than 25 %"						///
		2 "More than 25% but less than 50%"		///
		3 "About half of the sschools"			///
		4 "More than 50% but less than 75%"		///
		5 "More than 75% but not all of the schools"	 ///
		6 "All of the schools"					///
		997 "Do not know/Not monitored"			///
		998 "Not applicable"					///
		999 "Missing"

	label value kq2b kq2b_value



*S11/kq5/Q5.


******* Step E - Data cleaning *******
	
*S11/kq2/Q2. What do these guidelines cover? [Select all that apply]  (<< If question 1 = Yes) 
		replace kq1=1 if (kq2promotingphysicaldistancing==1 | kq2promotinghandwashingpracti==1 | kq2promotinggoodrespiratoryhy==1 |  ///
		kq2improvedhandwashingfaciliti==1 |  kq2increasedsurfacefoodprepa==1 | kq2improvedmanagementofinfect==1 |  kq2selfisolationofstaffands==1 | ///
		kq2temperaturechecksinschool==1 | kq2testingforcovid19inschoo==1 | kq2trackingstaffandstudentsw==1 | kq2selfscreeningformapp_==1 | kq2other_==1)
	// changing value of kq1 if any of the guidelines selected in kq2
	
*S11/kq2a/Q2a. How is the application of these guidelines monitored? [select all that apply] 
		replace kq2anomonitoringoftheapplica=0 if (kq2anationalorsubnationalsurv==1 | kq2ainspectionsbynationalors==1 | kq2ainspectionsbylocaleducati==1 | ///
		kq2athroughaschoollevelcommi==1 | kq2aotherpleasespecify_==1)
	// changing value of kq2a no monitoring if any of the methods selected in kq2a
	
	foreach j in kq2anationalorsubnationalsurv kq2ainspectionsbylocaleducati kq2athroughaschoollevelcommi kq2aotherpleasespecify_ {
	    replace `j'=998 if (kq2promotingphysicaldistancing==999 & kq2promotinghandwashingpracti==999 & kq2promotinggoodrespiratoryhy==999 & ///
		kq2improvedhandwashingfaciliti==999 & kq2increasedsurfacefoodprepa==999 & kq2improvedmanagementofinfect==999 & kq2selfisolationofstaffands==999 & ///
		kq2temperaturechecksinschool==999 & kq2testingforcovid19inschoo==999 & kq2trackingstaffandstudentsw==999 & kq2selfscreeningformapp_==999 & kq2other_==999) 
	}
	// changing value of kq2a (monitoring of guidelines) to not applicable if no guidelines selected in Q2
	
*S11/kq2c/Q2C. What are the challenges and bottlenecks faced in implementing the specific measures? (Select all that apply) 
		replace kq2cdonotknow_ =0 if (kq2clackofsafetycommitmentfr ==1 | kq2cpoorsafetyculture_==1 | kq2clackofadministrativecommi ==1 | ///
		kq2clackofstrictenforcemento ==1 | kq2clackofresourcesforimplem ==1 | kq2clackofmedicalfacilitiesa ==1 | kq2clackofdoortodoorservice ==1 | ///
		kq2clackofpropercommunication ==1 | kq2clackofgovernmentpolicies_ ==1 | kq2cpublicstigmatization_ ==1 | kq2cotherpleasespecify_ ==1)
		// replacing dont know to 0 if any of the other choices selected
		
		foreach j in kq2clackofadministrativecommi kq2clackofdoortodoorservice kq2clackofgovernmentpolicies_ kq2clackofmedicalfacilitiesa kq2clackofpropercommunication  ///
		kq2clackofresourcesforimplem kq2clackofsafetycommitmentfr kq2clackofstrictenforcemento kq2cotherpleasespecify_ kq2cpoorsafetyculture_ kq2cpublicstigmatization_ {
			replace `j'=998 if (kq2promotingphysicaldistancing==999 & kq2promotinghandwashingpracti==999 & kq2promotinggoodrespiratoryhy==999 & ///
			kq2improvedhandwashingfaciliti==999 & kq2increasedsurfacefoodprepa==999 & kq2improvedmanagementofinfect==999 & kq2selfisolationofstaffands==999 & ///
			kq2temperaturechecksinschool==999 & kq2testingforcovid19inschoo==999 & kq2trackingstaffandstudentsw==999 & kq2selfscreeningformapp_==999 & kq2other_==999)
	}
		// changing value of kq2c (implementation challenge faced) to not applicable if no guidelines selected in Q2

*S11/kq4/Q4. Which of the following measures to ensure the health and safety of students/learners on their journey to and from school are included in school reopening plans 
	*are being implemented as schools reopen? [Select all that apply]  
		replace kq4noneoftheabovemeasures=0 if kq4engagetheentireschoolcomm==1 | kq4ensurephysicaldistancingdu==1 | kq4prioritizeactivenonmotori==1 | ///
		kq4makeitsafetowalkcycle==1 | kq4helpstudentswhocycleands==1 | kq4reduceprivatevehicleuse==1 | kq4treatschoolbusesasextensi==1 | ///
		kq4promotesafetyandhygieneon==1 | kq4ensureequalaccessonthejo==1 | kq4donotknow==1
		
		replace kq4donotknow=0 if kq4engagetheentireschoolcomm==1 | kq4ensurephysicaldistancingdu==1 | kq4prioritizeactivenonmotori==1 | ///
		kq4makeitsafetowalkcycle==1 | kq4helpstudentswhocycleands==1 | kq4reduceprivatevehicleuse==1 | kq4treatschoolbusesasextensi==1 | ///
		kq4promotesafetyandhygieneon==1 | kq4ensureequalaccessonthejo==1 
		// replacing none/ dont know to 0 if one of the other measures is selected
		
*S11/kq5/Q5. Have any measures been taken to minimize the impact of school closures on the wellbeing of students? Please select all the measures that apply
		replace kq5_nomeasures=0 if kq5_psychosocial==1 | kq5_additional ==1 | kq5_supporttocounter==1 | ///
		kq5_regularcall==1 | kq5_donotknow==1 | kq5_other==1 
		
		replace kq5_donotknow=0 if kq5_psychosocial==1 | kq5_additional ==1 | kq5_supporttocounter==1 | ///
		kq5_regularcall==1 | kq5_other==1
		// replacing none/ dont know to 0 if one of the measures is selected

******* Step F - Open section to clean specific interested questions *******



*---------------------------------------------------------------------------
* Section 12. 2021 Planning
*---------------------------------------------------------------------------
*QUESTIONS IN THIS SECTION:

*S12/lq1/Q1. Has the government defined specific criteria or rules for deciding if schools should close again? [Yes; No; Do not know; This has been left to the discretion of local or school leaders]
*S12/lq1a/Q1.A If yes, what specific criteria help determine if schools should close again? (Select all that apply) [national prevalence rates; local prevalence rates; in-school outbreak; other, please specify]
*S12/lq2/Q2. Which measures have been/will be taken to facilitate access to connectivity of students to online distance learning infrastructure in 2021 or beyond? [Offer/negotiate access to internet at subsidized or zero cost; Subsidized/free devices for access; No measures taken; Other (please specify); Do not know] [nation-wide; by region; school-by-school basis] 
*S12/lq3/Q3. Were or will new non-teacher educational personnel (e.g. counselors, psychologists, IT personnel, administrative staff, cleaning staff, cooks etc.) being recruited for school re-opening / 2021? [Yes (If so, please answer Question 3.A); No; Do not know]
*S12/lq4/Q4. Please specify and estimation of the number of students (or % of students) who will be assessed to evaluate loss of learning during school closure: 
*S12/lq5/Q5. Has your country planned any new training programmes or activities for laborers (broader workforce) affected in response to the COVID-19 pandemic? (select all that apply) 
*S12/lq6/Q6. Has your country planned any survey on national stakeholders on the impacts and responses to Covid-19 to strengthen education response efforts? 

******* Step C - String to numerical (Yes, No, Select all that apply) *******

*S12/lq1/Q1. 
replace lq1 = ustrtrim(lq1) 
replace lq1 = "997" if lq1 == "" | lq1 == "Do not know" 
replace lq1 = "0" if lq1 == "No" 
replace lq1 = "1" if lq1 == "Yes" 
replace lq1 = "2" if lq1 == "This has been left to the discretion of local or school leaders" 
destring lq1, replace

*S12/lq1a/Q1A.
foreach i in nationalprevalencerates localprevalencerates inschooloutbreak otherpleasespecify {
	replace lq1a_`i' = "0" if lq1a_`i' == ""
}

replace lq1a_nationalprevalencerates 	= "1" if lq1a_nationalprevalencerates == "national prevalence rates"
replace lq1a_localprevalencerates 		= "1" if lq1a_localprevalencerates 	== "local prevalence rates"
replace lq1a_inschooloutbreak  			= "1" if lq1a_inschooloutbreak  	== "in-school outbreak"
replace lq1a_otherpleasespecify 		= "1" if lq1a_otherpleasespecify 	== "other, please specify"

destring lq1a*, replace

*S12/lq1a_specify/Other (Please specify)
*S12/lq1a_url/Please upload or provide link to the document which lists these criteria in more detail

*S12/lq2/Q2. 
foreach i in offer subsidized nomeasures other donotknow { 
	foreach j in nationwide byregion schoolbyschool schoolbyschoolb schoolbyschoolbasis {
		cap noi: replace lq2`i'_`j' = ustrtrim(lq2`i'_`j')
		cap noi: replace  lq2`i'_`j' = "1" if lq2`i'_`j' == "nation-wide" | lq2`i'_`j' == "by region" | lq2`i'_`j' == "school-by-school basis"
		cap noi: replace  lq2`i'_`j' = "0" if lq2`i'_`j' == ""
		cap noi: destring lq2`i'_`j', replace
	}
}

*S12/lq2_specify/Other (Please specify)

*S12/lq3/Q3. 
		replace lq3 = ustrtrim(lq3) 
		replace lq3 = "999" if lq3 == "" 
    replace lq3 = "997" if lq3 == "Do not know" 
		replace lq3 = "0" if lq3 == "No" 
		replace lq3 = "1" if lq3 == "Yes (If so, please answer Question 3.A)" 
		destring lq3, replace

*S12/lq3a/Q3.A If answered ‘yes’ to Question 3, which additional personnel were/will be recruited and why? Please specify: 

*S12/lq4/Q4.
foreach i in pp p ls us {
	foreach j in first second third {
		replace lq4_`i'_`j' = "1" if lq4_`i'_`j' == "Less than 25% "
		replace lq4_`i'_`j' = "2" if lq4_`i'_`j' == "More than 25% but less than 50%"
		replace lq4_`i'_`j' = "3" if lq4_`i'_`j' == "About half of the students"
		replace lq4_`i'_`j' = "4" if lq4_`i'_`j' == "More than 50% but less than 75%"
		replace lq4_`i'_`j' = "5" if lq4_`i'_`j' == "More than 75% but not all of the students"
		replace lq4_`i'_`j' = "5" if lq4_`i'_`j' == "More than 75% but not all of the students;"
		replace lq4_`i'_`j' = "5" if lq4_`i'_`j' == "More than 75% but not all of the students; "
		replace lq4_`i'_`j' = "6" if lq4_`i'_`j' == "All of the students"
    replace lq4_`i'_`j' = "997" if lq4_`i'_`j' == "unknown/not monitored."
		replace lq4_`i'_`j' = "999" if lq4_`i'_`j' == ""
		destring lq4_`i'_`j', replace
	}
}


*S12/lq5/Q5.  
foreach i in digitalskillstraining fosteringsocialandemotiona developingattitudesknowled healtheducationandlearning other none donotknow { 
		replace lq5`i' = ustrtrim(lq5`i')
		replace  lq5`i' = "1" if lq5`i' == "Digital skills training" | lq5`i' == "Fostering social and emotional learning and well-being for inclusive recovery, decent work and enhanced employability," | lq5`i' == "Developing attitudes, knowledge and behavior for sustainable development" | lq5`i' == "Health education and learning" | lq5`i' == "Other (Please specify)" | lq5`i' == "None" | lq5`i' == "Do not know"
		replace  lq5`i' = "0" if lq5`i' == ""
		destring lq5`i', replace
}

*S12/lq5_specify/Other (Please specify)

*S12/lq6/Q6. 
replace lq6 = ustrtrim(lq6) 
replace lq6 = "999" if lq6 == "" 
replace lq6 = "997" if lq6 == "Do not know" 
replace lq6 = "0" if lq6 == "No" 
replace lq6 = "1" if lq6 == "Yes" 
destring lq6, replace

*S12/lq7/Q7. Please let us know about current issues or solutions related to COVID-19 and education in your country and provide any relevant URLs/Links

******* Step D - Variable labeling *******

*S12/lq1/Q1.
label define lq1_value 		///
	0 "No"					///
	1 "Yes"					///
	2 "This has been left to the discretion of local or school leaders"		///
	997 "Do not know"		///
	998 "Not applicable"	///
	999 "Missing"		
label value lq1 lq1_value

*S12/lq1a/Q1A.
label define lq1a_value 		///
	0 "No"					///
	1 "Yes"					///
	997 "Do not know"		///
	998 "Not applicable"	///
	999 "Missing"		
cap noi: label value lq1a* lq1a_value

*S12/lq2/Q2.
label define lq2_value 		///
	0 "No"					///
	1 "Yes"					///
	997 "Do not know"		///
	998 "Not applicable"	///
	999 "Missing"		
cap noi: label value lq2* lq2_value

*S12/lq4/Q4.
label define lq4_value 						///
	1 "Less than 25 "						///
	2 "More than 25% but less than 50%"		///
	3 "About half of the students"			///
	4 "More than 50% but less than 75%"		///
	5 "More than 75% but not all of the students"	 ///
	6 "All of the students" /// 
  997 "Do not know/Not monitored"			///
	999 "Missing"
label value lq4_pp* lq4_p* lq4_ls* lq4_us* lq4_value

*S12/lq3/Q3.
label define lq3_value 		///
	0 "No"					///
	1 "Yes"					///
	997 "Do not know"		///
	998 "Not applicable"	///
	999 "Missing"		
label value lq3 lq3_value

*S12/lq5/Q5.
label define lq5_value 		///
	0 "No"					///
	1 "Yes"					///
	997 "Do not know"		///
	998 "Not applicable"	///
	999 "Missing"		
cap noi: label value lq5* lq5_value

*S12/lq6/Q6.
label define lq6_value 		///
	0 "No"					///
	1 "Yes"					///
	997 "Do not know"		///
	998 "Not applicable"	///
	999 "Missing"		
label value lq6 lq6_value

******* Step E - Data cleaning *******

*S12/lq1/Q1.

*S12/lq1a/Q1A.
gen lq1a_missing = (lq1a_nationalprevalencerates + lq1a_localprevalencerates + lq1a_inschooloutbreak + lq1a_otherpleasespecify == 0)

foreach i in nationalprevalencerates localprevalencerates inschooloutbreak otherpleasespecify {
	replace lq1a_`i' = 999 if lq1a_missing == 1
}

*logic check: variable iq1a exists if iq1 is 0/no
foreach i of varlist lq1a_nationalprevalencerates lq1a_localprevalencerates lq1a_inschooloutbreak lq1a_otherpleasespecify {
   replace `i' = 998 if  lq1  !=1
}

*S12/lq2/Q2.
* Cleaning Missing: Countries with zero for all are considered as missing
foreach i in nationwide byregion schoolbyschool schoolbyschoolb schoolbyschoolbasis {
	cap noi: gen lq2`i'_missing = (lq2offer_`i' + lq2subsidized_`i' + lq2nomeasures_`i' + lq2other_`i' + lq2donotknow_`i' == 0)
}

foreach i in nationwide byregion schoolbyschool schoolbyschoolb schoolbyschoolbasis {
	foreach j in offer subsidized nomeasures other donotknow {
		cap noi: replace lq2`j'_`i' = 999 if lq2`i'_missing == 1
	}
}

*Logic check: replacing "no measures taken" to 0 if one of the measures is selected
foreach j in nationwide byregion schoolbyschool schoolbyschoolb schoolbyschoolbasis {
	foreach i in offer subsidized other donotknow  {
		cap noi: replace lq2nomeasures_`j' = 0 if lq2`i'_`j' == 1
	}
}

*S12/lq3/Q3.

*S12/lq5/Q5.
* Cleaning Missing: Countries with zero for all are considered as missing
gen lq5_missing = (lq5digitalskillstraining + lq5fosteringsocialandemotiona +  lq5developingattitudesknowled + lq5healtheducationandlearning + lq5other + lq5none + lq5donotknow == 0)

foreach i in digitalskillstraining fosteringsocialandemotiona developingattitudesknowled healtheducationandlearning other none donotknow {
	replace lq5`i' = 999 if lq5_missing == 1
}

******* Step F - Open section to clean specific interested questions *******	
	

*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
* 2) Export Data (Do Not Edit these lines)
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------

* N=115

save             "${Data_clean}jsw3_uis_clean.dta", replace
export delimited "${Data_clean}jsw3_uis_clean.csv", replace
