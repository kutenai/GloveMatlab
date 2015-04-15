disp('Robotics Toolbox for Matlab (release 8)')
disp('  (c) Peter Corke 1992-2008 http://www.petercorke.com')
tbpath = fileparts(which('fkine'));
disp(['  installed in ', tbpath])
addpath( fullfile(tbpath, 'demos') );
