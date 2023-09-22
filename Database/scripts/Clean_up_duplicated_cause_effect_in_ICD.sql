-- Delete the ICD diagram sediment ICD(598) and metals ICD (633) before re-migrate the data

-- this query returns the cause effect pair where has higher hierarchy than effect.
/* 
This list contains all the shape pairs to be migrated into K_CAUSE_EFFECT according to the hierarchy below:
Human Activity -> Source
Human Activity -> Stressor
Human Activity -> Biological Response
Source -> Stressor
Source -> Biological Response
Stressor -> Biological Response
Only apply to diagrams 'composite ICD' (599) and 'flow example_NABS' (723)
*/
SELECT DISTINCT
	--a.SHAPE_LINKAGE_ID,
	b.SHAPE_LABEL AS FR_SHAPE_LABEL
	,
	--b.SHAPE_ID AS FR_SHAPE_ID,
	--b.LL_LEGEND_FILTER_ID AS FR_LEGEND_FILTER_ID,
	f.LIST_ITEM_CODE AS FR_LEGEND_FILTER
	,
	--             DECODE (b.LL_SHAPE_LABEL_SYMBOL_ID,
	--                     20026, 30418,
	--                     20027, 30419,
	--                     20028, 30420,
	--                     30421) AS FR_TRAJECTORY_ID,
	DECODE(b.LL_SHAPE_LABEL_SYMBOL_ID, 20026, 'change', 20027, 'increase', 20028, 'decrease', 'no trajectory') AS FR_TRAJECTORY
	,c.SHAPE_LABEL AS TO_SHAPE_LABEL
	,
	--c.SHAPE_ID AS TO_SHAPE_ID,
	--c.LL_LEGEND_FILTER_ID AS TO_LEGEND_FILTER_ID,
	g.LIST_ITEM_CODE AS TO_LEGEND_FILTER
	,
	--             DECODE (c.LL_SHAPE_LABEL_SYMBOL_ID,
	--                     20026, 30418,
	--                     20027, 30419,
	--                     20028, 30420,
	--                     30421)
	--                AS TO_TRAJECTORY_ID,
	DECODE(c.LL_SHAPE_LABEL_SYMBOL_ID, 20026, 'change', 20027, 'increase', 20028, 'decrease', 'no trajectory') AS TO_TRAJECTORY
	--,d.CITATION_ID
FROM ICD_SHAPE_LINKAGE a
	,ICD_SHAPE b
	,ICD_SHAPE c
	,ICD_LINKAGE_CITATION_JOIN d
	,V_ICD_LK_LEGEND_FILTER f
	,V_ICD_LK_LEGEND_FILTER g
WHERE a.SHAPE_FROM_ID = b.SHAPE_ID
	AND a.SHAPE_TO_ID = c.SHAPE_ID
	AND a.SHAPE_LINKAGE_ID = d.SHAPE_LINKAGE_ID
	AND EXISTS (
		SELECT 1
		FROM ICD_DIAGRAM_SHAPE_JOIN e
		WHERE (
				b.SHAPE_ID = e.SHAPE_ID
				OR c.SHAPE_ID = e.SHAPE_ID
				)
			AND e.DIAGRAM_ID IN (
				599
				,723
				)
		)
	AND b.LL_LEGEND_FILTER_ID < c.LL_LEGEND_FILTER_ID
	AND b.LL_LEGEND_FILTER_ID = f.LL_ID
	AND c.LL_LEGEND_FILTER_ID = g.LL_ID
	AND b.LL_LEGEND_FILTER_ID <= 20009
	AND c.LL_LEGEND_FILTER_ID <= 20009
	ORDER BY 1
	
	
-- this query returns the cause effect pair where cause and effect have the same legend filter	
/*
Source -> Source
Stressor -> Stressor
Human Activity -> Human Activity
Biological Response -> Biological Response
Only apply to diagrams 'composite ICD' (599) and 'flow example_NABS' (723)
*/
SELECT DISTINCT
	--a.SHAPE_LINKAGE_ID,
	b.SHAPE_LABEL AS FR_SHAPE_LABEL
	,
	--b.SHAPE_ID AS FR_SHAPE_ID,
	--b.LL_LEGEND_FILTER_ID AS FR_LEGEND_FILTER_ID,
	f.LIST_ITEM_CODE AS FR_LEGEND_FILTER
	,
	--             DECODE (b.LL_SHAPE_LABEL_SYMBOL_ID,
	--                     20026, 30418,
	--                     20027, 30419,
	--                     20028, 30420,
	--                     30421) AS FR_TRAJECTORY_ID,
	DECODE(b.LL_SHAPE_LABEL_SYMBOL_ID, 20026, 'change', 20027, 'increase', 20028, 'decrease', 'no trajectory') AS FR_TRAJECTORY
	,c.SHAPE_LABEL AS TO_SHAPE_LABEL
	,
	--c.SHAPE_ID AS TO_SHAPE_ID,
	--c.LL_LEGEND_FILTER_ID AS TO_LEGEND_FILTER_ID,
	g.LIST_ITEM_CODE AS TO_LEGEND_FILTER
	,
	--             DECODE (c.LL_SHAPE_LABEL_SYMBOL_ID,
	--                     20026, 30418,
	--                     20027, 30419,
	--                     20028, 30420,
	--                     30421)
	--                AS TO_TRAJECTORY_ID,
	DECODE(c.LL_SHAPE_LABEL_SYMBOL_ID, 20026, 'change', 20027, 'increase', 20028, 'decrease', 'no trajectory') AS TO_TRAJECTORY
	,d.CITATION_ID
FROM ICD_SHAPE_LINKAGE a
	,ICD_SHAPE b
	,ICD_SHAPE c
	,ICD_LINKAGE_CITATION_JOIN d
	,V_ICD_LK_LEGEND_FILTER f
	,V_ICD_LK_LEGEND_FILTER g
WHERE a.SHAPE_FROM_ID = b.SHAPE_ID
	AND a.SHAPE_TO_ID = c.SHAPE_ID
	AND a.SHAPE_LINKAGE_ID = d.SHAPE_LINKAGE_ID
	AND EXISTS (
		SELECT 1
		FROM ICD_DIAGRAM_SHAPE_JOIN e
		WHERE (
				b.SHAPE_ID = e.SHAPE_ID
				OR c.SHAPE_ID = e.SHAPE_ID
				)
			AND e.DIAGRAM_ID IN (
				599
				,723
				)
		)
	AND b.LL_LEGEND_FILTER_ID < c.LL_LEGEND_FILTER_ID
	AND b.LL_LEGEND_FILTER_ID = f.LL_ID
	AND c.LL_LEGEND_FILTER_ID = g.LL_ID
	AND b.LL_LEGEND_FILTER_ID <= 20009
	AND c.LL_LEGEND_FILTER_ID <= 20009
	ORDER BY 1

