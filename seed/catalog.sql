-- Demo catalog. Safe to run again: existing rows are left alone.
-- Fixed IDs so the demo orders in seed.sh and the e2e tests can rely on them.

insert into categories (id, name, slug) values
    (1, 'Coffee', 'coffee'),
    (2, 'Grinders', 'grinders'),
    (3, 'Brewing', 'brewing'),
    (4, 'Accessories', 'accessories')
on conflict (id) do nothing;

insert into products (id, sku, name, description, category_id, active) values
    (1,  'BEAN-ESP-1KG', 'Espresso beans 1kg', 'Dark roast, chocolate and hazelnut.', 1, true),
    (2,  'BEAN-FLT-250', 'Filter beans 250g', 'Light roast from Ethiopia. Floral.', 1, true),
    (3,  'BEAN-DEC-500', 'Decaf beans 500g', 'Swiss water process.', 1, true),
    (4,  'GR-HAND-01', 'Hand grinder', 'Steel burrs, 35 g hopper.', 2, true),
    (5,  'GR-ELEC-02', 'Electric grinder', '40 mm flat burrs, 30 settings.', 2, true),
    (6,  'BRW-V60-02', 'Pour-over dripper', 'Ceramic, size 02.', 3, true),
    (7,  'BRW-PRESS-8', 'French press 8 cup', 'Borosilicate glass.', 3, true),
    (8,  'ACC-JUG-350', 'Milk jug', 'Stainless steel, 350 ml.', 4, true),
    (9,  'ACC-TAMP-58', 'Tamper 58mm', NULL, 4, true),
    (10, 'ACC-SCALE-1', 'Coffee scale', 'With timer. 0.1 g resolution.', 4, true),
    (11, 'GR-HAND-00', 'Hand grinder (old model)', 'Replaced by GR-HAND-01.', 2, false),
    (12, 'BRW-FILT-100', 'Paper filters (100)', 'For the pour-over dripper.', 3, true)
on conflict (id) do nothing;

-- Product 12 has no price yet: it shows in the list but can't be ordered.
insert into prices (id, product_id, amount, currency, valid_from, valid_to) values
    (1,  1, 21.90, 'EUR', '2025-01-01T00:00:00Z', '2026-01-01T00:00:00Z'),
    (2,  1, 18.90, 'EUR', '2026-01-01T00:00:00Z', NULL),
    (3,  2,  9.50, 'EUR', '2025-01-01T00:00:00Z', NULL),
    (4,  3, 12.00, 'EUR', '2025-01-01T00:00:00Z', NULL),
    (5,  4, 64.00, 'EUR', '2025-01-01T00:00:00Z', NULL),
    (6,  5, 249.00, 'EUR', '2025-01-01T00:00:00Z', NULL),
    (7,  6, 24.00, 'EUR', '2025-01-01T00:00:00Z', NULL),
    (8,  7, 34.50, 'EUR', '2025-01-01T00:00:00Z', NULL),
    (9,  8, 12.50, 'EUR', '2025-01-01T00:00:00Z', NULL),
    (10, 9, 29.00, 'EUR', '2025-01-01T00:00:00Z', NULL),
    (11, 10, 39.90, 'EUR', '2025-01-01T00:00:00Z', NULL),
    (12, 11, 49.00, 'EUR', '2024-01-01T00:00:00Z', NULL)
on conflict (id) do nothing;

-- Explicit IDs don't move the identity sequences.
select setval(pg_get_serial_sequence('categories', 'id'), (select max(id) from categories));
select setval(pg_get_serial_sequence('products', 'id'), (select max(id) from products));
select setval(pg_get_serial_sequence('prices', 'id'), (select max(id) from prices));
