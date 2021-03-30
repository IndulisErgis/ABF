CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktInvcNumTrans]  
@ID int --TicketID  
As  
SET NOCOUNT ON  
SELECT ALP_tblArTransHeader_view.InvcNum, ALP_tblArTransHeader_view.AlpJobNum, ALP_tblArTransHeader_view.AlpSvcYN  
FROM ALP_tblArTransHeader_view 
WHERE ALP_tblArTransHeader_view.AlpJobNum = @ID AND ALP_tblArTransHeader_view.AlpSvcYN = 1 
ORDER BY ALP_tblArTransHeader_view.InvcNum;