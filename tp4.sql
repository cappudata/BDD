---Exercice 1---
DROP FUNCTION IF EXISTS verifier() CASCADE;
DROP TRIGGER IF EXISTS vollaille_ANGERS;

DROP TABLE IF EXISTS eleveur CASCADE;
DROP TYPE IF EXISTS elevage_ype CASCADE;
DROP TYPE IF EXISTS t_animal CASCADE;
DROP TYPE IF EXISTS t_adresse CASCADE;


CREATE TYPE t_animal AS ENUM ('bovin', 'porcin', 'ovin','volaille');
CREATE TYPE elevage_ype AS
	( n_animal	t_animal,
	ageMin		int,
	nbrMax		int);
	
CREATE TYPE t_adresse AS
	( nrue		int,
	rue			Varchar(30),
	ville		Varchar(30),
	code_postale		int);


CREATE TABLE eleveur 
	( num_licence 	int,
	animal	elevage_ype,
	adresse	t_adresse);
	
	
INSERT INTO eleveur VALUES 
	(3, row('ovin',5,10), row(18, 'francois mitterrand', 'Angers', 49100));

INSERT INTO eleveur VALUES 
	(5, row('porcin',5,10), row(20, 'Fire', 'Angers', 49100));	
	
INSERT INTO eleveur VALUES 
	(3, row('ovin',5,10), row(18, ' miami', 'Angers', 49100));

INSERT INTO eleveur VALUES 
	(10, row('bovin',5,10), row(50, ' Water', 'Paris', 75000));
	
UPDATE eleveur SET num_licence = 2 where (animal).n_animal = 'porcin';


UPDATE eleveur SET adresse.ville = 'Bordeaux' , adresse.code_postale = 33000 
	where (animal).n_animal = 'ovin';

UPDATE eleveur SET animal = NULL 
	where (adresse).ville = 'Paris';

UPDATE eleveur SET animal.n_animal = 'volaille' 
	where (adresse).ville = 'Angers';


CREATE FUNCTION verifier() RETURNS TRIGGERS AS $$
BEGIN
	if (adresse).ville = 'Angers'
		then RAISE NOTICE 'Angers a le droit de élever que des volailles';
	end if
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER vollaille_ANGERS AFTER INSERT OR UPDATE ON eleveur
FOR EACH ROW EXECUTE PROCEDURE verifier();


