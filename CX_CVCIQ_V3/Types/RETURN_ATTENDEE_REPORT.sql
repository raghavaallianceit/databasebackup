CREATE OR REPLACE TYPE cx_cvciq_v3.return_attendee_report AS OBJECT (
     requestid         NUMBER,
    visitdate         VARCHAR2(50),
    room              VARCHAR2(500),
    company           VARCHAR2(500),
    companycountry    VARCHAR2(500),
    duration          VARCHAR2(500),
    custcompanyname   VARCHAR2(500),
    firstName      VARCHAR2(256),
    lastName       VARCHAR2(256),
    title          VARCHAR2(256),
    istechnical       VARCHAR2(50),
    isdecision        VARCHAR2(50),
    attendeeType          VARCHAR2(256)  ,
    CONSTRUCTOR FUNCTION return_attendee_report RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY cx_cvciq_v3.return_attendee_report AS
    CONSTRUCTOR FUNCTION return_attendee_report RETURN SELF AS RESULT AS
    BEGIN
        self.requestid := NULL;
        self.visitdate := NULL;
        self.room := NULL;
        self.company := NULL;
        self.companycountry := NULL;
        self.duration := NULL;
        self.custcompanyname := NULL;
        self.firstName := NULL;
        self.lastName := NULL;
        self.title := NULL;
        self.istechnical := NULL;
        self.isdecision := NULL;
        SELF.attendeeType       := NULL;
        return;
    END;

END;
/