%%%Estudio de atencion a multiples objetos moviendose en el campo visual%%%
%%%Funcion pelicula calculo de movimiento de pelotas%%%%%%%%%%%%%%%%%%%%%%% 
%%%Version con movimiento aclerado de uno de los items en un tiempo%%
%%%determinado. Para analizar tiempo de reaccion.

%% FALTA

%definir si sera target o distractor



function [move, time, numframes, crazydots, crazydot_start, crazydot_frames] = pelicula1(Nbloques,Ndots,Xc,Yc, hmin, hmax, vmin, vmax, speed, duration, dotR)


%% Inicializa el movimiento
    %variables  
    %el probema podria estar cuando existan dos duraciones
    %location2draw=zeros(Ndots/2, Ndots); 
    
    location = zeros(2, Ndots);
    
    cell_parameters{1} = [duration(1) speed(2)];
    
    cell_parameters{2} = [duration(2) speed(1)];
    
    %cell_final =  repmat(cell_parameters,1,10);

    cell_final =  repmat(cell_parameters,1,Nbloques);

    time = zeros(1,Nbloques);
    
    move = zeros(Nbloques, max(duration), 2, Ndots);
    
    numframes = max(2*floor((duration*60/3)/2));
    
    %parametros limites de la pantalla    
    
    DX=hmax-hmin;                               
    DY=vmax-vmin;
    
    %vector para almacenar item que se acelera
    crazydots = zeros(1, Nbloques);
    crazydot_start = zeros(1, Nbloques);
    crazydot_frames = zeros(1, Nbloques);
    
    %Inicializar posicion,  velocidad y colisiones
    
    for b = 1: Nbloques
    
    %parametros duracion y velocidad
    vector_parameters = cell_final{b};
    duration = vector_parameters(1);
    duration = duration*60/3;
    duration = 2*floor(duration/2);
    time(b) = duration ;
    
    %cuidado aqui tengo que ver en que unidad esta la velocidad
    %si la velocidad esta en grados/seg
    %speed = round(tan(vector_parameters(2)*pi/180)* distm/pixm*ifi);  
    speed = vector_parameters(2);    
    %inicializo vectores de posicion
    Hpos = zeros(1, Ndots);
    Vpos = zeros(1, Ndots);
    Hspeed = zeros(1, Ndots);
    Vspeed = zeros(1, Ndots);
    angle = zeros(1, Ndots);
    collisionflag = zeros(1, Ndots);
        
    Hpos(Ndots+1) = Xc;
    Vpos(Ndots+1) = Yc;
    
    %% variables para el tiempo de reaccion
    %elijo al alzar que target sera el de velocidad constante
    crazydots(b) = randi([1 8],1,1);
    %flag para el item de velocidad constante
    vc = 0;
    %duracion de la aceleracion del item en segundos
    crazydot_duration = 2 ; 
    %duracion de la aceleracion del item en frames
    %puedo variar aleatoriamente el tiempo que dure la 
    %presentacion del target que se acelera 
    crazydot_frames(b) = max(2*floor((crazydot_duration*60/3)/2));
    %momento en que comienza la aceleracion 
    %va a servir para calcular el tiempo de reaccion
    frame_inf = round(duration/4);
    frame_sup = duration - round(duration/4);
    crazydot_start(b) = randsample(frame_inf:frame_sup, 1);
    
    
    %coordenadas iniciales
    for dot = 1:Ndots
            while 1
                if Hpos(dot) < hmin || Hpos(dot) > hmax || Vpos(dot) < vmin || Vpos(dot) > vmax || collisionflag(dot)
                    
                    switch dot
                        case 1
                            Hpos(dot) = round(rand*DX/4)+hmin;              
                            Vpos(dot) = round(rand*DY/2)+vmin;
                        case 2
                            Hpos(dot) = round(rand*DX/4)+hmin+DX/4;              
                            Vpos(dot) = round(rand*DY/2)+vmin;
                        case 3
                            Hpos(dot) = round(rand*DX/4)+hmin+DX/2;              
                            Vpos(dot) = round(rand*DY/2)+vmin;
                        case 4
                            Hpos(dot) = round(rand*DX/4)+hmin+3*DX/4;              
                            Vpos(dot) = round(rand*DY/2)+vmin;
                        case 5
                            Hpos(dot) = round(rand*DX/4)+hmin;              
                            Vpos(dot) = round(rand*DY/2)+vmin+DY/2;
                        case 6
                            Hpos(dot) = round(rand*DX/4)+hmin+DX/4;
                            Vpos(dot) = round(rand*DY/2)+vmin+DY/2;
                        case 7
                            Hpos(dot) = round(rand*DX/4)+hmin+DX/2;
                            Vpos(dot) = round(rand*DY/2)+vmin+DY/2;
                        otherwise
                            Hpos(dot) = round (rand*DX/4)+hmin+3*DX/4;
                            Vpos(dot) = round (rand*DY/2)+vmin+DY/2;
                    end
                                               
                    for otherdot = 1:Ndots+1
                        if otherdot ~= dot
                            dist = round(sqrt((Hpos(dot)-Hpos(otherdot))^2+(Vpos(dot)-Vpos(otherdot))^2));
                            if dist < (dotR*2)*1.5
                                collisionflag(dot) = 1;
                                collisionflag(otherdot) = 1;
                                break
                            else
                                collisionflag(dot) = 0;
                                collisionflag(otherdot) = 0;
                            end
                        end
                    end
                else
                    break
                end
            end
            angle(dot) = rand*2*pi;
            Hspeed(dot) = round(cos(angle(dot))*speed);
            Vspeed(dot) = round(sin(angle(dot))*speed);
    end
    
%% Cosntantes para la funcion de repulsion
    
        %minima distancia entre entre cada pelota en pixeles   
        mindist = 40;  
        mindist = mindist + 2* dotR;
        %constante de repulsion, afecta la distancia entre pelotas antes de que se
        %comienzen a repeler fuertemente  
        repulsion_constant = 10;                                  
        %angulo de repulsion mientras mas grande este valor, mas fuerte la curva de
        %repuliosion ente las pelotas
        repulsion_angle = pi/12;                                   
        inertia = 500;
        
       
        
        
%% Movimiento

        for f = 1: duration
            
            for dot = 1:Ndots
                
                
                    %% Cambio de direccion repentino 
                    if round(rand*inertia) == 1
                      
                    
                        angle(dot) = rand*2*pi;
                        
                        Hspeed(dot) = round(cos(angle(dot))*speed);
                        
                        Vspeed(dot) = round(sin(angle(dot))*speed);
                    
                    end
                    
                    %if vc ==1 && dot == crazydot
                    
                        %Cuando vc = 1 y el tiem es el target no hace
                        %nada
                    
                    %else
                        
                        
                        for otherdot = 1:(Ndots+1)
                        
                        %Cuando el indice apunta al target no hace
                        %nada para evitar interacciones
                       
                        %if otherdot == crazydot 
                        
                        %else
                            
                            %Cuando el indice apunta a la misma pelota no hace
                            %nada
                            if dot == otherdot
                            
                         
                            
                        else
                            
                            
                            
                            %distancia horizontal
                            dh = Hpos(dot)-Hpos(otherdot);          
                            %distancia vertical
                            dv = Vpos(dot)-Vpos(otherdot);            
                            %Distancia
                            dist = round(sqrt(dh^2+dv^2));            
                        
                        %calcula cuanto de angulo de repulsion tendria que
                        %ser usado para desviar el item
                        %F sera menor que 1 si dist > mindist y solo un
                        %factor del angulo de repulsion sera usado
                        %F sera mayor que o igual a 1 si dist <= mindist y
                        %un repulse_angle mayor sera utilizado
                        F = (dist/mindist)^(-repulsion_constant);
                        
                        %Calcula el angulo para el cual los centros de dos
                        %items estan alineados
                        %si la distancia horizontal es 0, los items están alineados ortogonalmente                           
                        if ~dh %|| ISNAN(dh)
                            
                            lineangle = 0.5*pi;
                        
                        else
                            
                            lineangle = atan(abs(dv/dh));
                        
                        end
                        
                        %tomando en cuenta las posiciones de los items,
                        %calcular en que cuadrante el angulo esta ubicado
                        if dh >= 0 && dv <= 0     % lineangle esta en el 2
                        
                            lineangle = pi - lineangle;
                        
                        elseif dh >= 0 && dv >= 0 % lineangle esta en el 3
                        
                            lineangle = pi + lineangle;
                        
                        elseif dh <= 0 && dv >= 0 % lineangle esta en el 4
                        
                            lineangle = 2*pi-lineangle;
                        
                        else                      % lineangle esta en el 1
                        
                        end
                        
 %% *NOTE: the quadrant system is reversed in matlab, what we know as first quadrant in traditional
 %% math is actually fourth quadrant, second is third, third is second and traditional fourth quadrant is first quadrant
                        
                        % Con la lineangle (angulo en el cual dos items estan alineados) como linea de
                        % base, dividir 4 cuadrantes en sentido horario
                        
                        if lineangle >= 1.5*pi                          % Line Angle esta en el 4
                            I = (lineangle <= angle(dot)) || (angle(dot) <= (lineangle-1.5*pi));
                            II = (lineangle-1.5*pi <= angle(dot)) && (angle(dot) <= lineangle-pi);
                            III = (lineangle-pi <= angle(dot)) && (angle(dot) <= lineangle-0.5*pi);
                            IV = (lineangle-0.5*pi <= angle(dot)) && (angle(dot) <= lineangle);
                        elseif lineangle <= 0.5*pi                      % Line Angle esta en el 1
                            I = (lineangle <= angle(dot)) && (angle(dot) <= lineangle+0.5*pi);
                            II = (lineangle+0.5*pi <= angle(dot)) && (angle(dot) <= lineangle+pi);
                            III = (lineangle+pi <= angle(dot)) && (angle(dot) <= lineangle+1.5*pi);
                            IV = (lineangle+1.5*pi <= angle(dot)) || (angle(dot) <= lineangle);
                        elseif 0.5*pi <= lineangle && lineangle <= pi   % Line Angle esta en el 2
                            I = (lineangle <= angle(dot)) && (angle(dot) <= lineangle+0.5*pi);
                            II = (lineangle+0.5*pi <= angle(dot)) && (angle(dot) <= lineangle+pi);
                            III = (lineangle+pi <= angle(dot)) && (angle(dot) <= lineangle-0.5*pi);
                            IV = (lineangle-0.5*pi <= angle(dot)) && (angle(dot) <= lineangle);
                        else                                            % Line Angle is in third quad
                            I = (lineangle <= angle(dot)) && (angle(dot) <= lineangle+0.5*pi);
                            II = (lineangle+0.5*pi <= angle(dot)) || (angle(dot) <= lineangle-pi);
                            III = (lineangle-pi <= angle(dot)) && (angle(dot) <= lineangle-0.5*pi);
                            IV = (lineangle-0.5*pi <= angle(dot)) && (angle(dot) <= lineangle);
                        end
                        
                        %si el angulo direccional del item esta en I o II
                        %alejar el angulo direccional en sentido horario    
                        if I || II  
                            angle(dot) = angle(dot) + repulsion_angle*F;
                        %si el angulo direccional del item esta en I o II
                        %alejar el angulo direccional en sentido antihorario    
                        elseif IV || III 
                            angle(dot) = angle(dot) - repulsion_angle*F;
                        end
                        %si en algulo es mayor que 2PI, transponer
                            angle(dot) = mod(angle(dot), 2*pi); 
                        end
                        
                                             
                    %end
                    end
                    %end
                    %% calculo velocidad
                
                    Hspeed(dot) = round(cos(angle(dot))*speed);
                
                    Vspeed(dot) = round(sin(angle(dot))*speed);
                         
                    
                    %% Colision de los item con los bordes y reflexion
                   
                    if Hpos(dot) >= hmax && Hspeed(dot) > 0
                    
                        if Vspeed(dot) < 0
                        
                            angle(dot) = angle(dot)-2*(angle(dot)-1.5*pi);
                    
                        elseif Vspeed(dot) > 0
                        
                            angle(dot) = angle(dot)+2*(0.5*pi-angle(dot));
                    
                        else
                            
                            angle(dot) = pi;
                    
                        end
                        
                    elseif Hpos(dot) <= hmin && Hspeed(dot) < 0
                    
                        if Vspeed(dot) > 0
                        
                            angle(dot) = angle(dot)-2*(angle(dot)-0.5*pi);
                    
                        elseif Vspeed(dot) < 0
                        
                            angle(dot) = angle(dot)+2*(1.5*pi-angle(dot));
                    
                        elseif Vspeed(dot) == 0
                        
                            angle(dot) = 0;
                    
                        end
                        
                    end
                    
                    if Vpos(dot) >= vmax && Vspeed(dot) > 0
                    
                        if Hspeed(dot) > 0
                        
                            angle(dot) = 2*pi-angle(dot);
                    
                        elseif Hspeed(dot) < 0
                        
                            angle(dot) = angle(dot) + 2*(pi-angle(dot));
                    
                        else
                            
                            angle(dot) = 1.5*pi;
                    
                        end
                        
                    elseif Vpos(dot) <= vmin && Vspeed(dot) < 0
                    
                        if Hspeed(dot) > 0
                        
                            angle(dot) = angle(dot)+2*(2*pi-angle(dot));
                    
                        elseif Hspeed(dot) < 0
                        
                            angle(dot) = angle(dot) - 2*(angle(dot)-pi);
                    
                        else
                            
                            angle(dot) = 0.5*pi;
                    
                        end
                        
                    end
                
                    %% Calculo velocidad final                     
                        
                    %% Aceleracion constante de uno los items 
                    
                    if f >= crazydot_start(b) && dot == crazydots(b) && f < (crazydot_start(b)+ crazydot_frames(b))
                    
                        if   vc == 0 
                             vc = 1;
                        
                        else vc == 1
                            
                            Hspeed(dot) = Hspeed(dot)+ Hspeed(dot);%aumento misma velocidad
                            Vspeed(dot) = Vspeed(dot)+ Vspeed(dot);%aumento misma velocidad
                        
                        %else
                            
                            %no hacer nada 
                        end
                    
                    end
                    
                    %% Modifico posiciones
                    Hpos(dot) = Hpos(dot) + Hspeed(dot);
                    Vpos(dot) = Vpos(dot) + Vspeed(dot);
                
                    location(1,dot)=Hpos(1,dot);
                    location(2,dot)=Vpos(1,dot);
                    location(3,dot)=Hpos(1,dot);
                    location(4,dot)=Vpos(1,dot);
                    %variable retorno
                    move(b,f,1,:) = location(1,:);
                    move(b,f,2,:) = location(2,:);
            end
        end
    end
end

