create table if not exists public.orders (
	"id" bigserial constraint orders_pk primary key not null,
	"status" varchar(255) not null
);

create table if not exists public.orders_date (
	"order_id" int8 constraint orders_date_order_id_fk references orders(id) not null,
	"status" varchar(255) not null,
	"date_created" date default current_date not null
);

create table if not exists public.product (
	"id" bigserial constraint product_pk primary key not null,
	"name" varchar(255) not null,
	"picture_url" varchar(255) not null
);

create table if not exists public.product_info (
	"product_id" int8 constraint product_info_product_id_fk references product(id) not null,
	"name" varchar(255) not null,
	"price" numeric(10, 2) not null
);

create table if not exists public.order_product (
	"quantity" int4 not null,
	"order_id" int8 constraint order_product_order_id_fk references orders(id) not null,
	"product_id" int8 constraint order_product_product_id_fk references product(id) not null
);