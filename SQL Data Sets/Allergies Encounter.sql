SELECT allergy.allergen_type,
(SELECT allergy_name.name FROM concept, concept_name AS allergy_name WHERE allergy_name.concept_name_type = 'FULLY_SPECIFIED' AND concept.retired=0 AND concept.concept_id=allergy_name.concept_id AND allergy_name.voided= 0 AND allergy_name.locale='en'  AND allergy_name.concept_id=allergy.coded_allergen LIMIT 1) AS coded_allergen,
(SELECT GROUP_CONCAT(allergy_reaction_name.name SEPARATOR ',') FROM allergy_reaction, concept_name AS allergy_reaction_name WHERE allergy_reaction_name.concept_name_type = 'FULLY_SPECIFIED' AND allergy_reaction_name.voided= 0 AND allergy_reaction_name.concept_id=allergy_reaction.reaction_concept_id AND allergy_reaction_name.locale='en' AND allergy_reaction.allergy_id=allergy.allergy_id) AS allergy_reaction

FROM allergy
WHERE allergy.patient_id = :person
-- LIMIT 1;