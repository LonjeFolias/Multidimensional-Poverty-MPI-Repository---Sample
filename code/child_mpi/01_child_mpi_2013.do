********************************************************************************
*																			   *
************    PART 1:  Child Multi-Dimensional Poverty Indices  ***********  *
*								Wave 1 (2013)								   *

*******************************************************************************
    clear 
	
    capture log close
	
    log   using  "$pathlog/01_cmdpi_2013", replace
	
    di in yellow "`c(current_date)' `c(current_time)'"
	
	set more off
/*******************************************************************************
# Name:			01_Child-Multi-Dimensional Poverty Index 2013

# Purpose:		Generates Child Multi-Dimensional Poverty Index for 2013
			
# Creates: 		cmdpi-2013.dta

# Created by:	Happy Banda, May 2024

# Repository curation and documentation:
#               Lonjezo Erick Folias, Everest Intelligence Consult (EIC), 2026
#
# Attribution note:
#               Original authorship and NSO ownership are preserved. Repository
#               curation does not transfer ownership or claim original authorship.

# Checked by:		

# Updated by:  		

# Owner:		NSO
*******************************************************************************/

/*******************************************************************************
*	Uses the following modules;
		(01) hh_mod_a_filt_13 - Household Identification
		(02) hh_mod_b_13	  - Household Roster
		(03) hh_mod_c_13	  - Education
		(04) hh_mod_d_13	  - Health
		(05) hh_mod_e_13	  - Time Use and Labour
		(06) hh_mod_f_13	  - Housing
		(07) hh_mod_h_13	  - Food Security
		(08) hh_mod_v_13	  - Child Anthropometry
		(09) hh_mod_l_13	  - Durable goods
		(10) 
*******************************************************************************/
*______________________________________________________________________________*

*	NOTE: Definitions of indicators are adapted from the Child Multi-Dimensional
*		  Poverty Report of 2023

********************************************************************************
*  Merge relevant modules to create child multi-dimensional poverty indices
********************************************************************************

** Open Durable Goods Module
use      "${wave1}/hh_mod_l_13.dta", clear  

* Interested in possession of assets that are used to obtain information eg radio
numlabel, add

tab1     hh_l01 hh_l02
gen      inforasset      = (hh_l01==1) if inlist(hh_l02, 507,509,529,530,5081) 
collapse (max) inforasset, by(y2_hhid)
lab var  inforasset "HH has any of the information assets: radio, TV, PC, satelite dish"

* Merge Household Identification
merge    1:1 y2_hhid   using "${wave1}/hh_mod_a_filt_13.dta", nogen 
 
* Merge Household Roster
merge    1:m y2_hhid   using "${wave1}/hh_mod_b_13.dta", nogen  

* Merge Education
merge 1:1  y2_hhid PID using "${wave1}/hh_mod_c_13.dta", keep (3) nogen 

* Merge Health
merge 1:1  y2_hhid PID using "${wave1}/hh_mod_d_13.dta", keep (3) nogen 

* Merge Time Use and Labour
merge 1:1  y2_hhid PID using "${wave1}/hh_mod_e_13.dta", keep (3) nogen

* Merge Housing
merge m:1  y2_hhid     using "${wave1}/hh_mod_f_13.dta", keep (3) nogen

* Merge Food Security
merge m:1 y2_hhid  	   using "${wave1}/hh_mod_h_13.dta", keep (3) nogen

* Merge Child Anthropometry
merge 1:1  y2_hhid PID using "${wave1}/hh_mod_v_13.dta", keep (3) nogen

*_______________________________________________________________________________

********************************************************************************
*** Household identification and weights
********************************************************************************
numlabel, add

* Region
tab      region
ren      region region_
gen      region = cond(region_ > 200, 3, cond(region_ < 200, 1, 2))
lab var  region "Region"
lab def  Region 1 Northern 2 Central 3 Southern
lab val  region Region

* District and Rural/Urban Residence
tab1     district reside
 
global   id_weights HHID case_id panelweight_2013 hh_wgt region reside district 

********************************************************************************
*** Dimensions are composed of age-specific indicators
********************************************************************************

* Age in months (under 5)
codebook hh_b05a hh_b05b
sum      hh_b05a hh_b05b
gen 	 agemonths =hh_b05b     if hh_b05a ==0
replace  agemonths =hh_b05b +12 if hh_b05a ==1
replace  agemonths =hh_b05b +24 if hh_b05a ==2
replace  agemonths =hh_b05b +36 if hh_b05a ==3
replace  agemonths =hh_b05b +48 if hh_b05a ==4

* Create child age-group dummies (0-17 years)

* 0-23 months
gen 	age_0_23m = (agemonths <= 23)        if hh_b05a <18
lab var age_0_23m   "0-23 months"

* 24-59 months
gen 	age_24_59m= inrange(agemonths,24,59) if hh_b05a <18
lab var age_24_59m  "24-59 months"

* 6-59 months
gen     age_6_59m = inrange(agemonths,6,59)  if hh_b05a <18
lab var age_6_59m   "6-59 months"

* 5-7 years
gen 	age_5_7   = inrange(hh_b05a,5,7)     if hh_b05a <18
lab var age_5_7     "5-7 years"

* 5-14 years
gen 	age_5_14  = inrange(hh_b05a,5,14)    if hh_b05a <18
lab var age_5_14    "5-14 years"

* 5-11 years
gen 	age_5_11  = inrange(hh_b05a,5,11)    if hh_b05a <18
lab var age_5_11    "5-11 years"

* 12-14 years
gen 	age_12_14 = inrange(hh_b05a,12,14)   if hh_b05a <18
lab var age_12_14   "12-14 years"

* 5-17 years
gen 	age_5_17  = inrange(hh_b05a,5,17)    if hh_b05a <18
lab var age_5_17    "5-17 years"

* 9-17 years
gen 	age_9_17  = inrange(hh_b05a,9,17)    if hh_b05a <18
lab var age_9_17    "9-17 years"

* 12-17 years
gen 	age_12_17 = inrange(hh_b05a,12,17)   if hh_b05a <18
lab var age_12_17   "12-17 years"

* 15-17 years
gen 	age_15_17 = inrange(hh_b05a,15,17)   if hh_b05a <18
lab var age_15_17   "15-17 years"

* 15-16 years
gen 	age_15_16 = inlist(hh_b05a,15,16)    if hh_b05a <18
lab var age_15_16   "15-16 years"

* 0-17 years
gen 	flag_0_17  = hh_b05a < 18
lab var flag_0_17   "0-17 years"

lab def yesno   1 "Yes" 0 "No"
lab val age_*   yesno

* Child Age Categorical

gen     cat_age = 1 if age_0_23m  == 1
replace cat_age = 2 if age_24_59m == 1
replace cat_age = 3 if age_5_14   == 1
replace cat_age = 4 if age_15_17  == 1

lab var cat_age   "Age group of child"
lab def age_cat 1 "0-23 months"         ///
                2 "24-59 months"        ///
				3 "5-14 years"          ///
				4 "15-17 years"
lab val cat_age age_cat

*_______________________________________________________________________________
 


********************************************************************************
**# 1: NUTRITION DIMENSION
********************************************************************************	

* Generate z-scores for stunting, underweight and wasting for children under 5
* using 'zscore06' the 2006 WHO child growth standards 
********************************************************************************

* Age of child in months, a()
sum      agemonths

* Sex of child, s() where 1 is male and 2 is female
tab      hh_b03

* Height/length of child, h() in cm 
*	Recumbent length is assumed for children <24months 
*	While standing height for children >24 months. If not, measure() must be 
*   specified 1 for recumbent length and 2 for standing height 

codebook hh_v09	hh_v10
tab      hh_v10 if hh_b05a <5, m
gen 	 measure = cond(hh_v10<2,2,1) if hh_b05a <5 & !missing(hh_v10)

* Treating missing 'measure', assuming recumbent length for 0-23 months and
*    standing height for 24-59 months
tab      measure if hh_b05a <5, m
replace  measure = 1 if age_0_23m == 1 & missing(hh_v10) 
replace  measure = 2 if age_24_59m== 1 & missing(hh_v10)
tab      measure

* Weight of child, w() in kg  
codebook hh_v08

* Check the variables for missing observations
count if (hh_b03==. | hh_v09==. | hh_v08==. | measure==.) & hh_b05a<5

//Expecting to have some cases with missing zscores

zscore06, a(agemonths) s(hh_b03) h(hh_v09) w(hh_v08) measure(measure)

* Check missing zscores 
count if haz06==. & hh_b05a <5
count if waz06==. & hh_b05a <5
count if whz06==. & hh_b05a <5
  
* ------------------------------------------------------------------------------
*** Indicator i) Stunted

* Deprived if height for age < -2 standard deviations (s.d.) (24-59 months)
* ------------------------------------------------------------------------------

gen 	ind_stunted =   (haz06 <-2) if age_24_59m ==1
replace ind_stunted = . if haz06==. &  age_24_59m ==1
lab var ind_stunted "Stunted (24-59 months)"

* ------------------------------------------------------------------------------
*** Indicator ii) Underweight

* Deprived if Weight for age <-2 s.d. (0-23 months)
* ------------------------------------------------------------------------------

gen     ind_underweight =   (waz06 <-2) if age_0_23m ==1
replace ind_underweight = . if waz06==. &  age_0_23m ==1
lab var ind_underweight "Underweight (0-23 months)"

* ------------------------------------------------------------------------------
*** Indicator iii) Wasting

* Deprived if weight for height <-2 s.d. (0-23 months)
* ------------------------------------------------------------------------------

gen      ind_wasting =   (whz06 <-2) if age_0_23m ==1
replace  ind_wasting = . if whz06==. &  age_0_23m ==1
lab var  ind_wasting  "Wasting (0-23 months)"
* ------------------------------------------------------------------------------

*** Indicator iv) Fewer than three meals

* Deprived if children in the HH have fewer than 3 meals per day (6-59 months)
* Mising treated as deprived
* ------------------------------------------------------------------------------
tab      hh_h03b if age_6_59m ==1,m

gen      ind_meals = hh_h03b < 3 if age_6_59m ==1
lab var  ind_meals   "Fewer than three meals per day (6-59 months)"

* ------------------------------------------------------------------------------
*** Indicator v) Nothing for breakfast

* Deprived if s/he had nothing for breakfast (5-14 years)
* ------------------------------------------------------------------------------
tab     hh_d38 if age_5_14==1, m //some missing, treated as did not have breakfast

gen     ind_breakfast = hh_d38 == 10 if age_5_14 ==1 & !missing(hh_d38)
replace ind_breakfast = 1            if age_5_14 ==1 &  missing(hh_d38)
lab var ind_breakfast  "Nothing for breakfast (5-14 years)"
tab     ind_breakfast                if age_5_14 ==1, m
* ------------------------------------------------------------------------------

* Nutrition Dimension - Deprivation in at least one indicator
********************************************************************************
gen     dim_nutrition= ind_stunted ==1 | ind_underweight==1 | ind_wasting==1 ///
	        | ind_meals==1 | ind_breakfast==1 if hh_b05a <15
		
lab var dim_nutrition "Nutrition dimension deprivation"
********************************************************************************

********************************************************************************
**# 2: HEALTH DIMENSION
********************************************************************************

* ------------------------------------------------------------------------------
*** Indicator i) No skilled birth attendance

* Deprived if not delivered with skilled health assistance (doctor, nurse) and 
* not in a hospital/health facility (0-23 months)
* ------------------------------------------------------------------------------

tab1    hh_d40 hh_d42 hh_d43 if age_0_23m == 1, m

// ????????????????? ALL MISSING ???????????????? 
 
gen ind_birthattend =(hh_d42 !=1) & (hh_d43>2) if age_0_23m==1 & !missing(hh_d40)
lab var ind_birthattend "No skilled birth attendance (0-23 months)"

* ------------------------------------------------------------------------------
*** Indicator ii) Does not sleep under bed net

* Deprived if not all children under 5 sleep under a net 
* ------------------------------------------------------------------------------

tab     hh_f47 if cat_age <=2, m
* missing observations treated as deprived
gen     ind_mosqnet = (hh_f47 >1) if cat_age <=2
lab var ind_mosqnet   "Does not sleep under bed net (0-59 months)"
tab     ind_mosqnet
*-------------------------------------------------------------------------------

* Health Dimension - Deprivation in at least one indicator
********************************************************************************
gen     dim_health = ind_birthattend ==1 | ind_mosqnet ==1 if hh_b05a <5
lab var dim_health "Health dimension deprivation"
********************************************************************************

********************************************************************************
**# 3: PROTECTION DIMENSION
********************************************************************************

* ------------------------------------------------------------------------------
*** Indicator i) Early marriage

* Deprived if ever married (12-17 years)
* ------------------------------------------------------------------------------
tab   hh_b24 if age_12_17==1, m
tab   hh_b24 if age_12_17==1 & missing(hh_b24) //missing treated as not deprived

gen     ind_marriage = (hh_b24 != 6) if age_12_17==1
lab var ind_marriage "Early marriage (12-17 years)"
tab     ind_marriage if age_12_17==1, m

* ------------------------------------------------------------------------------

*** Indicator ii) Child labour 
* ------------------------------------------------------------------------------

* Reference period is not specified, a period of 7 days is assumed.

* economic activities
codebook hh_e07 hh_e08 hh_e09 hh_e10 hh_e11 

* hh chores
codebook hh_e05 hh_e06 

/* NOTE: Duration for HH chores was collected with a reference period of   
   one day. I multiply by 7 to assume to a 7-day reference period, for   
   consistencewith the rest of economic activities variables   */

egen	econ_act  =rowtotal(hh_e07 hh_e08 hh_e09 hh_e10 hh_e11)
gen     chore_a   =(hh_e05*7) 
gen     chore_b   =(hh_e06*7)
egen    hhchore   =rowtotal(chore_a chore_b)
        
* Deprived if s/he does 1+ hrs of economic activity or 28hrs of hh chore (5-11yrs)
gen     ind_labor_5_11 = (econ_act>=1) | (hhchore >=28) if age_5_11==1
lab var ind_labor_5_11 "Child labour (5-11 years)"

* Deprived if s/he does 14+ hrs of economic activity or 28hrs of household
* chore (12-14yrs) 
gen     ind_labor_12_14= (econ_act>=14) | (hhchore >=28) if age_12_14==1
lab var ind_labor_12_14 "Child labour (12-14 years)"

* Deprived if s/he does 43+ hrs of total activity (15-17yrs)
egen    labor_15_17 = rowtotal(econ_act hhchore) if age_15_17== 1		 
gen     ind_labor_15_17 = (labor_15_17>=43)      if age_15_17== 1	
lab var ind_labor_15_17 "Child labour (15-17 years)"

* Child labor (5-17 years)
gen     ind_labour=ind_labor_5_11==1 | ind_labor_12_14==1 | ind_labor_15_17==1 ///
             if age_5_17==1
			 
lab var  ind_labour "Child labour (5-17 years)"
drop     *_labor_*

* ------------------------------------------------------------------------------
* Protection Dimension - Deprivation in at least one indicator
********************************************************************************
gen      dim_protection = ind_marriage ==1 | ind_labour ==1                  ///
             if inrange(hh_b05a,5,17)
		
lab var  dim_protection "Protection dimension deprivation"
********************************************************************************


********************************************************************************
**# 4. EDUCATION DIMENSION
********************************************************************************

* ------------------------------------------------------------------------------
*** Indicator i) Iliterate 

* Deprived if s/he cannot read and write in any language (15-17 years)

* Note: There is Chichewa and English only in 2013 wave
* ------------------------------------------------------------------------------

tab1 	 hh_c05a hh_c05b if age_15_17 ==1, m
* Missing observation treated as illiterate
gen	     ind_literacy = (hh_c05a !=1) & (hh_c05b !=1) if age_15_17 ==1
lab var  ind_literacy "Ilitrate (15-17 years)"
* ------------------------------------------------------------------------------

*** Indicator ii) Not Completed Primary

* Deprived if s/he has not completed primary school (15-17 years)
* ------------------------------------------------------------------------------

tab1 hh_c08 hh_c13

gen	     ind_primary = (hh_c08 < 8) & (hh_c13 ==1) if age_15_17 ==1
lab var  ind_primary "Not completed primary (15-17 years)" 
* ------------------------------------------------------------------------------

*** Indicator iii) Not in preschool
* Deprived if s/he is not in and never went to school (5-7yrs)
* ------------------------------------------------------------------------------

tab     hh_c06 if age_5_7 ==1

gen     ind_preschool = (hh_c06 ==2) if age_5_7 ==1
lab var ind_preschool "Not in preschool (5-7 years)"
* ------------------------------------------------------------------------------

*** Indicator iv) No grade progression

* Deprived if s/he is more than 2 grades behind expected grade for age (9-17yrs)
* -----------------------------------------------------------------------------
tab1    hh_c08 hh_c13 if age_9_17 ==1

/*	(https://www.scholaro.com/db/Countries/Malawi/Education-System)
	8-4-4 system 
	Primary is from 6-14; secondary 15-18
		age 08: 01 or higher
		age 09: 02 or higher
		age 10: 03 or higher
		age 11: 04 or higher
		age 12: 05 or higher
		age 13: 06 or higher
		age 14: 07 or higher
		age 15: 08 or higher
		age 16: 09 or higher (second form 1)
		age 17: 10 or higher (second form 2) 	*/
		
gen     ind_gradeprogress =(hh_c06 ==2) if age_9_17 ==1 
 
forvalues i = 9/17 {
    local j = `i' - 7
    replace ind_gradeprogress =1 if hh_b05a == `i' & hh_c08 < `j' & hh_c13 ==1
}

lab var ind_gradeprogress "No grade progression"
tab     ind_gradeprogress if age_9_17 == 1, m
*-------------------------------------------------------------------------------

********************************************************************************

* Education Dimension - Deprivation in at least one indicator (5-17 years)
********************************************************************************
gen     dim_education = ind_literacy==1 | ind_primary==1 | ind_preschool==1 ///
           | ind_gradeprogress==1 if inrange(hh_b05a,5,17)
		
lab var dim_education "Education dimension deprivation"
********************************************************************************
********************************************************************************
**# 5: INFORMATION DIMENSION
********************************************************************************

* ------------------------------------------------------------------------------

*** Indicator i) No information devices

* Deprived if in the HH there is no TV, Radio (with flash driv/micro SD), phone,
* mobile phone, PC, or satelite dish (5-17 years)
* ------------------------------------------------------------------------------

tab1     inforasset hh_f34 if age_5_17==1, m
gen      ind_information = (inforasset==0) & (hh_f34==0) if age_5_17==1
lab var  ind_information "No information devices (5-17 years)"
* ------------------------------------------------------------------------------

* Information Dimension - Deprivation in the information indicator
********************************************************************************
gen     dim_information = ind_information == 1 if inrange(hh_b05a,5,17)
		
lab var dim_information "Information dimension deprivation"
********************************************************************************

********************************************************************************
**# 6: WATER DIMENSION
********************************************************************************	
* ------------------------------------------------------------------------------

*** Indicator i) Unimproved drinking water

* Deprived if HH uses open well in yard/plot, open public well, river/stream, 
* pond/lake, dam, tanker truck/bowser, bottled water, unprotected stream in 
* either dry or wet season
* ------------------------------------------------------------------------------

tab1    hh_f36 hh_f40, m

gen     ind_watersource = inlist(hh_f36,4,5,10,11,14,16)     if hh_b05a <18
replace ind_watersource = 1 if inlist(hh_f36,4,5,10,11,14,16) & hh_b05a <18
lab var ind_watersource   "Unimproved drinking water (0-17 years)" 
* ------------------------------------------------------------------------------

*** Indicator ii) 30 minutes to water source

* Deprived if it takes 30 minutes one way on foot to reach water source
* ------------------------------------------------------------------------------

codebook hh_f38a hh_f38b

*Convert hrs to minutes
clonevar watermin = hh_f38a     if hh_f38b == 1
replace  watermin = hh_f38a *60 if hh_f38b == 2

gen      ind_waterminutes = watermin > 30  if !missing(hh_f38b) & hh_b05a <18
lab var  ind_waterminutes   "30 minutes to water (0-17 years)"
tab      ind_waterminutes if hh_b05a <18, m

*Treating those with missing, 0 for those with water source within vicinity  
tab      hh_f36 if missing(hh_f38b) & hh_b05a <18

replace  ind_waterminutes = 0 if  (inlist(hh_f36, 1,2,4,6) | hh_f38a==99)    ///
                 & missing(hh_f38b) & hh_b05a <18
			 
replace  ind_waterminutes = 1 if !inlist(hh_f36, 1,2,4,6)                   ///
                 & missing(hh_f38b) & hh_b05a <18
			 
tab      ind_waterminutes if hh_b05a <18, m
* ------------------------------------------------------------------------------

* Water Dimension - Deprivation in at least one indicator
********************************************************************************
gen     dim_water = ind_watersource ==1 | ind_waterminutes ==1  if hh_b05a <18		
lab var dim_water "Water dimension deprivation"
********************************************************************************


********************************************************************************
**# 7: SANITATION DIMENSION
********************************************************************************	
* ------------------------------------------------------------------------------
*** Indicator i) Unimproved sanitation

* Deprived if HH uses flush to open drain, pit latrine without slab/open pit, 
* bucket, hanging toilet/latrine, no facility/bush/field
* ------------------------------------------------------------------------------

/*  Options differ from those in 2019 wave; more detailed in 2019
	2013 has the following only; 
		1. FLUSH TOILET 
        2. VIP LATRINE 
		3. TRADITIONAL LATRINE WITH ROOF 
		4. TRADITIONAL LATRINE WITHOUT ROOF 
        5. NONE
        6. OTHER		
* Therefore, deprived if HH uses toilet without, or no toilet, or other   */
		
tab      hh_f41 if hh_b05a <18, m

gen      ind_sanitation = (hh_f41>3) if hh_b05a <18
lab var  ind_sanitation   "Unimproved sanitation (0-17 years)"
tab      ind_sanitation if hh_b05a <18, m
* ------------------------------------------------------------------------------

* Sanitation Dimension - Deprivation in the sanitation indicator
********************************************************************************
gen     dim_sanitation = ind_sanitation ==1 if hh_b05a <18		
lab var dim_sanitation "Sanitation dimension deprivation"
********************************************************************************


********************************************************************************
**# 8: HOUSING DIMENSION
********************************************************************************	
* ------------------------------------------------------------------------------
*** Indicator i) Inadequate roof/floor
* Deprived if dwelling has floor of sand/smoothed mud or other and roof made of 
* grass, plastic sheeting or other material
* ------------------------------------------------------------------------------

tab1     hh_f08 hh_f09 if hh_b05a <18, m

gen      ind_roofflow = inlist(hh_f08, 1,6) & inlist(hh_f09, 1,2,.)        ///
             if hh_b05a <18
			 
lab var  ind_roofflow   "Inadequate roof/floor (0-17 years)"

* ------------------------------------------------------------------------------
*** Indicator ii) Overcrowding
* Deprived if HH has more than 4 members (plus servants if HH member) per room
* ------------------------------------------------------------------------------

codebook hh_f10

bys y2_hhid: gen hsize = _N

lab var  hsize "Household size"
gen 	 ind_crowding = hsize/hh_f10 > 4
lab var  ind_crowding   "Overcrowding (0-17 years)"

* Housing Dimension - Deprivation in the sanitation indicator
********************************************************************************
gen      dim_housing = ind_roofflow ==1 | ind_crowding ==1 if hh_b05a <18		
lab var  dim_housing   "Housing dimension deprivation"
********************************************************************************

* Value label for indicators and dimensions
lab def  deprivation 1 "Deprived" 0 "Not deprived"
lab val  dim_*  ind_* deprivation
* ------------------------------------------------------------------------------


********************************************************************************
**# 9: MULTIPLE DEPRIVATION EXPERIENCE
********************************************************************************
egen     deprivation_count = rowtotal(dim_nutrition dim_health               ///
             dim_protection dim_education dim_information dim_water          ///
             dim_sanitation dim_housing)
			 
lab var  deprivation_count "Number of deprivations experienced"
* ------------------------------------------------------------------------------
*_______________________________________________________________________________


********************************************************************************
** Retain only derived data
********************************************************************************
gen     year = 2013, b(y2_hhid)
lab var year "Year"

order   hsize dim_nutrition dim_health dim_protection dim_education          ///
           dim_information dim_water dim_sanitation dim_housing, b(ind_stunted)

preserve

qui     ds(reside interview_status qx_type hh_* hhsize agemonths measure     ///
			inforasset watermin econ_act chore_a chore_b hhchore region_    ///
			haz06 waz06 whz06 bmiz06 age_*), not
		 
keep  `r(varlist)'

	keep    if flag_0_17 == 1
	drop    flag_0_17
	save    "${pathout}/cmdpi-2013.dta", replace    	

restore

********************************************************************************

*_______________________________________________________________________________

********************************************************************************

********************************************************************************
************    		PART 2: HOUSEHOLD CHARACTERISTICS     		************
************                	 						            ************
********************************************************************************
*_______________________________________________________________________________

*_______________________________________________________________________________


qui     ds(age_0_23m age_24_59m age_6_59m age_5_7 age_5_14 age_5_11          ///
        age_12_14 age_5_17 age_9_17 age_12_17 age_15_17 age_15_16 haz06      ///
		waz06 whz06 bmiz06 econ_act chore_a chore_b hhchore labor_15_17      ///
		deprivation_count cat_age ind_* dim_* flag_0_17 region_ watermin     ///
		agemonths measure inforasset), not
		
keep   `r(varlist)'
         
********************************************************************************	
* Household characteristics	
********************************************************************************

* Head of household 

gen       hoh = hh_b04 == 1
label var hoh "Head of household"

* Age (years)

gen       age_head  = hh_b05a if hh_b04 == 1 
label var age_head  "Age of head (years)"
	
gen       ageSpouse = hh_b05a if hh_b04 == 2
label var ageSpouse "Age of spouse (years)"

gen       ageheadsq = age_head^2
label var ageheadsq "Squared age of the head"

* Sex of houehold head

gen       male_head = hh_b03 == 1 & hh_b04 == 1

* Marital status of househod head

gen       mstatus1    = hh_b24 == 1 & hh_b04 == 1   		//monogamous
gen       mstatus2    = hh_b24 == 2 & hh_b04 == 1   		//polygamous
gen       mstatus3    = inlist(hh_b24, 3, 4) & hh_b04 == 1  //separated/divorced
gen       mstatus4    = hh_b24 == 5 & hh_b04 == 1   		//widow(er)
gen       mstatus5    = hh_b24 == 6 & hh_b04 == 1   		//never married
gen       marriedhead = mstatus1 == 1 | mstatus2 == 1   	//any type
	
	
*********************************************************************************	
* Household demographics (size, adult equivalent units, dep ratio, etc).
*********************************************************************************	

* Create gender ratio for households
gen       male   = (hh_b03 == 1)
label var male "1 = Male hh member"
	
gen       female = (hh_b03 == 2)
label var female "1 = Female hh member"

egen      msize = total(male), by(y2_hhid)
label var msize "Number of males in hh"

egen fsize = total(female), by(y2_hhid)
label var fsize "Number of females in hh"

* A gender ratio variable
gen       genderMix = msize/fsize
recode    genderMix (. = 0) if fsize==0
label var genderMix "Ratio of males to females (1 = 1:1 mix)"

* Literacy
* Can read and write in any language

tab1 	  hh_c05a hh_c05b
gen       literateHoh    = (hh_c05a==1) & (hh_c05b == 1) if hoh    == 1
gen       literateSpouse = (hh_c05a==1) & (hh_c05b == 1) if hh_b04 == 2

label var literateHoh "Hoh is literate"
label var literateSpouse "Spouse is literate"

* Calculate age demographics (Youth)
* Make cuts at 0-5; 6-9; 10-14; 15-17; 18-24; 25-30; 31-35;
* Malawi definition of youth is 10-35 years (National Youth Policy (2023-2028))
* https://www.youth.gov.mw/index.php/resource-centre/youth-resources/national-youth-policy
  
egen  youthtmp    = cut(hh_b05a), at(0, 6, 10, 15, 18, 25, 31, 36) icodes
table hh_b05a  youthtmp

* Create binary variables for demographic categories
gen  under5tmp      = inlist(youthtmp, 0)             
gen  under15tmp     = inlist(youthtmp, 0, 1, 2)       
gen  under24tmp     = inlist(youthtmp, 0, 1, 2, 3, 4) 
gen  youth15to24tmp = inlist(youthtmp, 3, 4)          
gen  youth18to30tmp = inlist(youthtmp, 4, 5)
gen  youth10to35tmp = inlist(youthtmp, 3, 4, 5, 6)      
gen  child0to17tmp  = inlist(youthtmp, 0, 1, 2, 3)

* Create total, male and female totals at the household level of each demographic

local demo under5 under15 under24 youth15to24 youth18to30 youth10to35 child0to17

foreach x of local demo {
    egen `x'  = total(`x'tmp), by(y2_hhid)
    egen `x'm = total(`x'tmp) if male   == 1, by(y2_hhid)
    egen `x'f = total(`x'tmp) if female == 1, by(y2_hhid)
	
	label var `x'  "Total hh members `x'"
	label var `x'm "Total male hh members `x'"
	label var `x'f "Total female hh members `x'"
}	
	

/* HH dependency ratio

    HH Dependecy Ratio = [(# people 0-14 + those 60+) / # people aged 15-60] * 100 
 
    The dependency ratio is defined as the ratio of the number of members in 
	the age groups of 0 - 14 years and above 60 years to the number of members 
	of working age (15 years - 60 years).
	
    The ratio is normally expressed as a percentage (data below are multiplied 
	by 100 for pcts.*/
	
gen  numDepRatio      = (hh_b05a < 15 | hh_b05a > 60) 
gen  demonDepRatio    = numDepRatio != 1        
egen totNumDepRatio   = total(numDepRatio),   by(y2_hhid)
egen totDenomDepRatio = total(demonDepRatio), by(y2_hhid)

* Check that numbers add to hh size

assert    hsize  == totNumDepRatio + totDenomDepRatio
drop      hhsize
rename    hsize hhsize
gen       depRatio = (totNumDepRatio/totDenomDepRatio)*100 if totDenomDepRatio!=.
recode    depRatio   (. = 0) if totDenomDepRatio==0
label var depRatio   "Dependency Ratio"

drop numDepRatio demonDepRatio totNumDepRatio totDenomDepRatio
 
* Household Labor Shares  (ages 12 - 60)
gen       hhLabort = inrange(hh_b05a, 15, 60) 
egen      hhlabor  = total(hhLabort), by(y2_hhid)
label var hhlabor  "hh labor age (15 to 60 years)"

gen       mlabort  = (inrange(hh_b05a, 15, 60) & male == 1)
egen      mlabor   = total(mlabort), by(y2_hhid)
label var mlabor   "hh male labor age (15 to 60 years)"

gen       flabort  = (inrange(hh_b05a, 15, 60) & female == 1)
egen      flabor   = total(flabort), by(y2_hhid)
label var flabor   "hh female labor age (15 to 60 years)"
	
drop hhLabort mlabort flabort

* Male/Female labor share in hh
gen       mlaborShare = mlabor/hhlabor
recode    mlaborShare (. = 0) if hhlabor == 0
label var mlaborShare "Share of working age males in hh"

gen       flaborShare = flabor/hhlabor
recode    flaborShare (. = 0) if hhlabor == 0
label var flaborShare "Share of working age females in hh"

* % of hh females aged 20-34 & 35 - 59
gen       fem20_34tmp   = (hh_b05a>=20 &hh_b05a<35) & (female == 1)
gen       fem35_59tmp   = (hh_b05a>=35 &hh_b05a<60) & (female == 1)
	
egen      femCount20_34 = total(fem20_34tmp), by(y2_hhid)
egen      femCount35_59 = total(fem35_59tmp), by(y2_hhid)
	
gen       femRatio20_34 = femCount20_34/hhsize
gen       femRatio35_59 = femCount35_59/hhsize

label var femRatio20_34 "Share of females in hh 20-34"
label var femRatio35_59 "Share of females in hh 35-59"

drop      fem20_34tmp fem35_59tmp femCount20_34 femCount35_59

* Generate adult equivalents in household
gen       male10   = 1
gen       fem10_19 = 0.84
gen       fem20    = 0.72
gen       child10  = 0.60

gen       ae = .
replace   ae = male10   if (hh_b05a >= 10) & male   == 1
replace   ae = fem10_19 if (hh_b05a >= 10  & hh_b05a < 20)  & female == 1
replace   ae = fem20    if (hh_b05a >= 20) & female == 1
replace   ae = child10  if (hh_b05a) < 10  
label var ae "Adult equivalents in household"

egen      adultEquiv = total(ae), by(y2_hhid)
label var adultEquiv "Total adult equivalent units"

********************************************************************************
* Orphans - If either father, mother or both are dead (Children under 18)
********************************************************************************
gen       orphan   = (hh_b16==98) | (hh_b19==98) if hh_b05a < 18
egen      orphanhh = total(orphan), by(y2_hhid)
label var orphan   "1 = child is an orphan"
label var orphanhh "Total number of orphans in hh"
	
* Education level 
*	https://www.scholaro.com/db/Countries/Malawi/Education-System		

tab1       hh_c06 hh_c08	, m
tab        hh_c06    if hh_c08 == .

gen       educ = . 
label var educ "Education levels"
	
*   No education (This includes those who never attended school)
replace educ = 0 if hh_c06 == 2
	
*   Pre-primary/Nursery
replace educ = 1 if hh_c08 == 0
	
*   Primary
replace educ = 2 if inrange(hh_c08, 1, 8)
	
*   Secondary 
replace educ = 3 if inrange(hh_c08, 9, 14)

*   Techincal/Vocational 
replace educ = 4 if inrange(hh_c08, 20, 23)
	
*   Tertiary
replace educ = 5 if inrange(hh_c08, 15, 19)
		
gen educHoh    = educ if hoh    == 1
gen educSpouse = educ if hh_b04 == 2 

lab def ed 0 "No education"                    ///
	       1 "Pre-primary/Nursery"             ///
		   2 "Primary"                         ///
		   3 "Secondary"                       ///
		   4 "Technical/Vocational"            ///
		   5 "Tertiary"
			   
label val  educ educHoh educSpouse ed

* Create variable to reflect the maximum level of education in the household for those 18+
egen educAdult  = max(educ) if hh_b05a>17, by(y2_hhid)
egen educAdultM = max(educ) if hh_b05a>17 & male   == 1, by(y2_hhid)
egen educAdultF = max(educ) if hh_b05a>17 & female == 1, by(y2_hhid)

* Max youth education in hh
egen educYouth  = max(educ) if youth10to35tmp == 1, by(y2_hhid)
egen educYouthM = max(educ) if youth10to35tmp == 1 & male   == 1, by(y2_hhid)
egen educYouthF = max(educ) if youth10to35tmp == 1 & female == 1, by(y2_hhid)

* Apply value labels
local edlist educ educHoh educSpouse educAdult educAdultM educAdultF ///
educYouth educYouthM educYouthF
	
foreach x of local edlist {
	replace   `x' = 0 if hh_c06 == 2
	label val `x' ed
}

label var educAdult  "Highest adult (18+ years) education in household"
label var educAdultM "Highest male adult (18+ years) education in household"
label var educAdultF "Highest female adult (18+ years) education in household"
label var educHoh    "Education of houehold head"
label var educSpouse "Education of spouse"
label var educYouth  "Max education of youth (10-35 years)"
label var educYouthM "Max education of male youth (10-35 years)"
label var educYouthF "Max education of female youth (10-35 years)"

/* Occupation of Hoh and Spouse
gen       occupHoh    = hh_e13_1a if hh_b04 ==1
gen       oocupSpouse = hh_e13_1a if hh_b04 ==2
label var occupHoh      "Main activity of houehold head"
label var oocupSpouse   "Main activity of spouse"
	*/

drop      youthtmp under5tmp under15tmp under24tmp youth15to24tmp        ///
          youth18to30tmp male10 fem10_19 fem20 child10 youth10to35tmp	 ///
		  child0to17tmp  

* Retain only derived data for collapsing
qui       ds(hh_*  educ ae), not
keep      `r(varlist)'


save "${pathout}/hhold-char-ind-2013.dta", replace    	


* Collapse everything down to HH-level using max values for all vars
* Copy variable labels to reapply after collapse
qui include "$pathdo/copylabels.do"

qui ds(y2_hhid case_id HHID ea_id PID hhmember baselinemember       ///
    baselinemembercount individualmover moverbasehh), not
     
collapse (firstnm) HHID case_id ea_id (max) `r(varlist)', by(y2_hhid) 

* Reapply variable lables & value labels
qui include "$pathdo/attachlabels.do"
	
* Summarize collapsed data and review for potential coding errors
sum

* Check missing values and determine which ones can be replaced with zero
mdesc, abbr(20)
	
foreach x of varlist youth* under* {
	replace `x' = 0 if `x' == .
}

* label 
foreach x of varlist  educHoh educSpouse educAdult educAdultM educAdultF educHoh educSpouse {
	label values `x' ed
	tab `x'
	}
	
label var age_head    "Age of household head (years)"
label var male_head   "1 = Male head of househod"
label var literateHoh "1 = Literate head of household"
label var mstatus1    "1 = Monogamous head of household"	
label var mstatus2    "1 = Polygamous head of household"	
label var mstatus3    "1 = Separated/divorced head of household"	
label var mstatus4    "1 = Didow(er) head of household"	
label var mstatus5    "1 = Never married head of household"	
label var marriedhead "1 = Married head of household"
	
save "${pathout}/hhold-char-2013.dta", replace 


log2html "$pathlog/01_cmdpi_2013", replace
log close
exit
