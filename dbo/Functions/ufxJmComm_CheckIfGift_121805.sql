
CREATE FUNCTION dbo.ufxJmComm_CheckIfGift_121805
(
	@InvcNum varchar(10)
)
returns bit
AS
BEGIN
declare @GiftYn bit

SET @GiftYn = 0
IF EXISTS (SELECT PmtMethodId
		  FROM  tblArHistPmt
		  WHERE (InvcNum = @InvcNum and PmtMethodId = 'GIFT')
		)
BEGIN
	SET @GiftYn = 1
END
RETURN @GiftYn
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxJmComm_CheckIfGift_121805] TO [JMCommissions]
    AS [dbo];

