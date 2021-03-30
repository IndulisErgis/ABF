CREATE TABLE [dbo].[tblInHazMat] (
    [HMRef]  INT           IDENTITY (1, 1) NOT NULL,
    [HMCode] VARCHAR (6)   NOT NULL,
    [Descr]  VARCHAR (300) NULL,
    [CF]     XML           NULL,
    [ts]     ROWVERSION    NULL,
    CONSTRAINT [PK__tblInHazMat] PRIMARY KEY CLUSTERED ([HMRef] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblInHazMat]
    ON [dbo].[tblInHazMat]([HMCode] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInHazMat';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInHazMat';

