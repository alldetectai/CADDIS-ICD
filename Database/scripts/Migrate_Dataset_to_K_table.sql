/* Formatted on 7/14/2015 11:57:55 AM (QP5 v5.149.1003.31008) */

-- this procedure migrate the records in P_DATASET table into K_DATASET table
CREATE OR REPLACE PROCEDURE MIGRATION_K_TABLES
IS
   n_source_data_ll_id   NUMBER (11) := 0;
   n_study_type_ll_id    NUMBER (11) := 0;
BEGIN
   SELECT LL_ID
     INTO n_source_data_ll_id
     FROM V_SOURCE_DATA
    WHERE LOWER (LIST_ITEM_CODE) = 'not available';

   SELECT LL_ID
     INTO n_study_type_ll_id
     FROM V_STUDY_TYPE
    WHERE LOWER (LIST_ITEM_CODE) = 'not available';

   -- migrate all the records from P_DATA_SET into K_DATA_SET
   INSERT INTO K_DATASET (DATASET_ID,
                          CITATION_ID,
                          LL_SOURCE_DATA_ID,
                          LL_STUDY_TYPE_ID,
                          LL_STUDY_DESIGN_ID,
                          LL_SAMPLE_SELECTION_ID,
                          STUDYDETAILS,
                          CONTROL_SAMPLES,
                          CONTROL_REPLICATES,
                          IMPACT_SAMPLE,
                          IMPACT_REPLICATES,
                          MIN_LATITUDE,
                          MAX_LATITUDE,
                          MIN_LONG,
                          MAX_LONG,
                          MAX_ELEVATION,
                          MIN_ELEVATION,
                          LL_ELEVATION_UNIT_ID,
                          GEOMETRY,
                          LL_HABITAT_ID,
                          LL_CLIMATE_ID,
                          LL_SPATIAL_EXTENT_ID,
                          LL_TEMPORAL_EXTENT_ID,
                          LOCATION_COMMENT,
                          CREATE_DATE,
                          CREATE_USER,
                          UPDATE_DATE,
                          UPDATE_USER)
      SELECT SEQ_K_DATASET_ID.NEXTVAL,
             CITATION_ID,
             CASE
                WHEN LL_SOURCE_DATA_ID IS NULL THEN n_source_data_ll_id
                WHEN LL_SOURCE_DATA_ID = 0 THEN n_source_data_ll_id
                ELSE LL_SOURCE_DATA_ID
             END
                AS SOURCE_DATA_ID,
             CASE
                WHEN LL_STUDY_TYPE_ID IS NULL THEN n_study_type_ll_id
                WHEN LL_STUDY_TYPE_ID = 0 THEN n_study_type_ll_id
                ELSE LL_STUDY_TYPE_ID
             END
                AS STUDY_TYPE_ID,
             LL_STUDY_DESIGN_ID,
             LL_SAMPLE_SELECTION_ID,
             STUDYDETAILS,
             CONTROL_SAMPLES,
             CONTROL_REPLICATES,
             IMPACT_SAMPLE,
             IMPACT_REPLICATES,
             MIN_LATITUDE,
             MAX_LATITUDE,
             MIN_LONG,
             MAX_LONG,
             MAX_ELEVATION,
             MIN_ELEVATION,
             LL_ELEVATION_UNIT_ID,
             GEOMETRY,
             CASE LL_HABITAT_ID WHEN 0 THEN NULL ELSE LL_HABITAT_ID END,
             LL_CLIMATE_ID,
             LL_SPATIAL_EXTENT_ID,
             LL_TEMPORAL_EXTENT_ID,
             LOCATION_COMMENT,
             CREATE_DATE,
             CREATE_USER,
             UPDATE_DATE,
             UPDATE_USER
        FROM P_DATASET;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (SQLERRM);
END MIGRATION_K_TABLES;

-- This procedure creates a default dataset for citations with no dataset or more than one dataset
CREATE OR REPLACE PROCEDURE CREATE_DEFAULT_DATASET
IS
   n_source_data_ll_id   NUMBER (11) := 0;
   n_study_type_ll_id    NUMBER (11) := 0;
BEGIN
   SELECT LL_ID
     INTO n_source_data_ll_id
     FROM V_SOURCE_DATA
    WHERE LOWER (LIST_ITEM_CODE) = 'not available';

   SELECT LL_ID
     INTO n_study_type_ll_id
     FROM V_STUDY_TYPE
    WHERE LOWER (LIST_ITEM_CODE) = 'not available';

   INSERT INTO K_DATASET (DATASET_ID,
                          CITATION_ID,
                          LL_SOURCE_DATA_ID,
                          LL_STUDY_TYPE_ID,
                          CREATE_DATE,
                          CREATE_USER)
      SELECT SEQ_K_DATASET_ID.NEXTVAL,
             CITATION_ID,
             n_source_data_ll_id,
             n_study_type_ll_id,
             SYSDATE,
             'SYSTEM'
        FROM (SELECT CITATION_ID
                FROM P_CITATION a
               WHERE NOT EXISTS
                        (SELECT 1
                           FROM K_DATASET b
                          WHERE a.CITATION_ID = b.CITATION_ID)
              UNION
              SELECT CITATION_ID
                FROM P_CITATION a
               WHERE EXISTS
                        (  SELECT 1
                             FROM K_DATASET b
                            WHERE a.CITATION_ID = b.CITATION_ID
                         GROUP BY CITATION_ID
                           HAVING COUNT (1) > 1));
END CREATE_DEFAULT_DATASET;

/* To Synch the SEQUENCE for STANDARD_TERM_ID */
/*
SELECT MAX (STANDARD_TERM_ID) FROM P_STANDARD_TERM;

ALTER SEQUENCE SEQ_STANDARD_TERM_ID INCREMENT BY 178;

SELECT SEQ_STANDARD_TERM_ID.NEXTVAL FROM DUAL;

ALTER SEQUENCE SEQ_STANDARD_TERM_ID INCREMENT BY 1;
*/

/* This procedure migrate shape labels of the from-to pairs in ICD_SHAPE_LINKAGE as standard terms */
CREATE OR REPLACE PROCEDURE CREATE_STANDARD_TERMS
IS
BEGIN
   INSERT INTO P_STANDARD_TERM (STANDARD_TERM_ID,
                                STANDARD_TERM,
                                IS_EEL_TERM,
                                STANDARD_TERM_DESC,
                                CREATE_DATE,
                                CREATE_USER)
      SELECT SEQ_STANDARD_TERM_ID.NEXTVAL,
             TRIM (SHAPE_LABEL),
             'N',
             TRIM (SHAPE_LABEL),
             SYSDATE,
             'SYSTEM'
        FROM (SELECT DISTINCT b.SHAPE_LABEL
                FROM ICD_SHAPE_LINKAGE a,
                     ICD_SHAPE b,
                     ICD_LINKAGE_CITATION_JOIN d
               WHERE a.SHAPE_FROM_ID = b.SHAPE_ID
                     AND a.SHAPE_LINKAGE_ID = d.SHAPE_LINKAGE_ID
                     AND NOT EXISTS
                                (SELECT 1
                                   FROM P_STANDARD_TERM x
                                  WHERE LOWER (TRIM (b.SHAPE_LABEL)) =
                                           LOWER (TRIM (x.STANDARD_TERM))));

   INSERT INTO P_STANDARD_TERM (STANDARD_TERM_ID,
                                STANDARD_TERM,
                                IS_EEL_TERM,
                                STANDARD_TERM_DESC,
                                CREATE_DATE,
                                CREATE_USER)
      SELECT SEQ_STANDARD_TERM_ID.NEXTVAL,
             TRIM (SHAPE_LABEL),
             'N',
             TRIM (SHAPE_LABEL),
             SYSDATE,
             'SYSTEM'
        FROM (SELECT DISTINCT c.SHAPE_LABEL
                FROM ICD_SHAPE_LINKAGE a,
                     ICD_SHAPE c,
                     ICD_LINKAGE_CITATION_JOIN d
               WHERE a.SHAPE_TO_ID = c.SHAPE_ID
                     AND a.SHAPE_LINKAGE_ID = d.SHAPE_LINKAGE_ID
                     AND NOT EXISTS
                                (SELECT 1
                                   FROM P_STANDARD_TERM x
                                  WHERE LOWER (TRIM (c.SHAPE_LABEL)) =
                                           LOWER (TRIM (x.STANDARD_TERM))));
END CREATE_STANDARD_TERMS;

-- thsi procedure migrates the ICD cause effect into K_CAUSE_EFFECT table 
CREATE OR REPLACE PROCEDURE MIGRATE_ICD_CAUSE_EFFECT
IS
   n_dataset_id            NUMBER (11) := 0;
   n_fr_standard_term_id   NUMBER (12) := 0;
   n_to_standard_term_id   NUMBER (12) := 0;

   TYPE rec_cursor IS RECORD
   (
      --SHAPE_LINKAGE_ID   NUMBER (12),
      --FR_SHAPE_ID        NUMBER (12),
      FR_SHAPE_LABEL     VARCHAR2 (50),
      FR_TRAJECTORY_ID   NUMBER (11),
      --TO_SHAPE_ID        NUMBER (12),
      TO_SHAPE_LABEL     VARCHAR2 (50),
      TO_TRAJECTORY_ID   NUMBER (11),
      CITATION_ID        NUMBER (11)
   );

   TYPE tbl_rec_cursor IS TABLE OF rec_cursor;

   t_rec_cursor            tbl_rec_cursor := tbl_rec_cursor ();

   CURSOR c_linkage_list
   IS
      SELECT DISTINCT
			 --a.SHAPE_LINKAGE_ID,
             --b.SHAPE_ID AS FR_SHAPE_ID,
             b.SHAPE_LABEL AS FR_SHAPE_LABEL,
             DECODE (b.LL_SHAPE_LABEL_SYMBOL_ID,
                     20026, 30418,
                     20027, 30419,
                     20028, 30420,
                     30421)
                AS FR_TRAJECTORY_ID,
             --c.SHAPE_ID AS TO_SHAPE_ID,
             c.SHAPE_LABEL AS TO_SHAPE_LABEL,
             DECODE (c.LL_SHAPE_LABEL_SYMBOL_ID,
                     20026, 30418,
                     20027, 30419,
                     20028, 30420,
                     30421)
                AS TO_TRAJECTORY_ID,
             d.CITATION_ID
        FROM ICD_SHAPE_LINKAGE a,
             ICD_SHAPE b,
             ICD_SHAPE c,
             ICD_LINKAGE_CITATION_JOIN d
       WHERE     a.SHAPE_FROM_ID = b.SHAPE_ID
             AND a.SHAPE_TO_ID = c.SHAPE_ID
             AND a.SHAPE_LINKAGE_ID = d.SHAPE_LINKAGE_ID;
BEGIN
   OPEN c_linkage_list;

   FETCH c_linkage_list
   BULK COLLECT INTO t_rec_cursor;

   CLOSE c_linkage_list;

   DBMS_OUTPUT.put_line ('Total Count: ' || t_rec_cursor.COUNT);

   IF t_rec_cursor.COUNT > 0
   THEN
      FOR c IN t_rec_cursor.FIRST .. t_rec_cursor.LAST
      LOOP
         --DBMS_OUTPUT.put_line ('SHAPE_LINKAGE_ID: ' || t_rec_cursor(c).SHAPE_LINKAGE_ID);
         SELECT MAX (STANDARD_TERM_ID)
           INTO n_fr_standard_term_id
           FROM P_STANDARD_TERM
          WHERE LOWER (TRIM (STANDARD_TERM)) =
                   LOWER (TRIM (t_rec_cursor (c).FR_SHAPE_LABEL));

         SELECT MAX (STANDARD_TERM_ID)
           INTO n_to_standard_term_id
           FROM P_STANDARD_TERM
          WHERE LOWER (TRIM (STANDARD_TERM)) =
                   LOWER (TRIM (t_rec_cursor (c).TO_SHAPE_LABEL));

         SELECT MAX (DATASET_ID)
           INTO n_dataset_id
           FROM K_DATASET
          WHERE CITATION_ID = t_rec_cursor (c).CITATION_ID;

         /*
         IF n_fr_standard_term_id IS NULL THEN
           DBMS_OUTPUT.put_line ('SHAPE_LINKAGE_ID: ' || t_rec_cursor(c).SHAPE_LINKAGE_ID);
           DBMS_OUTPUT.put_line ('NULL n_fr_standard_term_id: ' || t_rec_cursor(c).FR_SHAPE_LABEL);
         END IF;

         IF n_to_standard_term_id IS NULL THEN
           DBMS_OUTPUT.put_line ('SHAPE_LINKAGE_ID: ' || t_rec_cursor(c).SHAPE_LINKAGE_ID);
           DBMS_OUTPUT.put_line ('NULL n_to_standard_term_id: ' || t_rec_cursor(c).TO_SHAPE_LABEL);
         END IF;

         IF n_dataset_id IS NULL THEN
           DBMS_OUTPUT.put_line ('SHAPE_LINKAGE_ID: ' || t_rec_cursor(c).SHAPE_LINKAGE_ID);
           DBMS_OUTPUT.put_line ('NULL n_dataset_id --> CITATION_ID: ' || t_rec_cursor(c).CITATION_ID);
         END IF;
         */

         INSERT INTO K_CAUSE_EFFECT (CAUSE_EFFECT_ID,
                                     EFFECT_ID,
                                     CAUSE_ID,
                                     LL_CAUSE_TRAJECTORY_ID,
                                     LL_EFFECT_TRAJECTORY_ID,
                                     CREATE_DATE,
                                     CREATE_USER,
                                     DATASET_ID)
              VALUES (SEQ_K_CAUSE_EFFECT_ID.NEXTVAL,
                      n_to_standard_term_id,
                      n_fr_standard_term_id,
                      t_rec_cursor (c).FR_TRAJECTORY_ID,
                      t_rec_cursor (c).TO_TRAJECTORY_ID,
                      SYSDATE,
                      'SYSTEM',
                      n_dataset_id);
      END LOOP;
   END IF;
END MIGRATE_ICD_CAUSE_EFFECT;