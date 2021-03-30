CREATE VIEW dbo.ALP_tblInItem_view  
AS  
SELECT        dbo.trav_tblInItem_view.ItemId, dbo.trav_tblInItem_view.Descr, dbo.trav_tblInItem_view.SuperId, dbo.trav_tblInItem_view.ItemType, dbo.trav_tblInItem_view.ItemStatus, dbo.trav_tblInItem_view.ProductLine,   
                         dbo.trav_tblInItem_view.SalesCat, dbo.trav_tblInItem_view.PriceId, dbo.trav_tblInItem_view.TaxClass, dbo.trav_tblInItem_view.UomBase, dbo.trav_tblInItem_view.UomDflt, dbo.trav_tblInItem_view.LottedYN,   
                         dbo.trav_tblInItem_view.AutoReorderYN, dbo.trav_tblInItem_view.KittedYN, dbo.trav_tblInItem_view.ResaleYN, dbo.trav_tblInItem_view.PictId, dbo.trav_tblInItem_view.UsrFld1, dbo.trav_tblInItem_view.UsrFld2,   
                         dbo.trav_tblInItem_view.UsrFld3, dbo.trav_tblInItem_view.UsrFld4, dbo.trav_tblInItem_view.ts, dbo.trav_tblInItem_view.CostMethodOverride, dbo.trav_tblInItem_view.HMRef, cast( dbo.trav_tblInItem_view.CF as nvarchar(max)) as CF,   
                         dbo.ALP_tblInItem.AlpItemId, dbo.ALP_tblInItem.AlpServiceType, dbo.ALP_tblInItem.AlpDfltHours, dbo.ALP_tblInItem.AlpDfltPts, dbo.ALP_tblInItem.AlpPrintProposalYn, dbo.ALP_tblInItem.AlpCopyToListYn,   
                         dbo.ALP_tblInItem.AlpPhaseCodeID, dbo.ALP_tblInItem.AlpAcctCode, dbo.ALP_tblInItem.AlpPanelYN, dbo.ALP_tblInItem.AlpVendorKitYN, dbo.ALP_tblInItem.AlpDfltCommercialHours, dbo.ALP_tblInItem.AlpDfltCommercialPts,   
                         dbo.ALP_tblInItem.AlpLocationYn, dbo.ALP_tblInItem.AlpPrintOnInvoice, dbo.ALP_tblInItem.AlpMFG, dbo.ALP_tblInItem.AlpCATG, dbo.ALP_tblInItem.Alpts, dbo.ALP_tblInItem.AlpQMDescription,   
                         dbo.ALP_tblInItem.AlpKitUsageRestrictedToPO  
FROM            dbo.trav_tblInItem_view LEFT OUTER JOIN  
                         dbo.ALP_tblInItem ON dbo.trav_tblInItem_view.ItemId = dbo.ALP_tblInItem.AlpItemId
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'ALP_tblInItem_view';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'ALP_tblInItem_view';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[38] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "trav_tblInItem_view"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 238
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ALP_tblInItem"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 273
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 45
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
     ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'ALP_tblInItem_view';

