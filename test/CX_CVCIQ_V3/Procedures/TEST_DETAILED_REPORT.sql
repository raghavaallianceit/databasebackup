CREATE OR REPLACE PROCEDURE cx_cvciq_v3.TEST_DETAILED_REPORT (
    out_chr_err_code       OUT                    VARCHAR2,
    out_chr_err_msg        OUT                    VARCHAR2,
    out_detailed_rep_tab   OUT                    return_detailed_arr_result,
    in_from_date           IN                     DATE,
    in_to_date             IN                     DATE,
    in_sort_column         IN                     VARCHAR2,
    in_order_by            IN                     VARCHAR2,
    in_location            IN                     VARCHAR2,
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
    lrec                  return_detailed_report;
    l_num_counter         NUMBER := 0;
    l_start_date          DATE := in_from_date;
    l_end_date            DATE := in_to_date + 1;
    l_sort_column         VARCHAR2(30) := LOWER(in_sort_column);
    l_order_by            VARCHAR2(10) := LOWER(in_order_by);
    l_location_id         VARCHAR2(256) := in_location;
    l_start_row           NUMBER := l_start_row_num;
    l_end_row             NUMBER := l_end_row_num;
    CURSOR cur_detailed_data IS
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
        r.id                    requestId,
        TO_CHAR(r.start_date,'MM-DD-YYYY') startDate,
        (
            SELECT
                name
            FROM
                bi_location
            WHERE
                id = c.room
        ) room,
        r.customer_name         company,
        r.country               companyCountry,
        fn_code_to_lookup(r.industry, l_location_id,'CUSTOMER_INDUSTRY') industry,
        r.customer_tier         tier,
        fn_code_to_lookup(r.visit_type, l_location_id,
        CASE r.REQUEST_TYPE_ID
            WHEN 1     THEN 'VISIT_TYPE'
            WHEN 3   THEN 'NCV_VISIT_TYPE'
        END
        ) visitType,
        fn_code_to_lookup(r.visit_focus, l_location_id,'VISIT_FOCUS') visitFocus,

        (
            SELECT
                u.user_name
            FROM
                bi_user u
            WHERE
                u.id = r.briefing_manager
        ) briefingManager,
        r.host_email            host,
        (
            SELECT
                u.user_name
            FROM
                bi_user u
            WHERE
                u.id = r.REQUESTOR
        ) requestor,
        p.opportunity_id oppNumber,
        r.opportunity_revenue   oppRevenue,
        a.first_name            first_name,
        upper(a.first_name)            upper_first_name,
        a.last_name             last_name,
        upper(a.last_name)             upper_last_name,
        a.designation                 title,
       decode(a.attendee_type, 'externalattendees', 'External', 'Internal') attendee_type,
        r.cost_center           costCenter,
        r.duration              duration
    FROM
        bi_request r
        LEFT JOIN bi_request_attendees a on a.request_id = r.id
        LEFT JOIN bi_request_activity_day d on d.request_id = r.id
        LEFT JOIN bi_request_catering_activity c on c.REQUEST_ACTIVITY_DAY_ID = d.id
        LEFT JOIN bi_request_opportunity p on p.request_id = r.id 
    WHERE
        r.state='CONFIRMED' and 
        r.id IN (
            SELECT
                request_id
            FROM
                bi_request_activity_day
            WHERE
                event_date BETWEEN l_start_date  and  l_end_date
        )
        AND d.event_date BETWEEN l_start_date  and  l_end_date
        AND r.location_id = (
            SELECT UNIQUE
                ( id )
            FROM
                bi_location
            WHERE
                unique_id = l_location_id
        )
        order by r.start_date,room,customer_name,attendee_type,oppNumber,upper_first_name,upper_last_name,
        CASE l_order_by WHEN 'asc' THEN
            CASE l_sort_column 
              WHEN 'companycountry' THEN country 
            END
        END ,        
        CASE l_order_by WHEN 'desc' THEN
            CASE l_sort_column 
              WHEN 'companycountry' THEN country 
            END
        END DESC
        
        ) a
            WHERE
                ROWNUM <= l_end_row
        )
    WHERE
        rn >= l_start_row;


    TYPE rec_detailed_data IS
        TABLE OF cur_detailed_data%rowtype INDEX BY PLS_INTEGER;
    l_cur_detailed_data   rec_detailed_data;
BEGIN
    out_detailed_rep_tab := return_detailed_arr_result();
    OPEN cur_detailed_data;
    LOOP
        FETCH cur_detailed_data BULK COLLECT INTO l_cur_detailed_data LIMIT 1000;
        EXIT WHEN l_cur_detailed_data.count = 0;
        dbms_output.put_line('here in first insert');
        lrec := return_detailed_report();
        out_detailed_rep_tab := return_detailed_arr_result(return_detailed_report());
        out_detailed_rep_tab.DELETE;
        FOR i IN 1..l_cur_detailed_data.count LOOP


--						 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_detailed_report();
                lrec.requestId := l_cur_detailed_data(i).requestId;
                lrec.startDate := l_cur_detailed_data(i).startDate;
                lrec.room := l_cur_detailed_data(i).room;
                lrec.company := l_cur_detailed_data(i).company;
                lrec.companyCountry := l_cur_detailed_data(i).companyCountry;
                lrec.industry := l_cur_detailed_data(i).industry;
                lrec.tier := l_cur_detailed_data(i).tier;
                lrec.visitType := l_cur_detailed_data(i).visitType;
                lrec.visitFocus := l_cur_detailed_data(i).visitFocus;
                lrec.briefingManager := l_cur_detailed_data(i).briefingManager;
                lrec.host := l_cur_detailed_data(i).host;    
                lrec.requestor := l_cur_detailed_data(i).requestor;
                lrec.oppNumber := l_cur_detailed_data(i).oppNumber;
                lrec.oppRevenue := l_cur_detailed_data(i).oppRevenue;
                lrec.firstName := l_cur_detailed_data(i).first_name;
                lrec.lastName := l_cur_detailed_data(i).last_name;
                lrec.title := l_cur_detailed_data(i).title;
                lrec.attendeeType := l_cur_detailed_data(i).attendee_type;
                lrec.costCenter := l_cur_detailed_data(i).costCenter;
                lrec.duration := l_cur_detailed_data(i).duration;
                IF l_num_counter > 1 THEN
                    out_detailed_rep_tab.extend();
                    out_detailed_rep_tab(l_num_counter) := return_detailed_report();
                ELSE
                    out_detailed_rep_tab := return_detailed_arr_result(return_detailed_report());
                END IF;

                out_detailed_rep_tab(l_num_counter) := lrec;
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