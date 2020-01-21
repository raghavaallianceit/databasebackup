CREATE OR REPLACE FUNCTION cx_cvciq_v3."FN_DAY_LIGHT_TS" (in_ts IN TIMESTAMP)
   RETURN TIMESTAMP
   IS
   
       l_given_year NUMBER;
       l_march_date DATE;
       l_nov_date DATE;
       l_out_ts TIMESTAMP ;

   BEGIN

         BEGIN

           IF in_ts IS NOT NULL
           THEN

             SELECT EXTRACT(YEAR FROM in_ts) 
               INTO l_given_year 
               FROM dual;  --to excract year from given date
            END IF;   

         EXCEPTION
           WHEN OTHERS
           THEN
             DBMS_OUTPUT.PUT_LINE ('Error getting the year' || SQLERRM);
         END ;

         BEGIN

          IF l_given_year IS NOT NULL
          THEN

           SELECT NEXT_DAY(TRUNC(TO_DATE(TO_CHAR(l_given_year||'/03/01'), 'YYYY/MM/DD'),'MM')-1,'Sunday')+7 ,
                  NEXT_DAY(TRUNC(TO_DATE(TO_CHAR(l_given_year||'/11/01'), 'YYYY/MM/DD'),'MM')-1,'Sunday')
             INTO l_march_date,
                  l_nov_date 
             FROM DUAL;    --to get date of march and nov dst dates

          END IF;   
         EXCEPTION
           WHEN OTHERS
           THEN
             DBMS_OUTPUT.PUT_LINE ('Error getting the march and nov dates for an year' || SQLERRM);
         END ;

        IF in_ts IS NOT NULL
        THEN  
                IF in_ts >= TO_TIMESTAMP(l_march_date,'DD-MM-YY HH24:MI:SS.FF') AND in_ts <= TO_TIMESTAMP(l_nov_date,'DD-MM-YY HH24:MI:SS.FF')
                THEN

                    BEGIN
                      SELECT in_ts + interval '1' hour 
                        INTO l_out_ts 
                        FROM dual;
                    EXCEPTION
                      WHEN OTHERS
                      THEN
                         DBMS_OUTPUT.PUT_LINE ('Error getting o/p' || SQLERRM);
                    END ; 

                ELSE

                    BEGIN
                     SELECT in_ts 
                       INTO l_out_ts 
                       FROM dual;
                    EXCEPTION
                      WHEN OTHERS
                      THEN
                         DBMS_OUTPUT.PUT_LINE ('Error getting the march and nov dates for an year' || SQLERRM);
                    END ;  

                END IF;
         END IF;

        RETURN l_out_ts;

    END fn_day_light_ts;
/