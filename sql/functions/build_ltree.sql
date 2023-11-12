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
            base_hierarchy.parent_id AS parent_id,
            base_hierarchy.child_id AS child_id,
            ARRAY_CAT(
                ARRAY(
                    SELECT UPPER(REPLACE(base_parent.id::TEXT, '-', ''))
                ),
                ARRAY(
                    SELECT UPPER(REPLACE(base_child.id::TEXT, '-', ''))
                )
            ) AS path,
            ARRAY_CAT(
                ARRAY(
                    SELECT UPPER(base_parent.code)
                ),
                ARRAY(
                    SELECT UPPER(base_child.code)
                )
            ) AS code_path
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
            ARRAY_PREPEND(
                UPPER(REPLACE(h.parent_id::TEXT, '-', '')),
                t.path
            ) AS path,
            ARRAY_PREPEND(
                UPPER(parent.code),
                t.code_path
            ) AS code_path
        FROM org_unit_hierarchy h
        JOIN org_unit parent ON parent.id = h.parent_id
        JOIN org_unit child ON child.id = h.child_id
        JOIN tree t ON t.parent_id = h.child_id
    )
    SELECT array_to_string(path, '.'), array_to_string(code_path, '.')
    INTO var_ltree_path, var_ltree_code_path
    FROM tree
    WHERE child_id = NEW.child_id;

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
