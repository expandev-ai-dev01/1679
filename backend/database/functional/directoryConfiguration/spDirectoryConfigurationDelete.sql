/**
 * @summary
 * Soft deletes a directory configuration and its associated scheduled cleanups.
 *
 * @procedure spDirectoryConfigurationDelete
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - DELETE /api/v1/internal/directory-configuration/:id
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
 * - Valid deletion
 * - Configuration not found handling
 * - Account validation
 * - Cascade deletion of scheduled cleanups
 */
CREATE OR ALTER PROCEDURE [functional].[spDirectoryConfigurationDelete]
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

  BEGIN TRY
    /**
     * @rule {db-transaction-control} Transaction control for data integrity
     */
    BEGIN TRAN;

      /**
       * @rule {fn-directory-configuration} Soft delete directory configuration
       */
      UPDATE [functional].[directoryConfiguration]
      SET
        [deleted] = 1,
        [dateModified] = GETUTCDATE()
      WHERE [idDirectoryConfiguration] = @idDirectoryConfiguration
        AND [idAccount] = @idAccount;

      /**
       * @rule {fn-scheduled-cleanup} Soft delete associated scheduled cleanups
       */
      UPDATE [functional].[scheduledCleanup]
      SET
        [deleted] = 1,
        [dateModified] = GETUTCDATE()
      WHERE [idDirectoryConfiguration] = @idDirectoryConfiguration
        AND [idAccount] = @idAccount;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO
