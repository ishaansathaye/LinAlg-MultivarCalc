
k=double(1.11*10^(-4));

%% Numerical
xL=0; xR=12; %boundaries
dx=1; Nx=1+ceil((xR-xL)/dx); %steps 
X=xL+[0:Nx-1].*dx; %spacial coords
tI=0; tF=6*60*60; %t-boundaries (seconds)
dt=360; Nt=1+ceil((tF-tI)/dt); %time step
T=tI+[0:Nt-1].*dt; %time coords
NxI=Nx-2; %interior nodes
NtI=Nt-1; %interior nodes for x
NI=NxI*NtI; %total interior nodes

xt2n =@(x,t) (t-1)*(NxI)+x;
n2xt =@(n) [1+mod(n-1,(NxI)),ceil(n/(NxI))];
uI =@(x) (x./6).^3; %initial condition 
uL=uI(xL); %boundary condition
uR=uI(xR); %boundary condition

Cxt=-((1./dt)+((2*k)./(dx.^2)));
Cxp=k./(dx.^2);
Cxm=k./(dx.^2);
Ctm=1./dt;

M=sparse(NI,NI); %transition matrix
B=zeros(NI,1); %boundary vector

% For loop for interior nodes
for n=1:NI
    p=n2xt(n);x=p(1);t=p(2);
    if x-1==0 %node left bound
        B(n)=B(n)-Cxm.*uL;
    else 
        M(n,xt2n(x-1,t))=Cxm;
    end
    if x+1==Nx-1 %node right bound
        B(n)=B(n)-Cxp.*uR;
    else
        M(n,xt2n(x+1,t))=Cxp;
    end
    if t-1==0 %node at intial condition
        B(n)=B(n)-Ctm.*uI(X(x+1));
    else
        M(n,xt2n(x,t-1))=Ctm;
    end
    M(n,n)=Cxt;    
end

UI=M\B; %matrix
UI2=reshape(UI,NxI,NtI); %turn into matrix
U=vertcat(repmat(uL,[1,NtI]),UI2,repmat(uR,[1,NtI]));
U=horzcat(uI(X'),U);
U=U';

%% Analytical
Nm=1000;%max
AV =@(x,t,m) (1/20).*(((xR./(m.*pi)).^3).*((-1).^m)).*sin(pi.*m.*x./xR).*exp(-k.*t.*(pi.*m./xR).^2); %solution
AU =@(x) ((uR-uL).*x./xR)+uL; 
m=reshape(1:Nm,[1,1,Nm]);
A=AV(repmat(X,[Nt,1,Nm]),repmat(T',[1,Nx,Nm]),repmat(m,[Nt,Nx,1]));
A=sum(A,3)+AU(repmat(X,[Nt,1]));%u(x,t)
%%

plot(X,U(end,:),X,A(end,:),'-')





