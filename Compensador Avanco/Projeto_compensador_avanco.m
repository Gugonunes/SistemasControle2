close all;
clear all;
clc;

S=tf('s');
%Insira a G(S) abaixo:
G=@(S) 16/(S*(S+4));
G(S)
%comando de realimentaçao
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

%Verificação da condição de ângulo
Y=S1;
x=angle(G(Y))*180/pi %O resultado é em rad que é convertido para graus.
if x > 0
    phi = 180 - x
else
    phi = -180 - x    
end

%IMPORTANTE: Analisar se o polo ta alinhado com o zero ou polo escolhido.
%nesse caso deve ser feita a alteração do angulo, pois o angulo que
%queremos é do o do novo polo
%phi = 43.6  

%Compensador
syms n real
R = real(Y);
I = imag(Y);

%Insira o zero escolhido:
ZeroComp = -8; %Em 99% dos casos é a parte real do polo

dist = tan(phi*pi/180)*I;
PoloComp = ZeroComp - dist

T =@(S) (S-ZeroComp)/(S-PoloComp);
%Cálculo de Kc
Kc = 1/abs(T(Y)*G(Y))

Gc = Kc * T(S)


%Planta com compensação em malha fechada
Gmfc=feedback(Gc*G(S),1);
Gmfc=minreal(Gmfc)
%Polos de MF com compensação
pole(Gmfc)

%Resposta ao degrau
figure;
step(Gmf);
hold;
step(Gmfc);
legend('Sem compensação', 'Com compensação');

%Lugar das raízes da planta compensada
figure;
rlocus(Gc*G(S));