CREATE OR REPLACE VIEW V_DIAGRAM_EVIDENCES AS
SELECT distinct S.DIAGRAM_ID,
            S.SHAPE_FROM_LABEL,
            S.SHAPE_FROM_ID,
            S.SHAPE_TO_ID,
            S.SHAPE_TO_LABEL,
            E.SOURCE_DATA,
            E.HABITAT,
            E.STUDY_TYPE,
            E.CREATE_USER,
            P.AUTHOR,
            P.YEAR,
            P.TITLE, 
            S.CITATION_ID,
            S.DATASET_ID,
            S.IS_EFFECTRELATIONSHIP,
            S.SHAPE_FROM_LABEL_SYMBOL,
            S.SHAPE_TO_LABEL_SYMBOL,
            S.SHAPE_FROM_BIN_INDEX,
            E.CAUSE_TERM,
            E.CAUSE_TRAJECTORY,
            E.EFFECT_TERM,
            E.EFFECT_TRAJECTORY,
            S.DIAGRAM_NAME,
            E.CAUSE_EFFECT_ID
FROM V_EVIDENCE  E, 
         V_ICD_SHAPE_LINKAGES  S,
         P_CITATION P
WHERE S.CITATION_ID = E.CITATION_ID(+) 
     AND P.CITATION_ID = S.CITATION_ID
     AND S.DATASET_ID = E.DATASET_ID(+)
     AND (S.IS_EFFECTRELATIONSHIP IS NULL OR S.IS_EFFECTRELATIONSHIP = 'N' ) 
ORDER BY S.DIAGRAM_ID, S.SHAPE_FROM_BIN_INDEX, S.CITATION_ID, S.DATASET_ID