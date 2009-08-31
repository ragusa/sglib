function u=apply_boundary_conditions_solution( ui, g, P_I, P_B, varargin )
% APPLY_BOUNDARY_CONDITIONS_SOLUTION Applies boundary conditions to the solution.
%   U=APPLY_BOUNDARY_CONDITIONS_SOLUTION( UI, G, P_I, P_B ) adds
%   boundary conditions back to a solution given just on the inner nodes.
%
% Example (<a href="matlab:run_example apply_boundary_conditions_solution">run</a>)
%   [els,pos,bnd]=create_mesh_1d( 5, 0, 2 );
%   K=stiffness_matrix( els, pos, ones(size(pos)) );
%   f=sin(pi*pos);
%   g=2+pos;
%   [P_I,P_B]=boundary_projectors( bnd, size(pos,1) );
%   Ki=apply_boundary_conditions_operator( K, P_I );
%   fi=apply_boundary_conditions_rhs( K, f, g, P_I, P_B );
%   ui=Ki\fi;
%   u=apply_boundary_conditions_solution( ui, g, P_I, P_B );
%   fprintf( '%5s  %5s | %5s %5s\n', 'u', 'g', 'Ku', 'f', '=====', '=====', '=====', '=====' )
%   fprintf( '%5.2f  %5.2f | %5.2f  %5.2f\n', [ u, g, K*u, f]'  )

%
% See also BOUNDARY_PROJECTORS, APPLY_BOUNDARY_CONDITIONS_RHS,
%   APPLY_BOUNDARY_CONDITIONS_SOLUTION

%   Elmar Zander
%   Copyright 2009, Institute of Scientific Computing, TU Braunschweig.
%   $Id$
%
%   This program is free software: you can redistribute it and/or modify it
%   under the terms of the GNU General Public License as published by the
%   Free Software Foundation, either version 3 of the License, or (at your
%   option) any later version.
%   See the GNU General Public License for more details. You should have
%   received a copy of the GNU General Public License along with this
%   program.  If not, see <http://www.gnu.org/licenses/>.


options=varargin2options( varargin );
[truncation_options,options]=get_option( options, 'truncation_options', {} );
check_unsupported_options( options, mfilename );

if iscell(ui)
    M=size(ui{2},1);
else
    Ni=size(P_I,1);
    NiM=numel(ui);
    M=NiM/Ni;
end
if M>1; I_S=speye(M); else I_S=1; end

% Computes:
%   u=P_I'*ui+P_B'*gb (with gb=P_B*g)
u=tensor_operator_apply( {P_I', I_S}, ui );
g=tensor_operator_apply( {P_B'*P_B, I_S}, g );

u=tensor_add( u, g );
if iscell(u)
    u=tensor_truncate( u, truncation_options{:} );
end
