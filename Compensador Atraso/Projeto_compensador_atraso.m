close all;
clear all;
clc;

S=tf('s');
%Insira a G(S) abaixo:
G=@(S) (30/((S+1)*(S+5)*(S+10)));
G(S)
%comando de realimenta�ao
Gmf = feedback(G(S),(2*S))

%Polos de malha fechada
Polos = pole(Gmf)

%calculando amortecimento e wn
syms real
%selecione o polo com imaginario positivo
REAL = real(Polos(2,1));
IMAG = imag(Polos(2,1));
phi = (atan(IMAG/REAL));
Amortecimento1 = cos(phi)
Wn1 = -REAL/Amortecimento1

%Insira o Zero do compensador escolhido(arbitr�rio, ou a quest�o da):
ZeroE = -0.1;
T = 1/(-ZeroE)

%Calculo de Beta:
%calculo do Kv atual do sistema:
syms X
Y=G(X); %aqui usa a equa��o de degrau/rampa/parabolica
Kv = vpa(limit(Y, X, 0)) %vpa retorna o decimal da resposta

%calculando o erro em regime permanente
erro = 1/(1+Kv) %coloca 1+kv se for degrau

%Erro desejado do sistema:
erroD=0.05;
Kv2 = (1/erroD) -1 %se for degrau usa -1
divK = Kv2/Kv
Y2= (divK)-(floor(divK));
if Y2 < 0.5
    B = round(divK) + 1
else 
    B = round(divK)
end

%calculo de BT
BT = 1/double(B*T)
PoloComp = -BT

%Calculo do compensador Gc(S)
%Gc =@(S) (S - ZeroE)/(S + BT)
Gc =@(S) (S - ZeroE)/(S + BT);
Gc(S)
PoloGc = pole(Gc(S))

%GcG e local de raizes
%A seguir ser�o plotadas as duas curvas juntas. Encontre o polo na linha
%vermelha onde "Damping == Amortecimento1" e "Frequency == Wn1"
%Ap�s isso, encontre um polo na linha verde que fique alinhado ao polo
%escolhido na vermelha e � origem do sistema

GcG = @(S) Gc(S) * G(S) * 2*S; %se a realimenta��o nao for unitaria multiplique aqui

GcG(S)
figure;
rlocus(G(S), 'r');
hold;
rlocus(GcG(S), 'g')

PolosGcG1 = -7.78 + 8.26*j;
PolosGcG2 = -7.78 - 8.26*j;
%C�lculo anal�tico de Kc (ganho do compensador)
s=PolosGcG1;

Kc=1/abs(GcG(s))

%Nova Gc com o ganho vira o compensador:
GcK = @(S) Kc * Gc(S);
GcK(S)

Gmfc=feedback(GcK(S)*G(S),1);
%Polos de malha fechada com compensa��o
PolosGmfc = pole(Gmfc)
ZerosGmfc = zero(Gmfc)


%Erro sistema compensado
Y2 = GcK(X) * G(X)  %aqui usa a equa��o de degrau/rampa/parabolica
KvComp = vpa(limit(Y2, X, 0)) %vpa retorna o decimal da resposta
ErroComp = 1/KvComp


