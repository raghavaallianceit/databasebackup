CREATE OR REPLACE TYPE cx_cvciq_v3.return_safe_report AS OBJECT (
    requestId                 NUMBER,
    startDate       VARCHAR2(50),
    building                   VARCHAR2(500),
    startTime                 VARCHAR2(20),
    endTime                   VARCHAR2(20),
    room                       VARCHAR2(500),
    companyName              VARCHAR2(500),
    host                  VARCHAR2(500),
    company   VARCHAR2(500),
    firstName         VARCHAR2(500),
    lastName          VARCHAR2(500),
    email              VARCHAR2(4000),
    phone          VARCHAR2(256)  ,
    visitortype          VARCHAR2(256)  ,
    dob          VARCHAR2(256)  ,
  CONSTRUCTOR FUNCTION return_safe_report RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY cx_cvciq_v3.return_safe_report AS
    CONSTRUCTOR FUNCTION return_safe_report RETURN SELF AS RESULT AS
    BEGIN
         self.requestId := NULL;
         self.startDate := NULL;
        self.building := NULL;
        self.startTime := NULL;
        self.endTime := NULL;
        self.room := NULL;
        self.companyName := NULL;
        self.host := NULL;
        self.company := NULL;
        self.firstName := NULL;
        self.lastName := NULL;
        self.email := NULL;
        SELF.phone       := NULL;
        SELF.visitortype       := NULL;
        SELF.dob       := NULL;
        return;
    END;

END;
/