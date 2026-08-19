-- Purpose: check whether the name-derived slug fallback in SignUps/*.html is safe
--          for the ACTUAL sign-up groups, so the PublicSlug attribute can stay
--          optional. Flags two failure modes:
--            1. collisions   — two groups deriving the same slug (one becomes
--                              unreachable; the detail query does TOP 1 ORDER BY g.Id)
--            2. unsafe chars — anything left in the slug that is not a-z, 0-9 or '-'
--                              ('#' is the dangerous one: it truncates the URL path)
--          Scratch check only — nothing here ships.

DECLARE @groupTypeId INT = 176;   -- Sign-Up Group

;WITH Slugs AS (
    SELECT  g.Id,
            g.Name,
            LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                g.Name, '''', ''), '&', 'and'), '.', ''), ',', ''),
                '/', '-'), ':', ''), ' ', '-')) AS DerivedSlug,
            ISNULL(NULLIF(av.Value, ''), '')    AS PublicSlugAttr
    FROM    [Group] g
    LEFT    JOIN Attribute a       ON a.[Key] = 'PublicSlug'
                                  AND a.EntityTypeQualifierColumn = 'GroupTypeId'
                                  AND a.EntityTypeQualifierValue = CAST(@groupTypeId AS VARCHAR(10))
    LEFT    JOIN AttributeValue av ON av.AttributeId = a.Id AND av.EntityId = g.Id
    WHERE   g.GroupTypeId = @groupTypeId
      AND   g.IsActive = 1
      AND   g.IsPublic = 1
)
SELECT  s.Id,
        s.Name,
        s.DerivedSlug,
        s.PublicSlugAttr,
        CASE WHEN COUNT(*) OVER (PARTITION BY s.DerivedSlug) > 1
             THEN 'COLLISION' ELSE '' END                      AS CollisionFlag,
        CASE WHEN s.DerivedSlug LIKE '%[^a-z0-9-]%' COLLATE Latin1_General_BIN
             THEN 'UNSAFE CHARS' ELSE '' END                   AS CharFlag,
        CASE WHEN s.DerivedSlug LIKE '%#%' THEN 'BREAKS URL' ELSE '' END AS HashFlag
FROM    Slugs s
ORDER   BY CollisionFlag DESC, CharFlag DESC, s.Name;

-- Does the PublicSlug attribute even exist yet? (The blocks work either way —
-- a missing attribute LEFT JOINs to NULL and falls straight through to the
-- derived slug.)
SELECT Id, [Key], Name, EntityTypeQualifierColumn, EntityTypeQualifierValue
FROM   Attribute
WHERE  [Key] IN ('PublicSlug', 'ProjectImage')
  AND  EntityTypeQualifierColumn = 'GroupTypeId';
