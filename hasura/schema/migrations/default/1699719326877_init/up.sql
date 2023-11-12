CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "ltree";

CREATE TABLE IF NOT EXISTS org_unit (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name varchar(100),
  path ltree,
  code varchar(8),
  code_path ltree
);

-- The Org Unit's code is what gets used in the LTREE.
CREATE UNIQUE INDEX IF NOT EXISTS name ON org_unit (code);

-- Optionally, create indexes to speed up certain operations
CREATE INDEX IF NOT EXISTS idx_org_unit_path_gist ON org_unit USING GIST (path);
CREATE INDEX IF NOT EXISTS idx_org_unit_path_btree ON org_unit USING BTREE (path);
CREATE INDEX IF NOT EXISTS idx_org_unit_code_path_gist ON org_unit USING GIST (code_path);
CREATE INDEX IF NOT EXISTS idx_org_unit_code_path_btree ON org_unit USING BTREE (code_path);

CREATE TABLE IF NOT EXISTS org_unit_hierarchy (
    parent_id uuid,
    child_id uuid,
    PRIMARY KEY (parent_id, child_id),
    CONSTRAINT fk_org_unit_hierarchy_parent_id FOREIGN KEY (parent_id) REFERENCES org_unit(id),
    CONSTRAINT fk_org_unit_hierarchy_child_id FOREIGN KEY (child_id) REFERENCES org_unit(id)
);
