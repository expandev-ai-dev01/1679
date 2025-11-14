/**
 * @summary
 * Updates an existing scan configuration.
 * 
 * @procedure spScanConfigurationUpdate
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - PUT /api/v1/internal/scan-configuration/:id
 * 
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier for audit
 * @param {INT} idScanConfiguration - Configuration identifier
 * @param {NVARCHAR(100)} name - Configuration name
 * @param {NVARCHAR(500)} directoryPath - Directory path
 * @param {BIT} includeSubdirectories - Include subdirectories flag
 * @param {NVARCHAR(MAX)} fileExtensions - JSON array of file extensions
 * @param {NVARCHAR(MAX)} namingPatterns - JSON array of naming patterns
 * @param {INT} minimumAgeDays - Minimum age in days
 * @param {INT} minimumSizeBytes - Minimum size in bytes
 * @param {BIT} includeSystemFiles - Include system files flag
 * 
 * @testScenarios
 * - Valid update with all parameters
 * - Configuration not found error
 * - Duplicate name validation
 */
CREATE OR ALTER PROCEDURE [functional].[spScanConfigurationUpdate]
  @idAccount INT,
  @idUser INT,
  @idScanConfiguration INT,
  @name NVARCHAR(100),
  @directoryPath NVARCHAR(500),
  @includeSubdirectories BIT,
  @fileExtensions NVARCHAR(MAX),
  @namingPatterns NVARCHAR(MAX),
  @minimumAgeDays INT,
  @minimumSizeBytes INT,
  @includeSystemFiles BIT
AS
BEGIN
  SET NOCOUNT ON;

  /**
   * @validation Required parameter validation
   */
  IF (@idAccount IS NULL)
  BEGIN
    ;THROW 51000, 'idAccountRequired', 1;
  END;

  IF (@idScanConfiguration IS NULL)
  BEGIN
    ;THROW 51000, 'idScanConfigurationRequired', 1;
  END;

  /**
   * @validation Data consistency validation
   */
  IF NOT EXISTS (
    SELECT 1
    FROM [functional].[scanConfiguration] scnCfg
    WHERE scnCfg.[idScanConfiguration] = @idScanConfiguration
      AND scnCfg.[idAccount] = @idAccount
      AND scnCfg.[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'configurationNotFound', 1;
  END;

  /**
   * @validation Duplicate name check
   */
  IF EXISTS (
    SELECT 1
    FROM [functional].[scanConfiguration] scnCfg
    WHERE scnCfg.[idAccount] = @idAccount
      AND scnCfg.[name] = @name
      AND scnCfg.[idScanConfiguration] <> @idScanConfiguration
      AND scnCfg.[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'configurationNameAlreadyExists', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

      UPDATE [functional].[scanConfiguration]
      SET
        [name] = @name,
        [directoryPath] = @directoryPath,
        [includeSubdirectories] = @includeSubdirectories,
        [fileExtensions] = @fileExtensions,
        [namingPatterns] = @namingPatterns,
        [minimumAgeDays] = @minimumAgeDays,
        [minimumSizeBytes] = @minimumSizeBytes,
        [includeSystemFiles] = @includeSystemFiles,
        [dateModified] = GETUTCDATE()
      WHERE [idScanConfiguration] = @idScanConfiguration
        AND [idAccount] = @idAccount;

      /**
       * @output {UpdateResult, 1, 1}
       * @column {INT} idScanConfiguration - Updated configuration identifier
       */
      SELECT @idScanConfiguration AS [idScanConfiguration];

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO