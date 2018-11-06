******************************************** inicio de propinas
	FECINI=CTOD("01/11/2008")
	FECFIN=CTOD("19/11/2008")
		** esto deberia ser temporal mientras estamos seguros de que graba bien
		
		CREATE CURSOR tempo_propina (comanda i,tipo i,turno i,empleado i,porcen n(6,2), total n(10,2))
		
		SELECT A.COMANDA,A.TURNO,B.FACTURA,B.FECHA AS FF,A.FECHA AS FC,B.PROPINA,SUM(c.propina) as totprop ;
		FROM COMANDA A, FACTURA B, detalle_forma_pago c ;
		WHERE A.COMANDA=B.COMANDA AND  ;
		a.comanda=c.comanda AND ;
		!B.ANULADA AND ;
		BETWEEN(A.FECHA,fecini,fecfin) ;
		AND A.MODIFICADA<>1;
		GROUP BY a.comanda ;
		ORDER BY A.COMANDA ;
		 INTO CURSOR lacomanda
		 
*		 SET STEP ON
	SCAN
		Xqcomanda=Lacomanda.comanda
		DELETE from detalle_propina WHERE comanda=xqcomanda
			* Calcula total de propina en este pago
		TProp=LaComanda.TotProp
		IF TPROP<>0
				* Construye los empleados del turno
			SELECT a.Mesero,a.Garrotero,b.gerente,b.bar,b.bar2,b.cheff,b.cajero,b.gerente2,a.turno ;
			FROM Comanda a, Turno b ;
			WHERE comanda=xqcomanda AND a.turno=b.turno ;
			INTO CURSOR LosEmp
				* repartamos propinas
			TDP=0
			SELECT * FROM tipo_empleado WHERE porprop>0 INTO CURSOR LosTiposEmp
			SELECT LosTiposEmp
			SCAN
				ElCampo="LosEmp."+ALLTRIM(LosTiposEmp.Descripcion)
				ElPor=LostiposEmp.porprop
				IF ElCampo<>"LosEmp.COCINA" AND Elcampo<>"LosEmp.COCINA2" &&AND Elcampo<>"LosEmp.BAR" para jakes esto si sirve al 22/ene/2009
					INSERT INTO detalle_propina(comanda,turno,tipo,empleado,porcen,total) ;
					VALUES (xqcomanda,losemp.turno,lostiposemp.tipo,&elcampo,elpor,ROUND(TProp*(ElPor/100),2))
					TDP=TDP+ROUND(TProp*(ElPor/100),2)
				ELSE
					DO case
					   case elcampo="LosEmp.COCINA"
						SELECT * FROM empleado WHERE tipo=LosTiposEmp.Tipo AND !baja INTO CURSOR CocinaEmp
						COUNT TO TotCocina 
						PropC=ROUND((TProp*(ElPor/100))/TotCocina,2)
						SELECT CocinaEmp
						SCAN
							INSERT INTO detalle_propina(comanda,turno,tipo,empleado,porcen,total) ;
							VALUES (xqcomanda,losemp.turno,lostiposemp.tipo,CocinaEmp.Empleado,elpor,Propc)
							TDP=TDP+PropC
						ENDSCAN
					  CASE elcampo="LosEmp.COCINA2"
						SELECT * FROM empleado WHERE tipo=LosTiposEmp.Tipo AND !baja INTO CURSOR CocinaEmp
						COUNT TO TotCocina 
						PropC=ROUND((TProp*(ElPor/100))/TotCocina,2)
						SELECT CocinaEmp
						SCAN
							INSERT INTO detalle_propina(comanda,turno,tipo,empleado,porcen,total) ;
							VALUES (xqcomanda,losemp.turno,lostiposemp.tipo,CocinaEmp.Empleado,elpor,Propc)
							TDP=TDP+PropC
						ENDSCAN
*!*						  OTHERWISE
*!*						  	&& En Jakes se dividen los de bar la propina, sin embargo deberia de ser por %
*!*							IF EMPTY(losemp.bar2)
*!*								** solo hay un bartender
*!*								INSERT INTO detalle_propina(comanda,turno,tipo,empleado,porcen,total) ;
*!*								VALUES (xqcomanda,losemp.turno,lostiposemp.tipo,&elcampo,elpor,ROUND(TProp*(ElPor/100),2))
*!*								TDP=TDP+ROUND(TProp*(ElPor/100),2)
*!*							ELSE
*!*								** dos bartenders
*!*								elpor=ROUND(elpor/2,2)
*!*								INSERT INTO detalle_propina(comanda,turno,tipo,empleado,porcen,total) ;
*!*								VALUES (xqcomanda,losemp.turno,lostiposemp.tipo,losemp.bar,elpor,ROUND(TProp*(ElPor/100),2))
*!*								TDP=TDP+ROUND(TProp*(ElPor/100),2)
*!*								INSERT INTO detalle_propina(comanda,turno,tipo,empleado,porcen,total) ;
*!*								VALUES (xqcomanda,losemp.turno,lostiposemp.tipo,losemp.bar2,elpor,ROUND(TProp*(ElPor/100),2))
*!*								TDP=TDP+ROUND(TProp*(ElPor/100),2)
*!*							endif
					ENDCASE
				endif
			ENDSCAN
		 	* ajustar la propina con el gerente por regla
			IF TDP<>Tprop
				LaDif=ABS(TDP-TProp)
				IF Tprop>TDP
					** aumentar en gerente
					UPDATE detalle_propina SET Total=(TOTAL+LaDif) WHERE Comanda=xqcomanda AND Tipo=2
				ELSE
					** disminuir en gerente
					UPDATE detalle_propina SET Total=(TOTAL-LaDif) WHERE Comanda=xqcomanda AND Tipo=2
				ENDIF
			ENDIF
		ENDIF
	ENDSCAN
	
	
	*** AGREGAR LAS QUE MODIFARON DIRECTAMENTE
	
		SELECT A.COMANDA,A.TURNO,A.FECHA AS FC,c.TOTAL as totprop,c.tipo,c.empleado,c.porcen ;
		FROM COMANDA A,  detalle_propina c ;
		WHERE a.comanda=c.comanda AND ;
		BETWEEN(A.FECHA,fecini,fecfin) ;
		AND A.MODIFICADA=1;
		ORDER BY A.COMANDA ;
		 INTO CURSOR lacomanda
		 SCAN
			 INSERT INTO detalle_propina(comanda,turno,tipo,empleado,porcen,total) ;
			VALUES (lacomanda.comanda,lacomanda.turno,lacomanda.tipo,lacomanda.empleado,lacomanda.porcen,lacomanda.totprop)
		 ENDSCAN
	
******************************************** fin de propinas