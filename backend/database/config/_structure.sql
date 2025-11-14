/**
 * @schema config
 * Configuration schema - system-wide settings and utilities
 */
CREATE SCHEMA [config];
GO

/**
 * @table temporaryFileExtension Configuration for temporary file extensions
 * @multitenancy false
 * @softDelete false
 * @alias tmpExt
 */
CREATE TABLE [config].[temporaryFileExtension] (
  [idExtension] INTEGER IDENTITY(1, 1) NOT NULL,
  [extension] VARCHAR(50) NOT NULL,
  [description] NVARCHAR(200) NOT NULL,
  [active] BIT NOT NULL DEFAULT (1)
);

/**
 * @primaryKey pkTemporaryFileExtension
 * @keyType Object
 */
ALTER TABLE [config].[temporaryFileExtension]
ADD CONSTRAINT [pkTemporaryFileExtension] PRIMARY KEY CLUSTERED ([idExtension]);

/**
 * @index ixTemporaryFileExtension_Extension
 * @type Search
 * @unique true
 */
CREATE UNIQUE NONCLUSTERED INDEX [ixTemporaryFileExtension_Extension]
ON [config].[temporaryFileExtension]([extension])
WHERE [active] = 1;

/**
 * @table temporaryFilePattern Configuration for temporary file naming patterns
 * @multitenancy false
 * @softDelete false
 * @alias tmpPat
 */
CREATE TABLE [config].[temporaryFilePattern] (
  [idPattern] INTEGER IDENTITY(1, 1) NOT NULL,
  [pattern] NVARCHAR(200) NOT NULL,
  [description] NVARCHAR(200) NOT NULL,
  [active] BIT NOT NULL DEFAULT (1)
);

/**
 * @primaryKey pkTemporaryFilePattern
 * @keyType Object
 */
ALTER TABLE [config].[temporaryFilePattern]
ADD CONSTRAINT [pkTemporaryFilePattern] PRIMARY KEY CLUSTERED ([idPattern]);

/**
 * @index ixTemporaryFilePattern_Pattern
 * @type Search
 * @unique true
 */
CREATE UNIQUE NONCLUSTERED INDEX [ixTemporaryFilePattern_Pattern]
ON [config].[temporaryFilePattern]([pattern])
WHERE [active] = 1;
GO
