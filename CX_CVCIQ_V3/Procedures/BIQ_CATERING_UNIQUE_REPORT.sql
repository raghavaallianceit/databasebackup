CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_catering_unique_report (
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
            WHEN 'companycountry'    THEN country
            WHEN 'host'              THEN host
            WHEN 'requestername'     THEN requestername
            WHEN 'briefingmanager'   THEN briefingmanager
        END ) value
    FROM
        (
            (
            SELECT
                *
            FROM
                (
                    SELECT DISTINCT
                        *
                    FROM
                        (
                            SELECT
                                d.id              requestactivitydayid,
                                d.request_id      requestid,
                                TO_CHAR(d.event_date, 'MM/DD/YYYY') startdate,
                                TO_DATE(d.event_date, 'dd-mm-yyyy') r_date,
                                (
                                    SELECT
                                        name
                                    FROM
                                        bi_location
                                    WHERE
                                        id = c.room
                                ) room,
                                b.customer_name   company,
                                b.country         country,
                                (
                                    SELECT
                                        d.user_name
                                    FROM
                                        bi_user d
                                    WHERE
                                        d.id = b.briefing_manager
                                ) briefingmanager,
                                b.host_email      host,
                                b.host_contact    hostphonenumber,
                                (
                                    SELECT
                                        uc.value
                                    FROM
                                        bi_user_contact uc
                                    WHERE
                                        uc.user_id = b.requestor
                                        AND uc.contact_type = 'email'
                                ) requestername,
                                (
                                    SELECT
                                        uc.value
                                    FROM
                                        bi_user_contact uc
                                    WHERE
                                        uc.user_id = b.requestor
                                        AND uc.contact_type = 'phoneNumber'
                                ) requesterphonenumber,
                                fn_ts_to_time(d.arrival_ts, l_location_id, 0) starttime,
                                d.arrival_ts      activity_start_time,
                                NULL duration,
                                '-' endtime,
                                'Arrival' cateringtype,
                                NULL attendess,
                                NULL notes,
                                b.cost_center     costcenter,
                                NULL dietary,
                                NULL cateringactivityid,
                                1 roworder
                            FROM
                                bi_request b
                                LEFT JOIN bi_request_activity_day d ON d.request_id = b.id
                                LEFT JOIN bi_request_catering_activity c ON c.request_activity_day_id = d.id
                                LEFT JOIN bi_request_act_day_room b ON b.request_activity_day_id = d.id
                                                                       AND b.room = c.room
                            WHERE
                                b.state = 'CONFIRMED'
                                AND d.event_date BETWEEN l_start_date AND l_end_date
                                AND b.location_id = (
                                    SELECT UNIQUE
                                        ( id )
                                    FROM
                                        bi_location
                                    WHERE
                                        unique_id = l_location_id
                                )
                        )
                    UNION ALL
                    SELECT
                        d.id                    requestactivitydayid,
                        d.request_id            requestid,
                        TO_CHAR(d.event_date, 'MM/DD/YYYY') startdate,
                        TO_DATE(d.event_date, 'dd-mm-yyyy') r_date,
                        (
                            SELECT
                                name
                            FROM
                                bi_location
                            WHERE
                                id = c.room
                        ) room,
                        b.customer_name         company,
                        b.country               country,
                        (
                            SELECT
                                d.user_name
                            FROM
                                bi_user d
                            WHERE
                                d.id = b.briefing_manager
                        ) briefingmanager,
                        b.host_email            host,
                        b.host_contact          hostphonenumber,
                        (
                            SELECT
                                uc.value
                            FROM
                                bi_user_contact uc
                            WHERE
                                uc.user_id = b.requestor
                                AND uc.contact_type = 'email'
                        ) requestername,
                        (
                            SELECT
                                uc.value
                            FROM
                                bi_user_contact uc
                            WHERE
                                uc.user_id = b.requestor
                                AND uc.contact_type = 'phoneNumber'
                        ) requesterphonenumber,
                        fn_ts_to_time(c.activity_start_time, l_location_id, 0) starttime,
                        c.activity_start_time   activity_start_time,
                        c.duration              duration,
                        fn_ts_to_time(c.activity_start_time, l_location_id, c.duration) endtime,
                        c.catering_type         cateringtype,
                        c.no_of_attendees       attendess,
                        c.notes                 notes,
                        b.cost_center           costcenter,
                        fn_code_to_lookup(c.diet_information, l_location_id, 'DIET_INFO') dietary,
                        c.id                    cateringactivityid,
                        2 roworder
                    FROM
                        bi_request b
                        LEFT JOIN bi_request_activity_day d ON d.request_id = b.id
                        LEFT JOIN bi_request_catering_activity c ON c.request_activity_day_id = d.id
                        LEFT JOIN bi_request_act_day_room b ON b.request_activity_day_id = d.id
                                                               AND b.room = c.room
                    WHERE
                        b.state = 'CONFIRMED'
                        AND d.event_date BETWEEN l_start_date AND l_end_date
                        AND b.location_id = (
                            SELECT UNIQUE
                                ( id )
                            FROM
                                bi_location
                            WHERE
                                unique_id = l_location_id
                        )
                    UNION ALL
                    SELECT DISTINCT
                        *
                    FROM
                        (
                            SELECT
                                d.id              requestactivitydayid,
                                d.request_id      requestid,
                                TO_CHAR(d.event_date, 'MM/DD/YYYY') startdate,
                                TO_DATE(d.event_date, 'dd-mm-yyyy') r_date,
                                (
                                    SELECT
                                        name
                                    FROM
                                        bi_location
                                    WHERE
                                        id = c.room
                                ) room,
                                b.customer_name   company,
                                b.country         country,
                                (
                                    SELECT
                                        d.user_name
                                    FROM
                                        bi_user d
                                    WHERE
                                        d.id = b.briefing_manager
                                ) briefingmanager,
                                b.host_email      host,
                                b.host_contact    hostphonenumber,
                                (
                                    SELECT
                                        uc.value
                                    FROM
                                        bi_user_contact uc
                                    WHERE
                                        uc.user_id = b.requestor
                                        AND uc.contact_type = 'email'
                                ) requestername,
                                (
                                    SELECT
                                        uc.value
                                    FROM
                                        bi_user_contact uc
                                    WHERE
                                        uc.user_id = b.requestor
                                        AND uc.contact_type = 'phoneNumber'
                                ) requesterphonenumber,
                                '-' starttime,
                                d.arrival_ts      activity_start_time,
                                NULL duration,
                                fn_ts_to_time(d.adjourn_ts, l_location_id, 0) endtime,
                                'Adjourn' cateringtype,
                                NULL attendess,
                                NULL notes,
                                b.cost_center     costcenter,
                                NULL dietary,
                                NULL cateringactivityid,
                                3 roworder
                            FROM
                                bi_request b
                                LEFT JOIN bi_request_activity_day d ON d.request_id = b.id
                                LEFT JOIN bi_request_catering_activity c ON c.request_activity_day_id = d.id
                                LEFT JOIN bi_request_act_day_room b ON b.request_activity_day_id = d.id
                                                                       AND b.room = c.room
                            WHERE
                                b.state = 'CONFIRMED'
                                AND d.event_date BETWEEN l_start_date AND l_end_date
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
        )
        )
    WHERE
        CASE l_unique_column
            WHEN 'room'              THEN room
            WHEN 'company'           THEN company
            WHEN 'companycountry'    THEN country
            WHEN 'host'              THEN host
            WHEN 'requestername'     THEN requestername
            WHEN 'briefingmanager'   THEN briefingmanager
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