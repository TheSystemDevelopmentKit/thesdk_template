import os
import sys
if not (os.path.abspath('../../thesdk') in sys.path):
    sys.path.append(os.path.abspath('../../thesdk'))

import numpy as np
import tempfile

from thesdk import *
from verilog import *
from vhdl import *

class inverter(vhdl,verilog,thesdk):
    #Classfile is required by verilog and vhdl classes to determine paths.
    @property
    def _classfile(self):
        return os.path.dirname(os.path.realpath(__file__)) + "/"+__name__

    def __init__(self,*arg): 
        self.proplist = [ 'Rs' ];    #properties that can be propagated from parent
        self.Rs = 1;                 # sampling frequency
        self.iptr_A = refptr();      # Pointer for input data
        self.model='py';             #can be set externally, but is not propagated
        self.par= False              #By default, no parallel processing
        self.queue= []               #By default, no parallel processing
        self._Z = refptr();          # Pointer for output data
        if len(arg)>=1:
            parent=arg[0]
            self.copy_propval(parent,self.proplist)
            self.parent =parent;
        self.init()
    def init(self):
        self._vlogparameters =dict([('Rs',100e6)])
        self.def_verilog()
        self._vhdlparameters =dict([('Rs',100e6)])
        self.def_vhdl()

    def main(self):
        out=np.array(1-self.iptr_A.Value)
        if self.par:
            self.queue.put(out)
        self._Z.Value=out

    def run(self,*arg):
        if len(arg)>0:
            self.par=True      #flag for parallel processing
            self.queue=arg[0]  #multiprocessing.queue as the first argument
        if self.model=='py':
            self.main()
        else: 
          self.write_infile()

          # Define the outputfile
          if self.model=='sv':
              a=verilog_iofile(self,**{'name':'Z'})
              a.simparam='-g g_outfile='+a.file
              self.run_verilog()
          elif self.model=='vhdl':
              a=vhdl_iofile(self,**{'name':'Z'})
              a.simparam='-g g_outfile='+a.file
              self.run_vhdl()

          self.read_outfile()

    def write_infile(self):
        if self.model=='sv':
            a=verilog_iofile(self,**{'name':'A','data':self.iptr_A.Value.reshape(-1,1)})
        elif self.model=='vhdl':
            a=vhdl_iofile(self,**{'name':'A','data':self.iptr_A.Value.reshape(-1,1)})

        ## Write the file and define the parameter for the rtl simulator
        a.simparam='-g g_infile='+a.file
        a.write()

    def read_outfile(self):
        a=list(filter(lambda x:x.name=='Z',self.iofiles))[0]
        a.read(**{'dtype':'object'})
        out=a.data.astype('int')

        #This is for parallel processing
        if self.par:
            self.queue.put(out)
        self._Z.Value=out
        del self.iofiles #Large files should be deleted

