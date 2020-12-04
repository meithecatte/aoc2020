parse_field(Field, Name, Value) :- split_string(Field, ":", "", [Name, Value]).

parse_passport(Passport, Names, Values) :-
    split_string(Passport, " ", " ", Fields),
    maplist(parse_field, Fields, Names, Values).

subset([], _).
subset([E|X], Y) :- member(E, Y), !, subset(X, Y).

valid_part1(Names, _) :-
    subset(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"], Names).

valid_part2(Names, Values) :-
    valid_part1(Names, Values),
    maplist(check_field, Names, Values).

passports(Input, Passports) :-
    split_string(Input, "\n", "", Lines),
    split_empty_lines(Lines, Separated),
    maplist(merge_lines, Separated, Passports).

split_empty_lines([], [[]]).
split_empty_lines(["" | X], [[] | Y]) :- !, split_empty_lines(X, Y).
split_empty_lines([E | X], [[E | R] | Y]) :- split_empty_lines(X, [R | Y]).

merge_lines([], "").
merge_lines([E | X], S) :- merge_lines(X, S2),
    string_concat(E, " ", S3),
    string_concat(S2, S3, S).

count_valid(_, [], 0).
count_valid(C, [Current | Rest], Count) :-
    parse_passport(Current, Names, Values),
    call(C, Names, Values), !,
    count_valid(C, Rest, RestCount),
    Count is RestCount + 1.
count_valid(C, [_ | Rest], Count) :- count_valid(C, Rest, Count).

check_field("byr", X) :- atom_number(X, N), between(1920, 2002, N).
check_field("iyr", X) :- atom_number(X, N), between(2010, 2020, N).
check_field("eyr", X) :- atom_number(X, N), between(2020, 2030, N).
check_field("hgt", X) :- string_concat(H, "cm", X), atom_number(H, N), between(150, 193, N).
check_field("hgt", X) :- string_concat(H, "in", X), atom_number(H, N), between(59, 76, N).
check_field("hcl", X) :-
    string_concat("#", Rest, X),
    string_length(Rest, 6),
    string_chars(Rest, Chars),
    subset(Chars, ['0', '1', '2', '3', '4', '5', '6', '7',
                   '8', '9', 'a', 'b', 'c', 'd', 'e', 'f']).

check_field("ecl", "amb").
check_field("ecl", "blu").
check_field("ecl", "brn").
check_field("ecl", "gry").
check_field("ecl", "grn").
check_field("ecl", "hzl").
check_field("ecl", "oth").

check_field("pid", X) :- string_length(X, 9), atom_number(X, _).
check_field("cid", _).

:-
    open(input, read, Fd),
    read_string(Fd, _, Input),
    passports(Input, Passports),
    count_valid(valid_part1, Passports, Count1),
    write(Count1), write('\n'),
    count_valid(valid_part2, Passports, Count2),
    write(Count2), write('\n'),
    halt.
