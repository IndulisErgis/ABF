CREATE TABLE [dbo].[tblFaRetireID] (
    [Counter]  INT        IDENTITY (1, 1) NOT NULL,
    [RetireID] INT        DEFAULT ((0)) NULL,
    [CF]       XML        NULL,
    [ts]       ROWVERSION NULL
);

