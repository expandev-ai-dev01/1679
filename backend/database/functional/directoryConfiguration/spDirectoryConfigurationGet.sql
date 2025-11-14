/**
 * @summary
 * Retrieves detailed information about a specific directory configuration
 * including all associated extensions and patterns.
 *
 * @procedure spDirectoryConfigurationGet
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/directory-configuration/:id
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
 * @testScenarios
 * - Valid retrieval with all data
 * - Configuration not found handling
 * - Account validation
 */
CREATE OR ALTER PROCEDURE [functional].[spDirectoryConfigurationGet]
  @idAccount INTEGER,
  @idDirectoryConfiguration INTEGER
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
   * @output {DirectoryConfiguration, 1, n}
   * @column {INT} idDirectoryConfiguration - Configuration identifier
   * @column {NVARCHAR} directoryPath - Directory path
   * @column {BIT} includeSubdirectories - Include subdirectories flag
   * @column {INT} minimumAge - Minimum age in days
   * @column {BIGINT} minimumSize - Minimum size in bytes
   * @column {BIT} includeSystemFiles - Include system files flag
   * @column {DATETIME2} dateCreated - Creation timestamp
   * @column {DATETIME2} dateModified - Last modification timestamp
   */
  SELECT
    dirCfg.[idDirectoryConfiguration],
    dirCfg.[directoryPath],
    dirCfg.[includeSubdirectories],
    dirCfg.[minimumAge],
    dirCfg.[minimumSize],
    dirCfg.[includeSystemFiles],
    dirCfg.[dateCreated],
    dirCfg.[dateModified]
  FROM [functional].[directoryConfiguration] dirCfg
  WHERE dirCfg.[idDirectoryConfiguration] = @idDirectoryConfiguration
    AND dirCfg.[idAccount] = @idAccount
    AND dirCfg.[deleted] = 0;

  /**
   * @output {ConfigurationExtensions, n, n}
   * @column {INT} idExtension - Extension identifier
   * @column {VARCHAR} extension - Extension value
   * @column {NVARCHAR} description - Extension description
   */
  SELECT
    tmpExt.[idExtension],
    tmpExt.[extension],
    tmpExt.[description]
  FROM [functional].[directoryConfigurationExtension] dirCfgExt
    JOIN [config].[temporaryFileExtension] tmpExt ON (tmpExt.[idExtension] = dirCfgExt.[idExtension])
  WHERE dirCfgExt.[idAccount] = @idAccount
    AND dirCfgExt.[idDirectoryConfiguration] = @idDirectoryConfiguration
    AND tmpExt.[active] = 1;

  /**
   * @output {ConfigurationPatterns, n, n}
   * @column {INT} idPattern - Pattern identifier
   * @column {NVARCHAR} pattern - Pattern value
   * @column {NVARCHAR} description - Pattern description
   */
  SELECT
    tmpPat.[idPattern],
    tmpPat.[pattern],
    tmpPat.[description]
  FROM [functional].[directoryConfigurationPattern] dirCfgPat
    JOIN [config].[temporaryFilePattern] tmpPat ON (tmpPat.[idPattern] = dirCfgPat.[idPattern])
  WHERE dirCfgPat.[idAccount] = @idAccount
    AND dirCfgPat.[idDirectoryConfiguration] = @idDirectoryConfiguration
    AND tmpPat.[active] = 1;
END;
GO
