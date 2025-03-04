
/********************************************************************************/
/* 																				*/
/*		Multinational ADHD medication and the risk of suicide attempt  	 	    */
/*		SCCS_SAS_programme														*/
/*		0. Common Data Model Set up (HK Version)								*/
/*																				*/
/********************************************************************************/
option compress=yes;

libname a "D:\SAS\sccs_mph\raw"; /*original data*/
libname b "D:\SAS\sccs_mph\working library"; /*working library*/
libname c "D:\SAS\sccs_mph\common_data_model";  /* Please enter the path which save the coverted CDM */
libname d "D:\SAS\sccs_mph\results";  /* Folder which save the Results */

/* [1] establishing the common data model */
/* Table 1: Demographic table*/
/* Step 1: import data from ADHD rx cohort*/
PROC IMPORT  DATAFILE= "D:\SAS\sccs_mph\raw\MPH9620cohort_birth_death.xlsx"
OUT= a.death
DBMS=xlsx REPLACE;
GETNAMES=YES;
RUN;
/* Step 2: keep drop variable from raw*/
proc sql;
create table b.demo_1 as
select 
compress(VAR1) as id format $8., 
VAR8 as sex,
VAR9 as birth_date format date9.,
VAR2 as death_date format date9.
from a.death;
quit;
/* Step 3: assign enrolment start date => 01-01-1995 or birthdate */
proc sql;
create table b.demo_2 as
select *, (case 
when a.birth_date <= '01JAN1995'd 
then '01JAN1995'd
else birth_date
end) as enrol_in_date format date9.
from b.demo_1 as a;
quit;
/* Step 4: assign enrolment end date */
	* For US/claims: please check if person in and out of system use same id;
proc sql;
create table b.demo_3 as
select *, (case 
when '31DEC2020'd <= death_date or death_date=.
then '31DEC2020'd
else death_date
end) as enrol_out_date format date9.
from b.demo_2;
quit;
/* Step 5: export to common_data_model library c*/
proc sql;
create table c.demo_final as
select 
compress(id) as id, sex, birth_date,death_date,enrol_in_date,enrol_out_date
from b.demo_3;
quit;

/* Table 2: Drug table*/
/* Step 1: import data from ADHD rx cohort (all rx)*/
PROC IMPORT  DATAFILE= "D:\SAS\sccs_mph\raw\MPH9620allcohort_allrx.csv"
OUT= a.rx
DBMS=csv REPLACE;
delimiter=',';
GETNAMES=yes;
guessingrows=max;
RUN;
/* Step 2: keep drop variable from raw*/
proc sql;
create table b.rx_1 as
select 
compress(PUT(Reference_Key_, best12.)) as id format $14., 
input(rxst,yymmdd10.) as rxst format date9.,
input(rxed,yymmdd10.) as rxed format date9.,
disdt as disdt format DATE9.,
lower(Drug_Name_) as drugname,
dosage_,
Drug_Frequency_ as Drug_Frequency,
Drug_Strength_,
input(compress(prxchange('s/\(([^\)]+)\)//i', -1, Drug_Strength_), '', 'a'), best12.) as mgpertab,
Quantity__Named_Patient__ as supply_quantity,
Type_of_Patient__Drug__ as setting
from a.rx;
quit;
/* Step 3: assign atc for study drugs */
proc sql;
create table b.rx_2 as
select *, (case 
when a.drugname contains 'amphetamine' then 'N06BA01'
when a.drugname contains 'dexamphetamine' then 'N06BA02'
when a.drugname contains 'metamphetamine' then 'N06BA03'
when a.drugname contains 'methylphenidate' then 'N06BA04'
when a.drugname contains 'atomoxetine' then 'N06BA09' 
when a.drugname contains 'dexmethylphenidate' then 'N06BA11'
when a.drugname contains 'lisdexamphetamine' then 'N06BA12'
when a.drugname contains 'clonidine' then 'C02AC01'
when a.drugname contains 'guanfacine' then 'C02AC02'

when a.drugname contains 'desipramine' then 'N06AA01' 
when a.drugname contains 'imipramine' then 'N06AA02'
/*when a.drugname contains 'imipramine oxide' then 'N06AA03'*/
when a.drugname contains 'clomipramine' then 'N06AA04'
when a.drugname contains 'opipramol' then 'N06AA05'
when a.drugname contains 'trimipramine' then 'N06AA06'
when a.drugname contains 'lofepramine' then 'N06AA07'
when a.drugname contains 'dibenzepin' then 'N06AA08'
when a.drugname contains 'amitriptyline' then 'N06AA09'
when a.drugname contains 'nortriptyline' then 'N06AA10'
when a.drugname contains 'protriptyline' then 'N06AA11'
when a.drugname contains 'doxepin' then 'N06AA12'
when a.drugname contains 'iprindole' then 'N06AA13'
when a.drugname contains 'melitracen' then 'N06AA14'
when a.drugname contains 'butriptyline' then 'N06AA15'
when a.drugname contains 'dosulepin' then 'N06AA16'
when a.drugname contains 'amoxapine' then 'N06AA17'
when a.drugname contains 'dimetacrine' then 'N06AA18'
when a.drugname contains 'amineptine' then 'N06AA19'
when a.drugname contains 'opipramol' then 'N06AA21'
when a.drugname contains 'quinupramine' then 'N06AA23'

when a.drugname contains 'zimeldine' then 'N06AB02'
when a.drugname contains 'fluoxetine' then 'N06AB03'
when a.drugname contains 'citalopram' then 'N06AB04'
when a.drugname contains 'paroxetine' then 'N06AB05'
when a.drugname contains 'sertraline' then 'N06AB06'
when a.drugname contains 'alaproclate' then 'N06AB07'
when a.drugname contains 'fluvoxamine' then 'N06AB08'
when a.drugname contains 'etoperidone' then 'N06AB09'
when a.drugname contains 'escitalopram' then 'N06AB10'

when a.drugname contains 'isocarboxazid' then 'N06AF01'
when a.drugname contains 'nialamide' then 'N06AF02'
when a.drugname contains 'phenelzine' then 'N06AF03'
when a.drugname contains 'tranylcypromine' then 'N06AF04'
when a.drugname contains 'iproniazide' then 'N06AF05'
when a.drugname contains 'iproclozide' then 'N06AF06'

when a.drugname contains 'moclobemide' then 'N06AG02'
when a.drugname contains 'toloxatone' then 'N06AG03'

when a.drugname contains 'oxitriptan' then 'N06AX01'
when a.drugname contains 'tryptophan' then 'N06AX02'
when a.drugname contains 'mianserin' then 'N06AX03'
when a.drugname contains 'nomifensine' then 'N06AX04'
when a.drugname contains 'trazodone' then 'N06AX05'
when a.drugname contains 'nefazodone' then 'N06AX06'
when a.drugname contains 'minaprine' then 'N06AX07'
when a.drugname contains 'bifemelane' then 'N06AX08'
when a.drugname contains 'viloxazine' then 'N06AX09'
when a.drugname contains 'oxaflozane' then 'N06AX10'
when a.drugname contains 'mirtazapine' then 'N06AX11'
when a.drugname contains 'bupropion' then 'N06AX12'
when a.drugname contains 'medifoxamine' then 'N06AX13'
when a.drugname contains 'tianeptine' then 'N06AX14'
when a.drugname contains 'pivagabine' then 'N06AX15'
when a.drugname contains 'venlafaxine' then 'N06AX16'
when a.drugname contains 'milnacipran' then 'N06AX17'
when a.drugname contains 'reboxetine' then 'N06AX18'
when a.drugname contains 'gepirone' then 'N06AX19'
when a.drugname contains 'duloxetine' then 'N06AX21'
when a.drugname contains 'agomelatine' then 'N06AX22'
when a.drugname contains 'desvenlafaxine' then 'N06AX23'
when a.drugname contains 'vilazodone' then 'N06AX24'
when a.drugname contains 'hyperici herba' then 'N06AX25'
when a.drugname contains 'vortioxetine' then 'N06AX26'
when a.drugname contains 'esketamine' then 'N06AX27'

when a.drugname contains 'chlorpromazine' then 'N05AA01'
when a.drugname contains 'levomepromazine' then 'N05AA02'
when a.drugname contains 'promazine' then 'N05AA03'
when a.drugname contains 'acepromazine' then 'N05AA04'
when a.drugname contains 'triflupromazine' then 'N05AA05'
when a.drugname contains 'cyamemazine' then 'N05AA06'
when a.drugname contains 'chlorproethazine' then 'N05AA07'

when a.drugname contains 'dixyrazine' then 'N05AB01'
when a.drugname contains 'fluphenazine' then 'N05AB02'
when a.drugname contains 'perphenazine' then 'N05AB03'
when a.drugname contains 'prochlorperazine' then 'N05AB04'
when a.drugname contains 'thiopropazate' then 'N05AB05'
when a.drugname contains 'trifluoperazine' then 'N05AB06'
when a.drugname contains 'acetophenazine' then 'N05AB07'
when a.drugname contains 'thioproperazine' then 'N05AB08'
when a.drugname contains 'butaperazine' then 'N05AB09'
when a.drugname contains 'perazine' then 'N05AB10'

when a.drugname contains 'periciazine' then 'N05AC01'
when a.drugname contains 'thioridazine' then 'N05AC02'
when a.drugname contains 'mesoridazine' then 'N05AC03'
when a.drugname contains 'pipotiazine' then 'N05AC04'

when a.drugname contains 'haloperidol' then 'N05AD01'
when a.drugname contains 'trifluperidol' then 'N05AD02'
when a.drugname contains 'melperone' then 'N05AD03'
when a.drugname contains 'moperone' then 'N05AD04'
when a.drugname contains 'pipamperone' then 'N05AD05'
when a.drugname contains 'bromperidol' then 'N05AD06'
when a.drugname contains 'benperidol' then 'N05AD07'
when a.drugname contains 'droperidol' then 'N05AD08'
when a.drugname contains 'fluanisone' then 'N05AD09'

when a.drugname contains 'oxypertine' then 'N05AE01'
when a.drugname contains 'molindone' then 'N05AE02'
when a.drugname contains 'sertindole' then 'N05AE03'
when a.drugname contains 'ziprasidone' then 'N05AE04'
when a.drugname contains 'lurasidone' then 'N05AE05'

when a.drugname contains 'flupentixol' then 'N05AF01'
when a.drugname contains 'clopenthixol' then 'N05AF02'
when a.drugname contains 'chlorprothixene' then 'N05AF03'
when a.drugname contains 'tiotixene' then 'N05AF04'
when a.drugname contains 'zuclopenthixol' then 'N05AF05'

when a.drugname contains 'fluspirilene' then 'N05AG01'
when a.drugname contains 'pimozide' then 'N05AG02'
when a.drugname contains 'penfluridol' then 'N05AG03'

when a.drugname contains 'loxapine' then 'N05AH01'
when a.drugname contains 'clozapine' then 'N05AH02'
when a.drugname contains 'olanzapine' then 'N05AH03'
when a.drugname contains 'quetiapine' then 'N05AH04'
when a.drugname contains 'asenapine' then 'N05AH05'
when a.drugname contains 'clotiapine' then 'N05AH06'

when a.drugname contains 'sulpiride' then 'N05AL01'
when a.drugname contains 'sultopride' then 'N05AL02'
when a.drugname contains 'tiapride' then 'N05AL03'
when a.drugname contains 'remoxipride' then 'N05AL04'
when a.drugname contains 'amisulpride' then 'N05AL05'
when a.drugname contains 'veralipride' then 'N05AL06'
when a.drugname contains 'levosulpiride' then 'N05AL07'

when a.drugname contains 'lithium' then 'N05AN01'

when a.drugname contains 'prothipendyl' then 'N05AX07'
when a.drugname contains 'risperidone' then 'N05AX08'
when a.drugname contains 'mosapramine' then 'N05AX10'
when a.drugname contains 'zotepine' then 'N05AX11'
when a.drugname contains 'aripiprazole' then 'N05AX12'
when a.drugname contains 'paliperidone' then 'N05AX13'
when a.drugname contains 'iloperidone' then 'N05AX14'
when a.drugname contains 'cariprazine' then 'N05AX15'
when a.drugname contains 'brexpiprazole' then 'N05AX16'
when a.drugname contains 'pimavanserin' then 'N05AX17'

when a.drugname contains 'diazepam' then 'N05BA01'
when a.drugname contains 'chlordiazepoxide' then 'N05BA02'
when a.drugname contains 'medazepam' then 'N05BA03'
when a.drugname contains 'oxazepam' then 'N05BA04'
when a.drugname contains 'potassium clorazepate' then 'N05BA05'
when a.drugname contains 'lorazepam' then 'N05BA06'
when a.drugname contains 'adinazolam' then 'N05BA07'
when a.drugname contains 'bromazepam' then 'N05BA08'
when a.drugname contains 'clobazam' then 'N05BA09'
when a.drugname contains 'ketazolam' then 'N05BA10'
when a.drugname contains 'prazepam' then 'N05BA11'
when a.drugname contains 'alprazolam' then 'N05BA12'
when a.drugname contains 'halazepam' then 'N05BA13'
when a.drugname contains 'pinazepam' then 'N05BA14'
when a.drugname contains 'camazepam' then 'N05BA15'
when a.drugname contains 'nordazepam' then 'N05BA16'
when a.drugname contains 'fludiazepam' then 'N05BA17'
when a.drugname contains 'ethyl loflazepate' then 'N05BA18'
when a.drugname contains 'etizolam' then 'N05BA19'
when a.drugname contains 'clotiazepam' then 'N05BA21'
when a.drugname contains 'cloxazolam' then 'N05BA22'
when a.drugname contains 'tofisopam' then 'N05BA23'
when a.drugname contains 'bentazepam' then 'N05BA24'
/*when a.drugname contains 'lorazepam, combinations' then 'N05BA56'*/

when a.drugname contains 'hydroxyzine' then 'N05BB01'
when a.drugname contains 'captodiame' then 'N05BB02'
/*when a.drugname contains 'hydroxyzine, combinations' then 'N05BB51'*/

when a.drugname contains 'meprobamate' then 'N05BC01'
when a.drugname contains 'emylcamate' then 'N05BC03'
when a.drugname contains 'mebutamate' then 'N05BC04'
/*when a.drugname contains 'meprobamate, combinations' then 'N05BC51'*/

when a.drugname contains 'benzoctamine' then 'N05BD01'
when a.drugname contains 'buspirone' then 'N05BE01'
when a.drugname contains 'mephenoxalone' then 'N05BX01'
when a.drugname contains 'gedocarnil' then 'N05BX02'
when a.drugname contains 'etifoxine' then 'N05BX03'
when a.drugname contains 'fabomotizole' then 'N05BX04'
when a.drugname contains 'Lavandulae aetheroleum' then 'N05BX05'

when a.drugname contains 'methylphenobarbital' then 'N03AA01'
when a.drugname contains 'phenobarbital' then 'N03AA02'
when a.drugname contains 'primidone' then 'N03AA03'
when a.drugname contains 'barbexaclone' then 'N03AA04'
when a.drugname contains 'metharbital' then 'N03AA30'

when a.drugname contains 'ethotoin' then 'N03AB01'
when a.drugname contains 'phenytoin' then 'N03AB02'
when a.drugname contains /*amino(diphenylhydantoin) */'valeric acid' then 'N03AB03'
when a.drugname contains 'mephenytoin' then 'N03AB04'
when a.drugname contains 'fosphenytoin' then 'N03AB05'
/*when a.drugname contains 'phenytoin, combinations' then 'N03AB52'*/
/*when a.drugname contains 'mephenytoin, combinations' then 'N03AB54'*/

when a.drugname contains 'ethosuximide' then 'N03AD01'
when a.drugname contains 'phensuximide' then 'N03AD02'
when a.drugname contains 'mesuximide' then 'N03AD03'
/*when a.drugname contains 'ethosuximide, combinations' then 'N03AD51'*/

when a.drugname contains 'clonazepam' then 'N03AE01'
when a.drugname contains 'carbamazepine' then 'N03AF01'
when a.drugname contains 'oxcarbazepine' then 'N03AF02'
when a.drugname contains 'rufinamide' then 'N03AF03'
when a.drugname contains 'eslicarbazepine' then 'N03AF04'

when a.drugname contains 'valproic acid' then 'N03AG01'
when a.drugname contains 'valproate' then 'N03AG01'
when a.drugname contains 'valpromide' then 'N03AG02'
when a.drugname contains 'aminobutyric acid' then 'N03AG03'
when a.drugname contains 'vigabatrin' then 'N03AG04'
when a.drugname contains 'progabide' then 'N03AG05'
when a.drugname contains 'tiagabine' then 'N03AG06'

when a.drugname contains 'sultiame' then 'N03AX03'
when a.drugname contains 'phenacemide' then 'N03AX07'
when a.drugname contains 'lamotrigine' then 'N03AX09'
when a.drugname contains 'felbamate' then 'N03AX10'
when a.drugname contains 'topiramate' then 'N03AX11'
when a.drugname contains 'gabapentin' then 'N03AX12'
when a.drugname contains 'pheneturide' then 'N03AX13'
when a.drugname contains 'levetiracetam' then 'N03AX14'
when a.drugname contains 'zonisamide' then 'N03AX15'
when a.drugname contains 'pregabalin' then 'N03AX16'
when a.drugname contains 'stiripentol' then 'N03AX17'
when a.drugname contains 'lacosamide' then 'N03AX18'
when a.drugname contains 'carisbamate' then 'N03AX19'
when a.drugname contains 'retigabine' then 'N03AX21'
when a.drugname contains 'perampanel' then 'N03AX22'
when a.drugname contains 'brivaracetam' then 'N03AX23'
when a.drugname contains 'cannabidiol' then 'N03AX24'
when a.drugname contains 'beclamide' then 'N03AX30'

else 'exclude'
end) as atccde format $10.
from b.rx_1 as a;
quit;
data b.rx_3;
set b.rx_2; 
if atccde = 'exclude' 
then delete; 
run;

proc sql;
create table check1 as
  SELECT distinct * 
  FROM b.rx_3 
  WHERE missing (rxst);
quit; /*missing rx_date =17959 */
/* Step 4: Use disdt to replace rxst only for missing */
proc sql;
create table b.allrx_1 as
select *, (case 
when missing(rxst)then disdt
else rxst
end) as rx_date format date9.
from b.rx_3;
quit; 
proc sql;
create table check2 as
  SELECT distinct * 
  FROM b.allrx_1 
  WHERE missing (rx_date);
quit; /*check for missing rx_date =0 */

/* Step 5: Assign supply days to those w/o rxed and sup_days
1. supply_day = 
	. rxed-rxst+1 = 
	. supply_quantity/(tabs*drug_frequency)
	. use median if rxed and freq not available
2. dailydose = mgpertab*tabs*freq
3. 
*/


*(1) assign dosepertab and freq;
data b.allrx_2;
set b.allrx_1;

if missing(mgpertab) and drug_strength_='##18MG' then mgpertab=18;
else if missing(mgpertab) and drug_strength_='100MG' then mgpertab=100;
else if missing(mgpertab) and drug_strength_='10MG' then mgpertab=10;
else if missing(mgpertab) and drug_strength_='## 18MG' then mgpertab=18;
else if missing(mgpertab) and drug_strength_='10MG ***' then mgpertab=10;
else if missing(mgpertab) and drug_strength_='36MG ##' then mgpertab=36;
else if missing(mgpertab) and drug_strength_='10MG***' then mgpertab=10;
else if missing(mgpertab) and drug_strength_='10MG/10ML' then mgpertab=10;
else if missing(mgpertab) and drug_strength_='18MG' then mgpertab=18;
else if missing(mgpertab) and drug_strength_='2.5MG' then mgpertab=2.5;
else if missing(mgpertab) and drug_strength_='2.5MG/10ML' then mgpertab=2.5;
else if missing(mgpertab) and drug_strength_='20MG' then mgpertab=20;
else if missing(mgpertab) and drug_strength_='20 MG' then mgpertab=20;
else if missing(mgpertab) and drug_strength_='15 MG' then mgpertab=15;
else if missing(mgpertab) and drug_strength_='25MG' then mgpertab=25;
else if missing(mgpertab) and drug_strength_='27MG' then mgpertab=27;
else if missing(mgpertab) and drug_strength_='27MG##' then mgpertab=27;
else if missing(mgpertab) and drug_strength_='27MG**OWN' then mgpertab=27;
else if missing(mgpertab) and drug_strength_='30MG' then mgpertab=30;
else if missing(mgpertab) and drug_strength_='35MG' then mgpertab=35;
else if missing(mgpertab) and drug_strength_='36MG' then mgpertab=36;
else if missing(mgpertab) and drug_strength_='36MG##' then mgpertab=36;
else if missing(mgpertab) and drug_strength_='36MGCONCERTA' then mgpertab=36;
else if missing(mgpertab) and drug_strength_='40MG' then mgpertab=40;
else if missing(mgpertab) and drug_strength_='54MG' then mgpertab=54;
else if missing(mgpertab) and drug_strength_='5MG' then mgpertab=5;
else if missing(mgpertab) and drug_strength_='60MG' then mgpertab=60;
else if missing(mgpertab) and drug_strength_='80MG' then mgpertab=80;
else if missing(mgpertab) and drug_strength_='150MCG 1ML' then mgpertab=0.15;

else if missing(mgpertab) and drug_strength_='IM' then mgpertab=.;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='0.1 MG' then mgpertab=0.1;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='1 MG' then mgpertab=1;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='2 MG' then mgpertab=2;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='5 MG' then mgpertab=5;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='10 MG' then mgpertab=10;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='18 MG' then mgpertab=18;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='20 MG' then mgpertab=20;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='25 MG' then mgpertab=25;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='27 MG' then mgpertab=27;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='30 MG' then mgpertab=30;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='35 MG' then mgpertab=35;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='36 MG' then mgpertab=36;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='40 MG' then mgpertab=40;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='45 MG' then mgpertab=45;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='50 MG' then mgpertab=50;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='54 MG' then mgpertab=54;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='60 MG' then mgpertab=60;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='7.5 MG' then mgpertab=7.5;
else if missing(mgpertab) and drug_strength_='NA' and dosage_='80 MG' then mgpertab=80;

else if missing(mgpertab) and missing(drug_strength_) and dosage_='0.025 MG' then mgpertab=0.025;
else if missing(mgpertab) and missing(drug_strength_) and dosage_='5 MG' then mgpertab=5;
else if missing(mgpertab) and missing(drug_strength_) and dosage_='10 MG' then mgpertab=10;
else if missing(mgpertab) and missing(drug_strength_) and dosage_='18 MG' then mgpertab=18;
else if missing(mgpertab) and missing(drug_strength_) and dosage_='25 MG' then mgpertab=25;
else if missing(mgpertab) and missing(drug_strength_) and dosage_='27 MG' then mgpertab=27;
else if missing(mgpertab) and missing(drug_strength_) and dosage_='30 MG' then mgpertab=30;
else if missing(mgpertab) and missing(drug_strength_) and dosage_='35 MG' then mgpertab=35;
else if missing(mgpertab) and missing(drug_strength_) and dosage_='36 MG' then mgpertab=36;
else if missing(mgpertab) and missing(drug_strength_) and dosage_='40 MG' then mgpertab=40;
else if missing(mgpertab) and missing(drug_strength_) and dosage_='45 MG' then mgpertab=45;
else if missing(mgpertab) and missing(drug_strength_) and dosage_='50 MG' then mgpertab=50;
else if missing(mgpertab) and missing(drug_strength_) and dosage_='54 MG' then mgpertab=54;
else if missing(mgpertab) and missing(drug_strength_) and dosage_='60 MG' then mgpertab=60;
else if missing(mgpertab) and missing(drug_strength_) and dosage_='7.5 MG' then mgpertab=7.5;
else if missing(mgpertab) and missing(drug_strength_) and dosage_='80 MG' then mgpertab=80;
else if missing(mgpertab) and dosage_='12.5 MG' then mgpertab=12.5;

if Drug_frequency='STOP' then dosage=0;
else if Drug_frequency='AT 4 A.M.' then freq=1;
else if Drug_frequency='AT 5 A.M.' then freq=1;
else if Drug_frequency='AT 6 A.M.' then freq=1;
else if Drug_frequency='AT 7 A.M.' then freq=1;
else if Drug_frequency='AT 8 A.M.' then freq=1;
else if Drug_frequency='AT 9 A.M.' then freq=1;
else if Drug_frequency='AT 10 A.M.' then freq=1;
else if Drug_frequency='AT 11 A.M.' then freq=1;
else if Drug_frequency='AT 12 A.M.' then freq=1;
else if Drug_frequency='AT 1 P.M.' then freq=1;
else if Drug_frequency='AT 2 P.M.' then freq=1;
else if Drug_frequency='AT 2 P.M. (DAYS PER WEEK)' then freq=1;
else if Drug_frequency='AT 3 P.M.' then freq=1;
else if Drug_frequency='AT 4 P.M.' then freq=1;
else if Drug_frequency='AT 4 P.M. (DAYS PER WEEK)' then freq=1;
else if Drug_frequency='AT 4 P.M. (SUN, MON, TUE, WED, THU, FRI,' then freq=6/7;
else if Drug_frequency='AT 4 P.M. (SUN, MON, TUE, WED, THU, FRI, SAT)' then freq=1;
else if Drug_frequency='AT 5 P.M.' then freq=1;
else if Drug_frequency='AT 5 P.M. (SUN, MON, TUE, WED, THU, FRI,' then freq=1;
else if Drug_frequency='AT 5 P.M. (SUN, MON, TUE, WED, THU, FRI, SAT)' then freq=1;
else if Drug_frequency='AT 6 P.M.' then freq=1;
else if Drug_frequency='AT 6 P.M. (DAYS PER WEEK)' then freq=1;
else if Drug_frequency='AT 7 P.M.' then freq=1;
else if Drug_frequency='AT 8 P.M.' then freq=1;
else if Drug_frequency='AT 9 P.M.' then freq=1;
else if Drug_frequency='AT 10 P.M.' then freq=1;
else if Drug_frequency='AT 11 P.M.' then freq=1;
else if Drug_frequency='AT 12 P.M.' then freq=1;
else if Drug_frequency='AT ___A.M.' then freq=1;
else if Drug_frequency='AT ___A.M. WHEN NECESSARY' then freq=1;
else if Drug_frequency='AT ___P.M.' then freq=1;
else if Drug_frequency='AT ____A.M.' then freq=1;
else if Drug_frequency='AT ____A.M. WHEN NECESSARY' then freq=1;
else if Drug_frequency='AT ___A.M. AND ___P.M. WHEN NECESSARY' then freq=1;
else if Drug_frequency='AT NIGHT (FROM DAYOF TREATMENT)' then freq=1;
else if Drug_frequency='AT NIGHT (FROM OF TREATMENT CYCLE)' then freq=1;
else if Drug_frequency='AT NIGHT (ON ALTERNATE DAYS)' then freq=0.5;
else if Drug_frequency='AT NIGHT (ON DAY)' then freq=1;
else if Drug_frequency='AT NOON (DAYS PER WEEK)' then freq=1;
else if Drug_frequency='AT NOON (EVERY SATURDAY)' then freq=1/7;
else if Drug_frequency='AT NOON (EVERY SUNDAY)' then freq=1/7;
else if Drug_frequency='AT NOON (FROM DAYOF TREATMENT)' then freq=1;
else if Drug_frequency='AT NOON (ON ALTERNATE DAYS)' then freq=0.5;
else if Drug_frequency='AT NIGHT' then freq=1;
else if Drug_frequency='AT NIGHT (ON DAYOF TREATMENT CYCLE)' then freq=1;
else if Drug_frequency='AT NIGHT WHEN NECESSARY' then freq=1;
else if Drug_frequency='AT NOON (SUN, MON, TUE, WED, THU, FRI, SA' then freq=1;
else if Drug_frequency='AT NOON (SUN, MON, TUE, WED, THU, FRI, SAT)' then freq=1;
else if Drug_frequency='AT NIGHT' then freq=1;
else if Drug_frequency='IN THE EVENING' then freq=1;
else if Drug_frequency='AT NOON' then freq=1;
else if Drug_frequency='AT NOON WHEN NECESSARY' then freq=1;
else if Drug_frequency='AT BED TIME' then freq=1;
else if Drug_frequency='AT BEDTIME' then freq=1;
else if Drug_frequency='AT BEDTIME (FROM DAYOF TREATMENT)' then freq=1;
else if Drug_frequency='DAILY' then freq=1;
else if Drug_frequency='DAILY FOR 5 DAYS IN A WEEK' then freq=5/7;
else if Drug_frequency='DAILY WHEN NECESSARY' then freq=1;
else if Drug_frequency='DAILY (DAYS PER WEEK)' then freq=1;
else if Drug_frequency='DAILY (DOSES PER WEEK)' then freq=1;
else if Drug_frequency='DAILY (FROM DAYOF TREATMENT)' then freq=1;
else if Drug_frequency='DAILY (FROM OF TREATMENT CYCLE)' then freq=1;
else if Drug_frequency='DAILY (ON ALTERNATE DAYS)' then freq=0.5;
else if Drug_frequency='DAILY (ON DAY)' then freq=1;
else if Drug_frequency='TWICE DAILY AND [2] AT NIGHT' then freq=4;
else if Drug_frequency='TWICE DAILY AND [3] AT NIGHT' then freq=5;
else if Drug_frequency='TWICE DAILY AT DAYTIME AND [1] AT NIGHT' then freq=3;
else if Drug_frequency='TWICE DAILY AT DAYTIME AND [2] AT NIGHT' then freq=4;
else if Drug_frequency='TWICE DAILY AT DAYTIME AND [3] AT NIGHT' then freq=5;
else if Drug_frequency='TWICE DAILY DURING DAYTIME' then freq=2;
else if Drug_frequency='THREE TIMES DAILY AND [1] AT NIGHT' then freq=4;
else if Drug_frequency='THREE TIMES DAILY AND [3] AT NIGHT' then freq=6;
else if Drug_frequency='THREE TIMES DAILY DURING DAYTIME' then freq=3;
else if Drug_frequency='THRICE DAILY AT DAYTIME AND [1] AT NIGHT' then freq=4;
else if Drug_frequency='THRICE DAILY AT DAYTIME AND [3] AT NIGHT' then freq=6;
else if Drug_frequency='FOUR TIMES DAILY' then freq=4;
else if Drug_frequency='FOUR TIMES DAILY WHEN NECESSARY' then freq=6;
else if Drug_frequency='FIVE TIMES WEEKLY' then freq=5/7;
else if Drug_frequency='IN THE MORNING' then freq=1;
else if Drug_frequency='IN THE MORNING AND [0.5] AT NIGHT' then freq=1.5;
else if Drug_frequency='IN THE MORNING AND [0.5] AT NOON' then freq=1.5;
else if Drug_frequency='IN THE MORNING AND [0.5] IN THE AFTERNOON' then freq=1.5;
else if Drug_frequency='IN THE MORNING AND [1.5] AT NIGHT' then freq=2.5;
else if Drug_frequency='IN THE MORNING AND [1.5] AT NOON' then freq=2.5;
else if Drug_frequency='IN THE MORNING AND [1] AT NIGHT' then freq=2;
else if Drug_frequency='IN THE MORNING AND [1] AT NOON' then freq=2;
else if Drug_frequency='IN THE MORNING AND [1] IN THE AFTERNOON' then freq=2;
else if Drug_frequency='IN THE MORNING AND [2] AT NIGHT' then freq=3;
else if Drug_frequency='IN THE MORNING AND [2] AT NOON' then freq=3;
else if Drug_frequency='IN THE MORNING AND [2] IN THE AFTERNOON' then freq=3;
else if Drug_frequency='IN THE MORNING AND ___ AT NOON' then freq=2;
else if Drug_frequency='IN THE MORNING WHEN NECESSARY' then freq=1;
else if Drug_frequency='IN THE MORNING AND [2.5] AT NOON' then freq=3.5;
else if Drug_frequency='IN MORNING, ___ AT NOON AND ___ AT NIGHT' then freq=3;
else if Drug_frequency='IN THE MORNING AND [3] AT NIGHT' then freq=4;
else if Drug_frequency='IN THE MORNING AND [3] IN THE AFTERNOON' then freq=4;
else if Drug_frequency='IN THE AFTERNOON' then freq=1;
else if Drug_frequency='IN THE AFTERNOON (DAYS PER WEEK)' then freq=1;
else if Drug_frequency='IN THE AFTERNOON (DOSES PER WEEK)' then freq=1;
else if Drug_frequency='IN THE AFTERNOON WHEN NECESSARY' then freq=1;
else if Drug_frequency='IN THE MORNING AND [4] AT NIGHT' then freq=5;
else if Drug_frequency='IN THE MORNING AND ___ AT NIGHT' then freq=2;
else if Drug_frequency='IN THE AFTERNOON' then freq=1;
else if Drug_frequency='TWICE DAILY' then freq=2;
else if Drug_frequency='TWICE DAILY WHEN NECESSARY' then freq=2;
else if Drug_frequency='FOUR TIMES DAILY' then freq=4;
else if Drug_frequency='AT ____P.M.' then freq=1;
else if Drug_frequency='THREE TIMES DAILY' then freq=3;
else if Drug_frequency='THREE TIMES DAILY WHEN NECESSARY' then freq=3;
else if Drug_frequency='FOUR TIMES DAILY' then freq=4;
else if Drug_frequency='AFTER BREAKFAST' then freq=1;
else if Drug_frequency='AFTER BREAKFAST (FROM DAYOF TREATMENT)' then freq=1;
else if Drug_frequency='AFTER BREAKFAST (ON DAYOF TREATMENT CYCLE)' then freq=1;
else if Drug_frequency='AFTER BREAKFAST (SUN, MON, TUE, WED, THU,' then freq=5/7;
else if Drug_frequency='AFTER BREAKFAST (SUN, MON, TUE, WED, THU, FRI, SAT)' then freq=1;
else if Drug_frequency='AFTER DINNER' then freq=1;
else if Drug_frequency='AFTER DINNER (FROM DAYOF TREATMENT)' then freq=1;
else if Drug_frequency='AFTER LUNCH' then freq=1;
else if Drug_frequency='BEFORE BREAKFAST' then freq=1;
else if Drug_frequency='BEFORE BREAKFAST WHEN NECESSARY' then freq=1;
else if Drug_frequency='BEFORE DINNER' then freq=1;
else if Drug_frequency='BEFORE LUNCH' then freq=1;
else if Drug_frequency='EVERY EIGHT HOURS' then freq=3;
else if Drug_frequency='EVERY EIGHT HOURS WHEN NECESSARY' then freq=3;
else if Drug_frequency='EVERY FOUR HOURS' then freq=6;
else if Drug_frequency='EVERY FOUR HOURS WHEN NECESSARY' then freq=1;
else if Drug_frequency='EVERY FOUR WEEKS' then freq=1/28;
else if Drug_frequency='EVERY SIX HOURS' then freq=4;
else if Drug_frequency='EVERY SIX HOURS WHEN NECESSARY' then freq=4;
else if Drug_frequency='EVERY THREE WEEKS' then freq=1/21;
else if Drug_frequency='EVERY TWELVE HOURS' then freq=2;
else if Drug_frequency='EVERY TWELVE HOURS WHEN NECESSARY' then freq=2;
else if Drug_frequency='EVERY TWENTY-FOUR HOURS' then freq=1;
else if Drug_frequency='EVERY TWO HOURS WHEN NECESSARY' then freq=12;
else if Drug_frequency='HOURLY' then freq=24;
else if Drug_frequency='ON ALTERNATE DAYS' then freq=1/2;
else if Drug_frequency='ON ALTERNATE NIGHTS' then freq=1/2;
else if Drug_frequency='ONCE' then freq=1;
else if Drug_frequency='USE AS DIRECTED' then freq=1;
else if Drug_frequency='AS DIRECTED' then freq=1;
else if Drug_frequency='AT ONCE' then freq=1;
else if Drug_frequency='WHEN NECESSARY' then freq=1;
else if Drug_frequency='AT ONCE WHEN NECESSARY' then freq=1;
else if Drug_frequency='AT BED TIME WHEN NECESSARY' then freq=1;
else if Drug_frequency='1 HOUR(S) BEFORE EXAMINATION' then freq=1;
else if Drug_frequency='1 HOUR(S) BEFORE TREATMENT' then freq=1;
else if Drug_frequency='AT 2 A.M.' then freq=1;
else if Drug_frequency='AT 6 P.M. (FROM DAYOF TREATMENT)' then freq=1;
else if Drug_frequency='AT BEDTIME (DAYS PER WEEK)' then freq=1;
else if Drug_frequency='AT BEDTIME (ON ALTERNATE DAYS)' then freq=0.5;
else if Drug_frequency='AT BEDTIME (ON EVEN DAYS)' then freq=3/7;
else if Drug_frequency='AT BEDTIME (ON ODD DAYS)' then freq=4/7;
else if Drug_frequency='AT MIDNIGHT' then freq=1;
else if Drug_frequency='AT NIGHT (EVERY 3 DAY)' then freq=2/7;
else if Drug_frequency='AT NIGHT (ON EVEN DAYS)' then freq=3/7;
else if Drug_frequency='AT NIGHT (ON ODD DAYS)' then freq=4/7;
else if Drug_frequency='AT NIGHT (SUN, MON, TUE, WED, THU, FRI, SAT)' then freq=1;
else if Drug_frequency='AT ONCE (EVERYWEEK)' then freq=1;
else if Drug_frequency='AT START OF ATTACK' then freq=1;
else if Drug_frequency='DAILY (6 DAYS PER WEEK)' then freq=6/7;
else if Drug_frequency='DAILY (ON DAYOF TREATMENT CYCLE)' then freq=1;
else if Drug_frequency='DAILY (ON EVEN DAYS)' then freq=3/7;
else if Drug_frequency='DAILY (ON ODD DAYS)' then freq=4/7;
else if Drug_frequency='DAILY FOR 2 DAYS IN A WEEK' then freq=2/7;
else if Drug_frequency='DAILY FOR 3 DAYS IN A WEEK' then freq=3/7;
else if Drug_frequency='DAILY FOR 6 DAYS IN A WEEK' then freq=6/7;
else if Drug_frequency='DAILY FROM DAY 15 OF TREATMENT' then freq=1;
else if Drug_frequency='EVERY 12 HOUR(S)' then freq=2;
else if Drug_frequency='EVERY 12 HOURS' then freq=2;
else if Drug_frequency='EVERY 15 MINUTES' then freq=192;
else if Drug_frequency='EVERY 2 HOURS' then freq=8;
else if Drug_frequency='EVERY 24 HOUR(S)' then freq=1;
else if Drug_frequency='EVERY 24 HOURS' then freq=1;
else if Drug_frequency='EVERY 3 HOURS' then freq=16/3;
else if Drug_frequency='EVERY 4 HOURS' then freq=4;
else if Drug_frequency='EVERY 48 HOUR(S)' then freq=0.5;
else if Drug_frequency='EVERY 48 HOURS' then freq=0.5;
else if Drug_frequency='EVERY 6 HOUR(S)' then freq=16/6;
else if Drug_frequency='EVERY 6 TO 8 HOURS' then freq=16/6;
else if Drug_frequency='EVERY 8 HOUR(S)' then freq=2;
else if Drug_frequency='EVERY 8 HOURS' then freq=2;
else if Drug_frequency='FIVE TIMES DAILY' then freq=5;
else if Drug_frequency='FOUR TIMES DAILY AND [1] AT NIGHT' then freq=4;
else if Drug_frequency='FOUR TIMES DAILY DURING DAYTIME' then freq=4;
else if Drug_frequency='FOUR TIMES WEEKLY' then freq=4/7;
else if Drug_frequency='HOURLY WHEN NECESSARY' then freq=16;
else if Drug_frequency='IN MORNING, ___ IN AFTERNOON, ___ AT NIGH' then freq=3;
else if Drug_frequency='IN MORNING, ____ AT NOON AND ____ AT NIGH' then freq=3;
else if Drug_frequency='IN THE AFTERNOON (EVERY SATURDAY)' then freq=1/7;
else if Drug_frequency='IN THE AFTERNOON (EVERY SUNDAY)' then freq=1/7;
else if Drug_frequency='IN THE AFTERNOON (FROM DAYOF TREATMENT)' then freq=1/7;
else if Drug_frequency='IN THE AFTERNOON (SUN, MON, TUE, WED, THU' then freq=5/7;
else if Drug_frequency='IN THE AFTERNOON (SUN, MON, TUE, WED, THU, FRI, SAT)' then freq=1;
else if Drug_frequency='IN THE AFTERNOON AND ____ AT NIGHT' then freq=2;
else if Drug_frequency='IN THE MORNING (5 DAYS PER WEEK)' then freq=5/7;
else if Drug_frequency='IN THE MORNING (DAYS PER WEEK)' then freq=1;
else if Drug_frequency='IN THE MORNING (DOSES PER WEEK)' then freq=1;
else if Drug_frequency='IN THE MORNING (EVERY FRIDAY)' then freq=1/7;
else if Drug_frequency='IN THE MORNING (EVERY SATURDAY)' then freq=1/7;
else if Drug_frequency='IN THE MORNING (EVERY SUNDAY)' then freq=1/7;
else if Drug_frequency='IN THE MORNING (EVERY WEDNESDAY)' then freq=1/7;
else if Drug_frequency='IN THE MORNING (EVERYDAY)' then freq=1;
else if Drug_frequency='IN THE MORNING (EVERYWEEK)' then freq=1;
else if Drug_frequency='IN THE MORNING (FIVE TIMES WEEKLY)' then freq=5/7;
else if Drug_frequency='IN THE MORNING (FROM DAYOF TREATMENT)' then freq=1;
else if Drug_frequency='IN THE MORNING (FROM OF TREATMENT CYCLE)' then freq=1;
else if Drug_frequency='IN THE MORNING (ON ALTERNATE DAYS)' then freq=0.5;
else if Drug_frequency='IN THE MORNING (ON DAY)' then freq=1;
else if Drug_frequency='IN THE MORNING (ON DAYOF TREATMENT CYCLE)' then freq=1;
else if Drug_frequency='IN THE MORNING (ON EVEN DAYS)' then freq=3/7;
else if Drug_frequency='IN THE MORNING (ON ODD DAYS)' then freq=4/7;
else if Drug_frequency='IN THE MORNING (SUN, MON, TUE, WED, THU,' then freq=5/7;
else if Drug_frequency='IN THE MORNING (SUN, MON, TUE, WED, THU, FRI, SAT)' then freq=1;
else if Drug_frequency='IN THE MORNING AND [1.5] IN THE AFTERNOON' then freq=2.5;
else if Drug_frequency='IN THE MORNING AND [2.5] AT NIGHT' then freq=3.5;
else if Drug_frequency='IN THE MORNING AND [5] AT NIGHT' then freq=6;
else if Drug_frequency='IN THE MORNING AND ____ IN THE AFTERNOON' then freq=2;
else if Drug_frequency='ON ALTERNATE DAYS WHEN NECESSARY' then freq=0.5;
else if Drug_frequency='ON ALTERNATE MORNINGS' then freq=0.5;
else if Drug_frequency='ON EVEN DAYS' then freq=3/7;
else if Drug_frequency='ON EVEN NIGHTS' then freq=3/7;
else if Drug_frequency='ON FRIDAY(S)' then freq=1/7;
else if Drug_frequency='ON MONDAY(S)' then freq=1/7;
else if Drug_frequency='ON ODD DAYS' then freq=4/7;
else if Drug_frequency='ON ODD NIGHTS' then freq=4/7;
else if Drug_frequency='ON SATURDAY(S)' then freq=1/7;
else if Drug_frequency='ON SUNDAY(S)' then freq=1/7;
else if Drug_frequency='ON THURSDAY(S)' then freq=1/7;
else if Drug_frequency='ON TUESDAY(S)' then freq=1/7;
else if Drug_frequency='ON WEDNESDAY(S)' then freq=1/7;
else if Drug_frequency='ONCE (EVERY 1 MONTH(S))' then freq=1/30;
else if Drug_frequency='ONCE (EVERY 3 WEEK)' then freq=1/27;
else if Drug_frequency='ONCE (EVERY 4 WEEK)' then freq=1/30;
else if Drug_frequency='ONCE (EVERYDAY)' then freq=1;
else if Drug_frequency='ONCE (EVERYMONTH(S))' then freq=1/30;
else if Drug_frequency='ONCE (EVERYWEEK)' then freq=1/7;
else if Drug_frequency='ONCE (ON ALTERNATE DAYS)' then freq=0.5;
else if Drug_frequency='ONCE (ON DAY OF EXAMINATION)' then freq=1;
else if Drug_frequency='ONCE (ON EVEN DAYS)' then freq=3/7;
else if Drug_frequency='ONCE (ON ODD DAYS)' then freq=4/7;
else if Drug_frequency='ONCE (SUN, MON, TUE, WED, THU, FRI, SAT)' then freq=1;
else if Drug_frequency='ONCE PER DAY' then freq=1;
else if Drug_frequency='ONCE PER DAY (DAYS PER WEEK)' then freq=1;
else if Drug_frequency='ONCE PER DAY (DOSES PER WEEK)' then freq=1;
else if Drug_frequency='ONCE PER DAY (EVERY 4 WEEK)' then freq=1/30;
else if Drug_frequency='ONCE PER DAY (EVERYDAY)' then freq=1;
else if Drug_frequency='ONCE PER DAY (FROM DAYOF TREATMENT)' then freq=1;
else if Drug_frequency='ONCE PER DAY (FROM OF TREATMENT CYCLE)' then freq=1;
else if Drug_frequency='ONCE PER DAY (ON ALTERNATE DAYS)' then freq=0.5;
else if Drug_frequency='ONCE PER DAY (ON DAYOF TREATMENT CYCLE)' then freq=1;
else if Drug_frequency='ONCE PER DAY (ON EVEN DAYS)' then freq=3/7;
else if Drug_frequency='ONCE PER DAY (ON ODD DAYS)' then freq=4/7;
else if Drug_frequency='ONCE WEEKLY' then freq=1/7;
else if Drug_frequency='SIX TIMES DAILY' then freq=6;
else if Drug_frequency='SIX TIMES WEEKLY' then freq=6/7;
else if Drug_frequency='SIX TIMES WEEKLY WHEN NECESSARY' then freq=6/7;
else if Drug_frequency='THREE TIMES DAILY (6 DOSES PER WEEK)' then freq=3;
else if Drug_frequency='THREE TIMES DAILY (DAY(S) BEFORE SURGICAL' then freq=3;
else if Drug_frequency='THREE TIMES DAILY (DAY(S) BEFORE SURGICAL PROCEDURE)' then freq=3;
else if Drug_frequency='THREE TIMES DAILY (DAYS PER WEEK)' then freq=3;
else if Drug_frequency='THREE TIMES DAILY (EVERY SATURDAY)' then freq=3/7;
else if Drug_frequency='THREE TIMES DAILY (EVERY SUNDAY)' then freq=3/7;
else if Drug_frequency='THREE TIMES DAILY (FROM DAYOF TREATMENT)' then freq=3;
else if Drug_frequency='THREE TIMES DAILY (SUN, MON, TUE, WED, TH' then freq=15/7;
else if Drug_frequency='THREE TIMES DAILY (SUN, MON, TUE, WED, THU, FRI, SAT)' then freq=3;
else if Drug_frequency='THREE TIMES DAILY AND [2] AT NIGHT)' then freq=5;
else if Drug_frequency='THREE TIMES DAILY ON ALTERNATE DAYS' then freq=3/2;
else if Drug_frequency='THREE TIMES WEEKLY' then freq=3/7;
else if Drug_frequency='THRICE DAILY AT DAYTIME AND [2] AT NIGHT' then freq=5;
else if Drug_frequency='TWICE DAILY (3 DAYS PER CYCLE)' then freq=1;
else if Drug_frequency='TWICE DAILY (5 DAYS PER WEEK)' then freq=10/7;
else if Drug_frequency='TWICE DAILY (6 DAYS PER WEEK)' then freq=12/7;
else if Drug_frequency='TWICE DAILY (DAY(S) BEFORE SURGICAL PROCEDURE)' then freq=2;
else if Drug_frequency='TWICE DAILY (DAYS PER WEEK)' then freq=2;
else if Drug_frequency='TWICE DAILY (DOSES PER WEEK)' then freq=2;
else if Drug_frequency='TWICE DAILY (EVERY SUNDAY)' then freq=2/7;
else if Drug_frequency='TWICE DAILY (FROM DAYOF TREATMENT)' then freq=2;
else if Drug_frequency='TWICE DAILY (FROM OF TREATMENT CYCLE)' then freq=2;
else if Drug_frequency='TWICE DAILY (SUN, MON, TUE, WED, THU, FRI' then freq=12/7;
else if Drug_frequency='TWICE DAILY (SUN, MON, TUE, WED, THU, FRI, SAT)' then freq=2;
else if Drug_frequency='TWICE DAILY AND [1] AT NIGHT' then freq=3;
else if Drug_frequency='TWICE DAILY AND [4] AT NIGHT' then freq=6;
else if Drug_frequency='TWICE DAILY AT DAYTIME AND [4] AT NIGHT' then freq=3;
else if Drug_frequency='TWICE DAILY FOR 2 DAYS IN A WEEK' then freq=4/7;
else if Drug_frequency='TWICE DAILY FOR 5 DAYS IN A WEEK' then freq=10/7;
else if Drug_frequency='TWICE DAILY FROM DAY 15 OF TREATMENT' then freq=2;
else if Drug_frequency='TWICE DAILY FROM DAY 8 OF TREATMENT' then freq=2;
else if Drug_frequency='TWICE WEEKLY' then freq=2/7;
else if Drug_frequency='USE AS DIRECTED (SUN, MON, TUE, WED, THU, FRI, SAT)' then freq=1;
else if Drug_frequency='WITH DINNER' then freq=1;
else if Drug_frequency='WITH EVENING MEAL' then freq=1;
else if Drug_frequency='WITH LUNCH' then freq=1;
else if Drug_frequency='EVERY 4 TO 6 HOURS' then freq=4;
else if Drug_frequency='EVERY 6 HOURS' then freq=16/6;
else if Drug_frequency='EVERY THREE HOURS WHEN NECESSARY' then freq=16/3;
else if Drug_frequency='EVERY TWENTY-FOUR HOURS WHEN NECESSARY' then freq=1;
else if Drug_frequency='EVERY TWO HOURS' then freq=8;
else if Drug_frequency='EVERY TWO WEEKS' then freq=1/14;
else if Drug_frequency='WITH BREAKFAST' then freq=1;
else if Drug_frequency=' ' then freq=0;
else if Drug_frequency='NA' then freq=0;
else if Drug_frequency='ON CALL TO OPERATING THEATRE' then freq=0;
else if Drug_frequency='STOP' then freq=0;
run;
/*check for missing freq */
proc sql;
create table check3 as
  SELECT unique (Drug_frequency)
  FROM b.allrx_2 
  WHERE missing (freq);
quit; /*missing freq and rxed  = 0*/

*(2) median imputation for mgpertab;
proc means data=b.allrx_2 median noprint;
var mgpertab;
class atccde;
output out=mgpertab_median median= /autoname;
run;
proc sql;
create table b.allrx_3 as
select A.*, B.mgpertab_median from b.allrx_2 a 
left join mgpertab_median b on a.atccde=b.atccde;
quit;
data b.allrx_4;
set b.allrx_3;
if missing (mgpertab) then mgpertab=mgpertab_median;
run;
proc sql;
create table check3 as
  SELECT unique (dosage_),drug_strength_
  FROM b.allrx_4 
  WHERE missing (mgpertab);
quit; /*4*/
proc sql;
create table check2 as
  SELECT distinct mgpertab,drug_strength_,dosage_ 
  FROM b.allrx_4 
WHERE missing (mgpertab) and substr(atccde,1,5) in ("C02AC");
quit; /*n=0*/

*(3) assign dosage (how many tabs per day);
data b.allrx_5;
set b.allrx_4;
if find(dosage_,'CAPSULE') or 
find(dosage_,'TAB') or 
find(dosage_,'NO ') or 
find(dosage_,'DOSE(S) ') or 
find(dosage_,'CAP ')  or /*this comprises all adhd rx*/
find(dosage_,'AMP ') or 
find(dosage_,'BOTT ') or 
find(dosage_,'VIAL ') or 
find(dosage_,'DROPS ') or 
find(dosage_,'SPOONFUL(S)  ') or 
find(dosage_,'TUBE ') or 
find(dosage_,'SACHET(S) ') or 
find(dosage_,'TUBE(S) ') or 
find(dosage_,'PACK ') or 
find(dosage_,'DROP(S) ') 
then dosage=scan(dosage_,1,' ','m');
else dosage="." ; 
run;

/*(4) median imputation for dosage*/
proc means data=b.allrx_5 median noprint;
var dosage;
class atccde;
output out=dosage_median median= /autoname;
run;
proc sql;
create table b.allrx_6 as
select A.*, B.dosage_median from b.allrx_5 a 
left join dosage_median b on a.atccde=b.atccde;
quit;
data b.allrx_7;
set b.allrx_6;
if missing (dosage) then dosage=dosage_median;
run;
proc sql;
create table check3 as
  SELECT unique (dosage_)
  FROM b.allrx_7 
  WHERE missing(dosage) and substr(atccde,1,5) in ("N06BA");
quit;/*0*/
/*(5) calculate daily dose*/
data b.allrx_8;
set b.allrx_7;
dailydose=mgpertab*dosage*freq;
run;
/*(6) calculate supply days*/
proc sql;
create table b.allrx_9 as
select *, (case 
when rxed = . then ceil(supply_quantity/(dosage*freq))
else rxed-rx_date+1
end) as sup_days 
from b.allrx_8;
quit;
/*check for missing sup_days */
proc sql;
create table check4 as
  SELECT unique (id)
  FROM b.allrx_9 
  WHERE missing (sup_days);
quit; /*missing sup_days =151 */
/*change supply day to end-start+1 */
proc sql;
create table b.allrx_10 as
select *, (case 
when rxed = . then sup_days+rx_date-1
else rxed
end) as rx_end format date9.
from b.allrx_9;
quit;
proc sql;
create table check5 as
  SELECT distinct *
  FROM b.allrx_10 
  WHERE missing (rx_end);
quit; /*missing rx_end =1440 */
/* Step 6: assign median to sup_days for remaining 1402 wo rx_end*/
/*median imputation*/
proc means data=b.allrx_10 median noprint;
var sup_days;
class atccde;
output out=sup_days_median median= /autoname;
run;
proc sql;
create table b.allrx_11 as
select A.*, B.sup_days_median from b.allrx_10 a 
left join sup_days_median b on a.atccde=b.atccde;
quit;
data b.allrx_12;
 set b.allrx_11;
 if missing (rx_end) 
then rx_end=rx_date+sup_days_median-1;
run;
proc sql;
create table check5 as
  SELECT distinct *
  FROM b.allrx_12 
  WHERE missing (rx_end);
quit; /*missing rx_end =0 */
proc sql;
create table b.allrx_13 as
select 
compress(id) as id, 
atccde,
rx_date,
rx_end,
sup_days as supply_day,
dailydose as dose, 
supply_quantity,
setting
from b.allrx_12;
quit;
data b.allrx_14;
set b.allrx_13;
if atccde="exclude"
then delete;
run;
/* Step 7: export to cdm library c*/
data c.drug_final;
   set b.allrx_14;
run;
/* Table 3: Diagnosis table*/
/* Step 1: Import data */
PROC IMPORT  DATAFILE= "D:\SAS\sccs_mph\raw\MPH9620allcohort_alldx.csv"
OUT= a.dx
DBMS=csv REPLACE;
delimiter=',';
GETNAMES=YES;
guessingrows=max;
RUN;
/* Step 2: keep drop variable from raw */
proc sql;
create table b.dx_1 as
select 
compress(put(Reference_Key,8.)) as id format= $8.,
All_Diagnosis_Code__ICD9__ as icd9cm,
All_Diagnosis_Description__HAMDC as dx,
admdt as event_date format=DATE9.,
Patient_Type__IP_OP_A_E__ as setting
from a.dx;
quit;
proc sql;
select count(distinct id) as unique_id,
count(distinct case when icd9cm contains "E95" then id else "." end) as unique_suicide
from b.dx_1;
quit;
/* number of unique patient with suicide = 472*/
/*Step 3: Export to cdm library c*/
data c.dx_final;
   set b.dx_1;
run;
** END OF ESTABLISHING CDM **
