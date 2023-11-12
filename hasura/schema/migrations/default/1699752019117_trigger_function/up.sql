-- A function that executes before any Org Unit is inserted.
CREATE OR REPLACE FUNCTION prepare_org_unit()
RETURNS TRIGGER AS $$
DECLARE
  var_code TEXT;
  var_path TEXT;
BEGIN
    -- Generate a new human-readable code for this Org Unit
    var_code := UPPER(encode(gen_random_bytes(2), 'hex') || encode(gen_random_bytes(2), 'hex'));
    var_path := UPPER(REPLACE(NEW.id::TEXT, '-', ''));

    RAISE NOTICE 'New code: %', var_code;
    RAISE NOTICE 'New path: %', var_path;
    RAISE NOTICE 'New code_path: %', var_code;

    NEW.code := var_code;
    NEW.path := var_path;
    NEW.code_path := var_code;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_org_unit
BEFORE INSERT ON org_unit
FOR EACH ROW
EXECUTE FUNCTION prepare_org_unit();

-- A function that executes after an Org Unit Hierarchy record is inserted.
-- This function will recompute the LTREEs on the child node.
CREATE OR REPLACE FUNCTION build_ltree()
RETURNS TRIGGER AS $$
DECLARE
  var_ltree_path LTREE;
  var_ltree_code_path LTREE;
BEGIN
    -- Use a recursive CTE to calculate the Org Unit's
    -- ancestral hierarchy/lineage.
    WITH RECURSIVE tree AS (
        -- The initial (non-recursive) part selects the starting node
        SELECT
            parent_id AS parent_id,
            child_id AS child_id,
            UPPER(REPLACE(base_hierarchy.parent_id::TEXT || '.' || base_hierarchy.child_id::TEXT, '-', '')) AS ltree_path,
            UPPER(base_parent.code::TEXT || '.' || base_child.code::TEXT) AS ltree_code_path
        FROM org_unit_hierarchy base_hierarchy
        JOIN org_unit base_parent ON base_parent.id = base_hierarchy.parent_id
        JOIN org_unit base_child ON base_child.id = base_hierarchy.child_id
        WHERE base_hierarchy.child_id = NEW.child_id

        UNION ALL

        -- This part continues to traverse the lineage
        -- recursively until no more ancestors are found.
        SELECT
            h.parent_id AS parent_id,
            h.child_id AS child_id,
            UPPER(REPLACE(t.ltree_path || '.' || child.id::TEXT, '-', '')) AS ltree_path,
            UPPER(t.ltree_code_path || '.' || child.code) AS ltree_code_path
        FROM org_unit_hierarchy h
        JOIN org_unit child ON child.id = h.child_id
        JOIN tree t ON t.parent_id = h.child_id
    )
    SELECT ltree_path, ltree_code_path
    INTO var_ltree_path, var_ltree_code_path
    FROM tree;

    RAISE NOTICE 'Computed LTREE path: %', var_ltree_path;
    RAISE NOTICE 'Computed LTREE code_path: %', var_ltree_code_path;

    -- Update the Org Unit with the computed LTREEs!
    UPDATE org_unit
    SET
        path = var_ltree_path,
        code_path = var_ltree_code_path
    WHERE id = NEW.child_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
CREATE TRIGGER after_insert_org_unit_hierarchy
AFTER INSERT ON org_unit_hierarchy
FOR EACH ROW
EXECUTE FUNCTION build_ltree();
