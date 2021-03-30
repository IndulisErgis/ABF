CREATE PROCEDURE dbo.ALP_qryJmSvcTktInvcNumHist 

@ID int --TicketID  
As  
--Modified 04.15.2015, To use table directly instead of use view to resolve inconsistent result
SET NOCOUNT ON  
--SELECT ALP_tblArHistHeader_view.InvcNum, ALP_tblArHistHeader_view.AlpJobNum, ALP_tblArHistHeader_view.AlpSvcYN  
--FROM ALP_tblArHistHeader_view 
SELECT     tblArHistHeader.InvcNum, ALP_tblArHistHeader.AlpJobNum, ALP_tblArHistHeader.AlpSvcYN 
FROM         dbo.ALP_tblArHistHeader RIGHT OUTER JOIN  
                      dbo.tblArHistHeader ON dbo.ALP_tblArHistHeader.AlpPostRun = dbo.tblArHistHeader.PostRun 
                      AND dbo.ALP_tblArHistHeader.AlpTransId = dbo.tblArHistHeader.TransId  
WHERE   ALP_tblArHistHeader .AlpJobNum =@ID AND ALP_tblArHistHeader.AlpSvcYN = 1  
ORDER BY tblArHistHeader.InvcNum;