
CREATE VIEW [dbo].[trav_CmContactLabels_View] AS
   SELECT  [c].[ID],	   
           [c].[ContactName],
           [c].[Title],
           [c].[FName],
           [c].[MName],
           [c].[LName],	
           [c].[Type],
           [c].[LinkType],
           [c].[Status],
           [c].[StatusID],
           [c].[LinkID],
           [c].[ReportToID],
           [c].[ID] AS [ContactID],  
          [ca].[ID] AS [AddressID],
          [ca].[Descr] AS [Description],         
          [ca].[Addr1],
          [ca].[Addr2],
          [ca].[City],
          [ca].[Region],
          [ca].[Country],
          [ca].[PostalCode],          
          [ca].[Sequence],
          [ca].[Status] AS [AddressStatus],          
          [rt].[ContactName] AS [ReportTo]
     FROM [dbo].[tblCmContact] [c]
LEFT JOIN [dbo].[tblCmContactAddress] [ca]
       ON ([ca].[ContactID] = [c].[ID]) 
LEFT JOIN [dbo].[tblCmContact] [rt]
       ON ([rt].[ID] =[c].[ReportToID])
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_CmContactLabels_View';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_CmContactLabels_View';

