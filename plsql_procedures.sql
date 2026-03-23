-- Oracle PL/SQL Procedures
CREATE OR REPLACE PROCEDURE sp_create_order (
    p_id IN NUMBER,
    p_customer IN VARCHAR2,
    p_amount IN NUMBER
) AS
BEGIN
    INSERT INTO orders (id, customer, amount, created_date)
    VALUES (p_id, p_customer, p_amount, SYSDATE);
    COMMIT;
END;
/

CREATE OR REPLACE FUNCTION fn_get_total_orders (
    p_customer IN VARCHAR2
) RETURN NUMBER AS
    v_total NUMBER;
BEGIN
    SELECT SUM(amount) INTO v_total
    FROM orders
    WHERE customer = p_customer;
    RETURN NVL(v_total, 0);
END;
/

CREATE OR REPLACE TRIGGER tr_order_audit
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO order_audit (order_id, action, audit_date)
    VALUES (:NEW.id, 'INSERTED', SYSDATE);
END;
/
