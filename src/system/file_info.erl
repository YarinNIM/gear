-module(file_info).
-export([extension/1, exists/1, file_size/1, get_info/1,
    mimetype/1, is_image/1
]).

-type file_extension()::binary().
-type file() :: binary().
-type info_field():: size | extension | is_dir | is_file | is_regular | basename | dirname.

-spec exists(file()) -> true | any().
exists(F) ->
    case file:read_file_info(F) of
        {ok, _} -> true;
        Error -> Error
    end.

-spec extension(file()) -> file_extension().
extension(F) -> extension(F, true).
extension(F, C) ->
    case C of
        true ->
            case exists(F) of
                true -> filename:extension(F);
                E -> E
            end;
        _ -> filename:extension(F)
    end.

-spec file_size(file()) -> integer().
file_size(F) -> file_size(F, true).
file_size(F, C) ->
    case C of 
        true -> 
            case exists(F) of
                true -> filelib:file_size(F);
                E -> E
            end;
        _ -> filelib:file_size(F)
    end.

-spec get_info(file()) -> [{info_field(), any()},...].
get_info(F) ->
    case exists(F) of
        {error, Error} -> {error, Error};
        true -> 
            Ext = extension(F, false),
            Size = file_size(F, false),
            [
                {size, Size}, {extension, Ext},
                {is_dir, filelib:is_dir(F)},
                {is_file, filelib:is_file(F)},
                {is_regular, filelib:is_regular(F)},
                {basename, filename:basename(F)},
                {dirname, filename:dirname(F)}
            ]
            
    end.


-spec mimetype(File::string()) -> {error, term()} | string().
mimetype(F) ->
    File = type:to_list(F),
    case exists(File) of
        true ->
            Info = os:cmd("file -i " ++ File),
            [_, Mt, _] = re:split(Info, <<";*\s+">>),
            Mt;
        Else -> Else
    end.

is_image(F) ->
    Mt = mimetype(F),
    case re:run(Mt, <<"^image/">>, [{capture, none}]) of
        match -> true;
        _ -> false
    end.
