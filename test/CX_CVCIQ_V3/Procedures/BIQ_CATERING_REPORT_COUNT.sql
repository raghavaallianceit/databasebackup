CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_catering_report_count (
    out_chr_err_code    OUT                 VARCHAR2,
    out_chr_err_msg     OUT                 VARCHAR2,
    out_no_of_records   OUT                 NUMBER,
    in_from_date        IN                  VARCHAR2,
    in_to_date          IN                  VARCHAR2,
    in_sort_column      IN                  VARCHAR2,
    in_order_by         IN                  VARCHAR2,
    in_location         IN                  VARCHAR2
) IS

    l_no_of_records   NUMBER := 0;
    l_start_date      DATE := TO_DATE(in_from_date, 'dd-mm-yyyy hh24:mi:ss');
    l_end_date        DATE := TO_DATE(in_to_date, 'dd-mm-yyyy hh24:mi:ss');
    l_sort_column     VARCHAR2(30) := lower(in_sort_column);
    l_order_by        VARCHAR2(10) := lower(in_order_by);
    l_location_id     VARCHAR2(256) := in_location;
BEGIN
    SELECT
        COUNT(*)
    INTO l_no_of_records
    FROM
        ( (
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
        ) );

    out_no_of_records := l_no_of_records;
--         dbms_output.put_line('l_no_of_records :-'||l_no_of_records);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('HERE INSIIDE OTHERS' || sqlerrm);
END;
/