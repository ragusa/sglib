function unittest_exponential_distribution
% UNITTEST_EXPONENTIAL_DISTRIBUTION Test the distribution functions.
%
% Example (<a href="matlab:run_example unittest_exponential_distribution">run</a>)
%    unittest_exponential_distribution
%
% See also TESTSUITE

%   Elmar Zander
%   Copyright 2007, Institute of Scientific Computing, TU Braunschweig.
%
%   This program is free software: you can redistribute it and/or modify it
%   under the terms of the GNU General Public License as published by the
%   Free Software Foundation, either version 3 of the License, or (at your
%   option) any later version.
%   See the GNU General Public License for more details. You should have
%   received a copy of the GNU General Public License along with this
%   program.  If not, see <http://www.gnu.org/licenses/>.


alpha=1.5;
munit_set_function('exponential_cdf');
assert_equals( exponential_cdf(-inf,alpha), 0, 'cdf_minf' );
assert_equals( exponential_cdf(-1e10,alpha), 0, 'cdf_negative' );
assert_equals( exponential_cdf(inf,alpha), 1, 'cdf_inf' );
assert_equals( exponential_cdf(log(2)/alpha,alpha), 1/2, 'cdf_median' );

munit_set_function('exponential_pdf');
assert_equals( exponential_pdf(-inf,alpha), 0, 'pdf_minf' );
assert_equals( exponential_pdf(-1e10,alpha), 0, 'pdf_negative' );
assert_equals( exponential_pdf(inf,alpha), 0, 'pdf_inf' );

[x1,x2]=linspace_mp( -0.1, 5 );
F=exponential_cdf( x1, alpha );
F2=pdf_integrate( exponential_pdf( x2, alpha ), F, x1);
assert_equals( F, F2, 'pdf_cdf_match', struct('abstol',0.01) );
