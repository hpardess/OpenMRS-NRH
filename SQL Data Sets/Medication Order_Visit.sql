SELECT 
medication_order_encounter.encounter_datetime AS medication_order_datetime,
(SELECT CONCAT(provider_name.family_name, ', ', provider_name.given_name) AS provider FROM person_name AS provider_name WHERE provider_name.preferred = 1 AND provider_name.voided = 0 AND provider_name.person_id = (SELECT person_id FROM provider WHERE provider_id = (SELECT provider_id FROM encounter_provider WHERE voided = 0 AND encounter_id = medication_order_encounter.encounter_id LIMIT 1) LIMIT 1 ) LIMIT 1) AS medication_order_provider,
(SELECT location.name FROM location WHERE location.location_id=medication_order_encounter.location_id LIMIT 1) AS medication_order_location,

(SELECT (SELECT `name` FROM `concept_name` WHERE `voided` = 0 AND `locale` IN ('en','pa') AND `concept_id` = `value_coded`  AND `concept_name_type` = 'FULLY_SPECIFIED' ORDER BY `locale` DESC LIMIT 1) AS concept_name  FROM `obs` WHERE `concept_id` = 1282 AND `obs`.`encounter_id` = `medication_order_encounter`.`encounter_id` AND `voided` = 0  AND obs.`obs_group_id`=medication_group.obs_id LIMIT 1) AS drug_order,
(SELECT obs.value_numeric FROM obs WHERE obs.voided= 0 AND obs.concept_id=160856 AND obs.encounter_id=medication_order_encounter.encounter_id  AND obs.`obs_group_id`=medication_group.obs_id LIMIT 1) AS dose,
(SELECT (SELECT `name` FROM `concept_name` WHERE `voided` = 0 AND `locale` IN ('en','pa') AND `concept_id` = `value_coded`  AND `concept_name_type` = 'FULLY_SPECIFIED' ORDER BY `locale` DESC LIMIT 1) AS concept_name  FROM `obs` WHERE `concept_id` = 161563 AND `obs`.`encounter_id` = `medication_order_encounter`.`encounter_id` AND `voided` = 0  AND obs.`obs_group_id`=medication_group.obs_id LIMIT 1) AS dose_unit,
(SELECT (SELECT `name` FROM `concept_name` WHERE `voided` = 0 AND `locale` IN ('en','pa') AND `concept_id` = `value_coded`  AND `concept_name_type` = 'FULLY_SPECIFIED' ORDER BY `locale` DESC LIMIT 1) AS concept_name  FROM `obs` WHERE `concept_id` = 160855 AND `obs`.`encounter_id` = `medication_order_encounter`.`encounter_id` AND `voided` = 0  AND obs.`obs_group_id`=medication_group.obs_id LIMIT 1) AS frequency,
(SELECT CONCAT(obs.value_numeric, ' days') FROM obs WHERE obs.voided= 0 AND obs.concept_id=159368 AND obs.encounter_id=medication_order_encounter.encounter_id  AND obs.`obs_group_id`=medication_group.obs_id LIMIT 1) AS duration

FROM encounter AS medication_order_encounter, obs AS medication_group
WHERE medication_order_encounter.`visit_id` = :visitId
AND medication_order_encounter.`encounter_id` = medication_group.`encounter_id`

AND medication_order_encounter.voided = 0 
AND medication_order_encounter.encounter_type = 11 
AND medication_group.concept_id = 160741
-- LIMIT 1;