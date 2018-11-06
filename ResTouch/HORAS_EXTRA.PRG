CLOSE ALL

PUBLIC fecini,fecfin
STORE  DATE() TO fecini,fecfin

DO FORM ranfechas

STORE "Periodo del "+TRANSFORM(fecini,"@e")+" al "+TRANSFORM(fecfin,"@e") TO stitulo
SELECT path_nomi FROM config INTO CURSOR minomi
STORE ALLTRIM(minomi.path_nomi) TO xpnomi

XSNOMI02=xpnomi+"\nomi02"
XSHOREMP=xpnomi+"\horas_em"
XSNOMI01=xpnomi+"\nomi01"
XSNOMI08=xpnomi+"\nomi08"
XSNOMI06=xpnomi+"\nomi06"

USE &XSNOMI02 IN 0 ORDER CODIGO
USE &XSHOREMP IN 0
USE &XSNOMI01 IN 0
USE &XSNOMI08 IN 0
USE &XSNOMI06 IN 0

SELECT a.*, b.nombres, c.nombre as nomempre, d.nombre as nomsucur, e.nombre as nomdeptoes ;
FROM horas_em a, nomi02 b, nomi01 c, nomi08 d, nomi06 e ;
WHERE a.codigo=b.codigo AND BETWEEN(a.fecha,fecini,fecfin) ;
AND b.depto=c.codigo and b.sucur=d.codigo and b.deptoesp=e.codigo;
ORDER BY c.codigo, d.codigo, e.codigo, b.nombres,a.fecha INTO CURSOR mishoras

SELECT mishoras
REPORT FORM nomi02r TO PRINTER prev
REPORT FORM nomi02r TO PRINTER prom

CLOSE ALL
