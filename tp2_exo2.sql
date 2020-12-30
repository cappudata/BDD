--Exercice 2

DROP TABLE IF EXISTS VOL; 
DROP TABLE IF EXISTS PILOTE;
DROP TABLE IF EXISTS AVION ;

CREATE TABLE AVION (
	AvNum 			INTEGER PRIMARY KEY,
	AVNom 			Varchar(30),
	Capacite 		INTEGER,
	Localisation 	Varchar(50)	);

CREATE TABLE PILOTE (
	PiNum 			INTEGER PRIMARY KEY,
	PiNom			Varchar(30),
	PiPrenom		Varchar(30),
	Ville			Varchar(30),
	Salaire			Float);

CREATE TABLE VOL (
	VolNum			Varchar(10) PRIMARY KEY,
	PiNum			INTEGER REFERENCES PILOTE(PiNum),
	AvNum			INTEGER	REFERENCES AVION(AvNum),
	VilleDep		Varchar(30),
	VilleArr		Varchar(30),
	HeureDep		TIME,
	HeureArr		TIME);


INSERT INTO AVION VALUES (1,'A300',200,'France');
INSERT INTO AVION VALUES (2,'A310',100,'VN');
INSERT INTO AVION VALUES (3,'A100',500,'China');
INSERT INTO AVION VALUES (4,'A300',120,'Wakanda');
INSERT INTO AVION VALUES (5,'A100',70,'US');
INSERT INTO AVION VALUES (6,'A110',70,'US');
INSERT INTO AVION VALUES (7,'A100',70,'US');
INSERT INTO AVION VALUES (8,'A310',70,'US');


INSERT INTO PILOTE VALUES (1001,'AG-0','A','France',100);
INSERT INTO PILOTE VALUES (1002,'AG-1','B','USA',500);
INSERT INTO PILOTE VALUES (1003,'AG-2','C','HongKong',120);
INSERT INTO PILOTE VALUES (1004,'AG-3','D','Laos',350);
INSERT INTO PILOTE VALUES (1005,'AG-4','E','Taiwan',600);

INSERT INTO VOL VALUES ('F3501', 1001, 1, 'Paris','HCM','07:00:00', '09:00:00');
INSERT INTO VOL VALUES ('V7891', 1005, 4, 'Hawai','Hanoi','15:00:00', '12:30:00');
INSERT INTO VOL VALUES ('G2501', 1003, 2, 'London','ShangHai','10:10:00','07:00:00');

SELECT VolNum, PiNum, A.AvNum, VilleDep, VilleArr, HeureDep, HeureArr FROM AVION A INNER JOIN VOL V ON A.AvNum = V.AvNum   
	WHERE AVNom = 'A300';

CREATE OR REPLACE FUNCTION reduire()
	RETURNS VOID AS $$

DECLARE
	new_timeDep 		VOl.HeureDep 			%TYPE;
	new_timeArr			VOl.HeureArr			%TYPE;
	Curs1 	CURSOR FOR SELECT HeureDep, HeureArr FROM AVION A INNER JOIN VOL V ON A.AvNum = V.AvNum   
			WHERE AVNom = 'A300';
	Curs2 CURSOR FOR SELECT VolNum, PiNum, A.AvNum, VilleDep, VilleArr, HeureDep, HeureArr FROM AVION A INNER JOIN VOL V ON A.AvNum = V.AvNum   
	WHERE AVNom = 'A310';
BEGIN
	if ( (Curs1 is not null) and (Curs2 is not null) )
		then
			FOR i in Curs1
				LOOP
					new_timeDep = (i.HeureDep * 10) /100;
					new_timeArr = (i.HeureArr * 10) /100;
					UPDATE VOL SET HeureDep = new_timeDep, HeureArr = new_timeArr;
				END LOOP;

			FOR j in Curs2
				LOOP
					new_timeDep = (j.HeureDep * 10)/100;
					new_timeArr = (j.HeureArr * 10)/100;
					UPDATE VOL SET HeureDep = new_timeDep, HeureArr = new_timeArr;
				END LOOP;
	END IF;
END

$$ LANGUAGE plpgsql;

DECLARE

Cur_info CURSOR FOR SELECT VolNum, AvNum, HeureDep, HeureArr FROM VOL 
WHERE ( AvNum = 1 AND AvNum = 2 AND AvNum = 4 AND AvNum = 8);