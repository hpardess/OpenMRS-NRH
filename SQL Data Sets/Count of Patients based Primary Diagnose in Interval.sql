SELECT * FROM (
(SELECT 
(SELECT `name` FROM `concept_name` 
WHERE `voided` = 0 AND `locale` IN ('en','pa') AND `concept_id` = diagnose.`value_coded`  
AND `concept_name_type` = 'FULLY_SPECIFIED' ORDER BY `locale` DESC LIMIT 1) AS DiagnoseName, 'Coded' AS 'Type', COUNT(*) AS 'Total Patients'

FROM encounter AS visit_note_encounter, obs AS diagnose, obs AS diagnose_type, person, person_name, patient_identifier
WHERE visit_note_encounter.voided = 0 
AND visit_note_encounter.encounter_type = 5
AND DATE(visit_note_encounter.encounter_datetime) BETWEEN :startDate AND :endDate
AND diagnose.voided = 0	
AND diagnose.encounter_id = visit_note_encounter.encounter_id
AND diagnose.concept_id = 1284 -- it is coded diagnose concept - PROBLEM LIST
AND diagnose_type.encounter_id = visit_note_encounter.encounter_id
AND diagnose.obs_group_id = diagnose_type.obs_group_id AND diagnose_type.concept_id = 159946 
AND diagnose_type.value_coded = 159943

AND person.person_id = person_name.person_id 
AND person.person_id = patient_identifier.patient_id
AND person.voided=0 
AND person_name.voided=0 
AND patient_identifier.voided=0
AND person_name.preferred=1 
AND patient_identifier.preferred=1 
AND patient_identifier.identifier_type=3
AND patient_identifier.patient_id = visit_note_encounter.patient_id
GROUP BY DiagnoseName
ORDER BY DiagnoseName ASC)

UNION ALL

(SELECT diagnose.value_text AS DiagnoseName, 'Non-Coded' AS 'Type', COUNT(*) AS 'Total Patients'

FROM encounter AS visit_note_encounter, obs AS diagnose, obs AS diagnose_type, person, person_name, patient_identifier
WHERE visit_note_encounter.voided = 0 
AND visit_note_encounter.encounter_type = 5
AND DATE(visit_note_encounter.encounter_datetime) BETWEEN :startDate AND :endDate
AND diagnose.voided = 0
AND diagnose.encounter_id = visit_note_encounter.encounter_id
AND diagnose.concept_id = 161602 -- it is coded diagnose concept - Diagnosis or problem, non-coded
AND diagnose_type.encounter_id = visit_note_encounter.encounter_id
AND diagnose.obs_group_id = diagnose_type.obs_group_id AND diagnose_type.concept_id = 159946 
AND diagnose_type.value_coded = 159943

AND person.person_id = person_name.person_id 
AND person.person_id = patient_identifier.patient_id
AND person.voided=0 
AND person_name.voided=0 
AND patient_identifier.voided=0
AND person_name.preferred=1 
AND patient_identifier.preferred=1 
AND patient_identifier.identifier_type=3
AND patient_identifier.patient_id = visit_note_encounter.patient_id
GROUP BY DiagnoseName
ORDER BY DiagnoseName ASC)
) t