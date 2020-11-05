centHombroVerde2=[];
centMunecaRojo2=[];
centMunecaAzul=[];
centPechoAmarillo =[];

CHombro2=[];
CPecho=[];
CMunecaR2=[];
CMunecaA=[];

AHombroYawFinal=[];
ACodoRollFinal=[];

%Video plano sagital
v = VideoReader('JarraVideo22.mp4'); %Cargamos el video

%Video plano frontal

for i=1:v.numFrames
video=read(v,i);%Nos da los fotogramas del video uno a uno
    
imR=(video(:,:,1));%Matriz del primer componenete RGB (rojo)
imG=(video(:,:,2));%Matriz del segundo componente RGB (verde)
imB=(video(:,:,3));%Matriz del tercer componente RGB (azul)

%%%%%%%%%%%%%%DETECCIONES DE MARCADORES%%%%%%%%%%%%%%
%Para captar el marcador lo haremos por umbralización --> si los pixeles
%cumplen las condiciones que ponemos se podrán en 1 y sino se pondra en 0

%Imagen binaria de cada marcador
marcador1 =video(:,:,1).*0; %1º marcador hace referencia al marcador de color verde hombro
marcador1(imR>110 & imR<134 & imG>210 & imG<255 & imB>90 & imB<130)=1;

marcador2= video(:,:,1).*0 ; %2º marcador hace referencia al marcador de color rojo muñeca
marcador2(imR>141 & imR<191 & imG>9 & imG<57 & imB>12 & imB<60)=1;

marcador3= video(:,:,1).*0;%3º marcador hace referencia al marcador de color azul muñeca
marcador3(imR>0 & imR<19 & imG>46 & imG<75 & imB>121 & imB<193)=1;

marcador4 =video(:,:,1).*0;%4º marcador hace referencia al marcador de color amarillo pecho
marcador4(imR>195 & imR<255 & imG>141 & imG<213 & imB>15 & imB<101)=1;

%*****************************************
%Mejoras en la imagen con diferentes funciones
%*****************************************

%Elimina los objetos cuyo número de píxeles sea <5
imgFilled1 = bwareaopen (marcador1,5);% siendo 5 el numero de pixeles que quiero eliminar por cada marcador
imgFilled2 = bwareaopen (marcador2,5);
imgFilled3 = bwareaopen (marcador3,5);
imgFilled4 = bwareaopen (marcador4,5);

% Detección de objetos por cada marcador: 
[L1,Ne1] = bwlabel(imgFilled1);
[L2,Ne2] = bwlabel(imgFilled2);
[L3,Ne3] = bwlabel(imgFilled3);
[L4,Ne4] = bwlabel(imgFilled4);

%Calculo de propiedades de los objetos para calcular luego el centroide de
%cada marcador
propied1=regionprops(L1);
propied2=regionprops(L2);
propied3=regionprops(L3);
propied4=regionprops(L4);

%Calculo de centroides (Hombro, Muneca y Pecho)

% Si no detecta un marcador, coge el valor del centroide anterior
if (isempty(propied1) && size(CHombro2,1)>0)
    centHombroVerde2=CHombro2(size(CHombro2,1),:);
else
    centHombroVerde2=propied1.Centroid;
end
CHombro2 = [CHombro2;centHombroVerde2];

% Si no detecta el marcador rojo, detecta el azul
% Calculamos ángulo de pronosupinación del codo según lo
% anterior (marcador rojo = 90º ; marcador azul = 0º)
if (isempty(propied3))
centMunecaRojo2=propied2.Centroid;
angRC = 90;
else
centMunecaAzul=propied3.Centroid;
angRC = 0;
end

CMunecaR2=[CMunecaR2;centMunecaRojo2];
CMunecaA=[CMunecaA;centMunecaAzul];
ACodoRollFinal=[ACodoRollFinal,angRC];

if (isempty(propied4) && size(CPecho,1)>0)
    centPechoAmarillo=CPecho(size(CPecho,1),:);
else
centPechoAmarillo=propied4.Centroid;
end
CPecho=[CPecho;centPechoAmarillo];

%Mostrar los centroides en los fotogramas del video
imshow(video)
hold on 
plot(CHombro2(i,1),CHombro2(i,2), 'm+');%imprimo un centroide con su cordenada x e y
plot(CPecho(i,1),CPecho(i,2), 'w+');
if (isempty(propied3))
plot(centMunecaRojo2(1,1),centMunecaRojo2(1,2), 'w+');
else
plot(centMunecaAzul(1,1),centMunecaAzul(1,2), 'w+');
end
pause(0.05);%Evita superposición de puntos 
hold off
end

for i = 1: length(CPecho)
    %CÁLCULO DE ÁNGULOS
    %%%%%%%%%%%%%%%ÁNGULO DE ABDUCCIÓN Y ADUCCIÓN DEL HOMBRO%%%%%%%%%%%%%%%%%
    distanciaBrazo= CMunecaR2(i,:)-CHombro2(i,:);
    disBrazoX=(distanciaBrazo(1));
    disBrazoY=(distanciaBrazo(2));
    
    distanciaHombro_Torso= CPecho(i,:)-CHombro2(i,:);
    disHombro_TorsoX=(distanciaHombro_Torso(1));
    disHombro_TorsoY=(distanciaHombro_Torso(2));
    
    distanciaMuneca_Torso= CPecho(i,:)-CMunecaR2(i,:);
    disMuneca_TorsoX=(distanciaMuneca_Torso(1));
    disMuneca_TorsoY=(distanciaMuneca_Torso(2));
    
    %Cálculamos las distancias del triángulo escaleno
    brazo=sqrt((disBrazoX^2)+ (disBrazoY^2));
    hombro_torso=sqrt((disHombro_TorsoX^2)+ (disHombro_TorsoY^2));
    muneca_torso=sqrt((disMuneca_TorsoX^2)+ (disMuneca_TorsoY^2));
    
    %Una vez que hemos construido el triángulo conociendo sus distancia ,
    %calcularemos el ángulo de flexoextensión que forma el hombro con el
    %teorema del coseno ----> a^2=b^2+c^2-2*b*a*cos(ang), despejando coseno del
    %angulo nos queda lo siguiente a^2-b^^-c^
    tCoseno1=((muneca_torso^2-hombro_torso^2-brazo^2)/((-2)*(hombro_torso*brazo)));%siendo a=codo_cadera,b=tronco,c=brazo)
    
    %Hemos obtenido el cos(ang) para extraer el ang debemos hacer la
    %arccoseno
    arcHombro= acos(tCoseno1);
    %El ángulo nos lo dan en radianes y hay que pasarlo a grados para su uso
    angHY= rad2deg(arcHombro);
    
    AHombroYawFinal=[AHombroYawFinal,angHY];%Concatena todos los ángulos del movimiento (ángulos totales)
    
end

plot(ACodoRollFinal,'b');
legend('Ángulos Pronosupinación Codo');
hold on
plot(AHombroYawFinal,'r');
legend('Ángulos Aduccion Abduccion Hombro');
 
