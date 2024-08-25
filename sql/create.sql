CREATE DATABASE IF NOT EXISTS SOONGSIL_STUDENT_CAFETERIA_SCM;

USE SOONGSIL_STUDENT_CAFETERIA_SCM;

CREATE TABLE IF NOT EXISTS `INGREDIENT` (
  `IngredientID` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Name` varchar(255) NOT NULL,
  `Quantity` decimal(10, 2) NOT NULL,
  `Cost` decimal(10, 2) NOT NULL,
  `SupplierID` int NOT NULL,
  `NutritionID` int NOT NULL,
  `Unit` char(5) NOT NULL
);

CREATE TABLE IF NOT EXISTS `MENU` (
  `MenuID` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Name` varchar(255) NOT NULL,
  `Price` decimal(10, 2) NOT NULL,
  `Term` char(10) NOT NULL,
  `Corner` char(50) NOT NULL,
  `RecipeID` int NOT NULL,
  `Date` date NOT NULL,
  CONSTRAINT chk_term CHECK (`Term` IN ('Breakfast', 'Lunch', 'Dinner')),
  CONSTRAINT chk_corner CHECK (`Corner` IN ('HotPot', 'RiceBowl', 'Western'))
);

CREATE TABLE IF NOT EXISTS `ORDER_ITEM` (
  `OrderID` int NOT NULL,
  `IngredientID` int NOT NULL,
  `Quantity` int NOT NULL,
  `TotalCost` decimal(10, 2),
  `Status` char(20) NOT NULL,
  PRIMARY KEY (`OrderID`, `IngredientID`),
  CONSTRAINT chk_status CHECK (`Status` IN ('Preparing', 'Shipping', 'Delivered', 'Cancelled', 'Returning', 'Returned'))
);

CREATE TABLE IF NOT EXISTS `NUTRITION` (
  `NutritionID` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Calories` decimal(10, 2),
  `Protein` decimal(10, 2),
  `Carbohydrates` decimal(10, 2),
  `Fat` decimal(10, 2),
  `Sugar` decimal(10, 2),
  `Sodium` decimal(10, 2)
); -- (kcal, g, g, g, g, mg)

CREATE TABLE IF NOT EXISTS `ORDER` (
  `OrderID` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `OrderedAt` datetime,
  `TotalCost` decimal(10, 2)
);

CREATE TABLE IF NOT EXISTS `RECIPE` (
  `RecipeID` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Name` varchar(255) NOT NULL,
  `Instructions` varchar(4095) NOT NULL
);

CREATE TABLE IF NOT EXISTS `RECIPE_INGREDIENT` (
  `RecipeID` int NOT NULL,
  `IngredientID` int NOT NULL,
  `QuantityRequired` decimal(10, 6) NOT NULL,
  PRIMARY KEY (`RecipeID`, `IngredientID`)
);

CREATE TABLE IF NOT EXISTS `STOCK` (
  `StockID` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `StockQuantity` decimal(10, 2) NOT NULL,
  `ExpiryDate` datetime,
  `IngredientID` int NOT NULL
);

CREATE TABLE IF NOT EXISTS `SUPPLIER` (
  `SupplierID` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Name` varchar(255) NOT NULL,
  `Phone` char(15) NOT NULL,
  `Address` varchar(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS `SUPPLIER_CONTRACT` (
  `ContractID` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `StartDate` datetime NOT NULL,
  `EndDate` datetime NOT NULL,
  `SupplierID` int NOT NULL
);

ALTER TABLE `INGREDIENT` ADD CONSTRAINT `INGREDIENT_NutritionID_fk` FOREIGN KEY (`NutritionID`) REFERENCES `NUTRITION` (`NutritionID`);
ALTER TABLE `INGREDIENT` ADD CONSTRAINT `INGREDIENT_SupplierID_fk` FOREIGN KEY (`SupplierID`) REFERENCES `SUPPLIER` (`SupplierID`);
ALTER TABLE `MENU` ADD CONSTRAINT `MENU_RecipeID_fk` FOREIGN KEY (`RecipeID`) REFERENCES `RECIPE` (`RecipeID`);
ALTER TABLE `ORDER_ITEM` ADD CONSTRAINT `ORDER_ITEM_IngredientID_fk` FOREIGN KEY (`IngredientID`) REFERENCES `INGREDIENT` (`IngredientID`);
ALTER TABLE `ORDER_ITEM` ADD CONSTRAINT `ORDER_ITEM_OrderID_fk` FOREIGN KEY (`OrderID`) REFERENCES `ORDER` (`OrderID`);
ALTER TABLE `RECIPE_INGREDIENT` ADD CONSTRAINT `RECIPE_INGREDIENT_IngredientID_fk` FOREIGN KEY (`IngredientID`) REFERENCES `INGREDIENT` (`IngredientID`);
ALTER TABLE `RECIPE_INGREDIENT` ADD CONSTRAINT `RECIPE_INGREDIENT_RecipeID_fk` FOREIGN KEY (`RecipeID`) REFERENCES `RECIPE` (`RecipeID`);
ALTER TABLE `STOCK` ADD CONSTRAINT `STOCK_IngredientID_fk` FOREIGN KEY (`IngredientID`) REFERENCES `INGREDIENT` (`IngredientID`);
ALTER TABLE `SUPPLIER_CONTRACT` ADD CONSTRAINT `SUPPLIER_CONTRACT_SupplierID_fk` FOREIGN KEY (`SupplierID`) REFERENCES `SUPPLIER` (`SupplierID`);
