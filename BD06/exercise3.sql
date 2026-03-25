USE classicmodels;

DELIMITER $$

CREATE TRIGGER before_insert_orderdetails_check_stock
BEFORE INSERT ON orderdetails
FOR EACH ROW
BEGIN
    DECLARE v_stock INT DEFAULT NULL;

    SELECT quantityInStock
    INTO v_stock
    FROM products
    WHERE productCode = NEW.productCode;

    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The product does not exist';
    END IF;

    IF v_stock = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This product is out of stock';
    END IF;

    IF NEW.quantityOrdered > v_stock THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Requested quantity exceeds available stock';
    END IF;
END$$

DELIMITER ;

SELECT productCode, productName, quantityInStock
FROM products
ORDER BY quantityInStock ASC, productCode;

-- Since S24_2000 has stock 15, requesting 10 units should succeed
INSERT INTO orderdetails (
    orderNumber,
    productCode,
    quantityOrdered,
    priceEach,
    orderLineNumber
) VALUES (
    10100,
    'S24_2000',
    10,
    76.17,
    99
);

-- The same product has stock 15, so requesting 20 units should fail

INSERT INTO orderdetails (
    orderNumber,
    productCode,
    quantityOrdered,
    priceEach,
    orderLineNumber
) VALUES (
    10101,
    'S24_2000',
    20,
    76.17,
    1
);

/* To test the out-of-stock case, since no product has stock = 0,
   we temporarily set one product's stock to 0 */

UPDATE products
SET quantityInStock = 0
WHERE productCode = 'S24_2000';

-- Now the product is out of stock, so any request should fail

INSERT INTO orderdetails (
    orderNumber,
    productCode,
    quantityOrdered,
    priceEach,
    orderLineNumber
) VALUES (
    10102,
    'S24_2000',
    1,
    76.17,
    1
);
