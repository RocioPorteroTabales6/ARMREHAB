
centHombroVerde=[];
centCodo=[];
centMunecaRojo=[];
centCadera=[];

CCodo=[];
CMunecaR=[];
CHombro=[];
CCadera=[];

angHombroPitchFinal=[];
angCodoPitchFinal=[];

%Video plano sagital
v = VideoReader('JarraVideo.mp4'); %Cargamos el video

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
marcador1 =video(:,:,1).*0; %1º marcador hace referencia al marcador de color verde codo
marcador1(imR>73 & imR<134 & imG>154 & imG<255 & imB>58 & imB<119)=1;

marcador2= video(:,:,1).*0 ; %2º marcador hace referencia al marcador de color rojo muñeca
marcador2(imR>120 & imR<255 & imG>3 & imG<58 & imB>6 & imB<60)=1;

marcador3= video(:,:,1).*0;%3º marcador hace referencia al marcador de color azul hombro
marcador3(imR>0 & imR<40 & imG>35 & imG<73 & imB>76 & imB<145)=1;

marcador4 =video(:,:,1).*0;%4º marcador hace referencia al marcador de color amarillo cadera
% marcador4(imR>235 & imR<255 & imG>213 & imG<175 & imB>33 & imB<110)=1;
marcador4(imR>140 & imR<255 & imG>100 & imG<155 & imB>0 & imB<50)=1;

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

%Calculo de centroides (Hombro, Codo, Muneca y Pecho)
if (isempty(propied1)&& size(CCodo,1)>0)
    centCodo=CCodo(size(CCodo,1),:);
else
    centCodo=propied1.Centroid;
end
CCodo=[CCodo;centCodo];

if (isempty(propied2) && size(CMunecaR,1)>0)
    centMunecaRojo= CMunecaR(size(CMunecaR,1),:);
else
    centMunecaRojo=propied2.Centroid;
end
CMunecaR=[CMunecaR;centMunecaRojo];

if (isempty(propied3) && size(CHombro,1)>0)
    centHombroAzul= CHombro(size(CHombro,1),:);
else
    centHombroAzul=propied3.Centroid;
end
CHombro=[CHombro;centHombroAzul];

if (isempty(propied4) && size(CCadera,1)>0)
    centCadera=app.CCadera(size(CCadera,1),:);
else
    centCadera=propied4.Centroid;
end
CCadera=[CCadera;centCadera];

%Mostrar los centroides en los fotogramas del video
imshow(video)
hold on 
plot(CCodo(i,1),CCodo(i,2), 'w+');
plot(CHombro(i,1),CHombro(i,2), 'm+');%imprimo un centroide con su cordenada x e y
plot(CMunecaR(i,1),CMunecaR(i,2), 'w+');
plot(CCadera(i,1),CCadera(i,2), 'w+');
pause(0.05);%Evita superposición de puntos 
hold off
end

for i=1:length(CCodo)
    %%%%%%%%%%%%%%CALCULO DE ÁNGULOS%%%%%%%%%%%%%%%%%%%%%%%%%%
    %ÁNGULO DE FLEXOEXTENSIÓN DEL HOMBRO
    %El objetivo es construir un triángulo escaleno con los centros del
    %hombro,codo y cadera para sacar el ángulo de flexoextensión del hombro, para ello sacamos la
    %distancia que hay entre el hombro y el codo(brazo), entre el hombro y la
    %cadera (tronco) y entre el codo y cadera.
    
    %el centroide nos da dos coordenadas por lo que la distancia del brazo se
    %descompondrá en x e y para luego caclular la distancia de la misma
    distanciaBrazo= CCodo(i,:)-CHombro(i,:);
    disBrazoX=(distanciaBrazo(1));
    disBrazoY=(distanciaBrazo(2));
    
    distanciaTronco= CCadera(i,:)-CHombro(i,:);
    disTroncoX=(distanciaTronco(1));
    disTroncoY=(distanciaTronco(2));
    
    distanciaCodo_Cadera= CCadera(i,:)-CCodo(i,:);
    disCodo_CaderaX=(distanciaCodo_Cadera(1));
    disCodo_CaderaY=(distanciaCodo_Cadera(2));
    
    %Cálculamos las distancias del triángulo escaleno
    brazo=sqrt((disBrazoX^2)+ (disBrazoY^2));
    codo_cadera=sqrt((disCodo_CaderaX^2)+ (disCodo_CaderaY^2));
    tronco=sqrt((disTroncoX^2)+(disTroncoY^2));
    
    %Una vez que hemos construido el triángulo conociendo sus distancia ,
    %calcularemos el ángulo de flexoextensión que forma el hombro con el
    %teorema del coseno ----> a^2=b^2+c^2-2*b*a*cos(ang), despejando coseno del
    %angulo nos queda lo siguiente a^2-b^^-c^
    tCoseno=((codo_cadera^2-tronco^2-brazo^2)/((-2)*(tronco*brazo)));%siendo a=codo_cadera,b=tronco,c=brazo)
    
    %Hemos obtenido el cos(ang) para extraer el ang debemos hacer la
    %arccoseno
    arcHombro= acos(tCoseno);
    %El ángulo nos lo dan en radianes y hay que pasarlo a grados para su uso
    angHP= rad2deg(arcHombro);
    angHombroPitchFinal=[angHombroPitchFinal,angHP];
    
    %%%%%%%%%%%%%ANGULO DE FLEXOEXTENSION DEL CODO%%%%%%%%%%%%%%%%%%%
    distanciaAntebrazo= CMunecaR(i,:)-CCodo(i,:);
    disAntebrazoX=(distanciaAntebrazo(1));
    disAntebrazoY=(distanciaAntebrazo(2));
    
    distanciaHombro_Muneca= CMunecaR(i,:)-CHombro(i,:);
    disHombro_MunecaX=(distanciaHombro_Muneca(1));
    disHombro_MunecaY=(distanciaHombro_Muneca(2));
    
    %Cálculamos las distancias del triángulo escaleno
    antebrazo=sqrt((disAntebrazoX^2)+ (disAntebrazoY^2));
    hombro_muneca=sqrt((disHombro_MunecaX^2)+ (disHombro_MunecaY^2));
    
    %Una vez que hemos construido el triángulo conociendo sus distancia ,
    %calcularemos el ángulo de flexoextensión que forma el hombro con el
    %teorema del coseno ----> a^2=b^2+c^2-2*b*a*cos(ang), despejando coseno del
    %angulo nos queda lo siguiente a^2-b^^-c^
    tCoseno1=((hombro_muneca^2-antebrazo^2-brazo^2)/((-2)*(antebrazo*brazo)));%siendo a=codo_cadera,b=tronco,c=brazo)
    
    %Hemos obtenido el cos(ang) para extraer el ang debemos hacer la
    %arccoseno
    arcCodo= acos(tCoseno1);
    %El ángulo nos lo dan en radianes y hay que pasarlo a grados para su uso
    angCPITCH= rad2deg(arcCodo);
    angCodoPitchFinal=[angCodoPitchFinal,angCPITCH];
end

plot(angCodoPitchFinal,'b');
legend('Ángulos Flexoextension Codo');
hold on
plot(angHombroPitchFinal,'r');
legend('Ángulos Flexoextension Hombro');
