function hunem(varargin)
 clear global;
 clear functions;
 global GlobInArgs nargs;
 nargs=0;
 for ii_=length(varargin):-1:1
  if ischar(varargin{ii_})
   nargs=ii_;
   eval(['global ',varargin{ii_},';',varargin{ii_},'=',num2str(varargin{ii_+1},15),';']);
  end
 end
 GlobInArgs={mfilename,varargin{1:nargs-1}};
 nargs=length(GlobInArgs);
 global unit2fid;
 if ~isempty(unit2fid), unit2fid={};
 end
 persistent SH_enine_400 SH_normal_400 SH_haddeleme_400 creep_str_400 SH_enine_300 SH_normal_300 SH_haddeleme_300 SH_enine_25 SH_normal_25 SH_haddeleme_25 ASF_haddeleme400 ASF_haddeleme ASF_enine ASF_enine400 ASF_normal400 a o2_at_weight lioh_coef normal b_NR b_TR trans rolling fast_neu_eff_coef ox_rate_const1 pickup_fraction_zr4 zr4_at_weight b c int_cond lioh_conc hconst dco dci co dloc oxy_conc nonoxi_cld_thck zro2_density dif_coef dt dx firstCall fast_neu_flx i i_step stp1 stp2  ASF_normal n num_lim num_step pbr heat_flux tt pre_trans post_trans solution times timesd t fuel_clad_temp oxi_clad_temp run_time d_time d_timet tk_cond tkk_cond zro2_tcd zro2_tc cld_thck cld_thckm clad_outer_temp ox_rate_u kutle_kazanimi heat_mass_eff total_mass_eff irr_mass_eff lioh_mass_eff wtc weight_trans x heat_thck_eff total_thck_eff irr_thck_eff lioh_thick_eff xxx z zrc4_yogunluk zpt zptu   format_100  format_103  format_104  format_111  format_122  format_128  format_133  format_222  format_223  format_224  format_299  format_442  format_443  format_444  format_445  format_446  format_53  format_55  format_552  format_553  format_554  format_56  format_67  format_68
 ; 
 if isempty(firstCall),firstCall=1;end; 

 if firstCall;
  format_100=['%7x','ZAMAN ARALIÐI, DT =','%12.6e',' sn'];
  format_103=['%7x','TOPLAM SÝMÜLASYON SÜRESÝ',' =','%12.4e','%2x',' sn ','%5x',' =','%12.5f','%2x',' gün'];
  format_104=['%7x','ZARF KALINLIÐI, cld_thck =','%7.4f',' cm'];
  format_111=['%7x','DIÞ ZARF SICAKLIÐI, clad_outer_temp =','%8.3f','%2x',' K'];
  format_122=[ '\n' ,'%4t','SÜRE (gün)','%22t',' KÜTLE KAZANIMI (mg/dm2)','%58t','OKSÝT KALINLIÐI (mikro m) ','%91t','SICAKLIK (K)','    DÝF. KAT. ','   HÝDROJEN KONSANTRASYONU ',' HÝD. KIRINIM GERÝLÝM ANÝZOTR.','         HÝD. AKMA DAVR. ETK. (Mpa) ','                           AKMA GERÝLÝM FARKI','                                                                                                        Gerinim Sertleþmesi Üsteli,n','       Sürünme Gerinimi (mm)'];
  format_128=['%19t','HEATF','%4x','LiOH','%5x','FNEU','%5x','TOTAL','%54t',' HEATF','%4x','LiOH','%4x','FNEU','%4x','TOTAL','%90t','Z-O','%6x','Y-Z','     (cm2/sn)','             (ppm)','               b_N/b_R', '     b_T/b_R', '             Enine Y.','   Haddeleme Y.',' Normal Y.', '   Haddeleme(25C)', '  Enine(25C) ', '   Normal(25C)','   Haddeleme(400C)','   Enine(400C)','   Normal(400C)',' SH.Enine(25C)',' SH.Normal(25C)','   SH.Hadde(25C)',' SH.Enine(300C)',' SH.Normal(300C)','   SH.Hadde(300C)',' SH.Enine(400C)',' SH.Normal(400C)','   SH.Hadde(400C)','  creep_str_400'];
  format_133=['%12.5f','%1x','~',repmat(['%1x','%8.2f'] ,1,4),'%53t','~',repmat(['%1x','%7.3f'] ,1,4),'%89t','%7.7f','%1x','%7.5f','%12.4e','%1x','%18f','%23e','%1x','%10f','%1x','%20f','%2x','%10f','%2x','%10f','%2x','%10f','%2x','%13f','%2x','%12f','%2x','%14f','%2x','%14f','%2x','%12f','%2x','%12f','%2x','%12f','%2x','%14f','%2x','%14f','%2x','%14f','%2x','%14f','%2x','%14f','%2x','%14f','%2x','%14f','%2x','%14f'];
  format_222=['%7x','ÝSÝ_AKÝSÝ, heat_flux =','%7.2f',' W/cm2'];
  format_223=['%7x','HÝZLÝ NÖTRON AKÝSÝ, fast_neu_flx =','%12.6e',' n/cm2.sn'];
  format_224=['%7x','[Li0H) KONSANTRASYONU, lioh_conc =','%12.6e',' mol/litre'];
  format_299=[ '\n' ,'************************************ZARF TAMAMEN OKSÝDE DÖNÜÞTÜ MÝSSÝON FAÝLED**********************************************************************************************************************************************************************************************************************************************************************'];
%  format_442=[ '\n' , '\n' ,'%7x','Oksit kütle kazanýmý ve oksit kalýnlýðý þu þekilde tanýmlandý:'];
%   format_443=['%15x','heat_mass_eff,heat_thck_eff ==> Isý akýsý katkýsý ile oksit katkýsý'];
%   format_444=['%15x','lioh_mass_eff,lioh_thick_eff ==> LiOH Katkýsý ile oksit kalýnlýðý'];
%   format_445=['%15x','irr_mass_eff,irr_thck_eff ==> Hýzlý nötron katkýsý ile oksit kalýnlýðý'];
%   format_446=['%15x','total_mass_eff,total_thck_eff ==> Yukarýdaki 3 faktörün toplamý ile oksit kalýnlýðý'];
%   format_53=['%18x','ZÝRKONYUM ESASLI ALAÞIMIN OKSÝDASYON MODELÝ', '\n' ];
%   format_55=['%2x','ZÝRKONYUM ESASLI ZARF MALZEMESÝ ÝÇÝN OKSÝJEN DÝFÜZYON DENKLEMÝNÝN ÇÖZÜMÜ:'];
%   format_552=[ '\n' ,'%15x','Dif. Kat. ==>OKSÝJEN DÝFÜZYON KATSAYISI'];
%   format_553=['%15x','O-Z ==> OKSÝT-ZARF ARA YÜZ SICAKLIÐI'];
%   format_554=['%15x','Y-Z ==> YAKIT-ZARF ARA YÜZ SICAKLIÐI', '\n' ];
    format_56=['**********************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************'];
%   format_67=[ '\n' ,'%10x','ZAMANA BAÐLI OKSÝT KALINLIÐININ HESAPLANMASI', '\n' ];
%   format_68=[ '\n' ,'%13x','( 1-D SÝLÝNDÝRÝK GEOMETRÝ )'];
  a=zeros(1,50);o2_at_weight=0; lioh_coef=0; fast_neu_eff_coef=0;zr4_at_weight=0;  b=zeros(1,50); c=zeros(1,50);b_NR=0;b_TR=0;int_cond=0; lioh_conc=0;lioh_thick_eff=0; xxx=0;z=0;zrc4_yogunluk=0;zpt=0;zptu=0;
  co=0;dloc=zeros(1,50); oxy_conc=zeros(1,50);nonoxi_cld_thck=0;dco=0;dci=0;zro2_density=0;dif_coef=0;dt=0; dx=0;fast_neu_flx=0; i=0;i_step=0; stp1=0;  n=0;
  num_lim=0; num_step=0;pbr=0; heat_flux=0; tt=zeros(1,50); pre_trans=0; post_trans=0; solution=zeros(1,50);times=0;timesd=0; t=0;fuel_clad_temp=0;oxi_clad_temp=0;run_time=0;
  d_time=0;d_timet=0;tk_cond=0;tkk_cond=0;zro2_tcd=0;zro2_tc=0;cld_thck=0;cld_thckm=0;clad_outer_temp=0;ox_rate_u=0;kutle_kazanimi=0;heat_mass_eff=0;total_mass_eff=0;irr_mass_eff=0;lioh_mass_eff=0;wtc=0;weight_trans=0;x=0;heat_thck_eff=0;total_thck_eff=0;irr_thck_eff=0;  
  
 end

 firstCall=0;
 heat_flux = 110; %(<68-180w/cm2)
 fast_neu_flx = 5*10^13;
 lioh_conc = 0.01;%molal vol. 
 clad_outer_temp = 603; %k
 num_lim = 10000;
 num_step = 100;
 cld_thck = 0.07; %cm
 dco=0.01072; %m
 dci=0.01072-(cld_thck*10e-2); %m
 pickup_fraction_zr4=0.175;
 cld_thckm = cld_thck.*1.0e4;%mmicro
 i_step = 12;
 n = fix(i_step - 2);
 dt = 8640;
 times = dt.*num_lim;
 timesd = times./(86400);

 %---------------------------------------------------------------------
 %    " Hunem-1.0.OUT "

 thismlfid=fopen(strtrim('Hunem-1.0.txt'),'w+');
 unit2fid{end+1,1}=10;
 unit2fid{end,2}=thismlfid;
 unit2fid{end,3}=0;
 unit2fid{end,4}='Hunem-1.0.txt';
 unit2fid{end,5}=0;
 [writeErrFlag]=writeFmt(10,[format_53]);
 [writeErrFlag]=writeFmt(10,[format_55]);
 [writeErrFlag]=writeFmt(10,[format_67]);
 [writeErrFlag]=writeFmt(10,[format_68]);
 [writeErrFlag]=writeFmt(10,[format_56]);
 [writeErrFlag]=writeFmt(10,[format_100],'dt');
 [writeErrFlag]=writeFmt(10,[format_104],'cld_thck');
 [writeErrFlag]=writeFmt(10,[format_111],'clad_outer_temp');
 [writeErrFlag]=writeFmt(10,[format_222],'heat_flux');
 [writeErrFlag]=writeFmt(10,[format_223],'fast_neu_flx');
 [writeErrFlag]=writeFmt(10,[format_224],'lioh_conc');
 [writeErrFlag]=writeFmt(10,[format_103],'times','timesd');
 [writeErrFlag]=writeFmt(10,[format_442]);
 [writeErrFlag]=writeFmt(10,[format_443]);
 [writeErrFlag]=writeFmt(10,[format_444]);
 [writeErrFlag]=writeFmt(10,[format_445]);
 [writeErrFlag]=writeFmt(10,[format_446]);
 [writeErrFlag]=writeFmt(10,[format_552]);
 [writeErrFlag]=writeFmt(10,[format_553]);
 [writeErrFlag]=writeFmt(10,[format_554]);
 [writeErrFlag]=writeFmt(10,[format_56]);

 stp1 = 0;
 stp2 = 0;
 run_time = 0.0;
 int_cond = 9.3e-4;
 t = clad_outer_temp;
 %------------------------------------------------------------------------------------
 % Set the initial condition:
 for i = 1: i_step
  oxy_conc(i) = int_cond;
  dloc(i) = int_cond;
 end
 i = fix(i_step+1);
 %------------------------------------------------------------------------------------
 % Set the boundary conditons:
 oxy_conc(1) = 1526.0;
 [writeErrFlag]=writeFmt(10,[format_122]);
 [writeErrFlag]=writeFmt(10,[format_128]);
 [writeErrFlag]=writeFmt(10,[format_56]);
 while (1);

  %------------------------------------------------------------------------------------
  %
  % oxy_conc için (N+1)nci adýmý hesaplama:
  %
  %    Ýterasyon sayaçlarýnýn artýþý ve  
  %    Maksimum iterasyon sayýsýnýn bulunmasý:

  stp1 = fix(stp1 + 1);
  stp1 = fix(stp1 + 1);
  run_time = run_time + dt;

  %------------------------------------------------------------------------------------
  % Oksit kütle kazaným hesabý Hillner modeli
  % kullanýlarak yapýlmýþtýr.
  % zrc4_yogunluk : zircaloy density
  % DENS: Zr02 yoðunluðu
  % zr4_at_weight : Zr-4 atom aðýrlýðý
  % o2_at_weight : oksijen atom aðýrlýðý
  % PBR  : Pilling-Bedworth oraný
  
  zrc4_yogunluk = 6.5;
  zr4_at_weight = 91.22;
  o2_at_weight = 32.0;
  pbr = 1.57;
  d_time = run_time./(24..*3600.);
  d_timet = 6.73e-7.*exp(11975.0./t);

  if(d_time <= d_timet)

   pre_trans =(6.36e11.*exp(-13636.0./t)).^0.333333; %pre-transition
   wtc = pre_trans.*d_time.^0.3333; 

   zpt = 1.0e-5.*pbr.*(zr4_at_weight.*wtc)./(o2_at_weight.*zrc4_yogunluk);
   zptu = zpt.*1.0e4;

  else;

   post_trans = 1.12e8.*exp(-12529.0./t);%post-transition
   wtc = post_trans.*d_time;

   zpt = 1.0e-5.*pbr.*(zr4_at_weight.*wtc)./(o2_at_weight.*zrc4_yogunluk);
   zptu = zpt.*1.0e4;
  end

  %
  %------------------------------------------------------------------------------------
  % The kutle_kazanimi gain at the transition , weight_trans (mg/dm2)
  %

  weight_trans = 7.53.*10.0.*exp(-553.6./t);

  zro2_density = 5.82;
  x = zptu.*1.0e-4;

  dif_coef = x.*x.*zro2_density.*32.0./(2.0.*run_time.*123.22.*(oxy_conc(1)-oxy_conc(i_step)).*(1.0e-3));
  z = sqrt(2.0.*3.8506.*(dif_coef./zro2_density).*((oxy_conc(1)-oxy_conc(i_step))./1000.0).*run_time);

  dx = z./(i_step);

  %------------------------------------------------------------------------------------
  %        cm to mikro m çevrimi,
  %
  %          ZU=Z*1.0E4
  %
  %------------------------------------------------------------------------------------
  % To determine the effect of the ÝSÝ_AKÝSÝ on the oxide/metal
  % interface temperature"TI"
  % tk_cond : "zirkaloy-4" sýcaklýða baðlý ýsý iletim katsayýsý,W/m.K
  % zro2_tc : "Zr02" sýcaklýða baðlý ýsý iletim katsayýsý,W/m.K


  tk_cond = 7.848 + 2.2e-2.*t - 1.676e-5.*t.^2.0 + 8.712e-9.*t.^3.0;
  tkk_cond = tk_cond.*1.0e-2;
  zro2_tc = 1.9599 - 2.41e-4.*t + 6.43e-7.*t.^2.0 - 1.94e-10.*t.^3.0;
  zro2_tcd = zro2_tc.*1.0e-2;

  % heat_flux : ýsý akýsý ,W/cm2
  % heat_flux = Q/alan
  % T : oksit/metal interface temperature,K
  % fuel_clad_temp : yakýt/yakýt zarfý ara yüz sýcaklýðý,K
  % nonoxi_cld_thck : oksitlenmemiþ yakýt zarfý kalýnlýðý,cm
  %
  pbr = 1.57;
  t = clad_outer_temp;
  if(heat_flux>0)
  oxi_clad_temp = t +(heat_flux.*z)./zro2_tcd;
  nonoxi_cld_thck = cld_thck - z./pbr;
  fuel_clad_temp = oxi_clad_temp +(heat_flux.*nonoxi_cld_thck)./tkk_cond;
  t = oxi_clad_temp;
  else
  oxi_clad_temp = t;
  nonoxi_cld_thck = cld_thck - z./pbr;
  fuel_clad_temp = oxi_clad_temp;
  t = oxi_clad_temp;
  end
  if(stp1 > num_lim)
   tempBreak=1;
   break;
  end

  % Üçgen denklem sistemini oluþturur:
  %
  [dx,dt,dif_coef,i_step,oxy_conc,dloc,a,b,c,tt]=ftrdg(dx,dt,dif_coef,i_step,oxy_conc,dloc,a,b,c,tt);
  %
  % Üçgen denklem çözücü fonksiyon:
  %
  [a,b,c,tt,solution,n]=trdg(a,b,c,tt,solution,n);
  for i = 2: i_step - 1
   dloc(i) = oxy_conc(i);
  end
  i = fix(i_step - 1+1);
  for i = 2: i_step - 1
   oxy_conc(i) = solution(i);
  end
  i = fix(i_step - 1+1);

  % Impose the boundary conditons:

  [oxy_conc,i_step,t]=bcond(oxy_conc,i_step,t);
  
  [oxy_conc,i_step,dx,kutle_kazanimi]=trap(oxy_conc,i_step,dx,kutle_kazanimi);
  %
  % isi akisinin oksit kütle kazancina katkisi,heat_mass_eff (mg/dm2)
  % isi akisinin oksit kalinliðina katkisi,heat_thck_eff (um)
  %
  %
  heat_mass_eff = kutle_kazanimi;
  heat_thck_eff = 1.0e-1.*pbr.*(zr4_at_weight.*heat_mass_eff)./(o2_at_weight.*zrc4_yogunluk);
  if(lioh_conc>0)
  lioh_coef = 1.0 + 13.125.*lioh_conc;
  else
  lioh_coef=0;
  end
  lioh_mass_eff = heat_mass_eff.*lioh_coef;
  total_mass_eff = lioh_mass_eff+heat_mass_eff;
  lioh_thick_eff = 1.0e-1.*pbr.*(zr4_at_weight.*lioh_mass_eff)./(o2_at_weight.*zrc4_yogunluk);
  total_thck_eff = lioh_thick_eff+heat_thck_eff;
  ox_rate_u = 2.59e8;
  ox_rate_const1 = 7.46e-15;
  co = 8.04e7;
  hconst=(pickup_fraction_zr4*5.8*dco*total_thck_eff*16*10)/(6.5*(dco^2-dci^2)*123);

  if((heat_mass_eff >= weight_trans) &&(fast_neu_flx >= 1.0e12))
   fast_neu_eff_coef = 1.0+(ox_rate_u./co).*(ox_rate_const1.*fast_neu_flx).^0.24;
   irr_mass_eff = heat_mass_eff.*fast_neu_eff_coef;
    total_mass_eff = lioh_mass_eff+heat_mass_eff+irr_mass_eff;
    hconst=(pickup_fraction_zr4*5.8*dco*total_thck_eff*16*10)/(6.5*(dco^2-dci^2)*123);
  else
   fast_neu_eff_coef = 1.10;
   irr_mass_eff = heat_mass_eff.*fast_neu_eff_coef;
   total_mass_eff = lioh_mass_eff+heat_mass_eff+irr_mass_eff;
   hconst=(pickup_fraction_zr4*5.8*dco*total_thck_eff*16*10)/(6.5*(dco^2-dci^2)*123);

  end

  irr_thck_eff = 1.0e-1.*pbr.*(zr4_at_weight.*irr_mass_eff)./(o2_at_weight.*zrc4_yogunluk);
  total_thck_eff =irr_thck_eff+lioh_thick_eff+heat_thck_eff  ;
  xxx = pbr.*cld_thckm;%limiting point/if statement
  hconst=(pickup_fraction_zr4*5.8*dco*total_thck_eff*16*10)/(6.5*(dco^2-dci^2)*123);
  
%****************************************************************************************************************%
% 
% HÝDROJENÝN YAKIT ZARF MALZEMESÝ DAVRANIÞI ÜZERÝNDE ETKÝSÝNÝN ÝNCELENMESÝ
%           
%*****************************************************************************************************************%


  %HÝDROJENE BAÐLI AKMA GERÝNÝM ANÝZOTROPÝSÝ
  
  if(hconst< 50)&&(hconst > 0)
      b_NR =1.79 + (1.82 - 1.79)/(1 + (hconst/444.5019)^56.38393);
      b_TR =1.022 + (1.093333 - 1.022)/(1 + (hconst/666.603)^58.28871);
      trans= 520 + (560 - 520)/(1 + (hconst/52.39457)^23.4847);
      rolling= 562.754 - 0.4016484*hconst + 0.001043805*hconst^2 - 9.379713e-7*hconst^3 + 2.952348e-10*hconst^4;
      normal=990 + 1.085693*hconst - 0.007470016*hconst^2 + 0.00001350288*hconst^3 - 7.158556e-9*hconst^4;
   elseif((hconst >= 50) &&(hconst < 300))
      b_NR=1.79 + (1.82 - 1.79)/(1 + (hconst/444.5019)^56.38393);
      b_TR =1.022 + (1.093333 - 1.022)/(1 + (hconst/666.603)^58.28871);
      trans= 520 + (560 - 520)/(1 + (hconst/52.39457)^23.4847);
      rolling= 562.754 - 0.4016484*hconst + 0.001043805*hconst^2 - 9.379713e-7*hconst^3 + 2.952348e-10*hconst^4;
      normal=990 + 1.085693*hconst - 0.007470016*hconst^2 + 0.00001350288*hconst^3 - 7.158556e-9*hconst^4;
  elseif ((hconst >= 300) &&(hconst < 450))
      b_NR=1.79 + (1.82 - 1.79)/(1 + (hconst/444.5019)^56.38393);
      b_TR =1.022 + (1.093333 - 1.022)/(1 + (hconst/666.603)^58.28871);
      trans= 520 + (560 - 520)/(1 + (hconst/52.39457)^23.4847);
      rolling= 562.754 - 0.4016484*hconst + 0.001043805*hconst^2 - 9.379713e-7*hconst^3 + 2.952348e-10*hconst^4;
      normal=990 + 1.085693*hconst - 0.007470016*hconst^2 + 0.00001350288*hconst^3 - 7.158556e-9*hconst^4;
  else
      b_NR=1.79 + (1.82 - 1.79)/(1 + (hconst/444.5019)^56.38393);
      b_TR =1.022 + (1.093333 - 1.022)/(1 + (hconst/666.603)^58.28871);
      trans= 520 + (560 - 520)/(1 + (hconst/52.39457)^23.4847);
      rolling= 562.754 - 0.4016484*hconst + 0.001043805*hconst^2 - 9.379713e-7*hconst^3 + 2.952348e-10*hconst^4;
      normal=990 + 1.085693*hconst - 0.007470016*hconst^2 + 0.00001350288*hconst^3 - 7.158556e-9*hconst^4;
  end
 %************************************************************************************************************************
 %
 % AKMA SINIR FARKI HESAPLAMA
 %
 %***********************************************************************************************************************
 
%Coefficients:
  p1 = 1.1962e-10;
  p2 = -2.2294e-07;
  p3 = 0.00010311;
  p4 = -0.0018045;
  p5 = 5.3947 ;  
 %Coefficients:
  p11 = -1.1739e-09;
  p22 = 1.6143e-06;
  p33 = -0.00074807;
  p44 = 0.13468;
  p55 = 0.96844; 
%Coefficients:
  p111 = -1.6675e-07;
  p222 = 0.00014933;
  p333 = -0.025555;
  p444 = 7.2048;
  %Coefficients:
  p1111 = 0.0063484;
  p2222 = 4.8357;
  %Coefficients:
  p11111 = 0.0051261;
  p22222 = 4.8775;
  %Coefficients:
  p111111 = 0.0052683;
  p222222 = 5.4605;

  %Coefficients:
  p1t = 7.0968e-13;
  p2t = -6.935e-10;
  p3t = 1.3083e-07;
  p4t = 1.9042e-05;
  p5t = 0.051301;
  %Coefficients:
  p1n = -1.6432e-10;
  p2n = 1.6875e-07;
  p3n = -2.6826e-05;
  p4n = 0.057891;
  %Coefficients:
  p1r = 1.9545e-12;
  p2r = -3.586e-09;
  p3r = 1.8245e-06;
  p4r = -0.00022984;
  p5r = 0.068445;
%----------------300----------------
  %Coefficients:
  p1_300 = 2.2891e-10;
  p2_300 = -1.3854e-07;
  p3_300 = -3.9461e-06;
  p4_300 = 0.042397;
  %Coefficients:
  p1_300n = 4.4811e-10;
  p2_300n = -4.2769e-07;
  p3_300n = 0.00011248;
  p4_300n = 0.036545;
  %Coefficients:
  p1_300h = -1.3372e-09;
  p2_300h = 1.2003e-06;
  p3_300h = -0.00022616;
  p4_300h = 0.051373;
  %Coefficients:
  p1_400t = -1.6132e-11;
  p2_400t = 4.8351e-08;
  p3_400t = -2.2299e-05;
  p4_400t = 0.025707;
  %Coefficients:
  p1_400n = 1.9289e-10;
  p2_400n = -1.3203e-07;
  p3_400n = 3.642e-05;
  p4_400n = 0.029011;
  %Coefficients:
  p1_400h = -6.8776e-10;
  p2_400h = 4.9252e-07;
  p3_400h = -5.1833e-05;
  p4_400h = 0.044936;

%Coefficients:
  k1 = 1.3468e-26;
  k2 = -5.5579e-23;
  k3 = 9.9635e-20;
  k4 = -1.0178e-16;
  k5 = 6.5353e-14;
  k6 = -2.7447e-11;
  k7 = 7.6144e-09;
  k8 = -1.3791e-06;
  k9 = 0.00015814;
  k10 = -0.010966;
  k11 = 0.5375;

  if(hconst<650)
 creep_str_400=k1*hconst^10+k2*hconst^9+k3*hconst^8+k4*hconst^7+k5*hconst^6+k6*hconst^5+k7*hconst^4+k8*hconst^3+k9*hconst^2+k10*hconst+k11; 
 ASF_haddeleme= p1*hconst^4 + p2*hconst^3 + p3*hconst^2 + p4*hconst + p5;
 ASF_enine = p11*hconst^4 + p22*hconst^3 + p33*hconst^2 + p44*hconst + p55 ;
 ASF_normal = p111*hconst^3 + p222*hconst^2 + p333*hconst + p444;
 ASF_haddeleme400 = p1111*hconst + p2222;
 ASF_enine400 =p11111*hconst + p22222; 
 ASF_normal400=p111111*hconst + p222222;
 SH_enine_25= p1t*hconst^4 + p2t*hconst^3 +p3t*hconst^2 + p4t*hconst +p5t ;
 SH_normal_25 = p1n*hconst^3 + p2n*hconst^2 +p3n*hconst + p4n; 
 SH_haddeleme_25 = p1r*hconst^4 + p2r*hconst^3 +p3r*hconst^2 + p4r*hconst+p5r;
 SH_enine_300=p1_300*hconst^3 + p2_300*hconst^2 +p3_300*hconst +p4_300;
 SH_normal_300= p1_300n*hconst^3 + p2_300n*hconst^2 +p3_300n*hconst + p4_300n ;
 SH_haddeleme_300= p1_300h*hconst^3 + p2_300h*hconst^2+p3_300h*hconst + p4_300h ;
 SH_enine_400=p1_400t*hconst^3 + p2_400t*hconst^2 +p3_400t*hconst + p4_400t ;
 SH_normal_400=p1_400n*hconst^3 + p2_400n*hconst^2 +p3_400n*hconst + p4_400n; 
 SH_haddeleme_400= p1_400h*hconst^3 + p2_400h*hconst^2 +p3_400h*hconst + p4_400h; 

  elseif(hconst>650)
 creep_str_400=0;
 ASF_haddeleme=0; 
 ASF_enine =0;
 ASF_normal =0;
 ASF_haddeleme400=0;
 ASF_enine400 =0;
 SH_enine_25=0;
 SH_normal_25=0;
 SH_haddeleme_25 =0;
 SH_enine_300=0;
 SH_normal_300=0;
 SH_haddeleme_300=0;
  end
  
 if(total_thck_eff > xxx)
   [writeErrFlag]=writeFmt(10,[format_299]);
   tempBreak=1;
   break;
  end
  
  if(stp1 == num_step)
   [writeErrFlag]=writeFmt(10,[format_133],'d_time','heat_mass_eff','lioh_mass_eff','irr_mass_eff','total_mass_eff','heat_thck_eff','lioh_thick_eff','irr_thck_eff','total_thck_eff','t','fuel_clad_temp','dif_coef','hconst','b_NR','b_TR','trans','rolling','normal','ASF_haddeleme','ASF_enine',' ASF_normal','ASF_haddeleme400','ASF_enine400','ASF_normal400','SH_enine_25','SH_normal_25','SH_haddeleme_25','SH_enine_300','SH_normal_300','SH_haddeleme_300','SH_enine_400','SH_normal_400','SH_haddeleme_400','creep_str_400');
   
   stp1 = 0;
  end
  
 end
 
 try;
   
  fclose(unit2fid{find([unit2fid{:,1}]==10,1,'last'),2});
  unit2fid=unit2fid(find([unit2fid{:,1}]'~=10),:);end

 clear all
 
end 


