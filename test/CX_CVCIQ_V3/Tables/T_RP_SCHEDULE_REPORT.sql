CREATE TABLE cx_cvciq_v3.t_rp_schedule_report (
  "ID" NUMBER,
  unique_id VARCHAR2(64 BYTE) NOT NULL,
  execution_type VARCHAR2(20 BYTE) NOT NULL,
  execution_frequency NUMBER NOT NULL,
  report_params VARCHAR2(4000 BYTE),
  execution_pattern VARCHAR2(4000 BYTE),
  execution_begin_date TIMESTAMP NOT NULL,
  exeuction_final_end_date TIMESTAMP,
  total_executions_required NUMBER,
  executions_as_of_date NUMBER,
  last_execution_start_time TIMESTAMP,
  last_execution_end_time TIMESTAMP,
  next_execution_time TIMESTAMP,
  created_by VARCHAR2(64 BYTE) NOT NULL,
  requested_by VARCHAR2(64 BYTE),
  report_recipients VARCHAR2(4000 BYTE),
  is_active NUMBER,
  deleted NUMBER,
  "VERSION" NUMBER(20) DEFAULT 0,
  updated_by VARCHAR2(64 BYTE),
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  is_completed NUMBER DEFAULT 0,
  send_before NUMBER
);