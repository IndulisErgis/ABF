CREATE  FUNCTION [dbo].[ufxCS_Test_Type]
/* returns the Test Type as a string */
--EFI# 1408 MAH 042804 - expand conditions defining TD, TW, TM
--EFI# 1596 MAH 041607 - added TH
(
@Test_frequency_type varchar(12),
@Test_frequency_interval smallint 
)  
RETURNS varchar (17)
AS 
 
BEGIN 
declare @TestType as varchar(17)

--EFI# 1408 MAH 042804
SET @TestType = ''
SELECT 
@TestType =
	CASE 
	   WHEN @Test_frequency_type like 'h%'
		AND @Test_frequency_interval < '25'
	   	THEN 'TH - Hourly Test'
	   WHEN @Test_frequency_type like 'h%'
		AND @Test_frequency_interval >= '25'
	   	THEN 'TD - Daily Test'
	   WHEN @Test_frequency_type like 'd%'
		AND @Test_frequency_interval = '1'
	   	THEN 'TD - Daily Test'
	   WHEN @Test_frequency_type like 'd%'
		AND @Test_frequency_interval = '7'
	   	THEN 'TW - Weekly Test'
   	   WHEN @Test_frequency_type like 'd%'
		AND @Test_frequency_interval = '30'
	   	THEN 'TM - Monthly Test'
	   WHEN @Test_frequency_type like 'w%'
		AND @Test_frequency_interval = '1'
	   	THEN 'TW - Weekly Test'
	   WHEN @Test_frequency_type like 'w%'
		AND @Test_frequency_interval = '4'
	   	THEN 'TM - Monthly Test'
	   ELSE ''
	END

--SELECT 
--@TestType =
--	CASE 
--	   WHEN @Test_frequency_type = 'hly'
--		AND @Test_frequency_interval = '25'
--	   THEN 'TD - Daily Test'
--	   WHEN @Test_frequency_type = 'dly'
--		AND @Test_frequency_interval = '7'
--	   THEN 'TW - Weekly Test'
--	   WHEN @Test_frequency_type = 'wly'
--		AND @Test_frequency_interval = '4'
--	   THEN 'TM - Monthly Test'
--	END
return @TestType
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxCS_Test_Type] TO PUBLIC
    AS [dbo];

