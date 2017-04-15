SELECT GROUP_CONCAT(patient_identifier.identifier SEPARATOR ',') AS reg_nos,
patient_identifier.identifier, 
DATE(person.date_created) AS register_date, 
CONCAT(family_name, ' ', given_name) AS fullname, 
given_name, family_name, 
birthdate, 
TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) AS age, 
gender,
(SELECT person_attribute.value FROM person_attribute WHERE person_attribute_type_id=11 AND 
person_attribute.person_id=person.person_id ) AS fathername,
(SELECT person_attribute.value FROM person_attribute WHERE person_attribute_type_id=4 AND 
person_attribute.person_id=person.person_id ) AS mothername,
admission_encounter.encounter_datetime AS admission_datetime,
(SELECT CONCAT(person_address.address1, ', ', person_address.address2
, ', ', person_address.city_village, ', ', person_address.state_province, ', ', person_address.country) FROM person_address WHERE person_address.person_id=person.person_id) AS address,

(SELECT CONCAT(person_name.family_name, ', ', person_name.given_name) FROM person_name , provider WHERE person_name.voided = 0 AND person_name.person_id=provider.`person_id` AND provider.provider_id = (SELECT provider_id FROM encounter_provider WHERE encounter_provider.voided=0 AND encounter_provider.encounter_id=admission_encounter.encounter_id LIMIT 1) LIMIT 1) AS admission_provider,
(SELECT location.name FROM location WHERE location.location_id=admission_encounter.location_id LIMIT 1) AS admission_location,
(SELECT (SELECT `name` FROM `concept_name` WHERE `voided` = 0 AND `locale` IN ('en','pa') AND `concept_id` = `value_coded`  AND `concept_name_type` = 'FULLY_SPECIFIED' ORDER BY `locale` DESC LIMIT 1) AS concept_name  FROM `obs` WHERE `concept_id` = 1655 AND `obs`.`encounter_id` = `admission_encounter`.`encounter_id` AND `voided` = 0  LIMIT 1) AS reason_for_admission_fixed,
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
LIMIT 1), '_%') AS "blood_oxygen_saturation_en",

now() as now

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