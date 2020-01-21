CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_security_report_count (
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
        );

    out_no_of_records := l_no_of_records;
--         dbms_output.put_line('l_no_of_records :-'||l_no_of_records);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('HERE INSIIDE OTHERS' || sqlerrm);
END;
/