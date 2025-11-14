/**
 * @load temporaryFileExtension
 */
INSERT INTO [config].[temporaryFileExtension]
([extension], [description], [active])
VALUES
('.tmp', 'Temporary file', 1),
('.temp', 'Temporary file', 1),
('.cache', 'Cache file', 1),
('.bak', 'Backup file', 1),
('.log', 'Log file', 1),
('.~', 'Temporary file marker', 1),
('.swp', 'Swap file', 1);

/**
 * @load temporaryFilePattern
 */
INSERT INTO [config].[temporaryFilePattern]
([pattern], [description], [active])
VALUES
('temp*', 'Files starting with temp', 1),
('*_temp', 'Files ending with _temp', 1),
('*_old', 'Files ending with _old', 1),
('*_bak', 'Files ending with _bak', 1),
('~*', 'Files starting with tilde', 1);
GO
