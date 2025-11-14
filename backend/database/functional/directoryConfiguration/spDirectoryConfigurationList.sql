/**
 * @summary
 * Lists all directory configurations for an account with associated
 * extensions and patterns.
 *
 * @procedure spDirectoryConfigurationList
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/directory-configuration
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @testScenarios
 * - Valid list retrieval
 * - Empty result set handling
 * - Account validation
 */
CREATE OR ALTER PROCEDURE [functional].[spDirectoryConfigurationList]
  @idAccount INTEGER
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
   * @output {DirectoryConfigurationList, n, n}
   * @column {INT} idDirectoryConfiguration - Configuration identifier
   * @column {NVARCHAR} directoryPath - Directory path
   * @column {BIT} includeSubdirectories - Include subdirectories flag
   * @column {INT} minimumAge - Minimum age in days
   * @column {BIGINT} minimumSize - Minimum size in bytes
   * @column {BIT} includeSystemFiles - Include system files flag
   * @column {INT} extensionCount - Number of associated extensions
   * @column {INT} patternCount - Number of associated patterns
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
    (
      SELECT COUNT(*)
      FROM [functional].[directoryConfigurationExtension] dirCfgExt
      WHERE dirCfgExt.[idAccount] = dirCfg.[idAccount]
        AND dirCfgExt.[idDirectoryConfiguration] = dirCfg.[idDirectoryConfiguration]
    ) AS [extensionCount],
    (
      SELECT COUNT(*)
      FROM [functional].[directoryConfigurationPattern] dirCfgPat
      WHERE dirCfgPat.[idAccount] = dirCfg.[idAccount]
        AND dirCfgPat.[idDirectoryConfiguration] = dirCfg.[idDirectoryConfiguration]
    ) AS [patternCount],
    dirCfg.[dateCreated],
    dirCfg.[dateModified]
  FROM [functional].[directoryConfiguration] dirCfg
  WHERE dirCfg.[idAccount] = @idAccount
    AND dirCfg.[deleted] = 0
  ORDER BY dirCfg.[dateCreated] DESC;
END;
GO
