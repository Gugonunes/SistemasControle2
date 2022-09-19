close all;
clear all;
clc;

S=tf('s');
%Insira a G(S) abaixo:
G=@(S) (20/((S+1)*(S+4)));
G(S)
%comando de realimenta�ao
Gmf = feedback(G(S),1)
%Polos de malha fechada
Polos = pole(Gmf)

%Insira o Zero escolhido(arbitr�rio):
ZeroE = -0.1;
T = 1/(-ZeroE)

%Calculo de Beta:
%calculo do Kv:
syms X
Y=G(X) %aqui usa a equa��o de degrau/rampa/parabolica
Kv = vpa(limit(Y, X, 0)) %vpa retorna o decimal da resposta

%TODO: ajustar funçoes para cada tipo de entrada

%calculando o erro em regime permanente
erro = 1/(1+Kv) %coloca 1+kv se for degrau
%Erro desejado do sistema:
erroD=0.1;
Kv2 = 1/erroD;
divK = Kv2/Kv
Y2= (divK)-(floor(divK));
if Y2 < 0.5
    B = round(divK) + 1
else 
    B = round(divK)
end

%calculo de BT
BT = 1/double(B*T)

%Calculo de Gc(S)
%Gc =@(S) (S - ZeroE)/(S + BT)
Gc =@(S) (S - ZeroE)/(S + 0.001);
Gc(S)
PoloGc = pole(Gc(S))
%GcG e local de raizes
GcG = @(S) Gc(S) * G(S);
GcG(S)
figure;
rlocus(G(S));
hold;
rlocus(Gc(S)*G(S))

%Pegue os polos onde o amortecimento e o Wn s�o os calculados e anote
%abaixo
PolosGcG1 = -2.46 + 4.17*j;
PolosGcG2 = -0.312 - 0.552*j;
%C�lculo anal�tico de Kc
s=PolosGcG1;
Kc=1/abs(GcG(s))

%Nova Gc com o ganho vira o compensador:
GcK = @(S) Kc * Gc(S)

Gmfc=feedback(GcK(S)*G(S),1);
%Polos de malha fechada com compensa��o
PolosGmfc = pole(Gmfc)
ZerosGmfc = zero(Gmfc)

%Resposta ao degrau
%figure;
%step(Gmf);
%hold;
%step(Gmfc);
%legend('Sem compensação', 'Com compensação');

%Erro sistema compensado
Y2 = GcK(X) * G(X)
KvComp = vpa(limit(Y2, X, 0)) %vpa retorna o decimal da resposta
ErroComp = 1/KvComp
% %Lugar das ra�zes da planta e planta compensada
% figure;
% rlocus(G);
% legend('G(s)');
% figure;
% rlocus(Gc*G);
% legend('Gc(s)G(s)');

%Resposta a rampa
Gi=tf(1,[1 0]);
figure;
step(Gi,'b',50);
hold;
step(Gi*Gmf,'r',50);
step(Gi*Gmfc,'k',50);
title('Ramp Response');
legend('Refer�ncia','Sem compensa��o', 'Com compensa��o');


%Erros
[Yi t]=step(Gi,'b',linspace(0,200,2000));
[Y1 t]=step(Gi*Gmf,'r',linspace(0,200,2000));
[Y2 t]=step(Gi*Gmfc,'k',linspace(0,200,2000));
erro_MF=Yi-Y1;
erro_MF_C=Yi-Y2;

%Exibe erros
figure;
plot(t,erro_MF,'r');
hold;
plot(t,erro_MF_C,'b');
legend('Erro sem compensador','Erro com compensador');
xlabel('t(s)');
ylabel('Erro');
