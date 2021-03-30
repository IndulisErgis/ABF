CREATE TABLE [dbo].[tblMrWCMachineGroups] (
    [WorkCenterId]   VARCHAR (10) NOT NULL,
    [MachineGroupId] VARCHAR (10) NOT NULL,
    [ts]             ROWVERSION   NULL,
    [CF]             XML          NULL,
    PRIMARY KEY CLUSTERED ([WorkCenterId] ASC, [MachineGroupId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMrWCMachineGroups] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMrWCMachineGroups] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMrWCMachineGroups] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMrWCMachineGroups] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrWCMachineGroups';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrWCMachineGroups';

