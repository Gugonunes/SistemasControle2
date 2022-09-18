clc
clear all
syms x
%Amortecimento
Sobressinal = 0.05
eqn = (exp((-x*pi)/(sqrt(1-x^2)))) == Sobressinal;
solx = single(solve(eqn, x));
x=solx(1,1);
Amortecimento = x

%testando
teste = (exp((-x*pi)/(sqrt(1-x^2))))

%Wn
Ts = 0.5;
Wn = 4/(x*Ts)

%Polos dominantes:
S1 = -x*Wn + j*Wn*(sqrt(1-x^2))
S2 = -x*Wn - j*Wn*(sqrt(1-x^2))