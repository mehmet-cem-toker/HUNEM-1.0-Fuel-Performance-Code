
function [oxy_conc,i_step,t]=bcond(oxy_conc,i_step,t);
 persistent firstCall 
 ; 
 if isempty(firstCall),firstCall=1;end; 

 firstCall=0;
 oxy_conc(1) = 1526.0;
 oxy_conc(i_step) =(1.5494-9.7e-5.*t).*1000.0;

 %
end %subroutine bcond


