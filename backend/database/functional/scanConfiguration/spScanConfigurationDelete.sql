/**
 * @summary
 * Soft deletes a scan configuration.
 * 
 * @procedure spScanConfigurationDelete
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - DELETE /api/v1/internal/scan-configuration/:id
 * 
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier for audit
 * @param {INT} idScanConfiguration - Configuration identifier
 * 
 * @testScenarios
 * - Valid deletion
 * - Configuration not found error
 */
CREATE OR ALTER PROCEDURE [functional].[spScanConfigurationDelete]
  @idAccount INT,
  @idUser INT,
  @idScanConfiguration INT
AS
BEGIN
  SET NOCOUNT ON;

  /**
   * @validation Required parameter validation
   */
  IF (@idAccount IS NULL)
  BEGIN
    ;THROW 51000, 'idAccountRequired', 1;
  END;

  IF (@idScanConfiguration IS NULL)
  BEGIN
    ;THROW 51000, 'idScanConfigurationRequired', 1;
  END;

  /**
   * @validation Data consistency validation
   */
  IF NOT EXISTS (
    SELECT 1
    FROM [functional].[scanConfiguration] scnCfg
    WHERE scnCfg.[idScanConfiguration] = @idScanConfiguration
      AND scnCfg.[idAccount] = @idAccount
      AND scnCfg.[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'configurationNotFound', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

      UPDATE [functional].[scanConfiguration]
      SET
        [deleted] = 1,
        [dateModified] = GETUTCDATE()
      WHERE [idScanConfiguration] = @idScanConfiguration
        AND [idAccount] = @idAccount;

      /**
       * @output {DeleteResult, 1, 1}
       * @column {INT} idScanConfiguration - Deleted configuration identifier
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