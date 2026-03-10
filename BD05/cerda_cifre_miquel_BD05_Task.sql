
/* Autor: Miquel Cerdà Cifre */

use classicmodels;

/* 
Exercise 2
Insert the following payments into the payments table using SQL statements:
Copy the SQL statements you used in your submission. Only include the data shown.
*/

INSERT INTO payments values (124,'H123','2024-02-06',845.00),
							(151,'H124','2024-02-07',70.00),
			                (112,'H125','2024-02-05',1014.00);

/************************************************************************************************************************/
/*
Exercise 4
Cancel the order made on 2003-09-28, using SQL instructions. Change the status to 'Cancelled', 
the shippedDate to the current date, and comments to 'Order cancelled due to delay'. Do this using a single SQL statement.
Copy the statement in your submission.
*/

UPDATE orders
SET status = 'Cancelled',
shippedDate = CURRENT_DATE,
comments = 'Order cancelled due to delay'
WHERE orderDate = '2003-09-28';

/************************************************************************************************************************/
/*
Exercise 5
Update all product names of type Trains to include the product code in parentheses. For example, a product with productCode = S10_1949 and productName = "Vintage Train". will become:
"Vintage Train (code S10_1949)"
Do this with a single SQL statement using the proper MySQL functions.
*/

UPDATE products
SET productName = CONCAT(productName, ' (code ', productCode, ')')
WHERE productLine = 'Trains';



/************************************************************************************************************************/
/*
Exercise 6
Increase buyPrice and MSRP of all products with quantityInStock > 500 by 0.02%.
Do this with one SQL statement.
*/

UPDATE products
SET buyPrice = buyPrice * 1.0002,  
       MSRP = MSRP * 1.0002
WHERE quantityInStock > 500;

/*
But this give me a warning of data truncate in the column buyPrice and MSRP. 
This is because both columns are declare as decimal(10,2), when we multiply by 1.0002 generate more than 2 decimals. 
To avoid this warning I just round by 2 decimals as following:
*/

UPDATE products
SET buyPrice = ROUND(buyPrice * 1.0002, 2),
       MSRP = ROUND(MSRP * 1.0002, 2)
WHERE quantityInStock > 500;


/************************************************************************************************************************/

/*
Exercise 7
Remove all payments made by customers who are represented by employees with the last name 'Patterson'.
Use a single SQL statement and copy it for the task delivery.
*/

DELETE p FROM payments p
JOIN customers c ON p.customerNumber = c.customerNumber
JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
WHERE e.lastName = 'Patterson';


/************************************************************************************************************************/
/*
Exercise 8	
Delete all customers from Lisbon who have not made any payment.
Use one SQL statement only.
*/

DELETE FROM customers c WHERE c.city = 'Lisboa'
AND NOT EXISTS (SELECT 1 FROM payments p WHERE p.customerNumber = c.customerNumber);


/************************************************************************************************************************/
/*
Exercise 9
Add all customers as new employees, using their contact names as first and last name.
Use customerNumber + 2000 as the new employeeNumber, leave all other fields as 'x0000' extension, 'new@company.com' email,'1' officeCode, 'Sales Rep' jobTitle
Use contactFirstName as firstName, contactLastName as lastName.
Do this with a single SQL statement.
*/

INSERT INTO employees 
(employeeNumber, lastName, firstName, extension, email, officeCode, reportsTo, jobTitle)
SELECT 
    customerNumber + 2000,
    contactLastName,
    contactFirstName,
    'x0000',
    'new@company.com',
    '1',
    NULL, 'Sales Rep' FROM customers;


/************************************************************************************************************************/
/*
Exercise 10
Cancel all orders made by customers handled by the customer Elizabeth Lincoln.
Change the status to 'Cancelled', shippedDate to the current date, and comments to Order cancelled by management'.
Use a single SQL statement.
*/

UPDATE orders
SET status = 'Cancelled',
    shippedDate = CURRENT_DATE,
    comments = 'Order cancelled by management'
WHERE customerNumber IN (
    SELECT customerNumber
    FROM customers
    WHERE TRIM(contactFirstName) = 'Elizabeth'
      AND TRIM(contactLastName) = 'Lincoln'
);
