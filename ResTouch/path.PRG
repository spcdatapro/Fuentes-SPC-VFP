	STORE "C:\SPC\restouch\datos\" TO xpath

	STORE "C:\SPC\restouch\datos\" TO bodpath
  *store "s:\bodega_inv\historico\2004\Datos" to xpath,ppath
  *store "S:\bodega_inv\Datos" to xpath,ppath
  SET PATH TO &Xpath,PRGS, FORMS, LIBS, ;
      MENU, otros, BMPS, REPORS,frmenus, PNG, &bodpath
