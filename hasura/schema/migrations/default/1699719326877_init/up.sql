CREATE EXTENSION IF NOT EXISTS ltree;

CREATE TABLE org_unit (id uuid, name varchar(100), path ltree);

-- Optionally, create indexes to speed up certain operations
CREATE INDEX path_gist_idx ON org_unit USING GIST (path);
CREATE INDEX path_idx ON org_unit USING BTREE (path);
