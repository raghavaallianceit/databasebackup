CREATE OR REPLACE FORCE VIEW cx_cvciq_v3.cvc_downstream_v ("location_id",engagement_id,customer_name,industry,start_time,end_time) AS
SELECT
r.location_id "location_id",
r.unique_id "ENGAGEMENT_ID",
r.customer_name "CUSTOMER_NAME",
(select lv.value from bi_lookup_value lv where lv.code = r.industry and lv.lookup_type_id = (select id from bi_lookup_type lt where lt.code = 'CUSTOMER_INDUSTRY') and lv.location_id = l.id) "INDUSTRY",
CASE
WHEN (a.arrival_ts >= TO_TIMESTAMP(NEXT_DAY(TRUNC(TO_DATE(TO_CHAR( EXTRACT(YEAR FROM a.arrival_ts)||'/03/01'), 'YYYY/MM/DD'),'MM')-1,'Sunday')+7,'DD-MM-YY HH24:MI:SS.FF')
AND a.arrival_ts <= TO_TIMESTAMP(NEXT_DAY(TRUNC(TO_DATE(TO_CHAR( EXTRACT(YEAR FROM a.arrival_ts)||'/11/01'), 'YYYY/MM/DD'),'MM')-1,'Sunday'),'DD-MM-YY HH24:MI:SS.FF'))
THEN TO_CHAR(NEW_TIME (a.arrival_ts + interval '1' hour , 'GMT',(select bl.LOCATION_TIMEZONE_DB from bi_location bl where bl.id = r.location_id)),'DD-Mon-YY HH12:MI:SS AM')
ELSE
TO_CHAR(NEW_TIME (a.arrival_ts, 'GMT',(select bl.LOCATION_TIMEZONE_DB from bi_location bl where bl.id = r.location_id)),'DD-Mon-YY HH12:MI:SS AM')
END START_TIME ,
CASE
WHEN (a.adjourn_ts >= TO_TIMESTAMP(NEXT_DAY(TRUNC(TO_DATE(TO_CHAR( EXTRACT(YEAR FROM a.adjourn_ts)||'/03/01'), 'YYYY/MM/DD'),'MM')-1,'Sunday')+7,'DD-MM-YY HH24:MI:SS.FF')
AND a.adjourn_ts <= TO_TIMESTAMP(NEXT_DAY(TRUNC(TO_DATE(TO_CHAR( EXTRACT(YEAR FROM a.adjourn_ts)||'/11/01'), 'YYYY/MM/DD'),'MM')-1,'Sunday'),'DD-MM-YY HH24:MI:SS.FF'))
THEN TO_CHAR(NEW_TIME (a.adjourn_ts + interval '1' hour , 'GMT',(select bl.LOCATION_TIMEZONE_DB from bi_location bl where bl.id = r.location_id)),'DD-Mon-YY HH12:MI:SS AM')
ELSE
TO_CHAR(NEW_TIME (a.adjourn_ts, 'GMT',(select bl.LOCATION_TIMEZONE_DB from bi_location bl where bl.id = r.location_id)),'DD-Mon-YY HH12:MI:SS AM')
END END_TIME
FROM bi_Request r,
bi_location l,
bi_request_activity_day a
WHERE r.state = 'CONFIRMED'
AND r.id = a.request_id
and r.location_id = l.id
and r.location_id = 4300;