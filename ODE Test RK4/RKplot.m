%%% Initial Conditions %%%
x0 = 1;
y0 = 1;
xN = 2;
dx = 0.1;
N = ceil((xN-x0)/dx);


x = x0;
y = x0;
Y = zeros(1, N);
for n = 1:N
    y = RK(x, y, dx);
    x = x + dx;
    Y(1,n)=y;
end

X = (0:N)*dx;
Y = horzcat([y0], Y);
Yt = exp(X);
plot(X, Yt, X, Y)
legend(["True", "Approximate"])