/**
 * @summary
 * Updates an existing directory configuration including its associated
 * extensions and patterns.
 *
 * @procedure spDirectoryConfigurationUpdate
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - PUT /api/v1/internal/directory-configuration/:id
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {INT} idDirectoryConfiguration
 *   - Required: Yes
 *   - Description: Directory configuration identifier
 *
 * @param {NVARCHAR(500)} directoryPath
 *   - Required: Yes
 *   - Description: Full path of directory
 *
 * @param {BIT} includeSubdirectories
 *   - Required: Yes
 *   - Description: Whether to include subdirectories
 *
 * @param {INT} minimumAge
 *   - Required: Yes
 *   - Description: Minimum age in days
 *
 * @param {BIGINT} minimumSize
 *   - Required: Yes
 *   - Description: Minimum size in bytes
 *
 * @param {BIT} includeSystemFiles
 *   - Required: Yes
 *   - Description: Whether to include system files
 *
 * @param {NVARCHAR(MAX)} extensionsJson
 *   - Required: Yes
 *   - Description: JSON array of extension IDs
 *
 * @param {NVARCHAR(MAX)} patternsJson
 *   - Required: Yes
 *   - Description: JSON array of pattern IDs
 *
 * @testScenarios
 * - Valid update with all parameters
 * - Configuration not found handling
 * - Duplicate path validation
 * - Account validation
 */
CREATE OR ALTER PROCEDURE [functional].[spDirectoryConfigurationUpdate]
  @idAccount INTEGER,
  @idDirectoryConfiguration INTEGER,
  @directoryPath NVARCHAR(500),
  @includeSubdirectories BIT,
  @minimumAge INTEGER,
  @minimumSize BIGINT,
  @includeSystemFiles BIT,
  @extensionsJson NVARCHAR(MAX),
  @patternsJson NVARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON;

  /**
   * @validation Account existence validation
   * @throw {accountDoesntExist}
   */
  IF NOT EXISTS (SELECT * FROM [subscription].[account] acc WHERE acc.[idAccount] = @idAccount AND acc.[deleted] = 0)
  BEGIN
    ;THROW 51000, 'accountDoesntExist', 1;
  END;

  /**
   * @validation Configuration existence validation
   * @throw {directoryConfigurationDoesntExist}
   */
  IF NOT EXISTS (
    SELECT * FROM [functional].[directoryConfiguration] dirCfg
    WHERE dirCfg.[idDirectoryConfiguration] = @idDirectoryConfiguration
      AND dirCfg.[idAccount] = @idAccount
      AND dirCfg.[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'directoryConfigurationDoesntExist', 1;
  END;

  /**
   * @validation Required parameter validation
   * @throw {directoryPathRequired}
   */
  IF (@directoryPath IS NULL OR @directoryPath = '')
  BEGIN
    ;THROW 51000, 'directoryPathRequired', 1;
  END;

  /**
   * @validation Duplicate directory path validation
   * @throw {directoryPathAlreadyExists}
   */
  IF EXISTS (
    SELECT * FROM [functional].[directoryConfiguration] dirCfg
    WHERE dirCfg.[idAccount] = @idAccount
      AND dirCfg.[directoryPath] = @directoryPath
      AND dirCfg.[idDirectoryConfiguration] <> @idDirectoryConfiguration
      AND dirCfg.[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'directoryPathAlreadyExists', 1;
  END;

  /**
   * @validation Minimum age validation
   * @throw {minimumAgeMustBeEqualOrGreaterZero}
   */
  IF (@minimumAge < 0)
  BEGIN
    ;THROW 51000, 'minimumAgeMustBeEqualOrGreaterZero', 1;
  END;

  /**
   * @validation Minimum size validation
   * @throw {minimumSizeMustBeEqualOrGreaterZero}
   */
  IF (@minimumSize < 0)
  BEGIN
    ;THROW 51000, 'minimumSizeMustBeEqualOrGreaterZero', 1;
  END;

  BEGIN TRY
    /**
     * @rule {db-transaction-control} Transaction control for data integrity
     */
    BEGIN TRAN;

      /**
       * @rule {fn-directory-configuration} Update directory configuration
       */
      UPDATE [functional].[directoryConfiguration]
      SET
        [directoryPath] = @directoryPath,
        [includeSubdirectories] = @includeSubdirectories,
        [minimumAge] = @minimumAge,
        [minimumSize] = @minimumSize,
        [includeSystemFiles] = @includeSystemFiles,
        [dateModified] = GETUTCDATE()
      WHERE [idDirectoryConfiguration] = @idDirectoryConfiguration
        AND [idAccount] = @idAccount;

      /**
       * @rule {fn-directory-configuration-extensions} Update associated extensions
       */
      DELETE FROM [functional].[directoryConfigurationExtension]
      WHERE [idAccount] = @idAccount
        AND [idDirectoryConfiguration] = @idDirectoryConfiguration;

      IF (@extensionsJson IS NOT NULL AND @extensionsJson <> '[]')
      BEGIN
        INSERT INTO [functional].[directoryConfigurationExtension]
        ([idAccount], [idDirectoryConfiguration], [idExtension])
        SELECT
          @idAccount,
          @idDirectoryConfiguration,
          CAST(extJson.[value] AS INTEGER)
        FROM OPENJSON(@extensionsJson) extJson;
      END;

      /**
       * @rule {fn-directory-configuration-patterns} Update associated patterns
       */
      DELETE FROM [functional].[directoryConfigurationPattern]
      WHERE [idAccount] = @idAccount
        AND [idDirectoryConfiguration] = @idDirectoryConfiguration;

      IF (@patternsJson IS NOT NULL AND @patternsJson <> '[]')
      BEGIN
        INSERT INTO [functional].[directoryConfigurationPattern]
        ([idAccount], [idDirectoryConfiguration], [idPattern])
        SELECT
          @idAccount,
          @idDirectoryConfiguration,
          CAST(patJson.[value] AS INTEGER)
        FROM OPENJSON(@patternsJson) patJson;
      END;

      /**
       * @output {DirectoryConfiguration, 1, n}
       * @column {INT} idDirectoryConfiguration - Configuration identifier
       * @column {NVARCHAR} directoryPath - Directory path
       * @column {BIT} includeSubdirectories - Include subdirectories flag
       * @column {INT} minimumAge - Minimum age in days
       * @column {BIGINT} minimumSize - Minimum size in bytes
       * @column {BIT} includeSystemFiles - Include system files flag
       * @column {DATETIME2} dateModified - Last modification timestamp
       */
      SELECT
        dirCfg.[idDirectoryConfiguration],
        dirCfg.[directoryPath],
        dirCfg.[includeSubdirectories],
        dirCfg.[minimumAge],
        dirCfg.[minimumSize],
        dirCfg.[includeSystemFiles],
        dirCfg.[dateModified]
      FROM [functional].[directoryConfiguration] dirCfg
      WHERE dirCfg.[idDirectoryConfiguration] = @idDirectoryConfiguration;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO
