# Survey on National Education Responses to COVID-19 School Closures

This repository hosts the **UNESCO-UNICEF-WBG-OECD Survey on National education responses to COVID-19, Round 3**. It contains the raw data collected from the survey and the programs used to clean and analyze responses.

## Round 3 Survey

As part of the coordinated global education response to the COVID-19 pandemic, the United Nations Educational, Scientific and Cultural Organization (UNESCO), the United Nations Children's Fund (UNICEF), the World Bank, and the Organization for Economic Co-operation and Development (OECD) conducted a Survey on National Education Responses to COVID-19 School Closures. This round 3 survey covers government responses to school closures from pre-primary to secondary education from February 2021 – May 2021. In the final joint report, the results of the third of three rounds of data collection administered by the UNESCO Institute for Statistics (UIS) and OECD were analysed. 

This survey by UNESCO, UNICEF, the World Bank and the OECD seeks to collect information on national education responses to school closures related to the COVID-19 pandemic. In light of the current education crisis, the COVID-19 education response coordinated by UNESCO with our partners is deemed urgent. The survey is run on a regular basis to ensure that the latest impact and responses are captured. Analysis of results will allow for policy learning across diverse country settings to better inform local/national responses and prepare for school reopening.

We would like to thank all of you who participated and help the global community better understand the impact of the pandemic!

### Date of implementation and sample size

| Round         | Date          | Responses  |
| :-------------: |:-------------:| :-----:|
|       1       | May 2020 - June 2020 | 118 |
|  2            | June 2020 - October 2020       |   149 |
|  3            | February 2021 - May 2021      |    143 |

*In the third round 143 countries responded to the questionnaire: 31 countries submitted responses to the OECD (“OECD survey”) and 112 countries responded to the UIS (“UIS survey”). seven countries responded to both surveys.

### Questionnaires

#### UIS Questionnaires
The questionnaires were designed for Ministry of Education officials at central or decentralized levels in charge of school education. The UIS questionnaire does not cover higher education or technical and vocational education and training. The survey questionnaire can be found at: 

[Round 3 (English)](http://covid19.uis.unesco.org/wp-content/uploads/sites/11/2021/01/Survey-COVID_R3_EN_final.pdf) 

#### OECD Questionnaire 

The Organization for Economic Co-operation and Development (OECD) joined the consortium in the third round of the survey. The OECD questionnaire was sent to the members of the OECD INES Working Party and its two networks- the INES Network for the collection and the adjudication of system-level descriptive information on educational structures, policies, and practices (NESLI) and the Network for Labour Market, Economic and Social Outcomes of Learning (LSO). The survey can be found in:

[Round 3 (English)](http://covid19.uis.unesco.org/wp-content/uploads/sites/11/2021/06/OECD_SURVEY-ON-COVID-19-QUESTIONNAIRE_R3.xlsx).

### Technical reports and data

- Third round of data collection:  
[UIS data round 3] (http://covid19.uis.unesco.org/wp-content/uploads/sites/11/2021/06/UIS_JSW3_Data.xlsx),
[OECD data round 3](http://covid19.uis.unesco.org/wp-content/uploads/sites/11/2021/06/OECD_JSW3_Data.xlsx).

### Notes on Replication
Technical notes and the codebook:
[Technical report 3] (http://covid19.uis.unesco.org/wp-content/uploads/sites/11/2021/07/JSW3_TechnicalNote.pdf),
[Technical report 3 - Appendix] (http://covid19.uis.unesco.org/wp-content/uploads/sites/11/2021/07/Technical-Notes-Appendix-1-and-2.xlsx),

This repo includes answers for 130 countries that gave consent to the diffusion of their answers. Therefore, exact replication of the figures in the report are not possible.

Other countries have been added to the final replication, despite not being included in the report, such as Oman.

Please add profile_schoolsurvey-production.do to your Stata environment and run it before running other program files.

## Suggested Citation

of the analysis: 

[ UNESCO, UNICEF, the World Bank and OECD (2021). What’s Next? Lessons on Education Recovery: Findings from a Survey of Ministries of Education amid the COVID-19 Pandemic. Paris, New York, Washington D.C.: UNESCO, UNICEF, World Bank.] (http://covid19.uis.unesco.org/wp-content/uploads/sites/11/2021/07/National-Education-Responses-to-COVID-19-Report2_v3.pdf))

of the data:

[UNESCO, UNICEF, the World Bank, OECD  (2021). Survey on National Education Responses to COVID-19 School Closures, round 3. Paris, New York, Washington D.C.: UNESCO, UNICEF, World Bank, OECD]( http://covid19.uis.unesco.org/joint-covid-r3/) 

## Folder structure

| Folder Name | Usage |
|---|---|
|**01_data**|A subfolder for rawdata stored as csv plus derived files in the root|
|**02_programs**|Do-files and other programs used to replicate this repo|
|**03_outputs**|A subfolder for figures and other outputs in the root||

* Note: Replicated numbers in the output will not match 

Contributors:
Akito Kamei (UNICEF, Office of Research), Alison Gilberto (WB), António Carvalho (OECD), Joao Pedro Wagner De Azevedo (WB), Yifan Li (UNESCO Institute for Statistics), Yi Ning Wong (WB), Youngkwang Jeon (UNICEF, Office of Research)

## Reference for round 1 and 2

### Questionnaires

[Round 1 (English)](http://tcg.uis.unesco.org/wp-content/uploads/sites/4/2020/06/covid-19_school_closure_questionnaire_en.pdf)
 
[Round 2 (English)]( http://tcg.uis.unesco.org/wp-content/uploads/sites/4/2020/07/Joint-Survey-2.0-FINAL_EN.pdf)
 
Questionnaires in Arabic, French, Spanish, and Russian can be found on the [main page](http://tcg.uis.unesco.org/survey-education-covid-school-closures/).

### Technical reports and data

   - First round of data collection: 
[Technical report 1](http://tcg.uis.unesco.org/wp-content/uploads/sites/4/2020/07/COVID-SURVEY_technical-note-20200702.pdf), 
[data round 1](http://tcg.uis.unesco.org/wp-content/uploads/sites/4/2020/07/Response_final_20200720.xls).
   - Second round of data collection: 
[Technical report 2](http://tcg.uis.unesco.org/wp-content/uploads/sites/4/2020/10/COVID-SURVEY_R2_technical-note.pdf),
[data round 2](http://tcg.uis.unesco.org/wp-content/uploads/sites/4/2020/10/COVID_SchoolSurvey_R2_Data-and-Codebook.xlsx).

### Suggested Citation

of the analysis: 

  [UNESCO, UNICEF and the World Bank (2020). What have we learnt? Overview of findings from a survey of ministries of education on national responses to COVID-19. Paris, New York, Washington D.C.: UNESCO, UNICEF, World Bank.](https://data.unicef.org/wp-content/uploads/2020/10/National-Education-Responses-to-COVID-19-WEB-final.pdf)

of the data:

  [UNESCO, UNICEF and the World Bank (2020). Survey on National Education
Responses to COVID-19 School Closures, round 1. Paris, New York, Washington D.C.: UNESCO, UNICEF, World Bank.](http://tcg.uis.unesco.org/survey-education-covid-school-closures/) 

  [UNESCO, UNICEF and the World Bank (2020). Survey on National Education
Responses to COVID-19 School Closures, round 2. Paris, New York, Washington D.C.: UNESCO, UNICEF, World Bank.](http://tcg.uis.unesco.org/survey-education-covid-school-closures/) 
