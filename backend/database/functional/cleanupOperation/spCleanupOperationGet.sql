/**
 * @summary
 * Retrieves detailed information about a specific cleanup operation
 * including all processed files.
 *
 * @procedure spCleanupOperationGet
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/cleanup-operation/:id
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {INT} idCleanupOperation
 *   - Required: Yes
 *   - Description: Cleanup operation identifier
 *
 * @testScenarios
 * - Valid retrieval with all data
 * - Operation not found handling
 */
CREATE OR ALTER PROCEDURE [functional].[spCleanupOperationGet]
  @idAccount INTEGER,
  @idCleanupOperation INTEGER
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
   * @validation Operation existence validation
   * @throw {cleanupOperationDoesntExist}
   */
  IF NOT EXISTS (
    SELECT * FROM [functional].[cleanupOperation] clnOp
    WHERE clnOp.[idCleanupOperation] = @idCleanupOperation
      AND clnOp.[idAccount] = @idAccount
  )
  BEGIN
    ;THROW 51000, 'cleanupOperationDoesntExist', 1;
  END;

  /**
   * @output {CleanupOperation, 1, n}
   * @column {INT} idCleanupOperation - Operation identifier
   * @column {NVARCHAR} directoryPath - Directory path
   * @column {DATETIME2} operationDate - Operation date
   * @column {INT} totalFilesAnalyzed - Total files analyzed
   * @column {INT} totalFilesRemoved - Total files removed
   * @column {BIGINT} totalSpaceFreed - Total space freed
   * @column {VARCHAR} removalMode - Removal mode
   * @column {VARCHAR} status - Operation status
   * @column {NVARCHAR} criteriaJson - Criteria JSON
   */
  SELECT
    clnOp.[idCleanupOperation],
    dirCfg.[directoryPath],
    clnOp.[operationDate],
    clnOp.[totalFilesAnalyzed],
    clnOp.[totalFilesRemoved],
    clnOp.[totalSpaceFreed],
    clnOp.[removalMode],
    clnOp.[status],
    clnOp.[criteriaJson]
  FROM [functional].[cleanupOperation] clnOp
    JOIN [functional].[directoryConfiguration] dirCfg ON (dirCfg.[idAccount] = clnOp.[idAccount] AND dirCfg.[idDirectoryConfiguration] = clnOp.[idDirectoryConfiguration])
  WHERE clnOp.[idCleanupOperation] = @idCleanupOperation
    AND clnOp.[idAccount] = @idAccount;

  /**
   * @output {OperationFiles, n, n}
   * @column {NVARCHAR} filePath - File path
   * @column {NVARCHAR} fileName - File name
   * @column {VARCHAR} fileExtension - File extension
   * @column {BIGINT} fileSize - File size in bytes
   * @column {DATETIME2} fileModifiedDate - File modification date
   * @column {NVARCHAR} identificationCriteria - Identification criteria
   * @column {BIT} removed - Whether file was removed
   * @column {NVARCHAR} errorMessage - Error message if any
   */
  SELECT
    clnOpFile.[filePath],
    clnOpFile.[fileName],
    clnOpFile.[fileExtension],
    clnOpFile.[fileSize],
    clnOpFile.[fileModifiedDate],
    clnOpFile.[identificationCriteria],
    clnOpFile.[removed],
    clnOpFile.[errorMessage]
  FROM [functional].[cleanupOperationFile] clnOpFile
  WHERE clnOpFile.[idAccount] = @idAccount
    AND clnOpFile.[idCleanupOperation] = @idCleanupOperation
  ORDER BY clnOpFile.[filePath];
END;
GO
