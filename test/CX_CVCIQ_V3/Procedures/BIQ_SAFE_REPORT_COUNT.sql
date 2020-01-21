CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_safe_report_count (
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
                        code
                    FROM
                        bi_location
                    WHERE
                        id = b.room
                ) building,
                fn_ts_to_time(a.arrival_ts, in_location, 0) starttime,
                fn_ts_to_time(a.adjourn_ts, in_location, 0) endtime,
                (
                    SELECT
                        name
                    FROM
                        bi_location
                    WHERE
                        id = b.room
                ) room,
                b.room_type       room_type,
                r.customer_name   customer_name,
                r.host_name       host_name,
                r.customer_name   ext_att_customer_company,
                c.first_name      ext_att_first_name,
                c.last_name       ext_att_last_name,
                c.email           ext_att_email,
                'N/A' phone,
                'Visitor' visitortype,
                'N/A' dob
            FROM
                bi_request r
                LEFT OUTER JOIN bi_request_activity_day a ON r.id = a.request_id
                LEFT OUTER JOIN bi_request_act_day_room b ON b.request_activity_day_id = a.id
                                                             AND b.room_type = 'MAIN_ROOM'
                LEFT OUTER JOIN bi_request_attendees c ON c.request_id = r.id
            WHERE
                r.state = 'CONFIRMED'
                AND a.event_date BETWEEN l_start_date AND l_end_date
                AND r.location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = in_location
                )
                AND c.attendee_type = 'externalattendees'
        );

    out_no_of_records := l_no_of_records;
--         dbms_output.put_line('l_no_of_records :-'||l_no_of_records);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('HERE INSIIDE OTHERS' || sqlerrm);
END;
/