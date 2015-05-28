
#
# FUNCION PARA HACER LAS PRUEBAS
# Cada caso lleva asociado un valor DEBUG
# Genera aviones virtuales volando en dirección opuesta
#
var reset = 1;
var positivo = 1;
feeder = func() {
	var caso = getprop("/instrumentation/tcas/debug");
	if (caso == nil) { caso = 0; }
	
	if (caso == 1)#CODIGO PARA EL PRIMER CASO: frontal más bajo -> DESCEND
	{
		if( reset == 1)
		{
			#inicia variables y reset a 0;
			setprop("/instrumentation/tcas/amenaza-range-nm",15.0);
			setprop("/instrumentation/tcas/amenaza-speed-kt",250.0);
			setprop("/instrumentation/tcas/amenaza-alt-ft",5100.0);
			setprop("/instrumentation/tcas/amenaza-fpm", 0.0);
			reset = 0;
			screen.log.write('Comienza la prueba del PRIMER caso');
		}
		else
		{
			#decremento de variables, recuerda usar valor absoluto.
			diste = getprop("/instrumentation/tcas/amenaza-range-nm");
			if( diste < 0.0) 
			{ 
				positivo = 0; 
				diste = 0.0;
			}
			if(positivo == 1) { diste = diste - 0.13888888888; }
			else { diste = diste + 0.13888888888; } 			
			setprop("/instrumentation/tcas/amenaza-range-nm",diste);		
		}
	}
	elsif (caso == 2)#CODIGO PARA EL SEGUNDO CASO: frontal más alto -> ASCEND
	{
		if( reset == 1)
		{
			#inicia variables y reset a 0;
			setprop("/instrumentation/tcas/amenaza-range-nm",10.0);
			setprop("/instrumentation/tcas/amenaza-speed-kt",250.0);
			setprop("/instrumentation/tcas/amenaza-alt-ft",4900.0);
			setprop("/instrumentation/tcas/amenaza-fpm", 0.0);
			reset = 0;
			screen.log.write('Comienza la prueba del SEGUNDO caso');
		}
		else
		{
			#decremento de variables, recuerda usar valor absoluto.
			diste = getprop("/instrumentation/tcas/amenaza-range-nm");
			if( diste < 0.0) 
			{ 
				positivo = 0; 
				diste = 0.0;
			}
			if(positivo == 1) { diste = diste - 0.13888888888; }
			else { diste = diste + 0.13888888888; } 			
			setprop("/instrumentation/tcas/amenaza-range-nm",diste);		
		}
	}
	elsif (caso == 3)#CODIGO PARA EL TERCER CASO: frontal más alto -> CROSSING DESCEND
	{
		if( reset == 1)
		{
			#inicia variables y reset a 0;
			setprop("/instrumentation/tcas/amenaza-range-nm",7.0);
			setprop("/instrumentation/tcas/amenaza-speed-kt",250.0);
			setprop("/instrumentation/tcas/amenaza-alt-ft",6000.0);
			setprop("/instrumentation/tcas/amenaza-fpm", -1000.0);
			reset = 0;
			screen.log.write('Comienza la prueba del TERCER caso');
		}
		else
		{
			#decremento de variables, recuerda usar valor absoluto.
			diste = getprop("/instrumentation/tcas/amenaza-range-nm");
			alte = getprop("/instrumentation/tcas/amenaza-alt-ft");
			alte = alte - 16.66666666667;
			if( diste < 0.0) 
			{ 
				positivo = 0; 
				diste = 0.0;
			}
			if(positivo == 1) { diste = diste - 0.13888888888; }
			else { diste = diste + 0.13888888888; } 			
			setprop("/instrumentation/tcas/amenaza-range-nm",diste);
			setprop("/instrumentation/tcas/amenaza-alt-ft",alte);		
		}
	}
	elsif (caso == 4)#CODIGO PARA EL CUARTO CASO: frontal más bajo -> CROSSING CLIMB
	{
		if( reset == 1)
		{
			#inicia variables y reset a 0;
			setprop("/instrumentation/tcas/amenaza-range-nm",7.0);
			setprop("/instrumentation/tcas/amenaza-speed-kt",250.0);
			setprop("/instrumentation/tcas/amenaza-alt-ft",6000.0);
			setprop("/instrumentation/tcas/amenaza-fpm", 1000.0);
			reset = 0;
			screen.log.write('Comienza la prueba del TERCER caso');
		}
		else
		{
			#decremento de variables, recuerda usar valor absoluto.
			diste = getprop("/instrumentation/tcas/amenaza-range-nm");
			alte = getprop("/instrumentation/tcas/amenaza-alt-ft");
			alte = alte + 16.66666666667;
			if( diste < 0.0) 
			{ 
				positivo = 0; 
				diste = 0.0;
			}
			if(positivo == 1) { diste = diste - 0.13888888888; }
			else { diste = diste + 0.13888888888; } 			
			setprop("/instrumentation/tcas/amenaza-range-nm",diste);
			setprop("/instrumentation/tcas/amenaza-alt-ft",alte);		
		}
	}

	elsif ( caso == 69 )
	{
	   #CODIGO PARA EL CASO POR DEFECTO
		#RESETEO DE VARIABLES
		reset = 1;
		positivo = 1;
		screen.log.write('SE HA RESETEADO LA FUNCION');
	}
}

testing = func {
   feeder(); 
   settimer(testing,1); #llamada cada segundo
}

testing();