CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_attendee_report_count (
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
                r.id              request_id,
                TO_CHAR(a.event_date, 'MM/DD/YYYY') startdate,
                (
                    SELECT
                        name
                    FROM
                        bi_location
                    WHERE
                        id = d.room
                ) room,
                r.customer_name   customer_name,
                r.country         country,
                r.duration        duration,
                c.company         ext_att_customer_company,
                c.first_name      ext_att_first_name,
                c.last_name       ext_att_last_name,
                c.designation     ext_att_title,
                CASE
                    WHEN c.attendee_type = 'externalattendees' THEN DECODE(c.is_decision_maker, 1, 'Y', 'N')
                    ELSE 'N/A'
                END ext_att_is_decision_maker,
                CASE
                    WHEN c.attendee_type = 'externalattendees' THEN DECODE(c.is_technical, 1, 'Y', 'N')
                    ELSE 'N/A'
                END is_technical,
                DECODE(c.attendee_type, 'externalattendees', 'External', 'Internal') attendee_type
            FROM
                bi_request r
                LEFT JOIN bi_request_activity_day a ON a.request_id = r.id
                LEFT JOIN bi_request_attendees c ON c.request_id = r.id
                LEFT JOIN bi_request_act_day_room d ON d.request_activity_day_id = a.id
            WHERE
                r.state = 'CONFIRMED'
                AND a.event_date BETWEEN l_start_date AND l_end_date
                AND r.location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = l_location_id
                )
                AND d.room_type = 'MAIN_ROOM'
        );

    out_no_of_records := l_no_of_records;
--         dbms_output.put_line('l_no_of_records :-'||l_no_of_records);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('HERE INSIIDE OTHERS' || sqlerrm);
END;
/