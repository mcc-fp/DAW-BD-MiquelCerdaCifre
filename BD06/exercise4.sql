USE classicmodels;

DELIMITER $$

CREATE PROCEDURE delete_employee(IN p_employeeNumber INT)
BEGIN
    DECLARE v_supervisor INT DEFAULT NULL;
    DECLARE v_exists INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_exists
    FROM employees
    WHERE employeeNumber = p_employeeNumber;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The employeeNumber does not exist';
    END IF;

    SELECT reportsTo
    INTO v_supervisor
    FROM employees
    WHERE employeeNumber = p_employeeNumber;

    IF v_supervisor IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The president cannot be deleted because they have no supervisor';
    END IF;

    UPDATE customers
    SET salesRepEmployeeNumber = v_supervisor
    WHERE salesRepEmployeeNumber = p_employeeNumber;

    UPDATE employees
    SET reportsTo = v_supervisor
    WHERE reportsTo = p_employeeNumber;

    DELETE FROM employees
    WHERE employeeNumber = p_employeeNumber;
END$$

DELIMITER ;

-- Valid case
CALL delete_employee(1165);

-- Invalid case: president cannot be deleted
CALL delete_employee(1002);

-- Invalid case: employee does not exist
CALL delete_employee(999999);