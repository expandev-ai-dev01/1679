/**
 * @schema functional
 * Functional schema - business logic and entities
 */
CREATE SCHEMA [functional];
GO

/**
 * @table directoryConfiguration Directory configuration for file cleanup
 * @multitenancy true
 * @softDelete true
 * @alias dirCfg
 */
CREATE TABLE [functional].[directoryConfiguration] (
  [idDirectoryConfiguration] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [directoryPath] NVARCHAR(500) NOT NULL,
  [includeSubdirectories] BIT NOT NULL DEFAULT (1),
  [minimumAge] INTEGER NOT NULL DEFAULT (7),
  [minimumSize] BIGINT NOT NULL DEFAULT (0),
  [includeSystemFiles] BIT NOT NULL DEFAULT (0),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);

/**
 * @primaryKey pkDirectoryConfiguration
 * @keyType Object
 */
ALTER TABLE [functional].[directoryConfiguration]
ADD CONSTRAINT [pkDirectoryConfiguration] PRIMARY KEY CLUSTERED ([idDirectoryConfiguration]);

/**
 * @foreignKey fkDirectoryConfiguration_Account
 * @target subscription.account
 */
ALTER TABLE [functional].[directoryConfiguration]
ADD CONSTRAINT [fkDirectoryConfiguration_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);

/**
 * @index ixDirectoryConfiguration_Account
 * @type ForeignKey
 * @filter Active configurations only
 */
CREATE NONCLUSTERED INDEX [ixDirectoryConfiguration_Account]
ON [functional].[directoryConfiguration]([idAccount])
WHERE [deleted] = 0;

/**
 * @index ixDirectoryConfiguration_Account_Path
 * @type Search
 * @unique true
 * @filter Active configurations only
 */
CREATE UNIQUE NONCLUSTERED INDEX [ixDirectoryConfiguration_Account_Path]
ON [functional].[directoryConfiguration]([idAccount], [directoryPath])
WHERE [deleted] = 0;

/**
 * @table directoryConfigurationExtension Extensions configured for directory
 * @multitenancy true
 * @softDelete false
 * @alias dirCfgExt
 */
CREATE TABLE [functional].[directoryConfigurationExtension] (
  [idAccount] INTEGER NOT NULL,
  [idDirectoryConfiguration] INTEGER NOT NULL,
  [idExtension] INTEGER NOT NULL
);

/**
 * @primaryKey pkDirectoryConfigurationExtension
 * @keyType Relationship
 */
ALTER TABLE [functional].[directoryConfigurationExtension]
ADD CONSTRAINT [pkDirectoryConfigurationExtension] PRIMARY KEY CLUSTERED ([idAccount], [idDirectoryConfiguration], [idExtension]);

/**
 * @foreignKey fkDirectoryConfigurationExtension_Account
 * @target subscription.account
 */
ALTER TABLE [functional].[directoryConfigurationExtension]
ADD CONSTRAINT [fkDirectoryConfigurationExtension_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);

/**
 * @foreignKey fkDirectoryConfigurationExtension_DirectoryConfiguration
 * @target functional.directoryConfiguration
 */
ALTER TABLE [functional].[directoryConfigurationExtension]
ADD CONSTRAINT [fkDirectoryConfigurationExtension_DirectoryConfiguration] FOREIGN KEY ([idDirectoryConfiguration])
REFERENCES [functional].[directoryConfiguration]([idDirectoryConfiguration]);

/**
 * @foreignKey fkDirectoryConfigurationExtension_Extension
 * @target config.temporaryFileExtension
 */
ALTER TABLE [functional].[directoryConfigurationExtension]
ADD CONSTRAINT [fkDirectoryConfigurationExtension_Extension] FOREIGN KEY ([idExtension])
REFERENCES [config].[temporaryFileExtension]([idExtension]);

/**
 * @index ixDirectoryConfigurationExtension_Account_Configuration
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixDirectoryConfigurationExtension_Account_Configuration]
ON [functional].[directoryConfigurationExtension]([idAccount], [idDirectoryConfiguration]);

/**
 * @table directoryConfigurationPattern Patterns configured for directory
 * @multitenancy true
 * @softDelete false
 * @alias dirCfgPat
 */
CREATE TABLE [functional].[directoryConfigurationPattern] (
  [idAccount] INTEGER NOT NULL,
  [idDirectoryConfiguration] INTEGER NOT NULL,
  [idPattern] INTEGER NOT NULL
);

/**
 * @primaryKey pkDirectoryConfigurationPattern
 * @keyType Relationship
 */
ALTER TABLE [functional].[directoryConfigurationPattern]
ADD CONSTRAINT [pkDirectoryConfigurationPattern] PRIMARY KEY CLUSTERED ([idAccount], [idDirectoryConfiguration], [idPattern]);

/**
 * @foreignKey fkDirectoryConfigurationPattern_Account
 * @target subscription.account
 */
ALTER TABLE [functional].[directoryConfigurationPattern]
ADD CONSTRAINT [fkDirectoryConfigurationPattern_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);

/**
 * @foreignKey fkDirectoryConfigurationPattern_DirectoryConfiguration
 * @target functional.directoryConfiguration
 */
ALTER TABLE [functional].[directoryConfigurationPattern]
ADD CONSTRAINT [fkDirectoryConfigurationPattern_DirectoryConfiguration] FOREIGN KEY ([idDirectoryConfiguration])
REFERENCES [functional].[directoryConfiguration]([idDirectoryConfiguration]);

/**
 * @foreignKey fkDirectoryConfigurationPattern_Pattern
 * @target config.temporaryFilePattern
 */
ALTER TABLE [functional].[directoryConfigurationPattern]
ADD CONSTRAINT [fkDirectoryConfigurationPattern_Pattern] FOREIGN KEY ([idPattern])
REFERENCES [config].[temporaryFilePattern]([idPattern]);

/**
 * @index ixDirectoryConfigurationPattern_Account_Configuration
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixDirectoryConfigurationPattern_Account_Configuration]
ON [functional].[directoryConfigurationPattern]([idAccount], [idDirectoryConfiguration]);

/**
 * @table cleanupOperation Cleanup operation history
 * @multitenancy true
 * @softDelete false
 * @alias clnOp
 */
CREATE TABLE [functional].[cleanupOperation] (
  [idCleanupOperation] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idDirectoryConfiguration] INTEGER NOT NULL,
  [operationDate] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [totalFilesAnalyzed] INTEGER NOT NULL DEFAULT (0),
  [totalFilesRemoved] INTEGER NOT NULL DEFAULT (0),
  [totalSpaceFreed] BIGINT NOT NULL DEFAULT (0),
  [removalMode] VARCHAR(20) NOT NULL,
  [status] VARCHAR(20) NOT NULL,
  [criteriaJson] NVARCHAR(MAX) NULL
);

/**
 * @primaryKey pkCleanupOperation
 * @keyType Object
 */
ALTER TABLE [functional].[cleanupOperation]
ADD CONSTRAINT [pkCleanupOperation] PRIMARY KEY CLUSTERED ([idCleanupOperation]);

/**
 * @foreignKey fkCleanupOperation_Account
 * @target subscription.account
 */
ALTER TABLE [functional].[cleanupOperation]
ADD CONSTRAINT [fkCleanupOperation_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);

/**
 * @foreignKey fkCleanupOperation_DirectoryConfiguration
 * @target functional.directoryConfiguration
 */
ALTER TABLE [functional].[cleanupOperation]
ADD CONSTRAINT [fkCleanupOperation_DirectoryConfiguration] FOREIGN KEY ([idDirectoryConfiguration])
REFERENCES [functional].[directoryConfiguration]([idDirectoryConfiguration]);

/**
 * @check chkCleanupOperation_RemovalMode
 * @enum {lixeira} Send to recycle bin
 * @enum {permanente} Permanent deletion
 */
ALTER TABLE [functional].[cleanupOperation]
ADD CONSTRAINT [chkCleanupOperation_RemovalMode] CHECK ([removalMode] IN ('lixeira', 'permanente'));

/**
 * @check chkCleanupOperation_Status
 * @enum {não iniciada} Not started
 * @enum {em andamento} In progress
 * @enum {concluída} Completed
 * @enum {erro} Error
 */
ALTER TABLE [functional].[cleanupOperation]
ADD CONSTRAINT [chkCleanupOperation_Status] CHECK ([status] IN ('não iniciada', 'em andamento', 'concluída', 'erro'));

/**
 * @index ixCleanupOperation_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixCleanupOperation_Account]
ON [functional].[cleanupOperation]([idAccount]);

/**
 * @index ixCleanupOperation_Account_Date
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixCleanupOperation_Account_Date]
ON [functional].[cleanupOperation]([idAccount], [operationDate] DESC);

/**
 * @table cleanupOperationFile Files processed in cleanup operation
 * @multitenancy true
 * @softDelete false
 * @alias clnOpFile
 */
CREATE TABLE [functional].[cleanupOperationFile] (
  [idCleanupOperationFile] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idCleanupOperation] INTEGER NOT NULL,
  [filePath] NVARCHAR(500) NOT NULL,
  [fileName] NVARCHAR(255) NOT NULL,
  [fileExtension] VARCHAR(50) NOT NULL,
  [fileSize] BIGINT NOT NULL,
  [fileModifiedDate] DATETIME2 NOT NULL,
  [identificationCriteria] NVARCHAR(200) NOT NULL,
  [removed] BIT NOT NULL DEFAULT (0),
  [errorMessage] NVARCHAR(500) NULL
);

/**
 * @primaryKey pkCleanupOperationFile
 * @keyType Object
 */
ALTER TABLE [functional].[cleanupOperationFile]
ADD CONSTRAINT [pkCleanupOperationFile] PRIMARY KEY CLUSTERED ([idCleanupOperationFile]);

/**
 * @foreignKey fkCleanupOperationFile_Account
 * @target subscription.account
 */
ALTER TABLE [functional].[cleanupOperationFile]
ADD CONSTRAINT [fkCleanupOperationFile_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);

/**
 * @foreignKey fkCleanupOperationFile_CleanupOperation
 * @target functional.cleanupOperation
 */
ALTER TABLE [functional].[cleanupOperationFile]
ADD CONSTRAINT [fkCleanupOperationFile_CleanupOperation] FOREIGN KEY ([idCleanupOperation])
REFERENCES [functional].[cleanupOperation]([idCleanupOperation]);

/**
 * @index ixCleanupOperationFile_Account_Operation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixCleanupOperationFile_Account_Operation]
ON [functional].[cleanupOperationFile]([idAccount], [idCleanupOperation]);

/**
 * @table scheduledCleanup Scheduled cleanup configuration
 * @multitenancy true
 * @softDelete true
 * @alias schCln
 */
CREATE TABLE [functional].[scheduledCleanup] (
  [idScheduledCleanup] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idDirectoryConfiguration] INTEGER NOT NULL,
  [active] BIT NOT NULL DEFAULT (0),
  [frequency] VARCHAR(20) NOT NULL,
  [scheduleTime] TIME NOT NULL DEFAULT ('03:00'),
  [dayOfWeek] INTEGER NULL,
  [dayOfMonth] INTEGER NULL,
  [cronExpression] VARCHAR(100) NULL,
  [nextExecution] DATETIME2 NULL,
  [lastExecution] DATETIME2 NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);

/**
 * @primaryKey pkScheduledCleanup
 * @keyType Object
 */
ALTER TABLE [functional].[scheduledCleanup]
ADD CONSTRAINT [pkScheduledCleanup] PRIMARY KEY CLUSTERED ([idScheduledCleanup]);

/**
 * @foreignKey fkScheduledCleanup_Account
 * @target subscription.account
 */
ALTER TABLE [functional].[scheduledCleanup]
ADD CONSTRAINT [fkScheduledCleanup_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);

/**
 * @foreignKey fkScheduledCleanup_DirectoryConfiguration
 * @target functional.directoryConfiguration
 */
ALTER TABLE [functional].[scheduledCleanup]
ADD CONSTRAINT [fkScheduledCleanup_DirectoryConfiguration] FOREIGN KEY ([idDirectoryConfiguration])
REFERENCES [functional].[directoryConfiguration]([idDirectoryConfiguration]);

/**
 * @check chkScheduledCleanup_Frequency
 * @enum {diária} Daily
 * @enum {semanal} Weekly
 * @enum {mensal} Monthly
 * @enum {personalizada} Custom
 */
ALTER TABLE [functional].[scheduledCleanup]
ADD CONSTRAINT [chkScheduledCleanup_Frequency] CHECK ([frequency] IN ('diária', 'semanal', 'mensal', 'personalizada'));

/**
 * @check chkScheduledCleanup_DayOfWeek
 * @enum {1} Sunday
 * @enum {2} Monday
 * @enum {3} Tuesday
 * @enum {4} Wednesday
 * @enum {5} Thursday
 * @enum {6} Friday
 * @enum {7} Saturday
 */
ALTER TABLE [functional].[scheduledCleanup]
ADD CONSTRAINT [chkScheduledCleanup_DayOfWeek] CHECK ([dayOfWeek] BETWEEN 1 AND 7);

/**
 * @check chkScheduledCleanup_DayOfMonth
 */
ALTER TABLE [functional].[scheduledCleanup]
ADD CONSTRAINT [chkScheduledCleanup_DayOfMonth] CHECK ([dayOfMonth] BETWEEN 1 AND 31);

/**
 * @index ixScheduledCleanup_Account
 * @type ForeignKey
 * @filter Active schedules only
 */
CREATE NONCLUSTERED INDEX [ixScheduledCleanup_Account]
ON [functional].[scheduledCleanup]([idAccount])
WHERE [deleted] = 0;

/**
 * @index ixScheduledCleanup_Account_Active_NextExecution
 * @type Performance
 * @filter Active schedules only
 */
CREATE NONCLUSTERED INDEX [ixScheduledCleanup_Account_Active_NextExecution]
ON [functional].[scheduledCleanup]([idAccount], [active], [nextExecution])
WHERE [deleted] = 0;
GO
