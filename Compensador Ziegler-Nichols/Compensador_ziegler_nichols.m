%https://www.notion.so/Prova-ad7c43e714d543efafb3f6d82b0427f8

%Para ser utilizado, o controlador deve estar implementado na forma:
%Gc(S) = Kp ( 1 + 1/Ti*s + Td*s)

%Primeiro método de ziegler-nichols

%OBS: Se ouver um integrador ou par completo conjugado dominante, entao nao
%sera possivel usar o método

%1º Obter resposta em degrau do sistema em malha aberta
%2º A planta deve exibir uma resposta em forma de S
%3º Obter o tempo de atraso L e a constante de tempo T
%4º Escolher os parametros Kp, Ti e Td de acordo com a tabela:

%   TIPO DE    |        KP      |       Ti       |     Td
% CONTROLADOR  |                |                |
%-----------------------------------------------------------
%      P       |        T/L     |       inf      |      0
%      PI      |      0.9*T/L   |       L/0.3    |      0
%      PID     |      1.2*T/L   |        2L      |    0.5*L


%Segundo método

%1º Obter a resposta ao degrau do sistema em malha fechada utilizando um
%controlador proporcional
%2º Aumentar o ganho Kp até atingir o valor critico Kcr onde a saída
%apresenta oscilações sustentadas.
%3º Anotar o valor do ganho Kcr e o periodo de oscilação Pcr
%3.1 Se precisar resolve o polimonio pela tabela de Houth-Hurwitz e acha o
%Kcr
%Substitui esse Kcr na equação caracteristica (a de baixo) e acha as raizes
%W = raiz positiva
%Pcr=2*pi/W
%4º Escolher os parametros Kp, Ti e Td de acordo com a tabela:

%   TIPO DE    |        KP      |       Ti       |     Td
% CONTROLADOR  |                |                |
%-----------------------------------------------------------
%      P       |     0.5*Kcr    |       inf      |      0
%      PI      |     0.45*Kcr   |   (1/1.2)*Pcr  |      0
%      PID     |     0.6*Kcr    |     0.5*Pcr    |    0.125Pcr

close all;
clear all;
clc;

S=tf('s');
%Insira a G(S) abaixo:
%Testando Kps: 
Kpteste = 100
G=@(S) Kpteste/(S^2 + 2*S + 2);
%Tipo: PID
%Como possui polo na origem, metodo 1 nao pode ser usado (a curva 
% nao tem forma de 'S')

Gmf = feedback(G(S), 1)

step(Gmf)

%Como nao apresenta oscilaçoes, o segundo metodo nao é aplicavel

%Podemos usar Houth-Hurwitz para determinar o Kcr ( ganho critico )

%Função de transferencia = Kp*G(S)/(1+ Kp*G(S))

%joga no symbolab e pega a parte de baixo:
%GDen = @(S)  S^3 + (6+Kp)*S^2 + (5 + 5*Kp)*S + 6*Kp

%Montando a tabela
% S^3      1          5+5Kp 
%
% S^2     6+Kp         6Kp
%
% S^1     C1
%
% S^0     6Kp
%
% C1 = -((1*6Kp) - (6+Kp)*(5+5Kp))/(6+Kp)
% C1 = (5kp^2 + 29Kp + 30)   / 6+ Kp

%Como a primeira coluna é sempre positiva, nenhum ganho jamais ira levar o
%sistema à instabilidade, portanto nao existe ganho critico
%Logo o segundo método nao pode ser aplicado



