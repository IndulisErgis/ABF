CREATE TABLE [dbo].[ALP_tblArAlpDivision] (
    [DivisionId] INT           IDENTITY (1, 1) NOT NULL,
    [Division]   VARCHAR (10)  NULL,
    [Name]       VARCHAR (255) NULL,
    [GlSegId]    VARCHAR (12)  NULL,
    [InactiveYN] BIT           CONSTRAINT [DF_tblArAlpDivison_InactiveYN] DEFAULT (0) NULL,
    [ts]         ROWVERSION    NULL,
    CONSTRAINT [PK_tblArAlpDivision] PRIMARY KEY CLUSTERED ([DivisionId] ASC) WITH (FILLFACTOR = 80)
);


GO
 
CREATE TRIGGER trgArAlpDivisionU ON dbo.Alp_tblArAlpDivision FOR UPDATE AS  
SET NOCOUNT ON  
Declare @FldVal varchar(255)  
Declare @Undo bit  
Set @Undo = 0  
IF (UPDATE(DivisionID))  
BEGIN  
 /* BEGIN tblJmSvcTkt */  
 IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTkt WHERE (deleted.DivisionId = ALP_tblJmSvcTkt.DivId)) > 0  
 BEGIN  
  Select @FldVal = Cast(deleted.DivisionID As Varchar) from deleted  
  RAISERROR (90020, 16, 1, 'trgArAlpDivisionU', @FldVal, 'ALP_tblJmSvcTkt.DivId')  
  Set @Undo = 1  
 END  
 /* END tblJmSvcTkt */  
 /* BEGIN tblJmTech */  
 IF (SELECT COUNT(*) FROM deleted, ALP_tblJmTech WHERE (deleted.DivisionID = ALP_tblJmTech.DivisionId)) > 0  
 BEGIN  
  Select @FldVal = Cast(deleted.DivisionId As Varchar) from deleted  
  RAISERROR (90020, 16, 1, 'trgArAlpDivisionU', @FldVal, 'ALP_tblJmTech.DivisionId')  
  Set @Undo = 1  
 END  
 /* END tblJmTech */  
 /* BEGIN tblArSalesRep */  
 IF (SELECT COUNT(*) FROM deleted, Alp_tblArSalesRep WHERE (deleted.DivisionID = ALP_tblArSalesRep.AlpDivisionID)) > 0  
 BEGIN  
  Select @FldVal = Cast(deleted.DivisionId As Varchar) from deleted  
  RAISERROR (90020, 16, 1, 'trgArAlpDivisionU', @FldVal, 'ALP_tblArSalesRep.AlpDivisionId')  
  Set @Undo = 1  
 END  
 /* END tblArSalesRep */  
END  
If @Undo = 1  
Begin  
 Rollback Transaction  
End
GO

CREATE TRIGGER trgArAlpDivisionD ON dbo.ALP_tblArAlpDivision FOR DELETE AS  
SET NOCOUNT ON  
Declare @FldVal varchar(255)  
Declare @Undo bit  
Set @Undo = 0  
/* BEGIN tblJmSvcTkt */  
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTkt WHERE (deleted.DivisionId = ALP_tblJmSvcTkt.DivId)) > 0  
BEGIN  
    Select @FldVal = Cast(deleted.DivisionId As Varchar) from deleted  
    RAISERROR (90000, 16, 1, 'trgArAlpDivisionD', @FldVal, 'ALP_tblJmSvcTkt.DivId')  
    Set @Undo = 1  
END  
/* END tblJmSvcTkt */  
/* BEGIN tblJmTech */  
IF (SELECT COUNT(*) FROM deleted, Alp_tblJmTech WHERE (deleted.DivisionId = Alp_tblJmTech.DivisionId)) > 0  
BEGIN  
    Select @FldVal = Cast(deleted.DivisionId As Varchar) from deleted  
    RAISERROR (90000, 16, 1, 'trgArAlpDivisionD', @FldVal, 'Alp_tblJmTech.DivisionId')  
    Set @Undo = 1  
END  
/* END tblJmTech */  
/* BEGIN tblArSalesRep */  
IF (SELECT COUNT(*) FROM deleted, Alp_tblArSalesRep WHERE (deleted.DivisionId = Alp_tblArSalesRep.AlpDivisionId)) > 0  
BEGIN  
    Select @FldVal = Cast(deleted.DivisionId As Varchar) from deleted  
    RAISERROR (90000, 16, 1, 'trgArAlpDivisionD', @FldVal, 'Alp_tblArSalesRep.AlpDivisionId')  
    Set @Undo = 1  
END  
/* END tblArSalesRep */  
If @Undo = 1  
Begin  
 Rollback Transaction  
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpDivision] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpDivision] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpDivision] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpDivision] TO PUBLIC
    AS [dbo];

