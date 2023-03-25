* Matched for ISCHTIME
* Done by adjusting for ISCHTIME by multivariate regression models

global dirname "c:\data_work"
global dataname heart_data
cd $dirname
include _init
*use "$dirname/$dataname", clear
*drop if FLUSH`n'==""

program km_adj
args e fu grp unit event adj
replace `fu'=0.1 if `fu'==0
stset `fu', failure(`e') scale(`unit')
sts test `grp', strata(`adj')
local pv = "0" + substr(string(chi2tail(`r(df)', `r(chi2)')),1,5)
sts graph, failure ytitle(Proportion of Event) ///
    ylabel(, angle(horizontal)) ///
    xlabel (0(6)66) ///
    xtitle(Month) by(`grp') title (Kaplan-Meier Incidence of `event') ///
	  caption ("Log-rank test p = `pv'") ///
    adjustfor(`adj') ///
    subtitle(Adjusted for `adj' for Jan 2015 ~ Oct 2021)  
*   risktable (0(12)66)...unable to combine with adjustfor()
encode `grp', generate (`grp'a)
stcox `grp'a ISCHTIME
drop `grp'a
graph export km_`e'_`grp'_match.pdf, replace
end

program ilca
args x y
encode `x', generate (`x'a)
encode `y', generate (`y'a)
mlogit `y'a `x'a ISCHTIME
tab `x' `y', row
drop `y'a `x'a
end

program ilca2
args x y
encode `x', generate (`x'a)
mlogit `y' `x'a ISCHTIME
tab `x' `y', row
drop `x'a
end

program ilco
args x y
encode `x', generate (`x'a)
reg `y' `x'a ISCHTIME
tabstat `y', by(`x'a) stat(n mean sd med iqr)
drop `x'a
end

program heartflush_i
args n
use "$dirname/$dataname", clear
drop if FLUSH`n'==""
local logname heartFLUSH`n'_match
log using `logname', smcl replace

tab FLUSH FLUSH`n'

* To check the effect of different FLUSH`n' solutions on the outcomes of heart transplant

* Grouping setting 1: FLUSH1: CELSIOR, DELNIDO, HTK, UW, vs. OTHERS
* Grouping setting 5: FLUSH5: UW vs. non-UW
* Grouping setting 6: FLUSH6: EX (CELSIOR & HTK & DELNIDO)) vs. IC (UW)

* Matched on ISCHTIME

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


* Preop Donor
ca FLUSH`n' yr_donor
* ca FLUSH`n' HR_DISPOSITION
ca FLUSH`n' ABO_DON
ilco FLUSH`n' AGE_DON
ilca FLUSH`n' GENDER_DON
ilco FLUSH`n' BMI_DON_CALC
* ca FLUSH`n' COVID19_ANTIBODY_TESTRESULT
* ca FLUSH`n' COVID19_ANTIGEN_TESTRESULT
* ca FLUSH`n' COVID19_NAT_TESTRESULT
* ca FLUSH`n' GENDER_DON

* Preop recipient
ilca FLUSH`n' GENDER
ilco FLUSH`n' AGE
ilco FLUSH`n' BMI_CALC
ilco FLUSH`n' BMI_DON_CALC2
ilca FLUSH`n' PREV_TX
* ca FLUSH`n' FUNC_STAT_TCR
ilca2 FLUSH`n' IABP_TCR
ilca2 FLUSH`n' ECMO_TRR
* ca FLUSH`n' FUNC_STAT_TRR
ilca2 FLUSH`n' IABP_TRR
ilco FLUSH`n' DISTANCE
* co FLUSH`n' ISCHTIME
ilca FLUSH`n' LIFE_SUP_TRR
* ca FLUSH`n' GENDER_DON2
* co3 FLUSH`n' AGE_DON2

* Endpoint, short-term
disp "ECMO_72HOUR: Data N/A"
* ilca2 FLUSH`n' ECMO_72HOURS
disp "INTUBATED_72HOURS: Data N/A"
* ilca2 FLUSH`n' INTUBATED_72HOURS
ilco FLUSH`n' LOS
disp "POST_TX_VENT_SUPPORT: Data N/A"
* ilco FLUSH`n' POST_TX_VENT_SUPPORT
* ilca FLUSH`n' POST_TX_VENT_SUPPORT
disp "REINTUBATED: Data N/A"
* ilca2 FLUSH`n' REINTUBATED

* Endpoint, short-term, 30-day-graft-Graft_Failure
gen gf30d=1 if GTIME<=30 & GSTATUS==1
replace gf30d=0 if gf30d==.
ilca2 FLUSH`n' gf30d
drop gf30d

* Endpoint, short-term, 30-day-graft-Patient_Death
gen pf30d=1 if PTIME<=30 & PSTATUS==1
replace pf30d=0 if pf30d==.
ilca2 FLUSH`n' pf30d
drop pf30d

* Endpoint, long-term
km_adj GSTATUS GTIME FLUSH`n' 30 Graft_Failure ISCHTIME
km_adj PSTATUS PTIME FLUSH`n' 30 Patient_Death ISCHTIME

* Endpoint, long-term
* K-M curves
* ca FLUSH`n' GSTATUS
* co3 FLUSH`n' GTIME
* ca FLUSH`n' PSTATUS
* co3 FLUSH`n' PTIME
ilca FLUSH`n' TRTREJ1Y
* ca FLUSH`n' FUNC_STAT_TRF
* ca FLUSH`n' PX_STAT

log close
* translate `logname'.smcl `logname'.pdf, replace
log2html `logname', replace erase linesize(255)
end

* heartflush EC vs IC
heartflush_i 1
heartflush_i 5
heartflush_i 6

local logname heartFLUSH6_match_los
log using `logname', smcl replace
co3 FLUSH6 LOS
log close
*translate `logname'.smcl `logname'.pdf, replace
log2html `logname', replace erase linesize(255)

* exit, clear STATA
