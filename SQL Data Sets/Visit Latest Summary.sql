SELECT patient_identifier.identifier, 
DATE(person.date_created) AS register_date, 
CONCAT(family_name, ' ', given_name) AS fullname, 
birthdate, 
gender,
vital_encounter.encounter_datetime AS vital_datetime,
(SELECT CONCAT(provider_name.family_name, ', ', provider_name.given_name) AS provider FROM person_name AS provider_name WHERE provider_name.preferred = 1 AND provider_name.voided = 0 AND provider_name.person_id = (SELECT person_id FROM provider WHERE provider_id = (SELECT provider_id FROM encounter_provider WHERE voided = 0 AND encounter_id = vital_encounter.encounter_id LIMIT 1) LIMIT 1 ) LIMIT 1) AS vital_provider,
(SELECT location.name FROM location WHERE location.location_id=vital_encounter.location_id LIMIT 1) AS vital_location,

IFNULL((SELECT CONCAT(vital.value_numeric, 'cm') FROM obs AS vital 
WHERE vital.voided= 0 
AND vital.concept_id=5090
AND vital.encounter_id = vital_encounter.encounter_id
LIMIT 1), '_cm') AS "height_en",

IFNULL((SELECT CONCAT(vital.value_numeric, 'kg') FROM obs AS vital 
WHERE vital.voided= 0 
AND vital.concept_id=5089 
AND vital.encounter_id = vital_encounter.encounter_id
LIMIT 1), '_kg') AS "weight_en",

IFNULL((SELECT CONCAT(vital.value_numeric) FROM obs AS vital 
WHERE vital.voided= 0 
AND vital.concept_id=5088 
AND vital.encounter_id = vital_encounter.encounter_id
LIMIT 1), '_') AS "temperature_en",

IFNULL((SELECT CONCAT(vital.value_numeric, '/min') FROM obs AS vital 
WHERE vital.voided= 0
AND vital.concept_id=5087 
AND vital.encounter_id = vital_encounter.encounter_id
LIMIT 1), '_/min') AS "pulse_en",

IFNULL((SELECT CONCAT(vital.value_numeric, '/min') FROM obs AS vital 
WHERE vital.voided= 0 
AND vital.concept_id=5242
AND vital.encounter_id = vital_encounter.encounter_id
LIMIT 1), '_/min') AS "respiratory_rate_en",

IFNULL((SELECT CONCAT(vital.value_numeric, '/100') FROM obs AS vital
WHERE vital.voided= 0
AND vital.concept_id=5085 
AND vital.encounter_id = vital_encounter.encounter_id
LIMIT 1), '_/100') AS "systolic_blood_pressure_en",

IFNULL((SELECT CONCAT(vital.value_numeric, '/100') FROM obs AS vital 
WHERE vital.voided= 0 
AND vital.concept_id=5086  
AND vital.encounter_id = vital_encounter.encounter_id
LIMIT 1), '_/100') AS "diastolic_blood_pressure_en",

IFNULL((SELECT CONCAT(vital.value_numeric, '%') FROM obs AS vital 
WHERE vital.voided= 0 
AND vital.concept_id=5092  
AND vital.encounter_id = vital_encounter.encounter_id
LIMIT 1), '_%') AS "blood_oxygen_saturation_en"






FROM person, person_name, patient_identifier, visit, encounter AS vital_encounter, encounter AS admission_encounter, encounter AS visit_note_encounter 
WHERE -- person.person_id = 7 -- :patient
-- AND vital_encounter.encounter_id = :encounterId
visit.`visit_id` = 1 -- :visitId
AND visit.`voided` = 0
AND visit.`patient_id` = person.`person_id`
AND visit.`patient_id` = person.`person_id`
AND person.person_id = person_name.person_id 
AND person.person_id = patient_identifier.patient_id
AND person.voided=0 
AND person_name.voided=0 
AND patient_identifier.voided=0
AND person_name.preferred=1 
AND patient_identifier.preferred=1 
AND patient_identifier.identifier_type=3
AND patient_identifier.patient_id = vital_encounter.patient_id
AND vital_encounter.voided = 0 AND vital_encounter.encounter_type = 2 
AND admission_encounter.voided = 0
AND visit_note_encounter.voided = 0
-- LIMIT 1;