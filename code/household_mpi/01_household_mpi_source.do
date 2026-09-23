/*******************************************************************************
************       HOUSEHOLD MULTIDIMENSIONAL POVERTY INDEX        ********
************       Malawi IHS household-level implementation      ********
********************************************************************************
# Name:			Household MPI construction

# Purpose:		Constructs household deprivation indicators, applies indicator
#               weights and identifies multidimensionally poor households.
			
# Creates: 		Household-level analytical file containing MPI indicators

# Created by:	Lonjezo Erick Folias, Jan 2025

# Updated by:  	Lonjezo Erick Folias, Jan 2025

# Owner:		Lonjezo Erick Folias / Everest Intelligence Consult (EIC)

# Repository version:	Prepared and documented by Lonjezo Erick Folias, EIC, 2026

*******************************************************************************/



********************************************************************************
*** Table of Contents
********************************************************************************







********************************************************************************
**# Globals, Macros, Paths, and Ados
********************************************************************************

*Ados

 	local user_commands winsor mkdir  factortest ietoolkit iefieldkit movestay asdoc  codebookout confirmdir zscore06 mpi switch_probit movestay bicop
	  
	foreach command of local user_commands {
		   cap which `command'
		   if _rc == 111 {
			   ssc install `command'
		   }
		   else disp "`command' already installed, moving to the next command line"
	 }
	  
	  
	  
* Project folder : Note ! - make sure the replaced path has / AND not \

	global projectpath C:/Users/Lonje Folias/Documents/Manu Scripts/Climate 
	
	cd "$projectpath"

	
*Creating project folders

    local mainfolder `""Data and Do file""'
	
    foreach dir in `mainfolder' {
        confirmdir "`dir'"
        if `r(confirmdir)'==170 {
            mkdir "`dir'"
            display in yellow "Project directory named: `dir' created"
            }
        else disp as error "`dir' already exists. Skipped to next command."
        cd "${projectpath}/`dir'"
    }

	
*Creating subfolders
    local subfolders `" "IHSV" "Working files"  "Do" "Weather Data" "'
	

    foreach dir in `subfolders' {
        confirmdir "`dir'"
        if `r(confirmdir)'==170 {
            mkdir "`dir'"
            disp in yellow "`dir' successfully created."
        }
        else disp as error "`dir' already exists. Skipped to next command."
    }

****NOTE : You need to Manually  Copy the IHSIV data to the "IHSIV" folder 	
**************************************************************************
	
* Path globals
	global data				"${projectpath}/Data and Do file/IHSV"
	global workingfiles		"${projectpath}/Data and Do file/Working files"
	global do 				"${projectpath}/Data and Do file/do"
	global weatherdata 		"${projectpath}/Data and Do file/Weather Data"
	
	
	global deprivations dep_educ_1 dep_educ_2 dep_health_1 dep_health_2 dep_health_3 dep_health_4 dep_env1 dep_env2 dep_env3 dep_empl_1 dep_empl_2 dep_empl_3 dep_env4
	 
********************************************************************************
**# Survey Data Management
********************************************************************************



	
use "${data}/hh_mod_b.dta", clear 
		
		*merging with pertinent modules 
		merge 1:1 	case_id  PID 	using 	"${data}/hh_mod_c.dta", 		nogen 
		merge m:1 	case_id  		using 	"${data}/hh_mod_a_filt.dta", 	nogen 
		merge m:1 	case_id	 	  	using 	"${data}/hh_mod_f.dta", 		nogen 
		merge 1:1 	case_id  PID 	using 	"${data}/hh_mod_v.dta", 		nogen 
		merge 1:1 	case_id  PID 	using 	"${data}/hh_mod_e.dta", 		nogen 
		merge m:1 	case_id  	 	using 	"${workingfiles}/asset.dta", 	nogen 
		merge m:1 	case_id  	 	using 	"${data}/hh_mod_a_filt.dta", 	nogen		
		merge m:1 	case_id			using	"${data}/hh_mod_t.dta", 		nogen 
		merge m:1 	case_id			using	"${data}/householdgeovariables_ihs5.dta", 		nogen 

	
		********************************************************************************
	**# HH demo vars
		********************************************************************************
		
		*Age
		bysort 		case_id: g  	age=hh_b05a 		if 	hh_b04==1 

		*Dependancy ratio		
		bysort 	case_id: 	egen 	a=count(PID) 		if  hh_b05a<=14  | hh_b05a>64
		bysort 	case_id: 	egen	dependants=max(a) 	
		
		bysort 	case_id: 	egen 	b=count(PID) 		if 	hh_b05a>14	 & hh_b05a<=64
		bysort 	case_id: 	egen	working=max(b) 
		
		recode	 dependants (.=0)	
		recode 	 working	(.=1)
		
		g	 	 dependency=(dependants/working)
		
		*HH_Size
		bysort 	 case_id: 	 egen 	hh_size=count(PID)

		*Alduts
		bysort  case_id: 	 egen   alduts=count(PID) 	if hh_b05a>=15
		
		*Maritial 
		bysort case_id: 	 g  	marital=hh_b24 		if hh_b04==1
		
		
		*Gender
		bysort case_id: 	 g  	gender=hh_b03 		if hh_b04==1
		
		*Years in the Village
		bysort case_id: 	 g  	years_village=hh_b12 if hh_b04==1
		replace years_village=age 	if  missing( hh_b12 )
		
		*Education
		bysort case_id: g  educ=hh_c08 if hh_b04==1
		
		********************************************************************************
	**# HH MPI Indictors 
		********************************************************************************
		
*Education
			
			/*A household is deprived if all members aged 15+ have
			*less than 8 years of schooling OR cannot read or write
			English or Chichewa
			
			There is no variable asking the exact years spend on education
			Therefore, I make the strong assumption that getting to STD 8 
			is above the above defined assumption*/
			
			
			g 		lessstd8=1		if		((hh_b05a>=15)		& 	(hh_c08<8))
			g 		cannotread=1	if 		((hh_b05a>=15)		& 	(hh_c05_1==2))
			g 		deped=1 		if 		lessstd8==1			| 	cannotread==1
			
			
			// counting the above created conditions per HH
			bysort		case_id:	egen hh_15_counta=count(PID)		if 	hh_b05a>=15
			bysort		case_id:	egen depedcounta=count(PID)			if 	deped==1 	
			
			foreach 	var 	in 	hh_15_count depedcount {
				bysort	case_id:	egen `var'=count(`var'a)
			}
			
			bysort 		case_id:	g	 dep_educ_1=1 	if		hh_15_count==depedcount 
		
		
			/*A household is deprived if at least one child aged 6–14 is
			not attending school*/
			g 		attendance=1 	if 	((inrange(hh_b05a, 6, 14)) & hh_c13==2)
			bysort 		case_id:	egen	 dep_educ_2=max(attendance) 
			
			
*Health and Population

			/*A household is deprived if the sanitation facility is not
			flush or a VIP latrine or a latrine with a roof OR if it is
			shared with other households*/
			
			g		  latrine=1 	if 	(inrange(hh_f41, 8, 13)) | hh_f41_4==1
			bysort 		case_id:	egen	 dep_health_1=max(latrine) 
			
			
			/*A household is deprived if there is at least one child
			under 5 who is either underweight, stunted, or wasted*/
			
			gen 	 agemonths =hh_b05b     if hh_b05a ==0
			replace  agemonths =hh_b05b +12 if hh_b05a ==1
			replace  agemonths =hh_b05b +24 if hh_b05a ==2
			replace  agemonths =hh_b05b +36 if hh_b05a ==3
			replace  agemonths =hh_b05b +48 if hh_b05a ==4

						
			*** Create child age-group dummies

			* 0-23 months
			gen 	age_0_23m = (agemonths <= 23)        if hh_b05a <18

			* 24-59 months
			gen 	age_24_59m= inrange(agemonths,24,59) if hh_b05a <18
			
			* Generate z-scores for stunting, underweight and wasting for children under 5
			* using 'zscore06' the 2006 WHO child growth standards 
		

			* Age of child in months, a()
			sum      agemonths

			* Sex of child, s() where 1 is male and 2 is female
			tab      hh_b03

			* Height/length of child, h() in cm 
			*	Recumbent length is assumed for children <24months 
			*	While standing height for children >24 months. If not, measure() must be 
			*   specified 1 for recumbent length and 2 for standing height 

	
			tab      hh_v10 if hh_b05a <5, m
			gen 	 measure = cond(hh_v10<2,2,1) if hh_b05a <5 & !missing(hh_v10)

			* Treating missing 'measure', assuming recumbent length for 0-23 months and
			*    standing height for 24-59 months
			tab      measure if hh_b05a <5, m
			replace  measure = 1 if age_0_23m == 1 & missing(hh_v10) 
			replace  measure = 2 if age_24_59m== 1 & missing(hh_v10)
			tab      measure	

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

			* ------------------------------------------------------------------------------
			*** Indicator ii) Underweight

			* Deprived if Weight for age <-2 s.d. (0-23 months)
			* ------------------------------------------------------------------------------

			gen     ind_underweight =   (waz06 <-2) if age_0_23m ==1
			replace ind_underweight = . if waz06==. &  age_0_23m ==1

			* ------------------------------------------------------------------------------
			*** Indicator iii) Wasting

			* Deprived if weight for height <-2 s.d. (0-23 months)
			* ------------------------------------------------------------------------------

			gen      ind_wasting =   (whz06 <-2) if age_0_23m ==1
			replace  ind_wasting = . if whz06==. &  age_0_23m ==1
			* ------------------------------------------------------------------------------
						
			foreach ind in stunted underweight wasting {
				bysort 		case_id:	egen	 	`ind'=max(ind_`ind') 
			}
			
			gen 	dep_health_2=1 	if  stunted==1  | underweight==1  |  wasting==1
			
			/*A household is deprived if their main source of water is
			unimproved OR it takes 30 minutes or more (round trip)
			to collect it*/
			
			gen      	watersource= 		inlist(hh_f36,4,5,10,11,12,16,18) 
			
			foreach  string in PIPED TAP PROTECTED {
				replace watersource=. if regexm(hh_f36_oth,"`string'")
			}
			 
			replace 	watersource=1 	if 	hh_f38a>30 	& hh_f38b==1
			replace 	watersource=1 	if 	hh_f38a>1 	& hh_f38b==2
			
			bysort 		case_id:	egen	 	dep_health_3=max(watersource)
			
			
			/*A household is deprived if, in the past 12 months, they
			were hungry but did not eat AND went without eating for
			a whole day because there was not enough money or
			other resources for food*/
			
			gen      hunger= inlist( hh_t19 ,2)
			
			bysort 		case_id:	egen	 	dep_health_4=max(hunger)
			
			
			
*ENV			
			/*A household is deprived if they do not have access to
			electricity*/
			
			bysort 		case_id:	egen 		electricity=max(hh_f19) 	
			bysort 		case_id:	g			dep_env1=1 		if inlist(electricity,1)
			
			/*A household is deprived if rubbish is disposed of on a
			public heap, is burnt, disposed of by other means, or there
			is no disposal*/
			
			gen      	dep_env2= 		inlist(hh_f43,3,4,5,6) 
			
			foreach string in DISPOS SERVICE {
				replace dep_env2=. 	if	regexm(hh_f43_oth,"`string'")
			}
			
			
			/* A household is deprived if at least two of the following
			dwelling structural components are of poor quality:
				•Walls (grass, mud, compacted earth, unfired mud
				bricks, wood, iron sheets, or other materials)
				•Roof (grass, plastic sheeting, or other materials)
				•Floor (sand, smoothed mud, wood, or other materials)*/
			
			gen      	wall= 		inlist(hh_f07,1,2,3,4,7,8,9) 
			
			foreach string in CONC GLA {
				replace wall=. 	if	regexm(hh_f07_oth,"`string'")
			}
			
			
			gen      	roof= 		inlist(hh_f08,1,5,6) 
			
			foreach string in LEEDS TILES  {
				replace roof=. 	if	regexm(hh_f08_oth,"`string'")
			}
			
			gen      	floor= 		inlist(hh_f09,1,2,4,6)
			
			foreach string in CEME CONC  {
				replace floor=. 	if	regexm(hh_f09_oth,"`string'")
			}
			
			egen		agrigate=rowtotal(wall roof floor )
			
			bysort 		case_id:	g			dep_env3=1 		if agrigate>=2 
			
			
			g 		asset_1dummy=1 	if 	hh_b04a==1
			egen	asset_1=max(asset_1dummy),by(case_id)
			
			
*Employment (1/4)		

			/*A household is deprived if at least one member aged
			18–64 has not been working but has been looking for a
			job during the past 4 weeks*/
			
			g 		unempllookingfor=1		if 	(hh_e06_2==2  	| 	hh_e06_4==2	)	& 	hh_e17_1==1 & inrange(hh_b05a,18,64)

			egen 	dep_empl_1=max(unempllookingfor), 	by(case_id)
			
			/*A household is deprived if all working members are only
			engaged in farm activities, household livestock activities,
			or casual part-time work (ganyu)*/
			
			g 		ganyu=1 	if	(hh_e06_6==1 	| 	hh_e06_1a==1  |	hh_e06_1b==1 | inlist(hh_e06_8a,3,5))	& inrange(hh_b05a,18,64)
			replace ganyu=. 	if 	hh_e06_2==1  	| 	hh_e06_4==1	  | inlist(hh_e06_8a,1,2)
			
			egen 	workinga=count(PID)		if 		inrange(hh_b05a,18,64), 	by(case_id)
			egen 	wcount=	max(workinga)	, 	by(case_id)
			egen 	gcount=count(ganyu)		, 	by(case_id)
			
			g 		equal=1 	if 	wcount==gcount & !missing(wcount)
			
			egen  	dep_empl_2=max(equal)	, by(case_id)
			
			/*A household is deprived if any child aged 5–17 is
			engaged in any economic activities in or outside of the
			household*/
			g		ylabor=1 if (inlist(hh_e06_8a,1,2,5)	|	hh_e06_2==1	|	hh_e06_4==1	|	hh_e06_6==1	)	 & inrange(hh_b05a,5,17)
			
			egen  	dep_empl_3=max(ylabor)	, by(case_id)
			
			

			/*A household is deprived if they do not own more than
			two of the following basic livelihood items: radio,
			television, telephone, computer, animal cart, bicycle,
			motorbike, or refrigerator AND do not own a car or truck*/
			
			egen assets=rowtotal(assest_507 assest_5081 assest_509 assest_529 assest_516 assest_517 assest_514  assest_609 assest_610 assest_613 asset_1)
			
			g	 dummy=1	if	 assets>2 | car==1

			bysort 		case_id:	egen	 	dep_env4=max(dummy)
			
			
			
			/* Geo cordinates*/
			rename ( ea_lon_mod ea_lat_mod ) (lon lat)


			
			collapse (firstnm)  HHID ea_id (max) age hh_size alduts years_village marital dependency gender dep_* reside region district  hh_wgt hh_a02a lon lat educ, by (case_id)
		
			foreach var in dep_*{
				recode `var' (.=0)
			}

			********************************************************************************
*** Define vector 'w' of dimensional and indicator weight ***
********************************************************************************

*Health and Population / env

foreach health in dep_health_1 dep_health_2 dep_health_3 dep_health_4  dep_env1 dep_env2 dep_env3 dep_env4{
	gen w_`health' = 1/16
	}

*Education 
foreach educ in dep_educ_1 dep_educ_2 {
	gen w_`educ' = 1/8
	}

*Employment 
foreach empl in dep_empl_1 dep_empl_2 dep_empl_3 {
	gen w_`empl' = 1/12
	}

********************************************************************************
*** Generate the weighted deprivation matrix 'w' * 'g0'
********************************************************************************

foreach var of global deprivations {
	g weighted_`var'=w_`var' * `var'
}

********************************************************************************
*** Generate the vector of individual weighted deprivation count 'c'
********************************************************************************
egen	total_deprivations = rowtotal( weighted_dep_health_1 weighted_dep_health_2 weighted_dep_health_3 weighted_dep_health_4 weighted_dep_env1 weighted_dep_env2 weighted_dep_env3 weighted_dep_env4 weighted_dep_educ_1 weighted_dep_educ_2 weighted_dep_empl_1 weighted_dep_empl_2 weighted_dep_empl_3)


********************************************************************************
*** Identification step according to poverty cutoff k (33.33 ) ***
********************************************************************************
gen	mpi= (total_deprivations>=33/100)

			mpi d1(dep_health_1 dep_health_2 dep_health_3 dep_health_4) d2( dep_educ_1 dep_educ_2) d3(dep_env1 dep_env2 dep_env3 dep_env4) d4(dep_empl_1 dep_empl_2 dep_empl_3) w1(0.0625 0.0625 0.0625 0.0625) w2(0.125 0.125) w3(0.0625 0.0625 0.0625 0.0625) w4(0.0833333333333333 0.0833333333333333 0.0833333333333333), cutoff(0.33)
	
	drop w_* weighted_* total_deprivations 
	
save  "${workingfiles}/a.dta", replace
