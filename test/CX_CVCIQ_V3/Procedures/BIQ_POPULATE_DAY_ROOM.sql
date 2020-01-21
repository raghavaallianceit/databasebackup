CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_populate_day_room 
IS

   CURSOR cur_extract_main_room
   IS
	SELECT a.id,
		a.main_room,
		a.arrival_ts,
		a.adjourn_ts,
		a.created_by,
		a.updated_by,
		a.request_id		
	FROM bi_request_activity_day a
 WHERE a.main_room IS NOT NULL;
	
	CURSOR cur_get_main_room_data
	IS  
	  SELECT a.id,
	         a.request_id,
           a.start_time,
           a.end_time ,
			     a.room
	   FROM bi_request_act_day_room  a,
          bi_location_calendar b
      WHERE a.request_id = b.request_id 
         AND a.room_type ='MAIN_ROOM'
    ---     AND a.id <> b.activity_day_room_id
         AND TRUNC(b.start_date) =  TRUNC(a.start_time) 
         AND TRUNC(b.end_date) = TRUNC(a.end_time)
         AND b.location_id = a.room;
		

    CURSOR cur_extract_break_room
    IS
      SELECT a.id,
		b.break_rooms,
 		a.arrival_ts,
		a.adjourn_ts,
		a.created_by,
		a.updated_by,
		a.request_id		
	FROM bi_request_activity_day a,
	     bi_request_act_day_break_room b
	WHERE a.id = b.request_activity_day_id
      AND b.break_rooms IS NOT NULL; 	
      
	CURSOR cur_get_break_room_data
	IS  
	  SELECT a.id,
	         a.request_id,
           a.start_time,
           a.end_time ,
			     a.room
	   FROM bi_request_act_day_room  a,
          bi_location_calendar b
      WHERE a.request_id = b.request_id 
         AND a.room_type = 'BREAKOUT_ROOM'
       --  AND a.id <> b.activity_day_room_id
         AND TRUNC(b.start_date) =  TRUNC(a.start_time) 
         AND TRUNC(b.end_date) = TRUNC(a.end_time)
         AND b.location_id = a.room;      
	 

   TYPE cur_get_room_data_main IS TABLE OF cur_extract_main_room%ROWTYPE
   INDEX BY PLS_INTEGER;
   l_cur_extract_main_room   cur_get_room_data_main;  
   
   TYPE cur_get_room_data_break IS TABLE OF cur_extract_break_room%ROWTYPE
   INDEX BY PLS_INTEGER;
   l_cur_extract_break_room   cur_get_room_data_break; 
    
   l_out_chr_errbuf                VARCHAR2 (2000);   
   l_chr_err_code                  VARCHAR2(2000);
   l_chr_err_msg                   VARCHAR2(2000);
   
BEGIN

   BEGIN
   
 	  
      OPEN cur_extract_main_room;

      LOOP
      
         FETCH cur_extract_main_room
            BULK COLLECT INTO l_cur_extract_main_room
            LIMIT 1000;

         EXIT WHEN l_cur_extract_main_room.COUNT = 0;

		     DBMS_OUTPUT.PUT_LINE ('here in first insert');

				 FOR i IN 1 .. l_cur_extract_main_room.COUNT
				 LOOP
					BEGIN
					   INSERT INTO bi_request_act_day_room
												 (id,
												  request_activity_day_id,
												  room,
												  room_type,
												  start_time,
												  end_time,
												  unique_id,
												  tenant_id,
												  version,										  
												  created_by,
												  created_ts,
												  updated_by,
												  updated_ts,
												  request_id)
							VALUES (bi_request_act_day_room_seq.NEXTVAL,
									l_cur_extract_main_room (i).id,
									l_cur_extract_main_room (i).main_room,
									'MAIN_ROOM',
									l_cur_extract_main_room (i).arrival_ts,
									l_cur_extract_main_room (i).adjourn_ts,
									regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
									NULL,
									0,
									l_cur_extract_main_room(i).created_by,
									CURRENT_TIMESTAMP,
									l_cur_extract_main_room(i).updated_by,
									CURRENT_TIMESTAMP,
									l_cur_extract_main_room (i).request_id);
						EXCEPTION
						   WHEN OTHERS
						   THEN
						   DBMS_OUTPUT.PUT_LINE (
							  ' Error while inserting into bi_request_act_day_room table for main_room --'
						   || SQLERRM
						   || '--'
						   || SQLCODE);
						   
						l_out_chr_errbuf :=
							 ' Error while inserting into bi_request_act_day_room  table for main_room --'
						   || SQLERRM
						   || '--'
						   || SQLCODE;
						l_chr_err_msg := 'IN OTHERs EXCEPTION';
						END;
					
					END LOOP;
					
        END LOOP; 					
					
		FOR rec_get_main_room_data IN cur_get_main_room_data
		LOOP
		
	    	DBMS_OUTPUT.PUT_LINE ('here in update');
				
				BEGIN
        
           DBMS_OUTPUT.PUT_LINE ('request_id  :' || rec_get_main_room_data.request_id);
           DBMS_OUTPUT.PUT_LINE ('room :' || rec_get_main_room_data.room);
 
 
				
				 UPDATE bi_location_calendar
					SET activity_day_room_id = rec_get_main_room_data.id
             ,updated_ts = CURRENT_TIMESTAMP
				 WHERE request_id = rec_get_main_room_data.request_id
					AND TRUNC(start_date) =  TRUNC(rec_get_main_room_data.start_time) 
					AND TRUNC(end_date) = TRUNC(rec_get_main_room_data.end_time)
					AND location_id = rec_get_main_room_data.room;
				
				EXCEPTION
				   WHEN OTHERS
				   THEN
				   DBMS_OUTPUT.PUT_LINE (
					  ' Error while updating  bi_location_calendar table for main_room --'
				   || SQLERRM
				   || '--'
				   || SQLCODE);
				   
				l_out_chr_errbuf :=
					 ' Error while updating  bi_location_calendar table for main_room --'
				   || SQLERRM
				   || '--'
				   || SQLCODE;
				l_chr_err_msg := 'IN OTHERs EXCEPTION';
				END;

	 END LOOP;
	 
      OPEN cur_extract_break_room;

      LOOP
      
         FETCH cur_extract_break_room
            BULK COLLECT INTO l_cur_extract_break_room
            LIMIT 1000;

         EXIT WHEN l_cur_extract_break_room.COUNT = 0;
		 
		     DBMS_OUTPUT.PUT_LINE ('here in seond insert');
		 
				 FOR i IN 1 .. l_cur_extract_break_room.COUNT
				 LOOP
					BEGIN
					   INSERT INTO bi_request_act_day_room 
												 (id,
												  request_activity_day_id,
												  room,
												  room_type,
												  start_time,
												  end_time,
												  unique_id,
												  tenant_id,
												  version,										  
												  created_by,
												  created_ts,
												  updated_by,
												  updated_ts,
												  request_id)
							VALUES (bi_request_act_day_room_seq.NEXTVAL,
									l_cur_extract_break_room (i).id,
									l_cur_extract_break_room (i).break_rooms,
									'BREAKOUT_ROOM',
									l_cur_extract_break_room (i).arrival_ts,
									l_cur_extract_break_room (i).adjourn_ts,
									regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
									NULL,
									0,
									l_cur_extract_break_room(i).created_by,
									CURRENT_TIMESTAMP,
									l_cur_extract_break_room(i).updated_by,
									CURRENT_TIMESTAMP,
									l_cur_extract_break_room (i).request_id);
						EXCEPTION
						   WHEN OTHERS
						   THEN
						   DBMS_OUTPUT.PUT_LINE (
							  ' Error while inserting into bi_request_act_day_room table for main_room --'
						   || SQLERRM
						   || '--'
						   || SQLCODE);
						   
						l_out_chr_errbuf :=
							 ' Error while inserting into bi_request_act_day_room  table for main_room --'
						   || SQLERRM
						   || '--'
						   || SQLCODE;
						l_chr_err_msg := 'IN OTHERs EXCEPTION';
						END;
					
					END LOOP;
					
        END LOOP; 					
		 
		FOR rec_get_break_room_data IN cur_get_break_room_data
		LOOP
		
	    	DBMS_OUTPUT.PUT_LINE ('here in second update');
				
				BEGIN
        
           DBMS_OUTPUT.PUT_LINE ('request_id  :' || rec_get_break_room_data.request_id);
           DBMS_OUTPUT.PUT_LINE ('room :' || rec_get_break_room_data.room);
  
				
				 UPDATE bi_location_calendar
					SET activity_day_room_id = rec_get_break_room_data.id
             ,updated_ts = CURRENT_TIMESTAMP
				 WHERE request_id = rec_get_break_room_data.request_id
					AND TRUNC(start_date) =  TRUNC(rec_get_break_room_data.start_time) 
 					AND TRUNC(end_date) = TRUNC(rec_get_break_room_data.end_time)
					AND location_id = rec_get_break_room_data.room;
				
				EXCEPTION
				   WHEN OTHERS
				   THEN
				   DBMS_OUTPUT.PUT_LINE (
					  ' Error while updating  bi_location_calendar table for breakout_room --'
				   || SQLERRM
				   || '--'
				   || SQLCODE);
				   
				l_out_chr_errbuf :=
					 ' Error while updating  bi_location_calendar table for breakout_room --'
				   || SQLERRM
				   || '--'
				   || SQLCODE;
				l_chr_err_msg := 'IN OTHERs EXCEPTION';
				END;

	 END LOOP;     

     COMMIT;


  EXCEPTION
     WHEN OTHERS
     THEN
     DBMS_OUTPUT.PUT_LINE (
      ' Error in main --'
     || SQLERRM
     || '--'
     || SQLCODE);
     
  l_out_chr_errbuf :=
     ' Error in main --'
     || SQLERRM
     || '--'
     || SQLCODE;
  END;

END;
/