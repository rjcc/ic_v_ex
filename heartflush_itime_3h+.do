* Crude comparison between EX vs IC
* Only cases with ISCHTIME >= 3h

global dirname "c:\data_work"
global dataname heart_data
cd $dirname
include _init
* use "$dirname/$dataname", clear
* drop if ISCHTIME<3

program km
args e fu grp unit event
replace `fu'=0.1 if `fu'==0
stset `fu', failure(`e') scale(`unit')
sts test `grp'
local pv = "0" + substr(string(chi2tail(`r(df)', `r(chi2)')),1,5)
sts graph, failure ytitle(Proportion of Event) ///
    ylabel(, angle(horizontal)) ///
    xlabel (0(6)66) ///
    xtitle(Month) by(`grp') title (Kaplan-Meier Incidence of `event') ///
	  caption ("Log-rank test p = `pv'") ///
    subtitle(Ischemia >= 3 Hours for Jan 2015 ~ Oct 2021) ///
    risktable (0(12)66)
graph export km_3h_up_`e'_`grp'.pdf, replace
graph export km_3h_up_`e'_`grp'.jpg, replace

end

program heartflush
args n
use "$dirname/$dataname", clear
drop if FLUSH`n'==""
drop if ISCHTIME<3
local logname heartFLUSH`n'_3h_up
log using `logname', smcl replace

tab FLUSH FLUSH`n'

* To check the effect of different FLUSH`n' solutions on the outcomes of heart transplant


* Grouping setting 1: FLUSH1: CELSIOR, DELNIDO, HTK, UW, vs. OTHERS
* Grouping setting 2: FLUSH2: CELSIOR, HTK, vs. UW
* Grouping setting 3: FLUSH3: CELSIOR, HTK, UW, vs. OTHERS
* Grouping setting 4: FLUSH4: CELSIOR, HTK, UW, vs. OTHERS’ (including DELNIDO)
* Grouping setting 5: FLUSH5: UW vs. non-UW
* Grouping setting 6: FLUSH6: EX (CELSIOR & HTK & DELNIDO)) vs. IC (UW)

*
* Variables:
* Preop donor:
* CLAMP_DATE yr_donor HR_DISCARD_CD HR_DISCARD_CD_OSTXT HR_DISPOSITION ABO_DON AGE_DON BMI_DON_CALC COVID19_ANTIBODY_TESTRESULT COVID19_ANTIGEN_TESTRESULT COVID19_NAT_TESTRESULT GENDER_DON
* Preop recipient:
* GENDER AGE BMI_CALC BMI_DON_CALC PREV_TX FUNC_STAT_TCR IABP_TCR ECMO_TRR FUNC_STAT_TRR IABP_TRR DISTANCE ISCHTIME LIFE_SUP_TRR GENDER_DON2 AGE_DON2

* Endpoint, short-term:
* ECMO_72HOURS INTUBATED_72HOURS LOS
* POST_TX_VENT_SUPPORT, REINTUBATED

* Endpoint, long-term:
* GSTATUS GTIME PTIME PSTATUS COMPOSITE_DEATH_DATE TRTREJ1Y FUNC_STAT_TRF PX_STAT PX_STAT_DATE
* COD COD_OSTXT COD2


* Plans:
* Univariate:
* Preop donor by FLUSH`n', preop recipient by FLUSH`n', endpoint1 by FLUSH`n', endpoint2 by FLUSH`n'

* Multivariate:
* Select some endpoints to check, with the covariates adjusted for ISCHTIME

* Preop Donor
ca FLUSH`n' yr_donor
* ca FLUSH`n' HR_DISPOSITION
ca FLUSH`n' ABO_DON
co3 FLUSH`n' AGE_DON
ca FLUSH`n' GENDER_DON
co3 FLUSH`n' BMI_DON_CALC
* ca FLUSH`n' COVID19_ANTIBODY_TESTRESULT
* ca FLUSH`n' COVID19_ANTIGEN_TESTRESULT
* ca FLUSH`n' COVID19_NAT_TESTRESULT
* ca FLUSH`n' GENDER_DON

* Preop recipient
ca FLUSH`n' GENDER
co3 FLUSH`n' AGE
co3 FLUSH`n' BMI_CALC
co3 FLUSH`n' BMI_DON_CALC2
ca FLUSH`n' PREV_TX
* ca FLUSH`n' FUNC_STAT_TCR
ca FLUSH`n' IABP_TCR
ca FLUSH`n' ECMO_TRR
* ca FLUSH`n' FUNC_STAT_TRR
ca FLUSH`n' IABP_TRR
co3 FLUSH`n' DISTANCE
co3 FLUSH`n' ISCHTIME
ca FLUSH`n' LIFE_SUP_TRR
* ca FLUSH`n' GENDER_DON2
* co3 FLUSH`n' AGE_DON2

* Endpoint, short-term
disp "ECMO_72HOUR: Data N/A"
ca FLUSH`n' ECMO_72HOURS
disp "INTUBATED_72HOURS: Data N/A"
ca FLUSH`n' INTUBATED_72HOURS
co3 FLUSH`n' LOS
disp "POST_TX_VENT_SUPPORT: Data N/A"
* co3 FLUSH`n' POST_TX_VENT_SUPPORT
ca FLUSH`n' POST_TX_VENT_SUPPORT
disp "REINTUBATED: Data N/A"
* co3 FLUSH`n' REINTUBATED

* Endpoint, short-term, 30-day-graft-Graft_Failure
gen gf30d=1 if GTIME<=30 & GSTATUS==1
replace gf30d=0 if gf30d==.
ca FLUSH`n' gf30d
drop gf30d

* Endpoint, short-term, 30-day-graft-Patient_Death
gen pf30d=1 if PTIME<=30 & PSTATUS==1
replace pf30d=0 if pf30d==.
ca FLUSH`n' pf30d
drop pf30d

* Endpoint, long-term
km GSTATUS GTIME FLUSH`n' 30 Graft_Failure
km PSTATUS PTIME FLUSH`n' 30 Patient_Death

* Endpoint, long-term
* K-M curves
* ca FLUSH`n' GSTATUS
* co3 FLUSH`n' GTIME
* ca FLUSH`n' PSTATUS
* co3 FLUSH`n' PTIME
ca FLUSH`n' TRTREJ1Y
* ca FLUSH`n' FUNC_STAT_TRF
* ca FLUSH`n' PX_STAT

log close
* translate `logname'.smcl `logname'.pdf, replace
log2html `logname', replace erase linesize(255)
end

* heartflush 1
* heartflush 2
* heartflush 3
* heartflush 4
heartflush 5
heartflush 6


local logname heartFLUSH_3h_up_los
log using `logname', smcl replace
* co3 FLUSH1 LOS
* co3 FLUSH2 LOS
* co3 FLUSH3 LOS
* co3 FLUSH4 LOS
* co3 FLUSH5 LOS
co3 FLUSH6 LOS
log close
* translate `logname'.smcl `logname'.pdf, replace
log2html `logname', replace erase linesize(255)


* exit, clear STATA
