CREATE TABLE [dbo].[ALP_tblArAlpRecBillRunStatuses] (
    [StatusCode]   CHAR (1)      NOT NULL,
    [DisplayName]  VARCHAR (32)  NOT NULL,
    [DisplayOrder] INT           DEFAULT ((0)) NOT NULL,
    [Description]  VARCHAR (512) NULL
);

