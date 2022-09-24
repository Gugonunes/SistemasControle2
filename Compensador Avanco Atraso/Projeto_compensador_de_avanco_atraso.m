close all;
clear all;
clc;

%Planta
S = tf('s');
G =@(S) 1/(S*(S+4));
G(S)
%Planta sem compensação em malha fechada
Gmf=feedback(G(S),1)
%Polos de malha fechada sem compensação
PolosSemComp = pole(Gmf)

syms amort Wn S
%Insira o mp desejado após o "=="
Mp = exp(-(amort*pi)/(sqrt(1-amort*amort))) == 0.05;
Mpcalc = single(solve(Mp, amort));
amort = sqrt(Mpcalc(1,1)^2)

%Insira o TS desejado após o "=="
Ts = 4/(amort*Wn) == 2;
Tscalc = vpa(solve(Ts, Wn));
Wn = Tscalc

%Polos Malha fechada
S1 = (-amort*Wn) + j*Wn*(sqrt(1-amort^2))
S2 = (-amort*Wn) - j*Wn*(sqrt(1-amort^2))

%Calculo do angulo
Y=S1;
x=round((angle(G(Y))*180/pi), 4)%O resultado é em rad que é convertido para graus.
if x > 0
    phi = 180 - x
else
    phi = -180 - x    
end

%Posição do polo do compensador:
%Insira o Zero do avanço a seguir
ZeroComp = -0.1;

if ZeroComp > real(S1)
    dist = sqrt((real(S1) - ZeroComp)^2)
    theta1 = round((atan(dist/imag(S1))*180/pi), 4)
    theta2 = (phi - theta1)
    distX = imag(S1)*tan(round((theta2*pi/180), 4))
    postF = -distX - dist + ZeroComp
else
    dist = sqrt((real(S1) - ZeroComp)^2)
    theta1 = round((atan(dist/imag(S1))*180/pi), 4)
    theta2 = (phi + theta1)
    distX = imag(S1)*tan(round((theta2*pi/180), 4))
    postF = real(S1) - distX
end

%T1 e alfa
T1 = 1/(-ZeroComp)

alfa = 1/(T1*(-postF))

%calculando Kc

Kc = 1/ abs( ( ((S1 - ZeroComp)/(S1 - postF)) *G(S1)))

%Compensador de avanço
S = tf('s');

%substitua a seguir os valores das variaveis pelos numeros para facilitar
%Gav =@(S) Kc * (S - ZeroComp)/(S - postF)
Gav =@(S) 8,399 * (S+0.1)/(S+0.0998)
Gav(S)
%Planta compensada com avanço
Gmfcav= feedback((Gav(S)*G(S)),1)
Gmfcav= minreal(Gmfcav)

%Polos de malha fechada com compensação de avanço
PolosMF = pole(Gmfcav)

%Resposta ao degrau
step(Gmfcav,10);
legend('Com compensação de avanço');

%-----------------------------------------------------------------------
%kv
syms X
Y=X*G(X); %aqui usa a equação de degrau/rampa/parabolica
Kv = vpa(limit(Y, X, 0))
erroInf=1/Kv
%insira o erro desejado (questão diz)
erroDes = 0.2
Y2=X.*Gav(X).*G(X);
Kv2 = 1/erroDes
Betha = Kv2/(Kc*alfa*Kv)

%Escolhendo o valore de T2:
T2 = 10; 
% A eq1 deve ser ~1 e a eq2 deve estar entre -5 e 0 graus
% Se nao satisfazer esses valores, tente outro numero
eq1 = abs((S1 + 1/T2)/(S1 + 1/Betha*T2))
eq2 = round((angle((S1 + 1/T2)/(S1 + 1/Betha*T2))*180/pi), 4)

%Polo e zero do compensador
PoloComp2 = -1/(Betha*T2)
ZeroComp2 = -1/T2

%substitua a seguir os valores das variaveis pelos numeros para facilitar
%Gc = Gav(S) * ((S - ZeroComp2)/(S - PoloComp2))
GcAtraso = (S + 0.1)/(S + 0.042)
Gc = Gav(S) * GcAtraso

Gmfc = feedback(Gc*G(S), 1);
Gmfc = minreal(Gmfc)

%Polos de MF finais:
PolosFinais = pole(Gmfc)
ZeroFinal = zero(Gmfc)

ST1 = -0.782 + 1.074*j;
%usando o arquivo armotecimento_wn
amort2 = 0.5886
Wn2 = 1.3285

%valores teóricos
Mp2 = exp(-(amort2*pi)/(sqrt(1-amort2*amort2)))
Ts = 4/(amort2*Wn2)

%valores reais


step(Gmfc,60);
legend('Com compensação de avanço final');

