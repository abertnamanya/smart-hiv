/**
 * Library: HIV.IND.24 Logic
 * Ref No: HTS.7
 * Short Name: HTS linkage to prevention
 *
 * Definition: Among those testing HIV-negative and identified as being at elevated risk for HIV acquisition, % of people who receive an HIV prevention intervention within defined period
 *
 * Numerator: Number of people who receive an HIV prevention intervention within a defined period after receiving a negative HIV test result
 * Numerator Calculation: COUNT of clients with "At elevated risk for HIV acquisition"=True and with "Date accessed HIV prevention intervention" within X days of "HIV test date" in the reporting period with "HIV test result"='HIV-negative' |  | where X is 7, 14, or 28 days
 * Numerator Exclusions: 
 *
 * Denominator: Number of people testing negative for HIV in the reporting period and identified as being at elevated risk for HIV acquisition (includes people requesting/receiving any HIV prevention intervention, people from key populations, people with known risk factors or those assessed as being at risk of HIV acquisition)
 * Denominator Calculation: COUNT of clients with "At elevated risk for HIV acquisition"=True AND with an "HIV test date" in the reporting period with "HIV test result"='HIV-negative'
 * Denominator Exclusions: 
 *
 * Disaggregations:
 * • Gender (female, male, other*) 
 *  • Age (<15, 15–19, 20–24, 25–49, 50+ years)** 
 *  • Key populations (men who have sex with men, people living in prisons and other closed settings, people who inject drugs, sex workers, trans and gender diverse people)*** 
 *  • HIV prevention intervention (including PrEP, OAMT, NSP, STI services, VMMC) 
 *  • Provider type (key population-led or community-led organization, public sector provider, other entities such as private for-profit and not-for-profit organizations, including faith-based, international, nongovernmental) 
 *  • Cities and other administrative regions of epidemiologic importance
 *
 * Disaggregation Elements: Gender | Age | Key population member type | HIV prevention intervention
 *
 * Numerator and Denominator Elements:
 * At elevated risk for HIV acquisition 
 *  Date accessed HIV prevention intervention 
 *  HIV test date 
 *  HIV test result
 *
 * Reference: Consolidated guidelines on person-centred HIV strategic information: strengthening routine data for impact. Geneva: World Health Organization; 2022
 * 
 * Data Concepts:
 * HIV.A.DE17: Age | Calculated age (number of years) of the client based on date of birth
 * HIV.A.DE18: Gender* | Gender of the client*
 * HIV.A.DE19: Female | Client identifies as female
 * HIV.A.DE20: Male | Client identifies as male
 * HIV.A.DE21: Transgender male | Client identifies as transgender male
 * HIV.A.DE22: Transgender female | Client identifies as transgender female
 * HIV.A.DE23: Other | Additional category
 * HIV.B.DE50: Key population member type* | The type of key population that the client is included in
 * HIV.B.DE51: Sex worker | Client is a sex worker
 * HIV.B.DE52: Men who have sex with men | Client is a man who has sex with men
 * HIV.B.DE53: Trans and gender-diverse people | Client identifies as trans and gender-diverse
 * HIV.B.DE54: People who inject drugs | Client is a person who injects drugs
 * HIV.B.DE55: People living in prisons and other closed settings | Client lives in a prison or another closed setting
 * HIV.B.DE110: HIV test date | Date of the HIV test
 * HIV.B.DE111: HIV test result | The result from HIV testing after applying the testing algorithm
 * HIV.B.DE112: HIV-positive | Test result is HIV-positive
 * HIV.B.DE113: HIV-negative | Test result is HIV-negative
 * HIV.B.DE114: HIV-inconclusive | Test result is HIV-inconclusive
 * HIV.B.DE225: At elevated risk for HIV acquisition | Client is at elevated risk for HIV acquisition
 * HIV.E.DE114: Key population member type* | The type of key population that the infant's mother is included in
 * HIV.E.DE115: Sex worker | Infant's mother is a sex worker
 * HIV.E.DE116: People who inject drugs | Infant's mother is a person who injects drugs
 * HIV.E.DE117: Trans and gender-diverse people | Infant's mother identifies as trans and gender-diverse
 * HIV.E.DE118: People living in prisons and other closed setting | Infant's mother is in a prison or closed setting
 * HIV.E.DE224: HIV test date | Date of the HIV test
 * HIV.PRV.DE1: At elevated risk for HIV acquisition | Client is at elevated risk for HIV acquisition, defined according to country/programme context
 * HIV.PRV.DE2: HIV prevention intervention | HIV prevention intervention that client accessed
 * HIV.PRV.DE3: PrEP service | Client accessed PrEP services
 * HIV.PRV.DE4: OAMT | Client accessed opioid agonist maintenance treatment (OAMT) services
 * HIV.PRV.DE5: NSP | Client accessed needle-syringe programme (NSP) services
 * HIV.PRV.DE6: STI services | Client accessed sexually transmitted infection (STI) services
 * HIV.PRV.DE7: VMMC | Client accessed voluntary medical male circumcision (VMMC) services
 * HIV.PRV.DE8: Other | Client accessed other HIV prevention services
 * HIV.PRV.DE10: Date accessed HIV prevention intervention | Date the client accessed HIV prevention intervention
 * HIV.SRV.DE1: HIV test date | Date of the HIV test
 * HIV.SRV.DE2: HIV test result | The result from HIV testing after applying the testing algorithm
 *
 * Additional Context
 * - what it measures: Measures the proportion of people receiving HIV prevention within set period (for example, same day, 7, 14 or 28 days) after receiving a negative HIV test result.
 * - rationale: Access to HIV prevention interventions is important to reduce the risk of HIV acquisition among individuals testing HIV-negative. Ensuring individuals at ongoing risk are successfully linked to relevant HIV prevention is an important outcome following HIV testing.
 * - method: Individual-level data obtained from programme records |  | The indicator should exclude current PrEP recipients, as they are tested on a regular basis. As ongoing PrEP recipients are engaged in prevention, the number of days to intervention uptake is 0.
 * 
 * Suggested Scoring Method: proportion | http://hl7.org/fhir/us/cqfmeasures/StructureDefinition/proportion-measure-cqfm
 */

library HIVIND24Logic

// Included Libraries
using FHIR version '4.0.1'

include HIVCommon version '0.0.1' called HIC
include FHIRHelpers version '4.0.1'
include WHOCommon called WCom

// Indicator Definition
parameter "Measurement Period" Interval<Date> default Interval[@2023-01-01, @2023-01-30]
parameter "Intervention Interval" System.Quantity default 7 days

context Patient
/* Populations */

/*
 *Initial Population
 */

define "Initial Population":
  true


define "Negative Tests within Measurement Period":
HIC."HIV Negative Observation" O
    with HIC."Client is at elevated risk for HIV acquisition" HIV
    such that O.hasMember.references(HIV)
    and O.issued after start of "Measurement Period"
    and O.issued before end of "Measurement Period"
Sort by O.issued

define "First Negative Test within Measurement Period":
( First("Negative Tests within Measurement Period"))

define PReP_intervention:
"PReP Intervention" P 
  where P.effective starts before ("First Negative Test within Measurement Period" + "Intervention Interval")
  and P.effective starts after ("First Negative Test within Measurement Period")

define "OAMT_intervention":
  [EpisodeOfCare] EOC
    where exists(EOC.type T where T ~ HC."OAMT")
    and (exists (
      EOC.statusHistory H
      where H.period starts before ("First Negative Test within Measurement Period" + "Intervention Interval")
      and H.period starts after ("First Negative Test within Measurement Period")
    ) 
    or (
      EOC.period starts before ("First Negative Test within Measurement Period" + "Intervention Interval")
      and EOC.period starts after ("First Negative Test within Measurement Period")
    )
    )

define NSP_intervention:
  HIC."Needle Syringe Dispensed" DUS
	where DUS.timing starts before ("First Negative Test within Measurement Period" + "Intervention Interval")
  and DUS.timing starts after ("First Negative Test within Measurement Period")

define STI_intervention:
  HIC.STI_testing STI
	where STI.performed starts before ("First Negative Test within Measurement Period" + "Intervention Interval")
  and STI.performed starts after ("First Negative Test within Measurement Period")

define VMMC_intervention:
  HIC."VMMC_done" VM
  where VM.performed starts before ("First Negative Test within Measurement Period" + "Intervention Interval")
  and VM.performed starts after ("First Negative Test within Measurement Period")

/**
 * Numerator
 * 
 * Definition: Number of people who receive an HIV prevention intervention within a defined period after receiving a negative HIV test result
 * Calculation: COUNT of clients with "At elevated risk for HIV acquisition"=True and with "Date accessed HIV prevention intervention" within X days of "HIV test date" in the reporting period with "HIV test result"='HIV-negative' |  | where X is 7, 14, or 28 days
 */

define "Numerator":
  exists(PReP_intervention
  )
  or exists(OAMT_intervention
  )
  or exists(NSP_intervention
  )
  or exists(STI_intervention
  )
  or exists(VMMC_intervention
  )



/**
 * Denominator
 *
 * Definition: Number of people testing negative for HIV in the reporting period and identified as being at elevated risk for HIV acquisition (includes people requesting/receiving any HIV prevention intervention, people from key populations, people with known risk factors or those assessed as being at risk of HIV acquisition)
 * Calculation: COUNT of clients with "At elevated risk for HIV acquisition"=True AND with an "HIV test date" in the reporting period with "HIV test result"='HIV-negative'
 */

define "Denominator":
  exists(HIC."Negative Tests within Measurement Period")
    

/* end Populations */


/*
 * Disaggregators
 */

define "Administrative Gender Stratifier":
	HIC."By Administrative Gender Stratifier"

define "Age Stratifier":
	HIC."By Age Stratifier 2"

define "Geographic Region Stratifier":
	HIC."By Geographic Region Stratifier"

define "patientGroups Stratifier":
	HIC."patientGroups"

define "HIV prevention intervention":
	HIC."HIV prevention intervention"

define "Stratification":
 HIC."By Administrative Gender Stratifier".code 
  + ':' + HIC."By Age Stratifier 2"
+ ':' + HIC."By Geographic Region Stratifier"
+ Combine(HIC.patientGroups, ':')
//need to fix
//+ Combine(HIC."HIV prevention intervention", ':')