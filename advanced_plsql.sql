-- Oracle APEX Advanced PL/SQL Utilities
-- Extended procedures and functions for enterprise applications

-- ============================================
-- JSON Response Builder
-- ============================================
CREATE OR REPLACE PACKAGE body json_response AS
    
    PROCEDURE success(
        p_data IN OUT NOCOPY CLOB,
        p_message IN VARCHAR2 DEFAULT 'Success'
    ) IS
    BEGIN
        apex_json.open_object;
        apex_json.write('status', 'success');
        apex_json.write('message', p_message);
        apex_json.write('data', p_data);
        apex_json.write('timestamp', SYSTIMESTAMP);
        apex_json.close_object;
    END;
    
    PROCEDURE error(
        p_code IN VARCHAR2,
        p_message IN VARCHAR2
    ) IS
    BEGIN
        apex_json.open_object;
        apex_json.write('status', 'error');
        apex_json.write('code', p_code);
        apex_json.write('message', p_message);
        apex_json.write('timestamp', SYSTIMESTAMP);
        apex_json.close_object;
    END;
    
    PROCEDURE paginate(
        p_data IN OUT NOCOPY CLOB,
        p_page IN NUMBER,
        p_page_size IN NUMBER,
        p_total IN NUMBER
    ) IS
    BEGIN
        apex_json.open_object;
        apex_json.write('items', p_data);
        apex_json.open_object('pagination');
        apex_json.write('page', p_page);
        apex_json.write('page_size', p_page_size);
        apex_json.write('total', p_total);
        apex_json.write('total_pages', CEIL(p_total / p_page_size));
        apex_json.close_object;
        apex_json.close_object;
    END;

END json_response;
/

-- ============================================
-- Audit Trail Package
-- ============================================
CREATE OR REPLACE PACKAGE audit_trail AS
    
    PROCEDURE log_action(
        p_table_name IN VARCHAR2,
        p_record_id IN NUMBER,
        p_action IN VARCHAR2,
        p_old_values IN CLOB DEFAULT NULL,
        p_new_values IN CLOB DEFAULT NULL,
        p_user_id IN NUMBER DEFAULT NULL
    );
    
    PROCEDURE log_login(
        p_user_id IN NUMBER,
        p_session_id IN VARCHAR2,
        p_ip_address IN VARCHAR2,
        p_success IN BOOLEAN DEFAULT TRUE
    );
    
    FUNCTION get_history(
        p_table_name IN VARCHAR2,
        p_record_id IN NUMBER,
        p_limit IN NUMBER DEFAULT 50
    ) RETURN CLOB;

END audit_trail;
/

CREATE OR REPLACE PACKAGE body audit_trail AS
    
    PROCEDURE log_action(
        p_table_name IN VARCHAR2,
        p_record_id IN NUMBER,
        p_action IN VARCHAR2,
        p_old_values IN CLOB DEFAULT NULL,
        p_new_values IN CLOB DEFAULT NULL,
        p_user_id IN NUMBER DEFAULT NULL
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO audit_log (
            id,
            table_name,
            record_id,
            action,
            old_values,
            new_values,
            user_id,
            created_at
        ) VALUES (
            audit_log_seq.NEXTVAL,
            p_table_name,
            p_record_id,
            p_action,
            p_old_values,
            p_new_values,
            NVL(p_user_id, apex_session.get_user_id),
            SYSTIMESTAMP
        );
        
        COMMIT;
    END;
    
    PROCEDURE log_login(
        p_user_id IN NUMBER,
        p_session_id IN VARCHAR2,
        p_ip_address IN VARCHAR2,
        p_success IN BOOLEAN DEFAULT TRUE
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO login_audit (
            id,
            user_id,
            session_id,
            ip_address,
            success,
            created_at
        ) VALUES (
            login_audit_seq.NEXTVAL,
            p_user_id,
            p_session_id,
            p_ip_address,
            CASE WHEN p_success THEN 'Y' ELSE 'N' END,
            SYSTIMESTAMP
        );
        
        COMMIT;
    END;
    
    FUNCTION get_history(
        p_table_name IN VARCHAR2,
        p_record_id IN NUMBER,
        p_limit IN NUMBER DEFAULT 50
    ) RETURN CLOB IS
        v_result CLOB;
    BEGIN
        apex_json.initialize_clob_output;
        
        apex_json.open_array;
        
        FOR rec IN (
            SELECT created_at, action, old_values, new_values, user_id
            FROM audit_log
            WHERE table_name = p_table_name
              AND record_id = p_record_id
            ORDER BY created_at DESC
            FETCH FIRST p_limit ROWS ONLY
        ) LOOP
            apex_json.open_object;
            apex_json.write('timestamp', rec.created_at);
            apex_json.write('action', rec.action);
            apex_json.write('old_values', rec.old_values);
            apex_json.write('new_values', rec.new_values);
            apex_json.write('user_id', rec.user_id);
            apex_json.close_object;
        END LOOP;
        
        apex_json.close_array;
        
        v_result := apex_json.get_clob_output;
        apex_json.free_output;
        
        RETURN v_result;
    END;

END audit_trail;
/

-- ============================================
-- Data Validation Utilities
-- ============================================
CREATE OR REPLACE PACKAGE validation AS
    
    FUNCTION is_valid_email(p_email IN VARCHAR2) RETURN BOOLEAN;
    FUNCTION is_valid_phone(p_phone IN VARCHAR2) RETURN BOOLEAN;
    FUNCTION is_valid_rfc(p_rfc IN VARCHAR2) RETURN BOOLEAN;
    FUNCTION is_valid_curp(p_curp IN VARCHAR2) RETURN BOOLEAN;
    
    PROCEDURE validate_required_fields(
        p_data IN JSON,
        p_required_fields IN VARCHAR2,
        p_raise_on_error IN BOOLEAN DEFAULT TRUE
    );

END validation;
/

CREATE OR REPLACE PACKAGE body validation AS
    
    FUNCTION is_valid_email(p_email IN VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        RETURN REGEXP_LIKE(
            p_email,
            '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
        );
    END;
    
    FUNCTION is_valid_phone(p_phone IN VARCHAR2) RETURN BOOLEAN IS
        v_phone VARCHAR2(20);
    BEGIN
        -- Remove common formatting characters
        v_phone := REPLACE(REPLACE(REPLACE(p_phone, '-', ''), ' ', ''), '(', '');
        v_phone := REPLACE(v_phone, ')', '');
        
        RETURN REGEXP_LIKE(v_phone, '^\d{10,15}$');
    END;
    
    FUNCTION is_valid_rfc(p_rfc IN VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        -- Basic RFC format validation (Mexican RFC)
        RETURN LENGTH(p_rfc) IN (10, 13)
            AND REGEXP_LIKE(p_rfc, '^[A-Z]{4}\d{6}[A-Z0-9]{3}$');
    END;
    
    FUNCTION is_valid_curp(p_curp IN VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        -- CURP format validation
        RETURN LENGTH(p_curp) = 18
            AND REGEXP_LIKE(p_curp, '^[A-Z]{4}\d{6}[HM][A-Z]{2}[B-DF-HJ-NP-TV-Z]{3}[A-Z0-9]{2}$');
    END;
    
    PROCEDURE validate_required_fields(
        p_data IN JSON,
        p_required_fields IN VARCHAR2,
        p_raise_on_error IN BOOLEAN DEFAULT TRUE
    ) IS
        v_missing_fields VARCHAR2(4000);
    BEGIN
        FOR field IN (
            SELECT TRIM(COLUMN_VALUE) AS field_name
            FROM JSON_TABLE(
                p_required_fields,
                '$[*]'
                COLUMNS (field_name VARCHAR2(100) PATH '$')
            )
        ) LOOP
            IF NOT JSON_EXISTS(p_data, '$."' || field.field_name || '"') THEN
                v_missing_fields := v_missing_fields || field.field_name || ', ';
            END IF;
        END LOOP;
        
        IF v_missing_fields IS NOT NULL THEN
            v_missing_fields := RTRIM(v_missing_fields, ', ');
            
            IF p_raise_on_error THEN
                APEX_ERROR.raise_error(
                    p_message => 'Required fields missing: ' || v_missing_fields,
                    p_display_location => APEX_ERROR.c_inline_in_notification
                );
            END IF;
        END IF;
    END;

END validation;
/

-- ============================================
-- Dynamic Report Generator
-- ============================================
CREATE OR REPLACE PACKAGE report_generator AS
    
    FUNCTION generate_csv(
        p_query IN VARCHAR2,
        p_delimiter IN VARCHAR2 DEFAULT ','
    ) RETURN CLOB;
    
    FUNCTION generate_excel(
        p_query IN VARCHAR2,
        p_sheet_name IN VARCHAR2 DEFAULT 'Sheet1'
    ) RETURN BLOB;
    
    PROCEDURE export_to_file(
        p_query IN VARCHAR2,
        p_filename IN VARCHAR2,
        p_format IN VARCHAR2
    );

END report_generator;
/

-- Grant execute permissions
GRANT EXECUTE ON json_response TO apex_admin;
GRANT EXECUTE ON audit_trail TO apex_admin;
GRANT EXECUTE ON validation TO apex_admin;
GRANT EXECUTE ON report_generator TO apex_admin;
