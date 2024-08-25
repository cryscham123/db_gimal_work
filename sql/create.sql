CREATE DATABASE IF NOT EXISTS SOONGSIL_STUDENT_CAFETERIA_SCM;

USE SOONGSIL_STUDENT_CAFETERIA_SCM;

CREATE TABLE `INGREDIENT` (
  `IngredientID` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Name` varchar(255) NOT NULL,
  `Quantity` decimal(10, 2) NOT NULL,
  `Cost` decimal(10, 2) NOT NULL,
  `SupplierID` int NOT NULL,
  `NutritionID` int NOT NULL UNIQUE,
  `Unit` char(5) NOT NULL
);

CREATE TABLE `MENU` (
  `MenuID` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Price` decimal(10, 2) NOT NULL,
  `Term` char(10) NOT NULL,
  `RecipeID` int NOT NULL,
  `Date` date NOT NULL,
  CONSTRAINT chk_term CHECK (`Term` IN ('Breakfast', 'Lunch', 'Dinner'))
);

CREATE TABLE `ORDERING_ITEM` (
  `OrderingID` int NOT NULL,
  `IngredientID` int NOT NULL,
  `Quantity` int NOT NULL,
  `Status` char(20) NOT NULL,
  PRIMARY KEY (`OrderingID`, `IngredientID`),
  CONSTRAINT chk_status CHECK (`Status` IN ('Preparing', 'Shipping', 'Delivered', 'Cancelled', 'Returning', 'Returned'))
);

CREATE TABLE `NUTRITION` (
  `NutritionID` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Calories` decimal(10, 2),
  `Protein` decimal(10, 2),
  `Carbohydrates` decimal(10, 2),
  `Fat` decimal(10, 2),
  `Sugar` decimal(10, 2),
  `Sodium` decimal(10, 2)
); -- (kcal, g, g, g, g, mg)

CREATE TABLE `ORDERING` (
  `OrderingID` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `OrderedAt` datetime
);

CREATE TABLE `RECIPE` (
  `RecipeID` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Name` varchar(255) NOT NULL,
  `Corner` char(50) NOT NULL,
  `Instructions` varchar(4095) NOT NULL,
  CONSTRAINT chk_corner CHECK (`Corner` IN ('HotPot', 'RiceBowl', 'Western'))
);

CREATE TABLE `RECIPE_INGREDIENT` (
  `RecipeID` int NOT NULL,
  `IngredientID` int NOT NULL,
  `QuantityRequired` decimal(15, 10) NOT NULL,
  PRIMARY KEY (`RecipeID`, `IngredientID`)
);

CREATE TABLE `STOCK` (
  `StockID` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `StockQuantity` decimal(10, 2) NOT NULL,
  `ExpiryDate` datetime,
  `IngredientID` int NOT NULL
);

CREATE TABLE `SUPPLIER` (
  `SupplierID` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Name` varchar(255) NOT NULL,
  `Phone` char(15) NOT NULL,
  `Address` varchar(255) NOT NULL
);

CREATE TABLE `SUPPLIER_CONTRACT` (
  `ContractID` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `StartDate` date NOT NULL,
  `EndDate` date NOT NULL,
  `SupplierID` int NOT NULL
);

ALTER TABLE `INGREDIENT` ADD CONSTRAINT `INGREDIENT_NutritionID_fk` FOREIGN KEY (`NutritionID`) REFERENCES `NUTRITION` (`NutritionID`);
ALTER TABLE `INGREDIENT` ADD CONSTRAINT `INGREDIENT_SupplierID_fk` FOREIGN KEY (`SupplierID`) REFERENCES `SUPPLIER` (`SupplierID`);
ALTER TABLE `MENU` ADD CONSTRAINT `MENU_RecipeID_fk` FOREIGN KEY (`RecipeID`) REFERENCES `RECIPE` (`RecipeID`);
ALTER TABLE `ORDERING_ITEM` ADD CONSTRAINT `ORDERING_ITEM_IngredientID_fk` FOREIGN KEY (`IngredientID`) REFERENCES `INGREDIENT` (`IngredientID`);
ALTER TABLE `ORDERING_ITEM` ADD CONSTRAINT `ORDERING_ITEM_OrderingID_fk` FOREIGN KEY (`OrderingID`) REFERENCES `ORDERING` (`OrderingID`);
ALTER TABLE `RECIPE_INGREDIENT` ADD CONSTRAINT `RECIPE_INGREDIENT_IngredientID_fk` FOREIGN KEY (`IngredientID`) REFERENCES `INGREDIENT` (`IngredientID`);
ALTER TABLE `RECIPE_INGREDIENT` ADD CONSTRAINT `RECIPE_INGREDIENT_RecipeID_fk` FOREIGN KEY (`RecipeID`) REFERENCES `RECIPE` (`RecipeID`);
ALTER TABLE `STOCK` ADD CONSTRAINT `STOCK_IngredientID_fk` FOREIGN KEY (`IngredientID`) REFERENCES `INGREDIENT` (`IngredientID`);
ALTER TABLE `SUPPLIER_CONTRACT` ADD CONSTRAINT `SUPPLIER_CONTRACT_SupplierID_fk` FOREIGN KEY (`SupplierID`) REFERENCES `SUPPLIER` (`SupplierID`);
