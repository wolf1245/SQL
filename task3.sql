/*
1.Всіх діючих співробітників розбийте на сегменти залежно від віку в момент прийому на роботу:
до 25, 25-44, 45-54, 55 і старше, для кожного сегменту виведіть максимальну зарплату. В результаті
потрібно отримати два поля сегмент, максимальну зарплату в сегменті.
2. Покажіть посаду та зарплату працівника з найвищою зарплатою більше не працюючого в
компанії.
3.Покажіть ТОР-10 діючих співробітників з найбільшою зарплатою
4. Створіть Базу даних. В створену базу додайте дві таблички з будь-якими полями, заповніть
створені таблички будь-якими 3 рядками даних. (Як відповідь на питання запишіть команди якими
ви будете створювати вище зазначене)
5. Покажіть діючих співробітників зарплата яких вища ніж середня зарплата по діючим
співробітникам.
6.Покажіть співробітників, які працюють у відділах де працює більш ніж 20000 співробітників.
7. Покажіть співробітників, які заробляють більше, ніж будь-який інший працівник відділу Finance
8. Покажіть назви відділів, де колись працював хоча б один співробітник з зарплатою більше $150K 
*/
# 1
SELECT
    CASE
        WHEN TIMESTAMPDIFF(year, e.birth_date, e.hire_date) < 25 THEN 'до 25'
        WHEN TIMESTAMPDIFF(year, e.birth_date, e.hire_date) BETWEEN 25 AND 44 THEN '25-44'
        WHEN TIMESTAMPDIFF(year, e.birth_date, e.hire_date) BETWEEN 45 AND 54 THEN '45-54'
        WHEN TIMESTAMPDIFF(year, e.birth_date, e.hire_date) > 55 THEN '55 и выше'
    END AS segment,
    MAX(s.salary) AS max_salary
FROM employees AS e
LEFT JOIN salaries AS s USING(emp_no)
WHERE s.to_date = '9999-01-01'
GROUP BY segment;
# 2
SELECT
e.first_name,
e.last_name,
s.salary,
t.title
FROM employees AS e
LEFT JOIN salaries AS s ON e.emp_no = s.emp_no
LEFT JOIN titles AS t ON s.emp_no = t.emp_no
WHERE t.to_date NOT LIKE '9999-01-01' AND s.to_date NOT LIKE '9999-01-01'
ORDER BY s.salary DESC LIMIT 1;
# 3
SELECT
e.first_name,
e.last_name,
s.salary,
t.title
FROM employees AS e
LEFT JOIN salaries AS s ON e.emp_no = s.emp_no
LEFT JOIN titles AS t ON s.emp_no = t.emp_no
WHERE t.to_date > CURRENT_DATE() AND s.to_date > CURRENT_DATE()
ORDER BY s.salary DESC LIMIT 10;
# 4
CREATE DATABASE IF NOT EXISTS `test`;
CREATE TABLE `users` ( 
`id` int(11) NOT NULL AUTO_INCREMENT, 
`name` varchar(255) NOT NULL, 
`email` varchar(255) NOT NULL, 
`password` varchar(255) NOT NULL, 
`created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (`id`) );
CREATE TABLE IF NOT EXISTS `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_user` int(11) NOT NULL,
  `id_product` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `date` datetime NOT NULL
  );
INSERT INTO users 
SET 
name = 'XXXXX', 
email = 'sfsdds@gfgff',
password = 'dfdfdfdfd'
;
INSERT INTO orders
SET 
id_product = 11, 
quantity = 17;
# 5
SELECT 
emp_no, AVG(salary) AS 'Avg employees',  
(SELECT AVG(salary) FROM salaries) AS 'Avg по компании'
FROM salaries
WHERE salary > (SELECT AVG(salary) FROM salaries WHERE to_date > CURRENT_DATE())
GROUP BY emp_no;
# 6
SELECT
e.first_name,
e.last_name,
t.title,
COUNT(t.emp_no) AS countEmplo
FROM titles AS t
LEFT JOIN employees AS e ON t.emp_no = e.emp_no
GROUP BY t.title HAVING countEmplo > 20000;
# 7
SELECT 
e.first_name,
e.last_name,
s.salary,
ds.dept_name
FROM employees e
LEFT JOIN salaries s USING(emp_no)
LEFT JOIN dept_emp dp USING(emp_no)
LEFT JOIN departments ds USING(dept_no)
WHERE s.salary NOT IN(SELECT salary FROM salaries WHERE emp_no IN(SELECT emp_no 
																FROM dept_emp 
																WHERE dept_no = (SELECT dept_no 
																					FROM departments 
																					WHERE dept_name = 'Finance'))) LIMIT 100;
# 8
SELECT DISTINCT
t.title,
COUNT(t.emp_no) AS countEmplo
FROM salaries AS s
LEFT JOIN titles AS t ON s.emp_no = t.emp_no
WHERE s.salary > 150000
GROUP BY t.title;