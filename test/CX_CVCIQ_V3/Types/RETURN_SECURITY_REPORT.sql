CREATE OR REPLACE TYPE cx_cvciq_v3.return_security_report AS OBJECT (                  
				requestid         NUMBER,
    startDate         VARCHAR2(50),
    starttime         VARCHAR2(50),
    endtime           VARCHAR2(50),
    room              VARCHAR2(256),
    building          VARCHAR2(500),
    host              VARCHAR2(256),
    briefingManager			VARCHAR2(500),
    company             VARCHAR2(500),
    country           VARCHAR2(500),
    custcompanyname   VARCHAR2(500),
    firstname         VARCHAR2(256),
    lastname          VARCHAR2(256),
    title             VARCHAR2(256),
    attendeetype      VARCHAR2(256),
       CONSTRUCTOR FUNCTION return_security_report RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY cx_cvciq_v3.return_security_report AS
    CONSTRUCTOR FUNCTION return_security_report RETURN SELF AS RESULT AS
    BEGIN
        self.requestid := NULL;
        self.startdate := NULL;
        self.starttime := NULL;
        self.endtime := NULL;
        self.room := NULL;
        self.building := NULL;
        self.host := NULL;
        self.briefingmanager := NULL;
        self.company := NULL;
        self.country := NULL;
        self.custcompanyname := NULL;
        self.title := NULL;
        self.firstname := NULL;
        self.lastname := NULL;
        self.attendeetype := NULL;
        return;
    END;

END;
/