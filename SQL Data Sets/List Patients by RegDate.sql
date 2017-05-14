SELECT GROUP_CONCAT(patient_identifier.identifier SEPARATOR ',') as reg_nos, 
(SELECT identifier FROM patient_identifier WHERE patient_identifier.patient_id = person.person_id AND identifier_type=1 AND voided=0 AND preferred=1) AS identifier1, 
(SELECT identifier FROM patient_identifier WHERE patient_identifier.patient_id = person.person_id AND identifier_type=2 AND voided=0 AND preferred=1) AS identifier2, 
(SELECT identifier FROM patient_identifier WHERE patient_identifier.patient_id = person.person_id AND identifier_type=3 AND voided=0 AND preferred=1) AS identifier3,
DATE(person.date_created) AS register_date, given_name, family_name, 
CONCAT(family_name, ', ', given_name) AS fullname, birthdate, gender,
TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) AS age,
(select person_attribute.value from person_attribute where person_attribute_type_id=11 and 
person_attribute.person_id=person.person_id ) AS fathername,
(select person_attribute.value from person_attribute where person_attribute_type_id=4 and 
person_attribute.person_id=person.person_id ) AS mothername,
(select CONCAT(person_address.address1, ', ', person_address.address2
, ', ', person_address.city_village, ', ', person_address.state_province, ', ', person_address.country) From person_address where person_address.person_id=person.person_id) as address
FROM person, person_name, patient_identifier
WHERE person.person_id=person_name.person_id
AND person.person_id=patient_identifier.patient_id
AND person.voided=0
AND person_name.voided=0
AND patient_identifier.voided=0
AND person_name.preferred=1
AND patient_identifier.preferred=1
AND patient_identifier.identifier_type=3
and DATE(person.date_created) between :startDate and :endDate
group by person.person_id