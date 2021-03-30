CREATE TABLE [dbo].[tblInSourceType] (
    [SourceId]  TINYINT       NOT NULL,
    [TransType] TINYINT       NOT NULL,
    [TypeDescr] NVARCHAR (50) NULL,
    [AppId]     NCHAR (10)    NOT NULL,
    [RptCat]    TINYINT       DEFAULT ((1)) NOT NULL
);

