IF DB_ID(N'liquibase_dev') IS NULL
BEGIN
    CREATE DATABASE liquibase_dev;
END
GO
IF DB_ID(N'liquibase_test') IS NULL
BEGIN
    CREATE DATABASE liquibase_test;
END
GO
IF DB_ID(N'liquibase_stage') IS NULL
BEGIN
    CREATE DATABASE liquibase_stage;
END
GO
