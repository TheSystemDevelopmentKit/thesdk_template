classdef (Abstract) inv_common < thesdk & handle
   properties (SetAccess = public)
       %Things we want to propagate throughout the hierarchy
       %Default values 
       Rs=100e6;
       parent
       proplist={ 'Rs' }; 
       %proplist 
   end
end
