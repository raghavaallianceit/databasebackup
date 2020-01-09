CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_security_unique_report (
    out_chr_err_code   OUT                VARCHAR2,
    out_chr_err_msg    OUT                VARCHAR2,
    out_tab            OUT                return_unique_arr,
    in_from_date       IN                 VARCHAR2,
    in_to_date         IN                 VARCHAR2,
    in_unique_column   IN                 VARCHAR2,
    in_location        IN                 VARCHAR2
) IS

    l_chr_srcstage     VARCHAR2(200);
    l_chr_biqtab       VARCHAR2(200);
    l_chr_srctab       VARCHAR2(200);
    l_chr_bistagtab    VARCHAR2(200);
    l_chr_err_code     VARCHAR2(255);
    l_chr_err_msg      VARCHAR2(255);
    l_out_chr_errbuf   VARCHAR2(2000);
    lrec               return_unique_report;
    l_num_counter      NUMBER := 0;
    l_start_date       DATE := TO_DATE(in_from_date, 'dd-mm-yyyy hh24:mi:ss');
    l_end_date         DATE := TO_DATE(in_to_date, 'dd-mm-yyyy hh24:mi:ss');
    l_unique_column    VARCHAR2(30) := lower(in_unique_column);
    l_location_id      VARCHAR2(256) := in_location;
    CURSOR cursor_data IS
    SELECT UNIQUE
        ( CASE l_unique_column
            WHEN 'companyname'   THEN customer_name
            WHEN 'room'          THEN room
            WHEN 'host'          THEN host_email
        END ) value
    FROM
        (
            SELECT
                r.id              requestid,
                TO_CHAR(a.event_date, 'MM/DD/YYYY') event_date,
                fn_ts_to_time(c.start_time, l_location_id, 0) starttime,
                fn_ts_to_time(c.end_time, l_location_id, 0) endtime,
                c.start_time      sort_start_time,
                c.end_time        sort_end_time,
                r.customer_name   customer_name,
                r.host_email      host_email,
                (
                    SELECT
                        d.user_name
                    FROM
                        bi_user d
                    WHERE
                        d.id = r.briefing_manager
                ) briefingmanager,
                (
                    SELECT
                        name
                    FROM
                        bi_location
                    WHERE
                        id = c.room
                ) room,
                (
                    SELECT
                        code
                    FROM
                        bi_location
                    WHERE
                        id = c.room
                ) building,
                r.country         country,
                b.company         custcompanyname,
                b.first_name      first_name,
                b.last_name       lastname,
                b.designation     title,
                DECODE(b.attendee_type, 'externalattendees', 'External', 'Internal') attendeetype
            FROM
                bi_request r
                LEFT OUTER JOIN bi_request_activity_day a ON a.request_id = r.id
                LEFT OUTER JOIN bi_request_attendees b ON b.request_id = r.id
                LEFT OUTER JOIN bi_request_act_day_room c ON c.request_activity_day_id = a.id
                                                             AND c.room_type = 'MAIN_ROOM'
            WHERE
                r.state = 'CONFIRMED'
                AND a.event_date BETWEEN l_start_date AND l_end_date
                AND b.attendee_type = 'externalattendees'
                AND r.location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = l_location_id
                )
        )
    WHERE
        CASE l_unique_column
            WHEN 'companyname'   THEN customer_name
            WHEN 'room'          THEN room
            WHEN 'host'          THEN host_email
        END IS NOT NULL
    ORDER BY
        value;

    TYPE rec_attendee_data IS
        TABLE OF cursor_data%rowtype INDEX BY PLS_INTEGER;
    l_cursor_data      rec_attendee_data;
BEGIN
    out_tab := return_unique_arr();
    OPEN cursor_data;
    LOOP
        FETCH cursor_data BULK COLLECT INTO l_cursor_data;
        EXIT WHEN l_cursor_data.count = 0;
        dbms_output.put_line('here in first insert');
        lrec := return_unique_report();
        out_tab := return_unique_arr(return_unique_report());
        out_tab.DELETE;
        FOR i IN 1..l_cursor_data.count LOOP

--						 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_unique_report();
                lrec.value := l_cursor_data(i).value;
                IF l_num_counter > 1 THEN
                    out_tab.extend();
                    out_tab(l_num_counter) := return_unique_report();
                ELSE
                    out_tab := return_unique_arr(return_unique_report());
                END IF;

                out_tab(l_num_counter) := lrec;
            EXCEPTION
                WHEN OTHERS THEN
                    dbms_output.put_line('Error occurred : ' || sqlerrm);
            END;
        END LOOP;

    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('HERE INSIIDE OTHERS' || sqlerrm);
END;
/