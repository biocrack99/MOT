function inputData=inicializaMOT_Obs()

%Este archivo se usa para configurar la prueba. 
%Importante: Hay que crear una carpeta Datos para grabar
%los datos.

%% Agregado por Anibal de Paul 11/04/2017     

velocidad=[15  15];     % grados/seg
                        
tiempo=[20 20];         % tiempo en seg

numeroPruebas = 2;      %es la cantidad de pruebas que hace en la sesion.

size = 50;              %tama?o en grados depende de la ventana atencional medida al sujeto
                        %54 
                                                
diametro = 2;           %este es el diametro de las pelotitas.

color = [30,180,8];     %cuando los tres numeros son iguales es blanco o gris. Si solamente
                        %pones el primero y los demas 0, la pelotita sera
                        %roja. El segundo la hace verde y el tercero azul.                       l
                        %Puedes jugar con estos numero y ver como te gusta.
                        %Ejemplo: [80,0,200];
                       
colorfondo = [0,128,0]; %Este es el color del fondo. Puede ser negro (0), blanco (255) 
                        %o gris (cualquier numero del 1 al 254). Podrias usar
                        %colores si utilizas un triplete como en color.
                
ViewDist = 1410;         %Distancia de vision en mm




inputData=[numeroPruebas,velocidad,tiempo,size,diametro,color,colorfondo,ViewDist];%,distm,alphamin,falpha];
%fin de script------------------------------------------------------------
