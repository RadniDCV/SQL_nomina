set schema "EDV_ERP";
CREATE function "Pro_iANTR"(PLANI varchar(15), PLANICODE varchar(15), Gestion varchar(6))
RETURNS table 
	(
		empId varchar(20),
    	Monto numeric(18,5)
		
    )
LANGUAGE SQLSCRIPT AS  
PARAM numeric(18,5);
PARAM2 numeric(18,5);
PLANIP varchar(2);
BEGIN
select (SELECT CAST((SELECT IFNULL((SELECT TOP 1 CAST(EXPR."U_Expre" AS nvarchar(10)) FROM "PL_EDV_ERP"."@PL_EXP" EXPR WHERE EXPR."U_Cod_EXP" = :PLANI || '-P-SMN' AND EXPR."U_Origen" IN (SELECT MAX(EXPR2."U_Origen") FROM "PL_EDV_ERP"."@PL_EXP" EXPR2 WHERE EXPR2."U_Cod_EXP" = :PLANI || '-P-SMN')), '0') FROM DUMMY) AS numeric(18,5)) FROM DUMMY) into PARAM from dummy;
select (SELECT CAST((SELECT IFNULL((SELECT TOP 1 CAST(EXPR."U_Expre" AS nvarchar(10)) FROM "PL_EDV_ERP"."@PL_EXP" EXPR WHERE EXPR."U_Cod_EXP" = :PLANI || '-P-TDM' AND EXPR."U_Origen" IN (SELECT MAX(EXPR2."U_Origen") FROM "PL_EDV_ERP"."@PL_EXP" EXPR2 WHERE EXPR2."U_Cod_EXP" = :PLANI || '-P-TDM')), '0') FROM DUMMY) AS numeric(18,5)) FROM DUMMY) into PARAM2 from dummy;
if :PLANI = 'IM' then
		PLANIP := 'PM';
	end if;	
return 
	SELECT EMP."U_EmpID" as empId,
	case when  ANT.Monto <> 0  
	then
		0
	else
		"EncryptPL"((BON.Bono)-ANT2.Monto,EMP."U_EmpID") 
	end as Monto
	FROM "PL_EDV_ERP"."@PL_EMP" EMP inner join 
	--(Select empId,Monto from dbo.Pro_xCONC(@PLANI,'-I-TDT',@Gestion)) TDT on TDT.empId =EMP.U_EmpID inner join
	(Select empId,ifnull(Monto,0) as Monto from "Pro_xCONC"(:PLANIP,'-I-ANT',:Gestion)) ANT2 on ANT2.empId =EMP."U_EmpID" inner join
	(Select empId,ifnull(Monto,0) as Monto from "Pro_xCONC"(:PLANI,'-I-ANT',:Gestion)) ANT on ANT.empId =EMP."U_EmpID" inner join
	(Select empId,ifnull(Monto,0) as Monto from "Pro_xCONC"(:PLANI,'-I-TDT',:Gestion)) TDT on TDT.empId =EMP."U_EmpID" left outer join
	(select empId,ifnull(Bono,0) as Bono from "BONO2"(:PARAM, :Gestion)) BON on BON.empId =EMP."U_EmpID"
	WHERE EMP."U_Cod_PL" =:PLANI ORDER BY EMP."U_EmpID";
	
END;
