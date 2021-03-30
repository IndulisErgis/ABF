CREATE VIEW dbo.ALP_qryCSTransmitterExceptionsErrorsToBlock
AS  

SELECT     TOP 100 PERCENT T.Transmitter, E.ErrorCode, E.DisabledDate, E.DisabledBy, SS.SysDesc, SS.CustId, SS.SiteId, 
                      S.SiteName + CASE WHEN (S.AlpFirstName + '' <> '') THEN CONVERT(varchar, ', ') + S.AlpFirstName ELSE '' END AS SiteFullName, 
                      S.Addr1 + CASE WHEN (S.addr2 + '' <> '') THEN Char(13) + Char(10) + S.addr2 ELSE '' END + CHAR(13) + CHAR(10) + ISNULL(S.City, '') 
                      + CONVERT(varchar, ', ') + ISNULL(S.Region, '') + CONVERT(varchar, ' ') + ISNULL(S.PostalCode, '') AS SiteFullAddress, EC.ErrorMessage
FROM         ALP_tblCSTransmitterErrorsToBlock E INNER JOIN
                      ALP_tblCSErrorCodes EC ON E.ErrorCode = EC.ErrorCode RIGHT OUTER JOIN
                      ALP_tblCSTransmitterExceptions T INNER JOIN
                      ALP_tblArAlpSite S INNER JOIN
                      ALP_tblArAlpSiteSys SS ON S.SiteId = SS.SiteId ON T.Transmitter = SS.AlarmId ON E.Transmitter = T.Transmitter
ORDER BY T.Transmitter, E.ErrorCode