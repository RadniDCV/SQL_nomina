CREATE function "Pro_a_NS_R"(PLANI varchar(15),Gestion varchar(6), CONCEPT nvarchar(8))
RETURNS table 
(
	empId varchar(20),
    Monto decimal(18,5)
)
LANGUAGE SQLSCRIPT AS 
PLANIP varchar(15);
Param1 decimal(18,5);
Param2 decimal(18,5);
AFP nvarchar(4);
v_concept varchar(15);

BEGIN
select (select cast((select (ifnull((SELECT TOP 1 CAST(EXPR."U_Expre" AS nvarchar(10)) FROM "PL_LIDER_PROD"."@PL_EXP" EXPR WHERE EXPR."U_Cod_EXP" = :PLANI || '-P-SMN' AND EXPR."U_Origen" IN (SELECT MAX(EXPR2."U_Origen") FROM "PL_LIDER_PROD"."@PL_EXP" EXPR2 WHERE EXPR2."U_Cod_EXP" = :PLANI || '-P-SMN' AND expr2."U_Origen" <= :GESTION)),'0')) from dummy) as decimal(18,2)) from dummy) into Param1 from dummy;
Param2:= :Param1 * 60;
select (SELECT CASE WHEN :PLANI = 'RM' THEN 'PM' WHEN :PLANI = 'OR' THEN 'OM' ELSE 'XX' END FROM DUMMY) into PLANIP from dummy;
select (SELECT substring("U_Descrip", 1, 3) FROM "PL_LIDER_PROD"."@ADPR" WHERE "U_Entidad" = 'PLConcepto' AND "U_Codigo" = :CONCEPT) into AFP from dummy;
select SUBSTRING(:CONCEPT,3,8) into v_concept from dummy;



RETURN

	SELECT EMP."U_EmpID" as empId--, tpc.Monto , pnsp.Monto , @Param1 , @Param2 , @AFP , @PLANIP 
      ,
      (CASE when IFNULL(PNS.Monto,0)>0-- OR PNSP.Monto>0
      then 0 else 
      case when OHEM."U_CA"=:AFP then "LIDER_PROD"."EncryptPL"
        (round
                (
                CASE    WHEN (TPC_1.Monto+TPC.Monto<13000) then 0 
                        WHEN (TPC_1.Monto+TPC.Monto-13000)>0 then 
						 ((TPC_1.Monto+TPC.Monto-13000)*0.01) - PNS_1.Monto else 0 END        
                ,2)
        , EMP."U_EmpID"
        )
        else 0 end end
       ) as Monto
FROM "PL_LIDER_PROD"."@PL_EMP" EMP 
      inner join (select empid, Monto from "LIDER_PROD"."Pro_xCONC"(:PLANI,'-T-TPC',:GESTION))TPC on EMP."U_EmpID"=TPC.EmpId
	  inner join (select empid, Monto from "LIDER_PROD"."Pro_xCONC"(:PLANIP,'-T-TPC',:GESTION))TPC_1 on EMP."U_EmpID"=TPC_1.EmpId
      inner join (select empid, Monto from "LIDER_PROD"."Pro_xCONC"(:PLANI,'-A-ANS',:GESTION))PNS on EMP."U_EmpID"=PNS.EmpId
	  inner join (select empid, Monto from "LIDER_PROD"."Pro_xCONC"(:PLANIP,'-A-ANS',:GESTION))PNS_1 on EMP."U_EmpID"=PNS_1.EmpId
      inner join OHEM on EMP."U_EmpID"=OHEM."empID"
      WHERE EMP."U_Cod_PL" =:PLANI
ORDER BY EMP."U_EmpID";
end;
