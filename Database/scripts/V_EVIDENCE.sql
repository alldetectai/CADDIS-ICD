--DROP VIEW V_EVIDENCE;

CREATE VIEW V_EVIDENCE AS

SELECT DISTINCT D.CITATION_ID, 
            D.DATASET_ID, 
            S.STANDARD_TERM AS CAUSE_TERM,
            GET_ITEM_CODE(C.LL_CAUSE_TRAJECTORY_ID) AS CAUSE_TRAJECTORY,
            S2.STANDARD_TERM AS EFFECT_TERM,
            GET_ITEM_CODE(C.LL_EFFECT_TRAJECTORY_ID) AS EFFECT_TRAJECTORY,
            GET_ITEM_CODE(D.LL_HABITAT_ID) AS HABITAT,
            GET_ITEM_CODE(D.LL_SOURCE_DATA_ID) AS SOURCE_DATA,
            GET_ITEM_CODE(D.LL_STUDY_TYPE_ID) AS STUDY_TYPE
            
  FROM K_DATASET D,  
           P_STANDARD_TERM s,
           P_STANDARD_TERM s2,
           K_CAUSE_EFFECT C
     WHERE D.DATASET_ID = C.DATASET_ID
          AND C.CAUSE_ID = S.STANDARD_TERM_ID 
          AND C.EFFECT_ID = S2.STANDARD_TERM_ID
ORDER BY CITATION_ID