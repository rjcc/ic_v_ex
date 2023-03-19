set more off
set linesize 128
set scheme s2mono
char _dta[omit] "prevalent"
program drop _all

program dsf
version 9
args d
gen dtemp=daily(`d',"ymd") if `d'!=""
format dtemp %dCY/N/D
drop `d'
ren dtemp `d'
end


program co3
args gp var
tabstat `var', by(`gp') stat(n mean sd med iqr  min  max)
kwallis `var', by(`gp')
end

program co
args gp var
tabstat `var', by(`gp') stat(n mean sd med iqr  min  max)
ranksum `var', by(`gp')
end

program ca
args gp var
tab `gp' `var', chi2 row col
end

program destr
args str
encode `str', generate(`str'2)
drop `str'
ren `str'2 `str'
end

program dconv
args v
replace `v'm=. if `v'm==0
replace `v'd=. if `v'd==0
replace `v'y=. if `v'y==0
gen d_`v'=mdy(`v'm, `v'd, `v'y)
format d_`v' %dN/D/CY
end

program stl
args v
encode(`v'), gen(_temp) label(`v')
drop `v'
renam _temp `v'
end

*! Date variables
*!   yyyymmdd -> (date)
*!   YMD MDY ...

program dconv2
args v
tostring `v', replace
gen temp=date(`v',"YMD")
drop `v'
ren temp `v'
format `v' %dCY/N/D
end

program dconv2s
args v
gen temp=date(`v',"YMD")
drop `v'
ren temp `v'
format `v' %dCY/N/D
end
