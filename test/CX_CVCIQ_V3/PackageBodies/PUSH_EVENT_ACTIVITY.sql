CREATE OR REPLACE PACKAGE BODY cx_cvciq_v3."PUSH_EVENT_ACTIVITY" 
AS
PROCEDURE main_proc(    
                           out_chr_err_code   OUT VARCHAR2,
                           out_chr_err_msg    OUT VARCHAR2,
                           p_activity_day_id  IN NUMBER,
                           p_req_act_id       IN NUMBER,
                           p_room             IN NUMBER ,
                           p_source_time      IN TIMESTAMP,
                           p_target_time      IN TIMESTAMP,
                           p_duration         IN NUMBER
                           )
IS
l_chr_err_code VARCHAR2(2000);
l_chr_err_msg VARCHAR2(2000);
l_room_exists  VARCHAR2(20);

BEGIN
 
     DBMS_OUTPUT.PUT_LINE ('Calling push_activity since room is  null' ||p_room  );
     
     BEGIN
        SELECT DISTINCT NVL(room,1)
        INTO l_room_exists
        FROM bi_request_activity a 
        WHERE request_activity_day_id = p_activity_day_id;
     EXCEPTION
       WHEN TOO_MANY_ROWS
       THEN
        l_room_exists := 2;
       WHEN OTHERS
       THEN
          l_room_exists := 2;
     END;


 IF l_room_exists = 1
 THEN
 
     DBMS_OUTPUT.PUT_LINE ('Calling push_activity since room is  null' );
  
   BEGIN
       push_activity_upd(    
                           l_chr_err_code   ,
                           l_chr_err_msg    ,
                           p_activity_day_id  ,
                           p_req_act_id   ,
                           p_source_time    ,
                           p_target_time  ,
                           p_duration
                    );
   EXCEPTION
    WHEN OTHERS
    THEN
                   bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             12,
                             p_activity_day_id,
                             p_room,
                             'Error while calling push_activity_upd ' ,
                             SUBSTR (SQLERRM, 1, 255),
                             p_source_time||p_target_time); 
   END;   
                     
 ELSE
 
    DBMS_OUTPUT.PUT_LINE ('Calling push_activity_upd since room is null' );
 
   BEGIN
           push_activity(    
                           l_chr_err_code   ,
                           l_chr_err_msg    ,
                           p_activity_day_id  ,
                           p_req_act_id   ,
                           p_room         ,                           
                           p_source_time    ,
                           p_target_time  ,
                           p_duration
                    );
   EXCEPTION
    WHEN OTHERS
    THEN
      bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             12,
                             p_activity_day_id,
                             p_room,
                             'Error while calling push_activity' ,
                             SUBSTR (SQLERRM, 1, 255),
                             p_source_time||p_target_time); 
   END; 
                      
 END IF;
 
EXCEPTION
 WHEN OTHERS
 THEN
    bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             12,
                             p_activity_day_id,
                             p_room,
                             'Error while calling main ' ,
                             SUBSTR (SQLERRM, 1, 255),
                             p_source_time||p_target_time); 
END;                           

PROCEDURE push_activity(    
                           out_chr_err_code   OUT VARCHAR2,
                           out_chr_err_msg    OUT VARCHAR2,
                           p_activity_day_id  IN NUMBER,
                           p_req_act_id       IN NUMBER,
                           p_room             IN NUMBER,
                           p_source_time      IN TIMESTAMP,
                           p_target_time      IN TIMESTAMP,
                           p_duration         IN NUMBER
                           )
IS
/************************************************************************************
*Purpose: This procedure is called when ever there is a drag and drop of activities *
* are performed in UI Agenda section.                                               *
*Also when there is an increase or decrease of duration or change in starttime      *
*************************************************************************************/
l_chr_err_code       VARCHAR2 (300);
l_chr_err_msg        VARCHAR2 (300);
l_start_next TIMESTAMP;
l_second_id NUMBER;
l_second_acttime TIMESTAMP;
l_second_endtime TIMESTAMP;
l_second_duration NUMBER;
l_same_room NUMBER;
l_id_bw_duration NUMBER;
l_num_bw_id  NUMBER  ;
p_bwtime TIMESTAMP;
p_sametime TIMESTAMP;
l_id_duration NUMBER;
l_num_sametime_id NUMBER ;
l_act_duration NUMBER;
l_donot_update VARCHAR2(5);
l_add_duration NUMBER;
l_act_time TIMESTAMP;
l_request_type_id NUMBER ;

CURSOR C1 
IS
SELECT id,
       activity_start_time ,
       activity_start_time + (duration * (1/24/60)) end_time ,
       duration,
       room,
       attribute_info,
       updated_ts
  FROM bi_request_activity a    
 WHERE request_activity_day_id = p_activity_day_id
  AND  room = p_room 
  AND attribute_info ='P'
 ORDER by activity_start_time ASC;


CURSOR C2 
IS
 SELECT id,
       activity_start_time ,
       activity_start_time + (duration * (1/24/60)) end_time ,
       duration,
       room,
       attribute_info,
       updated_ts
  FROM bi_request_activity a    
 WHERE request_activity_day_id = p_activity_day_id
  AND  room = p_room 
  AND attribute_info ='Y'
  AND updated_ts IN (SELECT MAX(updated_ts) 
                              FROM bi_request_activity  
                             WHERE request_activity_day_id = p_activity_day_id
                               AND room = p_room 
                               AND attribute_info ='Y');
  
 BEGIN     


          DBMS_OUTPUT.PUT_LINE ('Before first room update' );
          

      
           BEGIN
            SELECT duration ,
                   activity_start_time,
                   request_type_activity_id
              INTO l_act_duration,
                   l_act_time,
                   l_request_type_id --after catering section is separated
              FROM bi_request_activity
             WHERE request_activity_day_id = p_activity_day_id
               AND room = p_room
               AND id = p_req_act_id
               AND activity_start_time = p_source_time
               AND NVL(attribute_info,'N') ='N' ;
           EXCEPTION
             WHEN OTHERS
             THEN
              bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             12,
                             p_activity_day_id,
                             p_room,
                             'Error getting details from bi_request_activity ' ,
                             SUBSTR (SQLERRM, 1, 255),
                             p_source_time||p_target_time);
           END;
           
           DBMS_OUTPUT.PUT_LINE ('Duration from input :' || p_duration);   
           DBMS_OUTPUT.PUT_LINE ('Duration from DB :' || l_act_duration);           
       
              BEGIN
                bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             12,
                             p_activity_day_id,
                             p_room,
                             'UPDATE bi_request_activity for the chosen activity with the targettime',
                             SUBSTR (SQLERRM, 1, 255),
                              p_source_time||p_target_time);
              EXCEPTION
                 WHEN OTHERS
                 THEN
                    NULL;
              END;
           
           
            BEGIN 
             UPDATE bi_request_activity 
               SET activity_start_time = p_target_time,
                   attribute_info ='Y',
                   updated_ts = CURRENT_TIMESTAMP,
                   duration = p_duration,
                   room = p_room
               WHERE activity_start_time = p_source_time
                 AND request_activity_day_id = p_activity_day_id
                 AND id = p_req_act_id
                 AND request_type_activity_id = l_request_type_id
                 --AND room = p_room
                 AND NVL(attribute_info,'N') ='N' ;
             EXCEPTION
               WHEN OTHERS
               THEN
                  bi_call_log_proc.call_log_proc (l_chr_err_code,
                                 l_chr_err_msg,
                                 12,
                                 p_activity_day_id,
                                 p_room,
                                 'Error updating bi_request_activity to Y' ,
                                 SUBSTR (SQLERRM, 1, 255),
                                 p_source_time||p_target_time);         
             END;                  
                 
                 DBMS_OUTPUT.PUT_LINE ('Count at first upd :' || SQL%ROWCOUNT);  
                 
            BEGIN          
             UPDATE bi_request_activity 
                SET attribute_info ='P'
               WHERE (activity_start_time > p_target_time OR activity_start_time = p_target_time)
                 AND request_activity_day_id = p_activity_day_id
                 AND request_type_activity_id = l_request_type_id
                 AND room = p_room
                 AND NVL(attribute_info,'N') ='N' ;
                     
                 DBMS_OUTPUT.PUT_LINE ('Count at other upd :' || SQL%ROWCOUNT);
             EXCEPTION
               WHEN OTHERS
               THEN
                  bi_call_log_proc.call_log_proc (l_chr_err_code,
                                 l_chr_err_msg,
                                 12,
                                 p_activity_day_id,
                                 p_room,
                                 'Error updating bi_request_activity to P' ,
                                 SUBSTR (SQLERRM, 1, 255),
                                 p_source_time||p_target_time);         
             END;     
 
              BEGIN
                bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             12,
                             p_activity_day_id,
                             p_room,
                             'UPDATE bi_request_activity for next activity with the targettime',
                             SUBSTR (SQLERRM, 1, 255),
                              p_source_time||p_target_time);
              EXCEPTION
                 WHEN OTHERS
                 THEN
                    NULL;
              END; 
                 
               FOR rec_c1 IN c1
               LOOP
                 
                     DBMS_OUTPUT.PUT_LINE ('Pending ID :' || rec_c1.id);
                     DBMS_OUTPUT.PUT_LINE ('Activity time :' || rec_c1.activity_start_time);
                   
                    
                        FOR rec_c2 IN c2
                        LOOP
                            l_second_id := rec_c2.id;
                            l_second_acttime := rec_c2.activity_start_time;
                            l_second_duration := rec_c2.duration;
                            l_second_endtime := rec_c2.end_time;
                        END LOOP;
                        
                                                                            
                        DBMS_OUTPUT.PUT_LINE ('--------------Second cursor -------------------- :' );
                        DBMS_OUTPUT.PUT_LINE ('l_second_id :' || l_second_id);
                        DBMS_OUTPUT.PUT_LINE ('l_second_acttime :' || l_second_acttime);
                        DBMS_OUTPUT.PUT_LINE ('l_second_duration :' || l_second_duration);
                   
                    BEGIN
                      SELECT id,duration
                        INTO l_num_sametime_id,l_id_duration
                        FROM bi_request_activity a    
                       WHERE request_activity_day_id = p_activity_day_id
                         AND room = p_room 
                         AND activity_start_time =  rec_c1.activity_start_time
                         AND rec_c1.activity_start_time NOT BETWEEN activity_start_time + (1 * (1/24/60)) AND activity_start_time + (duration * (1/24/60)) 
                         AND attribute_info ='Y'
                         ORDER by activity_start_time ASC;
                    EXCEPTION
                     WHEN TOO_MANY_ROWS
                     THEN
                         SELECT id,duration
                            INTO l_num_sametime_id,l_id_duration
                            FROM bi_request_activity a    
                            WHERE request_activity_day_id = p_activity_day_id
                             AND room = p_room 
                             AND activity_start_time =   rec_c1.activity_start_time
                             AND rec_c1.activity_start_time NOT BETWEEN activity_start_time + (1 * (1/24/60))  AND activity_start_time + (duration * (1/24/60)) 
                             AND attribute_info ='Y'
                             AND updated_ts 
                              IN (SELECT MAX(updated_ts) 
                                    FROM bi_request_activity  
                                   WHERE request_activity_day_id = p_activity_day_id
                                     AND room = p_room 
                                     AND activity_start_time =   rec_c1.activity_start_time
                                     AND attribute_info ='Y'
                                     AND  rec_c1.activity_start_time NOT BETWEEN activity_start_time + (1 * (1/24/60))  AND activity_start_time + (duration * (1/24/60)))
                              ORDER by updated_ts DESC;   
                     WHEN OTHERS
                     THEN
                       DBMS_OUTPUT.PUT_LINE (' In others in sametime');
                       l_num_sametime_id :=99999999;
                       l_id_duration:= 99999999;
                          bi_call_log_proc.call_log_proc (l_chr_err_code,
                                             l_chr_err_msg,
                                             12,
                                             p_activity_day_id,
                                             p_room,
                                             'In too many rows -Error getting id and duration from bi_request_activity' ,
                                             SUBSTR (SQLERRM, 1, 255),
                                             p_source_time||p_target_time);                               
                    END;  
                   
                    IF l_num_sametime_id <> 99999999
                    THEN
                    
                        DBMS_OUTPUT.PUT_LINE ('--------------Same time check-------------------- :' );
                        DBMS_OUTPUT.PUT_LINE ('Before third upd for id :' || rec_c1.id);
                        DBMS_OUTPUT.PUT_LINE ('Same time id :' || l_num_sametime_id);
                        DBMS_OUTPUT.PUT_LINE ('Its duration :' || l_id_duration);
                      
                          BEGIN
                            bi_call_log_proc.call_log_proc (l_chr_err_code,
                                         l_chr_err_msg,
                                         12,
                                         p_activity_day_id,
                                         p_room,
                                         'UPDATE bi_request_activity for next activity having the sametime',
                                         SUBSTR (SQLERRM, 1, 255),
                                          p_source_time||p_target_time);
                          EXCEPTION
                             WHEN OTHERS
                             THEN
                                NULL;
                          END; 
                        
                        IF l_second_id = l_num_sametime_id OR l_second_id = 0
                        THEN
                        
                           DBMS_OUTPUT.PUT_LINE ('l_add_duration before third update : ' || l_add_duration);
                           
                          BEGIN  
                            UPDATE bi_request_activity 
                               SET activity_start_time = activity_start_time + ((l_id_duration) * (1/24/60)) ,
                                   attribute_info ='Y',
                                   updated_ts = CURRENT_TIMESTAMP
                               WHERE activity_start_time = rec_c1.activity_start_time
                                 AND request_activity_day_id = p_activity_day_id
                                 AND room = p_room
                                 AND attribute_info ='P' 
                                 AND id = rec_c1.id;
                          EXCEPTION
                           WHEN OTHERS
                           THEN
                              bi_call_log_proc.call_log_proc (l_chr_err_code,
                                             l_chr_err_msg,
                                             12,
                                             p_activity_day_id,
                                             p_room,
                                             'Error updating activity_start_time in bi_request_activity ' ,
                                             SUBSTR (SQLERRM, 1, 255),
                                             p_source_time||p_target_time);         
                           END;                                  
                          DBMS_OUTPUT.PUT_LINE ('Count at third upd :' || SQL%ROWCOUNT);
                       
                       ELSE                         
                    
                        BEGIN
                           DBMS_OUTPUT.PUT_LINE ('l_add_duration before third update with second cursor : ' || l_add_duration);
                            UPDATE bi_request_activity 
                               SET activity_start_time = l_second_acttime + ((l_second_duration) * (1/24/60)) ,
                                   attribute_info ='Y',
                                   updated_ts = CURRENT_TIMESTAMP
                               WHERE activity_start_time = rec_c1.activity_start_time
                                 AND request_activity_day_id = p_activity_day_id
                                 AND room = p_room
                                 AND attribute_info ='P' 
                                 AND id = rec_c1.id;
                          EXCEPTION
                           WHEN OTHERS
                           THEN
                              bi_call_log_proc.call_log_proc (l_chr_err_code,
                                             l_chr_err_msg,
                                             12,
                                             p_activity_day_id,
                                             p_room,
                                             'Error updating activity_start_time again in bi_request_activity ' ,
                                             SUBSTR (SQLERRM, 1, 255),
                                             p_source_time||p_target_time);         
                           END;                                   
                         DBMS_OUTPUT.PUT_LINE ('Count at third upd with second cursor :' || SQL%ROWCOUNT);
                      END IF;
                   
                   END IF;
                    
                    BEGIN
                      SELECT id,duration
                        INTO l_num_bw_id,l_id_bw_duration
                        FROM bi_request_activity a    
                       WHERE request_activity_day_id = p_activity_day_id
                         AND room = p_room 
                         AND rec_c1.activity_start_time BETWEEN activity_start_time + (1 * (1/24/60)) AND activity_start_time + (duration * (1/24/60)) 
                         AND attribute_info ='Y'
                         ORDER by activity_start_time ASC;
                    EXCEPTION
                     WHEN TOO_MANY_ROWS
                     THEN
                       SELECT id,duration
                         INTO l_num_bw_id,l_id_bw_duration
                         FROM bi_request_activity a    
                       WHERE request_activity_day_id = p_activity_day_id
                         AND room = p_room 
                         AND rec_c1.activity_start_time BETWEEN activity_start_time + (1 * (1/24/60))  AND activity_start_time + (duration * (1/24/60)) 
                         AND attribute_info ='Y'
                         AND updated_ts IN (SELECT MAX(updated_ts) 
                                              FROM bi_request_activity  
                                             WHERE request_activity_day_id = p_activity_day_id
                                               AND room = p_room 
                                               AND attribute_info ='Y'
                                               AND rec_c1.activity_start_time BETWEEN activity_start_time + (1 * (1/24/60))  AND activity_start_time + (duration * (1/24/60)))
                         ORDER by activity_start_time ASC;
                     WHEN OTHERS
                     THEN
                       DBMS_OUTPUT.PUT_LINE (' In others in b/w');
                       l_num_bw_id := 99999999;
                       l_id_bw_duration  := 99999999;
                              bi_call_log_proc.call_log_proc (l_chr_err_code,
                                             l_chr_err_msg,
                                             12,
                                             p_activity_day_id,
                                             p_room,
                                             'In too many rows - Error getting details from bi_request_activity again' ,
                                             SUBSTR (SQLERRM, 1, 255),
                                             p_source_time||p_target_time);         
                    END;  
                   
                    IF l_num_bw_id <> 99999999
                    THEN
                      
                      DBMS_OUTPUT.PUT_LINE ('------------------In between time check---------------- :' );
                      DBMS_OUTPUT.PUT_LINE ('Before fourth upd for id :' || rec_c1.id);
                      DBMS_OUTPUT.PUT_LINE ('b/w time id :' || l_num_bw_id);
                      DBMS_OUTPUT.PUT_LINE ('Its duration :' || l_id_bw_duration);
                      
                           BEGIN
                            bi_call_log_proc.call_log_proc (l_chr_err_code,
                                         l_chr_err_msg,
                                         12,
                                         p_activity_day_id,
                                         p_room,
                                         'UPDATE bi_request_activity for next activity having overlapping times',
                                         SUBSTR (SQLERRM, 1, 255),
                                          p_source_time||p_target_time);
                          EXCEPTION
                             WHEN OTHERS
                             THEN
                                NULL;
                          END; 
                          
                        IF l_second_id = l_num_sametime_id OR l_second_id = 0
                        THEN
                        
                            DBMS_OUTPUT.PUT_LINE ('l_add_duration before fourth update : ' || l_add_duration);
                            
                           BEGIN 
                             UPDATE bi_request_activity 
                               SET activity_start_time = activity_start_time + ((l_id_bw_duration) * (1/24/60)) ,
                                   attribute_info ='Y',
                                   updated_ts = CURRENT_TIMESTAMP
                               WHERE activity_start_time = rec_c1.activity_start_time
                                 AND request_activity_day_id = p_activity_day_id
                                 AND room = p_room
                                 AND attribute_info ='P' 
                                 AND id = rec_c1.id;
                                DBMS_OUTPUT.PUT_LINE ('Count at fourth upd  :' || SQL%ROWCOUNT); 
                           EXCEPTION        
                             WHEN OTHERS
                             THEN
                                  bi_call_log_proc.call_log_proc (l_chr_err_code,
                                                 l_chr_err_msg,
                                                 12,
                                                 p_activity_day_id,
                                                 p_room,
                                                 'Error updating bi_request_activity update3' ,
                                                 SUBSTR (SQLERRM, 1, 255),
                                                 p_source_time||p_target_time);         
                              END;                                  
                        ELSE
                          
                           DBMS_OUTPUT.PUT_LINE ('l_second_endtime : '|| l_second_endtime);
                           DBMS_OUTPUT.PUT_LINE ('Current record activity_start_time : '|| l_second_acttime);
                           DBMS_OUTPUT.PUT_LINE ('rec_c1.activity_start_time : '|| rec_c1.activity_start_time);
                           
                       IF   rec_c1.activity_start_time > l_second_endtime OR rec_c1.activity_start_time = l_second_endtime
                       THEN
                          NULL;
                       ELSE
                           BEGIN
                            UPDATE bi_request_activity 
                               SET activity_start_time = l_second_acttime + ((l_second_duration) * (1/24/60)) ,
                                   attribute_info ='Y',
                                   updated_ts = CURRENT_TIMESTAMP
                               WHERE activity_start_time = rec_c1.activity_start_time
                                 AND request_activity_day_id = p_activity_day_id
                                 AND room = p_room
                                 AND attribute_info ='P' 
                                 AND id = rec_c1.id;
                           EXCEPTION        
                             WHEN OTHERS
                             THEN
                                  bi_call_log_proc.call_log_proc (l_chr_err_code,
                                                 l_chr_err_msg,
                                                 12,
                                                 p_activity_day_id,
                                                 p_room,
                                                 'Error updating bi_request_activity update4' ,
                                                 SUBSTR (SQLERRM, 1, 255),
                                                 p_source_time||p_target_time);         
                            END;      
                            
                           DBMS_OUTPUT.PUT_LINE ('Count at fourth upd with second cursor :' || SQL%ROWCOUNT); 
                           
                           END IF;
                           
                         END IF;                                 
                                 

                    END IF;

                   
               END LOOP;
               
                  
      BEGIN
      
          UPDATE bi_request_activity 
             SET attribute_info = NULL
           WHERE request_activity_day_id = p_activity_day_id
             AND room = p_room;
       EXCEPTION        
         WHEN OTHERS
         THEN
              bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             12,
                             p_activity_day_id,
                             p_room,
                             'Error resetting bi_request_activity ' ,
                             SUBSTR (SQLERRM, 1, 255),
                             p_source_time||p_target_time);         
      END;
      
      COMMIT;
      
  EXCEPTION
    WHEN OTHERS
    THEN
     NULL;
   END;

PROCEDURE push_activity_upd(    
                           out_chr_err_code   OUT VARCHAR2,
                           out_chr_err_msg    OUT VARCHAR2,
                           p_activity_day_id  IN NUMBER,
                           p_req_act_id       IN NUMBER,
                   --        p_room             IN NUMBER,
                           p_source_time      IN TIMESTAMP,
                           p_target_time      IN TIMESTAMP,
                           p_duration         IN NUMBER
                           )
IS
/************************************************************************************
*Purpose: This procedure is called when ever there is a drag and drop of activities *
* are performed in UI Agenda section.                                               *
*Also when there is an increase or decrease of duration or change in starttime      *
*************************************************************************************/
l_chr_err_code       VARCHAR2 (300);
l_chr_err_msg        VARCHAR2 (300);
l_start_next TIMESTAMP;
l_second_id NUMBER;
l_second_acttime TIMESTAMP;
l_second_endtime TIMESTAMP;
l_second_duration NUMBER;
l_same_room NUMBER;
l_id_bw_duration NUMBER;
l_num_bw_id  NUMBER  ;
p_bwtime TIMESTAMP;
p_sametime TIMESTAMP;
l_id_duration NUMBER;
l_num_sametime_id NUMBER ;
l_act_duration NUMBER;
l_donot_update VARCHAR2(5);
l_add_duration NUMBER;
l_act_time TIMESTAMP;
l_request_type_id NUMBER ;
l_room NUMBER;

CURSOR C1 
IS
SELECT id,
       activity_start_time ,
       activity_start_time + (duration * (1/24/60)) end_time ,
       duration,
       --room,
       attribute_info,
       updated_ts
  FROM bi_request_activity a    
 WHERE request_activity_day_id = p_activity_day_id
  --AND  room = p_room 
  AND attribute_info ='P'
 ORDER by activity_start_time ASC;


CURSOR C2 
IS
 SELECT id,
       activity_start_time ,
       activity_start_time + (duration * (1/24/60)) end_time ,
       duration,
    ---   room,
       attribute_info,
       updated_ts
  FROM bi_request_activity a    
 WHERE request_activity_day_id = p_activity_day_id
 --- AND  room = p_room 
  AND attribute_info ='Y'
  AND updated_ts IN (SELECT MAX(updated_ts) 
                              FROM bi_request_activity  
                             WHERE request_activity_day_id = p_activity_day_id
                             --  AND room = p_room 
                               AND attribute_info ='Y');
  
 BEGIN     


          DBMS_OUTPUT.PUT_LINE ('Before first room update' );
          

           BEGIN
            SELECT duration ,
                   activity_start_time,
                   request_type_activity_id
              INTO l_act_duration,
                   l_act_time,
                   l_request_type_id --after catering section is separated
              FROM bi_request_activity
             WHERE request_activity_day_id = p_activity_day_id
              --- AND NVL(room,111) = l_room
               AND id = p_req_act_id
               AND activity_start_time = p_source_time
               AND NVL(attribute_info,'N') ='N' ;
           EXCEPTION
             WHEN OTHERS
             THEN
              bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             12,
                             p_activity_day_id,
                             l_room,
                             'Error getting details from bi_request_activity ' ,
                             SUBSTR (SQLERRM, 1, 255),
                             p_source_time||p_target_time);
           END;
           
           DBMS_OUTPUT.PUT_LINE ('Duration from input :' || p_duration);   
           DBMS_OUTPUT.PUT_LINE ('Duration from DB :' || l_act_duration);           
       
              BEGIN
                bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             12,
                             p_activity_day_id,
                             l_room,
                             'UPDATE bi_request_activity for the chosen activity with the targettime',
                             SUBSTR (SQLERRM, 1, 255),
                              p_source_time||p_target_time);
              EXCEPTION
                 WHEN OTHERS
                 THEN
                    NULL;
              END;
           
           
            BEGIN 
             UPDATE bi_request_activity 
               SET activity_start_time = p_target_time,
                   attribute_info ='Y',
                   updated_ts = CURRENT_TIMESTAMP,
                   duration = p_duration--,
              --     room = l_room
               WHERE activity_start_time = p_source_time
                 AND request_activity_day_id = p_activity_day_id
                 AND id = p_req_act_id
                 AND request_type_activity_id = l_request_type_id
                 --AND room = p_room
                 AND NVL(attribute_info,'N') ='N' ;
             EXCEPTION
               WHEN OTHERS
               THEN
                  bi_call_log_proc.call_log_proc (l_chr_err_code,
                                 l_chr_err_msg,
                                 12,
                                 p_activity_day_id,
                                 l_room,
                                 'Error updating bi_request_activity to Y' ,
                                 SUBSTR (SQLERRM, 1, 255),
                                 p_source_time||p_target_time);         
             END;                  
                 
                 DBMS_OUTPUT.PUT_LINE ('Count at first upd :' || SQL%ROWCOUNT);  
                 
            BEGIN          
             UPDATE bi_request_activity 
                SET attribute_info ='P'
               WHERE (activity_start_time > p_target_time OR activity_start_time = p_target_time)
                 AND request_activity_day_id = p_activity_day_id
                 AND request_type_activity_id = l_request_type_id
                -- AND NVL(room,111) = l_room
                 AND NVL(attribute_info,'N') ='N' ;
                     
                 DBMS_OUTPUT.PUT_LINE ('Count at other upd :' || SQL%ROWCOUNT);
             EXCEPTION
               WHEN OTHERS
               THEN
                  bi_call_log_proc.call_log_proc (l_chr_err_code,
                                 l_chr_err_msg,
                                 12,
                                 p_activity_day_id,
                                 l_room,
                                 'Error updating bi_request_activity to P' ,
                                 SUBSTR (SQLERRM, 1, 255),
                                 p_source_time||p_target_time);         
             END;     
 
              BEGIN
                bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             12,
                             p_activity_day_id,
                             l_room,
                             'UPDATE bi_request_activity for next activity with the targettime',
                             SUBSTR (SQLERRM, 1, 255),
                              p_source_time||p_target_time);
              EXCEPTION
                 WHEN OTHERS
                 THEN
                    NULL;
              END; 
                 
               FOR rec_c1 IN c1
               LOOP
                 
                     DBMS_OUTPUT.PUT_LINE ('Pending ID :' || rec_c1.id);
                     DBMS_OUTPUT.PUT_LINE ('Activity time :' || rec_c1.activity_start_time);
                   
                    
                        FOR rec_c2 IN c2
                        LOOP
                            l_second_id := rec_c2.id;
                            l_second_acttime := rec_c2.activity_start_time;
                            l_second_duration := rec_c2.duration;
                            l_second_endtime := rec_c2.end_time;
                        END LOOP;
                        
                                                                            
                        DBMS_OUTPUT.PUT_LINE ('--------------Second cursor -------------------- :' );
                        DBMS_OUTPUT.PUT_LINE ('l_second_id :' || l_second_id);
                        DBMS_OUTPUT.PUT_LINE ('l_second_acttime :' || l_second_acttime);
                        DBMS_OUTPUT.PUT_LINE ('l_second_duration :' || l_second_duration);
                   
                    BEGIN
                      SELECT id,duration
                        INTO l_num_sametime_id,l_id_duration
                        FROM bi_request_activity a    
                       WHERE request_activity_day_id = p_activity_day_id
                      --   AND NVL(room,111) = l_room 
                         AND activity_start_time =  rec_c1.activity_start_time
                         AND rec_c1.activity_start_time NOT BETWEEN activity_start_time + (1 * (1/24/60)) AND activity_start_time + (duration * (1/24/60)) 
                         AND attribute_info ='Y'
                         ORDER by activity_start_time ASC;
                    EXCEPTION
                     WHEN TOO_MANY_ROWS
                     THEN
                         SELECT id,duration
                            INTO l_num_sametime_id,l_id_duration
                            FROM bi_request_activity a    
                            WHERE request_activity_day_id = p_activity_day_id
                          ---   AND NVL(room,111) = l_room 
                             AND activity_start_time =   rec_c1.activity_start_time
                             AND rec_c1.activity_start_time NOT BETWEEN activity_start_time + (1 * (1/24/60))  AND activity_start_time + (duration * (1/24/60)) 
                             AND attribute_info ='Y'
                             AND updated_ts 
                              IN (SELECT MAX(updated_ts) 
                                    FROM bi_request_activity  
                                   WHERE request_activity_day_id = p_activity_day_id
                                  --   AND NVL(room,111) = l_room 
                                     AND activity_start_time =   rec_c1.activity_start_time
                                     AND attribute_info ='Y'
                                     AND  rec_c1.activity_start_time NOT BETWEEN activity_start_time + (1 * (1/24/60))  AND activity_start_time + (duration * (1/24/60)))
                              ORDER by updated_ts DESC;   
                     WHEN OTHERS
                     THEN
                       DBMS_OUTPUT.PUT_LINE (' In others in sametime');
                       l_num_sametime_id :=99999999;
                       l_id_duration:= 99999999;
                          bi_call_log_proc.call_log_proc (l_chr_err_code,
                                             l_chr_err_msg,
                                             12,
                                             p_activity_day_id,
                                             l_room,
                                             'In too many rows -Error getting id and duration from bi_request_activity' ,
                                             SUBSTR (SQLERRM, 1, 255),
                                             p_source_time||p_target_time);                               
                    END;  
                   
                    IF l_num_sametime_id <> 99999999
                    THEN
                    
                        DBMS_OUTPUT.PUT_LINE ('--------------Same time check-------------------- :' );
                        DBMS_OUTPUT.PUT_LINE ('Before third upd for id :' || rec_c1.id);
                        DBMS_OUTPUT.PUT_LINE ('Same time id :' || l_num_sametime_id);
                        DBMS_OUTPUT.PUT_LINE ('Its duration :' || l_id_duration);
                      
                          BEGIN
                            bi_call_log_proc.call_log_proc (l_chr_err_code,
                                         l_chr_err_msg,
                                         12,
                                         p_activity_day_id,
                                         l_room,
                                         'UPDATE bi_request_activity for next activity having the sametime',
                                         SUBSTR (SQLERRM, 1, 255),
                                          p_source_time||p_target_time);
                          EXCEPTION
                             WHEN OTHERS
                             THEN
                                NULL;
                          END; 
                        
                        IF l_second_id = l_num_sametime_id OR l_second_id = 0
                        THEN
                        
                           DBMS_OUTPUT.PUT_LINE ('l_add_duration before third update : ' || l_add_duration);
                           
                          BEGIN  
                            UPDATE bi_request_activity 
                               SET activity_start_time = activity_start_time + ((l_id_duration) * (1/24/60)) ,
                                   attribute_info ='Y',
                                   updated_ts = CURRENT_TIMESTAMP
                               WHERE activity_start_time = rec_c1.activity_start_time
                                 AND request_activity_day_id = p_activity_day_id
                              --   AND NVL(room,111) = l_room
                                 AND attribute_info ='P' 
                                 AND id = rec_c1.id;
                          EXCEPTION
                           WHEN OTHERS
                           THEN
                              bi_call_log_proc.call_log_proc (l_chr_err_code,
                                             l_chr_err_msg,
                                             12,
                                             p_activity_day_id,
                                             l_room,
                                             'Error updating activity_start_time in bi_request_activity ' ,
                                             SUBSTR (SQLERRM, 1, 255),
                                             p_source_time||p_target_time);         
                           END;                                  
                          DBMS_OUTPUT.PUT_LINE ('Count at third upd :' || SQL%ROWCOUNT);
                       
                       ELSE                         
                    
                        BEGIN
                           DBMS_OUTPUT.PUT_LINE ('l_add_duration before third update with second cursor : ' || l_add_duration);
                            UPDATE bi_request_activity 
                               SET activity_start_time = l_second_acttime + ((l_second_duration) * (1/24/60)) ,
                                   attribute_info ='Y',
                                   updated_ts = CURRENT_TIMESTAMP
                               WHERE activity_start_time = rec_c1.activity_start_time
                                 AND request_activity_day_id = p_activity_day_id
                              ---   AND NVL(room,111) = l_room
                                 AND attribute_info ='P' 
                                 AND id = rec_c1.id;
                          EXCEPTION
                           WHEN OTHERS
                           THEN
                              bi_call_log_proc.call_log_proc (l_chr_err_code,
                                             l_chr_err_msg,
                                             12,
                                             p_activity_day_id,
                                             l_room,
                                             'Error updating activity_start_time again in bi_request_activity ' ,
                                             SUBSTR (SQLERRM, 1, 255),
                                             p_source_time||p_target_time);         
                           END;                                   
                         DBMS_OUTPUT.PUT_LINE ('Count at third upd with second cursor :' || SQL%ROWCOUNT);
                      END IF;
                   
                   END IF;
                    
                    BEGIN
                      SELECT id,duration
                        INTO l_num_bw_id,l_id_bw_duration
                        FROM bi_request_activity a    
                       WHERE request_activity_day_id = p_activity_day_id
                        -- AND NVL(room,111) = l_room 
                         AND rec_c1.activity_start_time BETWEEN activity_start_time + (1 * (1/24/60)) AND activity_start_time + (duration * (1/24/60)) 
                         AND attribute_info ='Y'
                         ORDER by activity_start_time ASC;
                    EXCEPTION
                     WHEN TOO_MANY_ROWS
                     THEN
                       SELECT id,duration
                         INTO l_num_bw_id,l_id_bw_duration
                         FROM bi_request_activity a    
                       WHERE request_activity_day_id = p_activity_day_id
                      ---   AND NVL(room,111) = l_room 
                         AND rec_c1.activity_start_time BETWEEN activity_start_time + (1 * (1/24/60))  AND activity_start_time + (duration * (1/24/60)) 
                         AND attribute_info ='Y'
                         AND updated_ts IN (SELECT MAX(updated_ts) 
                                              FROM bi_request_activity  
                                             WHERE request_activity_day_id = p_activity_day_id
                                             --  AND NVL(room,111) = l_room 
                                               AND attribute_info ='Y'
                                               AND rec_c1.activity_start_time BETWEEN activity_start_time + (1 * (1/24/60))  AND activity_start_time + (duration * (1/24/60)))
                         ORDER by activity_start_time ASC;
                     WHEN OTHERS
                     THEN
                       DBMS_OUTPUT.PUT_LINE (' In others in b/w');
                       l_num_bw_id := 99999999;
                       l_id_bw_duration  := 99999999;
                              bi_call_log_proc.call_log_proc (l_chr_err_code,
                                             l_chr_err_msg,
                                             12,
                                             p_activity_day_id,
                                             l_room,
                                             'In too many rows - Error getting details from bi_request_activity again' ,
                                             SUBSTR (SQLERRM, 1, 255),
                                             p_source_time||p_target_time);         
                    END;  
                   
                    IF l_num_bw_id <> 99999999
                    THEN
                      
                      DBMS_OUTPUT.PUT_LINE ('------------------In between time check---------------- :' );
                      DBMS_OUTPUT.PUT_LINE ('Before fourth upd for id :' || rec_c1.id);
                      DBMS_OUTPUT.PUT_LINE ('b/w time id :' || l_num_bw_id);
                      DBMS_OUTPUT.PUT_LINE ('Its duration :' || l_id_bw_duration);
                      
                           BEGIN
                            bi_call_log_proc.call_log_proc (l_chr_err_code,
                                         l_chr_err_msg,
                                         12,
                                         p_activity_day_id,
                                         l_room,
                                         'UPDATE bi_request_activity for next activity having overlapping times',
                                         SUBSTR (SQLERRM, 1, 255),
                                          p_source_time||p_target_time);
                          EXCEPTION
                             WHEN OTHERS
                             THEN
                                NULL;
                          END; 
                          
                        IF l_second_id = l_num_sametime_id OR l_second_id = 0
                        THEN
                        
                            DBMS_OUTPUT.PUT_LINE ('l_add_duration before fourth update : ' || l_add_duration);
                            
                           BEGIN 
                             UPDATE bi_request_activity 
                               SET activity_start_time = activity_start_time + ((l_id_bw_duration) * (1/24/60)) ,
                                   attribute_info ='Y',
                                   updated_ts = CURRENT_TIMESTAMP
                               WHERE activity_start_time = rec_c1.activity_start_time
                                 AND request_activity_day_id = p_activity_day_id
                               --  AND NVL(room,111) = l_room
                                 AND attribute_info ='P' 
                                 AND id = rec_c1.id;
                                DBMS_OUTPUT.PUT_LINE ('Count at fourth upd  :' || SQL%ROWCOUNT); 
                           EXCEPTION        
                             WHEN OTHERS
                             THEN
                                  bi_call_log_proc.call_log_proc (l_chr_err_code,
                                                 l_chr_err_msg,
                                                 12,
                                                 p_activity_day_id,
                                                 l_room,
                                                 'Error updating bi_request_activity update3' ,
                                                 SUBSTR (SQLERRM, 1, 255),
                                                 p_source_time||p_target_time);         
                              END;                                  
                        ELSE
                          
                           DBMS_OUTPUT.PUT_LINE ('l_second_endtime : '|| l_second_endtime);
                           DBMS_OUTPUT.PUT_LINE ('Current record activity_start_time : '|| l_second_acttime);
                           DBMS_OUTPUT.PUT_LINE ('rec_c1.activity_start_time : '|| rec_c1.activity_start_time);
                           
                       IF   rec_c1.activity_start_time > l_second_endtime OR rec_c1.activity_start_time = l_second_endtime
                       THEN
                          NULL;
                       ELSE
                           BEGIN
                            UPDATE bi_request_activity 
                               SET activity_start_time = l_second_acttime + ((l_second_duration) * (1/24/60)) ,
                                   attribute_info ='Y',
                                   updated_ts = CURRENT_TIMESTAMP
                               WHERE activity_start_time = rec_c1.activity_start_time
                                 AND request_activity_day_id = p_activity_day_id
                               --  AND NVL(room,111) = l_room
                                 AND attribute_info ='P' 
                                 AND id = rec_c1.id;
                           EXCEPTION        
                             WHEN OTHERS
                             THEN
                                  bi_call_log_proc.call_log_proc (l_chr_err_code,
                                                 l_chr_err_msg,
                                                 12,
                                                 p_activity_day_id,
                                                 l_room,
                                                 'Error updating bi_request_activity update4' ,
                                                 SUBSTR (SQLERRM, 1, 255),
                                                 p_source_time||p_target_time);         
                            END;      
                            
                           DBMS_OUTPUT.PUT_LINE ('Count at fourth upd with second cursor :' || SQL%ROWCOUNT); 
                           
                           END IF;
                           
                         END IF;                                 
                                 

                    END IF;

                   
               END LOOP;
               
                  
      BEGIN
      
          UPDATE bi_request_activity 
             SET attribute_info = NULL
           WHERE request_activity_day_id = p_activity_day_id;
         ---    AND NVL(room,111) = l_room;
       EXCEPTION        
         WHEN OTHERS
         THEN
              bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             12,
                             p_activity_day_id,
                             l_room,
                             'Error resetting bi_request_activity ' ,
                             SUBSTR (SQLERRM, 1, 255),
                             p_source_time||p_target_time);         
      END;
      
      COMMIT;
      
  EXCEPTION
    WHEN OTHERS
    THEN
     NULL;
   END;
                 
END;
/