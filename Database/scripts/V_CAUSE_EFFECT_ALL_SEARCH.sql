CREATE OR REPLACE VIEW CADDIS_DEV.V_CAUSE_EFFECT_ALL_SEARCH
(CAUSE_EFFECT_LINKAGE_ID, CITATION_ID, CAUSE_ID, CAUSE_TERM, EFFECT_ID, 
 EFFECT_TERM, LL_CAUSE_TRAJECTORY_ID, LL_EFFECT_TRAJECTORY_ID, LL_PUBLICATION_TYPE_ID, PUBLICATION_TYPE, 
 AUTHOR, YEAR, START_PAGE, END_PAGE, VOLUME, 
 ISSUE, ABSTRACT, DOI, TITLE, KEYWORD, 
 JOURNAL, VOLUME_ISSUE_PAGES, IS_APPROVED, CITATION_URL, BOOK, 
 EDITORS, PUBLISHERS, REPORT_NUMBER, PAGES, SOURCE, 
 TYPE)
AS 
SELECT CAUSE_EFFECT_LINKAGE_ID,
          ce.CITATION_ID,
          CAUSE_ID,
          S.STANDARD_TERM CAUSE_TERM,
          EFFECT_ID,
          S2.STANDARD_TERM EFFECT_TERM,
          LL_CAUSE_TRAJECTORY_ID,
          LL_EFFECT_TRAJECTORY_ID,
          LL_PUBLICATION_TYPE_ID,
          (SELECT list_item_code
             FROM p_list_item lk
            WHERE c.ll_publication_type_id = lk.ll_id)
             AS publication_type,
          AUTHOR,
          YEAR,
          START_PAGE,
          END_PAGE,
          VOLUME,
          ISSUE,
          ABSTRACT,
          DOI,
          TITLE,
          KEYWORD,
          (SELECT list_item_code
             FROM p_list_item lk
            WHERE c.ll_publication_id = lk.ll_id(+))
             AS journal,
             NVL2 (c.volume, c.volume, '')
          || NVL2 (c.issue, '(' || c.issue || '):', NVL2 (c.volume, ':', ''))
          || NVL2 (c.start_page, c.start_page, '')
          || NVL2 (c.end_page, '-' || c.end_page, '')
             AS VOLUME_ISSUE_PAGES,
          C.IS_APPROVED,
          CITATION_URL,
          BOOK,
          EDITORS,
          PUBLISHERS,
          REPORT_NUMBER,
          PAGES,
          SOURCE,
          TYPE
     FROM P_CAUSE_EFFECT_LINKAGE ce,
          P_STANDARD_TERM s,
          P_STANDARD_TERM s2,
          P_CITATION c
    WHERE     ce.CAUSE_ID = s.STANDARD_TERM_ID
          AND CE.EFFECT_ID = s2.STANDARD_TERM_ID
          AND CE.CITATION_ID = C.CITATION_ID;