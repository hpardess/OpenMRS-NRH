select patient_identifier.identifier,
CONCAT(person_name.family_name, ' ', person_name.given_name) AS fullname,
birthdate, 
TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) AS age,

diagnose.value_text as diagnose_noncoded_name

FROM encounter AS visit_note_encounter, obs as diagnose, person, person_name, patient_identifier
WHERE visit_note_encounter.voided = 0 
AND visit_note_encounter.encounter_type = 5
AND date(visit_note_encounter.encounter_datetime) between :startDate and :endDate
AND diagnose.voided = 0
AND diagnose.encounter_id = visit_note_encounter.encounter_id
AND diagnose.concept_id = 161602 -- it is coded diagnose concept - Diagnosis or problem, non-coded
AND diagnose.value_text = :diagnose

AND person.person_id = person_name.person_id 
AND person.person_id = patient_identifier.patient_id
AND person.voided=0 
AND person_name.voided=0 
AND patient_identifier.voided=0
AND person_name.preferred=1 
AND patient_identifier.preferred=1 
AND patient_identifier.identifier_type=3
AND patient_identifier.patient_id = visit_note_encounter.patient_id