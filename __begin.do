* First, save as a new *.do file

local dirname "c:\data_work"
local logname heartflush
local dataname heart_data
cd `dirname'
include _init
log using `logname', smcl replace

* if stata dataset
use "`dirname'/`dataname'", clear

* if Excel dataset to import
* import excel "`dirname'/`dataname'", sheet("zzz") firstrow case(lower) clear
*
* Variables:
*
* Plans:
*
replace fu_die=0.1 if fu_die==0
stset fu_die, failure(die)

program km
args e fu grp unit event
replace `fu'=0.1 if `fu'==0
stset `fu', failure(`e') scale(`unit')
sts test `grp'
local pv = "0" + substr(string(chi2tail(`r(df)', `r(chi2)')),1,5)
sts graph, failure ytitle(Proportion of Event) ///
    ylabel(0(0.05)0.25, angle(horizontal)) ///
    xlabel (0(6)66) ///
    xtitle(Month) by(`grp') title (Kaplan-Meier Incidence of `event') ///
	caption ("Log-rank test p = `pv'")
graph export km_`e'.pdf, replace
end

log close _all
translate `logname'.smcl `logname'.pdf, replace
log2html `logname', replace erase linesize(255)
* exit, clear STATA
