CREATE TYPE [dbo].[pDistCode]
    FROM VARCHAR (6) NOT NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pDistCode] TO PUBLIC;

