-- Active: 1770911084529@@127.0.0.1@3306@support_dw
USE support_dw;

DROP TABLE IF EXISTS calls;
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    team VARCHAR(50) NOT NULL,
    role VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL
);

CREATE TABLE calls (
    call_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    call_time DATETIME NOT NULL,
    phone VARCHAR(30) NOT NULL,
    direction VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);


INSERT INTO employees (full_name, team, role, hire_date) VALUES
('Alice Johnson', 'Support', 'Agent', '2023-01-15'),
('Bob Smith', 'Support', 'Agent', '2023-03-20'),
('Chris Lee', 'Support', 'Senior Agent', '2022-11-01'),
('Daria Ivanova', 'QA', 'QA Specialist', '2023-05-10'),
('Evan Brown', 'Support', 'Agent', '2024-01-05'),
('Fiona White', 'Escalations', 'Specialist', '2022-09-12'),
('George King', 'Support', 'Agent', '2023-07-18'),
('Hanna Green', 'QA', 'Analyst', '2024-02-22'),
('Ivan Petrov', 'Support', 'Agent', '2023-08-14'),
('Julia Black', 'Escalations', 'Lead', '2021-12-01');

INSERT INTO calls (employee_id, call_time, phone, direction, status) VALUES
(1, '2026-03-15 09:05:00', '+380501111111', 'INBOUND', 'ANSWERED'),
(2, '2026-03-15 09:20:00', '+380502222222', 'OUTBOUND', 'MISSED'),
(3, '2026-03-15 09:40:00', '+380503333333', 'INBOUND', 'ANSWERED'),
(4, '2026-03-15 10:00:00', '+380504444444', 'INBOUND', 'ANSWERED'),
(5, '2026-03-15 10:15:00', '+380505555555', 'OUTBOUND', 'ANSWERED'),
(6, '2026-03-15 10:35:00', '+380506666666', 'INBOUND', 'FAILED');

INSERT INTO calls (employee_id, call_time, phone, direction, status) VALUES
(2, '2026-03-15 11:10:00', '+380507777777', 'INBOUND', 'ANSWERED'),
(7, '2026-03-15 11:25:00', '+380508888888', 'OUTBOUND', 'ANSWERED');

INSERT INTO calls (employee_id, call_time, phone, direction, status)
VALUES (3, '2026-03-15 12:00:00', '+380509111111', 'INBOUND', 'ANSWERED');
