CREATE function "Pro_iSB_R"(PLANI varchar(15), PLANICODE varchar(15), Gestion varchar(10))
RETURNS table 
(
	empId varchar(20),
    Monto numeric(18,5)
)
LANGUAGE SQLSCRIPT AS 
TC numeric(18,2);
--ALTER LOCAL TEMPORARY TABLE #my_local_temp_table (empid varchar(15), HB numeric(18,2), U_Cur varchar(10));
BEGIN
select ifnull((SELECT TOP 1 "Rate" FROM ORTT WHERE upper("Currency") = 'USD' AND "RateDate" = (SELECT DOC."U_Fecha" FROM "PL_LIDER_PROD"."@PLDOC" DOC WHERE DOC."Name" = :PLANICODE)),0) into TC from dummy;
RETURN
	SELECT EMP."U_EmpID" as empId,
		
		(HB."U_HB"- SB.MONTO) as Monto 
	 
	FROM "PL_LIDER_PROD"."@PL_EMP" EMP inner join "PL_LIDER_PROD"."@PLPARD" HB  on EMP."U_EmpID" =HB."U_EmpId" 
	inner join (select empid, Monto from "Pro_xCONC"(:PLANI,'-I-SB',:Gestion))SB on EMP."U_EmpID"=SB.empid
	WHERE EMP."U_Cod_PL" =:PLANI ORDER BY EMP."U_EmpID";
	
END;
