CREATE OR REPLACE FUNCTION build_ltree()
RETURNS TRIGGER AS $$
DECLARE
  var_code TEXT;
  var_parent_id UUID;
  var_ltree_path LTREE;
  var_ltree_code_path LTREE;
BEGIN
    -- Generate a new human-readable code for this Org Unit
    var_code := UPPER(encode(gen_random_bytes(2), 'hex') || encode(gen_random_bytes(2), 'hex'));
    NEW.code := var_code;

    -- Retrieve this Org Unit's parent
    SELECT INTO var_parent_id
        parent_id
    FROM org_unit_hierarchy h
    JOIN org_unit ou ON ou.id = h.child_id
    WHERE ou.id = NEW.id;

    -- If it doesn't have a parent, we can
    -- skip the entire calculation of the
    -- lineage/LTREE.
    IF var_parent_id IS NULL THEN
        RAISE NOTICE 'Org Unit is root. LTREE is simple.';

        -- The LTREEs are very simple.
        NEW.path := UPPER(REPLACE(NEW.id::text, '-', ''));
        NEW.code_path := NEW.code;

        -- Immediately return.
        -- There's nothing left for us to do.
        RETURN NEW;
    END IF;


    -- If we've reached here, it means this Org Unit
    -- has a parent, and potentially many more ancestors.
    --
    -- Use a recursive CTE to calculate the Org Unit's
    -- ancestral hierarchy/lineage. The following code
    -- is the real heavy lifting of this function.
    WITH RECURSIVE tree AS (
        -- The initial (non-recursive) part selects the starting node
        SELECT
            parent_id,
            child_id,
            UPPER(REPLACE(child_id::TEXT, '-', '')) AS ltree_path,
            UPPER(REPLACE(code::TEXT, '-', '')) AS ltree_code_path
        FROM org_unit_hierarchy
        JOIN org_unit ON org_unit.id = org_unit_hierarchy.child_id
        WHERE child_id = NEW.id

        UNION ALL

        -- This part continues to traverse the lineage
        -- recursively until no more ancestors are found.
        SELECT
            h.parent_id,
            h.child_id,
            UPPER(REPLACE(t.ltree_path || '.' || h.child_id::TEXT, '-', '')),
            UPPER(REPLACE(t.ltree_code_path || '.' || ou.code::TEXT, '-', ''))
        FROM org_unit_hierarchy h
        JOIN org_unit ou ON ou.id = h.child_id
        JOIN tree t ON h.child_id = t.parent_id
    )
    SELECT ltree_path, ltree_code_path
    INTO var_ltree_path, var_ltree_code_path
    FROM tree;

    RAISE NOTICE 'Computed LTREE path: %', var_ltree_path;
    RAISE NOTICE 'Computed LTREE code_path: %', var_ltree_code_path;

    NEW.path := var_ltree_path;
    NEW.code_path := var_ltree_code_path;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
CREATE TRIGGER before_insert_org_unit
BEFORE INSERT ON org_unit
FOR EACH ROW
EXECUTE FUNCTION build_ltree();
