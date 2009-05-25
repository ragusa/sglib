function test_format_poly
% TEST_FORMAT_POLY Test the FORMAT_POLY functions.
%
% Example (<a href="matlab:run_example test_format_poly">run</a>) 
%    test_format_poly
%
% See also TESTSUITE

%   Elmar Zander
%   Copyright 2007, Institute of Scientific Computing, TU Braunschweig.
%   $Id$ 
%
%   This program is free software: you can redistribute it and/or modify it
%   under the terms of the GNU General Public License as published by the
%   Free Software Foundation, either version 3 of the License, or (at your
%   option) any later version. 
%   See the GNU General Public License for more details. You should have
%   received a copy of the GNU General Public License along with this
%   program.  If not, see <http://www.gnu.org/licenses/>.


assert_set_function( 'format_poly' );

assert_equals( format_poly( [1] ), '1', 'const 1' ); % # ok [1]
assert_equals( format_poly( [0 0 0 0] ), '0', 'zero' );
assert_equals( format_poly( [1 0 3 0 5 0] ), 'x^5+3x^3+5x', 'poly' );
assert_equals( format_poly( [0 1 0 3 0 5], 'symbol', 'z' ), 'z^4+3z^2+5', 'polyz' );

assert_equals( format_poly( [2 -3 -4] ), '2x^2-3x-4', 'minus' );
assert_equals( format_poly( [-2 -3 -4] ), '-2x^2-3x-4', 'minus' );
assert_equals( format_poly( [2 3 4], 'tight', false ), '2x^2 + 3x + 4', 'tight' );
assert_equals( format_poly( [-2 -3 -4], 'tight', false ), '-2x^2 - 3x - 4', 'tight-minus' );

options.tight=false;
options.twoline=true;
options.symbol='u';
assert_equals( format_poly( [-1 -1 -1], options ), ['  2        '; '-u  - u - 1'], 'twoline' );
assert_equals( format_poly( [1 1 1], options ), [' 2        '; 'u  + u + 1'], 'twoline' );