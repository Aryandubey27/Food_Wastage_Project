-- Table for Food Receivers
CREATE TABLE Receivers (
    Receiver_ID INT PRIMARY KEY,
    Name VARCHAR(255),
    Type VARCHAR(100),
    City VARCHAR(100),
    Contact VARCHAR(100)
-- );

-- Table for Food Listings
CREATE TABLE Food_Listings (
    Food_ID INT PRIMARY KEY,
    Food_Name VARCHAR(255),
    Quantity INT,
    Expiry_Date DATE,
    Provider_ID INT,
    Provider_Type VARCHAR(100),
    Location VARCHAR(100),
    Food_Type VARCHAR(100),
    Meal_Type VARCHAR(100)
);

-- Table for Food Providers
CREATE TABLE Providers (
    Provider_ID INT PRIMARY KEY,
    Name VARCHAR(255),
    Type VARCHAR(100),
    Address TEXT,
    City VARCHAR(100),
    Contact VARCHAR(100)
);

-- Table for Food Claims
CREATE TABLE Claims (
    Claim_ID INT PRIMARY KEY,
    Food_ID INT,
    Receiver_ID INT,
    Status VARCHAR(50),
    Timestamp TIMESTAMP
);

--Importing CSV Files

COPY Providers(Provider_ID, Name, Type, Address, City, Contact)
FROM 'D:\Sql_data\providers_data.csv'
DELIMITER ','
CSV HEADER;

COPY Receivers(Receiver_ID, Name, Type, City, Contact)
FROM 'D:\Sql_data\receivers_data.csv'
DELIMITER ','
CSV HEADER;

COPY Food_Listings(Food_ID, Food_Name, Quantity, Expiry_Date, Provider_ID, Provider_Type, Location, Food_Type, Meal_Type)
FROM 'D:\Sql_data\food_listings_data.csv'
DELIMITER ','
CSV HEADER;

COPY Claims(Claim_ID, Food_ID, Receiver_ID, Status, Timestamp)
FROM 'D:\Sql_data\claims_data.csv'
DELIMITER ','
CSV HEADER;

TRUNCATE TABLE Receivers;
TRUNCATE TABLE Food_Listings;
TRUNCATE TABLE Providers;
TRUNCATE TABLE Claims;


COPY Providers FROM 'D:\Food_Wastage_Project\cleaned_data\providers_data_cleaned.csv' DELIMITER ',' CSV HEADER;

COPY Receivers FROM 'D:\Food_Wastage_Project\cleaned_data\receivers_data_cleaned.csv' DELIMITER ',' CSV HEADER;

COPY Food_Listings FROM 'D:\Food_Wastage_Project\cleaned_data\food_listings_data_cleaned.csv' DELIMITER ',' CSV HEADER;

COPY Claims FROM 'D:\Food_Wastage_Project\cleaned_data\claims_data_cleaned.csv' DELIMITER ',' CSV HEADER;



--1. How many food providers and receivers are there in each city?

SELECT City, COUNT(*) AS Provider_Count, 'Provider' AS Type
FROM Providers
GROUP BY City
UNION ALL
SELECT City, COUNT(*) AS Receiver_Count, 'Receiver' AS Type
FROM Receivers
GROUP BY City
ORDER BY City, Type;

--2. Which type of food provider contributes the most food?

SELECT
    p.Type AS Provider_Type,
    SUM(fl.Quantity) AS Total_Quantity_Donated
FROM Providers p
JOIN Food_Listings fl ON p.Provider_ID = fl.Provider_ID
GROUP BY p.Type
ORDER BY Total_Quantity_Donated DESC
LIMIT 1;

--3. What is the contact information for providers in a specific city? (Example: 'New Jessica')

SELECT Name, Address, Contact
FROM Providers
WHERE City = 'New Jessica';

--4. Which receivers have claimed the most food?

SELECT
    r.Name AS Receiver_Name,
    COUNT(c.Claim_ID) AS Number_Of_Claims
FROM Receivers r
JOIN Claims c ON r.Receiver_ID = c.Receiver_ID
GROUP BY r.Name
ORDER BY Number_Of_Claims DESC
LIMIT 5; -- Top 5

--5. What is the total quantity of food available from all providers?

SELECT SUM(Quantity) AS Total_Available_Food_Quantity
FROM Food_Listings;

--6. Which city has the highest number of food listings?

SELECT Location, COUNT(Food_ID) AS Number_Of_Listings
FROM Food_Listings
GROUP BY Location
ORDER BY Number_Of_Listings DESC
LIMIT 1;

--7. What are the most commonly available food types?

SELECT Food_Type, COUNT(Food_ID) AS Listing_Count
FROM Food_Listings
GROUP BY Food_Type
ORDER BY Listing_Count DESC;

--8. How many food claims have been made for each food item?

SELECT
    fl.Food_Name,
    COUNT(c.Claim_ID) AS Number_Of_Claims
FROM Claims c
JOIN Food_Listings fl ON c.Food_ID = fl.Food_ID
GROUP BY fl.Food_Name
ORDER BY Number_Of_Claims DESC;

--9. Which provider has had the highest number of successful food claims?

SELECT
    p.Name AS Provider_Name,
    COUNT(c.Claim_ID) AS Successful_Claims
FROM Providers p
JOIN Food_Listings fl ON p.Provider_ID = fl.Provider_ID
JOIN Claims c ON fl.Food_ID = c.Food_ID
WHERE c.Status = 'Completed'
GROUP BY p.Name
ORDER BY Successful_Claims DESC
LIMIT 1;

--10. What percentage of food claims are completed vs. pending vs. canceled?

SELECT
    Status,
    COUNT(*) AS Total_Claims,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Claims)), 2) AS Percentage
FROM Claims
GROUP BY Status;

--11. What is the average quantity of food claimed per receiver?

SELECT AVG(Total_Quantity_Claimed) AS Avg_Quantity_Per_Receiver
FROM (
    SELECT
        c.Receiver_ID,
        SUM(fl.Quantity) AS Total_Quantity_Claimed
    FROM Claims c
    JOIN Food_Listings fl ON c.Food_ID = fl.Food_ID
    WHERE c.Status = 'Completed'
    GROUP BY c.Receiver_ID
) AS Receiver_Totals;

--12. Which meal type is claimed the most?

SELECT
    fl.Meal_Type,
    COUNT(c.Claim_ID) AS Number_Of_Claims
FROM Claims c
JOIN Food_Listings fl ON c.Food_ID = fl.Food_ID
GROUP BY fl.Meal_Type
ORDER BY Number_Of_Claims DESC
LIMIT 1;

--13. What is the total quantity of food donated by each provider?

SELECT
    p.Name AS Provider_Name,
    SUM(fl.Quantity) AS Total_Donated
FROM Providers p
JOIN Food_Listings fl ON p.Provider_ID = fl.Provider_ID
GROUP BY p.Name
ORDER BY Total_Donated DESC;

































