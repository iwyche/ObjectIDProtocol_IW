function [sph] = add_callback(sph, callback)

   global private_soloparam_list;
   private_soloparam_list{sph.lpos} = ...
       add_callback(private_soloparam_list{sph.lpos}, callback);

   