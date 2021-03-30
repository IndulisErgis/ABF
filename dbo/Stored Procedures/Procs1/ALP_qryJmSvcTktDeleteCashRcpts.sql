

CREATE Procedure dbo.ALP_qryJmSvcTktDeleteCashRcpts
@ID int
AS
begin
	SET NOCOUNT ON
	DELETE dbo.tblArCashRcptHeader
	FROM tblArCashRcptHeader INNER JOIN ALP_tblArTransHeader_view ON tblArCashRcptHeader.InvcTransID = ALP_tblArTransHeader_view.TransId
	WHERE ALP_tblArTransHeader_view.AlpJobNum = @ID
	
	DELETE dbo.tblArOpenInvoice
	FROM tblArOpenInvoice INNER JOIN ALP_tblArTransHeader_view ON tblArOpenInvoice.TransID = ALP_tblArTransHeader_view.TransId
	WHERE ALP_tblArTransHeader_view.AlpJobNum = @ID
	
	DELETE dbo.ALP_tblArOpenInvoice
	FROM ALP_tblArOpenInvoice INNER JOIN ALP_tblArTransHeader_view ON ALP_tblArOpenInvoice.AlpTransID = ALP_tblArTransHeader_view.TransId
	WHERE ALP_tblArTransHeader_view.AlpJobNum = @ID
end