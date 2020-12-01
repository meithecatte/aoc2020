s" input" r/o open-file throw value fd-in

10 constant buf-len
create line-buffer buf-len allot

: next-num ( -- n not-eof )
  line-buffer buf-len fd-in read-line throw
  if
    >r 0. line-buffer r> >number
    2drop d>s true
  else
    drop false
  then ;

: read-nums ( -- count )
  0 begin
    next-num
  while
    , 1+
  repeat ;

create numbers read-nums constant #numbers

: num-exists ( n -- flag )
  #numbers 0 ?do
    dup numbers i cells + @
    = if
      drop true unloop exit
    then
  loop drop false ;

2020 value target

: complement target swap - ;

: find-pair ( -- 0 | a b -1 )
  #numbers 0 ?do
    numbers i cells + @
    dup complement dup num-exists if
      true unloop exit
    then
    2drop
  loop
  false ;

find-pair invert throw * .

: find-triple ( -- a b c )
  #numbers 0 ?do
    numbers i cells + @
    2020 over - to target
    find-pair if
      unloop exit
    then
    drop
  loop
  abort" not found" ;

find-triple * * .

bye
