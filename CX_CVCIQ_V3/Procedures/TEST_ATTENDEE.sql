CREATE OR REPLACE PROCEDURE cx_cvciq_v3.test_attendee (
    out_chr_err_code   OUT                VARCHAR2,
    out_chr_err_msg    OUT                VARCHAR2,
    out_attendee_tab   OUT                return_attendee_arr_result,
    in_from_date       IN                 VARCHAR2,
    in_to_date         IN                 VARCHAR2,
    in_sort_column     IN                 VARCHAR2,
    in_order_by        IN                 VARCHAR2,
    in_location        IN                 VARCHAR2,
    l_start_row_num    IN                 NUMBER,
    l_end_row_num      IN                 NUMBER,
    in_json_doc        IN                 VARCHAR2
) IS

    l_chr_srcstage        VARCHAR2(200);
    l_chr_biqtab          VARCHAR2(200);
    l_chr_srctab          VARCHAR2(200);
    l_chr_bistagtab       VARCHAR2(200);
    l_chr_err_code        VARCHAR2(255);
    l_chr_err_msg         VARCHAR2(255);
    l_out_chr_errbuf      VARCHAR2(2000);
    lrec                  return_attendee_report;
    l_num_counter         NUMBER := 0;
    l_start_date          DATE := TO_DATE(in_from_date, 'dd-mm-yyyy hh24:mi:ss');
    l_end_date            DATE := TO_DATE(in_to_date, 'dd-mm-yyyy hh24:mi:ss');
    l_sort_column         VARCHAR2(30) := lower(in_sort_column);
    l_order_by            VARCHAR2(10) := lower(in_order_by);
    l_location_id         VARCHAR2(256) := in_location;
    l_start_row           NUMBER := l_start_row_num;
    l_end_row             NUMBER := l_end_row_num;
    json_doc              VARCHAR2(1000) := in_json_doc;
    l_country_array   CHAR_ARRAY := fn_json_to_array(json_doc, 'country');
    l_room_array  CHAR_ARRAY := fn_json_to_array(json_doc, 'country');
    CURSOR cur_attendee_data IS
    SELECT
        *
    FROM
        (
            SELECT
                a.*,
                ROWNUM rn
            FROM
                (SELECT * FROM (
                    SELECT
                        r.id              request_id,
                        TO_CHAR(a.event_date, 'MM/DD/YYYY') startdate,
                        (
                            SELECT
                                name
                            FROM
                                bi_location
                            WHERE
                                id = b.room
                        ) room,
                        
                        r.customer_name   customer_name,
                        r.country         country,
                        r.duration        duration,
                        r.customer_name   ext_att_customer_company,
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
                        LEFT JOIN bi_request_catering_activity b ON b.request_activity_day_id = a.id
                        LEFT JOIN bi_request_attendees c ON c.request_id = r.id
                        LEFT JOIN bi_request_act_day_room d ON d.request_activity_day_id = a.id
                                                               AND d.room = b.room
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
                        AND (l_country_array IS NULL 
                        OR country IN (
                            SELECT
                                column_value
                            FROM
                                TABLE ( l_country_array )
                        ))
--                         AND room IN (
--                            SELECT
--                                column_value
--                            FROM
--                                TABLE ( fn_json_to_array(json_doc, 'room') )
--                        )
                        
                    ORDER BY
                        a.event_date,
                        room,
                        customer_name,
                        attendee_type,
                        ext_att_first_name,
                        ext_att_last_name,
                        CASE l_order_by
                            WHEN 'asc'   THEN CASE l_sort_column
                                WHEN 'companycountry'   THEN country
                                WHEN 'visitdate'        THEN startdate
                            END
                        END,
                        CASE l_order_by
                            WHEN 'desc'   THEN CASE l_sort_column
                                WHEN 'companycountry'   THEN country
                                WHEN 'visitdate'        THEN startdate
                            END
                        END DESC
                )
                WHERE
                1=1
--                AND
--                case
--                    when (SELECT
--                                count(column_value)
--                            FROM
--                                TABLE (l_country_array)) > 1 and country in ( SELECT
--                                column_value
--                            FROM
--                                TABLE ( l_country_array)) then 1
--                    else 1
--                    end = 1
--                AND
--                case
--                    when (SELECT
--                                count(column_value)
--                            FROM
--                                TABLE (l_room_array)) > 1 and room in ( SELECT
--                                column_value
--                            FROM
--                                TABLE ( l_room_array)) then 1
--                    else 0
--                    end = 1
                        
                ) a
            WHERE
                ROWNUM <= l_end_row
        )
    WHERE
        rn >= l_start_row;

    TYPE rec_attendee_data IS
        TABLE OF cur_attendee_data%rowtype INDEX BY PLS_INTEGER;
    l_cur_attendee_data   rec_attendee_data;
BEGIN
        dbms_output.put_line(l_country_array.count);

    out_attendee_tab := return_attendee_arr_result();
    OPEN cur_attendee_data;
    LOOP
        FETCH cur_attendee_data BULK COLLECT INTO l_cur_attendee_data;
        EXIT WHEN l_cur_attendee_data.count = 0;
        dbms_output.put_line('here in first insert');

        lrec := return_attendee_report();
        out_attendee_tab := return_attendee_arr_result(return_attendee_report());
        out_attendee_tab.DELETE;
        FOR i IN 1..l_cur_attendee_data.count LOOP


--						 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_attendee_report();
                lrec.requestid := l_cur_attendee_data(i).request_id;
                lrec.visitdate := l_cur_attendee_data(i).startdate;
                lrec.room := l_cur_attendee_data(i).room;
                lrec.company := l_cur_attendee_data(i).customer_name;
                lrec.companycountry := l_cur_attendee_data(i).country;
                lrec.duration := l_cur_attendee_data(i).duration;
                lrec.custcompanyname := l_cur_attendee_data(i).ext_att_customer_company;
                lrec.firstname := l_cur_attendee_data(i).ext_att_first_name;
                lrec.lastname := l_cur_attendee_data(i).ext_att_last_name;
                lrec.title := l_cur_attendee_data(i).ext_att_title;
                lrec.isdecision := l_cur_attendee_data(i).ext_att_is_decision_maker;
                lrec.istechnical := l_cur_attendee_data(i).is_technical;
--                lrec.attendeetype := l_cur_attendee_data(i).attendee_type;
                lrec.attendeetype := json_doc;
--                dbms_output.put_line(lrec.attendeetype);
                IF l_num_counter > 1 THEN
                    out_attendee_tab.extend();
                    out_attendee_tab(l_num_counter) := return_attendee_report();
                ELSE
                    out_attendee_tab := return_attendee_arr_result(return_attendee_report());
                END IF;

                out_attendee_tab(l_num_counter) := lrec;
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