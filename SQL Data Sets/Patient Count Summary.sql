SELECT 
/*
(
SELECT COUNT(*) AS Total
FROM person, person_name, patient_identifier
WHERE person.person_id = person_name.person_id 
AND person.person_id = patient_identifier.patient_id
-- AND person.voided=0 
AND person_name.voided=0 
-- AND patient_identifier.voided=0
-- AND person_name.preferred=1 
AND patient_identifier.preferred=1 
AND patient_identifier.identifier_type=3

) AS TotalPatients,
*/
(

SELECT COUNT(*) AS Total
FROM person, person_name, patient_identifier
WHERE person.person_id = person_name.person_id 
AND person.person_id = patient_identifier.patient_id
AND person.voided=0 
AND person_name.voided=0 
AND patient_identifier.voided=0
AND person_name.preferred=1 
AND patient_identifier.preferred=1 
AND patient_identifier.identifier_type=3

) AS TotalAvailablePatients, 
/*
(

SELECT COUNT(*) AS Total
FROM person, person_name, patient_identifier
WHERE person.person_id = person_name.person_id 
AND person.person_id = patient_identifier.patient_id
AND person.voided=1 
AND person_name.voided=0 
AND patient_identifier.voided=0
AND person_name.preferred=1 
AND patient_identifier.preferred=0 
AND patient_identifier.identifier_type=3

) as TotalDeletedPatients, 
*/
(

SELECT COUNT(*) AS Total
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
AND gender = 'M'

) AS TotalActivePatientsBelow5Male, (

SELECT COUNT(*) AS Total
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
AND gender = 'F'

) AS TotalActivePatientsBelow5Female, (

SELECT COUNT(*) AS Total
FROM person, person_name, patient_identifier
WHERE person.person_id = person_name.person_id 
AND person.person_id = patient_identifier.patient_id
AND person.voided=0 
AND person_name.voided=0 
AND patient_identifier.voided=0
AND person_name.preferred=1 
AND patient_identifier.preferred=1 
AND patient_identifier.identifier_type=3
AND TIMESTAMPDIFF(YEAR, person.birthdate, CURDATE()) >= 5
AND gender = 'M'

) AS TotalActivePatientsAbove5Male, (

SELECT COUNT(*) AS Total
FROM person, person_name, patient_identifier
WHERE person.person_id = person_name.person_id 
AND person.person_id = patient_identifier.patient_id
AND person.voided=0 
AND person_name.voided=0 
AND patient_identifier.voided=0
AND person_name.preferred=1 
AND patient_identifier.preferred=1 
AND patient_identifier.identifier_type=3
AND TIMESTAMPDIFF(YEAR, person.birthdate, CURDATE()) >= 5
AND gender = 'F'

) AS TotalActivePatientsAbove5Female