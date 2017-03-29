SELECT visit.visit_id,
visit.date_created,
visit.date_started,
visit.date_stopped,
(SELECT location.name FROM location WHERE location.location_id=visit.location_id LIMIT 1) AS visit_location

FROM visit, visit_type, care_setting
WHERE visit.patient_id = :person
AND visit.visit_type_id=visit_type.visit_type_id 
AND visit.`voided`=0
-- LIMIT 1;