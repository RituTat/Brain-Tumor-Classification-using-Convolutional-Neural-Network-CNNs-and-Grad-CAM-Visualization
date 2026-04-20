CREATE DATABASE IF NOT EXISTS project;
USE project;

-------------------------
-- 1. Make sure tables exist
-------------------------

-- Create base table if it does not exist (no reload here)
CREATE TABLE IF NOT EXISTS cus_purchase (
    transactionid     INT PRIMARY KEY,
    customerid        INT,
    customername      VARCHAR(100),
    productid         INT,
    productname       VARCHAR(100),
    productcategory   VARCHAR(100),
    purchasequantity  INT,
    purchaseprice     FLOAT,
    purchasedate      DATE,
    country           VARCHAR(100)
);

-- Dimension tables (will not overwrite existing ones)
CREATE TABLE IF NOT EXISTS customers (
    customerPK   INT AUTO_INCREMENT PRIMARY KEY,
    customerid   INT,
    customername VARCHAR(100),
    country      VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS products (
    productPK       INT AUTO_INCREMENT PRIMARY KEY,
    productid       INT,
    productname     VARCHAR(100),
    productcategory VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS purchases (
    purchasespk      INT AUTO_INCREMENT PRIMARY KEY,
    transactionid    INT,
    customerPK       INT,
    productPK        INT,
    customerid       INT,
    productid        INT,
    purchasequantity INT,
    purchaseprice    FLOAT,
    purchasedate     DATE,
    FOREIGN KEY (customerPK) REFERENCES customers(customerPK),
    FOREIGN KEY (productPK)  REFERENCES products(productPK)
);

-------------------------
-- 2. Rebuild purchases ONLY
-------------------------

-- Clear child table (allowed even with FKs)
TRUNCATE TABLE purchases;

-- Insert purchases with foreign keys using existing customers/products
INSERT INTO purchases (
    transactionid,
    customerPK,
    productPK,
    customerid,
    productid,
    purchasequantity,
    purchaseprice,
    purchasedate
)
SELECT 
    cp.transactionid,
    c.customerPK,
    p.productPK,
    cp.customerid,
    cp.productid,
    cp.purchasequantity,
    cp.purchaseprice,
    cp.purchasedate
FROM cus_purchase AS cp
JOIN customers AS c ON cp.customerid = c.customerid
JOIN products  AS p ON cp.productid  = p.productid;

-------------------------
-- 3. Row-count checks
-------------------------

SELECT COUNT(*) AS n_cus_purchase FROM cus_purchase;
SELECT COUNT(*) AS n_customers     FROM customers;
SELECT COUNT(*) AS n_products      FROM products;
SELECT COUNT(*) AS n_purchases     FROM purchases;

-------------------------
-- 4. Analysis queries
-------------------------

SELECT c.customerid, c.customername, SUM(pc.purchasequantity) AS tot_purchases
FROM customers AS c
JOIN purchases AS pc ON c.customerpk = pc.customerpk
GROUP BY c.customerid, c.customername
ORDER BY tot_purchases DESC;

SELECT p.productid, p.productname, SUM(pc.purchasequantity) AS tot_saless
FROM products AS p
JOIN purchases AS pc ON p.productpk = pc.productpk
GROUP BY p.productid, p.productname
ORDER BY tot_saless DESC;

SELECT p.productcategory, SUM(pc.purchaseprice) AS sale_price
FROM products AS p
JOIN purchases AS pc ON p.productpk = pc.productpk
WHERE YEAR(purchasedate) = 2023
GROUP BY productcategory
ORDER BY sale_price DESC;

SELECT c.customerid, c.customername, c.country, SUM(pc.purchasequantity) AS sales
FROM customers AS c
JOIN purchases AS pc ON c.customerpk = pc.customerpk
GROUP BY c.customerid, c.customername, c.country
ORDER BY sales DESC, c.country ASC;

SELECT p.productname, p.productcategory, pc.purchaseprice
FROM products AS p
JOIN purchases AS pc ON p.productpk = pc.productpk
WHERE pc.purchaseprice > 500
ORDER BY pc.purchaseprice DESC, p.productcategory ASC;

SELECT * FROM purchases
WHERE customerid IS NULL;

SELECT customerpk, productpk, customerid, productid, COUNT(*) 
FROM purchases
GROUP BY customerpk, productpk, customerid, productid
HAVING COUNT(*) > 1;

SHOW DATABASES;
