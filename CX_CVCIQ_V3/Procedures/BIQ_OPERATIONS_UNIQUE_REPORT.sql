CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_operations_unique_report (
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
            WHEN 'room'              THEN room
            WHEN 'company'           THEN company
            WHEN 'briefingmanager'   THEN briefingmanager
            WHEN 'host'              THEN host
            WHEN 'requesttype'       THEN requesttype
        END ) value
    FROM
        (
            SELECT
                b.id                             requestid,
                c.id                             requestactivitydayid,
                (
                    SELECT
                        name
                    FROM
                        bi_location
                    WHERE
                        id = a.room
                ) room,
                a.room_type                      room_type,
                fn_ts_to_time(c.arrival_ts, l_location_id, 0) starttime,
                fn_ts_to_time(c.adjourn_ts, l_location_id, 0) endtime,
                TO_CHAR(c.event_date, 'MM/DD/YYYY') startdate,
                b.customer_name                  company,
                (
                    SELECT
                        d.user_name
                    FROM
                        bi_user d
                    WHERE
                        d.id = b.briefing_manager
                ) briefingmanager,
                b.host_email                     host,
                b.expected_no_of_ext_attendees   oracleattendees,
                b.expected_no_of_int_attendees   extattendees,
                b.no_of_gifts                    amountofgifts,
                b.gift_type                      gifttype,
                t.id                             topicid,
                concat(bp.first_name, concat(' ', bp.last_name)) executive,
                CASE bp.is_executive
                    WHEN '1'   THEN fn_ts_to_time(t.activity_start_time, l_location_id, 0)
                    ELSE NULL
                END agendastarttime,
                t.activity_start_time            sort_start_time,
                CASE bp.is_executive
                    WHEN '1'   THEN fn_ts_to_time(t.activity_start_time, l_location_id, t.duration)
                    ELSE NULL
                END agendaendtime,
                t.duration                       sort_duration,
                (select name from bi_request_type where id = b.request_type_id )  requesttype
            FROM
                bi_request b
                LEFT OUTER JOIN bi_request_activity_day c ON c.request_id = b.id
                LEFT OUTER JOIN bi_request_act_day_room a ON a.request_activity_day_id = c.id
                INNER JOIN bi_request_topic_activity t ON t.request_activity_day_id = c.id
                                                          AND a.room = t.room
                INNER JOIN bi_request_presenter p ON p.bi_request_topic_activity_id = t.id
                                                     AND p.status = 'Accepted'
                INNER JOIN bi_presenter bp ON bp.id = p.temp_presenter_id
                                              AND b.location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = l_location_id
                )
                                              AND bp.is_executive = 1
            WHERE
                b.state = 'CONFIRMED'
                AND c.event_date BETWEEN l_start_date AND l_end_date
                AND b.location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = l_location_id
                )
            UNION
            SELECT
                b.id                             requestid,
                c.id                             requestactivitydayid,
                (
                    SELECT
                        name
                    FROM
                        bi_location
                    WHERE
                        id = a.room
                ) room,
                a.room_type                      room_type,
                fn_ts_to_time(c.arrival_ts, l_location_id, 0) starttime,
                fn_ts_to_time(c.adjourn_ts, l_location_id, 0) endtime,
                TO_CHAR(c.event_date, 'MM/DD/YYYY') startdate,
                b.customer_name                  company,
                (
                    SELECT
                        d.user_name
                    FROM
                        bi_user d
                    WHERE
                        d.id = b.briefing_manager
                ) briefingmanager,
                b.host_email                     host,
                b.expected_no_of_ext_attendees   oracleattendees,
                b.expected_no_of_int_attendees   extattendees,
                b.no_of_gifts                    amountofgifts,
                b.gift_type                      gifttype,
                NULL topicid,
                NULL executive,
                NULL agendastarttime,
                NULL sort_start_time,
                NULL agendaendtime,
                NULL sort_duration,
                (select name from bi_request_type where id = b.request_type_id )  requesttype
            FROM
                bi_request b
                LEFT OUTER JOIN bi_request_activity_day c ON c.request_id = b.id
                LEFT OUTER JOIN bi_request_act_day_room a ON a.request_activity_day_id = c.id
            WHERE
                b.state = 'CONFIRMED'
                AND c.event_date BETWEEN l_start_date AND l_end_date
                AND b.location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = l_location_id
                )
                AND (a.room,a.request_activity_day_id) NOT IN (
                                    SELECT
                                        a.room,a.request_activity_day_id
                    FROM
                        bi_request b
                        LEFT OUTER JOIN bi_request_activity_day c ON c.request_id = b.id
                        LEFT OUTER JOIN bi_request_act_day_room a ON a.request_activity_day_id = c.id
                        INNER JOIN bi_request_topic_activity t ON t.request_activity_day_id = c.id
                                                                  AND a.room = t.room
                        INNER JOIN bi_request_presenter p ON p.bi_request_topic_activity_id = t.id
                                                             AND p.status = 'Accepted'
                        INNER JOIN bi_presenter bp ON bp.id = p.temp_presenter_id
                                                      AND b.location_id = (
                            SELECT UNIQUE
                                ( id )
                            FROM
                                bi_location
                            WHERE
                                unique_id = l_location_id
                        )
                                                      AND bp.is_executive = 1
                    WHERE
                        b.state = 'CONFIRMED'
                        AND c.event_date BETWEEN l_start_date AND l_end_date
                        AND b.location_id = (
                            SELECT UNIQUE
                                ( id )
                            FROM
                                bi_location
                            WHERE
                                unique_id = l_location_id
                        )
                )
        )
    WHERE
        CASE l_unique_column
            WHEN 'room'              THEN room
            WHEN 'company'           THEN company
            WHEN 'briefingmanager'   THEN briefingmanager
            WHEN 'host'              THEN host
            WHEN 'requesttype'       THEN requesttype
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