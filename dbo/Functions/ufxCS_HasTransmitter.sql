CREATE FUNCTION dbo.ufxCS_HasTransmitter
(
@transmitter varchar(36)= null
)
RETURNS int 
AS  
BEGIN 
DECLARE @OnlineYN as int
set @OnlineYN=0
if exists
	(SELECT * FROM PHX.phoenix.dbo.ABMTransmitter
	WHERE transmitter_id=@transmitter)
	set @OnlineYN = 1
return @OnlineYN
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxCS_HasTransmitter] TO PUBLIC
    AS [dbo];

