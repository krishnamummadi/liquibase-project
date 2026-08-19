--liquibase formatted sql

--changeset poc:001-create-schema
CREATE TABLE dbo.Customers (
    Id INT NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1
);


CREATE TABLE dbo.Orders (
    Id INT NOT NULL PRIMARY KEY,
    CustomerId INT NOT NULL,
    OrderDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Status NVARCHAR(50) NOT NULL DEFAULT N'Pending',
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerId) REFERENCES dbo.Customers(Id)
);

--changeset poc:002-add-email-to-customers
ALTER TABLE dbo.Customers ADD Email NVARCHAR(100);

--changeset poc:003-create-products-table
CREATE TABLE dbo.Products (
    Id INT NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0
);

--changeset poc:004-create-order-items-table
CREATE TABLE dbo.OrderItems (
    Id INT NOT NULL PRIMARY KEY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(Id),
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(Id)
);

--changeset poc:005-add-index-on-order-status
CREATE INDEX IX_Orders_Status ON dbo.Orders(Status);

--changeset poc:006-seed-sample-customers
IF NOT EXISTS (SELECT 1 FROM dbo.Customers WHERE Id = 1)
BEGIN
    INSERT INTO dbo.Customers (Id, Name, IsActive, Email) VALUES
    (1, N'John Smith', 1, N'john@example.com'),
    (2, N'Jane Doe', 1, N'jane@example.com'),
    (3, N'Bob Johnson', 0, N'bob@example.com');
END;
