CREATE TABLE [dbo].[ALP_tblArAlpRecBillRun] (
    [RunId]           INT              IDENTITY (1, 1) NOT NULL,
    [NextBillDate]    DATETIME         NOT NULL,
    [NewNextBillDate] DATETIME         NOT NULL,
    [BatchCode]       VARCHAR (6)      NOT NULL,
    [InvoiceDate]     DATE             NOT NULL,
    [GLYear]          SMALLINT         NOT NULL,
    [GLPeriod]        SMALLINT         NOT NULL,
    [CustomerIdFrom]  VARCHAR (10)     NULL,
    [CustomerIdTo]    VARCHAR (10)     NULL,
    [BranchFrom]      INT              NULL,
    [BranchTo]        INT              NULL,
    [ClassFrom]       VARCHAR (6)      NULL,
    [ClassTo]         VARCHAR (6)      NULL,
    [GroupFrom]       VARCHAR (1)      NULL,
    [GroupTo]         VARCHAR (1)      NULL,
    [StatusCode]      CHAR (1)         NOT NULL,
    [CreatedDate]     DATETIME         DEFAULT (getdate()) NOT NULL,
    [RunGuid]         UNIQUEIDENTIFIER DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [ts]              ROWVERSION       NOT NULL,
    [PreviewOnly]     BIT              CONSTRAINT [DF_ALP_tblArAlpRecBillRun_PreviewOnly] DEFAULT ((0)) NOT NULL
);

