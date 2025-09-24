-- Kategori tablosu
CREATE TABLE categories (
  category_id   NUMBER PRIMARY KEY,
  category_name VARCHAR2(100) NOT NULL
);

-- MÜŞTERİLER (Customers)
CREATE TABLE customers (
  customer_id   NUMBER PRIMARY KEY,
  first_name    VARCHAR2(50),
  last_name     VARCHAR2(50),
  email         VARCHAR2(100) UNIQUE,
  city          VARCHAR2(50),
  register_date DATE DEFAULT SYSDATE
);

-- ÜRÜNLER (Products)
CREATE TABLE products (
  product_id   NUMBER PRIMARY KEY,
  product_name VARCHAR2(100) NOT NULL,
  price        NUMBER(10,2) NOT NULL,
  stock_qty    NUMBER DEFAULT 0,
  category_id  NUMBER,
  CONSTRAINT fk_category FOREIGN KEY (category_id) 
      REFERENCES categories(category_id)
);

-- SİPARİŞLER (Orders)
CREATE TABLE orders (
  order_id    NUMBER PRIMARY KEY,
  customer_id NUMBER,
  order_date  DATE DEFAULT SYSDATE,
  status      VARCHAR2(20) DEFAULT 'Pending',
  CONSTRAINT fk_customer FOREIGN KEY (customer_id)
      REFERENCES customers(customer_id)
);

-- SİPARİŞ DETAYLARI (Order Items)
CREATE TABLE order_items (
  order_item_id NUMBER PRIMARY KEY,
  order_id      NUMBER,
  product_id    NUMBER,
  quantity      NUMBER NOT NULL,
  unit_price    NUMBER(10,2),
  CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Veri ekleme (Insert ile)
INSERT INTO categories VALUES (1, 'Elektronik');
INSERT INTO categories VALUES (2, 'Giyim');
INSERT INTO categories VALUES (3, 'Kitap');
INSERT INTO categories VALUES (4, 'Kozmetik');
INSERT INTO categories VALUES (5, 'Anne&Çocuk');
INSERT INTO categories VALUES (6, 'Kadın');
INSERT INTO categories VALUES (7, 'Erkek');

-- Kitap kategorisi için yeni müşteri 
INSERT INTO customers VALUES (4, 'Mehmet', 'Demir', 'mehmet@example.com', 'Ankara', DATE '2012-06-15');

-- Kitap kategorisine yeni ürün
INSERT INTO products VALUES (4, 'Roman Kitap', 100, 10, 3);  -- category_id=3 (Kitap)

-- Yeni sipariş 
INSERT INTO orders VALUES (4, 4, SYSDATE, 'Shipped');  -- customer_id=4

-- Yeni sipariş detayı (yeni order ve ürün için)
INSERT INTO order_items VALUES (4, 4, 4, 1, 100);  -- quantity=1, unit_price=100 (ürün fiyatı)

-- Kozmetik kategorisi için yeni müşteri (rastgele tarih: 2017)
INSERT INTO customers VALUES (5, 'Elif', 'Şahin', 'elif@example.com', 'İzmir', DATE '2017-03-22');

-- Kozmetik kategorisine yeni ürün
INSERT INTO products VALUES (5, 'Parfüm', 300, 25, 4);  -- category_id=4 (Kozmetik)

-- Yeni sipariş (yeni müşteri için)
INSERT INTO orders VALUES (5, 5, SYSDATE, 'Shipped');  -- customer_id=5

-- Yeni sipariş detayı (yeni order ve ürün için)
INSERT INTO order_items VALUES (5, 5, 5, 1, 300);  -- quantity=1, unit_price=300 (ürün fiyatı)

-- Erkek kategorisi için yeni müşteri (rastgele tarih: 2020)
INSERT INTO customers VALUES (6, 'Ali', 'Öztürk', 'ali@example.com', 'İstanbul', DATE '2020-09-10');

-- Erkek kategorisine yeni ürün
INSERT INTO products VALUES (6, 'Gömlek', 400, 12, 7);  -- category_id=7 (Erkek)

-- Yeni sipariş (yeni müşteri için)
INSERT INTO orders VALUES (6, 6, SYSDATE, 'Shipped');  -- customer_id=6

-- Yeni sipariş detayı (yeni order ve ürün için)
INSERT INTO order_items VALUES (6, 6, 6, 3, 400);  -- quantity=3, unit_price=400 (ürün fiyatı)


-- Tüm kategorileri listele
SELECT * FROM categories;


-- Fiyatı 10000'den büyük olan ürünleri listele
SELECT product_name, price 
FROM products 
WHERE price > 10000;

-- Çalışanları maaşlarına göre büyükten küçüğe (DESC) sırala
SELECT * FROM employees 
ORDER BY salary DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- Ürün adını büyük harfe çevirip uzunluğunu hesapla
SELECT UPPER(product_name) AS upper_name, 
       LENGTH(product_name) AS name_length 
FROM products;

-- Fiyatı yuvarlayın ve mutlak değer alma (örneğin negatif stok için)
SELECT product_name, 
       ROUND(price, 0) AS rounded_price, 
       ABS(stock_qty) AS abs_stock 
FROM products;

-- 2015-2019 arasında uygulamaya katılanları listele
SELECT first_name AS FIRST_NAME, 
       last_name AS LAST_NAME, 
       register_date AS REGISTER_DATE 
FROM customers 
WHERE register_date BETWEEN DATE '2015-01-01' AND DATE '2019-12-31'
ORDER BY register_date;  -- Katılma tarihine göre sırala (artan)

--  Her kategorideki ürün sayısını saymak için
SELECT category_id, 
       COUNT(*) AS product_count 
FROM products 
GROUP BY category_id;

-- Her kategorinin toplam stok miktarını ve ortalama fiyatını hesaplama
SELECT category_id, 
       SUM(stock_qty) AS total_stock, 
       AVG(price) AS avg_price 
FROM products 
GROUP BY category_id;

-- Toplam stok mikarı 10'dan fazla olan kategorileri listele
SELECT category_id, 
       SUM(stock_qty) AS total_stock 
FROM products 
GROUP BY category_id 
HAVING SUM(stock_qty) > 10;

-- Ürünleri kategorileriyle birlikte listeleme 
SELECT p.product_name, p.price, c.category_name 
FROM products p 
INNER JOIN categories c ON p.category_id = c.category_id;

-- Tüm müşterileri ve varsa siparişlerini listele (siparişi olmayanlar da görünsün)
SELECT c.first_name, c.last_name, o.order_id, o.order_date 
FROM customers c 
LEFT JOIN orders o ON c.customer_id = o.customer_id 
ORDER BY c.customer_id;

-- Sipariş detaylarını ürün ve siparişle birleştirerek toplam tutarı hesaplama
SELECT oi.order_id, p.product_name, oi.quantity * oi.unit_price AS total_amount 
FROM order_items oi 
INNER JOIN orders o ON oi.order_id = o.order_id 
INNER JOIN products p ON oi.product_id = p.product_id;

--Ortalama fiyattan pahalı ürünleri listeleme
SELECT product_name, price 
FROM products 
WHERE price > (SELECT AVG(price) FROM products);

--  Belirli bir kategoriye ait ürünleri listeleme (alt sorgu ile kategori ID'si)
SELECT product_name 
FROM products 
WHERE category_id IN (SELECT category_id FROM categories WHERE category_name = 'Elektronik');

-- Siparişi olan müşterileri listele
SELECT first_name, last_name 
FROM customers c 
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);

-- Kategorileri ve ürün adlarını birleştirerek listele (tekrarsız)
SELECT category_name AS name FROM categories
UNION
SELECT product_name FROM products;

--Müşteri şehirlerini ve kategori adlarını birleştir (tekrarlamaya izin ver)
SELECT city AS location FROM customers
UNION ALL
SELECT category_name FROM categories;

-- Ürünleri stok miktarına göre gruplayan bir CTE ile yüksek stoklu ürünleri listele
WITH high_stock_products AS (
  SELECT product_id, stock_qty 
  FROM products 
  WHERE stock_qty > 10
)
SELECT p.product_name, h.stock_qty 
FROM products p 
INNER JOIN high_stock_products h ON p.product_id = h.product_id;

-- Ürünleri fiyata göre sıralayıp satır numarası ver.
SELECT product_name, price, 
       ROW_NUMBER() OVER (ORDER BY price DESC) AS row_num 
FROM products;

-- Kategorilere göre stok miktarını sırala ve rank ver
SELECT category_id, stock_qty, 
       RANK() OVER (PARTITION BY category_id ORDER BY stock_qty DESC) AS stock_rank 
FROM products;

-- Siparişleri tarihe göre dense rank ver (eşitliklerde boşluk bırakmadan)
SELECT order_id, order_date, 
       DENSE_RANK() OVER (ORDER BY order_date DESC) AS date_rank 
FROM orders;


-- Kategorilere göre ürün sayısını listele (ürün yoksa 0 göster - NVL ile NULL kullan)
SELECT c.category_name,
       NVL(COUNT(p.product_id), 0) AS product_count  -- COUNT NULL dönerse 0 yap
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id  -- Sol join: Tüm kategorileri getir, ürün yoksa NULL
GROUP BY c.category_name
ORDER BY product_count DESC;  -- Ürün sayısı azalan sırada

-- Duruma göre kategori adını kısaltın (örneğin 'Elektronik' ise 'Elec')
SELECT category_name, 
       DECODE(category_name, 'Elektronik', 'Elec', 'Giyim', 'Giy', 'Kitap', 'Kit', 'Kozmetik', 'Kozm', 'Kadın', 'K', 'Erkek', 'E') AS short_name 
FROM categories;

-- Mevcut tarihi ve bir hesaplama almak için (DUAL = tek satır)
SELECT SYSDATE AS current_date, 
       2 + 2 AS calculation 
FROM DUAL;


-- Sipariş hiyerarşisi (Order Level 1, Items Level 2)
SELECT LEVEL AS seviye,
       o.order_id,
       c.first_name || ' ' || c.last_name AS customer,
       p.product_name,
       oi.quantity
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
START WITH oi.order_item_id IS NULL  -- Root: Orders (items NULL gibi simüle)
CONNECT BY PRIOR o.order_id = oi.order_id  -- Items order_id'ye bağla
ORDER BY o.order_id;