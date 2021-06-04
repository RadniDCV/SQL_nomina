DROP FUNCTION "EDV_ERP"."Pro_vMA_";
CREATE FUNCTION "EDV_ERP"."Pro_vMA_"( PLANI varchar(15), PLANICODE varchar(15), Gestion varchar(6), mes int)  
RETURNS
 table  ( 	empId nchar(15), Monto decimal(19,2) ) 
 LANGUAGE SQLSCRIPT AS     
 mesActual varchar(2);     
 anoActual varchar(4);   
 mesAnterior varchar(2);   
 gestionAnterior varchar(6);    
 cod_concepto integer;    
 planilla varchar(2);     
 anoAnterior varchar(4);
 BEGIN  
 select substring(:Gestion,5,6)into mesActual from dummy; select substring(:Gestion,1,4) into anoActual from dummy; 
 select substring(:Gestion,1,4) into anoAnterior from dummy;  
 mes := mes -1;  
 SELECT RIGHT ('00'||TO_NVARCHAR(TO_INTEGER(:mesActual)-:mes),2)into mesAnterior from dummy;  
 if (:mesAnterior =(-1)) 	
 THEN 
 mesAnterior := '11' ;  
 anoAnterior :=    Right('0000'||TO_NVARCHAR(TO_INTEGER (:anoActual) -1),4)   ;	
 else 	if (:mesAnterior=0) 	
 THEN 	mesAnterior := '12' ;  
 anoAnterior := Right('0000'||TO_NVARCHAR(TO_INTEGER (:anoActual) -1),4);	
 end if; 
 end if;  
 if (:mes +1 =3) then cod_concepto:= 1;  
 else   if (:mes +1 =2) then cod_concepto:= 2;  
 else  if (:mes +1 =1)  then  cod_concepto:= 3;  
 end if;  
 end if; 
 end if;  
 SELECT :anoAnterior||:mesAnterior INTO gestionAnterior FROM DUMMY; 
 RETURN 
 SELECT EMP."U_EmpID" AS empId,   
		case when IN_.Monto <>0 then 
			0 
			else 
			"EDV_ERP"."EncryptPL"( 		TPC."MONTO"+TPCR."MONTO"   	,EMP."U_EmpID")  
		end AS Monto 
 FROM "PL_EDV_ERP"."@PL_EMP" EMP  
 inner join (select empid, Monto from "EDV_ERP"."Pro_xCONC"(:PLANI,'-V-ME'||CAST(:cod_concepto AS varchar(1)),:Gestion))IN_ on EMP."U_EmpID"=IN_."EMPID"  
 inner join (select empid, Monto from "EDV_ERP"."Pro_xCONC"(:PLANI,'-T-TPC',:gestionAnterior))TPC on EMP."U_EmpID"=TPC."EMPID"
 inner join (select empid, Monto from "EDV_ERP"."Pro_xCONC"('RM','-T-TPC',:gestionAnterior))TPCR on EMP."U_EmpID"=TPCR."EMPID"
 WHERE EMP."U_Cod_PL" =:PLANI 
 ORDER BY EMP."U_EmpID";   
 END;

