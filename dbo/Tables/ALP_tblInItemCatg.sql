CREATE TABLE [dbo].[ALP_tblInItemCatg] (
    [CategoryId] VARCHAR (12) NOT NULL,
    [Desc]       VARCHAR (35) NULL,
    [InactiveYN] BIT          CONSTRAINT [DF_ALP_tblInProdCatg_InactiveYN] DEFAULT ((0)) NULL,
    [ts]         ROWVERSION   NULL,
    CONSTRAINT [PK_ALP_tblInProdCatg] PRIMARY KEY CLUSTERED ([CategoryId] ASC) WITH (FILLFACTOR = 80)
);

