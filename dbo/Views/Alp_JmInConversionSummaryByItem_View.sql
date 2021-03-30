
CREATE VIEW [dbo].[Alp_JmInConversionSummaryByItem_View] AS  
 (  
 --The Query Alter by ravi on 03.11.2015, Added Unitprice, UnitCost,ExtPrice,ExtCost columns
 SELECT Alp_tmpJmSvcTktItem_IN_Conversion.TicketId,  
 Alp_tmpJmSvcTktItem_IN_Conversion.ItemId,  
 SUM( Alp_tmpJmSvcTktItem_IN_Conversion.BaseQty)BaseQty,   
 Alp_tmpJmSvcTktItem_IN_Conversion.Category,   
 Alp_tblJmSvcTkt.BinNumber,ALP_tblJmSvcTktItem.[Desc] as Descr  ,
 --ALP_tblJmSvcTktItem.UnitPrice ,
 ALP_tblJmSvcTktItem.UnitCost ,
 Sum( ALP_tblJmSvcTktItem.UnitPrice *Alp_tmpJmSvcTktItem_IN_Conversion.BaseQty) as ExtPrice,
 Sum(ALP_tblJmSvcTktItem.UnitCost * Alp_tmpJmSvcTktItem_IN_Conversion.BaseQty) as ExtCost
 FROM Alp_tmpJmSvcTktItem_IN_Conversion INNER JOIN Alp_tblJmSvcTkt ON  
 Alp_tmpJmSvcTktItem_IN_Conversion.TicketId = Alp_tblJmSvcTkt.TicketId  
 LEFT OUTER JOIN ALP_tblJmSvcTktItem  ON Alp_tmpJmSvcTktItem_IN_Conversion.ItemId =ALP_tblJmSvcTktItem.ItemId   
 AND ALP_tblJmSvcTktItem.TicketId  =Alp_tmpJmSvcTktItem_IN_Conversion.TicketId   
 AND ALP_tblJmSvcTktItem.TicketItemId  =Alp_tmpJmSvcTktItem_IN_Conversion.TicketItemId  
 Group by Alp_tmpJmSvcTktItem_IN_Conversion.ItemId , 
 Alp_tmpJmSvcTktItem_IN_Conversion.TicketId,Category,Alp_tblJmSvcTkt.BinNumber,ALP_tblJmSvcTktItem.[Desc],
  -- ALP_tblJmSvcTktItem.UnitPrice ,
   ALP_tblJmSvcTktItem.UnitCost 
 )