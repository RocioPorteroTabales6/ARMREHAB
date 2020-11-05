centHombroVerde=[];
centMunecaRojo=[];
centMunecaAzul=[];
centPechoAmarillo=[];
AHombroYawFinal=[];
ACodoRollFinal=[];


%CÁLCULO DE ÁNGULOS
%%%%%%%%%%%%%%%ÁNGULO DE ABDUCCIÓN Y ADUCCIÓN DEL HOMBRO%%%%%%%%%%%%%%%%%
distanciaBrazo= centMunecaRojo-centHombroVerde;
disBrazoX=(distanciaBrazo(1));
disBrazoY=(distanciaBrazo(2));

distanciaHombro_Torso= centPechoAmarillo-centHombroVerde;
disHombro_TorsoX=(distanciaHombro_Torso(1));
disHombro_TorsoY=(distanciaHombro_Torso(2));

distanciaMuneca_Torso= centPechoAmarillo-centMunecaRojo;
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

%%%%%%%%%%%%%%%ÁNGULO DE PRONOSUPINACIÓN DEL CODO%%%%%%%%%%%%%%%
% Meterlo en el bucle for de deteccion de marcadores, en calculo de
% centroides
if (isempty(propied3))
centMunecaRojo=propied2.Centroid;
angRC = 90;
else
centMunecaAzul=propied3.Centroid;
angRC = 0;
end
CMunecaR=[CMunecaR;centMunecaRojo];
CMunecaA=[CMunecaA;centMunecaAzul];

ACodoRollFinal=[ACodoRollFinal,angRC];

plot(ACodoRollFinal);
title('Ángulos Pronosupinación Codo');
