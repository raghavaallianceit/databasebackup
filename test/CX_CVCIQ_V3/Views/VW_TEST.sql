CREATE OR REPLACE FORCE VIEW cx_cvciq_v3.vw_test ("ID",request_id,start_time,entry_date,end_time,time_from,time_to) AS
SELECT rownum AS ID, Q1.REQUEST_ID , Q1.START_TIME,Q1.ENTRY_DATE,Q2.END_TIME ,
To_timestamp ( concat ( to_char(Q1.ENTRY_DATE, 'dd-mm-yyyy'),  Q1.START_TIME), 'dd-mm-yyyy HH24:MI:SS') TIME_FROM  ,
To_timestamp ( concat ( to_char(Q1.ENTRY_DATE, 'dd-mm-yyyy'),  Q2.END_TIME), 'dd-mm-yyyy HH24:MI:SS') TIME_TO  
FROM
( select A.REQUEST_ID, TO_CHAR( min(time_from), ' HH24:MI:SS') AS START_TIME, entry_date from cx_cvc.CVC_AGENDA A  WHERE  ENTRY_TYPE IN ('START_MARK') group by entry_date,request_id ) Q1,
( select A.REQUEST_ID,  TO_CHAR( MAX(time_from),' HH24:MI:SS') AS END_TIME,ENtry_date From cx_cvc.CVC_AGENDA A WHERE ENTRY_TYPE IN ('END_MARK') group by entry_date,request_id ) Q2
WHERE Q1.REQUEST_ID = Q2.REQUEST_ID
AND Q1.ENTRY_DATE = Q2.ENTRY_DATE;