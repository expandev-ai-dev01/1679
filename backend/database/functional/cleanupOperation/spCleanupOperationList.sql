/**
 * @summary
 * Lists cleanup operations for an account with pagination support.
 *
 * @procedure spCleanupOperationList
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/cleanup-operation
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {INT} page
 *   - Required: No
 *   - Description: Page number (default 1)
 *
 * @param {INT} pageSize
 *   - Required: No
 *   - Description: Items per page (default 50)
 *
 * @testScenarios
 * - Valid list retrieval
 * - Pagination handling
 * - Empty result set
 */
CREATE OR ALTER PROCEDURE [functional].[spCleanupOperationList]
  @idAccount INTEGER,
  @page INTEGER = 1,
  @pageSize INTEGER = 50
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

  DECLARE @offset INTEGER = (@page - 1) * @pageSize;

  /**
   * @output {CleanupOperationList, n, n}
   * @column {INT} idCleanupOperation - Operation identifier
   * @column {NVARCHAR} directoryPath - Directory path
   * @column {DATETIME2} operationDate - Operation date
   * @column {INT} totalFilesAnalyzed - Total files analyzed
   * @column {INT} totalFilesRemoved - Total files removed
   * @column {BIGINT} totalSpaceFreed - Total space freed
   * @column {VARCHAR} removalMode - Removal mode
   * @column {VARCHAR} status - Operation status
   */
  SELECT
    clnOp.[idCleanupOperation],
    dirCfg.[directoryPath],
    clnOp.[operationDate],
    clnOp.[totalFilesAnalyzed],
    clnOp.[totalFilesRemoved],
    clnOp.[totalSpaceFreed],
    clnOp.[removalMode],
    clnOp.[status]
  FROM [functional].[cleanupOperation] clnOp
    JOIN [functional].[directoryConfiguration] dirCfg ON (dirCfg.[idAccount] = clnOp.[idAccount] AND dirCfg.[idDirectoryConfiguration] = clnOp.[idDirectoryConfiguration])
  WHERE clnOp.[idAccount] = @idAccount
  ORDER BY clnOp.[operationDate] DESC
  OFFSET @offset ROWS
  FETCH NEXT @pageSize ROWS ONLY;

  /**
   * @output {TotalCount, 1, 1}
   * @column {INT} total - Total number of operations
   */
  SELECT COUNT(*) AS [total]
  FROM [functional].[cleanupOperation] clnOp
  WHERE clnOp.[idAccount] = @idAccount;
END;
GO
