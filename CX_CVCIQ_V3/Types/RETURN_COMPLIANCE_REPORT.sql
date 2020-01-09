CREATE OR REPLACE TYPE cx_cvciq_v3.return_compliance_report AS OBJECT (                  
	requestid         NUMBER,
    startdate         VARCHAR2(50),
    room              VARCHAR2(500),
    company           VARCHAR2(500),
    companycountry    VARCHAR2(500),
    duration          VARCHAR2(500),
    briefingmanager   VARCHAR2(500),
    host              VARCHAR2(500),
    compliance        VARCHAR2(50),
    giftcount         VARCHAR2(500),
    gifttype          VARCHAR2(500),
    cateringtype      VARCHAR2(500),
    notes             VARCHAR2(500),
    custcompanyname   VARCHAR2(500),
    extfirstname      VARCHAR2(200),
    extlastname       VARCHAR2(200),
    exttitle          VARCHAR2(200),
       CONSTRUCTOR FUNCTION return_compliance_report RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY cx_cvciq_v3.return_compliance_report AS
      CONSTRUCTOR FUNCTION return_compliance_report RETURN SELF AS RESULT AS
      BEGIN

        self.requestid := NULL;
        self.startdate := NULL;
        self.room := NULL;
        self.company := NULL;
        self.companycountry := NULL;
        self.duration := NULL;
        self.briefingmanager := NULL;
        self.host := NULL;
        self.compliance := NULL;
        self.giftcount := NULL;
        self.gifttype := NULL;
        self.cateringtype := NULL;
        self.notes := NULL;
        self.custcompanyname := NULL;
        self.extfirstname := NULL;
        self.extlastname := NULL;
        self.exttitle := NULL;
         RETURN;
      END;
END;
/