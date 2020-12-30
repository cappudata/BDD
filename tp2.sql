--Excercie 1

DROP TABLE IF EXISTS Produit;
CREATE TABLE Produit (NumProd integer, Designation VARCHAR(30), Prix FLOAT);

DROP TABLE IF EXISTS Produit2;
CREATE TABLE Produit2 AS SELECT * FROM Produit;


INSERT INTO Produit VALUES (1,'voiture', 500);
INSERT INTO Produit VALUES (2,'velo', 100);
INSERT INTO Produit VALUES (3,'clavier', 200);
INSERT INTO Produit VALUES (4,'souris', 50);
INSERT INTO Produit VALUES (5,'porte',0);
INSERT INTO Produit VALUES (6,'pc',NULL);

CREATE OR REPLACE FUNCTION Initialisation()
	RETURNS VOID AS $$
DECLARE
	new_prix			Produit.Prix			%TYPE;
	new_designation		Produit.Designation		%TYPE;

	curs 	CURSOR FOR SELECT * FROM Produit;
BEGIN
	if (curs is not null) 
		then 
			FOR i IN curs
				LOOP
					new_designation = UPPER(i.Designation);
					if (i.prix = 0)
					then
						new_prix = 0;
					ELSEIF (i.prix = NULL)
					then
						new_prix = 0;
					ELSE
						new_prix = i.prix / 6.55957;
						new_prix = ROUND(new_prix);
					END IF;
					INSERT INTO Produit2 VALUES(i.NumProd, new_designation, new_prix);
				END LOOP;
	ELSE
		INSERT INTO 
	END IF;
END

$$ LANGUAGE plpgsql;
	

