/* This is where raw variables from the SID core and AHAL datasets are recoded into
predictor and outcome variables of interest */

/* If you want to make changes here, you need to do the implement your recoding in the `data` statement of 
the `recode_year` macro below. Make sure you update the `keep` line near the bottom as well, so that 
the results of your recoding (as well as any other variables from the original data set that you need in 
your analysis) are passed on correctly.

Common situations you will encounter here are:

1. Adding a new (predictor or outcome) variable to your analysis, when that variable already exists in 
the original dataset? Simply add it to the `keep` statement.
2. Adding a new (predictor or outcome) variables to your analysis, and you need to calculate it by 
recoding variables in the original data set? Add code inside `data` to do the recoding, and add 
the name of the resulting variables to the `keep` statement.
*/

/* If you are also working with hospital cost data (CHGS) or hospital utilization data (DX_PR_GRPS), 
you will probably want to adjust recording of those variables; scroll to the second half of this file */

/* In a single state, 
   * recode diagnosis fields into outcomes we care about
   * recode patient age into age categories
   * recode admission date
*/
/* Recode core dataset */
%macro recode_year(state, year);

data sid_&state..recoded_&state._&year._core; set sid_&state..sid_&state._&year._core;

  /* Recode ICD-10 diagnoses:
     * resp(iratory) = J00-J99 (Diseases Of The Respiratory System)
     * flu = 
     J09  Influenza due to certain identified influenza viruses,
     J10  Influenza due to other identified influenza virus,
     J11  Influenza due to unidentified influenza virus

     * rsv = 
     B97.4 (Respiratory syncytial virus as the cause of diseases classified elsewhere),
         J21.0 (Acute bronchiolitis due to respiratory syncytial virus), 
         J20.5 Acute bronchitis due to respiratory syncytial virus,
         J12.1 (Pneumonia due to respiratory syncytial virus)
         
     * resp(iratory) other = respiratory but not flu or rsv
     * bronchio(litis) = J21 (Acute bronchiolitis)
     * pneumo(nia) other = J12-J18 (Pneumonia And Influenza) but not flu or rsv

  */
  resp = 0;
  resp_prim = 0;

  flu = 0; 
  flu_prim = 0; 

  rsv = 0; 
  rsv_prim = 0; 

  resp_other = 0;
  resp_otherprim = 0;

  bronchio = 0; 
  bronchio_prim = 0; 

  pneumo_other = 0; 
  pneumo_otherprim = 0; 

  if "J00" <=: DX1 <=: "J99" then resp_prim=1;

  if '487  '<=DX1<='487  ' then flu_prim=1;
  if '4870 '<=DX1<='4879 ' then flu_prim=1;
  if '48700'<=DX1<='48799' then flu_prim=1;
  if '488  '<=DX1<='488  ' then flu_prim=1;
  if '4880 '<=DX1<='4889 ' then flu_prim=1;
  if '48800'<=DX1<='48899' then flu_prim=1;

  if '0796 '<=DX1<='0796 ' then rsv_prim=1;
  if '07960'<=DX1<='07969' then rsv_prim=1;
  if '46611'<=DX1<='46611' then rsv_prim=1;
  if '4801 '<=DX1<='4801 ' then rsv_prim=1;
  if '48010'<=DX1<='48019' then rsv_prim=1;

  if '460  '<=DX1<='519  ' and flu_prim=0 and rsv_prim=0 then resp_otherprim=1;
  if '4600 '<=DX1<='5199 ' and flu_prim=0 and rsv_prim=0 then resp_otherprim=1;
  if '46000'<=DX1<='51999' and flu_prim=0 and rsv_prim=0 then resp_otherprim=1;

  IF '4661 '<=DX1<='4661 ' THEN  bronchio_prim = 1; 
  IF '46610'<=DX1<='46619' THEN  bronchio_prim = 1; 

  if '480  '<=DX1<='488  ' and flu_prim=0 and rsv_prim=0 then pneumo_otherprim=1;
  if '4800 '<=DX1<='4889 ' and flu_prim=0 and rsv_prim=0 then pneumo_otherprim=1;
  if '48000'<=DX1<='48899' and flu_prim=0 and rsv_prim=0 then pneumo_otherprim=1;

  IF '481  '<=DX1<='481  ' THEN  pneumopneumo_prim = 1; 
  IF '4810 '<=DX1<='4819 ' THEN  pneumopneumo_prim = 1; 
  IF '48100'<=DX1<='48199' THEN  pneumopneumo_prim = 1; 

  IF '0382 '<=DX1<='0382 ' THEN  pneumosept_prim = 1; 

  ARRAY DX[30] DX1-DX30;
  DO I=1 TO 30;

    if '460  '<=DX[I]<='519  ' then resp = 1;
    if '4600 '<=DX[I]<='5199 ' then resp = 1;
    if '46000'<=DX[I]<='51999' then resp = 1;

    if '487  '<=DX[I]<='487  ' then flu = 1;
    if '4870 '<=DX[I]<='4879 ' then flu = 1;
    if '48700'<=DX[I]<='48799' then flu = 1;
    if '488  '<=DX[I]<='488  ' then flu = 1;
    if '4880 '<=DX[I]<='4889 ' then flu = 1;
    if '48800'<=DX[I]<='48899' then flu = 1;
   
    if '0796 '<=DX[I]<='0796 ' then rsv = 1;
    if '07960'<=DX[I]<='07969' then rsv = 1;
    if '46611'<=DX[I]<='46611' then rsv = 1;
    if '4801 '<=DX[I]<='4801 ' then rsv = 1;
    if '48010'<=DX[I]<='48019' then rsv = 1;

    if '460  '<=DX[I]<='519  ' and flu = 0 and rsv = 0 then resp_other = 1;
    if '4600 '<=DX[I]<='5199 ' and flu = 0 and rsv = 0 then resp_other = 1;
    if '46000'<=DX[I]<='51999' and flu = 0 and rsv = 0 then resp_other = 1;

    IF '4661 '<=DX[I]<='4661 ' THEN  bronchio = 1; 
    IF '46610'<=DX[I]<='46619' THEN  bronchio = 1; 
  
    if '480  '<=DX[I]<='488  ' and flu = 0 and rsv = 0 then pneumo_other = 1;
    if '4800 '<=DX[I]<='4889 ' and flu = 0 and rsv = 0 then pneumo_other = 1;
    if '48000'<=DX[I]<='48899' and flu = 0 and rsv = 0 then pneumo_other = 1;

    if '481  '<=DX[I]<='481  ' then  pneumopneumo = 1; 
    if '4810 '<=DX[I]<='4819 ' then  pneumopneumo = 1; 
    if '48100'<=DX[I]<='48199' then  pneumopneumo = 1; 

    IF '0382 '<=DX[I]<='0382 ' THEN pneumosept = 1; 
  END;
  
  flu_pneumo = max(flu, pneumo_other);
  flu_pneumoprim = max(flu_prim, pneumo_otherprim);

  leg_test = 0;
  ARRAY CPTS[30] CPT1-CPT30;
  DO I=1 TO 30;
    if CPTS[I] in('87449', '86713', '87278') then leg_test=1; 
  END;
  
  /* recode admission date; month 1 = Jan 1901 */
  if missing(ayear) then do;
    ayear = year;
    length ayear 3;
  end;

  amonth = (ayear - 1901) * 12 + amonth;
  amonthdate = intnx('month', '01DEC1900'd, amonth);
  format amonthdate date9.;
  
  /* recode age */
  ageyear = .;
  if age ne . then do;
    if ((age = 0) or (0 <= ageday <= 365) or (0 <= agemonth <= 11)) then ageyear = 0;
    else ageyear = age;
  end;

  agecat1 = .;
  if age ne . then do;
    if (ageyear = 0) then agecat1 = 0;
    else if ageyear = 1 then agecat1 = 1;
    else if ageyear = 2 then agecat1 = 2;
    else if ageyear = 3 then agecat1 = 3;
    else if ageyear = 4 then agecat1 = 4;
    else if ageyear < 10 then agecat1 = 5;
    else if ageyear < 15 then agecat1 = 6;
    else if ageyear < 20 then agecat1 = 7;
    else if ageyear < 25 then agecat1 = 8;
    else if ageyear < 30 then agecat1 = 9;
    else if ageyear < 35 then agecat1 = 10;
    else if ageyear < 40 then agecat1 = 11;
    else if ageyear < 45 then agecat1 = 12;
    else if ageyear < 50 then agecat1 = 13;
    else if ageyear < 55 then agecat1 = 14;
    else if ageyear < 60 then agecat1 = 15;
    else if ageyear < 65 then agecat1 = 16;
    else if ageyear < 70 then agecat1 = 17;
    else if ageyear < 75 then agecat1 = 18;
    else if ageyear < 80 then agecat1 = 19;
    else if ageyear < 85 then agecat1 = 20;
    else if ageyear < 90 then agecat1 = 21;
    else if ageyear < 95 then agecat1 = 22;
    else if ageyear >= 95 then agecat1 = 23;
  end;

  label agecat1 = "0=<1, 1=1, 2=2, 3=3, 4=4, 5=5-9, 6=10-14, 7=15-19, 8=20-24, 9=25-29, 10=30-34, 11=35-39, 12=40-44, 13=45-49, 14=50-54, 15=55-59, 16=60-64, 17=65-69, 18=70-74, 19=75-79, 20=80-84, 21=85-89, 22=90-94, 23=95+";

  agecat2 = .;
  if age ne . then do;
    if 0 <= ageday <= 182 then agecat2 = 1;
    else if 183 <= ageday <= 365 then agecat2 = 2;
    else if agecat1 > 0 then agecat2 = 3;
  end; 
  
  label agecat1 = "1=<183 days, 2=183-365 days, 3=1+ year";

  keep 
    key
    hospst hospstco hfipsstco zip 
    age agemonth ageday agecat1 agecat2 
    ayear amonth amonthdate 
    died 
    resp resp_prim flu flu_prim rsv rsv_prim resp_other resp_otherprim 
    bronchio bronchio_prim 
    pneumo_other pneumo_otherprim pneumopneumo pneumopneumo_prim pneumosept pneumosept_prim 
    leg_test;
run;

%if &include_charges. %then %do;
/* Recode charges dataset */
/* Charges comes in one of two forms: before 2009, each admission (identified by key column) has 1 row and
35 columns (chg1-chg35) for 35 possible charges. Other columns contain other information about individual
charges. Since 2009, each charge gets its own row (and the key column identifies the corresponding admission). */

/* First sum up all the charges in chg1-chg35 corresponding to one pre-2009 admission, put the sum in charges, and 
drop everything else. */
data recoded_&state._&year._chgs; set sid_&state..sid_&state._&year._chgs;
    /* By including "charge" (which is the since-2009 itemized charge value) in the sum, since-2009 data is retained;
    those charges will be summed below in proc means */
  charges = sum(of chg1-chg35, charge); 
  keep key charges;
run;

/* Then sum up all the rows corresponding to one admission. For a pre-2009 admission, this is a single row
that already contains the sum of all charges. */
proc means data=recoded_&state._&year._chgs noprint nway sum missing;
  %let outcome_vars = charges; /* What variables are being summed */
  var &outcome_vars.; 

  output out=sid_&state..recoded_&state._&year._chgs sum=&outcome_vars.;

  class key; /* Key is unique identifier of an admission */
run;
%end;

%if &include_utilization. %then %do;
  /* This is where you should add recoding of utilization variables. For efficiency, keep only the utilization variables
  that you care about, as well as the 'key' variable (which cross-links utilization data to admissions data) */

  data recoded_&state._&year._dx_pr_grps; set sid_&state..sid_&state._&year._dx_pr_grps;
    keep key u_icu;
  run;

/* Merge utilization data into the core data, now that both have been recoded. (It's more efficient to first
reduce both core and utilization data to our variables of interest, and then merge them, than the other way around.) */

  proc sort data=sid_&state..recoded_&state._&year._core;
     by key;
  run;

  proc sort data=sid_&state..recoded_&state._&year._dx_pr_grps;
     by key;
  run;

  data sid_&state..recoded_&state._&year._core;
    merge sid_&state..recoded_&state._&year._core sid_&state..recoded_&state._&year._dx_pr_grps;
    by key;
  run;
%end;

%mend;
