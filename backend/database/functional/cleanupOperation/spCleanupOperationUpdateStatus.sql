/**
 * @summary
 * Updates the status and statistics of a cleanup operation.
 *
 * @procedure spCleanupOperationUpdateStatus
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - PATCH /api/v1/internal/cleanup-operation/:id/status
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
 * @param {VARCHAR(20)} status
 *   - Required: Yes
 *   - Description: New status
 *
 * @param {INT} totalFilesAnalyzed
 *   - Required: No
 *   - Description: Total files analyzed
 *
 * @param {INT} totalFilesRemoved
 *   - Required: No
 *   - Description: Total files removed
 *
 * @param {BIGINT} totalSpaceFreed
 *   - Required: No
 *   - Description: Total space freed in bytes
 *
 * @testScenarios
 * - Valid status update
 * - Operation not found handling
 * - Invalid status validation
 */
CREATE OR ALTER PROCEDURE [functional].[spCleanupOperationUpdateStatus]
  @idAccount INTEGER,
  @idCleanupOperation INTEGER,
  @status VARCHAR(20),
  @totalFilesAnalyzed INTEGER = NULL,
  @totalFilesRemoved INTEGER = NULL,
  @totalSpaceFreed BIGINT = NULL
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
   * @validation Status validation
   * @throw {invalidStatus}
   */
  IF (@status NOT IN ('não iniciada', 'em andamento', 'concluída', 'erro'))
  BEGIN
    ;THROW 51000, 'invalidStatus', 1;
  END;

  /**
   * @rule {fn-cleanup-operation} Update operation status and statistics
   */
  UPDATE [functional].[cleanupOperation]
  SET
    [status] = @status,
    [totalFilesAnalyzed] = ISNULL(@totalFilesAnalyzed, [totalFilesAnalyzed]),
    [totalFilesRemoved] = ISNULL(@totalFilesRemoved, [totalFilesRemoved]),
    [totalSpaceFreed] = ISNULL(@totalSpaceFreed, [totalSpaceFreed])
  WHERE [idCleanupOperation] = @idCleanupOperation
    AND [idAccount] = @idAccount;

  /**
   * @output {CleanupOperation, 1, n}
   * @column {INT} idCleanupOperation - Operation identifier
   * @column {VARCHAR} status - Operation status
   * @column {INT} totalFilesAnalyzed - Total files analyzed
   * @column {INT} totalFilesRemoved - Total files removed
   * @column {BIGINT} totalSpaceFreed - Total space freed
   */
  SELECT
    clnOp.[idCleanupOperation],
    clnOp.[status],
    clnOp.[totalFilesAnalyzed],
    clnOp.[totalFilesRemoved],
    clnOp.[totalSpaceFreed]
  FROM [functional].[cleanupOperation] clnOp
  WHERE clnOp.[idCleanupOperation] = @idCleanupOperation;
END;
GO
