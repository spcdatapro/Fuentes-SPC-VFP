FUNCTION ACCESO
param sprograma
   if !used("SYS03")
      Use SYS03 In 0 Shared
   endif
   LOCATE FOR (ALLT(SUSUARIO)==ALLT(SYS03.IDUSUARIO)) .AND. UPPER(ALLT(SYS03.IDPROGRAMA))==UPPER(ALLT(SPROGRAMA))
   if found()
      store .f. to acceso && acceso
   else
      store .t. to acceso && no acceso
   endif
   SELE SYS03
   use
return acceso
