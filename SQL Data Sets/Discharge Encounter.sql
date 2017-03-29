SELECT patient_identifier.identifier, 
DATE(person.date_created) AS register_date, 
concat(family_name, ' ', given_name) as fullname, 
birthdate, 
gender,
discharge_encounter.encounter_datetime as discharge_datetime,
(SELECT CONCAT(provider_name.family_name, ', ', provider_name.given_name) as provider FROM person_name as provider_name WHERE provider_name.preferred = 1 AND provider_name.voided = 0 AND provider_name.person_id = (SELECT person_id FROM provider WHERE provider_id = (SELECT provider_id FROM encounter_provider WHERE voided = 0 AND encounter_id = discharge_encounter.encounter_id LIMIT 1) LIMIT 1 ) LIMIT 1) as discharge_provider,
(SELECT location.name FROM location where location.location_id=discharge_encounter.location_id LIMIT 1) as discharge_location

FROM person, person_name, patient_identifier, encounter as discharge_encounter
WHERE person.person_id = :personId 
-- AND discharge_encounter.encounter_id = :encounterId
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