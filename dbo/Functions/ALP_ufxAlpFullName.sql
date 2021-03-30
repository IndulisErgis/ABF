CREATE FUNCTION [dbo].[ALP_ufxAlpFullName] 
(
-- MAH 12/31/03 - Increased field sizes to accomodate changes made to Cust and Site name fields
@First varchar(30),
@Last varchar(80)  
)
RETURNS varchar(110) 
AS  
BEGIN 
	if NOT(@First is null )
		SET @Last=@Last+ ', ' + @First
		return @Last	
END