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

transfer_encounter.encounter_datetime AS transfer_datetime,
(SELECT CONCAT(person_name.family_name, ', ', person_name.given_name) FROM person_name , provider WHERE person_name.voided = 0 AND person_name.person_id=provider.`person_id` AND provider.provider_id = (SELECT provider_id FROM encounter_provider WHERE encounter_provider.voided=0 AND encounter_provider.encounter_id=transfer_encounter.encounter_id LIMIT 1) LIMIT 1) AS transfer_provider,

(SELECT location.name FROM location WHERE location.location_id=
(SELECT location_id FROM encounter as last_transfer_encounter WHERE last_transfer_encounter.voided = 0 AND last_transfer_encounter.encounter_type = 7 AND last_transfer_encounter.visit_id=transfer_encounter.visit_id AND last_transfer_encounter.encounter_id<transfer_encounter.`encounter_id` ORDER BY last_transfer_encounter.encounter_id DESC LIMIT 1) )AS transfer_from_location,

(SELECT location.name FROM location WHERE location.location_id=transfer_encounter.location_id LIMIT 1) AS transfer_to_location,
(SELECT obs.value_text FROM obs WHERE obs.voided= 0 AND obs.concept_id=162720 AND obs.encounter_id=transfer_encounter.encounter_id LIMIT 1) AS reason_for_patient_transfer,

now() as now

FROM person, person_name, patient_identifier, encounter AS transfer_encounter
WHERE person.person_id = :patientId
AND transfer_encounter.encounter_id = :encounterId
AND person.person_id = person_name.person_id 
AND person.person_id = patient_identifier.patient_id
AND person.voided=0 
AND person_name.voided=0 
AND patient_identifier.voided=0
AND person_name.preferred=1 
AND patient_identifier.preferred=1 
AND patient_identifier.identifier_type=3
AND patient_identifier.patient_id = transfer_encounter.patient_id
AND transfer_encounter.voided = 0 AND transfer_encounter.encounter_type = 7 
-- LIMIT 1;