close all;
clear all;
clc;

%Planta
S = tf('s');
G =@(S) 1/(S*((S^2)+2));
G(S)
%Planta sem compensação em malha fechada
Gmf=feedback(G(S),1)
%Polos de malha fechada sem compensação
PolosSemComp = pole(Gmf)

%Amortecimento e Wn
syms real
REAL = real(PolosSemComp(1,1));
IMAG = imag(PolosSemComp(1,1));

phi1 = (atan(IMAG/REAL));
Amort1 = cos(phi1)
Wn1 = -REAL/Amort1

%Calculando os polos de malha fechada dominantes baseado nas especificações

syms amort2 Wn2 S
%Insira o mp desejado após o "=="
Mp = exp(-(amort2*pi)/(sqrt(1-amort2*amort2))) == 0.163;
Mpcalc = vpa(solve(Mp, amort2));
amort2 = sqrt(Mpcalc(1,1)^2)

%Insira o TS desejado após o "=="
Ts = 4/(amort2*Wn2) == 2;
Tscalc = vpa(solve(Ts, Wn2));
Wn2 = Tscalc

%Polos Malha fechada:
%Caso ja tenha o armotecimento substitua abaixo:
%S1 = (-amort2*Wn2) + j*Wn2*(sqrt(1-amort2^2))
%S2 = (-amort2*Wn2) - j*Wn2*(sqrt(1-amort2^2))

S1 = (-1) + j*(sqrt(3))
S2 = (-1) - j*(sqrt(3))

%Calculo do angulo
Y=S1;
x=round((angle(G(Y))*180/pi), 4)%O resultado é em rad que é convertido para graus.
if x > 0
    phi = 180 - x
else
    phi = -180 - x    
end

%Caso o phi ainda esteja negativo, é o caso de diminuir do 360
if phi < 0
    phi = 360 + phi
end

%Caso tenha que fazer 2 PD em cascata, descomente o seguinte:
phi = phi/2;

%Calculando o zero do compensador
dist = imag(S1) / (round((tan(phi*pi/180)), 4))
XZero = real(S1) - dist

%Equação do compensador:
Td = 1/abs(XZero)

%Calculando Kp

Y=@(S) Td*(S-XZero)*G(S);
Y(S);
Kp = 1/abs(Y(S1))

%Caso tenha 2 PD em cascata, descomente o seguinte:
Y=@(S) ((Td*(S-XZero))^2)*G(S);
Y(S);
Kp = sqrt(1/abs(Y(S1)))


H = tf('s');
%Portanto, a equação do compensador é:
%Gc = Kp * Td*(S - XZero);

Kpt = double(Kp);
Tdt = double(Td);
XZerot = double(XZero);
Gc = @(H) Kpt * Tdt*(H - XZerot);
Gc(H)

%Caso tenha 2 PD em cascata, descomente o seguinte:
Gc = @(H) Gc(H) * Gc(H);
Gc(H)

%Sistema compensado:
%Função de transferencia de MF:

Gmfc = feedback(Gc(H)*G(H), 1)

%Polos de malha fechada:
PolosComComp = pole(Gmfc)





