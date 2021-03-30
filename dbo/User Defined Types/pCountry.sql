CREATE TYPE [dbo].[pCountry]
    FROM VARCHAR (6) NOT NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pCountry] TO PUBLIC;

