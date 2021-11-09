function inputData=inicializaMOT_Obs()

%Este archivo se usa para configurar la prueba. 
%Importante: Hay que crear una carpeta Datos para grabar
%los datos.

%% Agregado por Anibal de Paul 11/04/2017     
%velocidad=[8  12];      %velocidades en pixels que corresponde a 25.5 y 16.8 c/� segun la resolucion 
                        % que vamos a manejar en el gimnasio distancia y
velocidad=[3  3];                          % tama�o de pixel
tiempo=[6 8];          % tiempo en seg
%%
numeroPruebas = 20;      %es la cantidad de pruebas que hace en la sesion.
size=0.85;
diametro = 35;          %este es el diametro de las pelotitas.
color = [30,180,8];     %cuando los tres numeros son iguales es blanco o gris. Si solamente
                        %pones el primero y los demas 0, la pelotita sera
                        %roja. El segundo la hace verde y el tercero azul.                       l
                        %Puedes jugar con estos numero y ver como te gusta.
                        %Ejemplo: [80,0,200];
                       
colorfondo = [0,128,0]; %Este es el color del fondo. Puede ser negro (0), blanco (255) 
                        %o gris (cualquier numero del 1 al 254). Podrias usar
                        %colores si utilizas un triplete como en color.
                
ViewDist = 2;           %Distancia de vision en metros

distm = 30;             %Distancia media en metros

%%
%Se usa para la version 3D
disparity = 0;          %determina si habra disparidad o no. Si es cero, no hay disparidad
alphamin = 20;          %Disparidad minima. Es la que se usa para el estimulo mas cercano
falpha = 1.3;           %factor de disparidad. alphap = alphamin+falpha*z; la disparidad varia linealmente
                        %con la distancia entre items z
if disparity~=0, disparity=1; end 
alphamin=alphamin*disparity;
falpha=falpha*disparity;
%%
inputData=[numeroPruebas,velocidad,tiempo,size,diametro,color,colorfondo,ViewDist,distm,alphamin,falpha];
%fin de script------------------------------------------------------------
