from flask import Flask, render_template, request, redirect, url_for
import os
import pymysql
from flask.views import MethodView
from datetime import date

app = Flask(__name__)

class Database:
    @staticmethod
    def get_connection():
        return pymysql.connect(
            host=os.getenv('RDS_ENDPOINT', 'localhost'),
            user=os.getenv('RDS_USER', 'admin'), 
            password=os.getenv('RDS_PASSWORD', 'secret'), 
            db='SOONGSIL_STUDENT_CAFETERIA_SCM', 
            charset='utf8'
        )

    @staticmethod
    def fetch_data(query, params=None):
        conn = Database.get_connection()
        cursor = conn.cursor(pymysql.cursors.DictCursor)
        try:
            cursor.execute(query, params)
            return cursor.fetchall()
        finally:
            cursor.close()
            conn.close()

class HomeView(MethodView):
    def get(self):
        try:
            target_date = request.args.get('date', date.today().strftime('%Y-%m-%d'))
            modify_id = request.args.get('modify', '')
            data = Database.fetch_data("""
                SELECT m.*, r.Name, r.Corner
                FROM MENU m
                JOIN RECIPE r
                ON m.RecipeID = r.RecipeID
                WHERE Date = %s;
            """, (target_date, ))
            recipe_data = Database.fetch_data("""
                SELECT RecipeID, Name FROM RECIPE;
            """)
            return render_template('menu.html', 
                                   date=target_date, 
                                   data=data, 
                                   modify=modify_id,
                                   recipe_data=recipe_data), 200
        except Exception as e:
            return str(e), 500

    def post(self):
        try:
            recipe_id = request.form.get('RecipeID')
            term = request.form.get('Term')
            menu_id = request.form.get('MenuID')
            price = request.form.get('Price')
            date = request.form.get('Date')

            if not all([recipe_id, term, menu_id, price]):
                return "모든 필드를 입력해주세요.", 400

            conn = Database.get_connection()
            cursor = conn.cursor()
            try:
                cursor.execute("""
                    UPDATE MENU 
                    SET Price = %s, Term = %s, RecipeID = %s
                    WHERE MenuID = %s
                """, (price, term, recipe_id, menu_id))
                conn.commit()
                return redirect(url_for('home', date=date))
            except pymysql.Error as e:
                conn.rollback()
                return f"데이터베이스 오류: {str(e)}", 500
            finally:
                cursor.close()
                conn.close()
        except Exception as e:
            return str(e), 500


    def put(self):
        try:
            data = request.get_json()
            recipe_id = data.get('RecipeID')
            term = data.get('Term')
            target_date = data.get('Date')
            price = data.get('Price')

            if not all([recipe_id, term, target_date, price]):
                return "모든 필드를 입력해주세요.", 400

            conn = Database.get_connection()
            cursor = conn.cursor()
            try:
                cursor.execute("""
                    INSERT INTO MENU (Price, Term, RecipeID, Date)
                    VALUES (%s, %s, %s, %s)
                """, (price, term, recipe_id, target_date))
                conn.commit()
                return "메뉴가 성공적으로 추가되었습니다.", 204
            except pymysql.Error as e:
                conn.rollback()
                return f"데이터베이스 오류: {str(e)}", 500
            finally:
                cursor.close()
                conn.close()
        except Exception as e:
            return str(e), 500

    def delete(self):
        try:
            menu_id = request.args.get('menu_id', '')

            conn = Database.get_connection()
            cursor = conn.cursor()
            try:
                cursor.execute("""
                    DELETE FROM MENU
                    WHERE MenuID = %s
                """, (menu_id,))
                conn.commit()
                return "성공적으로 삭제되었습니다", 204
            except pymysql.Error as e:
                conn.rollback()
                return f"데이터베이스 오류: {str(e)}", 500
            finally:
                cursor.close()
                conn.close()
        except Exception as e:
            return str(e), 500

class RecipeView(MethodView):
    def get(self):
        try:
            name = request.args.get('name', '새우까스')
            recipes = Database.fetch_data("""
                SELECT Name FROM RECIPE;
            """)
            data = Database.fetch_data("""
                SELECT * FROM RECIPE
                WHERE Name = %s;
            """, (name, ))
            required_ingredient_data = Database.fetch_data("""
                SELECT 
                    ri.QuantityRequired,
                    i.Name,
                    i.Unit,
                    (ri.QuantityRequired * i.Quantity) AS TotalQuantity,
                    SUM(st.StockQuantity * i.Quantity) AS TotalStock
                FROM RECIPE r
                JOIN RECIPE_INGREDIENT ri ON r.RecipeID = ri.RecipeID
                JOIN INGREDIENT i ON ri.IngredientID = i.IngredientID
                LEFT JOIN STOCK st ON st.IngredientID = i.IngredientID AND st.ExpiryDate > NOW()
                WHERE r.Name = %s
                GROUP BY i.IngredientID;
            """, (name, ))
            nutrition_data = Database.fetch_data("""
                SELECT 
                    SUM(n.Calories * ri.QuantityRequired / 300) AS Calories,
                    SUM(n.Carbohydrates * ri.QuantityRequired / 300) AS Carbohydrates,
                    SUM(n.Protein * ri.QuantityRequired / 300) AS Protein,
                    SUM(n.Fat * ri.QuantityRequired / 300) AS Fat,
                    SUM(n.Sodium * ri.QuantityRequired / 300) AS Sodium,
                    SUM(n.Sugar * ri.QuantityRequired / 300) AS Sugar
                FROM RECIPE r
                JOIN RECIPE_INGREDIENT ri ON r.RecipeID = ri.RecipeID
                JOIN INGREDIENT i ON ri.IngredientID = i.IngredientID
                JOIN NUTRITION n ON i.NutritionID = n.NutritionID
                WHERE r.Name = %s;
            """, (name, ))
            return render_template('recipe.html', 
                                   data=data, 
                                   required_ingredient_data=required_ingredient_data, 
                                   recipes=recipes,
                                   nutrition_data=nutrition_data), 200
        except Exception as e:
            return str(e), 500

class IngredientsView(MethodView):
    def get(self):
        try:
            ingredient_id = request.args.get('id', '')
            nutrition_id = request.args.get('nutrition', '')
            data = Database.fetch_data("""
                SELECT 
                    i.*,
                    (
                      SELECT NAME
                      FROM SUPPLIER s
                      WHERE s.SupplierID = i.SupplierID
                    ) AS SupplierName,
                    SUM(st.StockQuantity * i.Quantity) AS TotalStock,
                    CASE
                        WHEN EXISTS (
                          SELECT SupplierID
                          FROM SUPPLIER_CONTRACT sc
                          WHERE i.SupplierID = sc.SupplierID
                          AND NOW() BETWEEN sc.StartDate AND sc.EndDate
                        )
                        THEN 'Available'
                        ELSE 'Not Available'
                    END AS PurchaseStatus
                FROM INGREDIENT i
                LEFT JOIN STOCK st
                ON i.IngredientID = st.IngredientID
                AND st.ExpiryDate > NOW()
                GROUP BY i.IngredientID
                ORDER BY PurchaseStatus;
            """)
            if ingredient_id == '' and nutrition_id == '':
                return render_template('ingredients.html', data=data), 200
            detail_data = Database.fetch_data("""
                SELECT *,
                CASE
                    WHEN ExpiryDate > NOW()
                    THEN 'Available'
                    ELSE 'Expired'
                END AS StockStatus
                FROM STOCK
                WHERE IngredientID = %s
                ORDER BY ExpiryDate;
            """, (ingredient_id, ))
            nutirition_data = Database.fetch_data("""
                SELECT *
                FROM NUTRITION
                WHERE NutritionID = %s;
            """, (nutrition_id, ))
            return render_template('ingredients.html', 
                                   data=data, 
                                   detail_data=detail_data, 
                                   ingredient_id=ingredient_id,
                                   nutrition_data=nutirition_data), 200
        except Exception as e:
            return str(e), 500

class OrderView(MethodView):
    def get(self):
        try:
            data = Database.fetch_data("""
                SELECT * FROM ORDERING ORDER BY OrderedAt DESC;
            """)
            detail_data = Database.fetch_data("""
                SELECT oi.*, i.Name,
                (oi.Quantity * i.Cost) AS TotalCost
                FROM ORDERING_ITEM oi
                JOIN INGREDIENT i
                ON oi.IngredientID = i.IngredientID;
            """)
            return render_template('order.html', data=data, detail_data=detail_data), 200
        except Exception as e:
            return str(e), 500

    def post(self):
        try:
            status = request.form.get('Status')
            order_id = request.form.get('OrderID')
            ingredient_id = request.form.get('IngredientID')

            if not all([status, order_id, ingredient_id]):
                return f"모든 필드를 입력해주세요.", 400

            conn = Database.get_connection()
            cursor = conn.cursor()
            try:
                cursor.execute("""
                    UPDATE ORDERING_ITEM
                    SET Status = %s
                    WHERE OrderingID = %s
                    AND IngredientID = %s;
                """, (status, order_id, ingredient_id))
                conn.commit()
                return redirect(url_for('order'))
            except pymysql.Error as e:
                conn.rollback()
                return f"데이터베이스 오류: {str(e)}", 500
            finally:
                cursor.close()
                conn.close()
        except Exception as e:
            return str(e), 500

    def put(self):
        try:
            data = request.get_json()
            if not data:
                return "주문 데이터가 필요합니다.", 400
            conn = Database.get_connection()
            cursor = conn.cursor()
            try:
                cursor.execute("""
                    INSERT INTO ORDERING (OrderedAt)
                    VALUES (%s)
                """, (data[0].get('OrderDate'),))
                ordering_id = cursor.lastrowid
                for item in data:
                    cursor.execute("""
                        INSERT INTO ORDERING_ITEM 
                        (OrderingID, IngredientID, Quantity, Status)
                        VALUES (%s, %s, %s, 'Preparing')
                    """, (ordering_id, item.get('IngredientID'), item.get('Quantity'))
                    )
                conn.commit()
                return "주문이 성공적으로 생성되었습니다.", 204

            except pymysql.Error as e:
                conn.rollback()
                return f"데이터베이스 오류: {str(e)}", 500
            finally:
                cursor.close()
                conn.close()

        except Exception as e:
            return str(e), 500

class SuppliersView(MethodView):
    def get(self):
        try:
            supplier_id = request.args.get('id', '')
            data = Database.fetch_data("""
                SELECT s.*, 
                CASE 
                    WHEN EXISTS (
                      SELECT SupplierID 
                      FROM SUPPLIER_CONTRACT sc
                      WHERE sc.SupplierID = s.SupplierID 
                      AND NOW() BETWEEN sc.StartDate AND sc.EndDate
                    ) 
                    THEN 'Active' 
                    ELSE 'Expired' 
                END AS ContractStatus 
                FROM SUPPLIER s 
                ORDER BY ContractStatus;
            """)
            if supplier_id == '':
                return render_template('suppliers.html', data=data), 200
            detail_data = Database.fetch_data("""
                SELECT *
                FROM SUPPLIER_CONTRACT
                WHERE SupplierID = %s;
            """, (supplier_id, ))
            return render_template('suppliers.html', data=data, detail_data=detail_data), 200
        except Exception as e:
            return str(e), 500

app.add_url_rule('/', view_func=HomeView.as_view('home'))
app.add_url_rule('/recipe', view_func=RecipeView.as_view('recipe'))
app.add_url_rule('/ingredients', view_func=IngredientsView.as_view('ingredients'))
app.add_url_rule('/order', view_func=OrderView.as_view('order'))
app.add_url_rule('/suppliers', view_func=SuppliersView.as_view('suppliers'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)

