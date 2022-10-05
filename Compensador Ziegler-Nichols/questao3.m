%Questao 3 método 1
close all;
clear all;
clc;

S=tf('s');
%Insira a G(S) abaixo:
G=@(S) 10/((S+1)*(S+5));
G(S)

%Polos sem compensação
PolosSemComp = pole(G(S))

%Como só tem polos reias e nao tem polo na origem, podemos usar o metodo 1
L = 0.106
T = 1.62 - L
%1.2*T/L   |        2L      |    0.5*L

Kp = 1.2*T/L
Ti = 2*L
Td = 0.5*L

C = @(S) minreal(Kp*( 1 + (1/(Ti*S)) + (Td*S)));
C(S)

%Simulação (pega o sobressinal daqui)
step(feedback(C(S)*G(S), 1))
hold()
figure()

%Para diminuir o MP aumentamos o Td
Td = 0.075

C = @(S) minreal(Kp*( 1 + (1/(Ti*S)) + (Td*S)));
C(S)

%Nova simulação (pega o sobressinal daqui)
step(feedback(C(S)*G(S), 1))


