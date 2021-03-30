CREATE FUNCTION dbo.ufxCS_CustID
(
@transmitter varchar(36)
)
RETURNS varchar(20)
AS  
BEGIN
DECLARE @CustID as varchar(20)
set @CustID = 
	(SELECT customer 
	FROM PHX.phoenix.dbo.ABMTransmitter 
	WHERE transmitter_id=@transmitter)
	
return @CustID
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxCS_CustID] TO PUBLIC
    AS [dbo];

