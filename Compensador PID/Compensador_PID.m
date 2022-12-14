%O controlador PID pode ser empregado quando deseja-se melhorar a resposta transitória e zerar o erro em regime permanente para algum tipo de entrada

%O controlador PID tem uso similar ao do controlador de avanço-atraso. A diferença é que o controlador de PID
%é capaz de zerar o erro em regime permanente para um certo tipo de entrada enquanto o controlador de avanço-atraso apenas reduz o erro.

%O controlador PID pode ter diferentes formas de implementação tais como a forma padrão C(s)=Kp(1+1Tis+Tds), 
% a forma paralela C(s)=Kp+Kis+Kds e a forma interativa ou em série C(s)=Kc(Tds+1)(1+1Tis). 
% Todas estas formas, caso tenham os ganhos ajustados corretamente, são equivalentes.

close all;
clear all;
clc;

%Planta
S = tf('s');
K = 10;
G =@(S) (K)/((S)*(S+4));
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

%kv
syms X
Y=G(X); %aqui usa a equação de degrau/rampa/parabolica
Kv = vpa(limit(Y, X, 0))
erroInf=1/Kv

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

%Wn1 = double(Wn2)
%Amort1 = double(amort2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Polos Malha fechada desejados:
%Caso ja tenha o armotecimento substitua abaixo:
Amort1 = 0.89
Wn1 = 1.3
S1mf = (-Amort1*Wn1) + j*Wn1*(sqrt(1-Amort1^2))
S2mf = (-Amort1*Wn1) - j*Wn1*(sqrt(1-Amort1^2))

%Calculo do angulo
Y=S1mf;
%caso tenha uma equação de Compensador, usar ela abaixo(aqui vai só a parte do PD):
C = @(S) (S+4)/S
%está com "/Y" pq a questao pedia erro nulo para entrada degrau, entao foi
%adicionado o integrador ('1/s') junto à G(S). 
%Caso nao peça isso, tirar o '/Y'
x=round((angle(C(Y)*G(Y))*180/pi), 4)%O resultado é em rad que é convertido para graus.
if x > 0
    phi = 180 - x
else
    phi = -180 - x    
end

%Caso o phi ainda esteja negativo, é o caso de diminuir do 360
if phi < 0
    phi = 360 + phi
end

%PD: Determinando o Zero 
%Calculando o zero do compensador
%Como dizia (s+z)^2, o '^2' indica que deve dividir o angulo por 2 nessa
%etapa, se nao tiver o '^2' remova o '/2' abaixo
dist = imag(S1mf) / (round((tan(phi*pi/180)), 4))
XZero = real(S1mf) - dist

%Equação do compensador:
%Utiliza o zero dado se for o caso
Td = 1/abs(XZero)

%Calculando Kc (Ganho do compensador PD)
%caso tenha uma equação de Compensador, usar ela abaixo:
C = @(S) (S+4)*(S-XZero)/S
C(S)
%Caso contrario use a forma padrao de Y padrao:
%Y=@(S) Td*(S-XZero)*G(S);

Y=@(S) (Td*C(S))*G(S);

Kc = 1/abs(Y(S1mf))

GanhoCompTotal = Kc*Td %K e Kd

%GcPD = @(S) Kc*Td*(S - XZero);
GcPD = @(S) GanhoCompTotal*C(S)
C(S)

Kp = GanhoCompTotal*(2*(abs(XZero)))
Ki = GanhoCompTotal*(XZero)^2

%Escolhendo o zero do PI:
%Escolhendo o zero do compensador próximo à origem:
ZeroComp = -0.1;
Ti = 1/abs(ZeroComp)

% A eq1 deve ser ~1 e a eq2 deve estar entre -5 e 0 graus
% Se nao satisfazer esses valores, tente outro numero
eq1 = abs((S1mf + 1/Ti)/(S1mf))
eq2 = round((angle((S1mf + 1/Ti)/(S1mf))*180/pi), 4)

%G compensador:
GcPI = @(S) (S-ZeroComp)/S;
GcPI(S)

%G final do compensador:
Gc = @(S) GcPI(S) * GcPD(S);
Gc(S)

%Se só usar o PD utilize GcPD abaixo, caso contrario use Gc
Gmfc = @(S) feedback(GcPD(S)*G(S), 1);
Gmfc(S)

%Polos de MF finais:
PolosComComp = pole(Gmfc(S))
ZerosComComp = zero(Gmfc(S))

%valores teóricos
Mp2 = exp(-(Amort1*pi)/(sqrt(1-Amort1*Amort1)))
Ts = 4/(Amort1*Wn1)

%Valores reais de MP e Ts:
step(Gmfc(S))

%Erro do sistema compensado(deve dar Inf no Kv e 0 no ErroInf):
syms X
Y2=Gc(X)*G(X); %aqui usa a equação de degrau/rampa/parabolica
KvComp = vpa(limit(Y2, X, 0))
erroInf=1/KvComp



