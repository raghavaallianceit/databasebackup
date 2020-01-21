CREATE OR REPLACE FUNCTION cx_cvciq_v3.fn_timestamp_to_time_dt(in_date IN TIMESTAMP,in_loc_timezone VARCHAR2,in_duration NUMBER)
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
--                         DBMS_OUTPUT.PUT_LINE(in_date||' ADD'||l_out_time);
                    END IF; 
                    IF (in_duration <= 0)
                     THEN
                        SELECT (TO_CHAR(new_time(in_date, 'GMT',(
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
--DBMS_OUTPUT.PUT_LINE ('bkjbckjbsdckjds'|| in_date ||' in_loc_timezone '|| in_loc_timezone || ' in_duration ' || in_duration);
                END IF; 
                -- DBMS_OUTPUT.PUT_LINE ('bkjbckjbsdckjds'|| in_date ||' in_loc_timezone '|| in_loc_timezone || ' in_duration ' || in_duration);
                EXCEPTION
                WHEN OTHERS
                THEN
                DBMS_OUTPUT.PUT_LINE ('Error getting the Time' || SQLERRM);
                END ;
        RETURN l_out_time;

END fn_timestamp_to_time_dt;
/