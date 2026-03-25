USE classicmodels;

DELIMITER $$

CREATE TRIGGER before_insert_active_orders
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE active_orders_count INT;

    IF NEW.status IN ('In Process', 'On Hold', 'Shipped') THEN
        SELECT COUNT(*)
        INTO active_orders_count
        FROM orders
        WHERE customerNumber = NEW.customerNumber
          AND status IN ('In Process', 'On Hold', 'Shipped');

        IF active_orders_count >= 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This customer already has 3 active orders and cannot create a fourth one';
        END IF;
    END IF;
END$$

DELIMITER ;

-- To be able to view the total active orders by customer to be able to try the trigger
SELECT customerNumber, COUNT(*) AS active_orders
FROM orders
WHERE status IN ('In Process', 'On Hold', 'Shipped')
GROUP BY customerNumber
ORDER BY active_orders DESC, customerNumber;


-- Insert which will give us an error because customerNumber 103 has already 3 orders active
INSERT INTO orders (
    orderNumber,
    orderDate,
    requiredDate,
    shippedDate,
    status,
    comments,
    customerNumber
) VALUES (
    99910,
    CURDATE(),
    DATE_ADD(CURDATE(), INTERVAL 7 DAY),
    NULL,
    'In Process',
    'Trigger test - should fail',
    103
);

-- Insert which will work because customerNumber 171 only has already 2 orders active
INSERT INTO orders (
    orderNumber,
    orderDate,
    requiredDate,
    shippedDate,
    status,
    comments,
    customerNumber
) VALUES (
    99911,
    CURDATE(),
    DATE_ADD(CURDATE(), INTERVAL 7 DAY),
    NULL,
    'In Process',
    'Trigger test - should work',
    171
);

