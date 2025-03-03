CREATE TABLE C##cdc_user.table_example (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(50)
);
INSERT INTO C##cdc_user.table_example (id, name) VALUES (1, 'Teste 1');
COMMIT;