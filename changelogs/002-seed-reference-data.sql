--liquibase formatted sql

--changeset poc:002-seed-reference-data
INSERT INTO dbo.Customers (Id, Name, IsActive)
VALUES
    (1, N'Contoso', 1),
    (2, N'Fabrikam', 1);

