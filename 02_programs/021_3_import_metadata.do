*=========================================================================*
* Project information at: https://github.com/worldbank/schoolsurvey-production
****** Country: Worldwide
****** Purpose: Cleaning of the UNESCO-UNICEF-WBG_OECD Survey on National education responses to COVID-19 - Round 3
****** Created by: UNESCO, UNICEF, WORLD BANK, and OECD
****** Used by: UNESCO, UNICEF, WORLD BANK, and OECD
****** Input  data : wbopendata            
****** Output data : wbg_country_metadata.dta, wbg_unicef_country_metadata.csv, population.csv, population.dta, enrollment.csv, enrollment.dta
****** Language: English
*=========================================================================*

* In this do file: 
* This .do file reads country-level metadata through the wbopendata command, and converts them to .dta and .csv format to track changes on Github while cleaning. 
* Countries are categorized by World Bank classifications and include countryname, region, region name, income level, incomelevelname, lendingtype, lending type name, total population, school age population, and enrollment. 
* Exceptions are made to entities that are not a part of the WBG list of economies. 
* These characteristics will later be merged into the survey data.
* This step runs parallel to 021_1_import_uis.do, and 021_2_import_oecd.do.
* Note: This file only needs to be run on first use.

** Steps in this do-file:
* 1) Get WBG country metadata 
* 2) Get school-age population by country
* 3) Get enrollment by country

*-----------------------------------------------------------------------------
* This switch allows to "freeze" the data downloaded from the API as a csv,
* which is stored in GitHub, ensuring reproducibility if the API is updated.
* When the local switch is turned to 0, code only import csvs as dtas.
* If the local switch is turned to 1, it forces a new download from the API.
local overwrite_wbopendata = 0
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
* 1) Get WBG country metadata
*-----------------------------------------------------------------------------

* Check for a pre-existing frozen version in the clone
cap confirm file "${Data_raw}/wbg_country_metadata.csv"

* If the frozen version is not found or forced to overwrite with a fresh wbopendata query
if (_rc | `overwrite_wbopendata') {

  * From wbopendata take metadata of all countries (the indicator is irrelevant)
  wbopendata, indicator(SP.POP.TOTL) latest clear long nometadata full

  * Drop non-countries (aggregates)
  drop if region == "NA"

  * Keep only the relevant metadata
  keep countrycode countryname region regionname incomelevel incomelevelname lendingtype lendingtypename

  * Export as a tracked csv file
  export delimited "${Data_raw}/wbg_country_metadata.csv", replace
  noi disp as txt _n "{phang}Created list of WBG countries with metadata from wbopendata.{p_end}"
}

* If not creating a new list of WBG countries, simply imports existing csv into a dta
else {
  import delimited "${Data_raw}/wbg_country_metadata.csv", varnames(1) clear
  noi disp as txt _n "{phang}Imported list of WBG countries with metadata from csv.{p_end}"
}


* Metadata exceptions (entities that are not part of the WBG list of economies)
* https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups

local N = _N
set obs `=_N + 5'

replace countrycode = "AIA"           if _n == `N' + 1
replace countryname = "Anguilla"      if _n == `N' + 1

replace countrycode = "COK"           if _n == `N' + 2
replace countryname = "Cook Islands"  if _n == `N' + 2

replace countrycode = "MSR"           if _n == `N' + 3
replace countryname = "Montserrat"    if _n == `N' + 3

replace countrycode = "NIU"           if _n == `N' + 4
replace countryname = "Niue"          if _n == `N' + 4

replace countrycode = "TKL"           if _n == `N' + 5
replace countryname = "Tokelau"       if _n == `N' + 5

replace lendingtype = "LNX"                if inlist(countrycode, "AIA", "COK", "MSR", "NIU", "TKL")
replace lendingtypename = "Not classified" if inlist(countrycode, "AIA", "COK", "MSR", "NIU", "TKL")

replace region     = "LAC"                         if inlist(countrycode, "AIA", "MSR")
replace regionname = "Latin America and Caribbean" if inlist(countrycode, "AIA", "MSR")
replace region     = "EAS"                         if inlist(countrycode, "COK", "NIU", "TKL")
replace regionname = "East Asia and Pacific"       if inlist(countrycode, "COK", "NIU", "TKL")

replace incomelevel     = "HIC"                 if inlist(countrycode, "AIA", "COK", "MSR", "NIU")
replace incomelevelname = "High income"         if inlist(countrycode, "AIA", "COK", "MSR", "NIU")
replace incomelevel     = "UMC"                 if countrycode == "TKL"
replace incomelevelname = "Upper middle income" if countrycode == "TKL"

/* Justification for incomelevel decisions
Country | GNI pc | GDP pc | Year | Source | Category
Anguila | $19,914 | $19,891 | 2018 | https://unstats.un.org/unsd/snaama/CountryProfile?ccode=660 | High income
Cook Islands | $20,705 | $20,705 | 2018 | https://unstats.un.org/unsd/snaama/CountryProfile?ccode=660 | High income
Montserrat | $12,544 | $12,754 | 2018 | https://unstats.un.org/unsd/snaama/CountryProfile?ccode=660 | High income
Niue | | $15,586 | 2016 | https://www.spc.int/our-members/niue/details | High income
Tokelau | |  $7,069 | 2016 | https://www.spc.int/our-members/tokelau/details | Upper middle income
*/

* Label everything and save the dta
label var countrycode     "Country Code"
label var countryname     "WBG Country Name"
label var region          "WBG Region Code"
label var regionname      "WBG Region Name"
label var incomelevel     "Income Level Code"
label var incomelevelname "Income Level Name"
label var lendingtype     "Lending Type Code"
label var lendingtypename "Lending Type Name"

* UIS and WBG do not use the same regions
rename (region regionname) (region_wbg regionname_wbg)

compress
sort countrycode
isid countrycode
save "${Data_raw}/wbg_country_metadata.dta", replace

export delimited using "${Data_raw}/wbg_unicef_country_metadata.csv", replace

*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
* 2) Get school-age population by country
*-----------------------------------------------------------------------------
* Check for a pre-existing frozen version in the clone
cap confirm file "${Data_raw}/population.csv"

* If the frozen version is not found or forced to overwrite with a fresh wbopendata query
if (_rc | `overwrite_wbopendata') {

  * Get latest available population data from UIS using WB API
  wbopendata, indicator(SP.POP.0004.FE; SP.POP.0004.MA; SP.POP.0509.FE; SP.POP.0509.MA; ///
                  SP.POP.1014.FE; SP.POP.1014.MA; SP.POP.1519.FE; SP.POP.1519.MA) ///
                  latest clear long nometadata

  * Aggregate on gender
  gen pop_0004 = sp_pop_0004_fe + sp_pop_0004_ma
  gen pop_0509 = sp_pop_0509_fe + sp_pop_0509_ma
  gen pop_1014 = sp_pop_1014_fe + sp_pop_1014_ma
  gen pop_1519 = sp_pop_1519_fe + sp_pop_1519_ma

  * Aggregate to population aged 04-17
  gen population_0417 = pop_0004*1/5 + pop_0509 + pop_1014 + pop_1519*3/5

  * Organize and keep only the relevant variables
  rename year year_population
  order countrycode year_population population_*
  keep  countrycode year_population population_*

  * Export as a tracked csv file
  export delimited "${Data_raw}/population.csv", replace
  noi disp as txt _n "{phang}Downloaded youth population from wbopendata.{p_end}"

}

* If not creating a new csv, simply imports existing csv into a dta
else {
  import delimited "${Data_raw}/population.csv", varnames(1) clear
  noi disp as txt _n "{phang}Imported youth population from csv.{p_end}"
}

* In any case, beautify, label everything and save as dta
format %12.0fc population*
label var countrycode      "Country Code"
label var year_population  "Year of population data"
label var population_0417  "Population ages 04-17"

compress
isid countrycode
save "${Data_raw}/population.dta", replace
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
* 3) Get enrollment by country
*-----------------------------------------------------------------------------
* Check for a pre-existing frozen version in the clone
cap confirm file "${Data_raw}/enrollment.csv"

* If the frozen version is not found or forced to overwrite with a fresh wbopendata query
if (_rc | `overwrite_wbopendata') {

  * Get latest available population data from UIS using WB API
  wbopendata, indicator(SE.PRE.ENRL; SE.PRM.ENRL; SE.SEC.ENRL) ///
                  latest clear long nometadata

  * Aggregate
  egen enrollment = rowtotal(se_pre_enrl  se_prm_enrl se_sec_enrl)
  
  * Organize and keep only the relevant variables
  rename year year_enrollment
  order countrycode year_enrollment enrollment se_*
  keep  countrycode year_enrollment enrollment se_*

  * Export as a tracked csv file
  export delimited "${Data_raw}/enrollment.csv", replace
  noi disp as txt _n "{phang}Downloaded enrollment from wbopendata.{p_end}"

}

* If not creating a new csv, simply imports existing csv into a dta
else {
  import delimited "${Data_raw}/enrollment.csv", varnames(1) clear
  keep countrycode year* enrollment
  noi disp as txt _n "{phang}Imported enrollment from csv.{p_end}"
}

* In any case, beautify, label everything and save as dta
format %12.0fc enrollment
label var countrycode      "Country Code"
label var year_enrollment  "Year of enrollment data"
label var enrollment       "Enrollment in pre-primary, primary and secondary education"

compress
isid countrycode
save "${Data_raw}/enrollment.dta", replace

*-----------------------------------------------------------------------------
