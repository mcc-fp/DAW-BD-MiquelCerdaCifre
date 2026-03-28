use classicmodels

DELIMITER $$

CREATE TRIGGER before_insert_sales_manager
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    -- Using LIKE because in the dataset jobTitle values are:
	-- 'Sales Manager (NA)', 'Sales Manager (EMEA)', etc.
	-- There is no exact 'Sales Manager' value, then the trigger will never been activate it

    IF NEW.jobTitle LIKE 'Sales Manager%' THEN
        
        -- Check if a Sales Manager already exists in the same office
        IF EXISTS (
            SELECT 1
            FROM employees
            WHERE officeCode = NEW.officeCode
            AND jobTitle LIKE 'Sales Manager%'
        ) THEN
        
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A Sales Manager already exists in this office';
            
        END IF;
        
    END IF;
END$$

DELIMITER ;

-- Insert that should FAIL (duplicate Sales Manager in same office)
INSERT INTO employees (
    employeeNumber,
    lastName,
    firstName,
    extension,
    email,
    officeCode,
    reportsTo,
    jobTitle
) VALUES (
    9999,
    'Test',
    'Manager',
    'x9999',
    'test@gmail.com',
    '1',
    NULL,
    'Sales Manager'
);

-- Insert that should SUCCEED (no Sales Manager in that office)
INSERT INTO employees (
    employeeNumber,
    lastName,
    firstName,
    extension,
    email,
    officeCode,
    reportsTo,
    jobTitle
) VALUES (
    9998,
    'New',
    'Manager',
    'x9998',
    'newtest@gmail.com',
    '2',
    NULL,
    'Sales Manager'
);
