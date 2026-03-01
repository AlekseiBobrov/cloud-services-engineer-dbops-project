ALTER TABLE product ADD COLUMN price numeric(10, 2);

UPDATE product
SET price = product_info.price
FROM product_info
WHERE product.id = product_info.product_id;

ALTER TABLE product ALTER COLUMN price SET NOT NULL;

DROP TABLE product_info;

ALTER TABLE orders ADD COLUMN date_created date default current_date not null;

UPDATE orders
SET date_created = orders_date.date_created
FROM orders_date
WHERE orders.id = orders_date.order_id;

DROP TABLE orders_date;