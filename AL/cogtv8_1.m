%%%Estudio de atencion a multiples objetos moviendose en el campo visual%%%
%%%Version 8. Incluye repulsion entre las pelotas %%%%%%%%%%%%%%%%%%%%%%%%%
%%%Version con carga cognitiva.%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Se suman distractores con el parametro Ndots%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Incluye Eyetracking
%% Version final
function cogtv8_1()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%Ingresar las iniciales del deportista
  
  obs = inputdlg('Ingrese las iniciales del Participante');
  condition = inputdlg('1: Prueba 2: Evaluacion 3: Entrenamiento','Elegir 1, 2 o 3');
  condition = str2double(condition{1});%-- 8/13/09  9:35 AM --%
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Cargar la imagen para la textura 
% Acordarse de cambiar el directorio segun donde se encuentren las im?genes
% [imageE,map,alpha] = imread('C:\Users\Anibal\Documents\MATLAB\Percepcion Deporte\PLADAR\Naranja.png');
  
  [imageE,~,alpha] = imread('Naranja.png');
  sizeE=size(imageE);
  wEsfera=sizeE(1);
  hEsfera=sizeE(2); 
  imageT=uint8(zeros(wEsfera,hEsfera,4));
  imageT(:,:,1:3)=imageE;
  imageT(:,:,4)=alpha;
  c = clock;
  h = num2str(c(4));
  m = num2str(c(5));
  dia = date;
  diahm = [dia,'-',h,'-',m];
  

%%%% Cantidad de estimulos 
  
  %Numero total de items
  Ndots=12;                    
  
  %Numero de items a seguir
  Ntrack=4;                   
  
  %Cantidad de parpadeos
  np=4;                       
  
  if Ntrack>Ndots, 
        
        Ntrack=Ndots/2;
  
  end
  
%%EYETRACKER
%calibracion_eyetracker;

%%%% Inicializa el modo de presentacion del estimulo
try 

  %Obtengo los valores configuracion del estimulo
  if condition == 1,
              
              idata = inicializaMOTPrueba();
              
  elseif condition  == 2,
              
              idata = inicializaMOTEval();

  else
  
              idata = inicializaMOTTrai();

  end

  %Configuracion del fondo de la pantalla
  if length(idata)>9,
    
              background=idata(1,8:10);
  
  else
  
              background=idata(1,end);
  
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Inicio Psychtoolbox
    %Obtener el numero de pantallas
    Screen('Preference', 'SkipSyncTests', 1);
    screens = Screen('Screens');
    %Para dibujar usamos el maximo numero de screens por si hay un monitor externo 
    %conectado. Si uso min seleciona la pantalla de mi laptop
    screenNumber = max(screens);
    win = Screen('OpenWindow', screenNumber , background,[],32,2);
    Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Priority(MaxPriority(win));
    Screen('Flip', win);
    ifi = Screen('GetFlipInterval', win);

%%%% Coordenadas de la pantalla
%%%% Configuracion parametros de monitor

  %Ancho del monitor en mm
  Xmonitor= 1650;               
    
  %Alto del monitor en mm 
  Ymonitor= 1265;           
  %Area efectiva de la pantalla. Es una proporcion
  sizeP=idata(1,6);                       
  %WindowsSize=1;
  %Tama?o del pixel en mm averiguar la resolucion del monitor
  [Xres, Yres] = Screen('WindowSize', screenNumber); %Xres e Yres es la resolucion en pixeles de la pantalla. La funcion esta sirve para cuando tenes mas de una pantalla
  mmXpix=(Xmonitor/Xres + Ymonitor/Yres)*0.5;         
  %Valores medidos sobre la pantalla
  %degXpix(1) = vertical
  %degXpix(2) = horizontal
  %degXpix(3) = oblicuo
  degXpix = [0.058 0.055 0.053] ;
  %calcula las coordenas del centro de la pantalla
  [Xc,  Yc] = RectCenter(Screen(0,'Rect')); 


%%%% Datos de inicializacion del estimulo

  Nbloques = idata(1,1);
  speed= idata(1,2:3);          %grados/seg
  duration=idata(1,4:5);        %seg   
  Dia= idata(1,7) ;             %grados
  color = idata(1,8:10);
  ViewDist= idata(1,14);        %mm
  ordenAcierto=zeros(Nbloques,Ntrack);

  %inicio pantalla
  credits(win);
  WaitSecs(2);
  Screen('Flip', win);
  WaitSecs(1);
 
  %creo textura a partir de la imagen cargada
  textureE=Screen('MakeTexture', win, imageT); 
  %i=0;
  

%%%% Agregado por Anibal de Paul 6/09/2017
% En el entrenamiento planteado duration y speed son vectores de dos elementos
% Tengo que calcular la velocidad angular segun la distancia y el tama?o
% del monitor a utilizar

  %se inicia la presentacion del est?mulo
  orden=ones(1,8);
  %location2draw=zeros(Ndots/2, Ndots);
  %location = zeros(Ndots/2, Ndots); 
  
  location2draw=zeros(Ntrack, Ndots);
  location = zeros(Ntrack, Ndots); 
  
  
  trackdim = [sizeP sizeP];
  trackdim = round(tan(trackdim*pi/180)*ViewDist/mmXpix);
  
  trackdim = [sizeP/degXpix(2) sizeP/degXpix(1)];
  
  
  %tamano de la pantala en pixeles
  %displaydim = round(tan([Xres, Yres]*pi/180)*ViewDist/mmXpix);
 
  
  if trackdim(1) > Xres
      
      trackdim(1) = Xres;
  
  end
  
  if trackdim(2) > Yres
      
      trackdim(2) = Yres;
  
  end
  
  %tama?o de la pelota en pixeles
  %dotsize = round(tan(Dia*pi/180)*ViewDist/mmXpix);
  dotsize = Dia/degXpix(1);
  dotR = round(dotsize/2);
  
  %velocidad en pixeles por cuadros
  %
  speed = [round(speed(1)/degXpix(1)*ifi) round(speed(2)/degXpix(1)*ifi)];
  
  % Limites de la pantalla
  T = round(0.5*(Yres-trackdim(2)));
  B = round(0.5*(Yres+trackdim(2)));
  L = round(0.5*(Xres-trackdim(1)));
  R = round(0.5*(Xres+trackdim(1)));

  bgrect = [L T R B];

  hmin = L + (dotR + 1);
  hmax = R - (dotR + 1);
  vmin = T + (dotR + 1);
  vmax = B - (dotR + 1);
  
  DX=hmax-hmin;                               
  
  DY=vmax-vmin;
  
  %matrices para guardar las coordenadas de las pelotas
  
  data = struct([]);
  
  move = zeros(Nbloques, duration, 2, Ndots);
%% ESTRUCTURA DATOS

  %Estructura para manipular y guardar los datos
  estructura_datos (1:Nbloques) = struct('ordenAcierto',[], 'R', ...
    [], 'idata', [],  'coordenadas', [], ...
     'XGaze_mm', [], 'YGaze_mm', []); 
  
  %calculo el moviento total de los items   
  [coordenadas, ~, cc] = pelicula(Nbloques, Ndots, Xc, Yc, hmin, hmax, vmin, vmax, speed, duration, dotR);

  j = 0;
    
  %% Eyetracking    
  %Track lo que dure la presentacion de las pistas y los targets
  %limpio el buffer
  %Declara las constantes del sistema
  global CRS;
  if isempty(CRS); crsLoadConstants; end;

  %Seteo el dispostivo del estimulo a Dual-VGA, dos monitores
  %Chequear si seria una mejor opcion CRS.deUser
  vetSetStimulusDevice(CRS.deVGA);

  %Seleciona una fuente de video a video source
  errorCode = vetSelectVideoSource(CRS.vsUserSelect);
  if(errorCode<0); error('Video Source not selected.');
  end;

  %Crea un display que muestra en vivo los ojos del sujeto para poder
  %posicionar la camara adecuadamente
  vetCreateCameraScreen;
  
  HideCursor;
  descanso = 1;
  negro = BlackIndex(screenNumber); 
%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------
 
  for b=1:Nbloques
        
    j=j+1;
  
      
%%%% Inicializa el movimiento
    %Descanso
    if b == descanso*50
        DrawFormattedText(win, 'Unos segundos de descanso...', 'center', 'center', negro);
        Screen('Flip', win);
        java.lang.Thread.sleep(30000)
        DrawFormattedText(win, 'Presionar Cualquier Tecla para Comenzar', 'center', 'center', negro);
        Screen('Flip', win);
        descanso = descanso +1;
        KbStrokeWait;
        
    end
     
    
    %define los targets con parpadeo
    ind=randperm(Ndots);
    
    
    
    for k = 1:Ndots
      
      location2draw(1,k)= coordenadas (b,1,1,k) - dotR;
      location2draw(2,k)= coordenadas (b,1,2,k) - dotR;
      location2draw(3,k)= coordenadas (b,1,1,k) + dotR;
      location2draw(4,k)= coordenadas (b,1,2,k) + dotR;
      
      location(1,k)=coordenadas (b,1,1,k);
      location(2,k)=coordenadas (b,1,2,k);
      location(3,k)=coordenadas (b,1,1,k);
      location(4,k)=coordenadas (b,1,2,k);  
    
    
    end
   
%%%% Presenta en la pantalla los objetivos y los distractores      
    
    for p=1:np

        for f=1:30

            Screen('DrawTextures', win, textureE,[0 0 hEsfera wEsfera], location2draw(:,ind(1:Ntrack)));
            %Screen('FillOval', win, 125 , location2draw(:,ind(1:Ntrack)));
            Screen('Flip',win);
             
        end

        
    end

%%%% Inicia la presentacion
    
    %Tecla para salir del loop
    escapeKey = KbName('esc');
    %transparencia
    trans = 0;
    
    %Tracking
    vetClearDataBuffer;
    %comienzo a grabar
    vetStartTracking;
    
    for f = 2 : cc
           
            [~,~, keyCode] = KbCheck;
        
        if keyCode(escapeKey)
        
              ShowCursor;
    
              sca;
            
        end
        
        %sentencia para evitar mostrar los frames que son iguals a 0
        if (sum(coordenadas(b,f,1,:))== 0  && sum(coordenadas(b,f,2,:))== 0)
            
            
            break;
            
        
        end
        
        %transparencia
        if trans == 1
        
              continue;
  
        else
            
            trans = trans + 1/30;
        
        end
        
        if f == 1
        
            continue;
        
        else
            for k = 1:Ndots
      
            location2draw(1,k)= coordenadas (b,f,1,k) - dotR;
            location2draw(2,k)= coordenadas (b,f,2,k) - dotR;
            location2draw(3,k)= coordenadas (b,f,1,k) + dotR;
            location2draw(4,k)= coordenadas (b,f,2,k) + dotR;
            
            location(1,k)=coordenadas (b,f,1,k);
            location(2,k)=coordenadas (b,f,2,k);
            location(3,k)=coordenadas (b,f,1,k);
            location(4,k)=coordenadas (b,f,2,k);  
            
      
            end
            
        end      
            
            %Objetivos
            Screen('DrawTextures', win, textureE, [0 0 hEsfera wEsfera], location2draw(:,ind(1:Ntrack)));
            %Distractores
            Screen('DrawTextures', win, textureE,[0 0 hEsfera wEsfera], location2draw(:,ind(Ntrack:Ndots)),[],[], trans);
            %% CENTROIDE
            
            %%Centro de masas de los targets
%             x_balls = [location(1,ind(1)), location(1,ind(2)), location(1,ind(3)), location(1,ind(4))] ;
%             y_balls = [location(2,ind(1)), location(2,ind(2)), location(2,ind(3)), location(2,ind(4))] ;
%             cx = mean(x_balls);
%             cy = mean(y_balls);
%             a = atan2(y_balls - cy, x_balls - cx);
%             [~, order] = sort(a);
%             x_balls = x_balls(order);
%             y_balls = y_balls(order);
%             [geom, ~, ~] = polygeom( x_balls, y_balls );
%             x_centroide = geom(2);
%             y_centroide = geom(3);           
%             x_coordenadas(1:4,f) = x_balls; 
%             y_coordenadas(1:4,f) = y_balls;
%             centroide(1:2, f) = [x_centroide y_centroide];
%             %%Cruz de fijacion en centroide
%             %Set el tama?o de la cruz de fijacion. 
%             fixCrossDimPix = 10;
%             %Configurar las coordenadas de la cruz (relativas al centroide 
%             %en el centro del monitor).
%             xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
%             yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
%             allCoords = [xCoords; yCoords];
%             %Tama?o del ancho de las lineas de la cruz.
%             lineWidthPix = 2;
            %dibuja el centroide
            %Screen('DrawLines', win, allCoords, lineWidthPix, 0, [abs(x_centroide) abs(y_centroide)]);
            %% FIN CENTROIDE
            Screen('Flip',win);

           
            framesSinceLastWait = Screen('WaitBlanking', win, 2);
                  
           
                
    end
    
  %dejar de grabar
  vetStopTracking;
  %recuperar los datos del lugar de  fijacion  the recorded eye positions
  remove = false;
  eye_track_data = vetGetBufferedEyePositions(remove);    
  
  ShowCursor('Arrow');
  %Screen ('Close', win);
  acierto=0;
  %ubicacion = zeros(4,4);
  l1=zeros(4,4);
  l2=zeros(4,4);

  %Respuesta del observador

  for d=1:Ntrack 
    
    %toma el click para la respuesta
    [~,~,~,xi,yi]=SubjectResp(win);
        
        for dt=1:Ntrack
            if xi>floor(location(1,ind(dt))- dotR + Xres) && xi<ceil(location(3,ind(dt))+ dotR + Xres) && yi>floor(location(2,ind(dt))-dotR) && yi<ceil(location(4,ind(dt))+dotR)%controla si apunto al correcto
                  
                acierto=acierto+1;
                ordenAcierto(b,d)=1;
                Screen('DrawTextures',win, textureE, [0 0 hEsfera wEsfera], location2draw);
                xdi=location(1,ind(dt))-dotsize/4;
                ydi=location(2,ind(dt))-dotsize/4;
                xdf=location(3,ind(dt))+dotsize/4;
                ydf=location(4,ind(dt))+dotsize/4;
                l1(d,:)=[xdi,ydi,xdf,ydf];
                l2(d,:)=[xdf,ydf,xdf+2*(xdf-xdi),ydi-(ydf-ydi)];
                for g=1:d
                    Screen('DrawLine', win,[0 0 0],l1(g,1),l1(g,2),l1(g,3),l1(g,4),2);
                    Screen('DrawLine', win,[0 0 0],l2(g,1),l2(g,2),l2(g,3),l2(g,4),2);
                end
                
                Screen('Flip',win);
            end
        end
  end

  WaitSecs(1);
  
  Screen('Flip',win); 
  
  R(j)=acierto;
  
  HideCursor;
  
  %Estructura para guardar los datos 
  estructura_datos(b).ordenAcierto = ordenAcierto(b,d);
  estructura_datos(b).R = R(j);
  estructura_datos(b).coordenadas = coordenadas (b,:,:,:);
  estructura_datos(b).XGaze_mm = eye_track_data.mmPositions(:,1);
  estructura_datos(b).YGaze_mm = eye_track_data.mmPositions(:,2);
  estructura_datos(b).idata = idata(1,:);                                          
               
         
            
  end

  Screen('Flip',win);

  R=100*R./Ntrack;

  Rm=sum(R)/j;
  
  showRes(win,Rm);
  WaitSecs(2);
   %Screen('Close',win)
   %ShowCursor;
  
  %save('coordenadas','x_coordenadas', 'y_coordenadas', 'centroide');  
  %se guardan los datos de respuesta en un matriz, en la direccion indicada
  %Verifica si el directorio Datos esta creado, si no lo crea
  directorio = pwd; 
  d_datos = fullfile(directorio, 'Datos', dia);

  if ~exist(d_datos, 'dir')

    mkdir(d_datos)

  end
  
  
  if condition == 1
      
      filename = strcat(obs{1},'_Prueba','_',diahm, '.mat');
      %filename = fullfile(d_datos , dia, filename); 
      filename = fullfile(d_datos, filename); 
      
      %save(filename, 'ordenAcierto','R','Rm','idata', 'coordenadas', 'centroide');
      save(filename, 'estructura_datos');
  
  
  elseif condition == 2
    
      filename = strcat(obs{1},'_Evaluacion','_',diahm, '.mat');
      filename = fullfile(d_datos , filename); 
      %save(filename, 'ordenAcierto','R','Rm','idata', 'coordenadas', 'centroide');
      save(filename, 'estructura_datos');
      
  elseif condition == 3
      
      filename = strcat(obs{1},'_Entrenamiento','_',diahm, '.mat');
      filename = fullfile(d_datos ,filename); 
      %save(filename, 'ordenAcierto','R','Rm','idata', 'coordenadas', 'centroide');
      save(filename, 'estructura_datos');
  end

  %Despejo el display de la camara 
  vetDestroyCameraScreen;   
  %Screen('Close',win)
  %ShowCursor;
  Priority(0);

  sca;

catch
    
    Priority(0);
    
    ShowCursor
    
    sca;
    
    rethrow(lasterror);  
end


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function credits(w)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Funci?n Cr?ditos
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('TextFont',w, 'Courier New');
Screen('TextSize',w, 40);
Screen('TextStyle', w, 1);
Screen('DrawText', w, 'multiple-object-tracking',120, 190, [0, 0, 255, 255]);
Screen('TextFont',w, 'Times');
Screen('TextSize',w, 14);
Screen('DrawText', w, 'ILAV (CONICET-UNT)', 120, 280, [255, 0, 0, 255]);
Screen('Flip',w);
end
function showRes(w,R)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Funci?n Muestra Respuesta
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Rstr = num2str(R);
msje = ['Aciertos promedio = ',Rstr];
Screen('TextFont',w, 'Times');
Screen('TextSize',w, 18);
Screen('DrawText', w, msje, 390, 300, [255, 0, 0, 255]);
Screen('TextSize',w, 12);
Screen('DrawText', w, 'ILAV (CONICET - UNT)', 10, 750, [255, 0, 0, 255]);

Screen('Flip',w);

end

function [Resp,esc,keyCode,x,y]=SubjectResp(windows)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Funcion Presionar Botones
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

esc=0;
[x,y,bot] = GetMouse(windows);
while any(bot) %Wait for release buttons
    [x,y,bot] = GetMouse(windows);
end
escKey = KbName('esc');
[~, ~, keyCode] = KbCheck;
    while ~any(bot) && ~keyCode(escKey) % wait for press or for esc key
        [~, ~, keyCode] = KbCheck;
        if keyCode(escKey), esc=1; end
        [x,y,bot] = GetMouse;
    end
    if bot(1), Resp = 'First ';
      elseif bot(3), Resp= 'Second';
      else Resp = 'Otr   ';
    end
end

