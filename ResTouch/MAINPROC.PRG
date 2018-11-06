FUNCTION CALCINI
Param fecini,sbanco
   Select Sum(monto) as debitos from banc03 ;
    where banco=sbanco and tipo$"CB" and fecha<fecini  and status<>"A" ;
    group by banco into cursor micursor
   Store debitos to xdebitos


   Select Sum(monto) as creditos from banc03 ;
    where banco=sbanco and tipo$"DR" and fecha<fecini  and status<>"A" ;
    group by banco into cursor micursor
   Store Creditos to xcreditos
   
   Store Xdebitos-Xcreditos to Calcini
Return Calcini
    
  


FUNCTION SALDOANTCONTA
PARAM Scuenta
 select codigo,sum(debe) as tdebe, sum(haber) as thaber from cont03 ;
  where codigo=scuenta .and. fecha<=fecini ;
  order by codigo group by codigo into cursor saldoant
  store saldoant.debe-saldoant.haber to saldoantconta
ENDFUNC

