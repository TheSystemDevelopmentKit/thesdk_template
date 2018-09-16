% INVERTER simulation class 
% Last modification by Marko Kosunen, marko.kosunen@aalto.fi, 03.10.2017 09:16
classdef inv_sim <  inv_common & thesdk & handle
 
    properties (SetAccess = public)
        printpath = './'
        inv=inverter
        models={ 'matlab' 'vhdl' 'sv' }
    end

    properties (SetAccess = private)
        data
    end
    methods 
       function obj = inv_sim(varargin)
            if nargin>=1;
                parent=varargin{1}; 
                obj.copy_propval(parent,obj.proplist);
                obj.parent=parent;
            end
           obj.init; 
       end
       function obj = init(obj)
            %Define input signal
            obj.data=zeros(1,10);
            obj.data([1,2,5,7,9])=1;

            for k=1:length(obj.models)
                %define models and connctions
                obj.inv(k)=inverter(obj,obj.proplist); 
                obj.inv(k).model=obj.models{k};
                if k==1
                    obj.inv(k).iptr_A=refptr(obj,'data');
                else
                    obj.inv(k).iptr_A=refptr(obj.inv(k-1),'Z');
                end
                obj.inv(k).init; 
            end
        end
        function obj=run_simple(obj)
            for k=1:length(obj.models)
                obj.inv(k).run;
            end
        end

        function obj=plot(obj)
            for k=1:length(obj.models)
                x=1:length(obj.data);
                figure(k)
                h1=stem(x,obj.inv(k).iptr_A.Value);
                set(h1,'LineWidth',2)
                hold on
                h2=stem(x,obj.inv(k).Z);
                set(h2,'LineWidth',2);
                axis([min(x) max(x) 0 1.4]);
                tstr=sprintf('Inverter model %s\n', obj.inv(k).model );
                title(tstr);
                xlabel('Time [s]')
                ylabel('Z [1|0]');
                legend('Input A','Output Z','Location','northeast');
                set(gca,'FontSize',14);
                set(gca,'FontWeight','Bold');
                set(gca,'LineWidth',2);
                %set(gca,'Xtick',tmarks)
                grid on
            end
        end
        function obj=print(obj)
            for k=1:length(obj.models)
               figure(k)
               eval(['print -depsc ' obj.printpath '/inv_sim_Rs_' num2str(obj.Rs) '_' num2str(k) '.eps']);
           end
        end
    end
end

