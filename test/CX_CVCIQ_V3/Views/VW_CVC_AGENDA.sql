CREATE OR REPLACE FORCE VIEW cx_cvciq_v3.vw_cvc_agenda ("ID",request_id,entry_date,room_id,created_by,updated_by,time_from,time_to,created_date,updated_date) AS
Select distinct q1.id as ID, q1.request_id,q1.entry_date,q1.room_id ,q1.created_by,q1.updated_by, q1.time_from ,q2.time_to,q2.created_date,q2.updated_date
FROM
(SELECT id, request_id,entry_date,room_id ,created_by,updated_by,created_date,updated_date,
  ( SELECT to_timestamp ( concat ( to_char(entry_date, 'dd-mm-yyyy'), to_char(time_from, ' HH24:MI:SS')), 'dd-mm-yyyy HH24:MI:SS') start_time  FROM cx_cvc.CVC_AGENDA  WHERE id = a.id AND entry_type = 'START_MARK' and request_id = a.request_id) time_from
    
     FROM cx_cvc.CVC_AGENDA   a
    WHERE request_id IN (select id from vw_cvc_request)  
       AND entry_type IN ('START_MARK'  ) 
  ) q1
LEFT JOIN
(SELECT  request_id,entry_date,room_id ,created_by,updated_by,created_date,updated_date,
   ( SELECT to_timestamp ( concat ( to_char(entry_date, 'dd-mm-yyyy'), to_char(time_from, ' HH24:MI:SS')), 'dd-mm-yyyy HH24:MI:SS') start_time FROM cx_cvc.CVC_AGENDA  WHERE id = a.id AND entry_type = 'END_MARK' and request_id = a.request_id) time_to
    FROM cx_cvc.CVC_AGENDA   a
    WHERE request_id IN (select id from vw_cvc_request )  
      AND entry_type IN ( 'END_MARK' )
 ) q2
 ON q1.request_id = q2.request_id and q1.entry_date = q2.entry_date
ORDER BY
  q1.request_id DESC;