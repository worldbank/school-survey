*==============================================================================*
*! UNESCO-UNICEF-WBG_OECD Survey on National education responses to COVID-19 - Round 3
*! Project information at: https://github.com/worldbank/school-survey
*
*! MASTER RUN: Executes all tasks sequentially
*==============================================================================*

* Steps in this do-file:

* 1) General program setup
* 2) Define user-dependant paths for local clone and subfolders as globals
* 3) Download and install required user written ado's
* 4) Run all tasks in this project

*-----------------------------------------------------------------------------
* 1) General program setup
*-----------------------------------------------------------------------------
clear               all
capture log         close _all
set more            off
set varabbrev       off
set emptycells      drop
set seed            12345
set maxvar          2048
set linesize        135
version             14
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
* 2) Define user-dependant paths for local clone and subfolders as globals
*-----------------------------------------------------------------------------
* Change here only if this repo is renamed
local this_repo     "school-survey"
* Change here only if this master run do-file is renamed
local this_run_do   "profile_school-survey.do"

* One of two options can be used to "know" the clone path for a given user
* A. the user had previously saved their GitHub location with -whereis-,
*    so the clone is a subfolder with this Project Name in that location
* B. through a window dialog box where the user manually selects a file

* Method A - Github location stored in -whereis-
*---------------------------------------------
capture whereis github
if _rc == 0 global clone "`r(github)'/`this_repo'"

* Method B - clone selected manually by user
*---------------------------------------------
else {
  * Display an explanation plus warning to force the user to look at the dialog box
  noi disp as txt `"{phang}Your GitHub clone local could not be automatically identified by the command {it: whereis}, so you will be prompted to do it manually. To save time, you could install -whereis- with {it: ssc install whereis}, then store your GitHub location, for example {it: whereis github "C:/Users/AdaLovelace/GitHub"}.{p_end}"'
  noi disp as error _n `"{phang}Please use the dialog box to manually select the file `this_run_do' in your machine.{p_end}"'

  * Dialog box to select file manually
  capture window fopen path_and_run_do "Select the master do-file for this project (`this_run_do'), expected to be inside any path/`this_repo'/" "Do Files (*.do)|*.do|All Files (*.*)|*.*" do

  * If user clicked cancel without selecting a file or chose a file that is not a do, will run into error later
  if _rc == 0 {

    * Pretend user chose what was expected in terms of string lenght to parse
    local user_chosen_do   = substr("$path_and_run_do",   - strlen("`this_run_do'"),     strlen("`this_run_do'") )
    local user_chosen_path = substr("$path_and_run_do", 1 , strlen("$path_and_run_do") - strlen("`this_run_do'") - 1 )

    * Replace backward slash with forward slash to avoid possible troubles
    local user_chosen_path = subinstr("`user_chosen_path'", "\", "/", .)

    * Check if master do-file chosen by the user is master_run_do as expected
    * If yes, attributes the path chosen by user to the clone, if not, exit
    if "`user_chosen_do'" == "`this_run_do'"  global clone "`user_chosen_path'"
    else {
      noi disp as error _newline "{phang}You selected $path_and_run_do as the master do file. This does not match what was expected (any path/`this_repo'/`this_run_do'). Code aborted.{p_end}"
      error 2222
    }
  }
}

* Regardless of the method above, check clone
*---------------------------------------------
* Confirm that clone is indeed accessible by testing that master run is there
cap confirm file "${clone}/`this_run_do'"
if _rc != 0 {
  noi disp as error _n `"{phang}Having issues accessing your local clone of the `this_repo' repo. Please double check the clone location specified in the run do-file and try again.{p_end}"'
  error 2222
}
* Flag that profile was successfully loaded
*--------------------------------------------
noi disp as result _n `"{phang}`this_repo' clone sucessfully set up (${clone}).{p_end}"'

* Set subfolders of clone as globals
*----------------------------------------------------
global Data     	   "${clone}/01_data/"
global Data_raw     "${clone}/01_data/011_rawdata/"
global Data_clean   "${clone}/01_data/012_cleandata/"
global Do           "${clone}/02_programs/"
global Table        "${clone}/03_outputs/"
*----------------------------------------------------


*-----------------------------------------------------------------------------
* 3) Download and install required user written ado's
*-----------------------------------------------------------------------------
* Fill this list will all user-written commands this project requires
* that can be installed automatically from ssc
local user_commands wbopendata estout tabout mrtab labvars tidy

* Loop over all the commands to test if they are already installed, if not, then install
foreach command of local user_commands {
  cap which `command'
  if _rc == 111 ssc install `command' 
}
cap which renvars
if _rc == 111 net install http://www.stata-journal.com/software/sj5-4/dm88_1
  
  
*-----------------------------------------------------------------------------
* 4) Run all tasks in this project
*-----------------------------------------------------------------------------
* Steps in Round 3 Cleaning: 

* 0211: Convert raw excel (UIS) to trackable .csv and .dta format 
* 0212: Convert raw excel (OECD) to trackable .csv and .dta format 
* 0213: Convert country metadata to trackable .csv and .dta format
* 0214: Convert Wave 1 and Wave 2 data to trackable .csv and .dta format

* 0221: Clean the converted .dta for UIS
* 0222: Clean the converted .dta for OECD

* 023: Append UIS and OECD and merge complementary files + clean metadata if needed

* 024: Export figures to excel

* 025: Export stats to excel

**** Note that 0221, 0222, 0224, and 0225 are organized by sections of the questionnaire
*-----------------------------------------------------------------------------

* TASK 01: download or import frozen cty metadata & population from WBG API 
do "${Do}021_1_import_uis.do"
do "${Do}021_2_import_oecd.do"
do "${Do}021_3_import_metadata.do"

* TASK 02: clean survey rawdata
do "${Do}022_1_clean_uis.do"
do "${Do}022_2_clean_oecd.do"
do "${Do}022_3_consistency.do"

* TASK 03: Append OECD and UNESCO data
do "${Do}023_append_all.do"

* TASK 04: creates excel with all tables needed for figures
do "${Do}024_analysis_figures.do"

* TASK 05: Adds to excel for other statistics used in the report.
do "${Do}025_analysis_stats.do"
*-----------------------------------------------------------------------------
