--liquibase formatted sql

--changeset poc:003-seed-test-data context:test
INSERT INTO dbo.Orders (Id, CustomerId, OrderDate, Status)
VALUES
    (1001, 1, '2026-01-15T10:00:00', N'Created'),
    (1002, 2, '2026-01-16T11:30:00', N'Approved');
