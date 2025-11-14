/**
 * @summary
 * Lists all scan configurations for an account.
 * 
 * @procedure spScanConfigurationList
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/scan-configuration
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 * 
 * @returns {RECORDSET} List of scan configurations
 * 
 * @testScenarios
 * - List configurations for valid account
 * - Empty list for account with no configurations
 */
CREATE OR ALTER PROCEDURE [functional].[spScanConfigurationList]
  @idAccount INT
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

  /**
   * @output {ScanConfigurationList, n, n}
   * @column {INT} idScanConfiguration - Configuration identifier
   * @column {NVARCHAR} name - Configuration name
   * @column {NVARCHAR} directoryPath - Directory path
   * @column {BIT} includeSubdirectories - Include subdirectories flag
   * @column {INT} minimumAgeDays - Minimum age in days
   * @column {INT} minimumSizeBytes - Minimum size in bytes
   * @column {DATETIME2} dateCreated - Creation date
   * @column {DATETIME2} dateModified - Last modification date
   */
  SELECT
    scnCfg.[idScanConfiguration],
    scnCfg.[name],
    scnCfg.[directoryPath],
    scnCfg.[includeSubdirectories],
    scnCfg.[minimumAgeDays],
    scnCfg.[minimumSizeBytes],
    scnCfg.[dateCreated],
    scnCfg.[dateModified]
  FROM [functional].[scanConfiguration] scnCfg
  WHERE scnCfg.[idAccount] = @idAccount
    AND scnCfg.[deleted] = 0
  ORDER BY scnCfg.[name];
END;
GO