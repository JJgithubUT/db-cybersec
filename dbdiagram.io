// Use colors to separate entities
Table companies {
  id integer [primary key, increment]
  name varchar
  street varchar
  city varchar
  state varchar
  zip_code varchar
}

Table products {
  id integer [primary key, increment]
  company_id integer [ref: > companies.id]
  code varchar [unique]
  name varchar
  price decimal(10,2)
}

Table customers {
  id integer [primary key, increment]
  ci varchar [unique, note: 'Cédula de Identidad / Tax ID']
  first_name varchar
  last_name varchar
  birth_date date
  phone varchar
  street varchar
  city varchar
  state varchar
  zip_code varchar
}

Table orders {
  id integer [primary key, increment]
  customer_id integer [ref: > customers.id]
  company_id integer [ref: > companies.id]
  order_date timestamp
  total_amount decimal(12,2)
}

Table order_items {
  id integer [primary key, increment]
  order_id integer [ref: > orders.id]
  product_id integer [ref: > products.id]
  units integer
  price_at_sale decimal(10,2) [note: 'Historical price at the time of purchase']
}