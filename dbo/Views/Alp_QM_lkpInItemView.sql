Create view Alp_QM_lkpInItemView  as 
select a.*,AlpItemStatus =          
Case           
 WHEN ItemLocStatus =1 THEN 'Active'          
 WHEN ItemLocStatus =2 THEN 'Discontinued'          
 WHEN ItemLocStatus =3 THEN 'Superseded'       
 WHEN ItemLocStatus =4 THEN 'Obsolete'     
END ,b.AlpMFG ,b.AlpCATG,b.Descr,b.AlpQMDescription,b.KittedYN,b.ProductLine,b.UomDflt
 from   ALP_tblInItemLocation_view a inner join ALP_tblInItem_view b on a.itemid =b.alpitemid