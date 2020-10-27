%Constant Values
radius = 0.001; 
uf = 0.084;
pf = 920;
ps = 8960;
Volume = (4/3*pi*radius^3); 
mass = ps*Volume;
gravity = 9.81; 
% Inital Conditions: x'(0) = 0 and x(0) = 1
F = (6*pi*uf*radius)/mass;
MD = gravity * (1-(pf/ps));
k1 = MD / F^2;
k2 = 1 - k1;
X_1 = @(t)((MD/F) + k1 * F * exp(-F*t));
X = @(t)((MD/F) * t + k1 * exp(-F*t) + k2);
fplot(X, [0, 50]);
hold on;

syms t;
T1 = vpasolve(t*(MD/F) + k1*exp(-F*t) + k2 == 0, t);

% deltaT = [0.1, 1, 10];
% 
% for n = 1:3
%     h = deltaT(n);
%     x = 0:h:50;
%     y = zeros(1,length(x)); 
%     y(1) = 1;
%     for i=1:(length(x)-1)
%         k_1 = X_1(x(i));
%         k_2 = X_1(x(i)+h/2);
%         k_3 = X_1(x(i)+h/2);
%         k_4 = X_1(x(i)+h);
%         y(i+1) = y(i) + (1/6)*(k_1+2*k_2+2*k_3+k_4)*h;
%     end
%     plot(x, y);
%     hold on;
% end
% hold off;