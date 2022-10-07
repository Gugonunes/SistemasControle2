%O controlador PI pode ser utilizado quando desejamos zerar o erro em regime permanente para uma certa referência sem alterar significativamente a
% resposta transitória do sistema original em malha fechada com realimentação unitária.
% O controlador atinge esse objetivo inserindo um polo na origem do sistema em malha aberta e com isso,
% se o sistema não tiver um polo na origem, este passará a ter erro nulo para entrada do tipo degrau.
% Caso o sistema tenha um polo na origem, a inserção de um polo adicional na origem irá zerar o erro para uma entrada do tipo rampa.

%No projeto para compensação do erro via controlador PI, o polo e o zero deste controlador estão próximos.
% Todavia, é possível se fazer a compensação do erro em regime permanente ao mesmo tempo que se modifica a resposta transitória de um sistema,
% para alguns cenários, afastando o zero do controlador da origem. Com isso, adiciona-se um polo na origem do sistema 
% em malha aberta ao mesmo tempo em que se leva os polos dominantes do sistema em malha fechada para onde se deseja para impor o comportamento transitório almejado.

close all;
clear all;
clc;

%Planta
S = tf('s');
K = 1;
G =@(S) (K)/((S+1));
G(S)
%Planta sem compensação em malha fechada
Gmf=feedback(G(S),1)
%Polos de malha fechada sem compensação
PolosSemComp = pole(Gmf)

%Amortecimento e Wn
%OBS: Funções com 3 polos deve-se selecionar um polo DOMINANTE abaixo!
%Ou seja, PolosSemComp(2,1)
syms real
REAL = real(PolosSemComp);
%IMAG = imag(PolosSemComp(2,1));
IMAG = 0;
phi1 = (atan(IMAG/REAL));
Amort1 = cos(phi1)
Wn1 = -REAL/Amort1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Caso tenha o Sobressinal e o Ts, descomente:
syms amort2 Wn2
%Insira o mp desejado após o "=="
%Mp = exp(-(amort2*pi)/(sqrt(1-amort2*amort2))) == 0;
%Mpcalc = vpa(solve(Mp, amort2))
%amort2 = sqrt(Mpcalc(0,1)^2)

%Insira o TS desejado após o "=="
%amort2 = 1;
%Ts = 4/(amort2*Wn2) == 1;
%Tscalc = vpa(solve(Ts, Wn2));
%Wn2 = Tscalc

%Wn1 = double(Wn2)
%Amort1 = double(amort2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Wn1=4

%Polos Malha fechada:
%Caso ja tenha o armotecimento substitua abaixo:
S1mf = (-Amort1*Wn1) + j*Wn1*(sqrt(1-Amort1^2))
S2mf = (-Amort1*Wn1) - j*Wn1*(sqrt(1-Amort1^2))

%kv
syms X
Y=G(X); %aqui usa a equação de degrau/rampa/parabolica
Kv = vpa(limit(Y, X, 0))
erroInf=1/(Kv+1)

%Iniciando o projeto. Deseja-se zerar o erro para entrada tipo rampa, sem
%comprometer a resposta transitória

%Escolhendo o zero do compensador próximo à origem:
ZeroComp = -0.05
Ti = 1/abs(ZeroComp)

syms Ki
%Ki = Kp/Ti
%G compensador:
%Kp = double(Kp)

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
S1 = -4.00
S2 = -1.00 - 1.732*j

%Insira o valor de "Gain":
Kp = 3

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
%figure();
%step(Gmfc)

