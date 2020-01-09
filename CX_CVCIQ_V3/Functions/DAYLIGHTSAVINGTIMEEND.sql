CREATE OR REPLACE FUNCTION cx_cvciq_v3."DAYLIGHTSAVINGTIMEEND" (p_Date IN Date)
Return Date Is
Begin
   Return NEXT_DAY(TO_DATE(to_char(p_Date,'YYYY') || '/11/01 02:00 AM', 'YYYY/MM/DD HH:MI AM') - 1, 'SUN');
End;
/