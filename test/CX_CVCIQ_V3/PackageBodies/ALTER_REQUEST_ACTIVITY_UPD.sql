CREATE OR REPLACE PACKAGE BODY cx_cvciq_v3."ALTER_REQUEST_ACTIVITY_UPD" 
AS
   PROCEDURE main (out_chr_err_code      OUT VARCHAR2,
                   out_chr_err_msg       OUT VARCHAR2,
                   p_request_id       IN     NUMBER,
                   p_newevent_date    IN     VARCHAR2,
                   p_duration         IN     NUMBER)
   IS
      /************************************************************************************
      *Purpose: This procedure is called when ever there is a reschedule of event         *
      *occurrs in UI.                                                                     *
      *1) Alterdates procedure would be called if the new date and old date               *
      *are not in match.Duration increase or decrease also handled there.                 *
      *2) Extend dates is called when old and new dates are same but when there is a      *
      *duration increase.                                                                 *
      *3) Duration decrease with the same date handled in this proc by deleting the records*
      *************************************************************************************/
      l_chr_err_code       VARCHAR2 (300);
      l_chr_err_msg        VARCHAR2 (300);
      l_event_date         TIMESTAMP;
      l_num_duration       NUMBER;
      l_num_location       NUMBER;
      l_num_request_id     NUMBER;
      l_num_existcount     NUMBER;
      l_diff               NUMBER;
      l_dte_new            VARCHAR2 (300);
      l_num_counter        NUMBER;
  --    l_new_date           DATE;
      l_other_act_exist    VARCHAR2 (2) := 'N';
      l_event_exists       VARCHAR2 (2);
      l_chr_duration_inc   VARCHAR2 (2);
      l_extend_Date        VARCHAR2 (100);
      l_remove_date        DATE;
      l_timechar           VARCHAR2 (30);
      l_dte_original       DATE;

      CURSOR c1 (
         l_duration    NUMBER,
         lreqid        NUMBER)
      IS
           SELECT *
             FROM (  SELECT *
                       FROM (SELECT event_Date,
                                    ROW_NUMBER ()
                                    OVER (PARTITION BY event_Date
                                          ORDER BY event_Date)
                                       rn
                               FROM bi_request_activity_day
                              WHERE request_id = lreqid)
                      WHERE rn = 1
                   ORDER BY event_Date) alias_name
            WHERE ROWNUM <= l_duration
         ORDER BY ROWNUM;

   BEGIN
      
      --EXECUTE IMMEDIATE 'TRUNCATE TABLE bi_procedure_log';
      BEGIN 
         bi_call_log_proc.call_log_proc (l_chr_err_code,
                     l_chr_err_msg,
                     11,
                     p_duration,
                     p_request_id,
                     p_newevent_date,
                    SUBSTR (SQLERRM, 1, 255),
                    'Get all init params');
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;
      
      BEGIN
         SELECT start_date,
                duration,
                location_id,
                id
           INTO l_event_date,
                l_num_duration,
                l_num_location,
                l_num_request_id
           FROM bi_request
          WHERE id = p_request_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            bi_call_log_proc.call_log_proc (l_chr_err_code,
                           l_chr_err_msg,
                           11,
                           p_duration,
                           p_request_id,
                           p_newevent_date + 4,
                           SUBSTR (SQLERRM, 1, 255),null);
            DBMS_OUTPUT.PUT_LINE ('l_event_date in excep: ' || l_event_date);
            NULL;
      END;

      DBMS_OUTPUT.PUT_LINE ('l_event_date : ' || l_event_date);
      DBMS_OUTPUT.PUT_LINE ('l_num_duration : ' || l_num_duration);
      DBMS_OUTPUT.PUT_LINE ('l_num_request_id : ' || l_num_request_id);

      BEGIN
         SELECT p_duration - l_num_duration INTO l_diff FROM DUAL;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_diff := 0;
      END;

      BEGIN
         SELECT MAX (event_date)+1
           INTO l_dte_new
           FROM bi_request_activity_day
          WHERE request_id = p_request_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_dte_new := NULL;
      END;

      DBMS_OUTPUT.PUT_LINE ('Before updating bi_request ');
      DBMS_OUTPUT.PUT_LINE ('p_newevent_date : ' || p_newevent_date);
      DBMS_OUTPUT.PUT_LINE ('p_duration : ' || p_duration);
      DBMS_OUTPUT.PUT_LINE ('l_dte_new : ' || l_dte_new);

      BEGIN
        bi_call_log_proc.call_log_proc (l_chr_err_code,
                     l_chr_err_msg,
                     11,
                     p_duration,
                     p_request_id,
                     p_newevent_date,
                    SUBSTR (SQLERRM, 1, 255),
                    'Update bi_Request');
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      
      BEGIN
         UPDATE bi_request
            SET start_date = TO_DATE(p_newevent_date, 'DD-MON-YY HH:MI:SS AM'),
                duration = p_duration
          WHERE id = p_request_id;

         DBMS_OUTPUT.PUT_LINE ('p_duration 1: ' || p_duration);
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE ('l_chr_err_code : ' || l_chr_err_code);
            DBMS_OUTPUT.PUT_LINE ('l_chr_err_msg : ' || l_chr_err_msg);
            DBMS_OUTPUT.PUT_LINE ('p_duration : ' || p_duration);
            DBMS_OUTPUT.PUT_LINE ('p_request_id : ' || p_request_id);
            bi_call_log_proc.call_log_proc (
               l_chr_err_code,
               l_chr_err_msg,
               11,
               p_duration,
               p_request_id,
               'Error while updating bi_request' || p_newevent_date,
               SUBSTR (SQLERRM, 1, 255),null);
            DBMS_OUTPUT.PUT_LINE ('error : ' || SUBSTR (SQLERRM, 1, 255));
      END;

      DBMS_OUTPUT.PUT_LINE ('p_duration 2: ' || p_duration);

      BEGIN
         SELECT TO_CHAR (start_date, 'HH24:MI:SS AM')
           INTO l_timechar
           FROM bi_request
          WHERE id = p_request_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_timechar := NULL;
      END;

      DBMS_OUTPUT.PUT_LINE ('l_timechar : ' || l_timechar);
      DBMS_OUTPUT.PUT_LINE (
            'l_dte_new now should be ' || l_dte_new ||' '|| l_timechar);

      IF l_event_date = p_newevent_date        -- This would call extend dates
      THEN
         DBMS_OUTPUT.PUT_LINE (
            '----Same date so call extend dates procedure: ---');
         DBMS_OUTPUT.PUT_LINE (
            'l_dte_new before calling extend_dates ' || l_dte_new ||' '|| l_timechar);

         IF p_duration > l_num_duration
         THEN
            DBMS_OUTPUT.PUT_LINE ('l_diff : ' || l_diff);
            
              BEGIN
                bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             11,
                             p_duration,
                             p_request_id,
                             p_newevent_date,
                            SUBSTR (SQLERRM, 1, 255),
                            'Call extend_dates since duration is more');
              EXCEPTION
                 WHEN OTHERS
                 THEN
                    NULL;
              END;

            BEGIN
               extend_dates (l_chr_err_code,
                             l_chr_err_msg,
                             p_request_id,
                             --l_dte_new  + 1, --Need to pass the timestamp now
                             l_dte_new  ||' '|| l_timechar ,
                             l_diff,
                             p_duration);
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 1: ');
                  bi_call_log_proc.call_log_proc (l_chr_err_code,
                                 l_chr_err_msg,
                                 11,
                                 p_duration,
                                 p_request_id,
                                 'Error while calling extend_dates',
                                 SUBSTR (SQLERRM, 1, 255),null);
            END;
         END IF;

         DBMS_OUTPUT.PUT_LINE ('p_duration 3: ' || p_duration);

         IF l_num_duration > p_duration
         THEN
            DBMS_OUTPUT.PUT_LINE ('removing dates : ');

            FOR rec_c1 IN c1 (p_duration, p_request_id)
            LOOP
               l_remove_date := rec_c1.event_Date;
               DBMS_OUTPUT.PUT_LINE ('l_remove_date : ' || l_remove_date);

               BEGIN
                  UPDATE bi_request_activity_day
                     SET attribute1 = 'D'
                   WHERE event_Date = l_remove_date
                    AND request_id = p_request_id;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     DBMS_OUTPUT.PUT_LINE (
                        'Before calling bi_call_log_proc.call_log_proc 2: ');
                     bi_call_log_proc.call_log_proc (l_chr_err_code,
                                    l_chr_err_msg,
                                    11,
                                    p_duration,
                                    p_request_id,
                                    'Error while updating attribute1 to D',
                                    SUBSTR (SQLERRM, 1, 255),null);
               END;
            END LOOP;
            
              BEGIN
                bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             11,
                             p_duration,
                             p_request_id,
                             p_newevent_date,
                            SUBSTR (SQLERRM, 1, 255),
                            'When duration is less delete rooms ,activities,calendar dates');
              EXCEPTION
                 WHEN OTHERS
                 THEN
                    NULL;
              END;

            BEGIN
               DELETE FROM bi_request_act_day_break_room
                     WHERE request_activity_day_id IN
                              (SELECT id
                                 FROM bi_request_activity_day
                                WHERE     request_id = p_request_id
                                      AND attribute1 IS NULL);

               bi_call_log_proc.call_log_proc (
                  l_chr_err_code,
                  l_chr_err_msg,
                  11,
                  p_duration,
                  p_request_id,
                  'Error while deleting from bi_request_act_day_break_room',
                  SUBSTR (SQLERRM, 1, 255),null);
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 3: ');
                  bi_call_log_proc.call_log_proc (
                     l_chr_err_code,
                     l_chr_err_msg,
                     11,
                     p_duration,
                     p_request_id,
                     'Error while deleting from bi_request_act_day_break_room',
                     SUBSTR (SQLERRM, 1, 255),null);
            END;

            BEGIN
               DELETE FROM bi_request_activity
                     WHERE request_activity_day_id IN
                              (SELECT id
                                 FROM bi_request_activity_day
                                WHERE     request_id = p_request_id
                                      AND attribute1 IS NULL);
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 4: ');
                  bi_call_log_proc.call_log_proc (
                     l_chr_err_code,
                     l_chr_err_msg,
                     11,
                     p_duration,
                     p_request_id,
                     'Error while deleting from bi_request_activity',
                     SUBSTR (SQLERRM, 1, 255),null);
            END;

            BEGIN
               DELETE FROM bi_request_activity_day
                     WHERE attribute1 IS NULL AND request_id = p_request_id;
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 5: ');
                  bi_call_log_proc.call_log_proc (
                     l_chr_err_code,
                     l_chr_err_msg,
                     11,
                     p_duration,
                     p_request_id,
                     'Error while deleting from bi_request_activity_day',
                     SUBSTR (SQLERRM, 1, 255),null);
            END;

            BEGIN
               DELETE FROM bi_location_calendar
                     WHERE start_date IN
                                  (SELECT event_Date
                                     FROM bi_request_activity_day
                                    WHERE request_id = p_request_id
                                     AND attribute1 IS NULL)
                           AND request_id = p_request_id;
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 6: ');
                  bi_call_log_proc.call_log_proc (
                     l_chr_err_code,
                     l_chr_err_msg,
                     11,
                     p_duration,
                     p_request_id,
                     'Error while deleting from bi_location_calendar',
                     SUBSTR (SQLERRM, 1, 255),null);
            END;
         END IF;
      END IF;

      IF p_newevent_date <> l_event_date AND p_duration > l_num_duration
      THEN
         DBMS_OUTPUT.PUT_LINE (
            '----calling alter_dates since dates are different ---- ');
         DBMS_OUTPUT.PUT_LINE ('p_newevent_date : ' || p_newevent_date);
         DBMS_OUTPUT.PUT_LINE ('p_duration : ' || p_duration);
         l_num_counter := 0;

         WHILE l_num_duration > l_num_counter
         LOOP
            l_num_counter := l_num_counter + 1;
         END LOOP;
         
         
          BEGIN
            bi_call_log_proc.call_log_proc (l_chr_err_code,
                         l_chr_err_msg,
                         11,
                         p_duration,
                         p_request_id,
                         p_newevent_date,
                        SUBSTR (SQLERRM, 1, 255),
                        'When dates are different call alter_dates');
          EXCEPTION
             WHEN OTHERS
             THEN
                NULL;
          END;         

         BEGIN
            alter_dates (l_chr_err_code,
                         l_chr_err_msg,
                         p_request_id,
                         p_newevent_date,
                         l_num_duration,
                         p_duration,
                         l_event_date);
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 7: ');
               bi_call_log_proc.call_log_proc (l_chr_err_code,
                              l_chr_err_msg,
                              11,
                              p_duration,
                              p_request_id,
                              'Error while calling alter_dates',
                              SUBSTR (SQLERRM, 1, 255),null);
         END;

         BEGIN
            SELECT MAX (event_Date) + 1
              INTO l_extend_Date
              FROM bi_request_activity_day
             WHERE request_id = p_request_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         IF l_num_counter = l_num_duration
         THEN
            DBMS_OUTPUT.PUT_LINE (
               'calling extend dates for the remaining dates : ');
              BEGIN
                bi_call_log_proc.call_log_proc (l_chr_err_code,
                             l_chr_err_msg,
                             11,
                             p_duration,
                             p_request_id,
                             p_newevent_date,
                            SUBSTR (SQLERRM, 1, 255),
                            'extend_dates after date change and duration increase');
              EXCEPTION
                 WHEN OTHERS
                 THEN
                    NULL;
              END;    
              
            BEGIN
               extend_dates (l_chr_err_code,
                             l_chr_err_msg,
                             p_request_id,
                             ---l_extend_Date,
                             l_extend_Date ||' '|| l_timechar ,
                             l_diff,
                             p_duration);
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 8: ');
                  bi_call_log_proc.call_log_proc (l_chr_err_code,
                                 l_chr_err_msg,
                                 11,
                                 p_duration,
                                 p_request_id,
                                 'Error while calling extend_dates again',
                                 SUBSTR (SQLERRM, 1, 255),null);
            END;
         END IF;
      ELSIF p_newevent_date <> l_event_date AND p_duration = l_num_duration
      THEN
         DBMS_OUTPUT.PUT_LINE (
            '----calling alter_dates with same duration ---- ');
          DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 8: ');

          BEGIN
            bi_call_log_proc.call_log_proc (l_chr_err_code,
                         l_chr_err_msg,
                         11,
                         p_duration,
                         p_request_id,
                         p_newevent_date,
                        SUBSTR (SQLERRM, 1, 255),
                        'alter_dates call but same duration');
          EXCEPTION
             WHEN OTHERS
             THEN
                NULL;
          END;              
         
         BEGIN
            alter_dates (l_chr_err_code,
                         l_chr_err_msg,
                         p_request_id,
                         p_newevent_date,
                         l_num_duration,
                         p_duration,
                         l_event_date);
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 9: ');
               bi_call_log_proc.call_log_proc (l_chr_err_code,
                              l_chr_err_msg,
                              11,
                              p_duration,
                              p_request_id,
                              'Error while calling alter_dates again',
                              SUBSTR (SQLERRM, 1, 255),null);
         END;
         
      ELSIF p_newevent_date <> l_event_date AND p_duration < l_num_duration
      THEN
         DBMS_OUTPUT.PUT_LINE (
            '----calling alter_dates with less duration ---- ');
          BEGIN
            bi_call_log_proc.call_log_proc (l_chr_err_code,
                         l_chr_err_msg,
                         11,
                         p_duration,
                         p_request_id,
                         p_newevent_date,
                        SUBSTR (SQLERRM, 1, 255),
                        'calling alter_dates with less duration');
          EXCEPTION
             WHEN OTHERS
             THEN
                NULL;
          END;              
         
         BEGIN
            alter_dates (l_chr_err_code,
                         l_chr_err_msg,
                         p_request_id,
                         p_newevent_date,
                         l_num_duration,
                         p_duration,
                         l_event_date);
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 10: ');
               bi_call_log_proc.call_log_proc (l_chr_err_code,
                              l_chr_err_msg,
                              11,
                              p_duration,
                              p_request_id,
                              'Error while calling alter_dates 3 time',
                              SUBSTR (SQLERRM, 1, 255),null);
         END;

         FOR rec_c1 IN c1 (p_duration, p_request_id)
         LOOP
            l_remove_date := rec_c1.event_Date;
            DBMS_OUTPUT.PUT_LINE ('l_remove_date : ' || l_remove_date);

            BEGIN
               UPDATE bi_request_activity_day
                  SET attribute1 = 'D'
                WHERE event_Date = l_remove_date
                 AND request_id = p_request_id;
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 11: ');
                  bi_call_log_proc.call_log_proc (
                     l_chr_err_code,
                     l_chr_err_msg,
                     11,
                     p_duration,
                     p_request_id,
                     'Error while updating bi_request_activity_day',
                     SUBSTR (SQLERRM, 1, 255),null);
            END;
         END LOOP;
         
          BEGIN
            bi_call_log_proc.call_log_proc (l_chr_err_code,
                         l_chr_err_msg,
                         11,
                         p_duration,
                         p_request_id,
                         p_newevent_date,
                        SUBSTR (SQLERRM, 1, 255),
                        'calling alter_dates and delete rooms,activities and dates');
          EXCEPTION
             WHEN OTHERS
             THEN
                NULL;
          END;    
          
         BEGIN
            DELETE FROM bi_request_act_day_break_room
                  WHERE request_activity_day_id IN
                           (SELECT id
                              FROM bi_request_activity_day
                             WHERE     request_id = p_request_id
                                   AND attribute1 IS NULL);
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 12: ');
               bi_call_log_proc.call_log_proc (
                  l_chr_err_code,
                  l_chr_err_msg,
                  11,
                  p_duration,
                  p_request_id,
                  'Error while deleting from bi_request_act_day_break_room again',
                  SUBSTR (SQLERRM, 1, 255),null);
         END;

         BEGIN
            DELETE FROM bi_request_activity
                  WHERE request_activity_day_id IN
                           (SELECT id
                              FROM bi_request_activity_day
                             WHERE request_id = p_request_id
                               AND attribute1 IS NULL);
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 13: ');
               bi_call_log_proc.call_log_proc (
                  l_chr_err_code,
                  l_chr_err_msg,
                  11,
                  p_duration,
                  p_request_id,
                  'Error while deleting from bi_request_activity again',
                  SUBSTR (SQLERRM, 1, 255),null);
         END;

         BEGIN
            DELETE FROM bi_request_activity_day
                  WHERE attribute1 IS NULL AND request_id = p_request_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 14: ');
               bi_call_log_proc.call_log_proc (
                  l_chr_err_code,
                  l_chr_err_msg,
                  11,
                  p_duration,
                  p_request_id,
                  'Error while deleting from bi_request_activity_day again',
                  SUBSTR (SQLERRM, 1, 255),null);
         END;
      END IF;

      BEGIN
         DBMS_OUTPUT.PUT_LINE ('Surya 1 : ');

         SELECT DISTINCT COUNT (1)
           INTO l_event_exists
           FROM bi_location_calendar
          WHERE start_date = 
                   TO_DATE (p_newevent_date, 'DD-MON-YY HH:MI:SS');
      EXCEPTION
         WHEN OTHERS
         THEN
            l_event_exists := 0;
      END;

      DBMS_OUTPUT.PUT_LINE ('Surya 2 : ');

      IF l_event_exists > 0
      THEN
         l_other_act_exist := 'Y';
      END IF;

      IF l_other_act_exist = 'Y'
      THEN
         out_chr_err_msg :=
            'There are other events occurring on the same day !';
      END IF;

      BEGIN
         UPDATE bi_request_activity_day
            SET attribute1 = NULL
          WHERE request_id = p_request_id;

         DBMS_OUTPUT.PUT_LINE ('Surya 3 : ');
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 15: ');
            bi_call_log_proc.call_log_proc (
               l_chr_err_code,
               l_chr_err_msg,
               11,
               p_duration,
               p_request_id,
               'Error while updating bi_request_activity_day attribute1',
               SUBSTR (SQLERRM, 1, 255),null);
      END;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         bi_call_log_proc.call_log_proc (l_chr_err_code,
                        l_chr_err_msg,
                        11,
                        p_duration,
                        p_request_id,
                        'Error in main proc',
                        SUBSTR (SQLERRM, 1, 255),null);
   END;

   PROCEDURE extend_dates (out_chr_err_code    OUT VARCHAR2,
                           out_chr_err_msg     OUT VARCHAR2,
                           p_request_id        IN     NUMBER,
                           p_event_date        IN     VARCHAR2,
                           p_diff              IN     NUMBER,
                           p_actual_duration   IN     NUMBER)
   IS
      l_max_id             NUMBER;
      l_exists_already     VARCHAR2 (2);
      l_sat_date           DATE;
      l_chr_err_code       VARCHAR2 (200);
      l_chr_err_msg        VARCHAR2 (200);
      l_MAX_date           DATE;
      l_num_counter        NUMBER := 0;
      l_day                VARCHAR2 (200) := NULL;
      l_chr_eventday       VARCHAR2 (40) := NULL;
      l_chr_arr            VARCHAR2 (400) := NULL;
      l_chr_adj            VARCHAR2 (400) := NULL;
      l_num_locid          NUMBER;
      l_event_date         TIMESTAMP := NULL;
      l_new_event_date     TIMESTAMP;
      l_chr_arrival_time   TIMESTAMP;
      l_chr_adjourn_time   TIMESTAMP;
      l_dte_arr_time       DATE;
      l_dte_adj_time       DATE;
      l_start_Date         DATE;
      l_end_date           DATE;
      l_currdate           TIMESTAMP := NULL;
      l_default_value      NUMBER := 30;
      l_dte_conv           DATE;
      l_timechar           VARCHAR2 (30);

      CURSOR c_get_day (
         p_start_date    DATE,
         p_duration      NUMBER)
      IS
         WITH DATA
              AS -- Fixed the date format from DD-MON-YY to DD-MM-YY
                 (SELECT TO_DATE (p_start_date, 'DD-MM-YY') date1,
                         TO_DATE (p_start_date + p_duration + 1,
                                  'DD-MM-YY')
                            date2
                    FROM DUAL)
             SELECT date1 + LEVEL - 1 the_date,
                    TO_CHAR (date1 + LEVEL - 1,
                             'DAY',
                             'NLS_DATE_LANGUAGE=AMERICAN')
                       weekday
               FROM DATA
         --WHERE TO_CHAR(date1+LEVEL-1, 'DY','NLS_DATE_LANGUAGE=AMERICAN') NOT IN ('SAT', 'SUN')
         CONNECT BY LEVEL <= date2 - date1 + 1;

      CURSOR c3 (l_counter NUMBER, l_proc NUMBER)
      IS
         SELECT event_date, weekday
           FROM bi_loc_temp
          WHERE ROWNUM < l_counter + l_proc;

      CURSOR C4 (l_loc NUMBER)
      IS
         SELECT DECODE ( (SELECT DISTINCT COUNT (1)
                            FROM bi_location_hours
                           WHERE location_id = l_loc AND MONDAY IS NULL),
                        '1', 'MONDAY',
                        'NO')
                   LOCATION_DAY
           FROM DUAL
         UNION
         SELECT DECODE ( (SELECT DISTINCT COUNT (1)
                            FROM bi_location_hours
                           WHERE location_id = l_loc AND TUESDAY IS NULL),
                        '1', 'TUESDAY',
                        'NO')
           FROM DUAL
         UNION
         SELECT DECODE ( (SELECT DISTINCT COUNT (1)
                            FROM bi_location_hours
                           WHERE location_id = l_loc AND WEDNESDAY IS NULL),
                        '1', 'WEDNESDAY',
                        'NO')
           FROM DUAL
         UNION
         SELECT DECODE ( (SELECT DISTINCT COUNT (1)
                            FROM bi_location_hours
                           WHERE location_id = l_loc AND THURSDAY IS NULL),
                        '1', 'THURSDAY',
                        'NO')
           FROM DUAL
         UNION
         SELECT DECODE ( (SELECT DISTINCT COUNT (1)
                            FROM bi_location_hours
                           WHERE location_id = l_loc AND FRIDAY IS NULL),
                        '1', 'FRIDAY',
                        'NO')
           FROM DUAL
         UNION
         SELECT DECODE ( (SELECT DISTINCT COUNT (1)
                            FROM bi_location_hours
                           WHERE location_id = l_loc AND SATURDAY IS NULL),
                        '1', 'SATURDAY',
                        'NO')
           FROM DUAL
         UNION
         SELECT DECODE ( (SELECT DISTINCT COUNT (1)
                            FROM bi_location_hours
                           WHERE location_id = l_loc AND SUNDAY IS NULL),
                        '1', 'SUNDAY',
                        'NO')
           FROM DUAL;

   BEGIN
      DBMS_OUTPUT.PUT_LINE ('--------Calling extend_dates ------ : ');
      DBMS_OUTPUT.PUT_LINE ('p_request_id : ' || p_request_id);
      DBMS_OUTPUT.PUT_LINE ('p_event_date : ' || p_event_date);
      DBMS_OUTPUT.PUT_LINE ('p_diff : ' || p_diff);

      --Separate date and time
      BEGIN
         SELECT TRUNC(TO_DATE(p_event_date,'DD-MM-YY  HH:MI:SS AM')) conv
           INTO l_dte_conv
           FROM DUAL;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_dte_conv := NULL;
      END;
      
      DBMS_OUTPUT.PUT_LINE ('l_dte_conv : ' || l_dte_conv);
      
      BEGIN
         SELECT TO_CHAR (start_date, 'HH24:MI:SS AM')
           INTO l_timechar
           FROM bi_request
          WHERE id = p_request_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_num_locid := 0;
      END;    
      
      BEGIN
         SELECT DISTINCT location_id
           INTO l_num_locid
           FROM bi_request
          WHERE id = p_request_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_num_locid := 0;
      END;
      
      BEGIN
        bi_call_log_proc.call_log_proc (l_chr_err_code,
                     l_chr_err_msg,
                     11,
                     p_actual_duration,
                     p_request_id,
                     'Inside extend_dates to  get the dates,arrival and adjourn',
                    SUBSTR (SQLERRM, 1, 255),
                    'Insert into BI_REQUEST_ACTIVITY_DAY');
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      FOR rec_c_get_day IN c_get_day (l_dte_conv, l_default_value)
      LOOP
      
         DBMS_OUTPUT.PUT_LINE('Me inside cursor : ' || rec_c_get_day.the_date  );
         
         l_new_event_date := TO_TIMESTAMP (rec_c_get_day.the_date||' '||l_timechar, 'DD-MON-YY HH:MI:SS AM' )   ;
         l_chr_eventday := rec_c_get_day.weekday;

        --  DBMS_OUTPUT.PUT_LINE('l_new_event_date : ' || l_new_event_date  );
         -- DBMS_OUTPUT.PUT_LINE('l_chr_eventday : ' || l_chr_eventday  );
         BEGIN
            INSERT INTO bi_loc_temp (event_date,
                                     weekday,
                                     flag,
                                     creation_date)
                 VALUES (l_new_event_date,
                         l_chr_eventday,
                         'N',
                         SYSDATE);
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 16: ');
               bi_call_log_proc.call_log_proc (l_chr_err_code,
                              l_chr_err_msg,
                              11,
                              p_actual_duration,
                              p_request_id,
                              'Error while inserting to bi_loc_Temp',
                              SUBSTR (SQLERRM, 1, 255),null);
         END;

         BEGIN
            SELECT start_date,end_Date
              INTO l_start_Date, l_End_date
              FROM bi_location_calendar
             WHERE l_new_event_date BETWEEN start_Date
                                            AND end_Date
                   AND request_id IS NULL
                   AND location_id = l_num_locid;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               l_start_Date := NULL;
               l_end_Date := NULL;
            WHEN OTHERS
            THEN
               l_start_Date := NULL;
               l_end_Date := NULL;
               DBMS_OUTPUT.PUT_LINE ('ERROR IN SELECT : ' || SQLERRM);
         END;

         IF l_start_Date IS NOT NULL OR l_End_date IS NOT NULL
         THEN
            IF    l_new_event_date = l_start_Date
               OR l_new_event_date = l_End_date
               OR l_new_event_date BETWEEN l_start_Date AND l_End_date
            THEN
               BEGIN
                  UPDATE bi_loc_temp
                     SET flag = 'Y'
                   WHERE event_date = l_new_event_date;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     DBMS_OUTPUT.PUT_LINE (
                        'Before calling bi_call_log_proc.call_log_proc 17: ');
                     bi_call_log_proc.call_log_proc (l_chr_err_code,
                                    l_chr_err_msg,
                                    11,
                                    p_actual_duration,
                                    p_request_id,
                                    'Error while updating bi_loc_Temp',
                                    SUBSTR (SQLERRM, 1, 255),null);
               END;
            END IF;
         END IF;
      END LOOP;

      FOR rec_c4 IN c4 (l_num_locid)
      LOOP
         DBMS_OUTPUT.PUT_LINE ('location_day : ' || rec_c4.location_day);

         BEGIN
            UPDATE bi_loc_temp
               SET flag = 'Y'
             WHERE TRIM (weekday) = rec_c4.location_day;
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.PUT_LINE ('Count of holidays : ' || SQL%ROWCOUNT);
         END;
      END LOOP;

      BEGIN
         DELETE FROM bi_loc_temp
               WHERE flag = 'Y';
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 18: ');
            bi_call_log_proc.call_log_proc (l_chr_err_code,
                           l_chr_err_msg,
                           11,
                           p_actual_duration,
                           p_request_id,
                           'Error while deleting bi_loc_Temp',
                           SUBSTR (SQLERRM, 1, 255),null);
      END;

      COMMIT;
      l_num_counter := 1;

      FOR rec_c3 IN c3 (l_num_counter, p_diff)
      LOOP
         l_currdate := rec_c3.event_date;
         l_day := rec_c3.weekday;
         DBMS_OUTPUT.PUT_LINE ('l_currdate :     ' || l_currdate);
         DBMS_OUTPUT.PUT_LINE ('l_day :     ' || l_day);

         BEGIN
            IF TRIM (l_day) = 'MONDAY'
            THEN
               -- DBMS_OUTPUT.PUT_LINE('in MONDAY ----------------------------  : ' );
               BEGIN
                  SELECT SUBSTR (MONDAY, 1, 7), SUBSTR (MONDAY, -7, 8)
                    INTO l_chr_arr, l_chr_adj
                    FROM bi_location_hours
                   WHERE location_id = l_num_locid;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_chr_arr := NULL;
                     l_chr_adj := NULL;
               END;
            ELSIF TRIM (l_day) = 'TUESDAY'
            THEN
               -- DBMS_OUTPUT.PUT_LINE('in TUESDAY  : '  );
               BEGIN
                  SELECT SUBSTR (TUESDAY, 1, 7), SUBSTR (TUESDAY, -7, 8)
                    INTO l_chr_arr, l_chr_adj
                    FROM bi_location_hours
                   WHERE location_id = l_num_locid;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_chr_arr := NULL;
                     l_chr_adj := NULL;
               END;
            ELSIF TRIM (l_day) = 'WEDNESDAY'
            THEN
               -- DBMS_OUTPUT.PUT_LINE('in WEDNESDAY  : '  );
               BEGIN
                  SELECT SUBSTR (WEDNESDAY, 1, 7), SUBSTR (WEDNESDAY, -7, 8)
                    INTO l_chr_arr, l_chr_adj
                    FROM bi_location_hours
                   WHERE location_id = l_num_locid;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_chr_arr := NULL;
                     l_chr_adj := NULL;
               END;
            ELSIF TRIM (l_day) = 'THURSDAY'
            THEN
               --  DBMS_OUTPUT.PUT_LINE('in thursday : '  );
               BEGIN
                  SELECT SUBSTR (THURSDAY, 1, 7), SUBSTR (THURSDAY, -7, 8)
                    INTO l_chr_arr, l_chr_adj
                    FROM bi_location_hours
                   WHERE location_id = l_num_locid;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_chr_arr := NULL;
                     l_chr_adj := NULL;
               END;
            ELSIF TRIM (l_day) = 'FRIDAY'
            THEN
               -- DBMS_OUTPUT.PUT_LINE('in FRIDAY : '  );
               BEGIN
                  SELECT SUBSTR (FRIDAY, 1, 7), SUBSTR (FRIDAY, -7, 8)
                    INTO l_chr_arr, l_chr_adj
                    FROM bi_location_hours
                   WHERE location_id = l_num_locid;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_chr_arr := NULL;
                     l_chr_adj := NULL;
               END;
            ELSIF TRIM (l_day) = 'SATURDAY'
            THEN
               -- DBMS_OUTPUT.PUT_LINE('in Saturday : '  );
               BEGIN
                  SELECT SUBSTR (SATURDAY, 1, 7), SUBSTR (SATURDAY, -7, 8)
                    INTO l_chr_arr, l_chr_adj
                    FROM bi_location_hours
                   WHERE location_id = l_num_locid;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_chr_arr := NULL;
                     l_chr_adj := NULL;
               END;
            ELSIF TRIM (l_day) = 'SUNDAY'
            THEN
               -- DBMS_OUTPUT.PUT_LINE('in Sunday : '  );
               BEGIN
                  SELECT SUBSTR (SUNDAY, 1, 7), SUBSTR (SUNDAY, -7, 8)
                    INTO l_chr_arr, l_chr_adj
                    FROM bi_location_hours
                   WHERE location_id = l_num_locid;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_chr_arr := NULL;
                     l_chr_adj := NULL;
               END;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               l_chr_arr := '9:00 AM';
               l_chr_adj := '5:30 PM';
               DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 19: ');
               bi_call_log_proc.call_log_proc (
                  l_chr_err_code,
                  l_chr_err_msg,
                  11,
                  p_actual_duration,
                  p_request_id,
                  'Assigning default values to arrival and  adjourn',
                  SUBSTR (SQLERRM, 1, 255),null);
         END;

         DBMS_OUTPUT.PUT_LINE ('l_chr_arr : ' || l_chr_arr);
         DBMS_OUTPUT.PUT_LINE ('l_chr_adj : ' || l_chr_adj);

         BEGIN
            SELECT MAX (id) + 1 INTO l_max_id FROM BI_REQUEST_ACTIVITY_DAY;
         EXCEPTION
            WHEN OTHERS
            THEN
               l_max_id := 0;
         END;
    
         BEGIN
            INSERT INTO BI_REQUEST_ACTIVITY_DAY (id,
                                                 request_id,
                                                 arrival,
                                                 adjourn,
                                                 created_by,
                                                 created_ts,
                                                 updated_by,
                                                 updated_ts,
                                                 version,
                                                 event_date)
                 VALUES (l_max_id,
                         p_request_id,
                         l_chr_arr,
                         l_chr_adj,
                         'vamsi.panuganti@briefingiq.com',
                         CURRENT_TIMESTAMP,
                         'vamsi.panuganti@briefingiq.com',
                         CURRENT_TIMESTAMP,
                         0,
                         l_currdate);
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 20: ');
               bi_call_log_proc.call_log_proc (
                  l_chr_err_code,
                  l_chr_err_msg,
                  11,
                  p_actual_duration,
                  p_request_id,
                  'Error while inserting into bi_request_activity_day',
                  SUBSTR (SQLERRM, 1, 255),null);
         END;
      END LOOP;

      COMMIT;

      EXECUTE IMMEDIATE 'TRUNCATE TABLE bi_loc_temp';


      
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.PUT_LINE ('Error here' || SQLERRM);
         bi_call_log_proc.call_log_proc (l_chr_err_code,
                        l_chr_err_msg,
                        11,
                        p_actual_duration,
                        p_request_id,
                        'Error in extend_dates procedure',
                       SUBSTR (SQLERRM, 1, 255),null);
   END;

   PROCEDURE alter_dates (out_chr_err_code       OUT VARCHAR2,
                          out_chr_err_msg        OUT VARCHAR2,
                          p_request_id        IN     NUMBER,
                          p_start_date        IN     VARCHAR2,
                          p_duration          IN     NUMBER,
                          p_actual_duration   IN     NUMBER,
                          p_before_event_date       IN DATE)
   IS
      l_num_counter        NUMBER := 0;
      l_chr_err_code       VARCHAR2 (300);
      l_chr_eventday       VARCHAR2 (50) := NULL;
      l_chr_err_msg        VARCHAR2 (300);
      l_num                NUMBER := 0;
      l_end_Date           DATE;
      l_chr_overlap_date   DATE;
      l_act_id             NUMBER;
      l_start_date         DATE;
      l_chr_arr            VARCHAR2 (400) := NULL;
      l_chr_adj            VARCHAR2 (400) := NULL;
      l_event_date         TIMESTAMP;
      l_get_curr_count     NUMBER;
      l_max_id             NUMBER := 0;
      l_MAX_date           DATE;
      l_default_value      NUMBER := 30;
      l_num_locid          NUMBER;
      l_new_event_date     TIMESTAMP;
      l_currdate           TIMESTAMP := NULL;
      l_day                VARCHAR2 (200) := NULL;
      l_dte_conv           DATE;
      l_timechar           VARCHAR2 (30);
      diffInDays         NUMBER;
      l_minActivityStartDate TIMESTAMP;
      
      l_timezone           VARCHAR2 (100);
      l_dts_start          DATE;
      l_dts_end            DATE;
      l_dst_support        VARCHAR2 (50);
      l_check_Date         DATE;
      ---
      CURSOR c_get_day (
         start_date    DATE,
         duration      NUMBER)
      IS
         WITH DATA
              AS (SELECT TO_DATE (start_date,  'DD-MM-YY') date1,
                         TO_DATE (start_date + duration + 1,
                                   'DD-MM-YY')
                            date2
                    FROM DUAL)
             SELECT date1 + LEVEL - 1 the_date,
                    TO_CHAR (date1 + LEVEL - 1,
                             'DAY',
                             'NLS_DATE_LANGUAGE=AMERICAN')
                       weekday
               FROM DATA
         -- WHERE TO_CHAR(date1+LEVEL-1, 'DY','NLS_DATE_LANGUAGE=AMERICAN') NOT IN ('SAT', 'SUN')
         CONNECT BY LEVEL <= date2 - date1 + 1;

      CURSOR c3 (l_counter NUMBER, l_proc NUMBER)
      IS
         SELECT event_date, weekday
           FROM bi_loc_temp
          WHERE ROWNUM < l_counter + l_proc;

      CURSOR C4 (l_loc NUMBER)
      IS
         SELECT DECODE ( (SELECT DISTINCT COUNT (1)
                            FROM bi_location_hours
                           WHERE location_id = l_loc AND MONDAY IS NULL),
                        '1', 'MONDAY',
                        'NO')
                   LOCATION_DAY
           FROM DUAL
         UNION
         SELECT DECODE ( (SELECT DISTINCT COUNT (1)
                            FROM bi_location_hours
                           WHERE location_id = l_loc AND TUESDAY IS NULL),
                        '1', 'TUESDAY',
                        'NO')
           FROM DUAL
         UNION
         SELECT DECODE ( (SELECT DISTINCT COUNT (1)
                            FROM bi_location_hours
                           WHERE location_id = l_loc AND WEDNESDAY IS NULL),
                        '1', 'WEDNESDAY',
                        'NO')
           FROM DUAL
         UNION
         SELECT DECODE ( (SELECT DISTINCT COUNT (1)
                            FROM bi_location_hours
                           WHERE location_id = l_loc AND THURSDAY IS NULL),
                        '1', 'THURSDAY',
                        'NO')
           FROM DUAL
         UNION
         SELECT DECODE ( (SELECT DISTINCT COUNT (1)
                            FROM bi_location_hours
                           WHERE location_id = l_loc AND FRIDAY IS NULL),
                        '1', 'FRIDAY',
                        'NO')
           FROM DUAL
         UNION
         SELECT DECODE ( (SELECT DISTINCT COUNT (1)
                            FROM bi_location_hours
                           WHERE location_id = l_loc AND SATURDAY IS NULL),
                        '1', 'SATURDAY',
                        'NO')
           FROM DUAL
         UNION
         SELECT DECODE ( (SELECT DISTINCT COUNT (1)
                            FROM bi_location_hours
                           WHERE location_id = l_loc AND SUNDAY IS NULL),
                        '1', 'SUNDAY',
                        'NO')
           FROM DUAL;

      CURSOR c_get_time
      IS
           SELECT DISTINCT TRUNC (activity_start_time), request_activity_day_id
             FROM bi_request_activity
            WHERE request_activity_day_id IN
                         (SELECT id
                            FROM bi_request_activity_day
                           WHERE request_id = p_request_id)
                  AND attribute_info IS NULL
         ORDER BY request_activity_day_id DESC;

   BEGIN
      DBMS_OUTPUT.PUT_LINE ('------- In alter dates------: ');
      DBMS_OUTPUT.PUT_LINE ('p_start_date : ' || p_start_date);
      DBMS_OUTPUT.PUT_LINE ('p_duration : ' || p_duration);
       DBMS_OUTPUT.PUT_LINE ('p_before_event_date : ' || p_before_event_date);

      -- l_event_date := p_newevent_date;
      -- DBMS_OUTPUT.PUT_LINE('l_event_date passed to get_arr_adj_workday : ' || l_event_date  );
            --Separate date and time
      BEGIN
         SELECT TRUNC(TO_DATE(p_start_date,'DD-MM-YY  HH:MI:SS AM')) conv
           INTO l_dte_conv
           FROM DUAL;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_dte_conv := NULL;
      END;
      
      DBMS_OUTPUT.PUT_LINE ('l_dte_conv : ' || l_dte_conv);
      
      BEGIN
         SELECT TO_CHAR (start_date, 'HH24:MI:SS AM')
           INTO l_timechar
           FROM bi_request
          WHERE id = p_request_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_num_locid := 0;
      END;    
      
      
      BEGIN
         SELECT DISTINCT location_id
           INTO l_num_locid
           FROM bi_request
          WHERE id = p_request_id;

         DBMS_OUTPUT.PUT_LINE ('------- In alter dates--2----: ');
      EXCEPTION
         WHEN OTHERS
         THEN
            l_num_locid := 0;
      END;
      
      BEGIN
        bi_call_log_proc.call_log_proc (l_chr_err_code,
                     l_chr_err_msg,
                     11,
                     p_duration,
                     p_request_id,
                     'Inside alter_dates to  get the dates,arrival and adjourn',
                    SUBSTR (SQLERRM, 1, 255),
                    'Update BI_REQUEST_ACTIVITY_DAY and BI_REQUEST_ACTIVITY with daylight savings');
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      FOR rec_c_get_day IN c_get_day (l_dte_conv, l_default_value)
      LOOP
      
        -- DBMS_OUTPUT.PUT_LINE('Me inside cursor : ' || rec_c_get_day.the_date  );
         l_new_event_date := TO_TIMESTAMP (rec_c_get_day.the_date||' '||l_timechar, 'DD-MON-YY HH:MI:SS AM' )   ;
         l_chr_eventday := rec_c_get_day.weekday;

         -- DBMS_OUTPUT.PUT_LINE('l_new_event_date : ' || l_new_event_date  );
         --DBMS_OUTPUT.PUT_LINE('l_chr_eventday : ' || l_chr_eventday  );

         BEGIN
            INSERT INTO bi_loc_temp (event_date,
                                     weekday,
                                     flag,
                                     creation_date)
                 VALUES (l_new_event_date,
                         l_chr_eventday,
                         'N',
                         SYSDATE);
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 21: ');
               bi_call_log_proc.call_log_proc (l_chr_err_code,
                              l_chr_err_msg,
                              11,
                              p_actual_duration,
                              p_request_id,
                              'Error while inserting into bi_loc_temp',
                              SUBSTR (SQLERRM, 1, 255),null);
         END;

         BEGIN
            SELECT  start_date,end_Date
              INTO l_start_Date, l_End_date
              FROM bi_location_calendar
             WHERE  l_new_event_date BETWEEN start_Date
                                            AND end_Date
                   AND request_id IS NULL
                   AND location_id = l_num_locid;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               l_start_Date := NULL;
               l_End_date := NULL;
            WHEN OTHERS
            THEN
               l_start_Date := NULL;
               l_End_date := NULL;
         END;

         IF l_start_Date IS NOT NULL OR l_End_date IS NOT NULL
         THEN
            IF    l_new_event_date = l_start_Date
               OR l_new_event_date = l_End_date
               OR l_new_event_date BETWEEN l_start_Date AND l_End_date
            THEN
               BEGIN
                  UPDATE bi_loc_temp
                     SET flag = 'Y'
                   WHERE event_date = l_new_event_date;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     DBMS_OUTPUT.PUT_LINE (
                        'Before calling bi_call_log_proc.call_log_proc 22: ');
                     bi_call_log_proc.call_log_proc (l_chr_err_code,
                                    l_chr_err_msg,
                                    11,
                                    p_actual_duration,
                                    p_request_id,
                                    'Error while updating bi_loc_temp',
                                    SUBSTR (SQLERRM, 1, 255),null);
               END;
            END IF;
         END IF;
      END LOOP;

      FOR rec_c4 IN c4 (l_num_locid)
      LOOP
         DBMS_OUTPUT.PUT_LINE ('location_day : ' || rec_c4.location_day);

         BEGIN
            UPDATE bi_loc_temp
               SET flag = 'Y'
             WHERE TRIM (weekday) = rec_c4.location_day;
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.PUT_LINE ('Count of holidays : ' || SQL%ROWCOUNT);
         END;
      END LOOP;

      BEGIN
         DELETE FROM bi_loc_temp
               WHERE flag = 'Y';
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 23: ');
            bi_call_log_proc.call_log_proc (l_chr_err_code,
                           l_chr_err_msg,
                           11,
                           p_actual_duration,
                           p_request_id,
                           'Error while deleting from bi_loc_temp',
                           SUBSTR (SQLERRM, 1, 255),null);
      END;

      COMMIT;
      l_num_counter := 1;

      FOR rec_c3 IN c3 (l_num_counter, p_duration)
      LOOP
         l_currdate := rec_c3.event_date;
         l_day := rec_c3.weekday;
         DBMS_OUTPUT.PUT_LINE ('l_currdate :     ' || l_currdate);
         DBMS_OUTPUT.PUT_LINE ('l_day :     ' || l_day);

         BEGIN
            IF TRIM (l_day) = 'MONDAY'
            THEN
               -- DBMS_OUTPUT.PUT_LINE('in MONDAY ----------------------------  : ' );
               BEGIN
                  SELECT SUBSTR (MONDAY, 1, 7), SUBSTR (MONDAY, -7, 8)
                    INTO l_chr_arr, l_chr_adj
                    FROM bi_location_hours
                   WHERE location_id = l_num_locid;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_chr_arr := NULL;
                     l_chr_adj := NULL;
               END;
            ELSIF TRIM (l_day) = 'TUESDAY'
            THEN
               -- DBMS_OUTPUT.PUT_LINE('in TUESDAY  : '  );
               BEGIN
                  SELECT SUBSTR (TUESDAY, 1, 7), SUBSTR (TUESDAY, -7, 8)
                    INTO l_chr_arr, l_chr_adj
                    FROM bi_location_hours
                   WHERE location_id = l_num_locid;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_chr_arr := NULL;
                     l_chr_adj := NULL;
               END;
            ELSIF TRIM (l_day) = 'WEDNESDAY'
            THEN
               -- DBMS_OUTPUT.PUT_LINE('in WEDNESDAY  : '  );
               BEGIN
                  SELECT SUBSTR (WEDNESDAY, 1, 7), SUBSTR (WEDNESDAY, -7, 8)
                    INTO l_chr_arr, l_chr_adj
                    FROM bi_location_hours
                   WHERE location_id = l_num_locid;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_chr_arr := NULL;
                     l_chr_adj := NULL;
               END;
            ELSIF TRIM (l_day) = 'THURSDAY'
            THEN
               --  DBMS_OUTPUT.PUT_LINE('in thursday : '  );
               BEGIN
                  SELECT SUBSTR (THURSDAY, 1, 7), SUBSTR (THURSDAY, -7, 8)
                    INTO l_chr_arr, l_chr_adj
                    FROM bi_location_hours
                   WHERE location_id = l_num_locid;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_chr_arr := NULL;
                     l_chr_adj := NULL;
               END;
            ELSIF TRIM (l_day) = 'FRIDAY'
            THEN
               -- DBMS_OUTPUT.PUT_LINE('in FRIDAY : '  );
               BEGIN
                  SELECT SUBSTR (FRIDAY, 1, 7), SUBSTR (FRIDAY, -7, 8)
                    INTO l_chr_arr, l_chr_adj
                    FROM bi_location_hours
                   WHERE location_id = l_num_locid;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_chr_arr := NULL;
                     l_chr_adj := NULL;
               END;
            ELSIF TRIM (l_day) = 'SATURDAY'
            THEN
               -- DBMS_OUTPUT.PUT_LINE('in Saturday : '  );
               BEGIN
                  SELECT SUBSTR (SATURDAY, 1, 7), SUBSTR (SATURDAY, -7, 8)
                    INTO l_chr_arr, l_chr_adj
                    FROM bi_location_hours
                   WHERE location_id = l_num_locid;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_chr_arr := NULL;
                     l_chr_adj := NULL;
               END;
            ELSIF TRIM (l_day) = 'SUNDAY'
            THEN
               -- DBMS_OUTPUT.PUT_LINE('in Sunday : '  );
               BEGIN
                  SELECT SUBSTR (SUNDAY, 1, 7), SUBSTR (SUNDAY, -7, 8)
                    INTO l_chr_arr, l_chr_adj
                    FROM bi_location_hours
                   WHERE location_id = l_num_locid;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_chr_arr := NULL;
                     l_chr_adj := NULL;
               END;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               l_chr_arr := '9:00 AM';
               l_chr_adj := '5:30 PM';
               DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 24: ');
               bi_call_log_proc.call_log_proc (
                  l_chr_err_code,
                  l_chr_err_msg,
                  11,
                  p_actual_duration,
                  p_request_id,
                  'Error in arrival and adjourn , setting defaultvalues',
                  SUBSTR (SQLERRM, 1, 255),null);
         END;

         DBMS_OUTPUT.PUT_LINE ('l_chr_arr : ' || l_chr_arr);
         DBMS_OUTPUT.PUT_LINE ('l_chr_adj : ' || l_chr_adj);

         BEGIN
            UPDATE bi_request_Activity_Day
               SET event_Date = l_currdate,
                   attribute1 = 'Y',
                   arrival = l_chr_arr,
                   adjourn = l_chr_adj
             WHERE request_id = p_request_id
                   AND id IN
                          (SELECT MIN (id)
                             FROM bi_request_Activity_Day
                            WHERE     request_id = p_request_id
                                  AND attribute1 IS NULL)
                   AND attribute1 IS NULL;

            DBMS_OUTPUT.PUT_LINE (
               'Count after updating bi_request_Activity_Day' || SQL%ROWCOUNT);
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 25: ');
               bi_call_log_proc.call_log_proc (l_chr_err_code,
                              l_chr_err_msg,
                              11,
                              p_actual_duration,
                              p_request_id,
                              'Error while updating bi_request_Activity_Day',
                              SUBSTR (SQLERRM, 1, 255),null);
         END;

         BEGIN
         SELECT location_timezone
           INTO l_timezone
           FROM bi_location
          WHERE id = l_num_locid;
         EXCEPTION
          WHEN OTHERS
          THEN
          DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc timezone: ');
               bi_call_log_proc.call_log_proc (l_chr_err_code,
                              l_chr_err_msg,
                              11,
                              p_actual_duration,
                              p_request_id,
                              'Error while obtaining timezone for the location',
                              SUBSTR (SQLERRM, 1, 255),null);
         END;         
         
         BEGIN
         SELECT DISTINCT
            CASE WHEN tz_offset_now != tz_offset_later THEN 'Y' ELSE 'N' END AS supports_dst
            INTO l_dst_support
            FROM (
            SELECT SYSTIMESTAMP,
            tzname,
            tzabbrev,
            TO_CHAR((SYSTIMESTAMP AT TIME ZONE tzname),'TZH:TZM (TZD)') AS tz_offset_now,
            TO_CHAR((SYSTIMESTAMP AT TIME ZONE tzname) + INTERVAL '6' MONTH,'TZH:TZM (TZD)') AS tz_offset_later
            FROM gv$timezone_names WHERE tzname = l_timezone
            ) WHERE tzname = l_timezone;
         EXCEPTION
          WHEN OTHERS
          THEN
          DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc timezone flag: ');
               bi_call_log_proc.call_log_proc (l_chr_err_code,
                              l_chr_err_msg,
                              11,
                              p_actual_duration,
                              p_request_id,
                              'Error while obtaining timezone eligible for thelocation',
                              SUBSTR (SQLERRM, 1, 255),null);       
         END;
         
         DBMS_OUTPUT.PUT_LINE ('l_dst_support: ' || l_dst_support);
         
         FOR rec_c_get_time IN c_get_time
         LOOP
            DBMS_OUTPUT.PUT_LINE (
                  'rec_c_get_time.request_activity_day_id : '
               || rec_c_get_time.request_activity_day_id);
            l_act_id := rec_c_get_time.request_activity_day_id;
            DBMS_OUTPUT.PUT_LINE ('l_act_id inside: ' || l_act_id);
         END LOOP;

         DBMS_OUTPUT.PUT_LINE ('l_act_id: ' || l_act_id);

         BEGIN
           
          BEGIN 
            SELECT min(activity_start_time) 
             INTO l_minActivityStartDate 
             FROM bi_request_activity 
            WHERE request_activity_day_id = l_act_id 
              AND attribute_info IS NULL;
          EXCEPTION
             WHEN OTHERS
             THEN
               DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc l_minActivityStartDate : ');
               bi_call_log_proc.call_log_proc (l_chr_err_code,
                              l_chr_err_msg,
                              11,
                              p_actual_duration,
                              p_request_id,
                              'Error while obtaining l_minActivityStartDate',
                              SUBSTR (SQLERRM, 1, 255),null);              
          END;       
            
            FOR rec IN (SELECT * FROM bi_request_activity where request_activity_day_id = l_act_id AND attribute_info IS NULL) 
            LOOP 
                
                BEGIN
                  SELECT ( TRUNC(l_currdate) - TRUNC(l_minActivityStartDate)) 
                    INTO diffInDays 
                    FROM dual;
                EXCEPTION
                  WHEN OTHERS
                  THEN
                   DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc diffInDays : ');
                   bi_call_log_proc.call_log_proc (l_chr_err_code,
                                  l_chr_err_msg,
                                  11,
                                  p_actual_duration,
                                  p_request_id,
                                  'Error while obtaining diffInDays',
                                  SUBSTR (SQLERRM, 1, 255),null);               
                END;            
               -- DBMS_OUTPUT.PUT_LINE ('diffInDays: ' || diffInDays);
               -- DBMS_OUTPUT.PUT_LINE ('rec.activity_start_time: ' || rec.activity_start_time);
                
                l_dts_start := DaylightSavingTimeStart (rec.activity_start_time);
                l_dts_end := DaylightSavingTimeEnd (rec.activity_start_time);
                
              --  DBMS_OUTPUT.PUT_LINE ('l_dts_start: ' || l_dts_start);
             --   DBMS_OUTPUT.PUT_LINE ('l_dts_end: ' || l_dts_end);
                
                IF l_dst_support ='Y' 
                THEN
                     
                     l_check_Date :=  TRUNC(l_currdate);

                    DBMS_OUTPUT.PUT_LINE ('l_dts_start: ' || TO_DATE(l_dts_start,'DD-MON-YY'));
                   -- DBMS_OUTPUT.PUT_LINE ('l_dts_end: ' || l_dts_end);
                   -- DBMS_OUTPUT.PUT_LINE ('p_before_event_date: ' || p_before_event_date);                
                  --  DBMS_OUTPUT.PUT_LINE ('l_check_Date ' || l_check_Date);
                
                    --Substract an hr
                    IF p_before_event_date NOT BETWEEN      
                                                TO_DATE(l_dts_start,'DD-MON-YY')  AND TO_DATE(l_dts_end ,'DD-MON-YY')
                    AND 
                      TO_DATE(l_check_Date,'DD-MON-YY') BETWEEN
                                                TO_DATE(l_dts_start,'DD-MON-YY')  AND TO_DATE(l_dts_end ,'DD-MON-YY')
                    THEN
                       DBMS_OUTPUT.PUT_LINE ('Substract an hr: ' || rec.activity_start_time);
                         UPDATE bi_request_activity
                           SET activity_start_time = (rec.activity_start_time -1/24 ) + diffInDays ,
                              attribute_info ='Y'     
                           WHERE id = rec.id;
                    END IF;                    
                    
                    --Add an hr
                    IF p_before_event_date BETWEEN      
                                                TO_DATE(l_dts_start,'DD-MON-YY')  AND TO_DATE(l_dts_end ,'DD-MON-YY')
                    AND 
                      TO_DATE(l_check_Date,'DD-MON-YY') NOT BETWEEN
                                                TO_DATE(l_dts_start,'DD-MON-YY')  AND TO_DATE(l_dts_end ,'DD-MON-YY')
                    THEN
                       DBMS_OUTPUT.PUT_LINE ('Add an hr: ' || rec.activity_start_time);
                         UPDATE bi_request_activity
                           SET activity_start_time = (rec.activity_start_time + 1/24) + diffInDays ,
                              attribute_info ='Y'     
                           WHERE id = rec.id;
                    END IF;                        
                    
                    
                    --Just update as is
                    IF p_before_event_date NOT BETWEEN      
                                                TO_DATE(l_dts_start,'DD-MON-YY')  AND TO_DATE(l_dts_end ,'DD-MON-YY')
                    AND 
                      TO_DATE(l_check_Date,'DD-MON-YY') NOT BETWEEN
                                                TO_DATE(l_dts_start,'DD-MON-YY')  AND TO_DATE(l_dts_end ,'DD-MON-YY')
                    THEN
                        DBMS_OUTPUT.PUT_LINE ('1 Just update as is: ' || rec.activity_start_time);
                    
                         UPDATE bi_request_activity
                           SET activity_start_time = (rec.activity_start_time ) + diffInDays,
                              attribute_info ='Y' 
                           WHERE id = rec.id;   
                    END IF;                    
                    
                    
                    --Just update as is
                    IF p_before_event_date BETWEEN      
                                                TO_DATE(l_dts_start,'DD-MON-YY')  AND TO_DATE(l_dts_end ,'DD-MON-YY')
                    AND 
                      TO_DATE(l_check_Date,'DD-MON-YY') BETWEEN
                                                TO_DATE(l_dts_start,'DD-MON-YY')  AND TO_DATE(l_dts_end ,'DD-MON-YY')
                    THEN
                        DBMS_OUTPUT.PUT_LINE ('2 Just update as is: ' || rec.activity_start_time);
                    
                         UPDATE bi_request_activity
                           SET activity_start_time = (rec.activity_start_time) + diffInDays,
                              attribute_info ='Y' 
                           WHERE id = rec.id;   
                    END IF;                    
                ELSIF l_dst_support ='N'
                THEN
                         UPDATE bi_request_activity
                           SET activity_start_time = (rec.activity_start_time) + diffInDays,
                              attribute_info ='Y' 
                           WHERE id = rec.id;                   
                END IF;               
             
            END LOOP;
        
         /*
          UPDATE bi_request_activity
               -- TRUNC(activity_start_time) +( TRUNC(l_currdate) - TRUNC(activity_start_time))
               SET activity_start_time = TO_DATE ( (TRUNC(activity_start_time) + ( TRUNC(l_currdate) - TRUNC(activity_start_time))) || ' ' || TO_CHAR (activity_start_time, 'HH24:MI:SS'),'DD-MM-YY HH24:MI:SS'),
                   attribute_info = 'Y'
             WHERE request_activity_day_id = l_act_id
               AND attribute_info IS NULL;*/
          /*
            UPDATE bi_request_activity
               SET activity_start_time = TO_DATE (TRUNC(l_currdate) || ' ' || TO_CHAR (activity_start_time, 'HH24:MI:SS'),'DD-MM-YY HH24:MI:SS'),
                   attribute_info = 'Y'
             WHERE request_activity_day_id = l_act_id
               AND attribute_info IS NULL;
           */    
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 26: ');
               bi_call_log_proc.call_log_proc (l_chr_err_code,
                              l_chr_err_msg,
                              11,
                              p_actual_duration,
                              p_request_id,
                              'Error while updating bi_request_Activity',
                              SUBSTR (SQLERRM, 1, 255),null);
         END;
         
      END LOOP;

      BEGIN
         DELETE FROM bi_location_calendar
               WHERE     request_id = p_request_id
                     AND start_date NOT BETWEEN to_DATE( p_start_date,'DD-MM-YY')
                                                    AND   to_DATE( p_start_date,'DD-MM-YY')
                                                        + p_duration
                                                        - 1;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 27: ');
            bi_call_log_proc.call_log_proc (l_chr_err_code,
                           l_chr_err_msg,
                           11,
                           p_actual_duration,
                           p_request_id,
                           'Error while deleting bi_location_calendar',
                           SUBSTR (SQLERRM, 1, 255),null);
      END;

      BEGIN
         UPDATE bi_request_Activity_Day
            SET attribute1 = NULL
          WHERE request_id = p_request_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 28: ');
            bi_call_log_proc.call_log_proc (l_chr_err_code,
                           l_chr_err_msg,
                           11,
                           p_actual_duration,
                           p_request_id,
                           'Error while updating bi_request_Activity_Day',
                           SUBSTR (SQLERRM, 1, 255),null);
      END;

      BEGIN
         UPDATE bi_Request_Activity
            SET attribute_info = NULL
          WHERE request_activity_day_id IN (SELECT id
                                              FROM bi_request_activity_day
                                             WHERE request_id = p_request_id);
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE ('Before calling bi_call_log_proc.call_log_proc 29: ');
            bi_call_log_proc.call_log_proc (
               l_chr_err_code,
               l_chr_err_msg,
               11,
               p_actual_duration,
               p_request_id,
               'Error while updating bi_request_Activity attribute',
               SUBSTR (SQLERRM, 1, 255),null);
      END;

      COMMIT;

      EXECUTE IMMEDIATE 'TRUNCATE TABLE bi_loc_temp';
   EXCEPTION
      WHEN OTHERS
      THEN
         bi_call_log_proc.call_log_proc (l_chr_err_code,
                        l_chr_err_msg,
                        11,
                        p_duration,
                        p_request_id,
                        'Error in alter dates proc',
                        SUBSTR (SQLERRM, 1, 255),null);
   END;

/*   PROCEDURE bi_call_log_proc.call_log_proc (out_chr_err_code      OUT VARCHAR2,
                            out_chr_err_msg       OUT VARCHAR2,
                            p_duration         IN     NUMBER,
                            p_request_id       IN     NUMBER,
                            in_chr_err_code    IN     VARCHAR2,
                            in_chr_err_msg     IN     VARCHAR2)
   IS
      l_err_message   VARCHAR2 (300);
      l_err_code      VARCHAR2 (300);
   BEGIN
      DBMS_OUTPUT.PUT_LINE ('INSIDE bi_call_log_proc.call_log_proc: ');
      l_err_message := in_chr_err_msg;
      l_err_code := in_chr_err_code;
      DBMS_OUTPUT.PUT_LINE ('Before insert bi_procedure_log: ');

      BEGIN
         INSERT INTO bi_procedure_log (id,
                                       proc_name,
                                       attribute1,
                                       request_id,
                                       error_message,
                                       ERROR_CODE)
              VALUES (11,
                      'alter_request_activity',
                      p_duration,
                      p_request_id,
                      l_err_code,
                      l_err_message);
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE ('Error in insert bi_procedure_log: ');
            out_chr_err_code := SUBSTR (SQLERRM, 1, 255);
            out_chr_err_msg := 'Unable to insert into bi_procedure_log';
      END;

      COMMIT;
      l_err_message := NULL;
      l_err_code := NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END;*/
END;
/