function [X,flag,info,solver_stats]=generalized_solve_pcg( A, F, varargin )

global gsolver_stats

options=varargin2options( varargin );
[Minv,options]=get_option( options, 'Minv', [] );
[abstol,options]=get_option( options, 'abstol', 1e-6 );
[reltol,options]=get_option( options, 'reltol', 1e-6 );
[maxiter,options]=get_option( options, 'maxiter', 100 );
[truncate_after_func,options]=get_option( options, 'truncate_after_func', @identity );
[truncate_before_func,options]=get_option( options, 'truncate_before_func', @identity );
[truncate_operator_func,options]=get_option( options, 'truncate_operator_func', @identity );
[gsolver_stats,options]=get_option( options, 'stats', struct() );
[stats_func,options]=get_option( options, 'stats_func', @gather_stats_def );
check_unsupported_options( options, mfilename );


info.abstol=abstol;
info.reltol=reltol;
info.maxiter=maxiter;
iter=0;
flag=0;

Xc=gvector_null(F);
Rc=funcall( truncate_before_func, F );
Zc=operator_apply( Minv, Rc );
Zc=funcall( truncate_after_func, F );
Pc=Zc;

initres=gvector_norm( Rc );

gsolver_stats=funcall( stats_func, 'init', gsolver_stats, initres );

while true
    %if is_tensor( Xc); fprintf( 'Rank X: %d\n', tensor_rank(Xc) ); end
    APc=operator_apply(A,Pc,'truncate_func', truncate_operator_func);
    %if is_tensor( Xc); fprintf( 'Rank A: %d\n', tensor_rank(APc) ); end
    APc=funcall( truncate_before_func, APc );
    %if is_tensor( Xc); fprintf( 'Rank A: %d\n', tensor_rank(APc) ); end
    alpha=gvector_scalar_product( Rc, Zc)/...
        gvector_scalar_product( Pc, APc );
    Xn=gvector_add( Xc, Pc, alpha);
    Rn=gvector_add( Rc, APc, -alpha );

    Xn=funcall( truncate_before_func, Xn );
    Rn=funcall( truncate_before_func, Rn );

    normres=gvector_norm( Rn );
    relres=normres/initres;

    % Proposed update is DY=alpha*Pc
    % actual update is DX=T(Xn)-Xc;
    % update ratio is (DX,DY)/(DY,DY) should be near one
    % no progress if near 0
    DY=gvector_scale( Pc, alpha );
    DX=gvector_add( Xn, Xc, -1 );
    upratio=gvector_scalar_product( DX, DY )/gvector_scalar_product( DY, DY );

    gsolver_stats=funcall( stats_func, 'step', gsolver_stats, F, A, Xn, Rn, normres, relres, upratio );

    if normres<abstol || relres<reltol; break; end

    %urc=iter-50;
    fprintf( 'Iter: %2d relres: %g upratio: %g\n', iter, relres, upratio );
    if abs(1-upratio)>.2 %&& urc>10
        flag=-1;
        break;
    end

    Zn=operator_apply(Minv,Rn);
    beta=gvector_scalar_product(Rn,Zn)/gvector_scalar_product(Rc,Zc);
    Pn=gvector_add(Zn,Pc,beta);

    % set all iteration variables to new state
    Xc=funcall( truncate_after_func, Xn );
    Rc=funcall( truncate_after_func, Rn );
    Pc=funcall( truncate_after_func, Pn );
    Zc=funcall( truncate_after_func, Zn );

    % increment and check iteration counter
%     disp(iter);
%     if iscell(Xn)
%         disp(tensor_rank(Xn));
%     end
        
    iter=iter+1;
    if iter>maxiter
        flag=1;
        break;
    end

    if false && mod(iter,100)==0
        keyboard
    end
end
X=funcall( truncate_after_func, Xn );

gsolver_stats=funcall( stats_func, 'finish', gsolver_stats, X );

info.flag=flag;
info.iter=iter;
info.relres=relres;
info.upratio=upratio;

solver_stats=gsolver_stats;

% if we were not successful but the user doesn't retrieve the flag as
% output argument we issue a warning on the terminal
if flag && nargout<2
    solver_message( 'generalized_pcg', flag, info )
end

function stats=gather_stats_def( what, stats, varargin )
what; %#ok, ignore
varargin; %#ok, ignore

