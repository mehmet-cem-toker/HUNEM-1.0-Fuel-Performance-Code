
%---------------------------------------------------------------------------------------
function [dx,dt,dif_coef,i_step,oxy_conc,dloc,a,b,c,tt]=ftrdg(dx,dt,dif_coef,i_step,oxy_conc,dloc,a,b,c,tt);
 persistent dd ee firstCall i n ro 
 ; 
 if isempty(firstCall),firstCall=1;end; 

 if firstCall;
  dd=0;
  ee=0;
  i=0;
  n=0;
  ro=0;
 end
 firstCall=0;
 %
 % This subroutine forms the tridiagonal matix.
 %
 % The generic form of the equation is:
 % A*oxy_conc(I-1) + B*oxy_conc(I) + C*oxy_conc(I+1) = R
 %

 ro = 0.48;
 n = fix(i_step - 2);
 dd =(dif_coef.*dt)./dx.^2;
 ee =(dif_coef.*dt)./2.0.*ro.*dx;
 a(1) = 0.0;
 for i = 2: n
  a(i) = -(dd-ee);
 end
 i = fix(n+1);
 c(n) = 0.0;
 for i = 1: n
  b(i) = 1.0 +(2.0.*dd);
 end
 i = fix(n+1);

 for i = 1: n
  tt(i) = dloc(i);
  if(i == 1)
   tt(i) = tt(i) +((dd-ee).*oxy_conc(1));
  end
  if(i == n)
   tt(i) = tt(i) +((dd-ee).*oxy_conc(i_step));
  end
 end
 i = fix(n+1);
end %subroutine ftrdg


