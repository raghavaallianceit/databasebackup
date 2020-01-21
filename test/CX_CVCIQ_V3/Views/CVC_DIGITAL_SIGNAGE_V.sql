CREATE OR REPLACE FORCE VIEW cx_cvciq_v3.cvc_digital_signage_v (event_date,request_id,meeting_organizer,topic,presenter,meeting_name,entry_date,start_date,"LOCATION",room,entry_type,time_from,time_to,location_id,room_id,digital_sign,hq_building,hide_room,display_name) AS
SELECT a.event_date,
       r.id "REQUEST_ID",
      (SELECT user_name from bi_user d where id = r.requestor )"MEETING_ORGANIZER",
       CASE 
        WHEN b.OPTIONAL_TOPIC is not null 
        THEN b.OPTIONAL_TOPIC else b.TOPIC 
        END "TOPIC",
      (SELECT listagg (first_name||''||last_name||','||designation,',') within group (order by first_name) FROM bi_request_presenter where bi_request_topic_activity_id = b.id  )"PRESENTER",
       r.customer_name "MEETING_NAME",
       TO_DATE (TO_CHAR (a.event_date, 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS')  "ENTRY_DATE",
       TO_DATE (TO_CHAR (r.start_date, 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS')   "START_DATE",
      '-Redwood Shores - HQ' "LOCATION",
       l.name   "ROOM",
       CASE 
        WHEN b.OPTIONAL_TOPIC is not null 
        THEN b.OPTIONAL_TOPIC else b.TOPIC 
        END "ENTRY_TYPE",
       CASE
        WHEN (b.activity_start_time >= TO_TIMESTAMP(NEXT_DAY(TRUNC(TO_DATE(TO_CHAR( EXTRACT(YEAR FROM b.activity_start_time)||'/03/01'), 'YYYY/MM/DD'),'MM')-1,'Sunday')+7,'DD-MM-YY HH24:MI:SS.FF')
         AND  b.activity_start_time <= TO_TIMESTAMP(NEXT_DAY(TRUNC(TO_DATE(TO_CHAR( EXTRACT(YEAR FROM b.activity_start_time)||'/11/01'), 'YYYY/MM/DD'),'MM')-1,'Sunday'),'DD-MM-YY HH24:MI:SS.FF'))
        THEN TO_CHAR(NEW_TIME (b.activity_start_time + interval '1' hour , 'GMT',(select bl.LOCATION_TIMEZONE_DB from bi_location bl where bl.id = l.parent_id)),'DD-Mon-YY HH12:MI:SS AM')    
       ELSE
            TO_CHAR(NEW_TIME (b.activity_start_time, 'GMT',(select bl.LOCATION_TIMEZONE_DB from bi_location bl where bl.id = l.parent_id)),'DD-Mon-YY HH12:MI:SS AM')  
       END TIME_FROM ,
      CASE
       WHEN (b.activity_start_time >= TO_TIMESTAMP(NEXT_DAY(TRUNC(TO_DATE(TO_CHAR( EXTRACT(YEAR FROM b.activity_start_time)||'/03/01'), 'YYYY/MM/DD'),'MM')-1,'Sunday')+7,'DD-MM-YY HH24:MI:SS.FF')
        AND  b.activity_start_time <= TO_TIMESTAMP(NEXT_DAY(TRUNC(TO_DATE(TO_CHAR( EXTRACT(YEAR FROM b.activity_start_time)||'/11/01'), 'YYYY/MM/DD'),'MM')-1,'Sunday'),'DD-MM-YY HH24:MI:SS.FF'))
       THEN TO_CHAR(NEW_TIME (b.activity_start_time + interval '1' hour , 'GMT',(select bl1.LOCATION_TIMEZONE_DB from bi_location bl1 where bl1.id = l.parent_id))+ (b.duration*1/1440),'DD-Mon-YY HH12:MI:SS AM')  
       ELSE
         TO_CHAR(NEW_TIME (b.activity_start_time , 'GMT',(select bl1.LOCATION_TIMEZONE_DB from bi_location bl1 where bl1.id = l.parent_id))+ (b.duration*1/1440),'DD-Mon-YY HH12:MI:SS AM')  
       END TIME_TO ,       
       l.parent_id "LOCATION_ID",
       l.id "ROOM_ID",
       r.digital_signage_option "DIGITAL_SIGN",
       DECODE (l.id,(SELECT id  FROM bi_location al WHERE NAME='-Redwood Shores - HQ' ) , DECODE (SUBSTR (l.name, 1, 3), '6OP', '600','500')  )    "HQ_BUILDING",
        'N'  "HIDE_ROOM",
        NULL "DISPLAY_NAME"
   FROM bi_Request r,
        bi_location l,
        bi_request_activity_day  a ,
        bi_request_topic_activity b
  WHERE  r.state = 'CONFIRMED'
        AND r.id = a.request_id
        AND ( a.main_room = l.id OR a.main_room = l.parent_id)
        AND a.id = b.request_activity_day_id;