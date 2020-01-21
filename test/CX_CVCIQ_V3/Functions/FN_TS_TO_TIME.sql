CREATE OR REPLACE FUNCTION cx_cvciq_v3.fn_ts_to_time(in_date IN TIMESTAMP,in_loc_timezone VARCHAR2,in_duration NUMBER)
RETURN VARCHAR2
IS

l_out_time VARCHAR2(50) ;
l_ts TIMESTAMP := FN_DAY_LIGHT_TS(in_date);


BEGIN

BEGIN

        IF l_ts IS NOT NULL
            THEN
            IF (in_duration > 0)
                    THEN
                        SELECT (TO_CHAR(new_time(l_ts + in_duration/1440, 'GMT',(
                        SELECT
                        "A8"."LOCATION_TIMEZONE_DB" "LOCATION_TIMEZONE_DB"
                        FROM
                        "BI_LOCATION" "A8"
                        WHERE
                        "A8"."UNIQUE_ID" = in_loc_timezone
                        )), 'HH:MI AM'))
                        INTO l_out_time 
                        FROM dual; --to excract TIme from given TS
--                         DBMS_OUTPUT.PUT_LINE(in_date||' ADD'||l_out_time);
                    END IF; 
                    IF (in_duration <= 0)
                     THEN
                        SELECT (TO_CHAR(new_time(l_ts, 'GMT',(
                        SELECT
                        "A8"."LOCATION_TIMEZONE_DB" "LOCATION_TIMEZONE_DB"
                        FROM
                        "BI_LOCATION" "A8"
                        WHERE
                        "A8"."UNIQUE_ID" = in_loc_timezone
                        )), 'HH:MI AM'))
                        INTO l_out_time 
                        FROM dual; 
                -- DBMS_OUTPUT.PUT_LINE(in_date||' SAME'||l_out_time);

                     END IF;
                END IF; 
                EXCEPTION
                WHEN OTHERS
                THEN
                DBMS_OUTPUT.PUT_LINE ('Error getting the Time' || SQLERRM);
                END ;
        RETURN l_out_time;

END fn_ts_to_time;
/