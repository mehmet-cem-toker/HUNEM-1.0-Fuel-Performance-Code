function [oxy_conc,i_step,dx,kutle_kazanimi]=trap(oxy_conc,i_step,dx,kutle_kazanimi);
 persistent firstCall i sum_ml kutle_dn 
 ; 
 if isempty(firstCall),firstCall=1;end; 

 if firstCall;
  i=0;
  sum_ml=0;
  kutle_dn=0;
 end
 firstCall=0;

 sum_ml = oxy_conc(1);
 for i = 2: i_step - 1
  sum_ml = sum_ml + 2.0.*oxy_conc(i);
 end
 i = fix(i_step - 1+1);
 kutle_dn =(dx./2.0).*(sum_ml+oxy_conc(i_step));
 %
 %  To convert the kutle_dnt from (mg/cm2) to (mg/dm2)
 %
 %
 kutle_kazanimi = kutle_dn.*100.0;
 %
end %subroutine trap

%-------------------------------------------------------------------------------------


