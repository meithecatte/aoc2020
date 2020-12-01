s" input" r/o open-file throw Value fd-in

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

: complement 2020 swap - ;

: find-pair ( -- a b )
  #numbers 0 ?do
    numbers i cells + @
    dup complement dup num-exists if
      unloop exit
    then
    2drop
  loop
  abort" not found" ;

find-pair * .

bye
