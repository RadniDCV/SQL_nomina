CREATE FUNCTION "NATURA"."Del_iMEP"(PLANI varchar(15), PLANICODE varchar(15), Gestion varchar(6), Tipo int)
RETURNS table 
(
	empId varchar(20),
    Monto decimal(18,5)
)
LANGUAGE SQLSCRIPT AS

	 MEDIDA nvarchar (3);
	 	
	 	BEGIN
	 
	 select case when :Tipo=2 then 'MES'
	 when :Tipo=3 then 'DIA'
	 END into MEDIDA from dummy;
	

 				
	RETURN
	SELECT EMP."U_EmpID" AS empId, "EncryptPL"(
	(CASE WHEN MED."MONTO"<>0 
	THEN 
		0 
	ELSE
	(CASE WHEN :Tipo=2
	THEN
	(CASE WHEN h."DIA"<0 then h."MES" -1 ELSE h."MES"
	END)
	WHEN :Tipo=3
	THEN (CASE WHEN h."DIA"<0 then 30 +h."DIA" ELSE h."DIA" 
	END)
	ELSE 0
	END)
	END),EMP."U_EmpID") 
	   AS Monto
	FROM "PL_NATURA"."@PL_EMP" EMP 
	inner join (
					select 
							i."EMPID", 
							MONTHS_BETWEEN (i."STARTDATE", i."TERMDATE") as MES, 
							DAYS_BETWEEN (
											ADD_MONTHS(i."STARTDATE",
											MONTHS_BETWEEN(i."STARTDATE", 
											i."TERMDATE")
											), i.TermDate) as DIA
								from (
										select 
												"empID" as EMPID, 
												(
													CASE WHEN YEAR("startDate") < LEFT(:gestion,4) THEN 
														LEFT(:gestion,4)||'0101' 
														ELSE 
														"startDate" END
												) AS STARTDATE,
												(
													CASE WHEN YEAR 
														(
															IFNULL (
																		"termDate",
																		LEFT(:gestion,4) || '1231')
																	) = 
															LEFT(:gestion,4) THEN 
														(CASE WHEN 
																	MONTH(
																			IFNULL ("termDate",LEFT(:gestion,4) || '1231')
																			)=12 
																	AND 
																	DAYOFMONTH(IFNULL ("termDate",LEFT(:gestion,4) || '1231')) = 30 THEN 
																		ADD_DAYS(IFNULL ("termDate",LEFT(:gestion,4) || '1231'),1) 
																		ELSE 
																	IFNULL ("termDate",LEFT(:gestion,4) || '1231') END) 
																ELSE
														ADD_DAYS(LEFT(:gestion,4)||'1231', 1) END) AS TERMDATE
	from OHEM) i)H ON H."EMPID" = EMP."U_EmpID" 
	inner join (select empID, Monto from "NATURA"."Pro_xCONC"(:PLANI,'-I-' || :MEDIDA, :gestion))MED on EMP."U_EmpID" = MED."EMPID"
	WHERE EMP."U_Cod_PL" =:PLANI 
	ORDER BY EMP."U_EmpID";

END;



---------------------------------


CREATE FUNCTION "NATURA"."Del_vMEP_S"( PLANI varchar(15), PLANICODE varchar(15), Gestion varchar(6), mes int)
RETURNS table 
(
	empId varchar(20),
    Monto decimal(18,5)
)
LANGUAGE SQLSCRIPT AS
mesActual varchar(2);
anoActual varchar(4);
mesAnterior varchar(2);
gestionAnterior varchar(6);
cod_concepto integer;
planilla varchar(2);
BEGIN

anoActual := substring(:Gestion, 1, 4);
IF :PLANI = 'IS' THEN planilla := 'PS';
----- para determinar que concepto es(I-TG1, I-TG2 o I-TG3) segun el parametro de entrada
END IF;
IF (:mes = 3) THEN cod_concepto := 1;
ELSE 
	IF (:mes = 2) THEN cod_concepto := 2;
	ELSE cod_concepto := 3;
	END IF;
----- para determinar el mes
END IF;
--
IF (:mes = 3) AND :PLANI = 'IS' 
THEN mesAnterior := '10';
ELSE
	 IF (:mes = 2) AND :PLANI = 'IS' 
	 THEN mesAnterior := '11';
		ELSE 
			IF (:mes = 1) AND :PLANI = 'IS' 
			THEN mesAnterior := '12';
			END IF;
		END IF;
	  END IF;


 gestionAnterior := :anoActual||:mesAnterior;

RETURN
SELECT EMP."U_EmpID" AS empId, 
	case when GES1.Monto<>0 then 0 else 
	 "NATURA"."EncryptPL"(TPC."MONTO" ,EMP."U_EmpID") end
	
	 AS Monto
FROM "PL_NATURA"."@PL_EMP" EMP 
	inner join (select empid, Monto from "NATURA"."Pro_xCONC"(:PLANI,'-I-TG'||CAST(:cod_concepto AS varchar(1)),:Gestion))IN_ on EMP."U_EmpID"=IN_."EMPID"
	inner join (select empid, Monto from "NATURA"."Pro_xCONC"(:planilla,'-T-TPC',:gestionAnterior))TPC on EMP."U_EmpID"=TPC."EMPID"
	left join (select empid, Monto from "NATURA"."Pro_xCONC"(:PLANI,'-I-ME'||case when :mes= 3 then '1' when :mes=2 then '2' when :mes=1 then '3' end,:Gestion))GES1 on EMP."U_EmpID"=GES1."EMPID"
	--inner join (select empid, Monto from "jam_xCONC"('PM','T-TPC',:gestionAnterior))TPC on EMP."U_EmpID"=TPC."EMPID"
WHERE EMP."U_Cod_PL" =:PLANI ORDER BY EMP."U_EmpID";
 
END;



---------------------


CREATE FUNCTION "NATURA"."Del_iPRP"(PLANI varchar(15), PLANICODE varchar(15), Gestion varchar(6))
RETURNS table 
(
	empId varchar(20),
    Monto decimal(18,5)
)
LANGUAGE SQLSCRIPT AS
BEGIN
 				
	RETURN
	SELECT EMP."U_EmpID" AS empId, 
	(CASE WHEN PRO."MONTO"<0 
	THEN 
		0 
	ELSE
	(CASE WHEN TG1."MONTO"<> 0 and TG2."MONTO" <> 0 
	THEN
		case  WHEN MES."MONTO" <=3
		then 
		"EncryptPL"((TG2."MONTO"+TG3."MONTO")/2,EMP."U_EmpID") 
		else
		"EncryptPL"((TG1."MONTO"+TG2."MONTO"+TG3."MONTO")/3,EMP."U_EmpID") 
		end
	ELSE 
	(CASE WHEN TG2."MONTO" <> 0 and MES."MONTO" <=3
	THEN
		"EncryptPL"((TG2."MONTO"+TG3."MONTO")/2,EMP."U_EmpID") 
	ELSE
		0 
	END)END)END)   AS Monto
	FROM "PL_NATURA"."@PL_EMP" EMP 
	inner join (select empid, Monto from "NATURA"."Pro_xCONC"(:PLANI,'-I-PRO',:gestion))PRO on EMP."U_EmpID" = PRO."EMPID"
	inner join (select empid, Monto from "NATURA"."Pro_xCONC"(:PLANI,'-I-ME3',:gestion))TG3 on EMP."U_EmpID" = TG3."EMPID"
	inner join (select empid, Monto from "NATURA"."Pro_xCONC"(:PLANI,'-I-ME2',:gestion))TG2 on EMP."U_EmpID" = TG2."EMPID"
	inner join (select empid, Monto from "NATURA"."Pro_xCONC"(:PLANI,'-I-ME1',:gestion))TG1 on EMP."U_EmpID" = TG1."EMPID"
	inner join (select empid, Monto from "NATURA"."Pro_xCONC"(:PLANI,'-I-MES',:gestion))MES on EMP."U_EmpID" = MES."EMPID"
	--inner join "NATURA"."OHEM" OH on EMP."U_EmpID"=OH."empID"
	WHERE EMP."U_Cod_PL" =:PLANI 
	ORDER BY EMP."U_EmpID";

END;

--------------


Create FUNCTION "NATURA"."Del_iPRI"(PLANI varchar(15), PLANICODE varchar(15), Gestion varchar(6))
RETURNS table 
(
	empId nchar(20),
    Monto decimal(19,2)
)
LANGUAGE SQLSCRIPT AS 

BEGIN
RETURN
	SELECT EMP."U_EmpID" as empId, 
			(CASE WHEN AGU.Monto>0 THEN 0 
					ELSE 
				(CASE WHEN ANIO.MONTO =12 THEN "EncryptPL"( (PRO.Monto), EMP."U_EmpID") --ANTIGUEDAD MAYOR A UN AÑO
					ELSE
				(CASE WHEN ((MES.Monto *30) + DIA.Monto)>=90  THEN "EncryptPL"( ((PRO.Monto*MES.MONTO/12) + (PRO.Monto * DIA.Monto/360)) ,EMP."U_EmpID") 
					ELSE
					 0 				
END )
END )
END )
as Monto
FROM "PL_NATURA"."@PL_EMP" EMP 
	inner join (select empid, Monto from "Pro_xCONC"(:PLANI,'-I-MES',:gestion))ANIO on EMP."U_EmpID"=ANIO.EmpId
	inner join (select empid, Monto from "Pro_xCONC"(:PLANI,'-I-MES',:gestion))MES on EMP."U_EmpID"=MES.EmpId
	inner join (select empid, Monto from "Pro_xCONC"(:PLANI,'-I-DIA',:gestion))DIA on EMP."U_EmpID"=DIA.EmpId
	inner join (select empid, Monto from "Pro_xCONC"(:PLANI,'-I-PRI',:gestion))AGU on EMP."U_EmpID"=AGU.EmpId
	inner join (select empid, Monto from "Pro_xCONC"(:PLANI,'-I-PRO',:gestion))PRO on EMP."U_EmpID"=PRO.EmpId
	left join "NATURA"."OHEM" OH on EMP."U_EmpID"=OH."empID"
	
	WHERE EMP."U_Cod_PL" =:PLANI ORDER BY EMP."U_EmpID";
	
END;




