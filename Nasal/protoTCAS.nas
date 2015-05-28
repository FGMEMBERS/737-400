# protoTCAS versi贸n 0.85b
#----------------------------------------------
# Written by VaronRojo
# Comments, improvements, every contribution is welcome to sicofonia 4T operamail xXxdotxXx com
# ---------------------------------------------
# HISTORIAL:
#      * Se han a帽adido funciones para c谩lculo matem谩tico simple 0.1
#      * A帽adida propiedad 'order' que indicar谩 al piloto como actuar 0.1
#	    * A帽adida funci贸n 'res_conflict' que dado un conflicto entre dos aviones produce una soluci贸n para este 0.2
# 	    * A帽adida funci贸n 'busqueda' que nos encuentra el avi贸n controlado por un humano m谩s cercano 0.3
#	    * A帽adida funci贸n 'existe_conflicto' que determina si otro avi贸n supone una amenaza real 0.4
#	    * Ahora la funci贸n 'busqueda' toma tanto aviones ai como mp. 0.5
#	    * Modificada funci贸n 'existe_conflicto' y reducci贸n tiempo de refresco 0.6
#	    * Adici贸n de la orden TA 0.7
#	    * Flags para cesar los RA 0.78
#	    * Inhibir por GPWS 0.78
#	    * Adici贸n de variables rangeTAU y vTAU 0.80
#	    * Se ha eliminado c骴igo muerto y arreglado bugs 0.81
#		 * Se han a馻dido sonidos de test para el TCAS 0.81
#		 * Se ha a馻dido sonido "Clear of Conflict" -> Test Satisfactorios 0.81
#		 * 0.82: Se a馻de la inhibici髇 por 9 segundos.
#		 * 0.83: Se a馻den resto de sonidos
#		 * 0.84: Arreglo de bugs.
#		 * 0.85: Se a馻de funci髇 de pruebas. (En desarrollo).		
#
# IDEAS DE MEJORA:
#	    * Se puede hacer la b煤squeda del avi贸n m谩s cercano en radar.nas para mayor eficiencia.
#	    * Emplear variables para guardar datos sobre la amenaza, intentar que sea m谩s preciso de este modo
#		 * El Climb y Descend NOW actuan muy tarde :: Ampliar el margen??
#		 * Se lanzaron RA's contradictorios, se hace necesario inhibir por 9 segundos.
#      * Despu閟 de a馻dir sonidos, el caso para los 'increases' debe contemplar m醩 situaciones.
#		 * A馻dir las inhibiciones de la p醙. 30.		 
#

setprop("/instrumentation/tcas/debug",0);
setprop("/instrumentation/transponder/serviceable",1); #EL TRANSPONDEDOR FUNCIONA inicialmente
setprop("/instrumentation/tcas/order",0); #orden TCAS:0 off, 1 desciende, 2 desciende ahora, 3 asciende, 4 asciende ahora

var riesgo = 0; #0 nulo, 1 trafico , 2 bajo, 3 alto;
var aux = 0;
var ta_flag = 0; #bandera para el TA
var ra_flag = 0; #bandera para el RA
var RA_inh = 0;  #inhibici髇 de 9 segundos tras el RA inicial
var counter = 0; #para contar los 9 segundos

#FUNCION PARA CALCULAR EL VALOR ABSOLUTO DE UN NUMERO 'N'
abs = func(n) {
	if(n < 0) { return -1 * n; }
	return n;
}


#FUNCION QUE CALCULA LA DIFERENCIA ABSOLUTA
dif_rel = func(alt1, alt2) {
	var dif = alt1 - alt2;
	return abs(dif);
}

#FUNCION DE RESOLUCION DEL CONFLICTO: Si mi altura es menor desciendo, si es mayor asciendo.
# 1 desciende, 2 desciende ahora, 3 asciende, 4 asciende ahora, 5 TA (alerta tr谩fico)
#res_conflict = func(alt1, alt2) {
#	if(riesgo == 1)
#	{
#		if(ta_flag == 0) { setprop("/instrumentation/tcas/order",5); }
#	}	
#	elsif(alt1 <= alt2)
#	{
#		if(riesgo == 2) 
#		{ 
#			if(ra_flag == 0) { setprop("/instrumentation/tcas/order",1); }
#		}
#		if(riesgo == 3) { setprop("/instrumentation/tcas/order",2); }			
#	}
#	else
#	{
#		if(riesgo == 2) 
#		{ 
#			if(ra_flag == 0) { setprop("/instrumentation/tcas/order",3); }
#		}		
#		if(riesgo == 3) { setprop("/instrumentation/tcas/order",4); }
#	}
#}

res_conflict = func(alt1, alt2) {
	
	var mi_fpm = getprop("/instrumentation/vertical-speed-indicator/indicated-speed-fpm");
	var tgt_fpm = getprop("/instrumentation/tcas/amenaza-fpm");
	if( tgt_fpm == nil) { tgt_fpm = 0.0; }

	if(RA_inh == 0) #ESTO ES UN RA INICIAL
	{
			print("PRIMER RA LANZADO....");	
			if((mi_fpm < -250.0) and (tgt_fpm > 250.0) and (alt1 > alt2))
			{
				if(ra_flag == 0) { setprop("/instrumentation/tcas/order",7); }    #crossing climb
			}
			elsif((mi_fpm > 250.0) and (tgt_fpm < -250.0) and (alt1 <= alt2))
			{
					if(ra_flag == 0) { setprop("/instrumentation/tcas/order",6); } #crossing descend
			}
			else
			{
					if(ra_flag == 0)
					{ 
						if(alt1 > alt2){setprop("/instrumentation/tcas/order",3);} # climb
						else { setprop("/instrumentation/tcas/order",1); }         # descend
					}
			}	
	}
	else 				 #RA NO INICIAL
	{
		var cur_order = getprop("/instrumentation/tcas/order");
		if(riesgo == 3)
		{
		   setprop("/instrumentation/tcas/order",66);						#dummy prop to get sounds working
			if(alt1 > alt2){setprop("/instrumentation/tcas/order",4);} #CLIMB NOW
			else { setprop("/instrumentation/tcas/order",2); }         # DESCEND NOW
		}
		elsif ((alt1 > alt2) and (mi_fpm > 1500.0) and (tgt_fpm < -1500.0)) #ADJUST VERTICAL SPEED
		{
			setprop("/instrumentation/tcas/order",8);
		}
		elsif ((alt1 < alt2) and (mi_fpm < -1500.0) and (tgt_fpm > 1500.0)) #ADJUST VERTICAL SPEED
		{
			setprop("/instrumentation/tcas/order",8);
		}
		elsif (((cur_order == 3) or (cur_order == 7)) and (mi_fpm > 1500.0) and (tgt_fpm > 1000.0)) #INCREASE CLIMB
		{
			setprop("/instrumentation/tcas/order",10);
		}
		elsif (((cur_order == 1) or (cur_order == 6)) and (mi_fpm < -1500.0) and (tgt_fpm < -1000.0)) #INCREASE DESCEND
		{
			setprop("/instrumentation/tcas/order",11);
		}
		elsif (((cur_order == 1) or (cur_order == 3)) and ((mi_fpm < -1500.0)and(mi_fpm > -4400.0)) or ((mi_fpm > 1500.0)and(mi_fpm < 4400.0))) #Maintain vertical
		{
			setprop("/instrumentation/tcas/order",12);
		}
		elsif (((cur_order == 7) or (cur_order == 6)) and ((mi_fpm < -1500.0)and(mi_fpm > -4400.0)) or ((mi_fpm > 1500.0)and(mi_fpm < 4400.0))) #Maintain cross
		{
			setprop("/instrumentation/tcas/order",13);
		}
		else #MONITOR VERTICAL SPEED
		{
			setprop("/instrumentation/tcas/order",9);
		}
	}
}


#
# TEST DE BUSQUEDA DEL AVION M脕S CERCANO
# El transpondedor debe estar encendido para que el TCAS pueda operar!!!!
# notas: 1 = true
# * Esta 煤ltima versi贸n permite tanto aviones mp como ai
#
var distancia = 50000.0;
busqueda = func {
	var trans = getprop("/instrumentation/transponder/ta-ra");
	if(trans == 1.0)
	{
		mp_crafts = props.globals.getNode("/ai/models").getChildren("multiplayer");		
		for(var i=0;i<size(mp_crafts);i+=1)
		{
			   var en_rango = getprop("/ai/models/multiplayer[" ~ i ~ "]/radar/in-range");
			   if(en_rango == 1)
			   {
				var su_dis = getprop("/ai/models/multiplayer[" ~ i ~ "]/radar/range-nm");
				if(su_dis < distancia)
				{
					distancia = su_dis;
					setprop("/instrumentation/tcas/amenaza-range-nm",distancia);
					var vel = getprop("/ai/models/multiplayer[" ~ i ~ "]/velocities/true-airspeed-kt");
					setprop("/instrumentation/tcas/amenaza-speed-kt",vel);
					var alt = getprop("/ai/models/multiplayer[" ~ i ~ "]/position/altitude-ft");
					setprop("/instrumentation/tcas/amenaza-alt-ft",alt);
				       var fps = getprop("/ai/models/multiplayer[" ~ i ~ "]/velocities/vertical-speed-fps");
					setprop("/instrumentation/tcas/amenaza-fpm", fps / 60);
				}
			   }
		}
		ai_crafts = props.globals.getNode("/ai/models").getChildren("aircraft");
		for(var i=0;i<size(ai_crafts);i+=1)
		{
			   var en_rango = getprop("/ai/models/aircraft[" ~ i ~ "]/radar/in-range");
			   if(en_rango == 1)
			   {
				var su_dis = getprop("/ai/models/aircraft[" ~ i ~ "]/radar/range-nm");
				if(su_dis < distancia)
				{
					distancia = su_dis;
					setprop("/instrumentation/tcas/amenaza-range-nm",distancia);
					var vel = getprop("/ai/models/aircraft[" ~ i ~ "]/velocities/true-airspeed-kt");
					setprop("/instrumentation/tcas/amenaza-speed-kt",vel);
					var alt = getprop("/ai/models/aircraft[" ~ i ~ "]/position/altitude-ft");
					setprop("/instrumentation/tcas/amenaza-alt-ft",alt);
					var fps = getprop("/ai/models/aircraft[" ~ i ~ "]/velocities/vertical-speed-fps");
					setprop("/instrumentation/tcas/amenaza-fpm", fps / 60);
				}
			   }
		}
		
	}
}

#
# FUNCION PARA AVERIGUAR SI UN AVION REPRESENTA UNA AMENAZA DE COLISION
#		
#
existe_conflicto = func {
	var mi_alt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var mi_obj_alt = getprop("/instrumentation/tcas/amenaza-alt-ft");
	var mi_obj_vel = getprop("/instrumentation/tcas/amenaza-speed-kt");
	var mi_obj_fpm = getprop("/instrumentation/tcas/amenaza-fpm");
	if(mi_obj_alt==nil) { mi_obj_alt = 0.0; }
	if(mi_obj_vel==nil) { mi_obj_vel = 0.0; }
	if(mi_obj_fpm==nil) { mi_obj_fpm = 0.0; }
	var dist = getprop("/instrumentation/tcas/amenaza-range-nm");
	if(dist == nil) { dist = -1.0; }

	#Inhibici贸n por GPWS:
	var son_gpws = getprop("/instrumentation/mk-viii/outputs/discretes/audio-on");
	if(son_gpws == 1) 
	{ 
		riesgo = 0; 
	}
	elsif((mi_alt < 500.0) or (mi_obj_fpm > 10000.0)) #ESTO ERA UN 50, LO PONGO A 500
	{
		riesgo = 0;
	}
	#Primero comprobamos que el objetivo est茅 en tierra para descartarlo	
	elsif((mi_obj_alt < 360.0) or (dif_rel(mi_alt,mi_obj_alt) > 1000.0) or (mi_obj_vel < 45.0))
	{
		riesgo = 0;
	}
	elsif((dist < 0.6) and (dif_rel(mi_alt, mi_obj_alt) < 100.0) and (mi_alt > 1000.0)) #COLISION INMINENTE
	{
		riesgo = 3;
		ta_flag = 1;
		ra_flag = 1;
	}
	elsif(mi_alt < 1000.0) # SL = 2
	{
		if(((rTAU < 20.0) and (dif_rel(mi_alt, mi_obj_alt) < 850.0)) or (dist < 0.30))
		{
			riesgo = 1;
		}
		else
		{
			riesgo = 0;
		}				
	}
	elsif((mi_alt > 1000.0) and (mi_alt < 2350.0)) # SL = 3
	{
		if(((rTAU < 15.0) and (dif_rel(mi_alt, mi_obj_alt) < 300.0)) or (dist < 0.20))
		{
			riesgo = 2; 
			ta_flag = 1;
		}
		elsif(((rTAU < 25.0) and (dif_rel(mi_alt, mi_obj_alt) < 850.0)) or (dist < 0.33))
		{
			riesgo = 1;
		}
		else
		{
			riesgo = 0;
		}
	}
	elsif((mi_alt > 2350.0) and (mi_alt < 5000.0)) # SL = 4
	{
		if(((rTAU < 20.0) and (dif_rel(mi_alt, mi_obj_alt) < 300.0)) or (dist < 0.35))
		{
			riesgo = 2; 
			ta_flag = 1;
		}
		elsif(((rTAU < 30.0) and (dif_rel(mi_alt, mi_obj_alt) < 850.0)) or (dist < 0.48))
		{
			riesgo = 1;
		}
		else
		{
			riesgo = 0;
		}
	}
	elsif((mi_alt > 5000.0) and (mi_alt < 10000.0)) # SL = 5
	{
		if(((rTAU < 25.0) and (dif_rel(mi_alt, mi_obj_alt) < 350.0)) or (dist < 0.55))
		{
			riesgo = 2; 
			ta_flag = 1;
		}
		elsif(((rTAU < 40.0) and (dif_rel(mi_alt, mi_obj_alt) < 850.0)) or (dist < 0.75))
		{
			riesgo = 1;
		}
		else
		{
			riesgo = 0;
		}
	}
	elsif((mi_alt > 10000.0) and (mi_alt < 20000.0)) # SL = 6
	{
		if(((rTAU < 30.0) and (dif_rel(mi_alt, mi_obj_alt) < 400.0)) or (dist < 0.80) )
		{
			riesgo = 2;
			ta_flag = 1; 
		}
		elsif(((rTAU < 45.0) and (dif_rel(mi_alt, mi_obj_alt) < 850.0)) or (dist < 1.00))
		{
			riesgo = 1;
		}
		else
		{
			riesgo = 0;
		}
	}
	elsif((mi_alt > 20000.0) and (mi_alt < 42000.0)) # SL = 7
	{
		if(((rTAU < 35.0) and (dif_rel(mi_alt, mi_obj_alt) < 600.0)) or (dist < 1.10))
		{
			riesgo = 2; 
			ta_flag = 1;
		}
		elsif(((rTAU < 48.0) and (dif_rel(mi_alt, mi_obj_alt) < 850.0)) or (dist < 1.30))
		{
			riesgo = 1;
		}
		else
		{
			riesgo = 0;
		}
	}
	elsif(mi_alt > 42000.0) # SL = 7
	{
		if(((rTAU < 35.0) and (dif_rel(mi_alt, mi_obj_alt) < 700.0)) or (dist < 1.10))
		{
			riesgo = 2; 
			ta_flag = 1;
		}
		elsif(((rTAU < 48.0) and (dif_rel(mi_alt, mi_obj_alt) < 1200.0)) or (dist < 1.30))
		{
			riesgo = 1;
		}
		else
		{
			riesgo = 0;
		}
	}
	#print("TAU en riesgo =" ~ rTAU);
	return riesgo;	
}

#
# RANGE TAU
#
var rTAU = 99000.0;
rangeTAU = func {
	var slant_nm = getprop("/instrumentation/tcas/amenaza-range-nm");
	if(cl_speed > 0)
	{
		rTAU = (slant_nm / cl_speed) * 3600;
	}
	else
	{
		rTAU = 99000.0;
	}
	#print("SEGUNDOS PARA EL IMPACTO =" ~ rTAU);
}
#
# CALCULO DE VERTICAL TAU
#
var vtau = 99000.0;
verticalTAU = func {
	var altvtau = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var tgt_alttau = getprop("/instrumentation/tcas/amenaza-alt-ft");
	if(tgt_alttau == nil) { tgt_alttau = 0.0; }
	difvtau = dif_rel(altvtau, tgt_alttau);
	var mi_fpm = getprop("/instrumentation/vertical-speed-indicator/indicated-speed-fpm");
	var tgt_fpm = getprop("/instrumentation/tcas/amenaza-fpm");
	if (tgt_fpm == nil) { tgt_fpm = 0.0 }
	com_speed = math.sqrt((mi_fpm * mi_fpm) + (tgt_fpm * tgt_fpm));
	if (com_speed == 0) { vtau = 99000.0; }
	else
	{
		#print("Diferencia de altitudes " ~ difvtau);
		#print("Velocidad Combinada " ~ com_speed);
		#print("VTAU vale " ~ (difvtau / com_speed) * 60);
		vtau = (difvtau / com_speed) * 60;
	}
}

#
# Velocidad de Aproximaci贸n = closing speed
#
var cl_speed = -5;
var bandera = 0;
var p0 =0;
var p1=0;
velocidad = func {
	var ddelob = getprop("/instrumentation/tcas/amenaza-range-nm");
	if(ddelob == nil) { ddelob = -1; }
	else
	{
		if(bandera == 0)
		{
			p0 = ddelob;
			bandera = 1;
		}
		else
		{
			p1 = ddelob;
			if(p1 < p0 ) # se acercan
			{
				cl_speed = abs(p1 - p0) * 3600;
			}
			else 
			{
				cl_speed = -5;
			}			
			bandera = 0;
		}
	}
}

#
# Funci髇 para alertar a la tripulaci髇 de fallo en el TCAS test
# Notas: Implementaci髇 OK y tests hechos satisfactoriamente.
# Si ta-ra = 69 no funciona el TCAS porque el transpondedor ha fallado
#
setlistener("/instrumentation/transponder/ta-ra", func {
			         funciona = getprop("/instrumentation/transponder/serviceable");
						tarac = getprop("/instrumentation/transponder/ta-ra");
						if((funciona == 0) and (tarac == 1))
						{
							setprop("/instrumentation/transponder/ta-ra",69);
						}
			});


#FUNCION PARA ACTUALIZAR LA INFORMACION
update = func {
#-------------------------------------
#      RESETEAMOS LA DISTANCIA CADA CIERTO TIEMPO POR SI LOS AVIONES SE ALEJAN
	aux += 1;
	if(aux == 5) #pon un 5 aqui nano
	{
		aux = 0;
		distancia = 50000.0;
	}
#-------------------------------------
#	busqueda();
	velocidad();
	rangeTAU();
#	verticalTAU();
	var confli = existe_conflicto();
	if(confli != 0)
	{
	  	#-----------------------------------------------------
	   #9 segundos de inhibici髇. con llamadas de settimer a 1 es 9, con 0.5 a 18
		#ESTA MIERDA ESTA COGIDA CON IMPERDIBLES -> TA ISSUE
		if(confli == 1)
		{
			if(ta_flag == 0) 
			{ 
				setprop("/instrumentation/tcas/order",5);
				print("TA lanzado");
			}
		}	
		elsif( RA_inh == 1)
		{
			counter += 1;
			if (counter == 9) #9 segundos, 18 si pones el timer a 0.5
			{
				var alt_1 = getprop("/instrumentation/altimeter/indicated-altitude-ft");
				var alt_2 = getprop("/instrumentation/tcas/amenaza-alt-ft");		
				res_conflict(alt_1,alt_2);
				counter = 0;
				print("SE HA LANZADO UN RA no inicial!!");
			}
		}
		else
		{
		#-----------------------------------------------------
			var alt_1 = getprop("/instrumentation/altimeter/indicated-altitude-ft");
			var alt_2 = getprop("/instrumentation/tcas/amenaza-alt-ft");		
			res_conflict(alt_1,alt_2);
			RA_inh = 1;
		}
	}
	else #si no hay conflicto no hay orden
	{
			#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			var trans = getprop("/instrumentation/transponder/ta-ra");
			if(trans == 1.0)
			{
					orden_act = getprop("/instrumentation/tcas/order");
					#Si se ha dado un RA (TA vale 5 ojo)
					if((orden_act != 0) and (orden_act != 5)) #CLEAR OF CONFLICT -> MOMENTO PARA RESETEAR EL COUNTER!!
					{
							setprop("/instrumentation/tcas/order",99);
							if(ta_flag == 1) { ta_flag = 0; }
							if(ra_flag == 1) { ra_flag = 0; }
							if(RA_inh == 1) { RA_inh = 0; }
							counter = 0;
					}
					elsif((orden_act == 99) or (orden_act == 5))
					{	
			#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
						#setprop("/instrumentation/tcas/order",0);
						if(ta_flag == 1) { ta_flag = 0; }
						if(ra_flag == 1) { ra_flag = 0; }
						if(RA_inh == 1) { RA_inh = 0; }
						counter = 0;
			#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
					}			
			}
			#~~~~~~~~~~~~
	}
	registerTimer();
}

# EL TIMER PARA LLAMAR CADA TANDA DE 2 frames (0 ser铆a para cada frame (taba en 0.5))
registerTimer = func {
    settimer(update, 1);
}
registerTimer();
