%Questao 3 método 1
close all;
clear all;
clc;

S=tf('s');
%Insira a G(S) abaixo:
G=@(S) 2/((S^3)+(4*S^2)+(6*S)+4);
G(S)

%Polos sem compensação
PolosSemComp = pole(G(S))

%Como tem polos complexos, nao se pode utilizar o metodo 1
step(G(S))

Gmf = feedback(G(S),1)
figure()
step(feedback(Gmf*9, 1))

%Ganho critico = 9 (fui no chute até dar)
Kcr = 9
Pcr = 4.06 - 1.5
%PID     |     0.6*Kcr    |     0.5*Pcr    |    0.125Pcr
Kp = 0.6*Kcr
Ti = 0.5*Pcr
Td = 0.125*Pcr

S=tf('s');
Gc = @(S) Kp * ( 1 + 1/Ti*S + Td*S);
Gc(S)
Kp
Ki = Kp/Ti
Kd = Kp*Ti
Total = Kp+Ki+Kd