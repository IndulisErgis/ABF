CREATE TYPE [dbo].[pLocID]
    FROM VARCHAR (10) NOT NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pLocID] TO PUBLIC;

