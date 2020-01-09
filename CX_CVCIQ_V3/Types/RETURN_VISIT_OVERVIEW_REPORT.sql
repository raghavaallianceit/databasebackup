CREATE OR REPLACE TYPE cx_cvciq_v3.return_visit_overview_report AS OBJECT (
    requestid         NUMBER,
    startdate         VARCHAR2(50),
    room              VARCHAR2(500),
    company           VARCHAR2(500),
    visitfocus        VARCHAR2(500),
    industry          VARCHAR2(500),
    tier              VARCHAR2(500),
    host              VARCHAR2(256),
    opprevenue        VARCHAR2(256),
    objectives        VARCHAR2(4000),
    sensitiveissues   VARCHAR2(4000),
    businesscase      VARCHAR2(4000),
    CONSTRUCTOR FUNCTION return_visit_overview_report RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY cx_cvciq_v3.return_visit_overview_report AS
    CONSTRUCTOR FUNCTION return_visit_overview_report RETURN SELF AS RESULT AS
    BEGIN
        self.requestid := NULL;
        self.startdate := NULL;
        self.room := NULL;
        self.company := NULL;
        self.visitfocus := NULL;
        self.industry := NULL;
        self.tier := NULL;
        self.host := NULL;
        self.opprevenue := NULL;
        self.objectives := NULL;
        self.sensitiveissues := NULL;
        self.businesscase := NULL;
        return;
    END;

END;
/