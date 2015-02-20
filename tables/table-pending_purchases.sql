
-- Holds records of customers who have gone to the shopping cart
-- site, so we can identify them by IP when they come back.

create table pending_purchases
(
  ip_address    text not null,
  email_address text not null,
  dt_added      timestamp not null
);

alter table pending_purchases owner to pgsql;
