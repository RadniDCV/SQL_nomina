DROP FUNCTION "EDV_ERP"."Pro_vMIN";
CREATE FUNCTION "EDV_ERP"."Pro_vMIN"(PLANI varchar(15), PLANICODE varchar(15), Gestion varchar(6)) 
RETURNS 
TABLE (empId nchar(15), Monto decimal(19,2)) 
LANGUAGE SQLSCRIPT AS 	
Param numeric(18,5);  
 BEGIN	 	
 RETURN  
 SELECT 	
 EMP."U_EmpID" as empId, 	
 case when year(OH."termDate") = left(:Gestion,4)  and  month( OH."termDate") = right(:Gestion,2)  then  
		"EDV_ERP"."EncryptPL"( DIA_2.Monto,EMP."U_EmpID")
	 else
	case when OH."U_INDEMDATE" is null 	
	then			
	case when right(:Gestion,2)='02' then "EDV_ERP"."EncryptPL"( DIA.Monto,EMP."U_EmpID")  else "EDV_ERP"."EncryptPL"( DIA.Monto,EMP."U_EmpID") end   		
	else		
	case when right(:Gestion,2)='02' then "EDV_ERP"."EncryptPL"( DIA_1.Monto,EMP."U_EmpID")  else "EDV_ERP"."EncryptPL"( DIA_1.Monto,EMP."U_EmpID")  end	
	end
end
 as Monto FROM "PL_EDV_ERP"."@PL_EMP" EMP  
 inner join (select "empID", "EDV_ERP"."diffdate11"("U_INDEMDATE", (case when right(:Gestion,2)='02' then :Gestion||'28' else :Gestion||'30' end) , 2) Monto from "EDV_ERP"."OHEM" ) DIA_1 on  EMP."U_EmpID" = DIA_1."empID"
 inner join (select "empID", "EDV_ERP"."diffdate11"("startDate", (case when right(:Gestion,2)='02' then :Gestion||'28' else :Gestion||'30' end) , 2) Monto from "EDV_ERP"."OHEM" ) DIA on  EMP."U_EmpID" = DIA."empID" 
 inner join "EDV_ERP"."OHEM" OH on EMP."U_EmpID"=OH."empID" inner join (select empid, Monto from "EDV_ERP"."Pro_xCONC"(:PLANI,'-V-IND',:Gestion))IND on EMP."U_EmpID"=IND.empid	 
 WHERE EMP."U_Cod_PL" =:PLANI
 ORDER BY EMP."U_EmpID";
 END;
