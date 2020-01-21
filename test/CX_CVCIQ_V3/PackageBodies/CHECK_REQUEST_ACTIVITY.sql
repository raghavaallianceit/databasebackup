CREATE OR REPLACE PACKAGE BODY cx_cvciq_v3."CHECK_REQUEST_ACTIVITY" 
AS

PROCEDURE return_avail_msg(    
                           out_chr_err_code   OUT VARCHAR2,
                           out_chr_err_msg    OUT VARCHAR2,
                           p_status           OUT VARCHAR2,
                           p_activity_day_id  IN NUMBER,
                           p_arrival          IN VARCHAR2,
                           p_adjorn           IN VARCHAR2
                           )
IS
l_first_rooom NUMBER;
l_minid NUMBER;
l_check_id NUMBER;
l_max_date DATE;
/*
CURSOR C1 
IS
select id from bi_request_activity
WHERE request_activity_day_id = p_activity_day_id
and attribute_info is null
ORDER BY TO_DATE(start_time,'HH:MI AM');

CURSOR C2(l_numid NUMBER)
IS
select id,start_Time, nvl(room,111) room from bi_request_activity
WHERE request_activity_day_id = p_activity_day_id
and id = l_numid;

l_early_date DATE;
l_min_id NUMBER  ;
l_first_enddate DATE;
l_num_duration NUMBER;
l_chrtime TIMESTAMP;
l_new_id NUMBER;
l_flag VARCHAR2(1);
l_num_reqid NUMBER;
l_num_id NUMBER;
l_chr_date_arr  VARCHAR2(40):= NULL; 
l_chr_date_adj  VARCHAR2(40):= NULL; 
l_chr_arr_actual  VARCHAR2(40):= NULL; 
l_chr_adj_actual  VARCHAR2(40):= NULL; 
l_chr_arr_Date DATE := NULL;
l_chr_adj_Date DATE := NULL;
l_dte_arr_actual DATE:= NULL;
l_dte_adj_actual DATE:= NULL;
l_dte_date_arr DATE:= NULL;
l_dte_date_adj DATE:= NULL;
l_num_arr_diff NUMBER := 0;
l_num_adj_diff NUMBER := 0;
l_req_act_day_id NUMBER := 0;
l_chr_succ_arr VARCHAR2(50):= NULL;
l_chr_succ_adj VARCHAR2(50):= NULL;
p_event_date DATE := NULL;
l_end TIMESTAMP;
l_num_upd_enddate VARCHAR2(50);
no_event_date EXCEPTION;
check_ip EXCEPTION;
check_arr_adj EXCEPTION;
err_diff EXCEPTION;*/
     
BEGIN

NULL;

/*

    BEGIN 
      SELECT event_date
      INTO p_event_date
      FROM BI_REQUEST_ACTIVITY_DAY
      WHERE ID = p_activity_day_id;
    EXCEPTION
      WHEN OTHERS
      THEN
        RAISE no_event_date;      
    END;

    DBMS_OUTPUT.PUT_LINE ('Here2' || p_event_date);

       BEGIN
         SELECT TO_CHAR(p_event_date,'MM/DD/YYYY') ||' '|| p_arrival,
                TO_CHAR(p_event_date,'MM/DD/YYYY') ||' '|| p_adjorn
           INTO l_chr_date_arr,
                l_chr_date_adj
           FROM DUAL;
       EXCEPTION
        WHEN OTHERS
        THEN
         l_chr_date_arr := null;
         l_chr_date_adj := null;
         RAISE check_ip;
       END;
             
       DBMS_OUTPUT.PUT_LINE ('Here3 : ' || l_chr_date_arr || l_chr_date_adj );
    
       BEGIN  
        SELECT TO_CHAR(event_date,'MM/DD/YYYY') ||' '|| arrival ,
               TO_CHAR(event_date,'MM/DD/YYYY') ||' '|| adjourn ,
               ID
          INTO l_chr_arr_actual,
               l_chr_adj_actual,
               l_req_act_day_id
          FROM bi_request_activity_day 
         WHERE id = p_activity_day_id ;
       EXCEPTION
        WHEN OTHERS
        THEN
         l_chr_arr_actual := null;
         l_chr_adj_actual := null;
         RAISE check_arr_adj;
       END;
       
       DBMS_OUTPUT.PUT_LINE ('Here4 : ' || l_chr_arr_actual || l_chr_adj_actual || '  '  || l_req_act_day_id);
       
       BEGIN  
        SELECT TO_DATE(l_chr_arr_actual, 'MM/DD/YY HH:MI AM') ,
               TO_DATE(l_chr_adj_actual, 'MM/DD/YY HH:MI AM') ,
               TO_DATE(l_chr_date_arr, 'MM/DD/YY HH:MI AM') ,
               TO_DATE(l_chr_date_adj, 'MM/DD/YY HH:MI AM') 
          INTO l_dte_arr_actual, -- from table
               l_dte_adj_actual, -- from table
               l_dte_date_arr,  -- from i/p
               l_dte_date_adj -- from i/p
          FROM DUAL;
       EXCEPTION
        WHEN OTHERS
        THEN
         l_dte_arr_actual := null;
         l_dte_adj_actual := null;
         l_dte_date_arr := null;
         l_dte_date_adj := null;
       END;

        
       BEGIN 
         SELECT ROUND(
                (CAST(l_dte_date_arr  AS DATE) - CAST( l_dte_arr_actual AS DATE)) * 24 * 60
                 ) AS diff_minutes_arr,
                  ROUND(
                (CAST(l_dte_date_adj AS DATE) - CAST(l_dte_adj_actual AS DATE)) * 24 * 60
                 ) AS diff_minutes_adj
           INTO l_num_arr_diff   ,
                l_num_adj_diff
           FROM DUAL;
       EXCEPTION
        WHEN OTHERS
        THEN
          l_num_arr_diff := 0;
          l_num_adj_diff := 0;
          RAISE err_diff;
       END;    
             
       
       DBMS_OUTPUT.PUT_LINE ('Here5 : ' || l_num_arr_diff || '   '  || l_req_act_day_id);

   IF l_num_arr_diff > 0 --ARRIVAL Validation starts
   THEN 
        
     FOR rec_c1 IN c1
     LOOP
     
       DBMS_OUTPUT.PUT_LINE('First id '|| rec_c1.id );
      
            FOR rec_c2 IN c2(rec_c1.id)
            LOOP
            
              BEGIN
               SELECT min(id)
                 INTO l_minid
                 FROM bi_request_activity
                WHERE request_activity_day_id = p_activity_day_id
                  AND TO_DATE(start_time,'HH:MI AM')
                     IN (SELECT MIN(TO_DATE(start_time,'HH:MI AM')) FROM bi_request_activity
                          WHERE request_activity_day_id = p_activity_day_id);
              EXCEPTION
               WHEN OTHERS
               THEN
                 l_minid :=0;
              END;
                
              --  DBMS_OUTPUT.PUT_LINE('l_minid : '|| l_minid );

              --  DBMS_OUTPUT.PUT_LINE('rec_c2.id : '|| rec_c2.id );
              --  DBMS_OUTPUT.PUT_LINE('rec_c2.id : '|| rec_c2.id );
                
                
                l_first_rooom := rec_c2.room;

             IF  rec_c2.id = l_minid
             THEN
               
                 --DBMS_OUTPUT.PUT_LINE('l_first_rooom : '|| l_first_rooom );
             
               UPDATE bi_request_activity
                 SET start_time =  TO_CHAR(TO_DATE(start_time,'HH:MI AM') + (l_num_arr_diff * (1/24/60)),'HH:MI AM'),
                     attribute_info ='Y'
               WHERE id = l_minid
                AND attribute_info IS NULL;
              DBMS_OUTPUT.PUT_LINE('First update  : '|| SQL%ROWCOUNT );
             END IF;
     
             -- DBMS_OUTPUT.PUT_LINE('room  : '|| rec_c2.room );
             -- DBMS_OUTPUT.PUT_LINE('l_first_rooom  : '|| l_first_rooom );
              
              
             IF (l_first_rooom = rec_c2.room AND  rec_c2.id <> l_minid)
               OR (l_first_rooom = 111 AND rec_c2.id <> l_minid)
             THEN
              
              ---  DBMS_OUTPUT.PUT_LINE('Second if  : '|| rec_c2.id );
                
              --  DBMS_OUTPUT.PUT_LINE('rec_c2.start_time : '|| TO_CHAR(TO_DATE(rec_c2.start_time,'HH:MI AM'),'HH:MI AM')); 
                
                BEGIN
                 SELECT max(TO_DATE (TO_CHAR(start_time ) ,'HH:MI AM') + (duration * (1/24/60)))
                   INTO l_max_date
                   FROM bi_request_activity
                  WHERE attribute_info ='Y'
                    AND room = nvl(rec_c2.room,111)
                    AND request_activity_day_id = p_activity_day_id;
                EXCEPTION
                  WHEN OTHERS
                  THEN
                    l_max_date := NULL;
                END;                
                
               -- DBMS_OUTPUT.PUT_LINE('l_max_date  : '|| l_max_date);
               -- DBMS_OUTPUT.PUT_LINE('l_max_date before second  : '|| TO_DATE(rec_c2.start_time,'HH:MI AM'));
                
                IF  l_max_date IS NOT NULL AND (TO_DATE(rec_c2.start_time,'HH:MI AM') <  l_max_date)
                THEN
                  
                  DBMS_OUTPUT.PUT_LINE('l_max_date is not null  : ');
                 
                 UPDATE  bi_request_activity
                 SET start_time =  TO_CHAR(TO_DATE(start_time,'HH:MI AM') + (l_num_arr_diff * (1/24/60)),'HH:MI AM'),
                     attribute_info ='Y'
                   WHERE id = rec_c2.id
                     AND attribute_info IS NULL;
                        DBMS_OUTPUT.PUT_LINE('sECOND update  : '|| SQL%ROWCOUNT );
                END IF;    
                 
                IF l_max_date IS NULL
                THEN
                
                   -- DBMS_OUTPUT.PUT_LINE('l_max_date is null  : ');
                   -- DBMS_OUTPUT.PUT_LINE('l_max_date is null  : ' || TO_DATE(rec_c2.start_time,'HH:MI AM') );
                   -- DBMS_OUTPUT.PUT_LINE('l_max_date is null  : '|| TO_DATE(p_arrival,'HH:MI AM'));
                    
                    IF TO_DATE(rec_c2.start_time,'HH:MI AM') < TO_DATE(p_arrival,'HH:MI AM')
                    THEN        
                           
                     UPDATE  bi_request_activity
                     SET start_time =  TO_CHAR(TO_DATE(start_time,'HH:MI AM') + (l_num_arr_diff * (1/24/60)),'HH:MI AM'),
                         attribute_info ='Y'
                       WHERE id = rec_c2.id
                        AND attribute_info IS NULL;
                        DBMS_OUTPUT.PUT_LINE('THIRD update  : '|| SQL%ROWCOUNT );
                    END IF;  
                END IF;
                
             END IF;
          
             IF l_first_rooom <> nvl(rec_c2.room,111) AND  rec_c2.id <> l_minid
             THEN
              
              --  DBMS_OUTPUT.PUT_LINE('Third if  : '|| rec_c2.id );      

                IF TO_DATE(rec_c2.start_time,'HH:MI AM') < TO_DATE(p_arrival,'HH:MI AM')
                THEN        
                       
                 UPDATE  bi_request_activity
                 SET start_time =  TO_CHAR(TO_DATE(start_time,'HH:MI AM') + (l_num_arr_diff * (1/24/60)),'HH:MI AM'),
                     attribute_info ='Y'
                   WHERE id = rec_c2.id
                    AND attribute_info IS NULL;
                    DBMS_OUTPUT.PUT_LINE('FOURTH update  : '|| SQL%ROWCOUNT );
                END IF;         

              END IF;
           
    END LOOP;     
 END LOOP;
        
      ELSIF l_num_arr_diff < 0 --Rows updated if its a prepone activity
      THEN   
        
           DBMS_OUTPUT.PUT_LINE ('Here8 : ' || l_chr_succ_arr );
           l_chr_succ_adj := 'S';
      END IF;  -- END OF ARRIVAL
      
      
      --ADJOURN Validation starts
      IF l_num_adj_diff > 0
      THEN
        
          l_chr_succ_adj := 'S';
         -- DBMS_OUTPUT.PUT_LINE ('Here9 : ' || l_chr_succ_adj );
          
      ELSIF l_num_adj_diff < 0
      THEN
         -- DBMS_OUTPUT.PUT_LINE ('Here10 : '  || l_dte_date_adj);  


          BEGIN       
            DELETE FROM  bi_request_activity
             WHERE REQUEST_ACTIVITY_DAY_ID = p_activity_day_id    
               AND to_date (to_char(p_event_date ||' '|| start_time ) ,'DD-MON-YY HH:MI AM') + (duration * (1/24/60))  > l_dte_date_adj;
          EXCEPTION
            WHEN OTHERS
            THEN
             l_chr_succ_adj := 'F';
          END;            
         -- DBMS_OUTPUT.PUT_LINE ('Here10 : ' || l_chr_succ_adj );    
          
          l_chr_succ_adj := 'S';          
          
        
        
       END IF;        
  
  IF l_chr_succ_arr = 'S' --AND l_chr_succ_arr = 'S'
  THEN
     p_status := 'SUCCESSFUL';
  ELSE
     p_status := 'FAILED';
  END IF;
  
  BEGIN
    UPDATE bi_request_activity
      SET attribute_info = null
     WHERE request_activity_day_id = p_activity_day_id
     AND attribute_info ='Y';
  EXCEPTION
    WHEN OTHERS
    THEN
     NULL;
  END;
   COMMIT;   
 EXCEPTION
  WHEN err_diff
  THEN
    out_chr_err_msg := 'Unable to get the difference between arrival and adjourn activities';
  WHEN check_arr_adj
  THEN
     out_chr_err_msg := 'Please check the arrival and adjourn activities'; 
  WHEN check_ip
  THEN
    out_chr_err_msg := 'Please check the input params';
  WHEN no_event_date
  THEN
    out_chr_err_msg := 'Event date doesnt exists in the activity day';
  WHEN OTHERS
  THEN
      DBMS_OUTPUT.PUT_LINE ('HERE' || SQLERRM);
      */ 
 END;  


END;
/