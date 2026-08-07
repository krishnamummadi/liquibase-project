USE liquibase_test;
GO

MERGE INTO dbo.Customers AS tgt
USING (
    SELECT Id, Name, IsActive
    FROM liquibase_stage.dbo.Customers
) AS src
ON tgt.Id = src.Id
WHEN MATCHED THEN
    UPDATE SET Name = src.Name, IsActive = src.IsActive
WHEN NOT MATCHED THEN
    INSERT (Id, Name, IsActive)
    VALUES (src.Id, src.Name, src.IsActive);
GO

MERGE INTO dbo.Orders AS tgt
USING (
    SELECT Id, CustomerId, OrderDate, Status
    FROM liquibase_stage.dbo.Orders
) AS src
ON tgt.Id = src.Id
WHEN MATCHED THEN
    UPDATE SET CustomerId = src.CustomerId, OrderDate = src.OrderDate, Status = src.Status
WHEN NOT MATCHED THEN
    INSERT (Id, CustomerId, OrderDate, Status)
    VALUES (src.Id, src.CustomerId, src.OrderDate, src.Status);
GO
