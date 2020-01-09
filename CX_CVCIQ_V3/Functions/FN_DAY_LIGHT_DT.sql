CREATE OR REPLACE FUNCTION cx_cvciq_v3."FN_DAY_LIGHT_DT" (in_date IN DATE)
   RETURN DATE
   IS
   
       l_given_year NUMBER;
       l_march_date DATE;
       l_nov_date DATE;
       l_out_dt TIMESTAMP ;

   BEGIN

         BEGIN

           IF in_date IS NOT NULL
           THEN

             SELECT EXTRACT(YEAR FROM in_date) 
               INTO l_given_year 
               FROM dual;  --to excract year from given date
           END IF;    

         EXCEPTION
           WHEN OTHERS
           THEN
             DBMS_OUTPUT.PUT_LINE ('Error getting the year' || SQLERRM);
         END ;

       --   DBMS_OUTPUT.PUT_LINE ('l_given_year : ' || l_given_year  || 'in_date : ' || in_date);

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
             DBMS_OUTPUT.PUT_LINE ('Error getting the march and nov dates for an year in DATE' || SQLERRM);
         END ;

          --  DBMS_OUTPUT.PUT_LINE ('l_march_date' || l_march_date ); 
         --   DBMS_OUTPUT.PUT_LINE ('l_nov_date' || l_nov_date ); 

            IF in_date IS NOT NULL
            THEN

                IF in_date >= l_march_date  AND in_date <= l_nov_date
                THEN

                    BEGIN
                      SELECT in_date - interval '1' hour 
                        INTO l_out_dt 
                        FROM dual;
                    EXCEPTION
                      WHEN OTHERS
                      THEN
                         DBMS_OUTPUT.PUT_LINE ('Error getting o/p' || SQLERRM);
                    END ; 

                ELSE

                    BEGIN
                     SELECT in_date 
                       INTO l_out_dt 
                       FROM dual;
                    EXCEPTION
                      WHEN OTHERS
                      THEN
                         DBMS_OUTPUT.PUT_LINE ('Error getting the march and nov dates for an year' || SQLERRM);
                    END ;  

                END IF; 
         END IF;

        RETURN l_out_dt;

    END fn_day_light_dt;
/