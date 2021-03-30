

CREATE    Procedure dbo.ALP_qryJmSvcTktDeleteTrans
@ID int
AS
SET NOCOUNT ON


DELETE  FROM tblArTransHeader where tblArTransHeader.TransId in (Select TransId from tblArTransHeader 
left outer join ALP_tblArTransHeader on tblArTransHeader.TransId=ALP_tblArTransHeader.AlpTransId
	WHERE ALP_tblArTransHeader.AlpJobNum = @ID 
	      AND ALP_tblArTransHeader.AlpFROMJobYN = 1)

DELETE 
FROM ALP_tblArTransHeader
WHERE ALP_tblArTransHeader.AlpJobNum = @ID AND ALP_tblArTransHeader.AlpFROMJobYN = 1