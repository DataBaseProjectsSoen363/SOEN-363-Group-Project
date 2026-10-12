
SELECT 
    (SELECT COUNT(*) FROM patient) AS live_patient_count,
    (SELECT COUNT(*) FROM admission) AS live_admission_count,
    (SELECT COUNT(*) FROM triage_assessment) AS live_triage_count,
    (SELECT COUNT(*) FROM diagnosis) AS live_diagnosis_count,
    (SELECT COUNT(*) FROM icu_stay) AS live_icu_stay_count,
    (SELECT COUNT(*) FROM clinical_note) AS live_notes_count,
    (SELECT COUNT(*) FROM diagnostic_order) AS live_orders_count,
    (SELECT COUNT(*) FROM radiology_examination) AS live_exams_count,
    (SELECT COUNT(*) FROM surgical_procedure) AS live_procedures_count,
    (SELECT COUNT(*) FROM discharge_record) AS live_discharge_count;
