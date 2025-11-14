/**
 * @schema subscription
 * Subscription schema - account management and multi-tenancy
 */
CREATE SCHEMA [subscription];
GO

/**
 * @table account Account management for multi-tenancy
 * @multitenancy false
 * @softDelete true
 * @alias acc
 */
CREATE TABLE [subscription].[account] (
  [idAccount] INTEGER IDENTITY(1, 1) NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);

/**
 * @primaryKey pkAccount
 * @keyType Object
 */
ALTER TABLE [subscription].[account]
ADD CONSTRAINT [pkAccount] PRIMARY KEY CLUSTERED ([idAccount]);

/**
 * @index ixAccount_Name
 * @type Search
 * @filter Active accounts only
 */
CREATE NONCLUSTERED INDEX [ixAccount_Name]
ON [subscription].[account]([name])
WHERE [deleted] = 0;
GO
