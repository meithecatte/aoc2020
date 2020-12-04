field_name(Field, Name) :- split_string(Field, ":", "", [Name|_]).

field_names([], []).
field_names([Field|Fields], [Name|Names]) :-
    field_name(Field, Name),
    field_names(Fields, Names).

subset([], _).
subset([E|X], Y) :- member(E, Y), !, subset(X, Y).

valid(Passport) :-
    split_string(Passport, " ", " ", Fields),
    maplist(field_name, Fields, Names),
    %field_names(Fields, Names),
    subset(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"], Names).

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

count_valid([], 0).
count_valid([Current | Rest], Count) :- valid(Current), !,
    count_valid(Rest, RestCount),
    Count is RestCount + 1.
count_valid([_ | Rest], Count) :- count_valid(Rest, Count).

:-
    open(input, read, Fd),
    read_string(Fd, _, Input),
    passports(Input, Passports),
    count_valid(Passports, Count),
    write(Count),
    halt.
