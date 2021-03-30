CREATE FUNCTION [dbo].[udf_GetNthOccurrence](@string VARCHAR(MAX), @occurrence_val VARCHAR(MAX), @occurrence_no INT)
 RETURNS INT AS
 BEGIN
     DECLARE @ctr INT, @pos INT, @len INT
     SET @ctr = 0
     SET @pos = 0
     SET @len = LEN(@occurrence_val)
     WHILE @ctr<@occurrence_no
     BEGIN        
         SET @pos = CHARINDEX(@occurrence_val, @string, @pos) + @len
 
        IF @pos = @len
         BEGIN
             RETURN -1
         END
         SET @ctr = @ctr+1            
     END
     RETURN @pos - @len
 END