close all;
clear all;
clc;

S=tf('s');
%Insira a G(S) abaixo:
G=@(S) (16/(S*(S+4)));
G(S)
%comando de realimenta�ao
Gmf=feedback(G(S),1)
%Polos de malha fechada
Polos = pole(Gmf)

%Lugar de raízes de G(S)
%rlocus(G)

%Insira os polos de malha fechada dominantes
S1 = -8 + j*8.389
S2 = -2 - 2*sqrt(3)*i

%TODO: Ajustar angulo negativo
%Verificação da condição de angulo
Y=S1
x=angle(G(Y))*180/pi %O resultado é em rad que é convertido para graus.
if x > 0
    phi = 180 - x
else
    phi = -180 - x    
end

%Compensador
syms n real
R = real(Y)
I = imag(Y)
newX = tan(phi*pi/180)*I
T =@(S) (S-R)/(S-(R-newX))
%C�lculo de Kc
Kc = 1/abs(T(Y)*G(Y))

Gc = Kc * T(S)


%Planta com compensação em malha fechada
Gmfc=feedback(Gc*G(S),1);
Gmfc=minreal(Gmfc)
%Polos de MF com compensa��o
pole(Gmfc)

%Resposta ao degrau
figure;
step(Gmf);
hold;
step(Gmfc);
legend('Sem compensação', 'Com compensação');

%Lugar das ra�zes da planta compensada
figure;
rlocus(Gc*G(S));