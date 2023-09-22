
select * from  p_cause_effect
where dataset_id in (select dataset_id from p_dataset where citation_id not in (
                                    select citation_id  from p_citation where citation_id > 2455 ) )
                                    
select * 
from p_analysis_details
where cause_effect_id in (select cause_effect_id from ( select * from  p_cause_effect
where dataset_id in (select dataset_id from p_dataset where citation_id not in (
                                    select citation_id  from p_citation where citation_id > 2455 ) ) ) )
                                    
select *
from  p_cause_measured where cause_effect_id in (select cause_effect_id from ( select * from  p_cause_effect
where dataset_id in (select dataset_id from p_dataset where citation_id not in (
                                    select citation_id  from p_citation where citation_id > 2455 ) ) ) )

select *
from   p_effect_measured
where cause_effect_id in (select cause_effect_id from ( select * from  p_cause_effect
where dataset_id in (select dataset_id from p_dataset where citation_id not in (
                                    select citation_id  from p_citation where citation_id > 2455 ) ) ) )
                                    
 select * from p_CLASS_DESCRIPTOR
where dataset_id in (select dataset_id from p_dataset where citation_id not in (
                                    select citation_id  from p_citation where citation_id > 2455 ) )
                                    

 select * from p_CLASS_details
where cause_effect_id in (select cause_effect_id from ( select * from  p_cause_effect
where dataset_id in (select dataset_id from p_dataset where citation_id not in (
                                    select citation_id  from p_citation where citation_id > 2455 ) ) ) )
  and class_detail_id >= 60000 -- <600000
 
 select * from P_SI_SIGNIFICANTS
where cause_effect_id in (select cause_effect_id from ( select * from  p_cause_effect
where dataset_id in (select dataset_id from p_dataset where citation_id not in (
                                    select citation_id  from p_citation where citation_id > 2455 ) ) ) )

 select * from P_SI_SIGNIFICANTS_EVIDENCE
 where SI_SIGNIFICANT_id in (select SI_SIGNIFICANT_id from P_SI_SIGNIFICANTS
where cause_effect_id in (select cause_effect_id from ( select * from  p_cause_effect
where dataset_id in (select dataset_id from p_dataset where citation_id not in (
                                    select citation_id  from p_citation where citation_id > 2455 ) ) ) ))
