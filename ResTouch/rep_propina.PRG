PUBLIC repmes,repanio
CLOSE ALL
USE propina_empleado
USE empleado
USE tipo_empleado

DO FORM pidefecha
SELECT a.mes,a.anio,a.tipoemp,a.empleado,a.propina,b.descripcion,b.tipo;
from propina_empleado a, tipo_empleado b;
WHERE mes=repmes AND anio=repanio AND a.tipoemp=b.tipo;
order BY b.tipo INTO CURSOR LaProp
*BROWSE
DO FORM imprime WITH "rep_propinas"


