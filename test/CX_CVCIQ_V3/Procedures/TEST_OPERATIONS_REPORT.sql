CREATE OR REPLACE PROCEDURE cx_cvciq_v3.test_operations_report (
    out_chr_err_code   OUT                VARCHAR2,
    out_chr_err_msg    OUT                VARCHAR2,
    out_oper_rep_tab   OUT                return_oper_arr_result,
    in_from_date       IN                 DATE,
    in_to_date         IN                 DATE,
    in_sort_column     IN                 VARCHAR2,
    in_order_by        IN                 VARCHAR2,
    in_location        IN                 VARCHAR2,
    l_start_row_num    IN                 NUMBER,
    l_end_row_num      IN                 NUMBER
) IS

    l_chr_srcstage          VARCHAR2(200);
    l_chr_biqtab            VARCHAR2(200);
    l_chr_srctab            VARCHAR2(200);
    l_chr_bistagtab         VARCHAR2(200);
    l_chr_err_code          VARCHAR2(255);
    l_chr_err_msg           VARCHAR2(255);
    l_out_chr_errbuf        VARCHAR2(2000);
    lrec                    return_oper_report;
    l_num_counter           NUMBER := 0;
    l_start_date            DATE := in_from_date;
    l_end_date              DATE := in_to_date + 1;
    l_sort_column           VARCHAR2(30) := lower(in_sort_column);
    l_order_by              VARCHAR2(10) := lower(in_order_by);
    l_location_id           VARCHAR2(256) := in_location;
    l_start_row             NUMBER := l_start_row_num;
    l_end_row               NUMBER := l_end_row_num;
    CURSOR cur_operations_data IS
    SELECT
        *
    FROM
        (
            SELECT
                a.*,
                ROWNUM rn
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
                        a.room_type room_type,
                        fn_ts_to_time(c.arrival_ts, l_location_id, 0) starttime,
                        fn_ts_to_time(c.adjourn_ts, l_location_id, 0) endtime,
                        TO_CHAR(c.event_date, 'MM-DD-YYYY') startdate,
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
                        b.gift_type                      gifttype
                    FROM
                        bi_request_act_day_room a,
                        bi_request b,
                        bi_request_activity_day c
                    WHERE
                        b.state = 'CONFIRMED'
                        AND b.id IN (
                            SELECT
                                request_id
                            FROM
                                bi_request_activity_day
                            WHERE
                                event_date BETWEEN l_start_date AND l_end_date
                        )
                        AND c.event_date BETWEEN l_start_date AND l_end_date
                        AND b.location_id = (
                            SELECT UNIQUE
                                ( id )
                            FROM
                                bi_location
                            WHERE
                                unique_id = l_location_id
                        )
                        AND a.request_id = b.id
                        AND c.id = a.request_activity_day_id
                    ORDER BY
                        c.event_date,
                        room_type DESC ,
                        room 
                ) a
            WHERE
                ROWNUM <= l_end_row
        )
    WHERE
        rn >= l_start_row;

    TYPE rec_operations_data IS
        TABLE OF cur_operations_data%rowtype INDEX BY PLS_INTEGER;
    l_cur_operations_data   rec_operations_data;
BEGIN
    out_oper_rep_tab := return_oper_arr_result();
    OPEN cur_operations_data;
    LOOP
        FETCH cur_operations_data BULK COLLECT INTO l_cur_operations_data;
        EXIT WHEN l_cur_operations_data.count = 0;
        dbms_output.put_line('here in first insert');
        lrec := return_oper_report();
        out_oper_rep_tab := return_oper_arr_result(return_oper_report());
        out_oper_rep_tab.DELETE;
        FOR i IN 1..l_cur_operations_data.count LOOP

					---	 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_oper_report();
                lrec.requestactivitydayid := l_cur_operations_data(i).requestactivitydayid;
                lrec.requestid := l_cur_operations_data(i).requestid;
                lrec.room := l_cur_operations_data(i).room;
                lrec.starttime := l_cur_operations_data(i).starttime;
                lrec.endtime := l_cur_operations_data(i).endtime;
                lrec.startdate := l_cur_operations_data(i).startdate;
                lrec.company := l_cur_operations_data(i).company;
                lrec.briefingmanager := l_cur_operations_data(i).briefingmanager;
                lrec.host := l_cur_operations_data(i).host;
                lrec.oracleattendees := l_cur_operations_data(i).oracleattendees;
                lrec.extattendees := l_cur_operations_data(i).extattendees;
                lrec.amountofgifts := l_cur_operations_data(i).amountofgifts;
                lrec.gifttype := l_cur_operations_data(i).gifttype;
                IF l_num_counter > 1 THEN
                    out_oper_rep_tab.extend();
                    out_oper_rep_tab(l_num_counter) := return_oper_report();
                ELSE
                    out_oper_rep_tab := return_oper_arr_result(return_oper_report());
                END IF;

                out_oper_rep_tab(l_num_counter) := lrec;
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