*=========================================================================*
* Project information at: https://github.com/worldbank/schoolsurvey-production
****** Country: Worldwide
****** Purpose: Cleaning of the UNESCO-UNICEF-WBG_OECD Survey on National education responses to COVID-19 - Round 3
****** Created by: UNESCO, UNICEF, and World Bank
****** Used by: UNESCO, UNICEF, and World Bank
****** Input  data : JSW3_20120616_UIS.xlsx      
****** Output data : jsw_uis.dta, jsw_uis.csv
****** Language: English
*=========================================================================*

* In this do file: 
* This .do file takes round 3 survey responses from UIS and converts them to .dta and .csv format 
* to track changes on Github while cleaning. This step runs parallel to 021_2_import_oecd.do, 021_3_import_metadata.do, and 021_4_import_round1_2.do. 
* Note: This file only needs to be run on first use.

** Steps in this do-file:

* 0) Import UIS data
* 1) Export to .csv
* 2) Export to .dta

*---------------------------------------------------------------------------
* 0) Import UIS Data (Do Not Edit these lines)
*---------------------------------------------------------------------------

clear

tempfile uis
copy "http://covid19.uis.unesco.org/wp-content/uploads/sites/11/2021/06/UIS_JSW3_Data.xlsx" `uis'
import excel using `uis', firstrow allstring

drop responseid responsestatus timestampmmddyyyy
replace q_consent = "YES" if q_consent ==""

*---------------------------------------------------------------------------
* 1) UIS Data: Export to .csv
*---------------------------------------------------------------------------

export delimited using "${Data_raw}/jsw3_uis.csv", replace
export excel using "${Data_raw}/jsw3_uis.xlsx", firstrow(variables) replace

*---------------------------------------------------------------------------
* 2) UIS Data :Export to .dta
*---------------------------------------------------------------------------

save "${Data_raw}jsw3_uis.dta", replace
