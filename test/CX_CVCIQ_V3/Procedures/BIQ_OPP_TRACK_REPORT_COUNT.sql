CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_opp_track_report_count (
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
                        request_id,
                        startdate,
                        customer_name,
                        country,
                        industry,
                        customer_tier,
                        briefing_manager,
                        host_email,
                        opportunity_number,
                        opportunity_revenue,
                        closed_opportunity_revenue,
                        (   closed_opportunity_revenue - opportunity_revenue) changeinrevenuedollar,
                        CASE
                            WHEN to_number(opportunity_revenue) > 0 THEN ( TO_CHAR((nvl(closed_opportunity_revenue, 0) -(CASE
                                WHEN TRIM(translate(replace(opportunity_revenue, ',', ''), '0123456789-,.', ' ')) IS NULL THEN replace
                                (opportunity_revenue, ',', '')
                                ELSE '0'
                            END)) * 100 /(CASE
                                WHEN TRIM(translate(replace(opportunity_revenue, ',', ''), '0123456789-,.', ' ')) IS NULL THEN replace
                                (opportunity_revenue, ',', '')
                                ELSE '0'
                            END)) )
                            ELSE 'N/A'
                        END changeinrevenuepercent,
                        opened_date,
                        closed_date,
                        state
                    FROM
                        (
                            SELECT
                                r.id               request_id,
                                TO_CHAR(r.start_date, 'MM/DD/YYYY') startdate,
                                r.customer_name    customer_name,
                                r.country          country,
                                fn_code_to_lookup(r.industry, l_location_id, 'CUSTOMER_INDUSTRY') industry,
                                fn_code_to_lookup(r.customer_tier, l_location_id, 'TIER') customer_tier,
                                (
                                    SELECT
                                        d.user_name
                                    FROM
                                        bi_user d
                                    WHERE
                                        d.id = r.briefing_manager
                                ) briefing_manager,
                                r.host_email       host_email,
                                o.opportunity_id   opportunity_number,
                                CASE
                                    WHEN TRIM(translate(replace(r.opportunity_revenue, ',', ''), '0123456789-,.', ' ')) IS NULL THEN
                                    replace(r.opportunity_revenue, ',', '')
                                    ELSE '0'
                                END opportunity_revenue,
                                nvl(r.closed_opportunity_revenue, 0) closed_opportunity_revenue,
                                TO_CHAR(r.opened_date, 'MM-DD-YYYY') opened_date,
                                TO_CHAR(r.closed_date, 'MM-DD-YYYY') closed_date,
                                NULL state
                            FROM
                                bi_request r
                                LEFT JOIN bi_request_opportunity o ON o.request_id = r.id
                            WHERE
                                r.state = 'CONFIRMED'
                                AND request_type_id = 1
                                AND r.start_date BETWEEN l_start_date AND l_end_date
                                AND r.location_id = (
                                    SELECT UNIQUE
                                        ( id )
                                    FROM
                                        bi_location
                                    WHERE
                                        unique_id = in_location
                                )
                            ORDER BY
                                r.start_date,
                                customer_name
                        )
        );

    out_no_of_records := l_no_of_records;
--         dbms_output.put_line('l_no_of_records :-'||l_no_of_records);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('HERE INSIIDE OTHERS' || sqlerrm);
END;
/