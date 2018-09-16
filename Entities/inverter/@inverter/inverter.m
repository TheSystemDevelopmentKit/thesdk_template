% INVERTER class 
% Last modification by Marko Kosunen, marko.kosunen@aalto.fi, 12.12.2017 00:17
classdef inverter <  rtl & thesdk & handle
    properties (SetAccess = public)
        %Default values required at this hierarchy level or below.
        parent ;
        proplist = { 'Rs' };    %properties that can be propagated from parent
        Rs = 100e6;             % sampling frequency
        iptr_A
        model='matlab'
    end
    properties ( Dependent )
        classfile
    end
    properties ( Dependent)
        rtlcmd
    end
    properties ( SetAccess = protected )
        name
        entitypath  
        rtlsrcpath  
        rtlsimpath  
        workpath    
        infile
        outfile
    end
    properties (SetAccess = private )
        Z
    end
    methods
        function classfile=get.classfile(obj); classfile=mfilename('fullpath'); end;

        function rtlcmd = get.rtlcmd(obj); 
            %the could be gathered to rtl class in some way but they are now here for clarity
            submission = [' bsub ' ]; 
            rtllibcmd = [ 'vlib '  obj.workpath ' && sleep 2' ];
            rtllibmapcmd = [ 'vmap work '  obj.workpath ];

            if strcmp(obj.model,'vhdl')==1
                rtlcompcmd = [ 'vcom ' obj.rtlsrcpath '/' obj.name '.vhd ' ...
                    obj.rtlsrcpath '/tb_' obj.name '.vhd'];
                rtlsimcmd = ['vsim -64 -batch -t 1ps -g g_infile=' ...
                    char(obj.infile) ' -g g_outfile=' char(obj.outfile) ...
                    ' work.tb_' obj.name ' -do "run -all; quit -f;"'];

            elseif strcmp(obj.model,'sv')==1
                rtlcompcmd = [ 'vlog -work work '  obj.rtlsrcpath '/' obj.name '.sv '...
                    obj.rtlsrcpath '/tb_' obj.name '.sv'];
                rtlsimcmd = [ 'vsim -64 -batch -t 1ps -voptargs=+acc -g g_infile=' char(obj.infile) ...
                 ' -g g_outfile=' char(obj.outfile) ' work.tb_' obj.name  ' -do "run -all; quit;"' ];
            end
            rtlcmd = [ submission rtllibcmd   ' && ' rtllibmapcmd  ' && ' rtlcompcmd  ' && ' rtlsimcmd ];
        end;
        
        function obj = inverter(varargin)
            if nargin>=1;
                parent=varargin{1}; 
                %Properties to copy from the parent
                obj.copy_propval(parent,obj.proplist);
                obj.parent=parent;
            end
            obj.init;
        end
        function obj = init(obj)
            obj.def_rtl;
            [ PATH, rndpart, EXT]=fileparts(tempname);
            obj.infile  = [ obj.rtlsimpath '/A_' rndpart '.txt' ];
            [ PATH, rndpart, EXT]=fileparts(tempname);
            obj.outfile = [ obj.rtlsimpath '/Z_' rndpart '.txt' ];
        end
        function obj=run(obj);
            if strcmp(obj.model,'matlab')
                obj.Z=~obj.iptr_A.Value;
            elseif ~strcmp(obj.model,'matlab')
              l=length(obj.iptr_A.Value);
              if exist(obj.outfile, 'file') == 2
                  delete(obj.infile);
                  delete(obj.outfile)
              end

              fid=fopen(obj.infile,'w');
              for i=1:l
                  fprintf(fid,'%d\n',obj.iptr_A.Value(i));
              end
              fclose(fid);
              system(obj.rtlcmd);
              while ~(exist(obj.outfile, 'file') == 2)
                  fprintf(1,'Waiting the outputfile to appear')
                  pause(5)
              end
              fid=fopen(obj.outfile,'r');
              out = textscan(fid, '%d\n');
              fclose(fid);
              obj.Z=cell2mat(out).';
              delete(obj.infile)
              delete(obj.outfile)
            end
        end
    end
end

