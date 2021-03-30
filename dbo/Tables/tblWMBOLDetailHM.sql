CREATE TABLE [dbo].[tblWMBOLDetailHM] (
    [BOLHMRef]  INT           IDENTITY (1, 1) NOT NULL,
    [BOLDtlRef] INT           NOT NULL,
    [HMCode]    VARCHAR (6)   NULL,
    [Descr]     VARCHAR (300) NULL,
    [CF]        XML           NULL,
    CONSTRAINT [PK_tblWMBOLDetailHM] PRIMARY KEY CLUSTERED ([BOLHMRef] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWMBOLDetailHM';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWMBOLDetailHM';

