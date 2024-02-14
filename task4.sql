/*
1. Необхідно створити процедуру додавання нового співробітника, з потрібним
переліком вхідних параметрів. Після успішної роботи Дані процедури повинні потрапити
в таблиці employees, dept_emp, salaries и titles;
Обчислення emp_no, обчислюємо по формулою max(emp_no) +1.
Якщо передана не існуюча посада, тоді показати помилку з необхідним текстом. Якщо
передано зарплату менше 30000, тоді показати помилку з необхідним текстом
2. Створити процедуру оновлення зарплати по співробітнику. При оновленні зарплати
потрібно закрити останню активну зарплату поточною датою, і створити новий
історичний запис поточною датою. Якщо переданий не існуючий співробітник, тоді
показати помилку із потрібним текстом.
3. Створити процедуру для звільнення працівника, закриття історичних записів у таблицях
dept_emp, salaries та titles. Якщо передано неіснуючий номер співробітника, тоді показати
помилку з потрібним текстом
4. Створити функцію, яка виводила б поточну зарплату по співробітнику.
*/
# 1
CREATE OR REPLACE PROCEDURE add_employee(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_birth_date DATE,
    p_gender CHAR,
    p_hire_date DATE,
    p_department_id INT,
    p_title VARCHAR,
    p_salary DECIMAL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_emp_no INT;
BEGIN
    -- Проверяем переданную должность
    IF NOT EXISTS (SELECT 1 FROM titles WHERE title = p_title) THEN
        RAISE EXCEPTION 'Посада % не существует.', p_title;
    END IF;

    -- Проверяем переданную зарплату
    IF p_salary < 30000 THEN
        RAISE EXCEPTION 'Зарплата не может быть меньше 30000.';
    END IF;

    -- Генерируем новый номер сотрудника
    SELECT COALESCE(MAX(emp_no), 0) + 1 INTO v_emp_no FROM employees;

    -- Добавляем данные о сотруднике в таблицу employees
    INSERT INTO employees (emp_no, first_name, last_name, birth_date, gender, hire_date)
    VALUES (v_emp_no, p_first_name, p_last_name, p_birth_date, p_gender, p_hire_date);

    -- Добавляем данные о сотруднике в таблицу dept_emp
    INSERT INTO dept_emp (emp_id, dept_id, from_date, to_date)
    VALUES (v_emp_no, p_department_id, p_hire_date, '9999-01-01');

    -- Добавляем данные о зарплате сотрудника в таблицу salaries
    INSERT INTO salaries (emp_id, salary, from_date, to_date)
    VALUES (v_emp_no, p_salary, p_hire_date, '9999-01-01');

    -- Добавляем данные о должности сотрудника в таблицу titles
    INSERT INTO titles (emp_id, title, from_date, to_date)
    VALUES (v_emp_no, p_title, p_hire_date, '9999-01-01');

    -- Выводим сообщение об успешном добавлении сотрудника
    RAISE NOTICE 'Сотрудник с идентификатором % успешно добавлен.', v_emp_no;
END;
# 2
CREATE OR REPLACE PROCEDURE update_salary(employee_id INT, new_salary DECIMAL)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Проверяем существование сотрудника
    IF NOT EXISTS (SELECT 1 FROM employees WHERE emp_id = employee_id) THEN
        RAISE EXCEPTION 'Сотрудник с идентификатором % не существует.', employee_id;
    END IF;

    -- Закрываем последнюю активную зарплату сотрудника текущей датой
    UPDATE salaries 
    SET to_date = CURRENT_DATE 
    WHERE emp_id = employee_id AND to_date = '9999-01-01';

    -- Вставляем новую запись о зарплате сотрудника с текущей датой
    INSERT INTO salaries (emp_id, salary, from_date, to_date)
    VALUES (employee_id, new_salary, CURRENT_DATE, '9999-01-01');

    -- Выводим сообщение об успешном обновлении зарплаты
    RAISE NOTICE 'Зарплата сотрудника с идентификатором % успешно обновлена на %.', employee_id, new_salary;
END;
# 3
CREATE OR REPLACE PROCEDURE fire_employee(employee_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Проверяем существование сотрудника
    IF NOT EXISTS (SELECT 1 FROM employees WHERE emp_id = employee_id) THEN
        RAISE EXCEPTION 'Сотрудник с идентификатором % не существует.', employee_id;
    END IF;

    -- Удаляем записи о сотруднике из таблицы dept_emp
    DELETE FROM dept_emp WHERE emp_id = employee_id;

    -- Закрываем записи о зарплате в таблице salaries
    UPDATE salaries SET to_date = CURRENT_DATE WHERE emp_id = employee_id AND to_date = '9999-01-01';

    -- Закрываем записи о должности в таблице titles
    UPDATE titles SET to_date = CURRENT_DATE WHERE emp_id = employee_id AND to_date = '9999-01-01';

    -- Выводим сообщение об успешном увольнении
    RAISE NOTICE 'Сотрудник с идентификатором % был успешно уволен.', employee_id;
END;
# 4
CREATE FUNCTION get_current_salary(employee_id INT)
RETURNS DECIMAL AS $$
DECLARE
    current_salary DECIMAL;
BEGIN
    SELECT salary INTO current_salary
    FROM salary_history
    WHERE employee_id = get_current_salary.employee_id
    ORDER BY payment_date DESC
    LIMIT 1;

    RETURN current_salary;
END;