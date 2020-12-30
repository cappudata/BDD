DROP TABLE STAT_RESULTAT;
DROP TABLE TabNOTE;
DROP TABLE MATIERE;
DROP TABLE FORMATION;
DROP TABLE ENSEIGNANT;
DROP TABLE ETUDIANT;


Create table ETUDIANT 
(numet integer primary key, 
nom varchar(50), 
prenom varchar(50));

create table ENSEIGNANT
(numens integer primary key, 
nomens varchar(50), 
prenomens varchar(50));

Create table FORMATION
(nomform varchar(30) primary key, 
nbretud integer, 
enseigresponsable varchar(50));

Create table MATIERE
(nommat varchar(50), 
nomform varchar(50), 
numens integer references ENSEIGNANT(numens) on delete cascade on update cascade, 
coef float,
PRIMARY key (nommat, nomform));

Create table TabNOTE
(num_etud integer, 
nommat varchar(50) , 
nomform varchar(50), 
note float,
FOREIGN KEY(nommat, nomform) references MATIERE(nommat,nomform));

Create table STAT_RESULTAT
(nom_formation varchar(50), 
moy_generale float, 
nbrrecu integer, 
nbretdpres integer, 
notemax float, 
notemin float); 

INSERT INTO ETUDIANT VALUES (001, 'HUA', 'Vi-Quang');
INSERT INTO ETUDIANT VALUES (002, 'CHOUEIB', 'Alex');
INSERT INTO ETUDIANT VALUES (003, 'ONDONGI', 'Aristote');
INSERT INTO ETUDIANT VALUES (004, 'HUA', 'Vi-Khanh');
INSERT INTO ETUDIANT VALUES (005, 'LAFARGUE', 'CHRISTOPHE');

INSERT INTO ENSEIGNANT VALUES (101, 'STEPHAN', 'IGOR');
INSERT INTO ENSEIGNANT VALUES (102, 'GENEST', 'DAVID');
INSERT INTO ENSEIGNANT VALUES (103, 'RICHER', 'J-Michel');
INSERT INTO ENSEIGNANT VALUES (104, 'LESSAINT', 'DAVID');
INSERT INTO ENSEIGNANT VALUES (105, 'HUNAULT', 'GILUNO');


INSERT INTO FORMATION VALUES ('L1', 25, 'ANDRE ROSSI');
INSERT INTO FORMATION VALUES ('L2', 15, 'RICHER J-MICHEL');
INSERT INTO FORMATION VALUES ('L3', 30, 'STEPHAN IGOR');

INSERT INTO MATIERE VALUES ('Web', 'L1', 104, 5);
INSERT INTO MATIERE VALUES ('Fondement', 'L1', 101, 3);
INSERT INTO MATIERE VALUES ('BDD', 'L2', 105, 5);
INSERT INTO MATIERE VALUES ('C++', 'L3', 102, 6);
INSERT INTO MATIERE VALUES ('C', 'L3', 102, 4);
INSERT INTO MATIERE VALUES ('Architecture', 'L3', 103, 5);


INSERT INTO TabNOTE VALUES (0001, 'Web', 'L1', 9.0);
INSERT INTO TabNOTE VALUES (0001, 'Fondement', 'L1', 10.0);
INSERT INTO TabNOTE VALUES (0002, 'C++', 'L3', 15.0);
INSERT INTO TabNOTE VALUES (0002, 'C', 'L3', 14.0);
INSERT INTO TabNOTE VALUES (0003, 'Architecture', 'L3', 12.0);
INSERT INTO TabNOTE VALUES (0003, 'C++', 'L3', 11.0);
INSERT INTO TabNOTE VALUES (0004, 'BDD', 'L2', 9.0);
INSERT INTO TabNOTE VALUES (0005, 'Fondement', 'L1', 10.50);
INSERT INTO TabNOTE VALUES (0005, 'Web', 'L1', 12.80);


--2--
CREATE OR REPLACE FUNCTION moyNote()
	returns float as $$
DECLARE	
	sommeNote float = 0.0;
	sommeCoef integer = 0;
	note_moy  CURSOR FOR SELECT TN.note, M.coef from TabNote TN JOIN MATIERE M ON TN.nomform = M.nomform;

BEGIN
	FOR i in note_moy
		LOOP
			sommeNote = sommeNote + (i.note*i.coef);
			sommeCoef = sommeCoef + i.coef;
		END LOOP;

	RETURN sommeNote/sommeCoef;
END;

$$ LANGUAGE plpgsql;

--3--
SELECT nom, prenom, note FROM ETUDIANT E JOIN TabNOTE TN ON E.numet = TN.num_etud
	where TN.note > (SELECT moyNote()); 

--4--
CREATE OR REPLACE FUNCTION Moy_format(formation varchar(10))
	returns float as $$

DECLARE
	sommeNote_for float = 0.0;
	sommeCoef_for integer = 0;
	moy_for CURSOR FOR SELECT * FROM TabNOTE TN JOIN MATIERE M on TN.nommat = M.nommat
			WHERE TN.nomform = formation;
BEGIN
	FOR i in moy_for
		LOOP
			sommeNote_for = sommeNote_for + (i.note*i.coef);
			sommeCoef_for = sommeCoef_for + i.coef;
		END LOOP;
	RETURN sommeNote_for/sommeCoef_for;
END;

$$ LANGUAGE plpgsql;

--5--

CREATE OR REPLACE FUNCTION stat_Form()
	returns VOID AS $$

DECLARE
	nom_forma 		formation.nomform 	%TYPE;
	Max				TabNote.note 		%TYPE;
	MIN				TabNote.note 		%TYPE;
	moy_gen 	float;
	nbrR 		integer ;
	nbrEt 		integer ;


	curFormation	CURSOR FOR SELECT nomform FROM FORMATION;
BEGIN
	FOR i in curFormation
		LOOP
			SELECT MAX(note) INTO MAX from TabNOTE TN where TN.nomform = i.nomform;
			SELECT Min(note) INTO Min from TabNOTE TN where TN.nomform = i.nomform;
			SELECT Moy_format(i.nomform) INTO moy_gen;
			SELECT Count(note) INTO nbrR from TabNOTE where nomform = i.nomform AND note > moy_gen;
			SELECT Count(note) INTO nbrEt from TabNOTE where nomform = i.nomform AND note < moy_gen;

			INSERT INTO STAT_RESULTAT VALUES (i.nomform, moy_gen, nbrR, nbrEt, Max, Min);
		END LOOP;
END;

$$ LANGUAGE plpgsql;

--6--

CREATE OR REPLACE FUNCTION info_etu(n_et integer)
	returns TABLE (nommat varchar, nomform varchar) AS $$

BEGIN
	RETURN QUERY SELECT TN.nommat, TN.nomform FROM TabNOTE TN
				WHERE TN.num_etud = n_et;
END;

$$ LANGUAGE plpgsql;

--7--

--DROP FUNCTION info_ensei(n_ensei integer);
CREATE OR REPLACE FUNCTION info_ensei(n_ensei integer)
	returns TABLE (nomens varchar, prenomens varchar) AS $$

DECLARE
	curs CURSOR FOR SELECT DISTINCT nomform from MATIERE 
			where numens = n_ensei;
BEGIN
	FOR i in curs
	LOOP
		RETURN QUERY 
		SELECT E.nomens, E.prenomens from ENSEIGNANT E JOIN MATIERE M ON E.numens = M.numens 
				where M.nomform = i.nomform AND M.numens != n_ensei;
	END LOOP;
END;

$$ LANGUAGE plpgsql;


--8--


CREATE OR REPLACE FUNCTION Enseig_Etudiant(n_et integer)
	returns table (nomens varchar, prenomens varchar) AS $$

DECLARE
	
BEGIN
	RETURN QUERY
	select E.nomens, E.prenomens from (MATIERE M JOIN TabNOTE TN ON TN.nommat = M.nommat) T 
		JOIN ENSEIGNANT E ON E.numens = T.numens 
			WHERE T.num_etud = n_et;
END;

$$ LANGUAGE plpgsql;

--9--

--DROP TRIGGER desinscription on ETUDIANT IF EXISTS;

CREATE OR REPLACE FUNCTION suppression()
	returns trigger AS $$

BEGIN
	DELETE FROM NOTE WHERE num_etud = OLD.numet;
	RETURN NEW;
END;

$$ LANGUAGE plpgsql;

CREATE TRIGGER desinscription AFTER DELETE ON ETUDIANT FOR EACH ROW EXECUTE PROCEDURE suppression();

--10--
/*
DROP TRIGGER mis_ajour on ETUDIANT IF EXISTS;
DROP TRIGGER mmis_ajour_2 on FORMATION IF EXISTS;
*/
CREATE OR REPLACE FUNCTION maj()
	returns trigger as $$

BEGIN
	SELECT stat_Form();
	RETURN NEW;
END;

$$ LANGUAGE plpgsql;

CREATE TRIGGER mis_ajour AFTER INSERT OR UPDATE OR DELETE on ETUDIANT FOR EACH ROW EXECUTE PROCEDURE maj();
CREATE TRIGGER mis_ajour_2 AFTER INSERT OR UPDATE OR DELETE ON FORMATION FOR EACH ROW EXECUTE PROCEDURE maj();
