// Getting information from TAG_REFERENCES regarding the tag needed
WITH tags_hist AS (
  SELECT object_id, tag_name, tag_value
  FROM snowflake.account_usage.tag_references
  WHERE tag_value = 'Level Super Secret A+++++++'
  ),

// Lateral join based on object_id
access_history_flatten AS (
  SELECT ah.query_id,
    f1.value:"objectId"::INT as object_id
  FROM snowflake.account_usage.access_history ah,  
    LATERAL flatten(base_objects_accessed) f1
  WHERE f1.value:"objectId"::INT in (SELECT object_id FROM tags_hist)
  AND f1.value:"objectDomain"::STRING='Table'
  )

// Building the results table
SELECT f.query_id,
  t.tag_name, t.tag_value,
  qh.database_name, qh.role_name
FROM access_history_flatten f
LEFT JOIN snowflake.account_usage.query_history qh
    ON f.query_id = qh.query_id
LEFT JOIN tags_hist t ON t.object_id = f.object_id
;
