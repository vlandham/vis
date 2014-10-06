# Formatting
# ----------

# TODO: maybe this file should be split up into their respective sections:
#   operators -> operators
#   array literals -> array literals
#   string literals -> string literals
#   function invocations -> function invocations

doesNotThrow -> CoffeeScript.compile "a = then b"

test "multiple semicolon-separated statements in parentheticals", ->
  nonce = {}
  eq nonce, (1; 2; nonce)
  eq nonce, (-> return (1; 2; nonce))()

# * Line Continuation
#   * Property Accesss
#   * Operators
#   * Array Literals
#   * Function Invocations
#   * String Literals

# Property Access

test "chained accesses split on period/newline, backwards and forwards", ->
  str = 'abc'
  result = str.
    split('').
    reverse().
    reverse().
    reverse()
  arrayEq ['c','b','a'], result
  arrayEq ['c','b','a'], str.
    split('').
    reverse().
    reverse().
    reverse()
  result = str
    .split('')
    .reverse()
    .reverse()
    .reverse()
  arrayEq ['c','b','a'], result
  arrayEq ['c','b','a'],
    str
    .split('')
    .reverse()
    .reverse()
    .reverse()
  arrayEq ['c','b','a'],
    str.
    split('')
    .reverse().
    reverse()
    .reverse()

# Operators

test "newline suppression for operators", ->
  six =
    1 +
    2 +
    3
  eq 6, six

test "`?.` and `::` should continue lines", ->
  ok not (
    Date
    ::
    ?.foo
  )
  #eq Object::toString, Date?.
  #prototype
  #::
  #?.foo

doesNotThrow -> CoffeeScript.compile """
  oh. yes
  oh?. true
  oh:: return
  """

doesNotThrow -> CoffeeScript.compile """
  a?[b..]
  a?[...b]
  a?[b..c]
  """

# Array Literals

test "indented array literals don't trigger whitespace rewriting", ->
  getArgs = -> arguments
  result = getArgs(
    [[[[[],
                  []],
                [[]]]],
      []])
  eq 1, result.length

# Function Invocations

doesNotThrow -> CoffeeScript.compile """
  obj = then fn 1,
    1: 1
    a:
      b: ->
        fn c,
          d: e
    f: 1
  """

# String Literals

test "indented heredoc", ->
  result = ((_) -> _)(
                """
                abc
                """)
  eq "abc", result

# Chaining - all open calls are closed by property access starting a new line
# * chaining after
#   * indented argument
#   * function block
#   * indented object
#
#   * single line arguments
#   * inline function literal
#   * inline object literal

test "chaining after outdent", ->
  id = (x) -> x

  # indented argument
  ff = id parseInt "ff",
    16
  .toString()
  eq '255', ff

  # function block
  str = 'abc'
  zero = parseInt str.replace /\w/, (letter) ->
    0
  .toString()
  eq '0', zero

  # indented object
  a = id id
    a: 1
  .a
  eq 1, a

test "#1495, method call chaining", ->
  str = 'abc'

  result = str.split ''
              .join ', '
  eq 'a, b, c', result

  result = str
  .split ''
  .join ', '
  eq 'a, b, c', result

  eq 'a, b, c', (str
    .split ''
    .join ', '
  )

  eq 'abc',
    'aaabbbccc'.replace /(\w)\1\1/g, '$1$1'
               .replace /([abc])\1/g, '$1'

  # Nested calls
  result = [1..3]
    .slice Math.max 0, 1
    .concat [3]
  arrayEq [2, 3, 3], result

  # Single line function arguments
  result = [1..6]
    .map (x) -> x * x
    .filter (x) -> x % 2 is 0
    .reverse()
  arrayEq [36, 16, 4], result

  # Single line implicit objects
  id = (x) -> x
  result = id a: 1
    .a
  eq 1, result

  # The parens are forced
  result = str.split(''.
    split ''
    .join ''
  ).join ', '
  eq 'a, b, c', result

# Nested blocks caused by paren unwrapping
test "#1492: Nested blocks don't cause double semicolons", ->
  js = CoffeeScript.compile '(0;0)'
  eq -1, js.indexOf ';;'

test "#1195 Ignore trailing semicolons (before newlines or as the last char in a program)", ->
  preNewline = (numSemicolons) ->
    """
    nonce = {}; nonce2 = {}
    f = -> nonce#{Array(numSemicolons+1).join(';')}
    nonce2
    unless f() is nonce then throw new Error('; before linebreak should = newline')
    """
  CoffeeScript.run(preNewline(n), bare: true) for n in [1,2,3]

  lastChar = '-> lastChar;'
  doesNotThrow -> CoffeeScript.compile lastChar, bare: true

test "#1299: Disallow token misnesting", ->
  try
    CoffeeScript.compile '''
      [{
         ]}
    '''
    ok no
  catch e
    eq 'unmatched ]', e.message

test "#2981: Enforce initial indentation", ->
  try
    CoffeeScript.compile '  a\nb-'
    ok no
  catch e
    eq 'missing indentation', e.message

test "'single-line' expression containing multiple lines", ->
  doesNotThrow -> CoffeeScript.compile """
    (a, b) -> if a
      -a
    else if b
    then -b
    else null
  """

test "#1275: allow indentation before closing brackets", ->
  array = [
      1
      2
      3
    ]
  eq array, array
  do ->
  (
    a = 1
   )
  eq 1, a
