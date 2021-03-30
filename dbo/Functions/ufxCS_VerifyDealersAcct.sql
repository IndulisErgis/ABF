CREATE FUNCTION dbo.ufxCS_VerifyDealersAcct
--EFI# 1546 MAH 02/18/05
(
@Transmitter varchar(36) = null,
@DealerNum varchar(20) = null
)
RETURNS varchar(1)
 AS  
BEGIN 
DECLARE @DealersAcct as varchar(1)
IF EXISTS (
		(SELECT 'DealersAcct'='Y'
		FROM PHX.phoenix.dbo.ABMTransmitter
		WHERE transmitter_id=@Transmitter AND dealer = @DealerNum)
	)
SET @DealersAcct = 'Y'
else 	
SET @DealersAcct ='N'
RETURN @DealersAcct
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxCS_VerifyDealersAcct] TO PUBLIC
    AS [dbo];

