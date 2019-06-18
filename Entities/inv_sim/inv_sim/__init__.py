#from joblib import Parallel, delayed
import numpy as np
import matplotlib as mpl 
mpl.use('Agg')
import matplotlib.pyplot as plt

from thesdk import *
from inverter import *
# This actually does very little. it is included to show how to use controllers
from  inverter.controller import controller as inverter_controller

class inv_sim:
    def __init__(self):
        self.Rs=100.0e6
        self.picpath=[];
        self.models=[ 'py', 'py', 'py' ];
        self.length=100;
        #self.cores=5
        self.b=np.random.randint(2,size=self.length).reshape(-1,1);
        self.define_simple()

    def define_simple(self):
        #There can be several configurations
        self.controller=inverter_controller(self)
        self.invs=[]
        for k in range(1,len(self.models)+1):
            self.invs.append(inverter(self))
            if k==1:
                self.invs[k-1].IOS.Members['A'].Data=self.b
            else:
                self.invs[k-1].IOS.Members['A']=self.invs[k-2].IOS.Members['Z']
            self.invs[k-1].model=self.models[k-1];
            self.invs[k-1].IOS.Members['control_write']=self.controller.IOS.Members['control_write']

    def run_simple(self):
            self.controller.start_datafeed()
            for inst in self.invs:
                inst.init();
                inst.run();

    def plot(self):
        for k in range(1,len(self.models)+1):
            figure=plt.figure()
            h=plt.subplot();
            hfont = {'fontname':'Sans'}
            x = np.linspace(0,10,11).reshape(-1,1)
            markerline, stemlines, baseline = plt.stem(x, self.invs[k-1].IOS.Members['Z'].Data[0:11,0], '-.')
            plt.setp(markerline,'markerfacecolor', 'b','linewidth',2)
            plt.setp(stemlines, 'linestyle','solid','color','b', 'linewidth', 2)
            #plt.ylim((np.amin([self.a,self.b]), np.amax([self.a,self.b])));
            plt.ylim(0, 1.1);
            plt.xlim((np.amin(x), np.amax(x)));
            #plt.xlim((np.amin(self.x), np.amax(self.x)));
            #plt.plot(self.x,self.a,label='Blowing in the wind',linewidth=2);
            #plt.plot(self.x,self.b,label='Blowing in the wind',linewidth=2);
            tstr = "Inverter model %s" %(self.invs[k-1].model) 
            plt.suptitle(tstr,fontsize=20);
            plt.ylabel('Out', **hfont,fontsize=18);
            plt.xlabel('Sample (n)', **hfont,fontsize=18);
            h.tick_params(labelsize=14)
            #for axis in ['top','bottom','left','right']:
            #h.spines[axis].set_linewidth(2)
            #lgd=plt.legend(loc='upper right', fontsize=14);
            ##lgd.set_fontsize(12);
            plt.grid(True);
            printstr="%s/inv_sim_Rs_%i_%i.eps" %(self.picpath, self.Rs, k)
            #plt.show()
            plt.show(block=False);
            figure.savefig(printstr, format='eps', dpi=300);
            #input();

if __name__=="__main__":
    from thesdk import *
    from inv_sim import *
    t=inv_sim()
    t.models=[ 'py', 'sv', 'sv' ]
    t.define_simple()
    t.picpath="./"
    t.run_simple()
    t.plot()


