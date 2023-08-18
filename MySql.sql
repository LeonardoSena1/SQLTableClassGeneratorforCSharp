SET @TABLE_NAME = 'My_TABLE_NAME';
SET @TABLE_SCHEMA = 'My_TABLE_SCHEMA';
SELECT
    CONCAT(
        'public class ', 'abproles', '\n',
        '{\n',
        GROUP_CONCAT(
            CONCAT(
                ' public ',
                CASE
                    WHEN DATA_TYPE = 'bigint' THEN 'long'
                    WHEN DATA_TYPE = 'int' THEN 'int'
                    WHEN DATA_TYPE = 'tinyint' THEN 'byte'
                    WHEN DATA_TYPE = 'smallint' THEN 'short'
                    WHEN DATA_TYPE = 'float' THEN 'float'
                    WHEN DATA_TYPE = 'double' THEN 'double'
                    WHEN DATA_TYPE = 'decimal' THEN 'decimal'
                    WHEN DATA_TYPE = 'char' THEN 'string'
                    WHEN DATA_TYPE = 'varchar' THEN 'string'
                    WHEN DATA_TYPE = 'text' THEN 'string'
                    WHEN DATA_TYPE = 'date' THEN 'DateTime'
                    WHEN DATA_TYPE = 'datetime' THEN 'DateTime'
                    WHEN DATA_TYPE = 'timestamp' THEN 'DateTime'
                    ELSE 'UNKNOWN'
                END,
                CASE WHEN IS_NULLABLE = 'YES' THEN '?' ELSE '' END,
                ' ',
                COLUMN_NAME,
                ' { get; set; }'
            ),
            '\n'
        ),
        '\n}'
    )
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @TABLE_NAME AND TABLE_SCHEMA = @TABLE_SCHEMA;