SELECT gender, COUNT(*) AS Total

FROM person, person_name, patient_identifier
WHERE person.person_id = person_name.person_id 
AND person.person_id = patient_identifier.patient_id
AND person.voided=0 
AND person_name.voided=0 
AND patient_identifier.voided=0
AND person_name.preferred=1 
AND patient_identifier.preferred=1 
AND patient_identifier.identifier_type=3
AND TIMESTAMPDIFF(YEAR, person.birthdate, CURDATE()) < 5

GROUP BY gender