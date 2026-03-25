USE classicmodels;

DELIMITER $$

CREATE FUNCTION customer_summary(p_customerNumber INT)
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE v_orders INT DEFAULT 0;
    DECLARE v_products INT DEFAULT 0;

    -- Count number of orders
    SELECT COUNT(*)
    INTO v_orders
    FROM orders
    WHERE customerNumber = p_customerNumber;

    -- Count number of products purchased
    SELECT COALESCE(SUM(od.quantityOrdered), 0)
    INTO v_products
    FROM orders o
    JOIN orderdetails od
        ON o.orderNumber = od.orderNumber
    WHERE o.customerNumber = p_customerNumber;

    -- Return formatted summary
    RETURN CONCAT(
        'Customer ', p_customerNumber,
        ' has ', v_orders, ' orders and ',
        v_products, ' products purchased'
    );
END$$

DELIMITER ;

-- Case with orders
SELECT customer_summary(103);

-- Case without orders
SELECT customer_summary(999);

