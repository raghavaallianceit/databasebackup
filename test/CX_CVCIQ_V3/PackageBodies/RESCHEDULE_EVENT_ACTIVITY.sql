CREATE OR REPLACE PACKAGE BODY cx_cvciq_v3."RESCHEDULE_EVENT_ACTIVITY" 
AS

PROCEDURE reschedule_event_day(    
                           out_chr_err_code   OUT VARCHAR2,
                           out_chr_err_msg    OUT VARCHAR2,
                           p_status           OUT VARCHAR2,
                           p_activity_day_id  IN NUMBER,
                           p_arrival          IN TIMESTAMP,
                           p_adjorn           IN TIMESTAMP
                           )
IS
/************************************************************************************
*Purpose: This procedure is called when ever there is a change in Arrival or        *
* Adjourn timings in the Agenda header section.                                     *
*************************************************************************************/
l_first_rooom NUMBER := 0;
l_minid NUMBER  := 0;
l_check_id NUMBER  := 0;
l_max_date DATE := NULL; 

CURSOR C1 
IS
SELECT id FROM bi_request_activity
WHERE request_activity_day_id = p_activity_day_id
AND attribute_info is null
AND request_type_activity_id = 3
ORDER BY activity_start_time;

CURSOR C2(l_numid NUMBER)
IS
SELECT id,activity_start_time, nvl(room,111) room FROM bi_request_activity
WHERE request_activity_day_id = p_activity_day_id
AND request_type_activity_id = 3
AND id = l_numid;

l_chr_err_code       VARCHAR2 (300);
l_chr_err_msg        VARCHAR2 (300);
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
err_diff EXCEPTION;
     
BEGIN

--13:= 'here';

     BEGIN
         bi_call_log_proc.call_log_proc (l_chr_err_code,
                 l_chr_err_msg,
                 13,
                 p_activity_day_id,
                 13,
                 'p_arrival and p_adjorn values ',
                 SUBSTR (SQLERRM, 1, 255),
                  p_arrival||p_adjorn);   
     END;
    
    BEGIN 
      SELECT event_date
        INTO p_event_date
        FROM BI_REQUEST_ACTIVITY_DAY
      WHERE ID = p_activity_day_id;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
             bi_call_log_proc.call_log_proc (l_chr_err_code,
                     l_chr_err_msg,
                     13,
                     p_activity_day_id,
                     13,
                     'No data found in first query',
                     SUBSTR (SQLERRM, 1, 255),
                      p_arrival||p_adjorn);      
      WHEN OTHERS
      THEN
        RAISE no_event_date;
    END;

        DBMS_OUTPUT.PUT_LINE ('Here2' || p_event_date);

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
        WHEN NO_DATA_FOUND
        THEN
             bi_call_log_proc.call_log_proc (l_chr_err_code,
                     l_chr_err_msg,
                     13,
                     p_activity_day_id,
                     13,
                     'No data found in second query',
                     SUBSTR (SQLERRM, 1, 255),
                      p_arrival||p_adjorn);             
        WHEN OTHERS
        THEN
         l_chr_arr_actual := null;
         l_chr_adj_actual := null;
         RAISE check_arr_adj;
       END;
       
       DBMS_OUTPUT.PUT_LINE ('Here4 : ' || l_chr_arr_actual || l_chr_adj_actual || '  '  || l_req_act_day_id);
       
       BEGIN  
        SELECT TO_DATE(l_chr_arr_actual, 'MM/DD/YY HH:MI AM') ,
               TO_DATE(l_chr_adj_actual, 'MM/DD/YY HH:MI AM')
          INTO l_dte_arr_actual, -- from table
               l_dte_adj_actual -- from table
          FROM DUAL;
       EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
             bi_call_log_proc.call_log_proc (l_chr_err_code,
                     l_chr_err_msg,
                     13,
                     p_activity_day_id,
                     13,
                     'No data found in third query',
                     SUBSTR (SQLERRM, 1, 255),
                      p_arrival||p_adjorn);             
        WHEN OTHERS
        THEN
         l_dte_arr_actual := null;
         l_dte_adj_actual := null;
             bi_call_log_proc.call_log_proc (l_chr_err_code,
                     l_chr_err_msg,
                     13,
                     p_activity_day_id,
                     13,
                     'Error while getting the actual arrival and adjourn',
                     SUBSTR (SQLERRM, 1, 255),
                      p_arrival||p_adjorn);                
       END;

        
       BEGIN 
         SELECT ROUND(
                (CAST(p_arrival  AS DATE) - CAST( l_dte_arr_actual AS DATE)) * 24 * 60
                 ) AS diff_minutes_arr,
                  ROUND(
                (CAST(p_adjorn AS DATE) - CAST(l_dte_adj_actual AS DATE)) * 24 * 60
                 ) AS diff_minutes_adj
           INTO l_num_arr_diff   ,
                l_num_adj_diff
           FROM DUAL;
       EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
             bi_call_log_proc.call_log_proc (l_chr_err_code,
                     l_chr_err_msg,
                     13,
                     p_activity_day_id,
                     13,
                     'No data found in 4th query',
                     SUBSTR (SQLERRM, 1, 255),
                      p_arrival||p_adjorn);          
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
                  AND request_type_activity_id = 3
                  AND activity_start_time
                     IN (SELECT MIN(activity_start_time) FROM bi_request_activity
                          WHERE request_activity_day_id = p_activity_day_id
                          AND request_type_activity_id = 3);
              EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                     bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             13,
                             p_activity_day_id,
                             13,
                             'No data found in first min id query',
                             SUBSTR (SQLERRM, 1, 255),
                              p_arrival||p_adjorn);                    
               WHEN OTHERS
               THEN
                 l_minid :=0;
                 bi_call_log_proc.call_log_proc (l_chr_err_code,
                         l_chr_err_msg,
                         13,
                         p_activity_day_id,
                         13,
                         'Error in getting l_minid',
                         SUBSTR (SQLERRM, 1, 255),
                          p_arrival||p_adjorn);                 
              END;
                
                DBMS_OUTPUT.PUT_LINE('l_minid : '|| l_minid );
                DBMS_OUTPUT.PUT_LINE('rec_c2.id : '|| rec_c2.id );
                DBMS_OUTPUT.PUT_LINE('rec_c2.id : '|| rec_c2.id );
                
                
                l_first_rooom := rec_c2.room;

             IF  rec_c2.id = l_minid
             THEN               
                 DBMS_OUTPUT.PUT_LINE('l_first_rooom : '|| l_first_rooom );
                 
                 BEGIN
                 
                   UPDATE bi_request_activity
                     SET activity_start_time =  activity_start_time + (l_num_arr_diff * (1/24/60)),
                         attribute_info ='Y'
                   WHERE id = l_minid
                    AND attribute_info IS NULL
                    AND request_type_activity_id = 3;
                  DBMS_OUTPUT.PUT_LINE('First update  : '|| SQL%ROWCOUNT );
                 EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                         bi_call_log_proc.call_log_proc (l_chr_err_code,
                                 l_chr_err_msg,
                                 13,
                                 p_activity_day_id,
                                 13,
                                 'No data found in first min id query',
                                 SUBSTR (SQLERRM, 1, 255),
                                  p_arrival||p_adjorn);                       
                   WHEN OTHERS
                   THEN
                     bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             13,
                             p_activity_day_id,
                             13,
                             'Error while updating bi_request_activity',
                             SUBSTR (SQLERRM, 1, 255),
                              p_arrival||p_adjorn);                            
                 END;                 
             END IF;
     
              DBMS_OUTPUT.PUT_LINE('room  : '|| rec_c2.room );
              DBMS_OUTPUT.PUT_LINE('l_first_rooom  : '|| l_first_rooom );
              
              
             IF (l_first_rooom = rec_c2.room AND  rec_c2.id <> l_minid)
               OR (l_first_rooom = 111 AND rec_c2.id <> l_minid)
             THEN
              
                DBMS_OUTPUT.PUT_LINE('Second if  : '|| rec_c2.id );                
                DBMS_OUTPUT.PUT_LINE('rec_c2.activity_start_time : '|| rec_c2.activity_start_time); 
                
                BEGIN
                 SELECT max(activity_start_time + (duration * (1/24/60)))
                   INTO l_max_date
                   FROM bi_request_activity
                  WHERE attribute_info ='Y'
                    AND room = nvl(rec_c2.room,111)
                    AND request_activity_day_id = p_activity_day_id
                    AND request_type_activity_id = 3;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                         bi_call_log_proc.call_log_proc (l_chr_err_code,
                                 l_chr_err_msg,
                                 13,
                                 p_activity_day_id,
                                 13,
                                 'No data found in second if query',
                                 SUBSTR (SQLERRM, 1, 255),
                                  p_arrival||p_adjorn);                  
                  WHEN OTHERS
                  THEN
                    l_max_date := NULL;
                     bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             13,
                             p_activity_day_id,
                             13,
                             'Error while selecting l_max_date',
                             SUBSTR (SQLERRM, 1, 255),
                              p_arrival||p_adjorn);                            
                END;                
                DBMS_OUTPUT.PUT_LINE('l_max_date  : '|| l_max_date);
                
                IF  l_max_date IS NOT NULL AND (rec_c2.activity_start_time <  l_max_date)
                THEN
                  
                  DBMS_OUTPUT.PUT_LINE('l_max_date is not null  : ');
                  
                  BEGIN
                     UPDATE bi_request_activity
                        SET activity_start_time =  activity_start_time + (l_num_arr_diff * (1/24/60)),
                            attribute_info ='Y'
                      WHERE id = rec_c2.id
                        AND attribute_info IS NULL
                        AND request_type_activity_id = 3;
                            DBMS_OUTPUT.PUT_LINE('sECOND update  : '|| SQL%ROWCOUNT );
                  EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                         bi_call_log_proc.call_log_proc (l_chr_err_code,
                                 l_chr_err_msg,
                                 13,
                                 p_activity_day_id,
                                 13,
                                 'No data found in second if query update',
                                 SUBSTR (SQLERRM, 1, 255),
                                  p_arrival||p_adjorn);                    
                   WHEN OTHERS
                   THEN
                     bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             13,
                             p_activity_day_id,
                             13,
                             'Error while updating bi_request_activity when l_max_date is not null ',
                             SUBSTR (SQLERRM, 1, 255),
                              p_arrival||p_adjorn);                       
                  END;                  
                END IF;    
                 
                IF l_max_date IS NULL
                THEN
                
                    DBMS_OUTPUT.PUT_LINE('l_max_date is null  : ');
                    DBMS_OUTPUT.PUT_LINE('l_max_date is null  : ' || TO_CHAR(rec_c2.activity_start_time,'HH:MI AM'));                    
                    DBMS_OUTPUT.PUT_LINE('l_max_date is null  : ' || p_arrival);
                    
                    IF rec_c2.activity_start_time < p_arrival
                    THEN        
                        
                       BEGIN                        
                         UPDATE bi_request_activity
                            SET activity_start_time =  activity_start_time + (l_num_arr_diff * (1/24/60)),
                                attribute_info ='Y'
                          WHERE id = rec_c2.id
                            AND attribute_info IS NULL
                            AND request_type_activity_id = 3;
                            DBMS_OUTPUT.PUT_LINE('THIRD update  : '|| SQL%ROWCOUNT );
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN
                                 bi_call_log_proc.call_log_proc (l_chr_err_code,
                                         l_chr_err_msg,
                                         13,
                                         p_activity_day_id,
                                         13,
                                         'No data found in update if maxdate is null',
                                         SUBSTR (SQLERRM, 1, 255),
                                          p_arrival||p_adjorn);                          
                         WHEN OTHERS
                         THEN
                             bi_call_log_proc.call_log_proc (l_chr_err_code,
                                     l_chr_err_msg,
                                     13,
                                     p_activity_day_id,
                                     13,
                                     'Error while updating bi_request_activity when startdate is less than arrival ',
                                     SUBSTR (SQLERRM, 1, 255),
                                      p_arrival||p_adjorn);                                 
                        END;
                    END IF; 
                    
                END IF;
                
             END IF;
          
             IF l_first_rooom <> nvl(rec_c2.room,111) AND  rec_c2.id <> l_minid
             THEN
              
                DBMS_OUTPUT.PUT_LINE('FOURTH if  : '|| rec_c2.id );  
                DBMS_OUTPUT.PUT_LINE('FOURTH if  : '|| TO_CHAR(rec_c2.activity_start_time,'HH:MI AM') );                     
                DBMS_OUTPUT.PUT_LINE('FOURTH if  : '|| p_arrival );     
                
                IF rec_c2.activity_start_time < p_arrival
                THEN        
                 
                  BEGIN      
                     UPDATE bi_request_activity
                        SET activity_start_time =  activity_start_time + (l_num_arr_diff * (1/24/60)),
                            attribute_info ='Y'
                       WHERE id = rec_c2.id
                         AND attribute_info IS NULL
                         AND request_type_activity_id = 3;
                      DBMS_OUTPUT.PUT_LINE('FOURTH update  : '|| SQL%ROWCOUNT );
                   EXCEPTION
                       WHEN NO_DATA_FOUND
                    THEN
                         bi_call_log_proc.call_log_proc (l_chr_err_code,
                                 l_chr_err_msg,
                                 13,
                                 p_activity_day_id,
                                 13,
                                 'No data found if activity_start_time < p_arrival ',
                                 SUBSTR (SQLERRM, 1, 255),
                                  p_arrival||p_adjorn);  
                    WHEN OTHERS
                    THEN
                         bi_call_log_proc.call_log_proc (l_chr_err_code,
                                 l_chr_err_msg,
                                 13,
                                 p_activity_day_id,
                                 13,
                                 'Error while updating bi_request_activity when startdate is less than arrival ',
                                 SUBSTR (SQLERRM, 1, 255),
                                  p_arrival||p_adjorn);                                 
                   END;                    
                END IF;         

              END IF;
           
         END LOOP;     
     END LOOP;
        
      ELSIF l_num_arr_diff < 0 --Rows updated if its a prepone activity
      THEN   
        
           DBMS_OUTPUT.PUT_LINE ('Here8 : ' || l_chr_succ_arr );
           l_chr_succ_adj := 'S';

           bi_call_log_proc.call_log_proc (l_chr_err_code,
                 l_chr_err_msg,
                 13,
                 p_activity_day_id,
                 13,
                 'l_chr_succ_adj = S ',
                 SUBSTR (SQLERRM, 1, 255),
                  p_arrival||p_adjorn);             
      END IF;  -- END OF ARRIVAL
      
      
      --ADJOURN Validation starts
      IF l_num_adj_diff > 0
      THEN
        
          l_chr_succ_adj := 'S';
          DBMS_OUTPUT.PUT_LINE ('Here9 : ' || l_chr_succ_adj );
           bi_call_log_proc.call_log_proc (l_chr_err_code,
                 l_chr_err_msg,
                 13,
                 p_activity_day_id,
                 13,
                 'l_num_adj_diff > 0 ',
                 SUBSTR (SQLERRM, 1, 255),
                  p_arrival||p_adjorn);           
          
      ELSIF l_num_adj_diff < 0
      THEN
          DBMS_OUTPUT.PUT_LINE ('Here10 : '  || l_dte_date_adj);  
           bi_call_log_proc.call_log_proc (l_chr_err_code,
                 l_chr_err_msg,
                 13,
                 p_activity_day_id,
                 13,
                 'l_num_adj_diff < 0 ',
                 SUBSTR (SQLERRM, 1, 255),
                  p_arrival||p_adjorn); 

         /* BEGIN       
            DELETE FROM  bi_request_activity
             WHERE REQUEST_ACTIVITY_DAY_ID = p_activity_day_id    
               AND activity_start_time + (duration * (1/24/60)) > p_adjorn;
          EXCEPTION
            WHEN OTHERS
            THEN
             l_chr_succ_adj := 'F';
          END;            
          DBMS_OUTPUT.PUT_LINE ('Here10 : ' || l_chr_succ_adj );    
          */
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
     AND attribute_info ='Y'
     AND request_type_activity_id = 3;
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
    bi_call_log_proc.call_log_proc (l_chr_err_code,
             l_chr_err_msg,
             13,
             p_activity_day_id,
             13,
             'Unable to get the difference between arrival and adjourn activities',
             SUBSTR (SQLERRM, 1, 255),
              p_arrival||p_adjorn);    
  WHEN check_arr_adj
  THEN
     out_chr_err_msg := 'Please check the arrival and adjourn activities'; 
     bi_call_log_proc.call_log_proc (l_chr_err_code,
             l_chr_err_msg,
             13,
             p_activity_day_id,
             13,
             'Please check the arrival and adjourn activities',
             SUBSTR (SQLERRM, 1, 255),
              p_arrival||p_adjorn);     
  WHEN check_ip
  THEN
    out_chr_err_msg := 'Please check the input params';
    bi_call_log_proc.call_log_proc (l_chr_err_code,
             l_chr_err_msg,
             13,
             p_activity_day_id,
             13,
             'Please check the input params',
             SUBSTR (SQLERRM, 1, 255),
              p_arrival||p_adjorn);    
  WHEN no_event_date
  THEN
    out_chr_err_msg := 'Event date doesnt exists in the activity day';
    bi_call_log_proc.call_log_proc (l_chr_err_code,
             l_chr_err_msg,
             13,
             p_activity_day_id,
             13,
             'Event date doesnt exists in the activity day',
             SUBSTR (SQLERRM, 1, 255),
              p_arrival||p_adjorn);
  WHEN OTHERS
  THEN
      DBMS_OUTPUT.PUT_LINE ('HERE' || SQLERRM);
 END;   

END;
/