select patient_identifier.identifier,
CONCAT(person_name.family_name, ' ', person_name.given_name) AS fullname,
birthdate, 
TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) AS age,

(SELECT `name` FROM `concept_name` 
WHERE `voided` = 0 AND `locale` IN ('en','pa') AND `concept_id` = diagnose.`value_coded`  
AND `concept_name_type` = 'FULLY_SPECIFIED' ORDER BY `locale` DESC LIMIT 1) as diagnose_coded_name

FROM encounter AS visit_note_encounter, obs as diagnose, person, person_name, patient_identifier
WHERE visit_note_encounter.voided = 0 
AND visit_note_encounter.encounter_type = 5
AND date(visit_note_encounter.encounter_datetime) between :startDate and :endDate
AND diagnose.voided = 0
AND diagnose.encounter_id = visit_note_encounter.encounter_id
AND diagnose.concept_id = 1284 -- it is coded diagnose concept - PROBLEM LIST
AND diagnose.value_coded = :diagnose

AND person.person_id = person_name.person_id 
AND person.person_id = patient_identifier.patient_id
AND person.voided=0 
AND person_name.voided=0 
AND patient_identifier.voided=0
AND person_name.preferred=1 
AND patient_identifier.preferred=1 
AND patient_identifier.identifier_type=3
AND patient_identifier.patient_id = visit_note_encounter.patient_id