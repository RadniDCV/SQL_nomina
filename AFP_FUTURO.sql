
--Ejemplo 1
CREATE  FUNCTION [dbo].[AFP_FUTURO](@PLA varchar(50),@GEST varchar(10), @OFI varchar(20))
/** PREVISION  FDBV**/
RETURNS @AFP TABLE(
CODIGO				INT, 
CI					VARCHAR(20),
NOMBRE				VARCHAR(150),
NUA					VARCHAR(30),
FECHANAC			DATETIME,
FECHAINIC			DATETIME,
NOVEDAD				VARCHAR(15),
FECHA_NOV			VARCHAR(30),
TOTALGANADO 		DECIMAL(10,2),
DIAST				INT,

-----APORTES LABORALES---
COTIZACION			DECIMAL(10,2), 
COMISIONAFP			DECIMAL(10,2),
RIESGOCOMUN			DECIMAL(10,2),
ALABORALSOL			DECIMAL(10,2),
ANACIONALSOL		DECIMAL(10,2),
AFP					DECIMAL(10,2),
--***************************--

-----APORTES LABORALES---
CNS					DECIMAL(10,2),
PROVIVIENDA			DECIMAL(10,2),
RIESGOPROF			DECIMAL(10,2),
APATRONALSOL		DECIMAL(10,2),
AGUINALDO     		DECIMAL(10,2),
INDEMINIZACION     	DECIMAL(10,2),
--***************************--

JUBILADO		INTEGER,
SUCURSAL		VARCHAR(20))
AS
BEGIN

declare @PLA1 AS VARCHAR(50)
SET @PLA1= @PLA --1(SELECT U_CODIGO FROM PL_LEVCORP.DBO.[@ADPR] WHERE U_ENTIDAD='PLLA' AND U_DESCRIP=@PLA)

insert into @AFP(
CODIGO,
CI,
NOMBRE,
NUA,
FECHANAC,
FECHAINIC,
NOVEDAD,
FECHA_NOV,
TOTALGANADO,
DIAST,
COTIZACION,
COMISIONAFP,
RIESGOCOMUN,
ALABORALSOL,
ANACIONALSOL,
AFP,
CNS,
PROVIVIENDA,
RIESGOPROF,
APATRONALSOL,
AGUINALDO,
INDEMINIZACION,
JUBILADO,
SUCURSAL
)

SELECT  
PL.CODIGO,
PL.CI,
PL.NOMBRE,
PL.NUA,
PL.FECHANAC,
PL.FECHAINIC,
PL.NOVEDAD,
PL.FECHA_NOV,
sum(isnull(PL.ColT1,0)) AS TOTALGANADO,
sum(isnull(PL.ColI2,0)) AS DIAST,
sum(isnull(PL.ColA1,0)) AS COTIZACION,
sum(isnull(PL.ColA2,0)) AS COMISIONAFP,
sum(isnull(PL.ColA3,0)) AS RIESGOCOMUN,
sum(isnull(PL.ColA4,0)) AS ALABORALSOL,
sum(isnull(PL.ColA5,0)) AS ANACIONALSOL,
sum(isnull(PL.ColA6,0)) AS AFP,
sum(isnull(PL.ColR1,0)) AS CNS,
sum(isnull(PL.ColR2,0)) AS PROVIVIENDA,
sum(isnull(PL.ColR3,0)) AS RIESGOPROF,
sum(isnull(PL.ColR4,0)) AS APATRONALSOL,
sum(isnull(PL.ColR5,0)) AS AGUINALDO,
sum(isnull(PL.ColR6,0)) AS INDEMINIZACION,
JUBILADO,
Sucursal 

FROM 

(SELECT  
OH.EMPID AS CODIGO,
OH.GOVID+'  '+isnull(OH.U_extCI,'') as CI,
ISNULL(OH.[lastName],'')+' '+ISNULL(OH.[U_ApMaterno],'')+' '+ ISNULL(OH.[firstName],'')+' '+ ISNULL(OH.[middleName],'') AS NOMBRE,
OH.U_NUA as NUA,
isnull(OH.[birthDate],'') as FECHANAC,
OH.STARTDATE AS FECHAINIC,
case when month(OH.termDate)=right(@gest,2) and year(OH.termDate)=left(@gest,4) then 'Retiro' 
when month(OH.startDate)=right(@gest,2)and year(OH.startDate)=left(@gest,4) then 'Ingreso' end  NOVEDAD,
case when month(OH.termDate)=right(@gest,2) and year(OH.termDate)=left(@gest,4) then Convert(varchar(10), oh.termDate, 103)
when month(OH.startDate)=right(@gest,2)and year(OH.startDate)=left(@gest,4) then Convert(varchar(10), oh.startDate, 103) end FECHA_NOV,

--/*---------------------------------------T O T A L E S-------------------------------------------------------------------------*/
CASE T.U_Cod_Conc WHEN rtrim(@PLA1)+'-T-TPC' THEN [dbo].DecryptPL(T.U_Monto,T.U_Cod_Emp) ELSE 0 END AS ColT1,    /*Total Ganado*/
--***********************************************************************************************************************--

--/*-------------------------------------------------S A L A R I O S-----------------------------------------------------*/
CASE T.U_Cod_Conc WHEN rtrim(@PLA1)+'-I-TDT' THEN [dbo].DecryptPL(T.U_Monto,T.U_Cod_Emp) ELSE 0 END AS ColI2,   /*Total Dias Trabajados*/
--***********************************************************************************************************************--

--/*---------------------------------------A P O R T E S - L A B O R A L E S-----------------------------------------------*/
CASE T.U_Cod_Conc WHEN rtrim(@PLA1)+'-A-BCM' THEN [dbo].DecryptPL(T.U_Monto,T.U_Cod_Emp) ELSE 0 END AS ColA1,   /*BBVA Cotización Mensual (10%)*/
CASE T.U_Cod_Conc WHEN rtrim(@PLA1)+'-A-BLC' THEN [dbo].DecryptPL(T.U_Monto,T.U_Cod_Emp) ELSE 0 END AS ColA2,   /*BBVA Comision AFP (0,5%)*/
CASE T.U_Cod_Conc WHEN rtrim(@PLA1)+'-A-BRC' THEN [dbo].DecryptPL(T.U_Monto,T.U_Cod_Emp) ELSE 0 END AS ColA3,   /*BBVA Riesgo Comun (1,7%)*/
CASE T.U_Cod_Conc WHEN rtrim(@PLA1)+'-A-BLS' THEN [dbo].DecryptPL(T.U_Monto,T.U_Cod_Emp) ELSE 0 END AS ColA4,   /*BBVA Aporte Laboral Solidario (0,5%)*/
CASE T.U_Cod_Conc WHEN rtrim(@PLA1)+'-A-BNS' THEN [dbo].DecryptPL(T.U_Monto,T.U_Cod_Emp) ELSE 0 END AS ColA5,   /*BBVA Aporte Nacional Solidario (>13,000)*/
CASE T.U_Cod_Conc WHEN rtrim(@PLA1)+'-A-BFP' THEN [dbo].DecryptPL(T.U_Monto,T.U_Cod_Emp) ELSE 0 END AS ColA6,   /*BBVA Aporte Fondo de Pensiones*/
--***********************************************************************************************************************--

--/*---------------------------------------A P O R T E S - P A T R O N A L E S-----------------------------------------------*/
CASE T.U_Cod_Conc WHEN rtrim(@PLA1)+'-R-CNS' THEN [dbo].DecryptPL(T.U_Monto,T.U_Cod_Emp) ELSE 0 END AS ColR1,    /*Caja de Salud (10%)*/
CASE T.U_Cod_Conc WHEN rtrim(@PLA1)+'-R-FFN' THEN [dbo].DecryptPL(T.U_Monto,T.U_Cod_Emp) ELSE 0 END AS ColR2,    /*BBVA PRO VIVIENDA (2%)*/
CASE T.U_Cod_Conc WHEN rtrim(@PLA1)+'-R-FPF' THEN [dbo].DecryptPL(T.U_Monto,T.U_Cod_Emp) ELSE 0 END AS ColR3,    /*BBVA Riesgo Profesional (1,71%)*/
CASE T.U_Cod_Conc WHEN rtrim(@PLA1)+'-R-FSO' THEN [dbo].DecryptPL(T.U_Monto,T.U_Cod_Emp) ELSE 0 END AS ColR4,    /*BBVA Aporte Patronal Solidario (3%)*/
CASE T.U_Cod_Conc WHEN rtrim(@PLA1)+'-R-APO' THEN [dbo].DecryptPL(T.U_Monto,T.U_Cod_Emp) ELSE 0 END AS ColR5,    /*Provisión Aguinaldo (8.33%)*/
CASE T.U_Cod_Conc WHEN rtrim(@PLA1)+'-R-API' THEN [dbo].DecryptPL(T.U_Monto,T.U_Cod_Emp) ELSE 0 END AS ColR6,    /*Provisión Indemnizacion (8.33%)*/
--************************************************************************************************************************--

OH.u_juvi AS JUBILADO,
OB.Name AS Sucursal

FROM  [PL_LEVCORP].[dbo].[@PL_TX] T 
left join OHEM OH on T.u_COD_EMP  = OH.empid
left join OHPS OP on OP.posID =OH.position
left join OUDP OD on OD.Code =OH.dept
left join OUBR OB on OB.Code =OH.branch
WHERE T.U_GESTION=@GEST AND T.U_PLANILLA = @PLA1 
--AND OH.U_TypeEmp  like '%'+@OFI+'%'--
AND OB.Code like '%'+@OFI+'%'
 AND OH.U_CA='FDBV'

) AS PL

GROUP BY 
PL.CODIGO,
PL.CI,
PL.NOMBRE,
PL.NUA,
PL.FECHANAC,
PL.FECHAINIC,
PL.NOVEDAD,
PL.FECHA_NOV,
PL.JUBILADO,
PL.Sucursal 

order by PL.NOMBRE

RETURN

END

/*
select * from [dbo].[AFP_FUTURO] ('PM','201509','1') 
*/
