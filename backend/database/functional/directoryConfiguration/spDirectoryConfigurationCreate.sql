/**
 * @summary
 * Creates a new directory configuration with associated extensions and patterns
 * for temporary file cleanup operations.
 *
 * @procedure spDirectoryConfigurationCreate
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - POST /api/v1/internal/directory-configuration
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {NVARCHAR(500)} directoryPath
 *   - Required: Yes
 *   - Description: Full path of directory to be configured
 *
 * @param {BIT} includeSubdirectories
 *   - Required: Yes
 *   - Description: Whether to include subdirectories in analysis
 *
 * @param {INT} minimumAge
 *   - Required: Yes
 *   - Description: Minimum age in days for file removal consideration
 *
 * @param {BIGINT} minimumSize
 *   - Required: Yes
 *   - Description: Minimum size in bytes for file removal consideration
 *
 * @param {BIT} includeSystemFiles
 *   - Required: Yes
 *   - Description: Whether to include system files in analysis
 *
 * @param {NVARCHAR(MAX)} extensionsJson
 *   - Required: Yes
 *   - Description: JSON array of extension IDs to associate
 *
 * @param {NVARCHAR(MAX)} patternsJson
 *   - Required: Yes
 *   - Description: JSON array of pattern IDs to associate
 *
 * @testScenarios
 * - Valid creation with all parameters
 * - Duplicate directory path validation
 * - Invalid extension/pattern ID validation
 * - Account validation
 */
CREATE OR ALTER PROCEDURE [functional].[spDirectoryConfigurationCreate]
  @idAccount INTEGER,
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

      DECLARE @idDirectoryConfiguration INTEGER;

      /**
       * @rule {fn-directory-configuration} Create directory configuration
       */
      INSERT INTO [functional].[directoryConfiguration]
      ([idAccount], [directoryPath], [includeSubdirectories], [minimumAge], [minimumSize], [includeSystemFiles], [dateCreated], [dateModified], [deleted])
      VALUES
      (@idAccount, @directoryPath, @includeSubdirectories, @minimumAge, @minimumSize, @includeSystemFiles, GETUTCDATE(), GETUTCDATE(), 0);

      SET @idDirectoryConfiguration = SCOPE_IDENTITY();

      /**
       * @rule {fn-directory-configuration-extensions} Associate extensions with configuration
       */
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
       * @rule {fn-directory-configuration-patterns} Associate patterns with configuration
       */
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
       * @column {DATETIME2} dateCreated - Creation timestamp
       */
      SELECT
        dirCfg.[idDirectoryConfiguration],
        dirCfg.[directoryPath],
        dirCfg.[includeSubdirectories],
        dirCfg.[minimumAge],
        dirCfg.[minimumSize],
        dirCfg.[includeSystemFiles],
        dirCfg.[dateCreated]
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
