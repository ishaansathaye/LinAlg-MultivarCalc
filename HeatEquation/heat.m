%%% Heat Equation Solver %%%

%% Parameters
k=double(1.11*10^(-4)); %thermal diffusivity of copper (meters squared per second).

%% Meshing
xL=0; xR=12; %Left and Right x-bouries (meters)
dx=1; Nx=1+ceil((xR-xL)/dx); %spacial step (secoonds) and Number of spacial steps. 
X=xL+[0:Nx-1].*dx; %spacial coordinates (meters)

tI=0; tF=6*60*60; %Initial and Final t-boundaries (seconds)
dt=360; Nt=1+ceil((tF-tI)/dt); %time step (secoonds) and Number of time steps. 
T=tI+[0:Nt-1].*dt; %time coordinates (seconds)

NxI=Nx-2; %Number of interior spacial nodes per t
NtI=Nt-1; %Number of interior time nodes per x
NI=NxI*NtI; %total number of interior nodes

%% Indexing
xt2n =@(x,t) (t-1)*(NxI)+x; %assigns a number to each interior node based on how many dx's and dt's away from (xL,tI) it is. (assumes rows are x and columns are t and numbers top-down then left-right)
n2xt =@(n) [1+mod(n-1,(NxI)),ceil(n/(NxI))]; %inverse function to xt2n; gives the coordines (in dx an dt's away from (xL, tI)) of the node numberd n

%% Conditions
uI =@(x) (x./6).^3; %initial condition 
uL=uI(xL); uR=uI(xR); %boundary conditions

%% Coefficients;
Cxt=-((1./dt)+((2*k)./(dx.^2))); %Coefficient for  (x,t) terms.
Cxp=k./(dx.^2); %Coefficient for (x+1,t) terms.
Cxm=k./(dx.^2); %Coefficient for (x-1,t) terms.
Ctm=1./dt; %Coefficient for (x,t-1) terms.


%% Initalization
M=sparse(NI,NI); %transition matrix (only includes interior nodes!) NOTE: sparse matricies are more efficient for large matricies with many 0's
B=zeros(NI,1); %boundary vector

for n=1:NI %loop over all interior nodes
    p=n2xt(n);x=p(1);t=p(2); %find the x and t indexes of node n
    
   %(x-1,t) terms
    if x-1==0 %if the node is next to the left boundary...
        B(n)=B(n)-Cxm.*uL; %...add the propper term to the boundary vector.
    else %Otherwise,...
        M(n,xt2n(x-1,t))=Cxm; %...put the coefficient in the row for (x,t) and the column for (x-1,t).
    end
    
   %(x+1,t) terms
    if x+1==Nx-1 %if the node is next to the right boundary...
        B(n)=B(n)-Cxp.*uR; %...add the propper term to the boundary vector.
    else %Otherwise,...
        M(n,xt2n(x+1,t))=Cxp; %...put the coefficient in the row for (x,t) and the column for (x+1,t).
    end
    
   %(x,t-1) terms
    if t-1==0 %if the node is next to the intitial time...
        B(n)=B(n)-Ctm.*uI(X(x+1));%...add the propper term to the boundary vector.
    else%Otherwise,...
        M(n,xt2n(x,t-1))=Ctm;%...put the coefficient in the row for (x,t) and the column for (x,t-1).
    end

   %(x,t) terms
    M(n,n)=Cxt;    
end

%% Matrix Inversion
UI=M\B; %Solve for u(x,t) on the interior "a\b" is equivalent to (a^-1)*b, but more accurate in this circumstance

%% Boundaries Affixing
UI2=reshape(UI,NxI,NtI); %Turn the vector into a matrix the shape of the interior mesh.
U=vertcat(repmat(uL,[1,NtI]),UI2,repmat(uR,[1,NtI])); %Place the x-boundary values on the top and bottom.
U=horzcat(uI(X'),U);%Place the t-boundary values on the left
U=U'; %Transpose so that x goes from left to right and t from top to bottom

%% Analytic Solution
Nm=100;%Maximum value of summation index for fourier series
AVm =@(x,t,m) (1/18).*(((xR./(m.*pi)).^3).*((-1).^m)).*sin(pi.*m.*x./xR).*exp(-k.*t.*(pi.*m./xR).^2); %Analytic solution v(x,t)
AUe =@(x) ((uR-uL).*x./xR)+uL; %Analytic equilibrium temperature u_e(x)
m=reshape(1:Nm,[1,1,Nm]); %make a vector that goes out into 3D with m=1:Nm
A=AVm(repmat(X,[Nt,1,Nm]),repmat(T',[1,Nx,Nm]),repmat(m,[Nt,Nx,1]));%make a big 3D matrix of the x coordinates, t coordinates, and m index vlaues, then find v_m(x,t) at each one.
A=sum(A,3)+AUe(repmat(X,[Nt,1]));%Sum over the m dimension (sum the fourier series), then add on the equilibrium temperature to get u(x,t);

%% Display
%plot(X,U(end,:),X,A(end,:),':')) %plot the last line vs. distance, (the ":" makes the second line dashed). This is sufficient, but I like to animate things:

%% Animation
for t=1:Nt
    plot(X,U(t,:),X,A(t,:),':') %plot temp vs. x
    title("t="+floor(T(t)/3600)+" hours") %Plot Title
    xlabel('Position (meters)') %x-axis label
    ylabel('Temperature (K)') %y-axis label
    drawnow limitrate %slows things down to a manageable rate.
end