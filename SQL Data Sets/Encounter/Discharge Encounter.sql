SELECT patient_identifier.identifier, 
DATE(person.date_created) AS register_date, 
CONCAT(family_name, ' ', given_name) AS fullname, 
birthdate, 
TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) AS age, 
gender,
(SELECT person_attribute.value FROM person_attribute WHERE person_attribute_type_id=11 AND 
person_attribute.person_id=person.person_id ) AS fathername,
(SELECT person_attribute.value FROM person_attribute WHERE person_attribute_type_id=4 AND 
person_attribute.person_id=person.person_id ) AS mothername,
(SELECT CONCAT(person_address.address1, ', ', person_address.address2
, ', ', person_address.city_village, ', ', person_address.state_province, ', ', person_address.country) FROM person_address WHERE person_address.person_id=person.person_id) AS address,

(select encounter_datetime from encounter as admission_encounter where  admission_encounter.voided = 0 AND admission_encounter.encounter_type = 4 and admission_encounter.visit_id=discharge_encounter.visit_id order by admission_encounter.encounter_id asc limit 1) AS admission_datetime,

discharge_encounter.encounter_datetime AS discharge_datetime,
(SELECT CONCAT(provider_name.family_name, ', ', provider_name.given_name) AS provider FROM person_name AS provider_name WHERE provider_name.preferred = 1 AND provider_name.voided = 0 AND provider_name.person_id = (SELECT person_id FROM provider WHERE provider_id = (SELECT provider_id FROM encounter_provider WHERE voided = 0 AND encounter_id = discharge_encounter.encounter_id LIMIT 1) LIMIT 1 ) LIMIT 1) AS discharge_provider,
(SELECT location.name FROM location WHERE location.location_id=discharge_encounter.location_id LIMIT 1) AS discharge_location,

(SELECT (SELECT `name` FROM `concept_name` WHERE `voided` = 0 AND `locale` IN ('en','pa') AND `concept_id` = `value_coded`  AND `concept_name_type` = 'FULLY_SPECIFIED' ORDER BY `locale` DESC LIMIT 1) AS concept_name  FROM `obs` WHERE `concept_id` = 163105 AND `obs`.`encounter_id` = `discharge_encounter`.`encounter_id` AND `voided` = 0  LIMIT 1) AS general_treatment_status,

(SELECT obs.value_text FROM obs WHERE obs.voided= 0 AND obs.concept_id=163104 AND obs.encounter_id=discharge_encounter.encounter_id LIMIT 1) AS treatment_plan_at_hospital,
(SELECT obs.value_text FROM obs WHERE obs.voided= 0 AND obs.concept_id=163106 AND obs.encounter_id=discharge_encounter.encounter_id LIMIT 1) AS instructions_to_patient_and_family,
(SELECT obs.value_datetime FROM obs WHERE obs.voided= 0 AND obs.concept_id=5096 AND obs.encounter_id=discharge_encounter.encounter_id LIMIT 1) AS next_appointment_date,

now() as now

FROM person, person_name, patient_identifier, encounter AS discharge_encounter
WHERE person.person_id = :patientId
AND discharge_encounter.encounter_id = :encounterId
AND person.person_id = person_name.person_id 
AND person.person_id = patient_identifier.patient_id
AND person.voided=0 
AND person_name.voided=0 
AND patient_identifier.voided=0
AND person_name.preferred=1 
AND patient_identifier.preferred=1 
AND patient_identifier.identifier_type=3
AND patient_identifier.patient_id = discharge_encounter.patient_id
AND discharge_encounter.voided = 0 AND discharge_encounter.encounter_type = 3 
-- LIMIT 1;