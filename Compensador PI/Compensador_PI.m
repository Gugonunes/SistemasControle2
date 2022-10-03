close all;
clear all;
clc;

%Planta
S = tf('s');
K = 10;
G =@(S) (K)/(S*(S+4));
G(S)
%Planta sem compensação em malha fechada
Gmf=feedback(G(S),1)
%Polos de malha fechada sem compensação
PolosSemComp = pole(Gmf)

%Amortecimento e Wn
%OBS: Funções com 3 polos deve-se selecionar um polo DOMINANTE abaixo!
%Ou seja, PolosSemComp(2,1)
syms real
REAL = real(PolosSemComp(2,1));
IMAG = imag(PolosSemComp(2,1));

phi1 = (atan(IMAG/REAL));
Amort1 = cos(phi1)
Wn1 = -REAL/Amort1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Caso tenha o Sobressinal e o Ts, descomente:
syms amort2 Wn2
%Insira o mp desejado após o "=="
Mp = exp(-(amort2*pi)/(sqrt(1-amort2*amort2))) == 0.163;
Mpcalc = vpa(solve(Mp, amort2));
amort2 = sqrt(Mpcalc(1,1)^2)

%Insira o TS desejado após o "=="
Ts = 4/(amort2*Wn2) == 4;
Tscalc = vpa(solve(Ts, Wn2));
Wn2 = Tscalc

Wn1 = double(Wn2)
Amort1 = double(amort2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Polos Malha fechada:
%Caso ja tenha o armotecimento substitua abaixo:
S1mf = (-Amort1*Wn1) + j*Wn1*(sqrt(1-Amort1^2))
S2mf = (-Amort1*Wn1) - j*Wn1*(sqrt(1-Amort1^2))

%kv
syms X
Y=X*G(X); %aqui usa a equação de degrau/rampa/parabolica
Kv = vpa(limit(Y, X, 0))
erroInf=1/Kv

%Iniciando o projeto. Deseja-se zerar o erro para entrada tipo rampa, sem
%comprometer a resposta transitória

%Escolhendo o zero do compensador próximo à origem:
ZeroComp = -1
Ti = 1/abs(ZeroComp)

%G compensador:
Gc = @(S) (S-ZeroComp)/S;
Gc(S)

%A seguir serão plotadas as duas curvas juntas. Encontre o polo na linha
%vermelha onde "Damping == Amort1" e "Frequency == Wn1"
%Após isso, encontre um polo na linha verde que fique alinhado ao polo
%escolhido na vermelha e à origem do sistema

rlocus(G(S), 'r')
hold;
rlocus(Gc(S)*G(S), 'g')

%Polo selecionado na linha verde (incluindo o +-):
S1 = -1.00 + 1.732*j
S2 = -1.97 - 3.4*j

%Insira o valor de "Gain":
Kp = 0.800

%Portanto, Gc atualizada:
Gc = @(S) Kp*Gc(S);
Gc(S)

%Calculando o angulo de Gc, deve estar entre -5 e 0:
x=round((angle(Gc(S1))*180/pi), 4)%O resultado é em rad que é convertido para graus.

%Sistema final compensado:
Gcg = @(S) Gc(S)*G(S)
Gmfc = feedback(Gcg(S), 1)

%Polos finais de MF: 
PolosComComp = pole(Gmfc)

%Erro do sistema compensado(deve dar NaN no Kv e no ErroInf):
Y2=X*Gcg(X)*G(X); %aqui usa a equação de degrau/rampa/parabolica
KvComp = vpa(limit(Y2, X, 0))
erroInf=1/KvComp

%Caso precise calcular o Mp e Ts final:
figure();
step(Gmfc)

