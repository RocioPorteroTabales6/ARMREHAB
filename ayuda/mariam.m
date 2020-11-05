% La camara graba a 30 FPS, por lo que dividir entre 5, para que haya 6
% frames por cada segundo.
 
clc
clear
 
centCad=[];
centRod=[];
centTal=[];
centPun=[];
anglesCadera=[];
anglesRodilla=[];
anglesPie=[];
CR=[];
CT=[];
CD=[];
CP=[];
difX=[];
difY=[];
centroids_X=[];
centroids_Y=[];
centroids=[];

workingDir = tempname;
mkdir(workingDir)
mkdir(workingDir,'images')
numberId = 0;


v = VideoReader('NewVideo1.mp4');
 
for i = 1:100

 
video = read(v,i);

%%%%%%%%%%%%%%%%%%%%%%%% DETECCIÓN DE MARCADORES %%%%%%%%%%%%%%%%%%%%%%%%%

%***********
% Imagen BINARIA de cada marcador
%***********
marcador1 = video(:,:,1).*0;
marcador1((video(:,:,1)>70 & video(:,:,1)<170) & (video(:,:,2)>140 & video(:,:,2)<230) & (video(:,:,3)>225)) = 1;
 
marcador2 = video(:,:,1).*0;
marcador2(video(:,:,1)>200 & video(:,:,2)<60 & video(:,:,3)<60) = 1;
 
marcador3 = video(:,:,1).*0;
marcador3((video(:,:,1)> 150 & video(:,:,1)<210) & video(:,:,2)>240 & (video(:,:,3)>70 & video(:,:,3)<150)) = 1;
 
marcador4 = video(:,:,1).*0;
marcador4((video(:,:,1)>50 & video(:,:,1)<95) & (video(:,:,2)>55 & video(:,:,2)<130) & (video(:,:,3)>85 & video(:,:,3)<190)) = 1;

%Elimina los objetos cuyo número de píxeles sea <10:
imgFilled1 = bwareaopen (marcador1,5);
imgFilled2 = bwareaopen (marcador2,10);
imgFilled3 = bwareaopen (marcador3,5);
imgFilled4 = bwareaopen (marcador4,20);

% Detección de objetos por cada marcador: 
[L1,Ne1] = bwlabel(imgFilled1);
[L2,Ne2] = bwlabel(imgFilled2);
[L3,Ne3] = bwlabel(imgFilled3);
[L4,Ne4] = bwlabel(imgFilled4);

%Cálculo de propiedades de los objetos de cada marcador: 
propied1=regionprops(L1);
propied2=regionprops(L2);
propied3=regionprops(L3);
propied4=regionprops(L4);

%Cálculo CENTROIDES(Rodilla y Talón) 
centRod=propied2.Centroid;
CR=[CR;centRod];
centTal=propied3.Centroid;
CT=[CT;centTal];
 
%************
%Cálculo CENTROIDES(Cadera y Punta) 
%************
%------------
%1)CADERA
 
% - SITUACIÓN:En algún fotograma pierde el punto ya que el brazo lo oculta.
%Por lo que si el vector propiedades, es decir, no existen objetos en la
%imagen binaria, coje el centroide del fotograma anterior.
 
TF = isempty(propied1);
I=size(CD,1);
if (TF==1 & I>0)% El tam. de CD[]tiene que ser mínimo 1(obvio). Sino da error.
    centCad=CD(I,:);
else
    centCad=propied1.Centroid;
end
CD=[CD;centCad];
 
%-------------
%2)PUNTA
 
% - SITUACIÓN:En algún fotograma pierde el punto. En otras, señala el suelo
% como centroide. En el primer caso,esto es, cuando no detecte, hará una
% estimación teniendo en cuenta 3 fotogramas anteriores para su cálculo o
% interpolación. En el segundo caso, comprobará que el punto detectado no
% se aleje de la máxima distancia Talón- Punta, si es así lo elimina y hace
% una estimación con el mismo procedimeinto descrito anteriormente.
 
TP = isempty(propied4);
 
ref= 45;%distancia aproxiamda máxima P-T
 
 
%   -  CASOS:
%       A) Sino encuentra punto: 
variable=size(CP,1);
if(variable > 3)  %el tam de CP >3 fotogramas, sino no puede hacer estiamción  
    
%Estudio de los fotogramas anteriores 
 
AntPunt_X=CP(variable,1);
 AntPunt1_X=CP(variable-1,1);
AntPunt2_X=CP(variable-2,1);
 
 AntPunt_Y=CP(variable,2);
AntPunt1_Y=CP(variable-1,2);
AntPunt2_Y=CP(variable-2,2);
 
%Diferencia de los dos anteriores(ver su crec o decrec) 
difX=(AntPunt_X - AntPunt1_X);
difY= AntPunt_Y -  AntPunt1_Y;
%Seguimos comprobando el 3º fotograma anterior: 
dif2X= AntPunt1_X- AntPunt2_X;
dif2Y=AntPunt1_Y- AntPunt2_Y;
%Media de ambas diferencias:
diftot_X=(abs(difX)+abs(dif2X))/2;
diftot_Y=(abs(difY)+abs(dif2Y))/2;
 
 
 if (TP==1)
 
    if(difX>0)% si los fotog. ant. han estado creciendo sumo enla proporción:    
    centroids_X=AntPunt_X + diftot_X;
 
    elseif(difX<0)% si los fotog. ant. han estado decreciendo resto en la proporción:    
    centroids_X=AntPunt_X - diftot_X;
    end   
     if(difY>0)% si los fotog. ant. han estado creciendo sumo enla proporción:    
    centroids_Y=AntPunt_Y + diftot_Y;
   
     elseif(difY<0)% si los fotog. ant. han estado decreciendo resto en la proporción:    
    centroids_Y=AntPunt_Y - diftot_Y;
    end   
    %Por tanto: 
    centPun=[centroids_X,centroids_Y];
 
  
%2º caso: si encuentra pero está más allá (>45)   
else
    centPun=propied4.Centroid;
%Declaración variables para hallar *distacia punta-talón*:
Y=(size(CP,1))+1;%tambien valdria CT en vez de CP +1
distanciasPie = centPun - CT(Y,:);
distPieX = abs(distanciasPie(1));
distPieY = abs(distanciasPie(2));
pie = sqrt((distPieX)^2 + (distPieY)^2);%Dist P-T diagonal por arriba
 
%Si el punto está más alejado de la dist ref:
    if (pie > ref)
   
        if(difX>0)% si los fotog. ant. han estado creciendo sumo enla proporción:    
        centroids_X=AntPunt_X + diftot_X;
       
        elseif(difX<0)% si los fotog. ant. han estado decreciendo resto en la proporción:    
        centroids_X=AntPunt_X - diftot_X;
        end   
         if(difY>0)% si los fotog. ant. han estado creciendo sumo enla proporción:    
        centroids_Y=AntPunt_Y + diftot_Y;
        
        elseif(difY<0)% si los fotog. ant. han estado decreciendo resto en la proporción:    
        centroids_Y=AntPunt_Y - diftot_Y;
        end   
     %Por tanto: 
       centPun=[centroids_X,centroids_Y];   
    end
 end
 
else
 
    centPun=propied4.Centroid;%si tam de CP<3
end
 
CP=[CP;centPun];
 
%**************
%Vector de centroides totales del fotograma
%**************
 
%centroids=[centroids,centCad];
%centroids=[centroids,centRod];
%centroids=[centroids,centTal];
%centroids=[centroids,centPun];
 
 
%**************
%IMPRIMIR CENTROIDES en el fotograma Actual 
%**************
figure, 
imshow(video)
hold on 
%plot(centroids(:,1),centroids(:,2), 'w+');
plot(centCad(1,1),centCad(1,2), 'm+');
plot(centRod(1,1),centRod(1,2), 'w+');
plot(centTal(1,1),centTal(1,2), 'm+');
plot(centPun(:,1),centPun(:,2), 'k+');
pause(0.4);%Evita superposición de puntos 
hold off
 
 
 
%*************************
%*************************
%%%%%%%%%%%%%%%%%%%%%%%% CÁLCULO DE ÁNGULOS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%*************************
%*************************
%Angulo Cadera:
distanciasFemur = centRod - centCad;
distCaderaX = abs(distanciasFemur(1)); 
distCaderaY = abs(distanciasFemur(2));
radsCadera = atan(distCaderaX/distCaderaY); % Utilizamos Trigonometria de triangulo
angleCad = rad2deg(radsCadera);             % rectangulo para hayar angulo.
 
if centCad(1) < centRod(1)    
    angleCaderaFinal = angleCad *-1;
else
    angleCaderaFinal = angleCad;
end
 
anglesCadera = [anglesCadera, angleCaderaFinal];
%Angulo Rodilla
 
distanciasTibia = centTal - centRod;
distRodX = abs(distanciasTibia(1));
distRodY = abs(distanciasTibia(2));
distanciasCadera_Talon = centTal - centCad; 
distC_TX = abs(distanciasCadera_Talon(1));
distC_TY = abs(distanciasCadera_Talon(2));
 
    %Calculamos dsitancias del triangulo escaleno
femur = sqrt((distCaderaX)^2 + (distCaderaY)^2);
tibia = sqrt((distRodX)^2 + (distRodY)^2);
Cadera_Talon = sqrt((distC_TX)^2 + (distC_TY)^2);
    % Calculamos angulo de la rodilla con teorema del coseno
teoremaCosenoR = (Cadera_Talon^2 - femur^2 - tibia^2)/(femur * tibia * (-2));
radsRod = acos(teoremaCosenoR);
angleRod = rad2deg(radsRod);
 
angleRodillaFinal = (180 - angleRod) * (-1);
anglesRodilla = [anglesRodilla,angleRodillaFinal];
 
%Angulo Tobillo
 
distanciasPie = centPun - centTal;
distPieX = abs(distanciasPie(1));
distPieY = abs(distanciasPie(2));   %IMPORTANTE!!!
distanciasRodilla_Punta = centPun - centRod;
distR_PX = abs(distanciasRodilla_Punta(1));
distR_PY = abs(distanciasRodilla_Punta(2));
 
%radsPie = atan(distPieY/distPieX); %Aqui medimos angulo con respecto a la horizontal... Mirar!
%angleTob = rad2deg(radsPie);
 
pie = sqrt((distPieX)^2 + (distPieY)^2);%Dist P-T diagonal por arriba
Rodilla_Punta = sqrt((distR_PX)^2 + (distR_PY)^2);%Dist R-P directa 
 
teoremaCosenoT = (Rodilla_Punta^2 - tibia^2 - pie^2)/(pie * tibia * (-2));
radsPie = acos(teoremaCosenoT);
anglePie = rad2deg(radsPie);%pasa a grados andulo del talón
 
%anglePieFinal = (180 - anglePie) * (-1)
anglesPie=[anglesPie,anglePie-111];%VA GUARDANDO TODOS LOS ANGULOS DE TOBILLO EN UNA SOLA
%Restamos 111 porque ese es el angulo del pie en reposo.
 
% fprintf('Angulo de Cadera: %s\n', sprintf('%d ', angleCaderaFinal))
% fprintf('Angulo de Rodilla: %s\n', sprintf('%d ', angleRodillaFinal))
% fprintf('Angulo de Tobillo: %s\n', sprintf('%d ',angleTobilloFinal))
% fprintf('\n')


% GUARDAR EN VIDEO

filename1 = [sprintf('%03d',i) '.fig']; %OJO con el jpg en vez de fig
fullname1 = fullfile(workingDir,'images',filename1);
savefig(fullname1)
%imwrite(video,fullname)    % Write out to a JPEG file (img1.jpg, img2.jpg, etc.)
%i = i+1; De mometno no hace falta porque el loop es for, ya definido, pero
%dejar para el futuro

figs = openfig(fullname1);
for K = 1 : length(figs)
   filename = [sprintf('%03d',i) '.jpg'];
   fullname = fullfile(workingDir,'images',filename);
   saveas(figs(K), fullname);
end
 
 
end

imageNames = dir(fullfile(workingDir,'images','*.jpg'));
imageNames = {imageNames.name}';

outputVideo = VideoWriter(fullfile(workingDir,'shuttle_out.avi'));
outputVideo.FrameRate = v.FrameRate;
open(outputVideo)

for ii = 1:length(imageNames)
   img = imread(fullfile(workingDir,'images',imageNames{ii}));
   writeVideo(outputVideo,img)
end

close(outputVideo)
shuttleAvi = VideoReader(fullfile(workingDir,'shuttle_out.avi'));

ii = 1;
while hasFrame(shuttleAvi)
   mov(ii) = im2frame(readFrame(shuttleAvi));
   ii = ii+1;
end

figure 
imshow(mov(1).cdata, 'Border', 'tight')

movie(mov,1,shuttleAvi.FrameRate)