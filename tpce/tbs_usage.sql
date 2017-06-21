REM LOCATION:   Object Management\Tablespaces and DataFiles\Reports
REM FUNCTION:   Generate a report of Tablespace Space Availability
REM             including autoextend related space availability.
REM
REM TESTED ON:  10.2.0.3 and 11.1.0.6
REM PLATFORM:   non-specific
REM REQUIRES:   dba_tablespaces, dba_data_files
REM
REM  This is a part of the Knowledge Xpert for Oracle Administration library.
REM  Copyright (C) 2008 Quest Software
REM  All rights reserved.
REM
REM ******************** Knowledge Xpert for Oracle Administration ********************
SET lines 132 pages 66 feedback off
COLUMN tablespace_name        format a15             heading 'Tablespace|(TBS)|Name'
COLUMN autoextensible         format a6              heading 'Can|Auto|Extend'
COLUMN files_in_tablespace    format 999             heading 'Files|In|TBS'
COLUMN total_tablespace_space format 999,999,999,999 heading 'Total|Current|TBS|Space'
COLUMN total_used_space       format 999,999,999,999 heading 'Total|Current|Used|Space'
COLUMN total_tablespace_free_space format 999,999,999,999 heading 'Total|Current|Free|Space'
COLUMN total_used_pct              format 999.99      heading 'Total|Current|Used|PCT'
COLUMN total_free_pct              format 999.99      heading 'Total|Current|Free|PCT'
COLUMN max_size_of_tablespace      format 999,999,999,999 heading 'TBS|Max|Size'
COLUMN total_auto_used_pct         format 999.99      heading 'Total|Max|Used|PCT'
COLUMN total_auto_free_pct         format 999.99      heading 'Total|Max|Free|PCT'

TTITLE left _date center Tablespace Space Utilization Status Report skip 2

WITH tbs_auto AS
     (SELECT DISTINCT tablespace_name, autoextensible
                 FROM dba_data_files
                WHERE autoextensible = 'YES'),
     files AS
     (SELECT   tablespace_name, COUNT (*) tbs_files,
               SUM (BYTES) total_tbs_bytes
          FROM dba_data_files
      GROUP BY tablespace_name),
     fragments AS
     (SELECT   tablespace_name, COUNT (*) tbs_fragments,
               SUM (BYTES) total_tbs_free_bytes,
               MAX (BYTES) max_free_chunk_bytes
          FROM dba_free_space
      GROUP BY tablespace_name),
     AUTOEXTEND AS
     (SELECT   tablespace_name, SUM (size_to_grow) total_growth_tbs
          FROM (SELECT   tablespace_name, SUM (maxbytes) size_to_grow
                    FROM dba_data_files
                   WHERE autoextensible = 'YES'
                GROUP BY tablespace_name
                UNION
                SELECT   tablespace_name, SUM (BYTES) size_to_grow
                    FROM dba_data_files
                   WHERE autoextensible = 'NO'
                GROUP BY tablespace_name)
      GROUP BY tablespace_name)
SELECT a.tablespace_name,
       CASE tbs_auto.autoextensible
          WHEN 'YES'
             THEN 'YES'
          ELSE 'NO'
       END AS autoextensible,
       files.tbs_files files_in_tablespace,
       files.total_tbs_bytes total_tablespace_space,
       (files.total_tbs_bytes - fragments.total_tbs_free_bytes
       ) total_used_space,
       fragments.total_tbs_free_bytes total_tablespace_free_space,
       (  (  (files.total_tbs_bytes - fragments.total_tbs_free_bytes)
           / files.total_tbs_bytes
          )
        * 100
       ) total_used_pct,
       ((fragments.total_tbs_free_bytes / files.total_tbs_bytes) * 100
       ) total_free_pct,
       AUTOEXTEND.total_growth_tbs max_size_of_tablespace,
       (  (  (  AUTOEXTEND.total_growth_tbs
              - (AUTOEXTEND.total_growth_tbs - fragments.total_tbs_free_bytes
                )
             )
           / AUTOEXTEND.total_growth_tbs
          )
        * 100
       ) total_auto_used_pct,
       (  (  (AUTOEXTEND.total_growth_tbs - fragments.total_tbs_free_bytes)
           / AUTOEXTEND.total_growth_tbs
          )
        * 100
       ) total_auto_free_pct
  FROM dba_tablespaces a, files, fragments, AUTOEXTEND, tbs_auto
 WHERE a.tablespace_name = files.tablespace_name
   AND a.tablespace_name = fragments.tablespace_name
   AND a.tablespace_name = AUTOEXTEND.tablespace_name
   AND a.tablespace_name = tbs_auto.tablespace_name(+);


