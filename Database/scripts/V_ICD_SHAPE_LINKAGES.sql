DROP VIEW CADDIS_DEV.V_ICD_SHAPE_LINKAGES;

/* Formatted on 3/14/2016 1:19:18 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW CADDIS_DEV.V_ICD_SHAPE_LINKAGES
(
   DIAGRAM_ID,
   DIAGRAM_NAME,
   LL_DIAGRAM_STATUS_ID,
   CREATED_BY,
   SHAPE_FROM_BIN_INDEX,
   SHAPE_FROM_LABEL,
   SHAPE_FROM_ID,
   SHAPE_FROM_LABEL_SYMBOL,
   SHAPE_TO_LABEL,
   SHAPE_TO_LABEL_SYMBOL,
   SHAPE_TO_ID,
   SHAPE_LINKAGE_ID,
   CITATION_ID,
   CAUSE_EFFECT_ID,
   DATASET_ID,
   IS_EFFECTRELATIONSHIP
)
AS
   SELECT D.DIAGRAM_ID AS DIAGRAM_ID,
          d.diagram_name AS diagram_name,
          d.ll_diagram_status_id AS ll_diagram_status_id,
          d.created_by AS created_by,
          s.shape_bin_index AS shape_from_bin_index,
          s.shape_label AS shape_from_label,
          sl.shape_from_id,
          s.ll_shape_label_symbol_id AS SHAPE_FROM_LABEL_SYMBOL,
          (SELECT s1.shape_label
             FROM icd_shape s1
            WHERE s1.shape_id = sl.shape_to_id)
             AS shape_to_label,
          (SELECT s1.ll_shape_label_symbol_id
             FROM icd_shape s1
            WHERE s1.shape_id = sl.shape_to_id)
             AS shape_to_label_symbol,
          sl.shape_to_id AS shape_to_id,
          sl.shape_linkage_id AS shape_linkage_id,
          lcj.citation_id AS citation_id,
          lcj.cause_effect_id AS cause_effect_id,
          KC.DATASET_ID AS DATASET_ID,
          lcj.IS_EFFECTRELATIONSHIP AS IS_EFFECTRELATIONSHIP
     FROM icd_diagram_shape_join dsj,
          icd_shape s,
          --    ICD_SHAPE_ATTRIBUTE a,
          icd_shape_linkage sl,
          icd_linkage_citation_join lcj,
          icd_diagram d,
          k_cause_effect kc
    WHERE     d.diagram_id = dsj.diagram_id
          AND dsj.shape_id = s.shape_id
          AND dsj.shape_id = sl.shape_from_id
          AND sl.shape_linkage_id = lcj.shape_linkage_id(+)
          AND lcj.cause_effect_id = kc.cause_effect_id(+);
