CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_operations_report_count (
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
        (SELECT
                        *
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
                                (select name from bi_request_type where id = b.request_type_id ) requesttype

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
        );

    out_no_of_records := l_no_of_records;
--         dbms_output.put_line('l_no_of_records :-'||l_no_of_records);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('HERE INSIIDE OTHERS' || sqlerrm);
END;
/