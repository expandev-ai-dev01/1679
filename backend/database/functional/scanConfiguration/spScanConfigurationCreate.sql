/**
 * @summary
 * Creates a new scan configuration with directory path and identification criteria.
 * 
 * @procedure spScanConfigurationCreate
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/internal/scan-configuration
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 * 
 * @param {INT} idUser
 *   - Required: Yes
 *   - Description: User identifier for audit
 * 
 * @param {NVARCHAR(100)} name
 *   - Required: Yes
 *   - Description: Configuration name
 * 
 * @param {NVARCHAR(500)} directoryPath
 *   - Required: Yes
 *   - Description: Directory path to scan
 * 
 * @param {BIT} includeSubdirectories
 *   - Required: Yes
 *   - Description: Include subdirectories in scan
 * 
 * @param {NVARCHAR(MAX)} fileExtensions
 *   - Required: Yes
 *   - Description: JSON array of file extensions
 * 
 * @param {NVARCHAR(MAX)} namingPatterns
 *   - Required: Yes
 *   - Description: JSON array of naming patterns
 * 
 * @param {INT} minimumAgeDays
 *   - Required: Yes
 *   - Description: Minimum file age in days
 * 
 * @param {INT} minimumSizeBytes
 *   - Required: Yes
 *   - Description: Minimum file size in bytes
 * 
 * @param {BIT} includeSystemFiles
 *   - Required: Yes
 *   - Description: Include system files in scan
 * 
 * @returns {INT} idScanConfiguration - Created configuration identifier
 * 
 * @testScenarios
 * - Valid creation with all parameters
 * - Duplicate name validation
 * - Invalid directory path handling
 */
CREATE OR ALTER PROCEDURE [functional].[spScanConfigurationCreate]
  @idAccount INT,
  @idUser INT,
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
   * @throw {parameterRequired}
   */
  IF (@idAccount IS NULL)
  BEGIN
    ;THROW 51000, 'idAccountRequired', 1;
  END;

  IF (@idUser IS NULL)
  BEGIN
    ;THROW 51000, 'idUserRequired', 1;
  END;

  IF (@name IS NULL OR LTRIM(RTRIM(@name)) = '')
  BEGIN
    ;THROW 51000, 'nameRequired', 1;
  END;

  IF (@directoryPath IS NULL OR LTRIM(RTRIM(@directoryPath)) = '')
  BEGIN
    ;THROW 51000, 'directoryPathRequired', 1;
  END;

  /**
   * @validation Business rule validation
   * @throw {minimumAgeMustBeNonNegative}
   */
  IF (@minimumAgeDays < 0)
  BEGIN
    ;THROW 51000, 'minimumAgeMustBeNonNegative', 1;
  END;

  IF (@minimumSizeBytes < 0)
  BEGIN
    ;THROW 51000, 'minimumSizeMustBeNonNegative', 1;
  END;

  /**
   * @validation Duplicate name check
   * @throw {configurationNameAlreadyExists}
   */
  IF EXISTS (
    SELECT 1
    FROM [functional].[scanConfiguration] scnCfg
    WHERE scnCfg.[idAccount] = @idAccount
      AND scnCfg.[name] = @name
      AND scnCfg.[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'configurationNameAlreadyExists', 1;
  END;

  BEGIN TRY
    /**
     * @rule {db-multi-tenancy} Account-based data isolation
     */
    BEGIN TRAN;

      DECLARE @idScanConfiguration INT;

      INSERT INTO [functional].[scanConfiguration] (
        [idAccount],
        [name],
        [directoryPath],
        [includeSubdirectories],
        [fileExtensions],
        [namingPatterns],
        [minimumAgeDays],
        [minimumSizeBytes],
        [includeSystemFiles]
      )
      VALUES (
        @idAccount,
        @name,
        @directoryPath,
        @includeSubdirectories,
        @fileExtensions,
        @namingPatterns,
        @minimumAgeDays,
        @minimumSizeBytes,
        @includeSystemFiles
      );

      SET @idScanConfiguration = SCOPE_IDENTITY();

      /**
       * @output {ScanConfiguration, 1, 1}
       * @column {INT} idScanConfiguration - Created configuration identifier
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