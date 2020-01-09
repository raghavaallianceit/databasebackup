CREATE OR REPLACE FUNCTION cx_cvciq_v3.fn_varchar_to_array(p_list IN VARCHAR2)
      RETURN CHAR_ARRAY
    AS
      l_string       VARCHAR2(32767) := p_list || '|';
      l_comma_index  PLS_INTEGER;
      l_index        PLS_INTEGER := 1;
      l_tab          CHAR_ARRAY := CHAR_ARRAY();
    BEGIN
--    IF l_string IS NOT NULL
--    THEN
      LOOP
       l_comma_index := INSTR(l_string, '|', l_index);
       EXIT WHEN l_comma_index = 0;
       l_tab.EXTEND;
       l_tab(l_tab.COUNT) := SUBSTR(l_string, l_index, l_comma_index - l_index);
       l_index := l_comma_index + 1;
     END LOOP;
--     ELSE l_tab := NULL;
--     END if;
     RETURN l_tab;
   END fn_varchar_to_array;
/