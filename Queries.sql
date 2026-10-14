-- =====================================================================
-- Task 3: Writing the Queries
-- File: FirstPart.sql
-- =====================================================================
-- ---------------------------------------------------------------------
-- Instructions:
-- 1. Find the block assigned to your handle below.
-- 2. Run each query in pgAdmin to confirm it executes.
-- 3. Screenshot of the Data Output grid captured
-- 4. Screenshot pasted into the shared Word document
-- 5. Comment under the screenshot explaining what the query does
--    and what the result shows (2-4 sentences)
-- 6. Commit this file when done.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1 - 4   |   @Zitkq
-- ---------------------------------------------------------------------

-- Q1


-- Q2


-- Q3


-- Q4


-- ---------------------------------------------------------------------
-- 5 - 8   |   @JuanMa_487
-- ---------------------------------------------------------------------

-- Q5


-- Q6


-- Q7


-- Q8


-- ---------------------------------------------------------------------
-- 9 - 12   |   @Mohammad
-- ---------------------------------------------------------------------

-- Q9: Calculate the average length of stay for each critical care unit type.
SELECT
    unit_type,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (exit_date_time - entry_date_time)) / 86400.0),
        2
    ) AS average_length_of_stay_days
FROM icu_stay
WHERE exit_date_time IS NOT NULL
GROUP BY unit_type
ORDER BY unit_type;


-- Q10: List patients who had a surgical procedure before entering
-- an ICU or CCU during the same admission.
SELECT
    p.name,
    sp.procedure_date_time,
    i.unit_type,
    i.entry_date_time
FROM patient p
JOIN admission a
    ON p.patient_id = a.patient_id
JOIN surgical_procedure sp
    ON a.admission_id = sp.admission_id
JOIN icu_stay i
    ON a.admission_id = i.admission_id
WHERE i.unit_type IN ('ICU', 'CCU')
  AND sp.procedure_date_time < i.entry_date_time
ORDER BY p.name;


-- Q11: Count the total number of radiology examinations for each patient,
-- including patients who have not received any examinations.
SELECT
    p.name,
    COUNT(re.examination_id) AS total_radiology_examinations
FROM patient p
LEFT JOIN diagnostic_order d
    ON p.patient_id = d.patient_id
LEFT JOIN radiology_examination re
    ON d.order_id = re.order_id
GROUP BY p.patient_id, p.name
ORDER BY p.name;

-- side by side (AI generated this code )
WITH patient_counts AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY p.name) AS rn,
        p.name,
        COUNT(re.examination_id) AS total_radiology_examinations
    FROM patient p
    LEFT JOIN diagnostic_order d
        ON p.patient_id = d.patient_id
    LEFT JOIN radiology_examination re
        ON d.order_id = re.order_id
    GROUP BY p.patient_id, p.name
)
SELECT
    a.name AS col_1,
    a.total_radiology_examinations ,
    b.name AS col_2,
    b.total_radiology_examinations 
FROM patient_counts a
LEFT JOIN patient_counts b
    ON b.rn = a.rn + CEIL((SELECT COUNT(*) FROM patient_counts) / 2.0)
WHERE a.rn <= CEIL((SELECT COUNT(*) FROM patient_counts) / 2.0)
ORDER BY a.rn;


-- Q12: Find patients whose discharge-summary clinical note
-- contains the keyword "recovery", case-insensitively.
SELECT DISTINCT
    p.name
FROM patient p
JOIN admission a
    ON p.patient_id = a.patient_id
JOIN clinical_note cn
    ON a.admission_id = cn.admission_id
WHERE cn.type = 'Discharge Summary'
  AND cn.contents ILIKE '%recovery%'
ORDER BY p.name;

-- ---------------------------------------------------------------------
-- 13 - 16   |   @Laurent
-- ---------------------------------------------------------------------

-- Q13 List all admissions in which the patient had at least one radiology examination but
-- had no recorded ICU or CCU stay.
SELECT DISTINCT
  patient.name,
  admission.patient_id,
  admission.admission_id,
  radiology_examination.examination_id,
  icu_stay.unit_stay_id
FROM admission
-- LEFT JOINs to produce a table with all icu_stays + radiology_examinations according to admission
-- (Just JOIN would reject null columns but we want to keep to filter out later)
LEFT JOIN icu_stay ON admission.admission_id = icu_stay.admission_id
LEFT JOIN diagnostic_order ON admission.admission_id = diagnostic_order.admission_id
LEFT JOIN radiology_examination ON diagnostic_order.order_id = radiology_examination.order_id
LEFT JOIN patient ON admission.patient_id = patient.patient_id
-- Filter out admissions without radiology examinations and that has some icu_stay
WHERE icu_stay.admission_id IS NULL
  AND radiology_examination.examination_id IS NOT NULL
ORDER BY admission.patient_id;

-- Q14 Retrieve the patient or patients with the longest completed hospital stay, cal-
-- culated from admission time to discharge time. If multiple patients have the same
-- maximum length of stay, display all of them.
SELECT 
  patient.patient_id,
  patient.name,
  admission.admission_id,
  admission.admission_date_time,
  admission.discharge_date_time,
  (admission.discharge_date_time - admission.admission_date_time) AS length_of_stay
FROM admission
-- JOIN for admission + patient table
JOIN patient ON admission.patient_id = patient.patient_id
WHERE (admission.discharge_date_time - admission.admission_date_time) = (
    SELECT MAX(discharge_date_time - admission_date_time)
    FROM admission);

-- Q15 Count the total number of transfers between hospital units for each patient. The
-- patient’s first unit placement is not considered a transfer; each subsequent unit stay
-- within the same admission represents one transfer.
SELECT
  patient.name,
  admission.patient_id,
  icu_stay.admission_id,
  COUNT(*) - 1 AS total_transfers -- First transfer doesn't count
FROM icu_stay
-- JOIN for icu_stay + admission + patient table
JOIN admission ON icu_stay.admission_id = admission.admission_id
JOIN patient ON admission.patient_id = patient.patient_id
GROUP BY patient.name, admission.patient_id, icu_stay.admission_id;

-- Q16 List all patients who stayed in more than one type of critical care unit during
-- the same admission. For example, a patient may have been transferred from an ICU
-- to a CCU.

SELECT
  patient.patient_id,
  patient.name,
  admission.admission_id,
  COUNT (DISTINCT icu_stay.unit_type) AS distinct_unit_types
FROM admission
-- JOIN of patient + admission + icu_stay to get a table
JOIN patient ON admission.patient_id = patient.patient_id
JOIN icu_stay ON admission.admission_id = icu_stay.admission_id
GROUP BY patient.patient_id, patient.name, admission.admission_id
-- Filter out with distinct unit types greater than 1
HAVING COUNT (DISTINCT icu_stay.unit_type) > 1;



-- ---------------------------------------------------------------------
-- 17 - 20   |   @fmvemba
-- ---------------------------------------------------------------------

-- Q17: Find all admissions during which the patient received more than one distinct ICD-
--      9 diagnosis. Display the patient name, admission identifier, and number of distinct
--      ICD-9 codes.
    SELECT patient.name,
		   admission.admission_id,
		   COUNT(DISTINCT diagnosis.icd9_code) AS num_distinct_diagnoses
    FROM patient
	JOIN admission USING(patient_id)
	JOIN diagnosis USING(admission_id)
	GROUP BY patient.name, admission.admission_id
	HAVING COUNT(DISTINCT diagnosis.icd9_code) > 1;

	

-- Q18: Retrieve the latest clinical note for each patient. Display the patient name, note
-- type, note creation date and time, and note contents
	SELECT patient.name,clinical_note.type,clinical_note.creation_date,clinical_note.patient_symptoms
	FROM patient
	JOIN admission on admission.patient_id = patient.patient_id
	JOIN clinical_note ON admission.admission_id = clinical_note.admission_id
	
-- Q19: List all admissions where the patient’s discharge status or discharge condition indicates
-- that the patient died during the hospital stay. Display the patient name, admission
-- date, recorded date of death, and associated primary ICD-9 diagnosis.
SELECT
    p.name ,                                 
    a.admission_id,
    d.discharge_date_time,              
    dg.icd9_code                    
FROM admission a
JOIN patient           p  ON p.patient_id       = a.patient_id
JOIN discharge_record  d  ON d.admission_id     = a.admission_id
LEFT JOIN diagnosis    dg ON dg.admission_id    = a.admission_id
                          AND dg.primary_diagnosis = TRUE
WHERE d.condition_at_discharge = 'Deceased'
ORDER BY d.discharge_date_time;

-- Q20: Find all patients who underwent a surgical procedure and a radiology examination
-- on the same calendar day during the same admission. Display the patient
-- name, admission identifier, procedure type, radiology examination type, and the common
-- date.
SELECT
	patient.name,
	admission.admission_id,
	surgical_procedure.procedure_name,
	radiology_examination.examination_type,
	DATE(surgical_procedure.procedure_date_time) AS common_date
FROM patient
JOIN admission 			   ON admission.patient_id = patient.patient_id
JOIN surgical_procedure    ON admission.admission_id = surgical_procedure.admission_id
JOIN diagnostic_order      ON diagnostic_order.admission_id = admission.admission_id
JOIN radiology_examination ON radiology_examination.order_id = diagnostic_order.order_id
WHERE DATE(surgical_procedure.procedure_date_time) = DATE(radiology_examination.examination_date_time)
ORDER BY common_date,patient.name;

-- Show all surgery dates and exam dates per admission, side by side
SELECT
    a.admission_id,
    DATE(sp.procedure_date_time)      AS surgery_date,
    DATE(re.examination_date_time)    AS exam_date,
    (DATE(sp.procedure_date_time) = DATE(re.examination_date_time)) AS same_day
FROM admission a
JOIN surgical_procedure  sp ON sp.admission_id = a.admission_id
JOIN diagnostic_order    o  ON o.admission_id  = a.admission_id
JOIN radiology_examination re ON re.order_id   = o.order_id
ORDER BY a.admission_id;
	



