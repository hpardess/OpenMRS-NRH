SELECT GROUP_CONCAT(patient_identifier.identifier SEPARATOR ','), 
(SELECT identifier FROM patient_identifier WHERE patient_identifier.patient_id = person.person_id AND identifier_type=1 AND voided=0 AND preferred=1) AS identifier1, 
(SELECT identifier FROM patient_identifier WHERE patient_identifier.patient_id = person.person_id AND identifier_type=2 AND voided=0 AND preferred=1) AS identifier2, 
(SELECT identifier FROM patient_identifier WHERE patient_identifier.patient_id = person.person_id AND identifier_type=3 AND voided=0 AND preferred=1) AS identifier3,
DATE(person.date_created) AS register_date, given_name, family_name, birthdate, gender
FROM person, person_name, patient_identifier
WHERE person.person_id = 7
AND person.person_id=person_name.person_id
AND person.person_id=patient_identifier.patient_id
AND person.voided=0
AND person_name.voided=0
AND patient_identifier.voided=0
AND person_name.preferred=1
AND patient_identifier.preferred=1
AND patient_identifier.identifier_type=3
 LIMIT 1;