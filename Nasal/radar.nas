#737-400 Radar

update_systems = func {
update_radar();
baro = getprop("/instrumentation/altimeter/setting-inhg");
setprop("/instrumentation/efis/inhg",baro * 100);
setprop("/instrumentation/efis/kpa",baro * 33.8637526);
setprop("/instrumentation/efis/stab",getprop("/controls/flight/elevator-trim") * 15);

if(getprop("/instrumentation/efis/baro-mode")== 0){
setprop("/instrumentation/efis/baro", baro * 100);
}else{
setprop("/instrumentation/efis/baro",baro * 33.8637526);
}
settimer(update_systems,0);
}
settimer(update_systems,0);


# FUNCION PARA ASIGNAR SIMBOLO A UN AVION
# Rombo Vacío = 1; Cualquier aparato
# Rombo Relleno = 2; Cualquier aparato por cuya altitud relativa sea inferior a 1000ft
# Círculo = 3; Cualquier aparato <500 ft y distancia >2nm
# Cuadrado = 4; Cualquier aparato <500 ft y distancia <=2nm
#
#     0 -> avión en tierra  que no será mostrado

# ESTIMATED TIME CALCULATIONS 

update_radar = func{
	true_heading = getprop("/orientation/heading-deg");
	ai_craft = props.globals.getNode("/ai/models").getChildren("aircraft");
	for(i=0; i<size(ai_craft);i=i+1){
		tgt_offset=getprop("/ai/models/aircraft[" ~ i ~ "]/radar/bearing-deg");
		if(tgt_offset == nil){tgt_offset = 0.0;}
		tgt_offset -= true_heading;
		if (tgt_offset < -180){tgt_offset +=360;}
		if (tgt_offset > 180){tgt_offset -=360;}
		setprop("/instrumentation/radar/ai[" ~ i ~ "]/brg-offset",tgt_offset);
		test_dist=getprop("/instrumentation/radar/range");
		test1_dist = getprop("/ai/models/aircraft[" ~ i ~ "]/radar/range-nm");
		if(test1_dist == nil){test1_dist=0.0;}
		norm_dist= (1 / test_dist) * test1_dist;
		setprop("/instrumentation/radar/ai[" ~ i ~ "]/norm-dist", norm_dist);
		#--------------------------------------------------------------------
		# Modificación VaronRojo para añadir propiedades de TCAS
		# Condiciones previas:
		#	* TCAS encendido (ta-ra == 1)
		#	* Posibles valores de símbolo: 1 R, 2 RR, 3 C, 4 cuadrado
		#	* ... Recuerda hallar la diferencia de altura entre ambos.
		#var trans = getprop("/instrumentation/transponder/ta-ra");
		#if(trans == 1.0)
		#{
		#	var mi_alt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		#	var mi_obj_alt = getprop("/ai/models/aircraft[" ~ i ~ "]/position/altitude-ft");
		#	if(mi_obj_alt==nil) { mi_obj_alt = 0.0; }
		#	var par_diff = int((mi_obj_alt - mi_alt) / 100); #diferencia relativa de alturas
		#	var valor = 1; #valor para el simbolo
		#	if((test1_dist <= 2.0) and (abs(par_diff) < 500.0)) #Cuadrado
		#	{
		#		valor = 4;
		#	}
		#	elsif ((test1_dist > 2.0) and (abs(par_diff) > 500.0)) #Circulo
		#	{
		#		valor = 3;
		#	}
		#	elsif (abs(par_diff) > 1000.0)
		##	{
		#		valor = 2;
		#	}
		#	setprop("/instrumentation/radar/ai[" ~ i ~ "]/simbolo",valor);
		#	setprop("/instrumentation/radar/ai[" ~ i ~ "]/diff",par_diff);
		#}		
		#--------------------------------------------------------------------

	}

	mp_craft = props.globals.getNode("/ai/models").getChildren("multiplayer");
	for(i=0; i<size(mp_craft);i=i+1){
		tgt_offset=getprop("/ai/models/multiplayer[" ~ i ~ "]/radar/bearing-deg");
		if(tgt_offset == nil){tgt_offset = 0.0;}
		tgt_offset -= true_heading;
		if (tgt_offset < -180){tgt_offset +=360;}
		if (tgt_offset > 180){tgt_offset -=360;}
		setprop("/instrumentation/radar/mp[" ~ i ~ "]/brg-offset",tgt_offset);
		test_dist=getprop("/instrumentation/radar/range");
		test1_dist = getprop("/ai/models/multiplayer[" ~ i ~ "]/radar/range-nm");
		if(test1_dist == nil){test1_dist=0.0;}
		norm_dist= (1 / test_dist) * test1_dist;
		setprop("/instrumentation/radar/mp[" ~ i ~ "]/norm-dist", norm_dist);

#-------------------------------------------------------------------------------------
		var trans = getprop("/instrumentation/transponder/ta-ra");
		if(trans == 1.0)
		{
		   var vel = getprop("/ai/models/multiplayer[" ~ i ~ "]/velocities/true-airspeed-kt");			
			var mi_alt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
			var mi_obj_alt = getprop("/ai/models/multiplayer[" ~ i ~ "]/position/altitude-ft");
			if(mi_obj_alt==nil) { mi_obj_alt = 0.0; }
			var par_diff = int((mi_obj_alt - mi_alt) / 100); #diferencia relativa de alturas
			var valor = 1; #valor para el simbolo
			if(vel < 50.0) #Suponemos que está en tierra y no lo mostramos
			{
				valor = 0;
			}
			elsif((test1_dist <= 2.0) and (abs(par_diff) < 5.0)) #Cuadrado
			{
				valor = 4;
			}
			elsif ((test1_dist > 2.0) and (abs(par_diff) > 5.0) and (abs(par_diff) < 10.0)) #Circulo
			{
				valor = 3;
			}
			elsif (abs(par_diff) < 10.0)
			{
				valor = 2;
			}
			setprop("/instrumentation/radar/mp[" ~ i ~ "]/simbolo",valor);
			setprop("/instrumentation/radar/mp[" ~ i ~ "]/diff",par_diff);
		}
#-------------------------------------------------------------------------------------
	}
} 

