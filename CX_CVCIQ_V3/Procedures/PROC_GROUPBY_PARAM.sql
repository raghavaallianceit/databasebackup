CREATE OR REPLACE PROCEDURE cx_cvciq_v3.proc_groupby_param (
    out_chr_err_code    OUT                 VARCHAR2,
    out_chr_err_msg     OUT                 VARCHAR2,
    out_groupby_tab     OUT                 return_groupby_param_arr,
    in_from_date        IN                  DATE,
    in_to_date          IN                  DATE,
    in_groupby_column   IN                  VARCHAR2,
    in_location         IN                  VARCHAR2
) IS

    l_chr_srcstage       VARCHAR2(200);
    l_chr_biqtab         VARCHAR2(200);
    l_chr_srctab         VARCHAR2(200);
    l_chr_bistagtab      VARCHAR2(200);
    l_chr_err_code       VARCHAR2(255);
    l_chr_err_msg        VARCHAR2(255);
    l_out_chr_errbuf     VARCHAR2(2000);
    lrec                 return_groupby_report;
    l_num_counter        NUMBER := 0;
    l_start_date         DATE := in_from_date;
    l_end_date           DATE := in_to_date + 1;
    l_groupby_column     VARCHAR2(30) := upper(in_groupby_column);
    l_location_id        VARCHAR2(256) := in_location;
    CURSOR cur_groupby_data IS
    SELECT
        noofrecords,
        nvl(fn_code_to_lookup(groupbycolumn, l_location_id, CASE l_groupby_column
            WHEN 'VISIT_FOCUS'     THEN 'VISIT_FOCUS'
            WHEN 'CUSTOMER_TIER'   THEN 'TIER'
            WHEN 'INDUSTRY'        THEN 'CUSTOMER_INDUSTRY'
            WHEN 'VISIT_TYPE'      THEN 'VISIT_TYPE'
        END), 'Others') groupbycolumn,
        opportunityrevenue   opportunityrevenue,
        fn_lookup_sort_order(groupbycolumn, l_location_id, CASE l_groupby_column
            WHEN 'VISIT_FOCUS'     THEN 'VISIT_FOCUS'
            WHEN 'CUSTOMER_TIER'   THEN 'TIER'
            WHEN 'INDUSTRY'        THEN 'CUSTOMER_INDUSTRY'
            WHEN 'VISIT_TYPE'      THEN 'VISIT_TYPE'
        END) sort_order
    FROM
        (
            ( SELECT
                COUNT(*) noofrecords,
                CASE l_groupby_column
                    WHEN 'VISIT_FOCUS'     THEN visit_focus
                    WHEN 'CUSTOMER_TIER'   THEN customer_tier
                    WHEN 'INDUSTRY'        THEN industry
                    WHEN 'VISIT_TYPE'      THEN visit_type
                END groupbycolumn,
                nvl(SUM(CASE
                    WHEN TRIM(translate(replace(opportunity_revenue, ',', ''), '0123456789-,.', ' ')) IS NULL THEN replace(opportunity_revenue
                    , ',', '')
                    ELSE '0'
                END), 0) opportunityrevenue
            FROM
                bi_request
            WHERE
                location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = l_location_id
                )
                AND start_date BETWEEN l_start_date AND l_end_date
                AND state = 'CONFIRMED'
                AND request_type_id = 1
                AND CASE l_groupby_column
                    WHEN 'VISIT_FOCUS'     THEN visit_focus
                    WHEN 'CUSTOMER_TIER'   THEN customer_tier
                    WHEN 'INDUSTRY'        THEN industry
                    WHEN 'VISIT_TYPE'      THEN visit_type
                END IS NOT NULL
            GROUP BY
                CASE l_groupby_column
                    WHEN 'VISIT_FOCUS'     THEN visit_focus
                    WHEN 'CUSTOMER_TIER'   THEN customer_tier
                    WHEN 'INDUSTRY'        THEN industry
                    WHEN 'VISIT_TYPE'      THEN visit_type
                END
            )
            UNION
            SELECT
                COUNT(*),
                'Others' groupbycolumn,
                nvl(SUM(CASE
                    WHEN TRIM(translate(replace(opportunity_revenue, ',', ''), '0123456789-,.', ' ')) IS NULL THEN replace(opportunity_revenue
                    , ',', '')
                    ELSE '0'
                END), 0) opportunityrevenue
--    '7' sort_order
            FROM
                bi_request
            WHERE
                location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = l_location_id
                )
                AND start_date BETWEEN l_start_date AND l_end_date
                AND state = 'CONFIRMED'
                AND request_type_id = 1
                AND customer_tier IS NULL
                AND CASE l_groupby_column
                    WHEN 'CUSTOMER_TIER'   THEN 1
                    ELSE 0
                END = 1
            GROUP BY
                CASE l_groupby_column
                    WHEN 'CUSTOMER_TIER'   THEN customer_tier
                END
            UNION
            SELECT
                0 noofrecords,
                code,
                0 opportunityrevenue
            FROM
                bi_lookup_value
            WHERE
                location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = l_location_id
                )
                AND lookup_type_id = (
                    SELECT
                        id
                    FROM
                        bi_lookup_type
                    WHERE
                        code = CASE l_groupby_column
                            WHEN 'VISIT_FOCUS'     THEN 'VISIT_FOCUS'
                            WHEN 'CUSTOMER_TIER'   THEN 'TIER'
                            WHEN 'INDUSTRY'        THEN 'CUSTOMER_INDUSTRY'
                            WHEN 'VISIT_TYPE'      THEN 'VISIT_TYPE'
                        END
                )
                AND code NOT IN (
                    SELECT
                        CASE l_groupby_column
                            WHEN 'VISIT_FOCUS'     THEN visit_focus
                            WHEN 'CUSTOMER_TIER'   THEN customer_tier
                            WHEN 'INDUSTRY'        THEN industry
                            WHEN 'VISIT_TYPE'      THEN visit_type
                        END groupbycolumn
                    FROM
                        bi_request
                    WHERE
                        location_id = (
                            SELECT UNIQUE
                                ( id )
                            FROM
                                bi_location
                            WHERE
                                unique_id = l_location_id
                        )
                        AND start_date BETWEEN l_start_date AND l_end_date
                        AND state = 'CONFIRMED'
                        AND request_type_id = 1
                        AND CASE l_groupby_column
                            WHEN 'VISIT_FOCUS'     THEN visit_focus
                            WHEN 'CUSTOMER_TIER'   THEN customer_tier
                            WHEN 'INDUSTRY'        THEN industry
                            WHEN 'VISIT_TYPE'      THEN visit_type
                        END IS NOT NULL
                    GROUP BY
                        CASE l_groupby_column
                            WHEN 'VISIT_FOCUS'     THEN visit_focus
                            WHEN 'CUSTOMER_TIER'   THEN customer_tier
                            WHEN 'INDUSTRY'        THEN industry
                            WHEN 'VISIT_TYPE'      THEN visit_type
                        END
                )
        )
    ORDER BY
        sort_order,
        groupbycolumn;

    TYPE rec_groupby_data IS
        TABLE OF cur_groupby_data%rowtype INDEX BY PLS_INTEGER;
    l_cur_groupby_data   rec_groupby_data;
BEGIN
    out_groupby_tab := return_groupby_param_arr();
    OPEN cur_groupby_data;
--    dbms_output.put_line('l_groupby_column :-' || l_groupby_column);
    LOOP
        FETCH cur_groupby_data BULK COLLECT INTO l_cur_groupby_data;
        EXIT WHEN l_cur_groupby_data.count = 0;
        dbms_output.put_line('here in first insert');
        lrec := return_groupby_report();
        out_groupby_tab := return_groupby_param_arr(return_groupby_report());
        out_groupby_tab.DELETE;
        FOR i IN 1..l_cur_groupby_data.count LOOP

--						 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_groupby_report();
                lrec.noofrecords := l_cur_groupby_data(i).noofrecords;
                lrec.param := l_cur_groupby_data(i).groupbycolumn;
                lrec.opportunityrevenue := l_cur_groupby_data(i).opportunityrevenue;
--                dbms_output.put_line('sort_order :-' || l_cur_groupby_data(i).sort_order);
                IF l_num_counter > 1 THEN
                    out_groupby_tab.extend();
                    out_groupby_tab(l_num_counter) := return_groupby_report();
                ELSE
                    out_groupby_tab := return_groupby_param_arr(return_groupby_report());
                END IF;

                out_groupby_tab(l_num_counter) := lrec;
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