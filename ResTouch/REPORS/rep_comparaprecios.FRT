   �   !                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Courier New                    <    winspool  Adobe PDF  Desktop\*.pdf                                                      PAdobe PDF                        � �S�  �
od   X  X  Letter                                                                            PRIV�                                                                                        '''  '        � �                               0 \K hC                             FF��      � �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       �   SMTJ     � A d o b e   P D F   C o n v e r t e r   Resolution 1200dpi PageSize Letter PageRegion  LeadingEdge  InputSlot OnlyOne                                           0  EBDA                   S t a n d a r d                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                �DRIVER=winspool
DEVICE=Adobe PDF
OUTPUT=Desktop\*.pdf
ORIENTATION=0
PAPERSIZE=1
SCALE=100
ASCII=100
COPIES=1
DEFAULTSOURCE=7
PRINTQUALITY=600
COLOR=2
YRESOLUTION=600
TTOPTION=3
COLLATE=1
                            	proveedor                      Arial                          )"Grupo Culinario - M�dulo de Inventarios"                       Arial                          "Hoja de inventario Fisico"                                     date()                                                        Arial                          Arial                          "SPC - rep_existencia"         descripcion                                                   Arial                          Arial                          "Descripci�n"                  _pageno                                                       Arial                          "##"                           Arial                          "Pag."                         
nombreprov                                                    Arial                          "Iif(sbodega="01",nombreumedida,"")                                                             Arial                          stitulo                                                       Arial                          Arial                          "Fisico"                       Arial                          "Unidad M."                    Courier New                    Arial                          Arial                          Arial                          Arial                          dataenvironment                JLeft = 1
Top = 220
Width = 520
Height = 200
Name = "Dataenvironment"
                      �PROCEDURE OpenTables
close all
use tipo_inventario order tipo_inven in 0
use config in 0

IF sbodega="01"
	Select a.*,b.nombre as nombreprov,c.nombre as nombreumedida from articulo a, proveedor b, umedida c WHERE  a.proveedor=b.proveedor AND a.umedida=c.id AND &quetipo ;
	order by b.nombre,a.tipo_inventario,a.descripcion into cursor mireporte
	sele  mireporte
	set relatio to tipo_inventario into tipo_inventario
else
	Select a.*,b.nombre as nombreprov,c.nombre as nombreumedida from articulo a, proveedor b, umedida c WHERE  a.proveedor=b.proveedor AND a.umedida=c.id AND &quetipo ;
	AND a.newmodel in (select DISTINCT modelo FROM inventariofisico WHERE bodega=sbodega AND fisico>0);
	order by b.nombre,a.tipo_inventario,a.descripcion into cursor mireporte
	sele  mireporte
	set relatio to tipo_inventario into tipo_inventario
ENDIF

IF genexcell=1
	COPY TO &quearchivo TYPE xls
endif
ENDPROC
PROCEDURE CloseTables
close all data
ENDPROC
                     E���    ,  ,                        �o   %   �      �     �          �  U   �) Q�  � tipo_inventario��
 tipo_inven� Q�  � config� %�� � 01��X�� Select a.*,b.nombre as nombreprov,c.nombre as nombreumedida from articulo a, proveedor b, umedida c WHERE  a.proveedor=b.proveedor AND a.umedida=c.id AND &quetipo  order by b.nombre,a.tipo_inventario,a.descripcion into cursor mireporte
 F� � G-(��  ���  � ���RSelect a.*,b.nombre as nombreprov,c.nombre as nombreumedida from articulo a, proveedor b, umedida c WHERE  a.proveedor=b.proveedor AND a.umedida=c.id AND &quetipo  AND a.newmodel in (select DISTINCT modelo FROM inventariofisico WHERE bodega=sbodega AND fisico>0) order by b.nombre,a.tipo_inventario,a.descripcion into cursor mireporte
 F� � G-(��  ���  � � %�� �����  COPY TO &quearchivo TYPE xls
 � U  TIPO_INVENTARIO
 TIPO_INVEN CONFIG SBODEGA	 MIREPORTE	 GENEXCELL  � U  
 OpenTables,     �� CloseTablesx    ��1 Q �!2�q � � #q � A A 2 Q 1                       �        �  �      )   ,                  