CREATE OR REPLACE PROCEDURE cx_cvciq_v3.test_opp_track_report (
    out_chr_err_code        OUT                     VARCHAR2,
    out_chr_err_msg         OUT                     VARCHAR2,
    out_opp_track_rep_tab   OUT                     return_opp_track_arr_result,
    in_from_date            IN                      DATE,
    in_to_date              IN                      DATE,
    in_sort_column          IN                      VARCHAR2,
    in_order_by             IN                      VARCHAR2,
    in_location             IN                      VARCHAR2,
    l_start_row_num         IN                      NUMBER,
    l_end_row_num           IN                      NUMBER
) IS

    l_chr_srcstage         VARCHAR2(200);
    l_chr_biqtab           VARCHAR2(200);
    l_chr_srctab           VARCHAR2(200);
    l_chr_bistagtab        VARCHAR2(200);
    l_chr_err_code         VARCHAR2(255);
    l_chr_err_msg          VARCHAR2(255);
    l_out_chr_errbuf       VARCHAR2(2000);
    lrec                   return_opp_track_report;
    l_num_counter          NUMBER := 0;
    l_start_date           DATE := in_from_date;
    l_end_date             DATE := in_to_date + 1;
    l_sort_column          VARCHAR2(30) := lower(in_sort_column);
    l_order_by             VARCHAR2(10) := lower(in_order_by);
    l_location_id          VARCHAR2(256) := in_location;
    l_start_row            NUMBER := l_start_row_num;
    l_end_row              NUMBER := l_end_row_num;
    CURSOR cur_opp_track_data IS
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
                        r.id                           request_id,
                        TO_CHAR(r.start_date, 'MM-DD-YYYY') startdate,
                        r.customer_name                customer_name,
                        r.country                      country,
--                        r.industry                     industry,
                        fn_code_to_lookup(r.industry, l_location_id, 'CUSTOMER_INDUSTRY') industry,
                        fn_code_to_lookup(r.customer_tier, l_location_id, 'TIER') customer_tier,
--                        r.customer_tier                customer_tier,
                        (
                            SELECT
                                d.user_name
                            FROM
                                bi_user d
                            WHERE
                                d.id = r.briefing_manager
                        ) briefing_manager,
                        r.host_email                   host_email,
                        o.opportunity_id               opportunity_number,
--                        CASE
--                            WHEN TRIM(translate(replace(r.opportunity_revenue, ',', ''), '0123456789-,.', ' ')) IS NULL THEN r.opportunity_revenue
--                            ELSE '0'
--                        END opportunity_revenue,
--                        CASE
--                            WHEN TRIM(translate(replace(r.closed_opportunity_revenue, ',', ''), '0123456789-,.', ' ')) IS NULL THEN r.opportunity_revenue
--                            ELSE '0'
--                        END closed_opportunity_revenue,
                        r.opportunity_revenue          opportunity_revenue,
                        r.closed_opportunity_revenue   closed_opportunity_revenue,
                        TO_CHAR(r.opened_date, 'MM-DD-YYYY') opened_date,
                        TO_CHAR(r.closed_date, 'MM-DD-YYYY') closed_date,
                        NULL state
                    FROM
                        bi_request r,
                        bi_request_opportunity o
                    WHERE
                        r.state = 'CONFIRMED'
                        AND r.start_date BETWEEN l_start_date AND l_end_date
                        AND r.location_id = (
                            SELECT UNIQUE
                                ( id )
                            FROM
                                bi_location
                            WHERE
                                unique_id = in_location
                        )
                        AND o.request_id = r.id
                    ORDER BY
                        r.start_date,
                        customer_name
                ) a
            WHERE
                ROWNUM <= l_end_row
        )
    WHERE
        rn >= l_start_row;

    TYPE rec_opp_track_data IS
        TABLE OF cur_opp_track_data%rowtype INDEX BY PLS_INTEGER;
    l_cur_opp_track_data   rec_opp_track_data;
BEGIN
    out_opp_track_rep_tab := return_opp_track_arr_result();
    OPEN cur_opp_track_data;
    LOOP
        FETCH cur_opp_track_data BULK COLLECT INTO l_cur_opp_track_data LIMIT 1000;
        EXIT WHEN l_cur_opp_track_data.count = 0;
        dbms_output.put_line('here in first insert');
        lrec := return_opp_track_report();
        out_opp_track_rep_tab := return_opp_track_arr_result(return_opp_track_report());
        out_opp_track_rep_tab.DELETE;
        FOR i IN 1..l_cur_opp_track_data.count LOOP

--						 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_opp_track_report();
                lrec.requestid := l_cur_opp_track_data(i).request_id;
                lrec.startdate := l_cur_opp_track_data(i).startdate;
                lrec.company := l_cur_opp_track_data(i).customer_name;
                lrec.companycountry := l_cur_opp_track_data(i).country;
                lrec.industry := l_cur_opp_track_data(i).industry;
                lrec.tier := l_cur_opp_track_data(i).customer_tier;
                lrec.briefingmanager := l_cur_opp_track_data(i).briefing_manager;
                lrec.hostname := l_cur_opp_track_data(i).host_email;
                lrec.oppnumber := l_cur_opp_track_data(i).opportunity_number;
                lrec.openopprevenue := l_cur_opp_track_data(i).opportunity_revenue;
                lrec.curropprevenue := l_cur_opp_track_data(i).closed_opportunity_revenue;
                lrec.opendate := l_cur_opp_track_data(i).opened_date;
                lrec.closedate := l_cur_opp_track_data(i).closed_date;
                lrec.status := l_cur_opp_track_data(i).state;
                IF l_num_counter > 1 THEN
                    out_opp_track_rep_tab.extend();
                    out_opp_track_rep_tab(l_num_counter) := return_opp_track_report();
                ELSE
                    out_opp_track_rep_tab := return_opp_track_arr_result(return_opp_track_report());
                END IF;

                out_opp_track_rep_tab(l_num_counter) := lrec;
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