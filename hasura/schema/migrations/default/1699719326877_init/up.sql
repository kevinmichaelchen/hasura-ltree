CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "ltree";

CREATE TABLE org_unit (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name varchar(100),
  path ltree,
  code varchar(10)
);

-- The Org Unit's code is what gets used in the LTREE.
CREATE UNIQUE INDEX name ON org_unit (code);

-- Optionally, create indexes to speed up certain operations
CREATE INDEX path_gist_idx ON org_unit USING GIST (path);
CREATE INDEX path_idx ON org_unit USING BTREE (path);

-- Create the BEFORE INSERT trigger function
CREATE OR REPLACE FUNCTION generate_random_code()
RETURNS TRIGGER AS $$
BEGIN
    NEW.code := encode(gen_random_bytes(5), 'hex') || encode(gen_random_bytes(5), 'hex');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the BEFORE INSERT trigger
CREATE TRIGGER before_insert_org_unit
BEFORE INSERT ON org_unit
FOR EACH ROW
EXECUTE FUNCTION generate_random_code();
