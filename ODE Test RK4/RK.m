function y=RK(x0, y0, dx)
%%% Derivative %%%
%Stored in the df function

%%% Butcher Tableu %%%
BUTCHER=[
    0 0 0 0 0
    1/2 1/2 0 0 0
    1/2 0 1/2 0 0 
    1 0 0 1 0
    0 1/6 1/3 1/3 1/6
    ];

%dx=0.1

C = BUTCHER(1:end-1, 1);
A = BUTCHER(1:end-1, 2:end);
B = BUTCHER(end, 2:end);
N = length(C);

F = zeros(N, 1);

for n=1:N
    slopes=A(n,:)*F(:,1);
    F(n,1) = df(x0+C(n)*dx, y0+slopes*dx);
end

y = y0+B+F+dx