﻿CREATE TYPE [dbo].[pEmpID]
    FROM VARCHAR (11) NOT NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pEmpID] TO PUBLIC;

