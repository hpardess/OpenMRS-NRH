SELECT patient_identifier.identifier, 
DATE(person.date_created) AS register_date, 
concat(family_name, ' ', given_name) as fullname, 
birthdate,
TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) AS age, 
gender,
(SELECT person_attribute.value FROM person_attribute WHERE person_attribute_type_id=11 AND 
person_attribute.person_id=person.person_id ) AS fathername,
(SELECT person_attribute.value FROM person_attribute WHERE person_attribute_type_id=4 AND 
person_attribute.person_id=person.person_id ) AS mothername,

vital_encounter.encounter_datetime as vital_datetime,
(SELECT CONCAT(provider_name.family_name, ', ', provider_name.given_name) as provider FROM person_name as provider_name WHERE provider_name.preferred = 1 AND provider_name.voided = 0 AND provider_name.person_id = (SELECT person_id FROM provider WHERE provider_id = (SELECT provider_id FROM encounter_provider WHERE voided = 0 AND encounter_id = vital_encounter.encounter_id LIMIT 1) LIMIT 1 ) LIMIT 1) as vital_provider,
(SELECT location.name FROM location where location.location_id=vital_encounter.location_id LIMIT 1) as vital_location,

ifnull((SELECT CONCAT(vital.value_numeric, 'cm') FROM obs AS vital 
WHERE vital.voided= 0 
AND vital.concept_id=5090
AND vital.encounter_id = vital_encounter.encounter_id
LIMIT 1), '_cm') AS "height_en",

ifnull((SELECT CONCAT(vital.value_numeric, 'kg') FROM obs AS vital 
WHERE vital.voided= 0 
AND vital.concept_id=5089 
AND vital.encounter_id = vital_encounter.encounter_id
LIMIT 1), '_kg') AS "weight_en",

ifnull((SELECT round(weight.value_numeric/(height.value_numeric/100)*(height.value_numeric/100), 2) FROM obs AS weight, obs AS height
WHERE weight.voided= 0 
AND weight.concept_id=5089 
and height.voided= 0 
AND height.concept_id=5090
AND weight.encounter_id = height.encounter_id
AND height.encounter_id = vital_encounter.encounter_id
LIMIT 1), 'Can not Calculate') AS "bmi_en",

ifnull((SELECT CONCAT(vital.value_numeric) FROM obs AS vital 
WHERE vital.voided= 0 
AND vital.concept_id=5088 
AND vital.encounter_id = vital_encounter.encounter_id
LIMIT 1), '_') AS "temperature_en",

ifnull((SELECT CONCAT(vital.value_numeric, '/min') FROM obs AS vital 
WHERE vital.voided= 0
AND vital.concept_id=5087 
AND vital.encounter_id = vital_encounter.encounter_id
LIMIT 1), '_/min') AS "pulse_en",

ifnull((SELECT CONCAT(vital.value_numeric, '/min') FROM obs AS vital 
WHERE vital.voided= 0 
AND vital.concept_id=5242
AND vital.encounter_id = vital_encounter.encounter_id
LIMIT 1), '_/min') AS "respiratory_rate_en",

ifnull((SELECT CONCAT(vital.value_numeric, '/100') FROM obs AS vital
WHERE vital.voided= 0
AND vital.concept_id=5085 
AND vital.encounter_id = vital_encounter.encounter_id
LIMIT 1), '_/100') AS "systolic_blood_pressure_en",

ifnull((SELECT CONCAT(vital.value_numeric, '/100') FROM obs AS vital 
WHERE vital.voided= 0 
AND vital.concept_id=5086  
AND vital.encounter_id = vital_encounter.encounter_id
LIMIT 1), '_/100') AS "diastolic_blood_pressure_en",

ifnull((SELECT CONCAT(vital.value_numeric, '%') FROM obs AS vital 
WHERE vital.voided= 0 
AND vital.concept_id=5092  
AND vital.encounter_id = vital_encounter.encounter_id
LIMIT 1), '_%') AS "blood_oxygen_saturation_en",

now() as now

FROM person, person_name, patient_identifier, encounter as vital_encounter
WHERE person.person_id = :patient
AND vital_encounter.encounter_id = :encounterId
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
-- LIMIT 1;