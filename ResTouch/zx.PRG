SELECT a.empleado,a.tipo,sum(a.total) as monto,b.nombres,b.identificacion as cedula,0000000000.00 as montotrunc FROM ;
	  tempo_propina a, empleado b, tipo_empleado c where;
	  a.empleado=b.empleado AND b.tipo=c.tipo GROUP BY a.empleado ORDER BY c.orden,b.nombres INTO table LasProp

SELECT lasprop
BROWSE
