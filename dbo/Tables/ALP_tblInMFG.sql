CREATE TABLE [dbo].[ALP_tblInMFG] (
    [ManufacturerId] VARCHAR (12) NOT NULL,
    [Desc]           VARCHAR (35) NULL,
    [InactiveYN]     BIT          CONSTRAINT [DF_ALP_tblInMFG_InactiveYN] DEFAULT ((0)) NULL,
    [ts]             ROWVERSION   NULL,
    CONSTRAINT [PK_ALP_tblInMFG] PRIMARY KEY CLUSTERED ([ManufacturerId] ASC) WITH (FILLFACTOR = 80)
);

