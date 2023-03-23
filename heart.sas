%let path=/data_work;
libname donor "&path/data_202109/DDR";
libname thoracic "&path/data_202109/Thoracic";
libname follow "&path/data_202109/Thoracic/Individual Follow-up Records";
libname rjcc "&path";

** The above is the setting for the local environment;

proc sql;
create table rjcc.heart_data as
select
d.DONOR_ID,
d.CONTROLLED_DON,
d.CORE_COOL_DON,
d.ABO_DON,
d.AGE_DON,
d.BMI_DON_CALC,
d.CLAMP_DATE,
year(d.clamp_date) as yr_donor,
d.GENDER_DON,
d.COVID19_ANTIBODY_TESTRESULT,
d.COVID19_ANTIGEN_TESTRESULT,
d.COVID19_NAT_TESTRESULT,
d.HR_INITIAL_FLUSH,
d.HR_INITIAL_FLUSH_OSTXT,
d.HR_FINAL_FLUSH,
d.HR_FINAL_FLUSH_OSTXT,
d.HR_BACK_TBL_FLUSH,
d.HR_BACK_TBL_FLUSH_OSTXT,
d.HR_DISCARD_CD,
d.HR_DISCARD_CD_OSTXT,
d.HR_DISPOSITION,

t.DONOR_ID as DONOR_ID2,
t.PT_CODE,
t.BMI_CALC,
t.BMI_DON_CALC as BMI_DON_CALC2,
t.PREV_TX,
t.AGE,
t.GENDER_DON as GENDER_DON2,
t.AGE_DON  as AGE_DON2,
t.GENDER,
t.FUNC_STAT_TCR,
t.IABP_TCR,
t.IABP_TRR,
t.LIFE_SUP_TRR,
t.DISTANCE,
t.ISCHTIME,
t.ECMO_72HOURS,
t.ECMO_TRR,
t.FUNC_STAT_TRR,
t.LOS,
t.GSTATUS,
t.GTIME,
t.INTUBATED_72HOURS,
t.COMPOSITE_DEATH_DATE,
t.PTIME,
t.PSTATUS,
t.PX_STAT,
t.PX_STAT_DATE,
t.TRTREJ1Y,
t.FUNC_STAT_TRF,
t.COD,
t.COD_OSTXT,
t.COD2,
t.REINTUBATED,
t.POST_TX_VENT_SUPPORT,
t.ECD_DONOR,
case
    when HR_INITIAL_FLUSH=307 then "CELSIOR"
    when HR_INITIAL_FLUSH in (308, 312) then "HTK"
  	when HR_INITIAL_FLUSH in (300, 313) then "UW"
  	when upper(HR_INITIAL_FLUSH_OSTXT) like '%CELSIOR%' then "CELSIOR"
    when upper(HR_INITIAL_FLUSH_OSTXT) like '%HTK%' then "HTK"
    when upper(HR_INITIAL_FLUSH_OSTXT) like '%UW%' then "UW"
    when upper(HR_INITIAL_FLUSH_OSTXT) like '%SPS%' then "UW"
    when upper(HR_INITIAL_FLUSH_OSTXT) like '%VIASPA%' then "UW"
	when upper(HR_INITIAL_FLUSH_OSTXT) like '%NIDO%' then "DELNIDO"
    else "OTHERS"
end as FLUSH
from donor.deceased_donor_data as d inner join
          thoracic.thoracic_data as t
on d.donor_id =t.donor_id
 where  d.HEART_PERFUSION="N" AND
        t.MULTIORG<>"Y" AND
        t.ORGAN="HR" AND
        t.AGE_GROUP="A" and
        d.HR_INITIAL_FLUSH in (307,312,313,999) and
        calculated yr_donor>=2015;
quit;
run;

data rjcc.heart_data;
set rjcc.heart_data;
FLUSH1=FLUSH;
select (FLUSH);
  when('CELSIOR')  FLUSH2='CELSIOR';
  when('HTK')  FLUSH2='HTK';
  when('UW')  FLUSH2='UW';
  otherwise FLUSH2='';
end;
select (FLUSH);
  when('CELSIOR')  FLUSH3='CELSIOR';
  when('HTK')  FLUSH3='HTK';
  when('UW')  FLUSH3='UW';
  when('OTHERS')  FLUSH3='OTHERS';
  otherwise FLUSH3='';
end;
select (FLUSH);
  when('CELSIOR')  FLUSH4='CELSIOR';
  when('HTK')  FLUSH4='HTK';
  when('UW')  FLUSH4='UW';
  when('DELNIDO')  FLUSH4='OTHERS';
  when('OTHERS')  FLUSH4='OTHERS';
  otherwise FLUSH4='';
end;
select (FLUSH);
  when('CELSIOR')  FLUSH5='NUW';
  when('HTK')  FLUSH5='NUW';
  when('UW')  FLUSH5='UW';
  when('DELNIDO')  FLUSH5='NUW';
  when('OTHERS')  FLUSH5='NUW';
  otherwise FLUSH5='';
end;
select (FLUSH);
  when('CELSIOR')  FLUSH6='EX';
  when('HTK')  FLUSH6='EX';
  when('UW')  FLUSH6='IC';
  otherwise FLUSH6='';
end;
run;

proc freq data=rjcc.heart_data;
 tables flush * yr_donor/norow;
 tables flush6 * yr_donor/norow;
run;

/*
proc sql;
create table rjcc.heart_data2 as
select
  a.pt_code,
  a.yr_donor,
  a.FLUSH6,
  b.pt_code as pt_code2,
  b.ACUTE_REJ_EPI
from rjcc.heart_data as a inner join
    follow.thoracic_followup_data as b
on a.pt_code =b.pt_code;
quit;
run;

proc freq data=rjcc.heart_data2;
 tables flush6 * yr_donor/norow;
run;
*/

PROC EXPORT DATA= RJCC.heart_data
            OUTFILE= "C:\Data_work\heart_data.dta"
            DBMS=STATA REPLACE;
RUN;
/*
PROC EXPORT DATA= RJCC.heart_data2
            OUTFILE= "C:\Data_work\heart_data2.dta"
            DBMS=STATA REPLACE;
RUN;
*/
