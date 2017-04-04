SELECT patient_identifier.identifier, 
DATE(person.date_created) AS register_date, 
CONCAT(family_name, ' ', given_name) AS fullname, 
birthdate, 
gender, 
admission_encounter.encounter_datetime AS admission_datetime,
(SELECT CONCAT(provider_name.family_name, ', ', provider_name.given_name) AS provider FROM person_name AS provider_name WHERE provider_name.preferred = 1 AND provider_name.voided = 0 AND provider_name.person_id = (SELECT person_id FROM provider WHERE provider_id = (SELECT provider_id FROM encounter_provider WHERE voided = 0 AND encounter_id = admission_encounter.encounter_id LIMIT 1) LIMIT 1 ) LIMIT 1) AS admission_provider,
(SELECT location.name FROM location WHERE location.location_id=admission_encounter.location_id LIMIT 1) AS admission_location,
(SELECT obs.value_text FROM obs WHERE obs.voided= 0 AND obs.concept_id=1655 AND obs.encounter_id=admission_encounter.encounter_id LIMIT 1) AS reason_for_admission_fixed,
(SELECT obs.value_text FROM obs WHERE obs.voided= 0 AND obs.concept_id=162879 AND obs.encounter_id=admission_encounter.encounter_id LIMIT 1) AS reason_for_admission_text,
(SELECT obs.value_text FROM obs WHERE obs.voided= 0 AND obs.concept_id=160531 AND obs.encounter_id=admission_encounter.encounter_id LIMIT 1) AS chief_complains,

IFNULL((SELECT CONCAT(vital.value_numeric, 'cm') FROM obs AS vital, encounter
WHERE vital.encounter_id = encounter.encounter_id
AND vital.voided= 0 
AND encounter.voided = 0 
AND encounter.encounter_type = 2
AND vital.concept_id=5090
AND encounter.visit_id = admission_encounter.visit_id
ORDER BY vital.obs_id ASC
LIMIT 1), '_cm') AS "height_en",

IFNULL((SELECT CONCAT(vital.value_numeric, 'kg') FROM obs AS vital, encounter
WHERE vital.encounter_id = encounter.encounter_id
AND vital.voided= 0 
AND encounter.encounter_type = 2
AND vital.concept_id=5089
AND encounter.visit_id = admission_encounter.visit_id
ORDER BY vital.obs_id ASC
LIMIT 1), '_kg') AS "weight_en",

IFNULL((SELECT CONCAT(vital.value_numeric) FROM obs AS vital, encounter 
WHERE vital.encounter_id = encounter.encounter_id
AND vital.voided= 0 
AND vital.concept_id=5088 
AND encounter.encounter_type = 2
AND encounter.visit_id = admission_encounter.visit_id
ORDER BY vital.obs_id ASC
LIMIT 1), '_') AS "temperature_en",

IFNULL((SELECT CONCAT(vital.value_numeric, '/min') FROM obs AS vital, encounter 
WHERE vital.encounter_id = encounter.encounter_id
AND vital.voided= 0
AND vital.concept_id=5087 
AND encounter.encounter_type = 2
AND encounter.visit_id = admission_encounter.visit_id
ORDER BY vital.obs_id ASC
LIMIT 1), '_/min') AS "pulse_en",

IFNULL((SELECT CONCAT(vital.value_numeric, '/min') FROM obs AS vital, encounter 
WHERE vital.encounter_id = encounter.encounter_id
AND vital.voided= 0 
AND vital.concept_id=5242
AND encounter.encounter_type = 2
AND encounter.visit_id = admission_encounter.visit_id
ORDER BY vital.obs_id ASC
LIMIT 1), '_/min') AS "respiratory_rate_en",

IFNULL((SELECT CONCAT(vital.value_numeric, '/100') FROM obs AS vital, encounter
WHERE vital.encounter_id = encounter.encounter_id
AND vital.voided= 0
AND vital.concept_id=5085 
AND encounter.encounter_type = 2
AND encounter.visit_id = admission_encounter.visit_id
ORDER BY vital.obs_id ASC
LIMIT 1), '_/100') AS "systolic_blood_pressure_en",

IFNULL((SELECT CONCAT(vital.value_numeric, '/100') FROM obs AS vital, encounter 
WHERE vital.encounter_id = encounter.encounter_id
AND vital.voided= 0 
AND vital.concept_id=5086  
AND encounter.encounter_type = 2
AND encounter.visit_id = admission_encounter.visit_id
ORDER BY vital.obs_id ASC
LIMIT 1), '_/100') AS "diastolic_blood_pressure_en",

IFNULL((SELECT CONCAT(vital.value_numeric, '%') FROM obs AS vital, encounter 
WHERE vital.encounter_id = encounter.encounter_id
AND vital.voided= 0 
AND vital.concept_id=5092  
AND encounter.encounter_type = 2
AND encounter.visit_id = admission_encounter.visit_id
ORDER BY vital.obs_id ASC
LIMIT 1), '_%') AS "blood_oxygen_saturation_en"

FROM person, person_name, patient_identifier, encounter AS admission_encounter
WHERE person.person_id = :patientId
AND admission_encounter.encounter_id = :encounterId
AND person.person_id = person_name.person_id 
AND person.person_id = patient_identifier.patient_id
AND person.voided=0 
AND person_name.voided=0 
AND patient_identifier.voided=0
AND person_name.preferred=1 
AND patient_identifier.preferred=1 
AND patient_identifier.identifier_type=3
AND patient_identifier.patient_id = admission_encounter.patient_id
AND admission_encounter.voided = 0 AND admission_encounter.encounter_type = 4 
-- LIMIT 1;