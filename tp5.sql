DROP TABLE IF EXISTS HISTO_AN_ACTIONNAIRE CASCADE;
DROP TABLE IF EXISTS ACTION CASCADE;
DROP TABLE IF EXISTS SALARIE CASCADE; 
DROP TABLE IF EXISTS SOCIETE CASCADE;
DROP TABLE IF EXISTS PERSONNE CASCADE;

DROP TYPE IF EXISTS t_SOCIETE CASCADE;
DROP TYPE IF EXISTS t_PERSONNE CASCADE;

CREATE TYPE t_PERSONNE AS (
	NumSecu		INTEGER,
	Nom			varchar(30),
	Prenom		varchar(30),
	Sexe		varchar(5),
	DateNaiss	Date);
CREATE Table PERSONNE of t_PERSONNE(NumSecu PRIMARY KEY);


CREATE TYPE t_SOCIETE AS (
	CodeSoc		INTEGER,
	NomSoc		varchar(30),
	Adresse		varchar(30));
CREATE table SOCIETE of t_SOCIETE(CodeSoc PRIMARY KEY);


CREATE TABLE SALARIE(
	pers_salarie		t_PERSONNE,
	soc_salarie 		t_SOCIETE,
	salaire 			float
);

CREATE TABLE ACTION(
	pers_action		t_PERSONNE,
	soc_action		t_SOCIETE,
	dateAct			Date PRIMARY KEY,
	nbrAct			integer,
	typeAct			varchar(30)
);

CREATE TABLE HISTO_AN_ACTIONNAIRE(
	pers_histo		t_PERSONNE,
	soc_histo		t_SOCIETE,
	Annee			integer ,
	NbrActTotal		integer,
	Nbr_Achat		integer,
	Nbr_vente		integer
);

INSERT INTO PERSONNE VALUES (1,'HUA','Vi-Quang','M','07/09/1995');
INSERT INTO PERSONNE VALUES (2,'CHOUEIB','Alex','M','12/11/1994');
INSERT INTO PERSONNE VALUES (3,'HUA','Vi-Khanh','M','25/04/2004');
INSERT INTO PERSONNE VALUES (4,'Apolo','Mei','F','22/12/1994');

INSERT INTO SOCIETE VALUES (11,'LA-VIE','18 allée francois mitterrand');
INSERT INTO SOCIETE VALUES (12,'LIFE','26 la grande couléé');
INSERT INTO SOCIETE VALUES (13,'ABC','3 rue de la paix');

INSERT INTO SALARIE VALUES (row(1,'HUA','Vi-Quang','M','07/09/1995'), row(11,'LA-VIE','18 allée francois mitterrand'),5000);
INSERT INTO SALARIE VALUES (row(2,'CHOUEIB','Alex','M','12/11/1994'), row(12,'LIFE','26 la grande couléé'),3500);
INSERT INTO SALARIE VALUES (row(3,'HUA','Vi-Khanh','M','25/04/2004'), row(11,'LA-VIE','18 allée francois mitterrand'),3900);
INSERT INTO SALARIE VALUES (row(4,'Apolo','Mei','F','22/12/1994'), row(13,'ABC','3 rue de la paix'),1500);
INSERT INTO SALARIE VALUES (row(5,'David','Beckham','M','01/01/1990'), row(11,'LA-VIE','18 allée francois mitterrand'),6000);

INSERT INTO ACTION VALUES (row(1,'HUA','Vi-Quang','M','07/09/1995'), row(13,'ABC','3 rue de la paix'),'2020-09-30',1,'Vente');
INSERT INTO ACTION VALUES (row(1,'HUA','Vi-Quang','M','07/09/1995'), row(11,'LA-VIE','18 allée francois mitterrand'),'2021-04-21',6,'Achat');
INSERT INTO ACTION VALUES (row(2,'CHOUEIB','Alex','M','12/11/1994'), row(12,'LIFE','26 la grande couléé'),'2022-09-10',5,'Achat');
INSERT INTO ACTION VALUES (row(5,'David','Beckham','M','01/01/1990'), row(11,'LA-VIE','18 allée francois mitterrand'),'2020-05-10', 10, 'Achat');
INSERT INTO ACTION VALUES (row(5,'David','Beckham','M','01/01/1990'), row(13,'ABC','3 rue de la paix'),'2020-01-10',7,'Vente');

INSERT INTO HISTO_AN_ACTIONNAIRE VALUES (row(1,'HUA','Vi-Quang','M','07/09/1995'),row(11,'LA-VIE','18 allée francois mitterrand'),2021,100,30,70);
INSERT INTO HISTO_AN_ACTIONNAIRE VALUES (row(2,'CHOUEIB','Alex','M','12/11/1994'), row(12,'LIFE','26 la grande couléé'),2022, 50,30,20);
INSERT INTO HISTO_AN_ACTIONNAIRE VALUES (row(5,'David','Beckham','M','01/01/1990'), row(11,'LA-VIE','18 allée francois mitterrand'),2020,10,9,1);
INSERT INTO HISTO_AN_ACTIONNAIRE VALUES (row(1,'HUA','Vi-Quang','M','07/09/1995'),row(13,'ABC','3 rue de la paix'),2020,1,0,1);

--INSERT INTO ACTION VALUES (row(2,'CHOUEIB','Alex','M','12/11/1994'), row(12,'LIFE','26 la grande couléé'),'2019-05-01',5,'Achat');
--cette requette pour tester le trigger de la question 4;

--INSERT INTO ACTION VALUES (row(1,'HUA','Vi-Quang','M','07/09/1995'), row(11,'LA-VIE','18 allée francois mitterrand'),'2021-09-01',6,'Achat');
--cette requette pour tester le trigger de la question 10;

--INSERT INTO ACTION VALUES (row(1,'HUA','Vi-Quang','M','07/09/1995'), row(11,'LA-VIE','18 allée francois mitterrand'),'2020-09-01',6,'Achat');
--cette requette pour tester le trigger de la question 10 et la question 3;

--3--
CREATE OR REPLACE FUNCTION count_act()
	returns trigger as $$

DECLARE
	--curs CURSOR FOR SELECT NbrActTotal, Nbr_Achat, Nbr_vente FROM HISTO_AN_ACTIONNAIRE;
BEGIN
	--FOR i in curs
	--	LOOP
			IF (new.typeAct = 'Achat') 
				THEN	UPDATE HISTO_AN_ACTIONNAIRE H SET Nbr_Achat = (Nbr_Achat + 1)
								Where (new.pers_action).NumSecu = (H.pers_histo).NumSecu;
						UPDATE HISTO_AN_ACTIONNAIRE H SET NbrActTotal = (NbrActTotal + 1)
								Where (new.pers_action).NumSecu = (H.pers_histo).NumSecu;
			ELSE 
						UPDATE HISTO_AN_ACTIONNAIRE H SET Nbr_vente = (Nbr_vente + 1)
								Where (new.pers_action).NumSecu = (H.pers_histo).NumSecu;
						UPDATE HISTO_AN_ACTIONNAIRE H SET NbrActTotal = (NbrActTotal + 1)
								Where (new.pers_action).NumSecu = (H.pers_histo).NumSecu;
			END IF;
		--END LOOP;
	RETURN NEW;
END;

$$ LANGUAGE plpgsql;

CREATE TRIGGER maj AFTER INSERT ON ACTION FOR EACH ROW EXECUTE PROCEDURE count_act();

--4--
CREATE OR REPLACE FUnCTION non_ajouter()
	returns trigger as $$

BEGIN
	IF (new.dateAct < (select date(now() )))
		THEN	DELETE FROM ACTION WHERE dateAct = new.dateAct;
		RAISE EXCEPTION 'ne peux pas ajouter car la date est trop vieux';
	END IF;

RETURN NEW;

END;

$$ LANGUAGE plpgsql;

CREATE TRIGGER interdit AFTER INSERT ON ACTION FOR EACH ROW EXECUTE PROCEDURE non_ajouter();

--5--

CREATE OR REPLACE FUNCTION info_societe(cod_soc integer)
	returns table(Annee integer) AS $$

BEGIN
	RETURN QUERY
		SELECT H.Annee FROM HISTO_AN_ACTIONNAIRE H WHERE (H.soc_histo).CodeSoc = cod_soc AND (H.Nbr_vente > H.Nbr_Achat);
END;

$$ LANGUAGE plpgsql;


--6--

CREATE OR REPLACE FUNCTION nbr_perso(cod_soc integer)
	returns integer AS $$

DECLARE
	nbr integer=0;

BEGIN	
	SELECT count(P.NumSecu) INTO nbr FROM PERSONNE P WHERE P.NumSecu NOT IN (SELECT (H.pers_histo).NumSecu FROM HISTO_AN_ACTIONNAIRE H WHERE (H.soc_histo).CodeSoc = 11);
	RETURN nbr;
END;

$$ LANGUAGE plpgsql;

--7--

CREATE OR REPLACE FUNCTION liste_soc()
	returns table (NomSoc varchar, Annee integer) AS $$

DECLARE
	curs CURSOR FOR SELECT * FROM HISTO_AN_ACTIONNAIRE;
BEGIN
	FOR i in curs
	LOOP
		RETURN QUERY
			SELECT DISTINCT (H.soc_histo).NomSoc, H.Annee FROM HISTO_AN_ACTIONNAIRE H;
	END LOOP;
END;
$$ LANGUAGE plpgsql;


--8--

CREATE OR REPLACE FUNCTION aff_annee(cod_soc integer)
	returns table(Annee integer) AS $$

BEGIN
		RETURN QUERY
			SELECT H.Annee FROM HISTO_AN_ACTIONNAIRE H Where (H.soc_histo).CodeSoc = cod_soc;
END;

$$ LANGUAGE plpgsql;

--9--

CREATE OR REPLACE FUNCTION aff_pers(year integer)
	returns table(NumSecu integer, Nom varchar, Prenom varchar, Sexe varchar, DateNaiss Date)  AS $$
DECLARE


BEGIN
	RETURN QUERY
	SELECT (H.pers_histo).NumSecu, (H.pers_histo).Nom, (H.pers_histo).Prenom, (H.pers_histo).Sexe, (H.pers_histo).DateNaiss 
		 FROM HISTO_AN_ACTIONNAIRE H WHERE H.Annee = year AND H.NbrActTotal = (select Max(H2.NbrActTotal) FROM HISTO_AN_ACTIONNAIRE H2);

END;

$$ LANGUAGE plpgsql;


--10--

CREATE OR REPLACE FUNCTION verifier()
	returns trigger AS $$

DECLARE
	curs CURSOR FOR SELECT H.NbrActTotal FROM HISTO_AN_ACTIONNAIRE H 
					WHERE (H.pers_histo).NumSecu = (new.pers_action).NumSecu AND H.Annee = (SELECT EXTRACT(year from new.dateAct));
BEGIN
	FOR i in curs
		LOOP	
			IF (i.NbrActTotal > 3)
				THEN
					DELETE FROM ACTION A WHERE A.dateAct = new.dateAct;
					RAISE EXCEPTION 'Ce personne a deja 3 actions cet annee'; 
			END IF;
		END LOOP;
	RETURN NEW;
END;

$$ LANGUAGE plpgsql;

CREATE TRIGGER verification AFTER INSERT ON ACTION FOR EACH ROW EXECUTE PROCEDURE verifier();