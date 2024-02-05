/*
1. Виведіть список усіх співробітниць, які приєдналися 01.01.1990 або після 01.01.2000
2. Покажіть імена всіх співробітників, які мають однакові ім’я та прізвище
3. Покажіть номери співробітників 10001, 10002, 10003 і 10004. Виберіть стовпці: first_name,
last_name, gender, hire_date.
4. Виберіть назви всіх департаментів, назви яких мають букву «а» на будь-якій позиції або «е»
на другому місці.
5. Покажіть співробітників, які відповідають наступному опису: Йому було 45 років, коли його
прийняли на роботу, він народився в жовтні і був прийнятий на роботу в неділю
6. Покажіть максимальну річну зарплату в компанії після 01.06.1995.
7. У таблиці dept_emp покажіть кількість співробітників за департаментами (dept_no). To_date
має бути більшим за current_date. Покажіть департаменти з понад 13 000 співробітників.
Відсотртуйте за кількістю працівників.
8. Показати мінімальну та максимальну зарплати по працівникам
*/
USE employees;
# SHOW TABLE STATUS;
# 1
# SHOW COLUMNS FROM employees;
SELECT *
FROM (SELECT * FROM employees WHERE gender = "F") AS f
WHERE hire_date = "1990-01-01" OR hire_date > "2000-01-01";
# 2
SELECT * 
FROM employees
WHERE first_name = last_name;
# 3
SELECT first_name,
last_name, gender, hire_date
FROM employees
WHERE emp_no IN(10001, 10002, 10003, 10004);
# 4
# SHOW COLUMNS FROM departments;
SELECT *
FROM departments
WHERE dept_name LIKE '%a%' OR dept_name LIKE '_a%';
# 5
SELECT first_name, last_name, birth_date, hire_date,
TIMESTAMPDIFF(year, birth_date, hire_date) AS '45 y.o.',
MONTHNAME(birth_date) AS 'Month',
DAYNAME(hire_date) AS 'Day'
FROM employees
WHERE 
TIMESTAMPDIFF(year, birth_date,hire_date) = 45 AND 
MONTHNAME(birth_date) = 'October' AND 
DAYNAME(hire_date) = 'Sunday';
# 6
# SHOW COLUMNS FROM salaries;
SELECT MAX(salary)
FROM salaries
WHERE from_date > "1995-06-01";
# 7
SELECT DISTINCT emp_no, MAX(salary), MIN(salary)
FROM salaries
GROUP BY emp_no;
# 8
SELECT dept_no, COUNT(DISTINCT emp_no) AS counts_emp 
FROM dept_emp 
WHERE to_date > curdate() 
GROUP BY dept_no 
HAVING COUNT(emp_no) > '13000' 
ORDER BY COUNT(emp_no) ASC;