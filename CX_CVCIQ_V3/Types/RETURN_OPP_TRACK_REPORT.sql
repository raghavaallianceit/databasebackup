CREATE OR REPLACE TYPE cx_cvciq_v3.return_opp_track_report AS OBJECT (
    requestid         NUMBER,
    startdate         VARCHAR2(50),
    company           VARCHAR2(500),
    companycountry    VARCHAR2(500),
    industry          VARCHAR2(500),
    tier              VARCHAR2(250),
    briefingmanager   VARCHAR2(500),
    hostname          VARCHAR2(500),
    oppnumber         VARCHAR2(500),
    openopprevenue    NUMBER,
    curropprevenue    NUMBER,
    changeinrevenuedollar    VARCHAR2(100),
    changeinrevenuepercent    VARCHAR2(100),
    opendate          VARCHAR2(50),
    closedate         VARCHAR2(50),
    status            VARCHAR2(500),
    CONSTRUCTOR FUNCTION return_opp_track_report RETURN SELF AS RESULT
);

/
CREATE OR REPLACE TYPE BODY cx_cvciq_v3.return_opp_track_report AS
    CONSTRUCTOR FUNCTION return_opp_track_report RETURN SELF AS RESULT AS
    BEGIN
        self.requestid := NULL;
        self.startdate := NULL;
        self.company := NULL;
        self.companycountry := NULL;
        self.industry := NULL;
        self.tier := NULL;
        self.briefingmanager := NULL;
        self.hostname := NULL;
        self.oppnumber := NULL;
        self.openopprevenue := NULL;
        self.curropprevenue := NULL;
        self.changeinrevenuedollar := NULL;
        self.changeinrevenuepercent := NULL;
        self.opendate := NULL;
        self.closedate := NULL;
        self.status := NULL;
        return;
    END;

END;

/