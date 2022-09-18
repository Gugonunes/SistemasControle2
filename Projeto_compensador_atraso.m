close all;
clear all;
clc;

%Planta
num=1.06;
den=[1 3 2 0];
G=tf(num,den);
%Planta sem compensa��o em malha fechada
Gmf=feedback(G,1);
%Polos de malha fechada sem compensa��o
pole(Gmf)

%Lugar das ra�zes de Gc(s)G(s) para projeto do ganho Kc
numc=[1 0.05];
denc=[1 0.005];
Gcp=tf(numc,denc);
figure;
rlocus(G);
hold;
rlocus(Gcp*G);

%C�lculo anal�tico de Kc
s=-0.31+j*0.55;
Kc=1/abs(((s+0.05)*1.06)/((s+0.005)*(s^3+3*s^2+2*s)))

%Compensador
numc=0.97*[1 0.05];
denc=[1 0.005];
Gc=tf(numc,denc);
%Planta com compensa��o em malha fechada
Gmfc=feedback(Gc*G,1);
%Polos de malha fechada com compensa��o
pole(Gmfc)

%Resposta ao degrau
figure;
step(Gmf);
hold;
step(Gmfc);
legend('Sem compensa��o', 'Com compensa��o');

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
