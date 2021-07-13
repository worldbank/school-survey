*=========================================================================*
* Project information at: https://github.com/worldbank/schoolsurvey-production
****** Country: OECD Data
****** Purpose: Cleaning of the UNESCO-UNICEF-WBG_OECD Survey on National education responses to COVID-19 - Round 3
****** Created by: OECD
****** Used by: OECD
****** Input  data : "${data}\021_2_OECD.dta" , OECD dataset from Covid19Survey_OECDData_forJSW3folder_07June2021.xlsx, sheet 1            
****** Output data : "${data}\021_2_OECD.dta" .dta file for file 022_2_clean_oecd.do
****** Language: English
*=========================================================================*
* In this do file: 
* This .do file takes round 3 survey responses from OECD and converts them to .dta and .csv format to track changes on Github while cleaning. 
* This step runs parallel to 021_1_import_uis.do, 021_3_import_metadata.do, and 021_4_import_round1_2.do.
* Note: This file only needs to be run on first use.

** Steps in this do-file:
 
* 0) Import OECD data
* 1) Export to .csv
* 2) Export to .dta

*************************************************************************************
** Comments on OECD procedures prior to the cleaning process on GitHub:

*1.	Excel questionnaires were cleaned directly in the Excel file with discussion and agreement with each of the countries. These exchanges discussed if "not applicable", "missing" or "included in another category" was the best option in each instance. Multiple iterations of discussion and data validation were often made with member countries.

*2.	All remaining empty cells in the Excel questionnaires after data validation were then replaced as "Not Applicable" in Stata before generating the Excel file which is the basis of OECD data for GitHub work.

*---------------------------------------------------------------------------
* 0) Import OECD Data (Do Not Edit these lines)
*---------------------------------------------------------------------------

clear
tempfile oecd
copy "http://covid19.uis.unesco.org/wp-content/uploads/sites/11/2021/06/OECD_JSW3_Data.xlsx" `oecd'
import excel using `oecd', firstrow allstring 

keep Answer OECDVariableName  Country
rename Answer A
rename OECDVariableName Q
*** Not originally running in OECD computer - previously not mentioned that it requires the package "TIDY", function "spread"
ssc install tidy
*** After "tidy" is installed, then "spread" function can be applied
spread Q A

*---------------------------------------------------------------------------
* 1) OECD Data: Export to .csv
*---------------------------------------------------------------------------

export excel "${Data_raw}jsw3_oecd.xlsx", firstrow(variables) replace
export delimited using "${Data_raw}jsw3_oecd.csv", replace
  
*---------------------------------------------------------------------------
* 2) OECD Data: Export to .dta
*--------------------------------------------------------------------------- 
 
	save "${Data_raw}jsw3_oecd.dta", replace 

	
	
