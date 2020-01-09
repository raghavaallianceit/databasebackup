CREATE OR REPLACE FORCE VIEW cx_cvciq_v3.vw_cvc_request_process (requestid,companyname,eventstartdate,hostname,country,"LOCATION",status,description,ac_id) AS
SELECT
    req.id requestid,
    req.company_name companyname,
    req.start_date eventstartdate,
    req.host_name hostname,
    req.company_country country,
    loc.name as location,
    'INIT' as status,
    sts.description as description,
    req.ac_id as ac_id
FROM
    cx_cvc.cvc_request req,
    cx_cvc.cvc_location loc,
    cx_cvc.cvc_status sts
WHERE
        req.location_id = 80
    AND
        sts.id = req.status_id
    AND
        req.location_id = loc.id
    AND
        req.start_date >= TO_DATE(
            '1.1.' || 2015,
            'DD.MM.YYYY'
        );