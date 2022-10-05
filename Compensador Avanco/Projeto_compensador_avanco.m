close all;
clear all;
clc;

S=tf('s');
%Insira a G(S) abaixo:
G=@(S) 16/(S*(S+4));
G(S)
%comando de realimenta�ao
Gmf=feedback(G(S),1)
%Polos de malha fechada
Polos = pole(Gmf)

%Polos Malha fechada:
%Caso ja tenha o armotecimento substitua abaixo:
amort2 = 0.69;
Wn2 = 11.59;

S1 = (-amort2*Wn2) + j*Wn2*(sqrt(1-amort2^2))
S2 = (-amort2*Wn2) - j*Wn2*(sqrt(1-amort2^2))

%S1 = (-1) + j*(sqrt(3))
%S2 = (-1) - j*(sqrt(3))

%Verifica��o da condi��o de �ngulo
Y=S1;
x=angle(G(Y))*180/pi %O resultado � em rad que � convertido para graus.
if x > 0
    phi = 180 - x
else
    phi = -180 - x    
end

%IMPORTANTE: Analisar se o polo ta alinhado com o zero ou polo escolhido.
%nesse caso deve ser feita a altera��o do angulo, pois o angulo que
%queremos � do o do novo polo
%phi = 43.6  

%Compensador
syms n real
R = real(Y);
I = imag(Y);

%Insira o zero escolhido:
ZeroComp = -8; %Em 99% dos casos � a parte real do polo

dist = tan(phi*pi/180)*I;
PoloComp = ZeroComp - dist

T =@(S) (S-ZeroComp)/(S-PoloComp);
%C�lculo de Kc
Kc = 1/abs(T(Y)*G(Y))

Gc = Kc * T(S)


%Planta com compensa��o em malha fechada
Gmfc=feedback(Gc*G(S),1);
Gmfc=minreal(Gmfc)
%Polos de MF com compensa��o
pole(Gmfc)

%Resposta ao degrau
figure;
step(Gmf);
hold;
step(Gmfc);
legend('Sem compensa��o', 'Com compensa��o');

%Lugar das ra�zes da planta compensada
figure;
rlocus(Gc*G(S));