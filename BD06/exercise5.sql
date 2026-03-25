USE classicmodels;

DELIMITER $$

CREATE PROCEDURE customer_sales_report(
    IN office_name VARCHAR(50),
    IN year_param INT,
    OUT sales_report TEXT
)
BEGIN
    SET SESSION group_concat_max_len = 1000000;

    SELECT GROUP_CONCAT(
               CONCAT(
                   'Month: ', LPAD(report_data.month_num, 2, '0'),
                   ' | Employee: ', report_data.employee_name,
                   ' | Customer: ', report_data.customer_name,
                   ' | Total Sales: ',
                   ROUND(report_data.total_sales, 2)
               )
               ORDER BY report_data.month_num, report_data.employee_name, report_data.customer_name
               SEPARATOR '\n'
           )
    INTO sales_report
    FROM (
        SELECT
            MONTH(o.orderDate) AS month_num,
            CONCAT(e.firstName, ' ', e.lastName) AS employee_name,
            c.customerName AS customer_name,
            SUM(od.quantityOrdered * od.priceEach) AS total_sales
        FROM offices ofc
        JOIN employees e
            ON e.officeCode = ofc.officeCode
        JOIN customers c
            ON c.salesRepEmployeeNumber = e.employeeNumber
        JOIN orders o
            ON o.customerNumber = c.customerNumber
        JOIN orderdetails od
            ON od.orderNumber = o.orderNumber
        WHERE ofc.city = office_name
          AND YEAR(o.orderDate) = year_param
        GROUP BY
            MONTH(o.orderDate),
            e.employeeNumber,
            e.firstName,
            e.lastName,
            c.customerNumber,
            c.customerName
    ) AS report_data;

    IF sales_report IS NULL THEN
        SET sales_report = 'No data available for the selected office and year';
    END IF;
END$$

DELIMITER ;

-- For example, one office city in the dataset is San Francisco.
CALL customer_sales_report('San Francisco', 2003, @report);
SELECT @report;

-- Test with no data
CALL customer_sales_report('Tokyo', 1990, @report);
SELECT @report;

