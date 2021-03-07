function [writeErrFlag]=writeFmt(unitIn,formatIn,varargin)
%   function [writeErrFlag]=writeFmt(unitIn,formatIn,varargin)
%
% readFmt attempts to reproduce fortran's read statements in
%  f2matlab converted m-files
%
% INPUTS: unitIn => fortran unit number, indexed to a matlab fid in unit2fid
%       formatIn => format string for this read statement. This should be 
%                   one string with percent markers similar to fscanf formats
%       varargin => List of string corresponding to variables or expressions 
%                   in the calling workspace. For an impled do loop from 
%                   fortran, the format is a cell array:
%                   {'expression_1','expression_2','loopVariable','startIndex','increment','endIndex'}
%
% OUTPUTS: writeErrFlag => set to true if there was an error during the writing process
%
% EXAMPLES:
%   fortran: write(*,'(''this is an '',i4,'' example.'')') 3
%    matlab: [writeErrFlag]=writeFmt(1,['this is an ','%4d',' example.'],'3');
%   fortran: write(*,'(10i5)') (ii,ii+2,ii=1,10)
%    matlab: [writeErrFlag]=writeFmt(1,[repmat('%5d',1,10)],{'ii','ii+2','ii','1','1','10'});

 global unit2fid ; crlf=char(10); if ispc, crlf=[char(13),crlf]; end; fidRow=[];
 %translate unitIn to fidIn
 if isnumeric(unitIn)
  if isempty(unit2fid)
   fidIn=1;
  else
   fidRow=find([unit2fid{:,1}]==unitIn,1,'last');
   if isempty(fidRow)
    if unitIn==6 || unitIn==1 || unitIn==0
     fidIn=1;
    else %fortran writes text files like fort.3 in these cases
     warning(['unknown fid in writeFmt',]);
     thismlfid=fopen(strtrim(['matl.',num2str(unitIn)]),'w+');
     unit2fid{end+1,1}=unitIn; unit2fid{end,2}=thismlfid; unit2fid{end,3}=0;
     fidRow=find([unit2fid{:,1}]==unitIn,1,'last');
     fidIn=unit2fid{fidRow,2};
    end
   else
    fidIn=unit2fid{fidRow,2};
   end
  end % if isempty(unit2fid)
 else %internal write, pass the string through
  fidIn=unitIn;
 end
 unformatted=0;
 if ~isempty(fidRow) 
  if unit2fid{fidRow,3}==1
   unformatted=1;
  end
 end
 %try to convert manually if formatIn was a variable at conversion time
 if iscell(formatIn), formatIn=char(formatIn)'; formatIn=formatIn(:)'; end
 if isempty(formatIn), formatIn='\n'; end
 varargin=strtrim(varargin);
 %extract format fields from formatIn
 percents=find(formatIn=='%');
 if isempty(percents) && ~isempty(inputname(2)) && ~isempty(varargin)
  formatIn=eval(['[',convertFormatField(strrep(formatIn,'"','''')),']']);
  percents=find(formatIn=='%');
 end
 hasParen=~isempty(strfind(formatIn,'~'));
 formatInLetters=find(isletter(formatIn));
 formatFields={}; ffWithFormat=[];
 if ~isempty(percents)
  if percents(1)>1
   formatFields{1}=formatIn(1:percents(1)-1);
  end
  for ii=1:length(percents)
   if length(formatIn)>percents(ii) && formatIn(percents(ii)+1)=='%', continue, end
   nextLetter=formatInLetters(find(formatInLetters>percents(ii),1,'first'));
   if strcmpi(formatIn(nextLetter),'l'), formatIn(nextLetter)='d'; end
   formatFields{length(formatFields)+1}=formatIn(percents(ii):nextLetter);
   if ~any(formatFields{length(formatFields)}=='t') && ~any(formatFields{length(formatFields)}=='x') && ~any(formatFields{length(formatFields)}=='p') 
    ffWithFormat=[ffWithFormat,length(formatFields)];
   end
   if ii==length(percents)
    if length(formatIn)>nextLetter
     formatFields{length(formatFields)+1}=formatIn(nextLetter+1:end);
    end
   else
    if percents(ii+1)>nextLetter+1
     formatFields{length(formatFields)+1}=formatIn(nextLetter+1:percents(ii+1)-1);
    end
   end
  end % for ii=1:length(percents)
 else %must be just a string to echo to file
  formatFields{1}=formatIn;
 end
 formatFields=strrep(formatFields,'%*g',' %*g'); %adds a space before to separate values
 %Now form the IO list for assigning the calling workspace
 % first, expand the structs if any
 for ii=length(varargin):-1:1
  if ~iscell(varargin{ii}) && evalin('caller',['isstruct(',varargin{ii},')'])
   foo=evalin('caller',['fieldnames(',varargin{ii},')']);
   bar=varargin{ii}; bar2=cell(1,length(foo));
   varargin={varargin{1:ii-1},bar2{:},varargin{ii+1:end}};
   for jj=1:length(foo)
    varargin{ii+jj-1}=[bar,'.',foo{jj}];
   end % for jj=1:length(fieldnames)
  end % if evalin('caller',
 end
 
 for ii=length(varargin):-1:1
  if iscell(varargin{ii}) %an implied do loop, make a list
   ;%build in functionality for a nested loop
   for kk=(length(varargin{ii})-4):-1:1
    if iscell(varargin{ii}{kk})
     IDL(1)=evalin('caller',varargin{ii}{kk}{end-2});
     IDL(2)=evalin('caller',varargin{ii}{kk}{end-1});
     IDL(3)=evalin('caller',varargin{ii}{kk}{end  });
     vt={}; clk=length(varargin{ii}{kk});
     for jj=IDL(1):IDL(2):IDL(3)
      for mm=1:clk-4
       vt={vt{:},regexprep(varargin{ii}{kk}{mm},...
                           ['\<',varargin{ii}{kk}{clk-3},'\>'],sprintf('%d',jj))};
      end % for mm=1:length(varargin{ii}{kk})-1
     end
     varargin{ii}={varargin{ii}{1:kk-1},vt{:},varargin{ii}{kk+1:end}};
    end % for kk=1:length(varargin{ii})-4
   end % if any(cellfun('isclass',
  end % if iscell(varargin{ii}) %an implied do loop,
 end % for ii=1:length(varargin)
 IOlist={}; IDLff={};
 for ii=1:length(varargin)
  if iscell(varargin{ii}) %an implied do loop, make a list
   IDL(1)=evalin('caller',varargin{ii}{end-2});
   IDL(2)=evalin('caller',varargin{ii}{end-1});
   IDL(3)=evalin('caller',varargin{ii}{end  });
   cl=length(varargin{ii});
   for jj=IDL(1):IDL(2):IDL(3)
    for kk=1:cl-4
     IOlist={IOlist{:},regexprep(varargin{ii}{kk},...
                                 ['\<',varargin{ii}{cl-3},'\>'],sprintf('%d',jj))};
     if evalin('caller',['ischar(',IOlist{end},')'])
      IDLff={IDLff{:},'%c'};
     else
      IDLff={IDLff{:},'%g'};
     end
    end % for kk=1:cl-4
   end
   %formatFields={formatFields{1:ii-1},IDLff{:},formatFields{ii+1:end}};
   %ffWithFormat=[ffWithFormat(1:ii-1),[1:length(IDLff)]+ffWithFormat(ii)-1,ffWithFormat(ii+1:end)+length(IDLff)-1];
  elseif ischar(varargin{ii}) %regular string input, so one IOlist item per element of varargin
                              %assume no vector indexing on non scalars with subscripts
                              %if this is a value rather than an array, then no index
   cmplx=~evalin('caller',['isreal(',varargin{ii},')']);
   if ~isempty(regexp(varargin{ii},'[\(\{\*\/\-\+\^]|^[0-9\.]')) || ...
        evalin('caller',['ischar(',varargin{ii},')'])
    if evalin('caller',['ischar(',varargin{ii},')'])
     IOlist={IOlist{:},varargin{ii}};
    else
     if cmplx
      IOlist={IOlist{:},['real(',varargin{ii},')']};
      IOlist={IOlist{:},['imag(',varargin{ii},')']};
     else
      bar=cellstr(num2str(evalin('caller',varargin{ii}),40));
      IOlist={IOlist{:},bar{:}};
      %IOlist={IOlist{:},varargin{ii}};
     end
    end
   else
    %assume this is a single variable, with at least size of 1
    varSize=evalin('caller',['prod(size(',varargin{ii},'))']);
    if varSize>0
     cellArray=evalin('caller',['iscell(',varargin{ii},')']);
     IDLff={};
     for jj=1:varSize
      if cellArray
       IOlist={IOlist{:},[varargin{ii},'{',sprintf('%d',jj),'}']};IDLff={IDLff{:},'%c'};
      else
       if cmplx
        IOlist={IOlist{:},['real(',varargin{ii},'(',sprintf('%d',jj),'))']};IDLff={IDLff{:},'%g'};
        IOlist={IOlist{:},['imag(',varargin{ii},'(',sprintf('%d',jj),'))']};IDLff={IDLff{:},'%g'};
       else
        IOlist={IOlist{:},[varargin{ii},'(',sprintf('%d',jj),')']};IDLff={IDLff{:},'%g'};
       end
      end
     end % for jj=1:evalin('caller',
     if length(IDLff)>1&0 %TODO
      formatFields={formatFields{1:ffWithFormat(ii)-1},IDLff{:},formatFields{ii+1:end}};
      ffWithFormat=[ffWithFormat(1:ii-1),[1:length(IDLff)]+ffWithFormat(ii)-1,ffWithFormat(ii+1:end)+length(IDLff)-1];
     end
    else
     IOlist={IOlist{:},varargin{ii}};
    end
   end % if any(varargin{ii}=='(')
  else
   warning('writeFmt didn''t understand what it was given')
   (varargin{ii})
   return
  end
 end
 % take care of format reversion
 if hasParen
  hasParen=regexp(formatFields,'\');
  allParens=find(~cellfun('isempty',hasParen));
  for ii=fliplr(allParens(:)')
   formatFields={formatFields{1:ii-1},formatFields{ii}(1:hasParen{ii}(end)-1),formatFields{ii}(hasParen{ii}(end):end),formatFields{ii+1:end}};
   ffWithFormat(find(ffWithFormat>ii))=ffWithFormat(find(ffWithFormat>ii))+1;
  end
  lastParen=find(~cellfun('isempty',regexp(formatFields,'~')),1,'last');
  if formatFields{lastParen}(end)=='~',   lastParen=lastParen+1;  end
  formatFields=regexprep(formatFields,'~','');
 else
  lastParen=1;
 end
 
 %'ffff',kb
 %now start assigning
 writeErrFlag=false;  nFF=length(formatFields);  whereFF=1;  dataLine=''; pfact='0';
 %write out any fields not containing format specs
 for jj=whereFF:nFF
  if ~any(jj==ffWithFormat)
   if any(formatFields{jj}=='t') && any(formatFields{jj}=='%')
    %pad dataLine with spaces out to tab#
    tlen=str2num(formatFields{jj}(2:end-1));
    needed=max(1,tlen-(length(dataLine)-max([find(dataLine==char(10)),0]))-1);
    if needed>1
     dataLine=[dataLine,repmat(' ',1,needed)];
     %dataLine=[dataLine,repmat(' ',1,tlen-(length(dataLine)-find(dataLine==char(10),1,'last'))-1)];
    end
   elseif any(formatFields{jj}=='x') && any(formatFields{jj}=='%')
    tlen=str2num(formatFields{jj}(2:end-1));
    %dataLine=[dataLine,repmat(' ',1,tlen-1)];
    dataLine=[dataLine,repmat(' ',1,tlen)];
   elseif any(formatFields{jj}=='p') && any(formatFields{jj}=='%')
    foo=str2double(formatFields{jj}(2:end-1));
    if ~isnan(foo);pfact=formatFields{jj}(2:end-1);end
   else
    dataLine=[dataLine,sprintf(strrep(formatFields{jj},'pRcNt','%%'))];
   end
   whereFF=whereFF+1;
  else
   break
  end % if ~any(jj==ffWithFormat)
 end % for jj=whereFF+1:nFF
 for ii=1:length(IOlist)
  for jj=whereFF:nFF
   if ~any(jj==ffWithFormat)
    if any(formatFields{jj}=='t') && any(formatFields{jj}=='%')
     %pad dataLine with spaces out to tab#
     tlen=str2num(formatFields{jj}(2:end-1));
     needed=max(1,tlen-(length(dataLine)-max([find(dataLine==char(10)),0]))-1);
     if needed>1
      dataLine=[dataLine,repmat(' ',1,needed)];
      %dataLine=[dataLine,repmat(' ',1,tlen-(length(dataLine)-find(dataLine==char(10),1,'last'))-1)];
     end
    elseif any(formatFields{jj}=='x') && any(formatFields{jj}=='%')
     tlen=str2num(formatFields{jj}(2:end-1));
     dataLine=[dataLine,repmat(' ',1,tlen)];
    elseif any(formatFields{jj}=='p') && any(formatFields{jj}=='%')
     foo=str2double(formatFields{jj}(2:end-1));
     if ~isnan(foo);pfact=formatFields{jj}(2:end-1);end
    else
     dataLine=[dataLine,sprintf(strrep(formatFields{jj},'pRcNt','%%'))];
    end
    whereFF=whereFF+1;
   else
    break
   end % if ~any(jj==ffWithFormat)
  end % for jj=whereFF+1:nFF
      %Now go for the next in the IOlist
  switch formatFields{whereFF}(end)
    case {'f'}
      tempOut=evalin('caller',['sprintf(''',strrep(strrep(formatFields{whereFF},'%','%#'),'*',''),''',(',IOlist{ii},')*10^(',pfact,'));']);
      fieldWidth=sscanf(formatFields{whereFF}(2:end-1),'%d');
      if length(tempOut)>fieldWidth, tempOut=tempOut(1:fieldWidth); end
      %if length(tempOut)>fieldWidth, tempOut=repmat('*',1,fieldWidth); end
      dataLine=[dataLine,tempOut];
      %dataLine=[dataLine,evalin('caller',['sprintf(''',strrep(formatFields{whereFF},'*',''),''',(',IOlist{ii},')*10^(',pfact,'));'])];
    case {'g','u','i','l','d','e','z'}
      dataLine=[dataLine,evalin('caller',['sprintf(''',strrep(formatFields{whereFF},'*',''),''',(',IOlist{ii},'));'])];
    case {'c'}
      if evalin('caller',['ischar(',IOlist{ii},')'])
       tempStr=evalin('caller',IOlist{ii});  tempStr=tempStr(:)';
      else % formatField is a char, but caller variable is numeric
       tempStr=evalin('caller',['char(bin2dec(reshape(dec2bin(',IOlist{ii},',32),8,[])'')'')']);
      end
      charWidth=sscanf(formatFields{whereFF}(2:end-1),'%d');      
      if length(tempStr)>charWidth, tempStr=tempStr(1:charWidth); end
      if length(tempStr)<charWidth
       tempStr=[repmat(' ',1,charWidth-length(tempStr)),tempStr];
      end
      dataLine=[dataLine,tempStr];
    case {'x'}
      charWidth=str2num(formatFields{whereFF}(2:end-1));
      dataLine=[dataLine,repmat(' ',1,charWidth)];
  end
  if all(formatFields{whereFF}~='*'), whereFF=whereFF+1; end
  %whereFF=whereFF+1;
  for jj=whereFF:nFF
   if ~any(jj==ffWithFormat)
    if any(formatFields{jj}=='t') && any(formatFields{jj}=='%')
     %pad dataLine with spaces out to tab#
     tlen=str2num(formatFields{jj}(2:end-1));
     needed=max(1,tlen-(length(dataLine)-max([find(dataLine==char(10)),0]))-1);
     if needed>1
      dataLine=[dataLine,repmat(' ',1,needed)];
      %dataLine=[dataLine,repmat(' ',1,tlen-(length(dataLine)-find(dataLine==char(10),1,'last'))-1)];
     end
    elseif any(formatFields{jj}=='x') && any(formatFields{jj}=='%')
     tlen=str2num(formatFields{jj}(2:end-1));
     dataLine=[dataLine,repmat(' ',1,tlen)];
    elseif any(formatFields{jj}=='p') && any(formatFields{jj}=='%')
     foo=str2double(formatFields{jj}(2:end-1));
     if ~isnan(foo);pfact=formatFields{jj}(2:end-1);end
    else
     dataLine=[dataLine,sprintf(strrep(formatFields{jj},'pRcNt','%%'))];
    end
    whereFF=whereFF+1;
   else
    break
   end % if ~any(jj==ffWithFormat)
  end % for jj=whereFF+1:nFF %
  if whereFF>nFF %add carriage return and start over with ff
   if strcmp(formatIn(end),'$')
    dataLine=dataLine(1:end-1);
   elseif ~unformatted && ~ischar(unitIn)
    dataLine=[dataLine,crlf];
   end
   whereFF=lastParen;%whereFF=1;
  end
 end
 if whereFF~=lastParen || unformatted % put a carriage return in if unformatted
  dataLine=[dataLine,crlf];
 end 
 %now write it out to file or set it to the incoming string
 if isnumeric(fidIn) %fidIn is a file ID
  try
   fprintf(fidIn,'%s',dataLine);
  catch
   writeErrFlag=true;
  end
 elseif ischar(fidIn) %they are trying to write to a string
  if isempty(inputname(1))
   if any(fidIn=='(') && any(fidIn==')') && any(fidIn==':')
    strVar=fidIn(1:find(fidIn=='(',1,'first')-1);
    lowB=fidIn(find(fidIn=='(',1,'first')+1:find(fidIn==':',1,'first')-1);
    uppB=fidIn(find(fidIn==':',1,'first')+1:find(fidIn==')',1,'last')-1);
    evalin('caller',strrep([strVar,'=strAssign(',strVar,',[',lowB,'],[',uppB,'],''',...
                        dataLine,''');'],crlf,''));
   else
    evalin('caller',strrep([fidIn,'=''',strrep(dataLine,'''',''''''),''';'],crlf,''));
   end
  else
   evalin('caller',strrep([inputname(1),'(1:length(''',dataLine,'''))=''',dataLine,''';'],crlf,''));
  end
 end % if isnumeric(fidIn)
end % function [writeErrFlag,

 
 
 
 
function out=convertFormatField(in,firstOrLast,isString)
 global sp
 sp='';
 %this changes the fortran format field into the fprintf equivalent

 if nargin<3, isString=0; end
 if nargin<2, firstOrLast=0; end

 out='';
 inorig=in;
 in=strtrim(in);
 %if any(in=='('), in, kb, end
 if any(strcmpi(in,{'sp','ss'}))
  %do nothing for now...
  return
 end

 %let's try to take care of #H callouts if they are in there...
 [foo,bar]=regexpi(in,['\D\d+H'],'start','end');
 for ii=length(foo):-1:1
  if ~inAstring(in,foo(ii))
   in=[in(1:foo(ii)),'''',in(bar(ii)+1:bar(ii)+1+str2num(in(foo(ii)+1:bar(ii)-1))-1),'''',...
       in(bar(ii)+1+str2num(in(foo(ii)+1:bar(ii)-1)):end)];
  end
 end
 % get rid of unnecessary spaces
 in(~mod(cumsum(in==''''),2)&in==' ')='';
 
 temp2=find(in=='>',1,'first');
 if ~isempty(temp2)
  if ~inAstring(in,temp2)
   in=[in(1:temp2),'(',in(temp2+1:end),')'];
  end % if ~inAstring_f(in,
 end % if ~isempty(temp2)

 %may get things crammed together like 10x2x or 3xF15.8
 inas=false;
 if length(in)>1
  for jj=length(in)-1:-1:1
   promote=false;
   if jj==length(in)-1 && in(jj+1)==''''
    inas=~inas;
   end
   if ~inas & in(jj)=='''' & (isletter(in(jj+1))|isnumber(in(jj+1))), promote=true; end
   if ~inas && isletter(in(jj)) && (isletter(in(jj+1)) || in(jj+1)=='''')
    promote=true;
   end
   if ~inas && (strcmpi(in(jj),'x')||strcmpi(in(jj),'p')) && isnumber(in(jj+1))
    promote=true;
   end
   if in(jj)==''''
    inas=~inas;
   end
   if promote %meaning add a comma
              %groups={groups{1:ii-1},in(1:jj),in(jj+1:end),groups{ii+1:end}};
    in=[in(1:jj),',',in(jj+1:end)];
   end % if promote
   if ~inas & (strcmpi(in(jj),'s')|strcmpi(in(jj),'n')) ...
        & strcmpi(in(jj-1),'e')
    in=[in(1:jj-1),in(jj+1:end)];
   end
  end
 end 
 groups=getTopGroups(in);
 if length(groups)==1
  in=groups{1};
 else
  groups=strtrim(groups);
  groupsStr='';
  for ii=1:length(groups)
   temp1=',';if ii==length(groups), temp1='';end
   groupsStr=[groupsStr,convertFormatField(groups{ii}),temp1];
  end
  out=groupsStr;
  %'rrrrrrrrrrr',groups,groupsStr,out,kb
  return    
 end
 
 if any(in=='(') % we have a recursive definition
  temp=find(in=='(');
  temp2=find(in=='>',1,'last');
  if ~isempty(temp2)
   if ~inAstring(in,temp2)
    temp=temp(find(temp>temp2,1,'first'));
   end
  else
   temp=temp(1);
  end
  if ~inAstring(in,temp)% & ~inAstring2_f(in,temp)
   rs='1';
   if ~isempty((in(1:temp-1)))
    rs=(strrep(strrep(in(1:temp-1),'<',''),'>',''));
   end
   tempr=findRights(temp,in);
   groups=strtrim(getTopGroups(in(temp+1:tempr-1)));
   groupsStr='';
   for ii=1:length(groups)
    temp1=',';if ii==length(groups), temp1='';end
    groupsStr=[groupsStr,convertFormatField(groups{ii}),temp1];
   end
   groupsStr=['[',groupsStr,']'];
   out=['''~'',repmat(',groupsStr,' ,1,',(rs),')'];
   return
  end
 end

 % first thing to do is to determine if it's a string
 if any(in=='''') | isString
  out=in;
  if length(out)>2
   if strcmp(out(1:2),'''''')
    if ~strcmp(out(3),'''')
     out=out(2:end);
    end
   end
   % actually test the last 2 non white space, non / characters
   temp3=find(~isspace(out) & out~='/') ;
   if temp3(end)>2
    if strcmp(out(temp3(end)-1:temp3(end)),'''''')
     if ~strcmp(out(temp3(end)-2),'''')
      out=[out(1:temp3(end)-1),out(temp3(end)+1:end)];
     end
    end
   end
  end
 else %OK, it's not a string
  in=regexprep(in,'es','e','ignorecase');
  in=regexprep(in,'en','e','ignorecase');
  %does it have a letter in it?
  % also fix the slashes to have commas in between them and call recursively  
  if any(isletter(in))
   letterLoc=find(isletter(in));
   if strcmpi(in(letterLoc(1)),'p')   %move the p spec to the end
   end % if any(strcmpi(in(letterLoc),
       %does it have a repeat specification
   rs=[];
   if letterLoc>1
    rs=num2str(in(1:letterLoc-1));
   end
   b1=find(in=='<',1,'first');
   if ~isempty(b1)   b2=find(in=='>',1,'first');  rs=in(b1+1:b2-1);  end   
   letters=find(isletter(in));
   letterSpec=in(letters(1));
   if strcmpi(in(letters(end)),'p')
    rest=in(1:letters(1)-1);
   else
    rest=in(letters(end)+1:end);
   end
   preOut='';
   postOut='';
   if ~isempty(rs)
    preOut='repmat(';
    postOut=[',1,',rs,')'];
   end
   switch lower(letterSpec)
     case 'a'
       out=[preOut,'''%',rest,'c','',sp,'''',postOut];
     case 'b'
       out=[preOut,'''''',postOut];
     case {'e','d'}
       out=[preOut,'''%',rest,'e','',sp,'''',postOut];
     case 'f'
       out=[preOut,'''%',rest,'f','',sp,'''',postOut];
     case 'g'
       out=[preOut,'''%',rest,'g','',sp,'''',postOut];
     case 'h'
       %in,'kkkkkkkkkkkkkk',kb
       out=['''',sp,'',in(letters(1)+1:end),''''];
     case 'i'
       out=[preOut,'''%',rest,'i','',sp,'''',postOut];
     case 'l'
       out=[preOut,'''%',rest,'l','',sp,'''',postOut];
     case 'm' % for *g
       out=[preOut,'''%',rest,'*g','',sp,'''',postOut];
     case 'p' %multiplier:
       ;% http://h21007.www2.hp.com/portal/download/files/unprot/fortran/docs/lrm/lrm0398.htm#format_spec
       out=['''%',rest,'p','',sp,''''];
     case 'r' % list directed sequential read. Read tokens instead
       out=[preOut,'''%',rest,'r','',sp,'''',postOut];
     case 't'
       out=[preOut,'''%',rest,'t','',sp,'''',postOut];
     case 'x'
       if isempty(rs)
        out=['''%1x',''''];
       else
        out=['''%',rs,'x',''''];
       end
       %out=[preOut,''' ''',postOut];
     case 'z'
       out=[preOut,'''%',rest,'z','',sp,'''',postOut];
     otherwise
       in
       error('encountered an unknown format spec !!!!!!!!!!!!!!!!!!')
       in
       out=[preOut,'''%',rest,'f','',sp,'''',postOut];
   end  
  else
   switch in
     case ':'
       out=' ''\n '' ';
       out=' ''\n'' ';
     case '$' %this is supposed to suppress a linefeed
       out='''''';
     otherwise
       out=in;
   end
  end
 end

 % change over /'s
 temp=find(out=='/');
 temp2=find(out=='''');
 if ~isempty(temp)
  if isempty(temp2)
   temp1=find(~inAstring(out,temp));
  else
   if isempty(temp)
    temp1=find(~inAstring(out,temp));
   else
    temp1=find(~inAstring(out,temp)|temp>temp2(end));
   end % if isempty(temp)
  end % if isempty(temp2)
  for ii=length(temp1):-1:1
   %out=[out(1:temp(temp1(ii))-1),' ''\n '' ',out(temp(temp1(ii))+1:end)];
   out=[out(1:temp(temp1(ii))-1),' ''\n'' ',out(temp(temp1(ii))+1:end)];
  end
 end
end


function out=inAstring(in,loc)
 out=mod(cumsum(in==''''),2);
 out=out(loc);
end

function out=getTopGroups(in)
 commas=(in==',');
 inStr=mod(cumsum(in==''''),2);
 inPar=cumsum(in=='('&~mod(cumsum(in==''''),2))-cumsum(in==')'&~mod(cumsum(in==''''),2));
 commas=[0,find(commas&~inStr&~inPar),length(in)+1];
 out={};
 for ii=1:length(commas)-1
  out{ii}=in(commas(ii)+1:commas(ii+1)-1);
 end
end

function out=findRights(loc,in)
 diffs=cumsum(in=='('&~mod(cumsum(in==''''),2))-cumsum(in==')'&~mod(cumsum(in==''''),2));
 out=find(diffs(loc+1:end)==(diffs(loc)-1),1,'first')+loc;
end

function out=isnumber(str)
%out=(((str>47)&(str<58))|(str==46));
out=((str>47)&(str<58));
end

