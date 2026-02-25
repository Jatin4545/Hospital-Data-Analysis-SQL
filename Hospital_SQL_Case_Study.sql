/* ===============================================================
   PROJECT TITLE  : Hospital Management Data Analysis using SQL
   DOMAIN         : Healthcare Analytics
   TOOL USED      : Microsoft SQL Server (SSMS)
   AUTHOR         : Jatin
==================================================================

📌 PROJECT DESCRIPTION
------------------------------------------------------------------
This project focuses on analyzing Hospital Management Dataset 
using SQL Server to extract meaningful business insights related to:

• Patient demographics
• Doctor specialization demand
• Appointment workload analysis
• Treatment cost distribution
• Billing revenue contribution
• Patient registration trends
• High cost treatments
• Doctor experience segmentation
• Patient spending behaviour

This project demonstrates strong hands-on knowledge of:
- SQL Joins
- Aggregation Functions
- CTEs
- Window Functions
- Subqueries
- Ranking Functions
- CASE Statements
- Business Insight Generation

==================================================================
                        BUSINESS ANALYSIS
================================================================== */

---------------------------------------------------------------
-- 1. Total Number of Doctors Available in Hospital
---------------------------------------------------------------
SELECT COUNT(*) AS total_doctors
FROM doctors;



---------------------------------------------------------------
-- 2. Find Distinct Specializations Available
---------------------------------------------------------------
SELECT DISTINCT specialization
FROM doctors;



---------------------------------------------------------------
-- 3. Doctors Sorted by Experience (High to Low)
---------------------------------------------------------------
SELECT 
(first_name + ' ' + last_name) AS doctor_name,
years_experience
FROM doctors
ORDER BY years_experience DESC;



---------------------------------------------------------------
-- 4. Find Doctors Whose Name Ends With 'is'
---------------------------------------------------------------
SELECT *
FROM doctors
WHERE first_name LIKE '%is';



---------------------------------------------------------------
-- 5. Appointment Status Distribution
---------------------------------------------------------------
SELECT status,
COUNT(*) AS total_appointments
FROM appointments
GROUP BY status;



---------------------------------------------------------------
-- 6. Appointment Status Having Volume > 50
---------------------------------------------------------------
SELECT status,
COUNT(*) AS total_appointments
FROM appointments
GROUP BY status
HAVING COUNT(*) > 50;



---------------------------------------------------------------
-- 7. Appointments in Last 14 Days
---------------------------------------------------------------
SELECT *
FROM appointments
WHERE appointment_date >=
(
SELECT DATEADD(DAY,-14,MAX(appointment_date))
FROM appointments
)
ORDER BY appointment_date DESC;



---------------------------------------------------------------
-- 8. Date-wise Appointment Volume
---------------------------------------------------------------
SELECT appointment_date,
COUNT(status) AS total_appointments
FROM appointments
GROUP BY appointment_date;



---------------------------------------------------------------
-- 9. Most Common Treatment Type
---------------------------------------------------------------
SELECT treatment_type,
COUNT(*) AS performed_treatment
FROM treatments
GROUP BY treatment_type
ORDER BY COUNT(*) DESC;



---------------------------------------------------------------
-- 10. Treatment Cost Statistics
---------------------------------------------------------------
SELECT treatment_type,
ROUND(MAX(cost),1) AS max_cost,
ROUND(AVG(cost),1) AS avg_cost,
ROUND(MIN(cost),1) AS min_cost
FROM treatments
GROUP BY treatment_type;



---------------------------------------------------------------
-- 11. Patient Distribution by Address
---------------------------------------------------------------
SELECT address,
COUNT(patient_id) AS total_patients
FROM patients
GROUP BY address
ORDER BY total_patients DESC;



---------------------------------------------------------------
-- 12. Patient Age Segmentation
---------------------------------------------------------------
WITH age_calc AS
(
SELECT DATEDIFF(YEAR,date_of_birth,GETDATE()) AS age
FROM patients
),
segment AS
(
SELECT *,
CASE
WHEN age < 18 THEN 'Under Age'
WHEN age BETWEEN 18 AND 35 THEN 'Young'
WHEN age BETWEEN 36 AND 55 THEN 'Adult'
ELSE 'Old'
END AS age_group
FROM age_calc
)
SELECT age_group,
COUNT(*) AS total_patients
FROM segment
GROUP BY age_group;



---------------------------------------------------------------
-- 13. Most Common Email Domain Used by Patients
---------------------------------------------------------------
SELECT 
SUBSTRING(email,
CHARINDEX('@',email)+1,
LEN(email)) AS domain,
COUNT(*) AS patient_count
FROM patients
GROUP BY 
SUBSTRING(email,
CHARINDEX('@',email)+1,
LEN(email));



---------------------------------------------------------------
-- 14. Monthly Patient Registration Trend
---------------------------------------------------------------
SELECT 
YEAR(registration_date) AS year,
MONTH(registration_date) AS month,
COUNT(*) AS registrations
FROM patients
GROUP BY 
YEAR(registration_date),
MONTH(registration_date)
ORDER BY year;



---------------------------------------------------------------
-- 15. Specialization Demand Based on Appointment Volume
---------------------------------------------------------------
SELECT d.specialization,
COUNT(a.appointment_id) AS appointment_volume
FROM doctors d
JOIN appointments a
ON a.doctor_id = d.doctor_id
GROUP BY d.specialization;



---------------------------------------------------------------
-- 16. Junior vs Senior Doctor Segmentation
---------------------------------------------------------------
SELECT specialization,
COUNT(*) AS total_doctors,
SUM(CASE WHEN years_experience <=15
THEN 1 ELSE 0 END) AS junior_doctors,
SUM(CASE WHEN years_experience >15
THEN 1 ELSE 0 END) AS senior_doctors
FROM doctors
GROUP BY specialization;



---------------------------------------------------------------
-- 17. Doctor Workload Ranking
---------------------------------------------------------------
SELECT d.doctor_id,
d.first_name,
COUNT(a.appointment_id) AS appointments,
RANK() OVER 
(ORDER BY COUNT(a.appointment_id) DESC) 
AS doctor_rank
FROM doctors d
LEFT JOIN appointments a
ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_id, d.first_name;



---------------------------------------------------------------
-- 18. Total Revenue Generated by Hospital
---------------------------------------------------------------
SELECT ROUND(SUM(amount),2) AS total_revenue
FROM billing
WHERE payment_status='paid';



---------------------------------------------------------------
-- 19. Top Revenue Contributing Patients
---------------------------------------------------------------
SELECT p.patient_id,
CONCAT(p.first_name,' ',p.last_name) 
AS patient_name,
SUM(b.amount) AS total_spending,
DENSE_RANK() OVER
(ORDER BY SUM(b.amount) DESC)
AS patient_rank
FROM patients p
LEFT JOIN billing b
ON b.patient_id = p.patient_id
WHERE b.payment_status='paid'
GROUP BY p.patient_id,
CONCAT(p.first_name,' ',p.last_name);



---------------------------------------------------------------
-- 20. High Cost Treatments for Review
---------------------------------------------------------------
SELECT treatment_type,
cost
FROM treatments
WHERE cost >
(
SELECT AVG(cost) +
0.5*STDEV(cost)
FROM treatments
);



---------------------------------------------------------------
-- 21. Treatment Frequency Ranking
---------------------------------------------------------------
SELECT treatment_type,
COUNT(*) AS treatment_frequency,
RANK() OVER
(ORDER BY COUNT(*) DESC)
AS treatment_rank
FROM treatments
GROUP BY treatment_type;


/* ===============================================================
                      END OF CASE STUDY
================================================================== */
