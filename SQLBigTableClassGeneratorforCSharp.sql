-- Definir o nome da tabela para gerar a classe
DECLARE @TableName sysname = '[{TABLE}]';  -- Substitua pelo nome da sua tabela

-- Criar uma tabela temporária para armazenar os resultados das colunas
CREATE TABLE #TempColumns (
    ColumnName sysname,
    ColumnType sysname,
    NullableSign sysname
);

-- Inserir as informações das colunas da tabela na tabela temporária
INSERT INTO #TempColumns (ColumnName, ColumnType, NullableSign)
SELECT 
    REPLACE(col.name, ' ', '_') AS ColumnName,
    CASE 
        WHEN typ.name = 'bigint' THEN 'long'
        WHEN typ.name = 'binary' THEN 'byte[]'
        WHEN typ.name = 'bit' THEN 'bool'
        WHEN typ.name = 'char' THEN 'string'
        WHEN typ.name = 'date' THEN 'DateTime'
        WHEN typ.name = 'datetime' THEN 'DateTime'
        WHEN typ.name = 'datetime2' THEN 'DateTime'
        WHEN typ.name = 'datetimeoffset' THEN 'DateTimeOffset'
        WHEN typ.name = 'decimal' THEN 'decimal'
        WHEN typ.name = 'float' THEN 'float'
        WHEN typ.name = 'image' THEN 'byte[]'
        WHEN typ.name = 'int' THEN 'int'
        WHEN typ.name = 'money' THEN 'decimal'
        WHEN typ.name = 'nchar' THEN 'string'
        WHEN typ.name = 'ntext' THEN 'string'
        WHEN typ.name = 'numeric' THEN 'decimal'
        WHEN typ.name = 'nvarchar' THEN 'string'
        WHEN typ.name = 'real' THEN 'double'
        WHEN typ.name = 'smalldatetime' THEN 'DateTime'
        WHEN typ.name = 'smallint' THEN 'short'
        WHEN typ.name = 'smallmoney' THEN 'decimal'
        WHEN typ.name = 'text' THEN 'string'
        WHEN typ.name = 'time' THEN 'TimeSpan'
        WHEN typ.name = 'timestamp' THEN 'DateTime'
        WHEN typ.name = 'tinyint' THEN 'byte'
        WHEN typ.name = 'uniqueidentifier' THEN 'Guid'
        WHEN typ.name = 'varbinary' THEN 'byte[]'
        WHEN typ.name = 'varchar' THEN 'string'
        ELSE 'UNKNOWN_' + typ.name
    END AS ColumnType,
    CASE 
        WHEN col.is_nullable = 1 AND typ.name IN ('bigint', 'bit', 'date', 'datetime', 'datetime2', 'datetimeoffset', 'decimal', 'float', 'int', 'money', 'numeric', 'real', 'smalldatetime', 'smallint', 'smallmoney', 'time', 'tinyint', 'uniqueidentifier') 
        THEN '?' 
        ELSE '' 
    END AS NullableSign
FROM sys.columns col
JOIN sys.types typ ON col.system_type_id = typ.system_type_id 
    AND col.user_type_id = typ.user_type_id
WHERE object_id = object_id(@TableName)
ORDER BY column_id;

-- Gerar o código da classe
DECLARE @Result varchar(max) = 'public class ' + @TableName + ' {' + CHAR(13) + CHAR(10);

-- Concatenar as colunas
DECLARE @ColumnName sysname, @ColumnType sysname, @NullableSign sysname;
DECLARE column_cursor CURSOR FOR 
    SELECT ColumnName, ColumnType, NullableSign
    FROM #TempColumns;

OPEN column_cursor;

FETCH NEXT FROM column_cursor INTO @ColumnName, @ColumnType, @NullableSign;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Result = @Result + '    public ' + @ColumnType + @NullableSign + ' ' + @ColumnName + ' { get; set; }' + CHAR(13) + CHAR(10);
    
    FETCH NEXT FROM column_cursor INTO @ColumnName, @ColumnType, @NullableSign;
END

CLOSE column_cursor;
DEALLOCATE column_cursor;

-- Fechar a classe
SET @Result = @Result + '}';

-- Criar uma tabela de log para armazenar a classe gerada
CREATE TABLE GeneratedClassLog (
    Id INT IDENTITY(1,1),
    GeneratedClassText VARCHAR(MAX)
);

-- Inserir o resultado gerado na tabela de log
INSERT INTO GeneratedClassLog (GeneratedClassText)
VALUES (@Result);

SELECT * FROM GeneratedClassLog

-- Limpeza da tabela temporária
DROP TABLE #TempColumns;
DROP TABLE GeneratedClassLog;
