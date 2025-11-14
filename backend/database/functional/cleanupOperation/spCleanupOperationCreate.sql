/**
 * @summary
 * Creates a new cleanup operation record to track file analysis and removal.
 *
 * @procedure spCleanupOperationCreate
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - POST /api/v1/internal/cleanup-operation
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
 * @param {VARCHAR(20)} removalMode
 *   - Required: Yes
 *   - Description: Removal mode (lixeira or permanente)
 *
 * @param {NVARCHAR(MAX)} criteriaJson
 *   - Required: No
 *   - Description: JSON with criteria used for operation
 *
 * @testScenarios
 * - Valid creation
 * - Configuration validation
 * - Account validation
 * - Invalid removal mode handling
 */
CREATE OR ALTER PROCEDURE [functional].[spCleanupOperationCreate]
  @idAccount INTEGER,
  @idDirectoryConfiguration INTEGER,
  @removalMode VARCHAR(20),
  @criteriaJson NVARCHAR(MAX) = NULL
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
   * @validation Removal mode validation
   * @throw {invalidRemovalMode}
   */
  IF (@removalMode NOT IN ('lixeira', 'permanente'))
  BEGIN
    ;THROW 51000, 'invalidRemovalMode', 1;
  END;

  DECLARE @idCleanupOperation INTEGER;

  /**
   * @rule {fn-cleanup-operation} Create cleanup operation record
   */
  INSERT INTO [functional].[cleanupOperation]
  ([idAccount], [idDirectoryConfiguration], [operationDate], [removalMode], [status], [criteriaJson])
  VALUES
  (@idAccount, @idDirectoryConfiguration, GETUTCDATE(), @removalMode, 'não iniciada', @criteriaJson);

  SET @idCleanupOperation = SCOPE_IDENTITY();

  /**
   * @output {CleanupOperation, 1, n}
   * @column {INT} idCleanupOperation - Operation identifier
   * @column {DATETIME2} operationDate - Operation date
   * @column {VARCHAR} status - Operation status
   */
  SELECT
    clnOp.[idCleanupOperation],
    clnOp.[operationDate],
    clnOp.[status]
  FROM [functional].[cleanupOperation] clnOp
  WHERE clnOp.[idCleanupOperation] = @idCleanupOperation;
END;
GO
