
CREATE FUNCTION dbo.ufxCS_GlobalPhone_SMS
(
@name varchar(25)= null
)
RETURNS varchar(18) 
AS  
BEGIN
return ( 
SELECT Phone 
FROM SMS...GlobalPhoneNumberTbl 
WHERE [Name] = @name)
--return @OnlineYN
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxCS_GlobalPhone_SMS] TO PUBLIC
    AS [dbo];

