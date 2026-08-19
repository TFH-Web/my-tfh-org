-- Purpose: confirm WHY the serve team picker cards carry ~100px of dead space
-- under the description, even on the card with the most text (see the Baptism
-- card in the 2026-08-19 screenshot).
--
-- Hypothesis: ConnectionOpportunity.Summary is authored in Rock's HTML editor
-- and the values carry TRAILING EMPTY PARAGRAPHS from pasted content --
-- <p>&nbsp;</p> repeated a few times. Those render as real line boxes, not
-- margin, which is why the gap is ~5 lines tall and why no amount of
-- margin-bottom:0 was going to fix it. Because CSS grid rows size to their
-- tallest item, the junk on ONE card stretches every card in that row.
--
-- The picker's Lava now flattens Summary to text before rendering, so the
-- symptom is gone either way. This query is to confirm the diagnosis and to
-- decide whether the underlying content should be cleaned up in Rock too --
-- it affects anywhere else Summary is rendered as HTML, not just this page.
--
-- Run against the same campus the screenshot used. The picker defaults to 2.
--
-- Read the results as:
--   TrailingEmptyBlocks > 0  -> hypothesis confirmed for that row
--   RawLen vs TextLen        -> how much of the field is markup
--   TailHex                  -> the literal last 40 chars, entities and all

DECLARE @CampusId INT = 2;

SELECT
      CO.[Id]
    , CO.[Name]
    , LEN(CO.[Summary])                                  AS [RawLen]

    -- Rough count of trailing "empty paragraph" constructs. Each replace
    -- collapses one known-empty shape; the length drop / pattern length is
    -- how many were present.
    , ( LEN(CO.[Summary])
      - LEN(REPLACE(REPLACE(REPLACE(CO.[Summary],
            '<p>&nbsp;</p>', ''),
            '<p></p>',       ''),
            '<p> </p>',      ''))
      ) / NULLIF(LEN('<p>&nbsp;</p>'), 0)                AS [TrailingEmptyBlocks]

    , CASE WHEN CO.[Summary] LIKE '%<p>&nbsp;</p>' THEN 'YES' ELSE 'no' END
                                                          AS [EndsWithEmptyP]
    , CASE WHEN CO.[Summary] LIKE '%<br>' OR CO.[Summary] LIKE '%<br />' THEN 'YES' ELSE 'no' END
                                                          AS [EndsWithBr]

    -- The literal tail, so you can eyeball exactly what is trailing.
    , RIGHT(CO.[Summary], 40)                            AS [Tail]

    , CO.[Summary]                                       AS [RawSummary]

FROM [ConnectionOpportunity] CO
JOIN [ConnectionOpportunityCampus] CC
    ON CC.[ConnectionOpportunityId] = CO.[Id]
LEFT JOIN [Attribute] A
    ON A.[EntityTypeQualifierValue] = CO.[ConnectionTypeId]
   AND CO.[ConnectionTypeId] = 1
   AND A.[Id] = 44230
LEFT JOIN [AttributeValue] AV
    ON AV.[AttributeId] = A.[Id]
   AND AV.[EntityId] = CO.[Id]

WHERE CO.[IsActive] = 1
  AND CC.[CampusId] = @CampusId
  AND ( (CO.[ConnectionTypeId] = 1 AND AV.[Value] = 'True') OR CO.[Id] = 52 )

ORDER BY [TrailingEmptyBlocks] DESC, CO.[Name];
