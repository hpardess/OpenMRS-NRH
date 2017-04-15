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

visit_note_encounter.encounter_datetime AS visit_note_datetime,
(SELECT CONCAT(person_name.family_name, ', ', person_name.given_name) FROM person_name , provider WHERE person_name.voided = 0 AND person_name.person_id=provider.`person_id` AND provider.provider_id = (SELECT provider_id FROM encounter_provider WHERE encounter_provider.voided=0 AND encounter_provider.encounter_id=visit_note_encounter.encounter_id LIMIT 1) LIMIT 1) AS visit_note_provider,

(SELECT location.name FROM location WHERE location.location_id=visit_note_encounter.location_id LIMIT 1) AS visit_note_location,
(SELECT clinic_note.value_text FROM obs AS clinic_note WHERE clinic_note.voided= 0 AND clinic_note.concept_id=162169 AND clinic_note.encounter_id=visit_note_encounter.encounter_id LIMIT 1) AS visit_note_clinic_note,

(

SELECT CONCAT_WS(', ', GROUP_CONCAT(UPPER(
(SELECT `name` FROM `concept_name` WHERE `voided` = 0 AND `locale` IN ('en','fr') AND `concept_id` = `diags`.`value_coded`  AND `concept_name_type` = 'FULLY_SPECIFIED' ORDER BY `locale` DESC LIMIT 1)) SEPARATOR ', '),
(SELECT GROUP_CONCAT(UPPER(`diags`.`value_text`) SEPARATOR ', ') FROM `obs` AS diags, `obs` AS diag_type WHERE `diags`.`concept_id` = 161602 AND `diags`.`encounter_id` = `visit_note_encounter`.`encounter_id` AND `diag_type`.`encounter_id` = `visit_note_encounter`.`encounter_id` AND `diags`.`voided` = 0 AND `diag_type`.`voided` = 0 AND `diags`.`obs_group_id` = `diag_type`.`obs_group_id` AND `diag_type`.`concept_id` = 159394 AND `diag_type`.`value_coded` = 160250
)
)
FROM `obs` AS diags, `obs` AS diag_type WHERE `diags`.`concept_id` = 1284 AND `diags`.`encounter_id` = `visit_note_encounter`.`encounter_id` AND `diag_type`.`encounter_id` = `visit_note_encounter`.`encounter_id` AND `diags`.`voided` = 0 AND `diag_type`.`voided` = 0 AND `diags`.`obs_group_id` = `diag_type`.`obs_group_id` AND `diag_type`.`concept_id` = 159394 AND `diag_type`.`value_coded` = 160250





) AS visit_note_primary_diagnoses,

 (1) as visit_note_secondary_diagnoses,

NOW() AS NOW

FROM person, person_name, patient_identifier, encounter AS visit_note_encounter
WHERE person.person_id = :patientId 
AND visit_note_encounter.encounter_id = :encounterId
AND person.person_id = person_name.person_id 
AND person.person_id = patient_identifier.patient_id
AND person.voided=0 
AND person_name.voided=0 
AND patient_identifier.voided=0
AND person_name.preferred=1 
AND patient_identifier.preferred=1 
AND patient_identifier.identifier_type=3
AND patient_identifier.patient_id = visit_note_encounter.patient_id
AND visit_note_encounter.voided = 0 AND visit_note_encounter.encounter_type = 5 
-- LIMIT 1;

