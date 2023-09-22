DROP MATERIALIZED VIEW CADDIS_DEV.MV_CITATION_DOWNLOAD;
CREATE MATERIALIZED VIEW CADDIS_DEV.MV_CITATION_DOWNLOAD 
TABLESPACE CADDIS_DATA
PCTUSED    0
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
/* Formatted on 3/1/2016 3:05:25 PM (QP5 v5.149.1003.31008) */
SELECT A.CITATION_ID,
       A.AUTHOR,
       A.YEAR,
       A.TITLE,
       A.SOURCE,
       A.VOLUME,
       A.PAGES,
       A.ABSTRACT,
       --DBMS_LOB.SUBSTR (A.ABSTRACT) AS abstract,
       A.KEYWORD,
       get_study_type (a.CITATION_ID) AS "STUDY_TYPE",
       get_location_state (a.CITATION_ID) AS LOC_STATE,
       get_location_ecoregion (a.CITATION_ID) AS LOC_ECOREGION,
       get_location_huc (a.CITATION_ID) AS LOC_HUC,
       get_location_country (a.CITATION_ID) AS LOC_COUNTRY,
       CE.CAUSE_ID,
       st1.standard_term AS cause_term,
       CE.EFFECT_ID,
       st2.standard_term AS effect_term,
       pl.list_item_code AS organism,
       cm.measurement_method AS cause_ms_method,
       EM.MEASUREMENT_METHOD AS effect_ms_method,
       PL2.LIST_ITEM_CODE AS cause_trajectory,
       pl5.list_item_code AS cause_measure,
       pl3.list_item_code AS effect_trajectory,
       pl6.list_item_code AS effect_measure,
       CDES.CLASS_DESCRIPTOR,
       CD.CAUSE_MAX,
       CD.CAUSE_MEAN,
       CD.CAUSE_MIN,
       CD.CAUSE_STANDARD_DEV AS cause_stdv,
       CD.EFFECT_MAX,
       CD.EFFECT_MEAN,
       CD.EFFECT_MIN,
       CD.EFFECT_STANDARD_DEV AS effect_stdv,
       PL4.LIST_ITEM_CODE AS si_sig,
       AD.P_LEVEL AS analysis_p_level
  FROM p_citation a,
       p_dataset d,
       p_cause_effect ce,
       p_standard_term st1,
       p_standard_term st2,
       p_list_item pl,
       p_list_item pl2,
       p_list_item pl3,
       p_cause_measured cm,
       p_effect_measured em,
       p_class_details cd,
       p_class_descriptor cdes,
       p_si_significants ss,
       p_list_item pl4,
       p_analysis_details ad,
       p_list_item pl5,
       p_list_item pl6
 WHERE     d.citation_id(+) = a.citation_id
       AND CE.DATASET_ID(+) = d.dataset_id
       AND st1.standard_term_id(+) = ce.cause_id
       AND st2.standard_term_id(+) = ce.effect_id
       AND pl.ll_id(+) = ce.ll_organism_id
       AND cm.cause_effect_id(+) = ce.cause_effect_id
       AND EM.EFFECT_MEASURED_ID(+) = ce.cause_effect_id
       AND pl2.ll_id(+) = ce.ll_cause_trajectory_id
       AND pl3.ll_id(+) = ce.ll_effect_trajectory_id
       AND pl5.ll_id(+) = CE.LL_CAUSE_MEASURED_ID
       AND pl6.ll_id(+) = ce.ll_effect_measured_id
       AND cd.cause_effect_id(+) = ce.cause_effect_id
       AND CDES.CLASS_DESCRIPTOR_ID(+) = CD.CLASS_DESCRIPTOR_ID
       AND SS.CAUSE_EFFECT_ID(+) = ce.cause_effect_id
       AND pl4.ll_id(+) = SS.LL_SI_SIG_ID
       AND ad.cause_effect_id(+) = ce.cause_effect_id;

COMMENT ON MATERIALIZED VIEW CADDIS_DEV.MV_CITATION_DOWNLOAD IS 'SNAPSHOT TABLE FOR SNAPSHOT CADDIS_DEV.MV_CITATION_DOWNLOAD';

