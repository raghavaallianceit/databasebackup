CREATE OR REPLACE TYPE cx_cvciq_v3.return_oper_report AS OBJECT (
    requestactivitydayid   NUMBER,
    requestid              NUMBER,
    requesttype            VARCHAR2(256),
    room                   VARCHAR2(500),
    starttime              VARCHAR2(50),
    endtime                VARCHAR2(50),
    company                VARCHAR2(8000),
    briefingmanager        VARCHAR2(8000),
    host                   VARCHAR2(500),
    startdate              VARCHAR2(50),
    oracleattendees        NUMBER,
    extattendees           NUMBER,
    amountofgifts          NUMBER,
    executive              VARCHAR2(500),
    agendastarttime        VARCHAR2(500),
    agendaendtime          VARCHAR2(500),
    gifttype               VARCHAR2(500),
    CONSTRUCTOR FUNCTION return_oper_report RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY cx_cvciq_v3.return_oper_report AS
    CONSTRUCTOR FUNCTION return_oper_report RETURN SELF AS RESULT AS
    BEGIN
        self.requestactivitydayid := NULL;
        self.requestid := NULL;
        self.room := NULL;
        self.requesttype := NULL;
        self.starttime := NULL;
        self.endtime := NULL;
        self.company := NULL;
        self.briefingmanager := NULL;
        self.host := NULL;
        self.startdate := NULL;
        self.oracleattendees := NULL;
        self.extattendees := NULL;
        self.amountofgifts := NULL;
        self.executive := NULL;
        self.agendastarttime := NULL;
        self.agendaendtime := NULL;
        self.gifttype := NULL;
        return;
    END;

END;
/