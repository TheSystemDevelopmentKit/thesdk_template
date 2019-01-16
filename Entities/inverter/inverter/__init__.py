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
        self.proplist = [ 'Rs' ];    # Properties that can be propagated from parent
        self.Rs =  100e6;            # Sampling frequency
        self.iptr_A = IO();          # Pointer for input data
        self.model='py';             # Can be set externally, but is not propagated
        self.par= False              # By default, no parallel processing
        self.queue= []               # By default, no parallel processing
        self._Z = IO();              # Pointer for output data
        if len(arg)>=1:
            parent=arg[0]
            self.copy_propval(parent,self.proplist)
            self.parent =parent;
        self.init()

    def init(self):
        #This gets updated every time you add an iofile
        self.iofile_bundle=Bundle()
        # Define the outputfile

        # Adds an entry named self._iofile_Bundle.Members['Z']
        if self.model=='sv':
            a=verilog_iofile(self,name='Z')
            a.simparam='-g g_outfile='+a.file
            b=verilog_iofile(self,name='A')
            b.simparam='-g g_infile='+b.file
            self.vlogparameters =dict([('g_Rs',self.Rs)])
        if self.model=='vhdl':
            a=vhdl_iofile(self,name='Z')
            a.simparam='-g g_outfile='+a.file
            b=vhdl_iofile(self,name='A')
            b.simparam='-g g_infile='+b.file
            self.vhdlparameters =dict([('g_Rs',self.Rs)])

    def main(self):
        out=np.array(1-self.iptr_A.Data)
        if self.par:
            self.queue.put(out)
        self._Z.Data=out

    def run(self,*arg):
        if len(arg)>0:
            self.par=True      #flag for parallel processing
            self.queue=arg[0]  #multiprocessing.queue as the first argument
        if self.model=='py':
            self.main()
        else: 
          self.write_infile()

          if self.model=='sv':
              self.run_verilog()

          elif self.model=='vhdl':
              self.run_vhdl()

          self.read_outfile()

    def write_infile(self):
        self.iofile_bundle.Members['A'].data=self.iptr_A.Data.reshape(-1,1)
        self.iofile_bundle.Members['A'].write()

    def read_outfile(self):
        #a is just a shorthand notation
        a=self.iofile_bundle.Members['Z']
        a.read(dtype='object')
        out=a.data.astype('int')

        #This is for parallel processing
        if self.par:
            self.queue.put(out)
        self._Z.Data=out
        del self.iofile_bundle #Large files should be deleted

