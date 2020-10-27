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
X_1 = @(t)(MD/F) + k1 * F * exp(-F*t);
X = @(t)((MD/F) * t + k1 * exp(-F*t) + k2);
newY = @(x) (x*(0.2087) + 0.0049*exp(-42.1875*x) + 0.9951);

% syms t;
% E = (t * (MD/F) + k1 * exp(-F*t) + k2) == 0;
% E = (1 + (t *(-F/MD) + k1 * (1/(-exp(-F*t))) + k2 == 0));
% T1 = vpasolve(E, t);
% T1
% syms x;
% S = vpasolve(x+1 == 2, x);
% S
apprx = fplot(X, [0, 50]);
hold on;


Ts = [0.1, 1, 10];
for n = 1:3
    deltaT = Ts(n);
    t = 0:deltaT:50;
    XTrue = zeros(1,length(t)); 
    XTrue(1) = 1;
    for i=1:(length(t)-1)
        k_1 = X_1(t(i));
        k_2 = X_1(t(i)+deltaT/2);
        k_3 = X_1(t(i)+deltaT/2);
        k_4 = X_1(t(i)+deltaT);
        XTrue(i+1) = XTrue(i) + (1/6)*(k_1+2*k_2+2*k_3+k_4)*deltaT;
    end
%     if deltaT == 0.1
%         Tplot1 = plot(t, XTrue);
%     elseif deltaT == 1
%         Tplot2 = plot(t, XTrue);
%     elseif deltaT == 10
%         Tplot3 = plot(t, XTrue);
%     end
end
% legend([apprx Tplot1 Tplot2 Tplot3], ["Approximate", "True-0.1s", "True-1s", "True-10s"])
hold on;
hold off;