CREATE OR REPLACE PROCEDURE cx_cvciq_v3.test_catering_report (
    out_chr_err_code   OUT                VARCHAR2,
    out_chr_err_msg    OUT                VARCHAR2,
    out_cate_rep_tab   OUT                return_cat_arr_result,
    in_from_date       IN                 DATE,
    in_to_date         IN                 DATE,
    in_sort_column     IN                 VARCHAR2,
    in_order_by        IN                 VARCHAR2,
    in_location        IN                 VARCHAR2,
    l_start_row_num    IN                 NUMBER,
    l_end_row_num      IN                 NUMBER
) IS

    l_chr_srcstage        VARCHAR2(200);
    l_chr_biqtab          VARCHAR2(200);
    l_chr_srctab          VARCHAR2(200);
    l_chr_bistagtab       VARCHAR2(200);
    l_chr_err_code        VARCHAR2(255);
    l_chr_err_msg         VARCHAR2(255);
    l_out_chr_errbuf      VARCHAR2(2000);
    lrec                  return_cat_report;
    l_num_counter         NUMBER := 0;
    l_start_date          DATE := in_from_date;
    l_end_date            DATE := in_to_date + 1;
    l_sort_column         VARCHAR2(30) := lower(in_sort_column);
    l_order_by            VARCHAR2(10) := lower(in_order_by);
    l_location_id         VARCHAR2(256) := in_location;
    l_start_row           NUMBER := l_start_row_num;
    l_end_row             NUMBER := l_end_row_num;
    CURSOR cur_catering_data IS
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
                        d.id                requestactivitydayid,
                        d.request_id        requestid,
                        TO_CHAR(d.event_date, 'MM-DD-YYYY') startdate,
                        (
                            SELECT
                                name
                            FROM
                                bi_location
                            WHERE
                                id = c.room
                        ) room,
                        b.customer_name     company,
                        b.country           country,
                        (
                            SELECT
                                d.user_name
                            FROM
                                bi_user d
                            WHERE
                                d.id = b.briefing_manager
                        ) briefngmanager,
                        b.host_email        host,
                        b.host_contact      hostphonenumber,
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
                        c.activity_start_time activity_start_time,
                        c.duration          duration,
                        fn_ts_to_time(c.activity_start_time, l_location_id, c.duration) endtime,
                        c.catering_type     cateringtype,
                        c.no_of_attendees   attendess,
                        c.notes             notes,
                        b.cost_center       costcenter,
                        fn_code_to_lookup(c.diet_information, l_location_id, 'DIET_INFO') dietary,
                        c.id                cateringactivityid
                    FROM
                        bi_request b,
                        bi_request_catering_activity c,
                        bi_request_activity_day d
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
                        AND d.event_date BETWEEN l_start_date AND l_end_date
                        AND b.location_id = (
                            SELECT UNIQUE
                                ( id )
                            FROM
                                bi_location
                            WHERE
                                unique_id = l_location_id
                        )
                        AND d.request_id = b.id
                        AND c.request_activity_day_id = d.id
                    ORDER BY
                        d.event_date,
                        room,
                        company,
                        activity_start_time,
                        duration,
                        CASE l_order_by
                            WHEN 'asc'   THEN CASE l_sort_column
                                WHEN 'companycountry'   THEN country
                                WHEN 'briefngmanager'   THEN briefngmanager
                                WHEN 'host'             THEN host
                            END
                        END,
                        CASE l_order_by
                            WHEN 'desc'   THEN CASE l_sort_column
                                WHEN 'companycountry'   THEN country
                                WHEN 'briefngmanager'   THEN briefngmanager
                                WHEN 'host'             THEN host
                            END
                        END DESC
                ) a
            WHERE
                ROWNUM <= l_end_row
        )
    WHERE
        rn >= l_start_row;
        
    TYPE rec_catering_data IS
        TABLE OF cur_catering_data%rowtype INDEX BY PLS_INTEGER;
    l_cur_catering_data   rec_catering_data;
BEGIN
    out_cate_rep_tab := return_cat_arr_result();
    OPEN cur_catering_data;
    LOOP
        FETCH cur_catering_data BULK COLLECT INTO l_cur_catering_data LIMIT 1000;
        EXIT WHEN l_cur_catering_data.count = 0;
        dbms_output.put_line('here in first insert');
        lrec := return_cat_report();
        out_cate_rep_tab := return_cat_arr_result(return_cat_report());
        out_cate_rep_tab.DELETE;
        FOR i IN 1..l_cur_catering_data.count LOOP

-- dbms_output.put_line('Inside cursor ' );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_cat_report();
                lrec.requestactivitydayid := l_cur_catering_data(i).requestactivitydayid;
                lrec.requestid := l_cur_catering_data(i).requestid;
                lrec.startdate := l_cur_catering_data(i).startdate;
                lrec.room := l_cur_catering_data(i).room;
                lrec.company := l_cur_catering_data(i).company;
                lrec.companycountry := l_cur_catering_data(i).country;
                lrec.briefingmanager := l_cur_catering_data(i).briefngmanager;
                lrec.host := l_cur_catering_data(i).host;
                lrec.hostphonenumber := l_cur_catering_data(i).hostphonenumber;
                lrec.requestername := l_cur_catering_data(i).requestername;
                lrec.requesterphonenumber := l_cur_catering_data(i).requesterphonenumber;
                lrec.starttime := l_cur_catering_data(i).starttime;
                lrec.duration := l_cur_catering_data(i).duration;
                lrec.endtime := l_cur_catering_data(i).endtime;
                lrec.cateringtype := l_cur_catering_data(i).cateringtype;
                lrec.attendess := l_cur_catering_data(i).attendess;
                lrec.notes := l_cur_catering_data(i).notes;
                lrec.costcenter := l_cur_catering_data(i).costcenter;
                lrec.dietary := l_cur_catering_data(i).dietary;
                lrec.cateringactivityid := l_cur_catering_data(i).cateringactivityid;
                IF l_num_counter > 1 THEN
                    out_cate_rep_tab.extend();
                    out_cate_rep_tab(l_num_counter) := return_cat_report();
                ELSE
                    out_cate_rep_tab := return_cat_arr_result(return_cat_report());
                END IF;

                out_cate_rep_tab(l_num_counter) := lrec;
            EXCEPTION
                WHEN OTHERS THEN
                    dbms_output.put_line('Error occurred : ' || sqlerrm);
            END;
        END LOOP;

    END LOOP;

-- END IF;

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('HERE INSIIDE OTHERS' || sqlerrm);
END;
/