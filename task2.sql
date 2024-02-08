USE employees;
SHOW TABLES;
/*
1. Для поточної максимальної річної заробітної плати в компанії ПОКАЗАТИ ПІБ
працівника, департамент, поточну посаду, тривалість перебування на поточній
посаді та загальний стаж роботи в компанії.
2. Для кожного департамента покажіть його назву, ім’я та прізвище поточного
керівника та його поточну зарплату.
3. Покажіть для кожного працівника їхню поточну зарплату та поточну зарплату
поточного керівника
4. Покажіть всіх співробітників, які зараз заробляють більше, ніж їхні керівники
5. Покажіть, скільки співробітників зараз мають кожну посаду. Відсортуйте в порядку
спадання за кількістю співробітників.
6. Покажіть повні імена всіх співробітників, які працювали більш ніж в одному відділі.
7. Покажіть середню та максимальну зарплату в тисячах доларів за кожен рік
8. Покажіть, скільки працівників було найнято у вихідні дні (субота + неділя),
розділивши за статтю
*/
# 1
SELECT
MAX(ss.salary),
es.first_name, 
es.last_name, 
ds.dept_name, 
ts.title,
TIMESTAMPDIFF(YEAR, ts.from_date, CURDATE()) AS year_title,
TIMESTAMPDIFF(YEAR, es.hire_date, CURDATE()) AS year_work_company
FROM employees AS es
LEFT JOIN salaries AS ss USING(emp_no)
LEFT JOIN titles AS ts USING(emp_no)
LEFT JOIN dept_emp AS dp USING(emp_no)
LEFT JOIN departments AS ds USING(dept_no)
WHERE ts.to_date > CURDATE();
# 2
SELECT 
ds.dept_name, 
es.first_name, 
es.last_name, 
ss.salary
FROM departments AS ds
LEFT JOIN dept_manager AS dm USING(dept_no)
LEFT JOIN employees AS es USING(emp_no)
LEFT JOIN salaries AS ss USING(emp_no)
WHERE ss.to_date > CURDATE() AND dm.to_date > CURDATE();
# 3
SELECT 
es.emp_no, 
ss.salary, 
dm.emp_no,
ssm.salary
FROM employees AS es
LEFT JOIN salaries AS ss USING(emp_no)
LEFT JOIN dept_emp AS dp USING(emp_no)
LEFT JOIN dept_manager AS dm USING(dept_no)
LEFT JOIN salaries AS ssm ON dm.emp_no = ssm.emp_no
WHERE ss.to_date > CURDATE() AND dm.to_date > CURDATE() AND ssm.to_date > CURDATE();
# 4
SELECT
DISTINCT es.emp_no,
ss.salary,
dm.emp_no,
ssm.salary
FROM employees AS es
LEFT JOIN salaries AS ss USING(emp_no)
LEFT JOIN dept_emp AS dp USING(emp_no)
LEFT JOIN departments AS ds USING(dept_no)
LEFT JOIN dept_manager AS dm USING(dept_no)
LEFT JOIN salaries AS ssm ON dm.emp_no = ssm.emp_no
WHERE ss.salary > ssm.salary AND (ss.to_date > CURDATE() AND ssm.to_date > CURDATE());
# 5
SELECT
title,
COUNT(DISTINCT emp_no) AS e_count
FROM titles
WHERE to_date > CURDATE()
GROUP BY title
ORDER BY e_count DESC;
# 6
SELECT
es.first_name,
es.last_name,
COUNT(dp.dept_no) AS count_dept
FROM employees AS es
LEFT JOIN dept_emp AS dp USING(emp_no)
GROUP BY es.emp_no
HAVING count_dept >= 2;
# 7
SELECT
es.first_name,
es.last_name,
COUNT(dp.dept_no) AS count_dept
FROM employees AS es
LEFT JOIN dept_emp AS dp USING(emp_no)
GROUP BY es.emp_no
HAVING count_dept >= 2;
# 8
SELECT
DAYNAME(hire_date) AS dayS,
gender,
COUNT(emp_no)
FROM employees
GROUP BY gender, dayS
HAVING dayS = 'Sunday' OR dayS = 'Saturday'
;