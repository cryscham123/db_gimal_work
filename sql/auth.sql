USE SOONGSIL_STUDENT_CAFETERIA_SCM;

CREATE USER 'kitchen_staff'@'%' IDENTIFIED BY 'secret123';
CREATE USER 'purchasing_manager'@'%' IDENTIFIED BY 'secret123';
CREATE USER 'supplier'@'%' IDENTIFIED BY 'secret123';
CREATE USER 'nutritionist'@'%' IDENTIFIED BY 'secret123';

GRANT SELECT ON MENU TO 'kitchen_staff'@'%';
GRANT SELECT ON RECIPE_INGREDIENT TO 'kitchen_staff'@'%';
GRANT SELECT ON RECIPE TO 'kitchen_staff'@'%';
GRANT SELECT ON INGREDIENT TO 'kitchen_staff'@'%';
GRANT SELECT ON STOCK TO 'kitchen_staff'@'%';

GRANT SELECT, INSERT ON ORDERING TO 'purchasing_manager'@'%';
GRANT SELECT, INSERT ON ORDERING_ITEM TO 'purchasing_manager'@'%';
GRANT SELECT ON INGREDIENT TO 'purchasing_manager'@'%';
GRANT SELECT ON STOCK TO 'purchasing_manager'@'%';
GRANT SELECT ON SUPPLIER TO 'purchasing_manager'@'%';
GRANT SELECT ON SUPPLIER_CONTRACT TO 'purchasing_manager'@'%';

GRANT SELECT ON ORDERING TO 'supplier'@'%';
GRANT SELECT, UPDATE ON ORDERING_ITEM TO 'supplier'@'%';
GRANT SELECT ON INGREDIENT TO 'supplier'@'%';
GRANT SELECT ON SUPPLIER_CONTRACT TO 'supplier'@'%';
GRANT SELECT ON SUPPLIER TO 'supplier'@'%';


GRANT SELECT, INSERT, UPDATE, DELETE ON MENU TO 'nutritionist'@'%';
GRANT SELECT ON RECIPE TO 'nutritionist'@'%';
GRANT SELECT ON RECIPE_INGREDIENT TO 'nutritionist'@'%';
GRANT SELECT ON NUTRITION TO 'nutritionist'@'%';
GRANT SELECT ON INGREDIENT TO 'nutritionist'@'%';

FLUSH PRIVILEGES;
