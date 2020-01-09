CREATE OR REPLACE PACKAGE BODY cx_cvciq_v3.bi_report_gen_pkg
IS

    FUNCTION fn_timestamp_to_time_dt(in_date IN TIMESTAMP,in_loc_timezone VARCHAR2,in_duration NUMBER)
RETURN VARCHAR2
IS

l_out_time VARCHAR2(50) ;

BEGIN
BEGIN

        IF in_date IS NOT NULL
            THEN
            IF (in_duration > 0)
                    THEN
                        SELECT (TO_CHAR(new_time(in_date + in_duration/1440, 'GMT',(
                        SELECT
                        "A8"."LOCATION_TIMEZONE_DB" "LOCATION_TIMEZONE_DB"
                        FROM
                        "BI_LOCATION" "A8"
                        WHERE
                        "A8"."UNIQUE_ID" = in_loc_timezone
                        )), 'HH:MI AM'))
                        INTO l_out_time 
                        FROM dual; --to excract TIme from given TS
                         DBMS_OUTPUT.PUT_LINE(in_date||' ADD'||l_out_time);
                    END IF; 
                    IF (in_duration <= 0)
                     THEN
                        SELECT (TO_CHAR(new_time(in_date, 'GMT',(
                        SELECT
                        "A8"."LOCATION_TIMEZONE_DB" "LOCATION_TIMEZONE_DB"
                        FROM
                        "UAT_CX_CVCIQ"."BI_LOCATION" "A8"
                        WHERE
                        "A8"."UNIQUE_ID" = in_loc_timezone
                        )), 'HH:MI AM'))
                        INTO l_out_time 
                        FROM dual; 
                -- DBMS_OUTPUT.PUT_LINE(in_date||' SAME'||l_out_time);
                
                     END IF;
DBMS_OUTPUT.PUT_LINE ('bkjbckjbsdckjds'|| in_date ||' in_loc_timezone '|| in_loc_timezone || ' in_duration ' || in_duration);
                END IF; 
                -- DBMS_OUTPUT.PUT_LINE ('bkjbckjbsdckjds'|| in_date ||' in_loc_timezone '|| in_loc_timezone || ' in_duration ' || in_duration);
                EXCEPTION
                WHEN OTHERS
                THEN
                DBMS_OUTPUT.PUT_LINE ('Error getting the Time' || SQLERRM);
                END ;
        RETURN l_out_time;

END fn_timestamp_to_time_dt;

          
          
 PROCEDURE operations_rep   
             (out_chr_err_code   OUT VARCHAR2,
              out_chr_err_msg    OUT VARCHAR2,
              out_oper_rep_tab   OUT return_arr_result   ,
              in_from_date IN date,
              in_to_date IN date,
              in_sort_column IN VARCHAR2,
              in_order_by IN VARCHAR2,
              in_location IN VARCHAR2
             )
IS             

      l_chr_srcstage     VARCHAR2 (200);
      l_chr_biqtab       VARCHAR2 (200);
      l_chr_srctab       VARCHAR2 (200);
      l_chr_bistagtab    VARCHAR2 (200);
      l_chr_err_code     VARCHAR2 (255);
      l_chr_err_msg      VARCHAR2 (255);
      l_out_chr_errbuf   VARCHAR2 (2000);
      lrec               return_oper_report;
      l_num_counter         NUMBER := 0;
      l_start_date date := in_from_date;
      l_end_date date := in_to_date + 1;
      l_sort_column VARCHAR2(30):= in_sort_column;
      l_order_by VARCHAR2(10):=  in_order_by ;
      l_location_id VARCHAR2(256) := in_location ;

CURSOR cur_operations_data IS

        SELECT a.request_activity_day_id requestActivityDayId,
		   a.request_id requestId,
		   a.room room,
		   a.room_type roomType,
           fn_timestamp_to_time_dt(d.ACTIVITY_START_TIME,in_location,0) startTime,
           fn_timestamp_to_time_dt(d.ACTIVITY_START_TIME,in_location,d.duration) endTime,
           c.event_date eventDate,
		   b.customer_name customerName,
		   (SELECT d.user_name
			  FROM bi_user d
			  WHERE d.id = b.Briefing_manager) briefingManager,
		  REPLACE(replace(lower(b.host_name),chr(9),' '),' ','.') ||'@briefingiq.com'  hostName,
		  ( SELECT DISTINCT count(1)
			  FROM BI_REQUEST_ATTENDEES c
			  WHERE c.attendee_type ='internalattendee'
				AND c.request_id = b.id) oracleAttendees,
					  ( SELECT DISTINCT count(1)
			  FROM BI_REQUEST_ATTENDEES c
			  WHERE c.attendee_type ='externalattendee'
				AND c.request_id = b.id) externalAttendees,
				b.no_of_gifts noOfGifts,
				b.gift_type giftType
	   FROM 
            BI_REQUEST_ACT_DAY_ROOM a, 
            BI_REQUEST b ,
            BI_REQUEST_ACTIVITY_DAY c,
            BI_REQUEST_TOPIC_ACTIVITY d
       WHERE
        a.request_id = b.id
        AND c.id = d.REQUEST_ACTIVITY_DAY_ID
        AND c.id = a.REQUEST_ACTIVITY_DAY_ID 
        AND  b.start_date between l_start_date  and l_end_date
        AND b.LOCATION_ID = (select UNIQUE(id) from bi_location where UNIQUE_ID = l_location_id)
        AND ROWNUM<10
        ORDER BY l_sort_column 
;

   TYPE rec_operations_data IS TABLE OF cur_operations_data%ROWTYPE
   INDEX BY PLS_INTEGER;
   l_cur_operations_data   rec_operations_data;  

begin

      OPEN cur_operations_data;

      LOOP      
         FETCH cur_operations_data
         BULK COLLECT INTO l_cur_operations_data
         LIMIT 1000;

         EXIT WHEN l_cur_operations_data.COUNT = 0;

        DBMS_OUTPUT.PUT_LINE ('here in first insert');

        lrec := return_oper_report();
        out_oper_rep_tab  := return_arr_result(return_oper_report());
        out_oper_rep_tab.delete;


				 FOR i IN 1 .. l_cur_operations_data.COUNT
				 LOOP

					---	 dbms_output.put_line('Inside cursor   '  );

							   BEGIN  

									l_num_counter                := l_num_counter + 1;
									lrec                         := return_oper_report();
									lrec.requestActivityDayId := l_cur_operations_data(i).requestActivityDayId ;          
								 	lrec.requestId              := l_cur_operations_data(i).requestId ;
									lrec.room                    := l_cur_operations_data(i).room ;
									lrec.roomType               := l_cur_operations_data(i).roomType ;
									lrec.startTime              := l_cur_operations_data(i).startTime ;
									lrec.endTime                := l_cur_operations_data(i).endTime ;
									lrec.customerName           := l_cur_operations_data(i).customerName ;
									lrec.briefingManager        := l_cur_operations_data(i).briefingManager ;
									lrec.hostName               := l_cur_operations_data(i).hostName ;
									lrec.eventDate               := l_cur_operations_data(i).eventDate ;
									lrec.oracleAttendees        := l_cur_operations_data(i).oracleAttendees ;
									lrec.externalAttendees      := l_cur_operations_data(i).externalAttendees ;
									lrec.noOfGifts             := l_cur_operations_data(i).noOfGifts ;
									lrec.giftType               := l_cur_operations_data(i).giftType ; 
									IF l_num_counter > 1 
									THEN
									   out_oper_rep_tab.extend();
									   out_oper_rep_tab(l_num_counter) := return_oper_report();
									ELSE
									   out_oper_rep_tab := return_arr_result(return_oper_report());
									END IF;
									   out_oper_rep_tab(l_num_counter) := lrec;        

							   EXCEPTION             
								  WHEN OTHERS 
								  THEN
									DBMS_OUTPUT.PUT_LINE('Error occurred : '  || SQLERRM);
							  END; 

						END LOOP;              

       END LOOP;              



   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.PUT_LINE ('HERE INSIIDE OTHERS' || SQLERRM);
   END;



--
-- PROCEDURE catering_rep
--                (out_chr_err_code   OUT VARCHAR2,
--              out_chr_err_msg    OUT VARCHAR2,
--              out_cate_rep_tab   OUT return_cat_arr_result   ,
--              in_from_date IN date,
--              in_to_date IN date,
--              in_sort_column IN VARCHAR2,
--              in_order_by IN VARCHAR2,
--              in_location IN VARCHAR2
--             )
--
--    IS             
--
--      l_chr_srcstage     VARCHAR2 (200);
--      l_chr_biqtab       VARCHAR2 (200);
--      l_chr_srctab       VARCHAR2 (200);
--      l_chr_bistagtab    VARCHAR2 (200);
--      l_chr_err_code     VARCHAR2 (255);
--      l_chr_err_msg      VARCHAR2 (255);
--      l_out_chr_errbuf   VARCHAR2 (2000);
--      lrec               return_cat_report;
--      l_num_counter         NUMBER := 0;
--      l_start_date date := in_from_date;
--      l_end_date date := in_to_date + 1;
--      l_sort_column VARCHAR2(30):= in_sort_column;
--      l_order_by VARCHAR2(10):=  in_order_by ;
--      l_location_id VARCHAR2(256) := in_location ;
--
--CURSOR cur_catering_data IS
--	SELECT a.request_activity_day_id request_activity_day_id,
--		   a.request_id request_id,
--           (select NAME from BI_LOCATION where id = a.room) room,
--           b.customer_name customer_name,
--           b.country country,
--           (SELECT d.user_name
--			  FROM bi_user d
--			  WHERE d.id = b.Briefing_manager) Briefing_manager,
--           b.host_email host_email,
----		  REPLACE(replace(lower(b.host_name),chr(9),' '),' ','.') ||'@briefingiq.com'  host_name,
--           b.host_contact host_contact,
--           (SELECT d.user_name
--			  FROM bi_user d
--			  WHERE d.id = b.requestor) requestor,
--            TO_CHAR(NEW_TIME (a.start_time, 'GMT',(select bl.LOCATION_TIMEZONE_DB from bi_location bl where bl.id = 4300)),'HH:MI AM') AS start_time, 
--            TO_CHAR(NEW_TIME (a.end_time, 'GMT',(select bl.LOCATION_TIMEZONE_DB from bi_location bl where bl.id = 4300)),'HH:MI AM')  AS end_time, 
--            (select catering_type from bi_request_catering_activity c where c.request_activity_day_id = a.request_activity_day_id) catering_type,
--		 ( SELECT DISTINCT count(1)
--			  FROM BI_REQUEST_ATTENDEES c
--			  WHERE c.attendee_type ='internalattendee'
--				AND c.request_id = b.id) 
--                +
--         ( SELECT DISTINCT count(1)
--			  FROM BI_REQUEST_ATTENDEES c
--			  WHERE c.attendee_type ='externalattendee'
--				AND c.request_id = b.id) as Attendees,
--                (select NOTES from BI_REQUEST_CATERING_ACTIVITY c where a.REQUEST_ACTIVITY_DAY_ID = c.REQUEST_ACTIVITY_DAY_ID) NOTES,
--                b.COST_CENTER COST_CENTER,
--                (select DIET_INFORMATION DIET_INFORMATION from BI_REQUEST_CATERING_ACTIVITY c where a.REQUEST_ACTIVITY_DAY_ID = c.REQUEST_ACTIVITY_DAY_ID) DIET_INFORMATION
--	   FROM BI_REQUEST_ACT_DAY_ROOM a,
--			BI_REQUEST b
--		WHERE a.request_id = b.id 
--        and location_id = 4300
--        AND ROWNUM<10;
--
--   TYPE rec_catering_data IS TABLE OF cur_catering_data%ROWTYPE
--   INDEX BY PLS_INTEGER;
--   l_cur_catering_data   rec_catering_data;  
--
--
--begin
--
--
--
--
--      OPEN cur_catering_data;
--
--      LOOP      
--         FETCH cur_catering_data
--         BULK COLLECT INTO l_cur_catering_data
--         LIMIT 1000;
--
--         EXIT WHEN l_cur_catering_data.COUNT = 0;
--
--		     DBMS_OUTPUT.PUT_LINE ('here in first insert');
--
--
--        lrec := return_cat_report();
--        out_cate_rep_tab  := return_cat_arr_result(return_cat_report());
--        out_cate_rep_tab.delete;
--
--
--				 FOR i IN 1 .. l_cur_catering_data.COUNT
--				 LOOP
--
--
----						 dbms_output.put_line('Inside cursor   '  );
--
--							   BEGIN  
--
--									l_num_counter                := l_num_counter + 1;
--									lrec                         := return_cat_report();
--									lrec.request_activity_day_id := l_cur_catering_data(i).request_activity_day_id ;          
--								 	lrec.request_id              := l_cur_catering_data(i).request_id ;
--									lrec.room                    := l_cur_catering_data(i).room ;
--									lrec.customer_name           := l_cur_catering_data(i).customer_name ;
--									lrec.country                 := l_cur_catering_data(i).country ;
--									lrec.Briefing_manager        := l_cur_catering_data(i).Briefing_manager ;
--									lrec.host_email              := l_cur_catering_data(i).host_email ;
--									lrec.host_contact            := l_cur_catering_data(i).host_contact ;
--									lrec.requestor               := l_cur_catering_data(i).requestor ;
--									lrec.start_time              := l_cur_catering_data(i).start_time ;
--									lrec.end_time                := l_cur_catering_data(i).end_time ;
--									lrec.catering_type           := l_cur_catering_data(i).catering_type ;
--									lrec.Attendees               := l_cur_catering_data(i).Attendees ;
--                                  lrec.NOTES                   := l_cur_catering_data(i).NOTES;
--                                  lrec.COST_CENTER             := l_cur_catering_data(i).COST_CENTER;
--                                  lrec.DIET_INFORMATION        := l_cur_catering_data(i).DIET_INFORMATION;
--
--                                    dbms_output.put_line(l_cur_catering_data(i).COST_CENTER );
--
--
--									IF l_num_counter > 1 
--									THEN
--									   out_cate_rep_tab.extend();
--									   out_cate_rep_tab(l_num_counter) := return_cat_report();
--									ELSE
--									   out_cate_rep_tab := return_cat_arr_result(return_cat_report());
--									END IF;
--									   out_cate_rep_tab(l_num_counter) := lrec; 
--
--							   EXCEPTION             
--								  WHEN OTHERS 
--								  THEN
--									DBMS_OUTPUT.PUT_LINE('Error occurred : '  || SQLERRM);
--							  END; 
--
--						END LOOP;              
--       END LOOP;              
--
--   
--
--   EXCEPTION
--      WHEN OTHERS
--      THEN
--         DBMS_OUTPUT.PUT_LINE ('HERE INSIIDE OTHERS' || SQLERRM);
--   END;
--   

 PROCEDURE security_rep 
             (out_chr_err_code   OUT VARCHAR2,
              out_chr_err_msg    OUT VARCHAR2,
              out_security_tab   OUT return_security_arr_result   ,
              in_from_date IN date,
              in_to_date IN date,
              in_sort_column IN VARCHAR2,
              in_order_by IN VARCHAR2,
              in_location IN VARCHAR2
             )
IS             

      l_chr_srcstage     VARCHAR2 (200);
      l_chr_biqtab       VARCHAR2 (200);
      l_chr_srctab       VARCHAR2 (200);
      l_chr_bistagtab    VARCHAR2 (200);
      l_chr_err_code     VARCHAR2 (255);
      l_chr_err_msg      VARCHAR2 (255);
      l_out_chr_errbuf   VARCHAR2 (2000);
      lrec               return_security_report;
      l_num_counter      NUMBER := 0;	
      l_start_date date := in_from_date;
      l_end_date date := in_to_date + 1;
      l_sort_column VARCHAR2(30):= in_sort_column;
      l_order_by VARCHAR2(10):=  in_order_by ;

CURSOR cur_security_data IS
	SELECT
    "A3"."ID"                  requestId,
    "A3"."START_DATE"          startDate,
    "A3"."CUSTOMER_NAME"       customerName,
    (select name from bi_location where id = A4.room) room,
    (select ADDRESS1 from bi_location where id = A4.room) building,
    "A3"."COUNTRY"             country,
    "A3"."DURATION"            duration,
    "A2"."COMPANY"             customerCompany,
    "A2"."FIRST_NAME"          firstName,
    "A2"."LAST_NAME"           lastName,
    "A2"."TITLE"               TITLE,
    "A1"."IS_DECISION_MAKER"   isDecisionMaker,
    "A1"."IS_TECHNICAL"        isTechnical,
    "A1"."FIRST_NAME"          internalAttFirstName,
    "A1"."LAST_NAME"           internalAttLastName,
    "A1"."TITLE"               internalAttTitle
FROM
    "BI_REQUEST_CATERING_ACTIVITY" "A4",
    "BI_REQUEST" "A3",
    "BI_REQUEST_ATTENDEES" "A2",
    "BI_REQUEST_ATTENDEES" "A1"
WHERE
    "A3"."ID" = "A2"."REQUEST_ID"
    AND "A3"."ID" = "A4"."REQUEST_ID"
    AND "A2"."ATTENDEE_TYPE" = 'externalattendees'
    AND "A2"."REQUEST_ID" = "A1"."REQUEST_ID"
    AND "A1"."ATTENDEE_TYPE" = 'internalattendee' 
    AND "A3"."START_DATE" between l_start_date  and l_end_date
--        ORDER BY l_sort_column  
;
   TYPE rec_security_data IS TABLE OF cur_security_data%ROWTYPE
   INDEX BY PLS_INTEGER;
   l_cur_security_data   rec_security_data;  


begin
   
    out_security_tab := return_security_arr_result(return_security_report());
      OPEN cur_security_data;

      LOOP      
         FETCH cur_security_data
         BULK COLLECT INTO l_cur_security_data
         LIMIT 1000;

         EXIT WHEN l_cur_security_data.COUNT = 0;

		     DBMS_OUTPUT.PUT_LINE ('here in first insert');
		     DBMS_OUTPUT.PUT_LINE ('l_start_date'|| ' ' ||l_start_date || ' end :- '|| l_end_date ||' l_sort_column ' ||l_sort_column);


        lrec := return_security_report();
        out_security_tab  := return_security_arr_result(return_security_report());
        out_security_tab.delete;


				 FOR i IN 1 .. l_cur_security_data.COUNT
				 LOOP


--						 dbms_output.put_line('Inside cursor   '  );

							   BEGIN  

									l_num_counter                := l_num_counter + 1;
									lrec                         := return_security_report();
								 	lrec.requestid              := l_cur_security_data(i).requestId ;
								 	lrec.startDate              := l_cur_security_data(i).startDate ;
									lrec.customerName           := l_cur_security_data(i).customerName ;
									lrec.room                 := l_cur_security_data(i).room ;
									lrec.building                 := l_cur_security_data(i).building ;
									lrec.country                 := l_cur_security_data(i).country ;
									lrec.duration                := l_cur_security_data(i).duration ;
									lrec.customerCompany        := l_cur_security_data(i).customerCompany ;
									lrec.firstName              := l_cur_security_data(i).firstName ;
									lrec.lastName               := l_cur_security_data(i).lastName ;
									lrec.title                   := l_cur_security_data(i).title ;
									lrec.isDecisionMaker       := l_cur_security_data(i).isDecisionMaker ;
									lrec.isTechnical            := l_cur_security_data(i).isTechnical ;
									lrec.internalAttFirstName := l_cur_security_data(i).internalAttFirstName ;
                                    lrec.internalAttLastName  := l_cur_security_data(i).internalAttLastName;
                                    lrec.internalAttTitle      := l_cur_security_data(i).internalAttTitle;



									IF l_num_counter > 1 
									THEN
									   out_security_tab.extend();
									   out_security_tab(l_num_counter) := return_security_report();
									ELSE
									   out_security_tab := return_security_arr_result(return_security_report());
									END IF;
									   out_security_tab(l_num_counter) := lrec; 

							   EXCEPTION             
								  WHEN OTHERS 
								  THEN
									DBMS_OUTPUT.PUT_LINE('Error occurred : '  || SQLERRM);
							  END; 

						END LOOP;   
                         
                       
       END LOOP;  


   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.PUT_LINE ('HERE INSIIDE OTHERS' || SQLERRM);
   END;

END;
/