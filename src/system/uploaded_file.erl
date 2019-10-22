%% @author Yarin NIM <yarin.nim@gmail.com>
%% @copyright 2019 Yarin NIM
%% @version 0.1
%% @title Uploaded File
%% @doc  This module is for uploaded file.
%% File can be any file defined in the configuration

-module(uploaded_file).
-export([ save/2 ]).

%map_val(K, M) -> map_val(K, M, undefined).
%map_val(K, M, D) -> 
%   case maps:find(K, M) of
%       error ->  D;
%       {ok, V} -> V
%   end.
%
%% @doc Validate the mininum file size
validate(min_file_size, Min, #{ file_size:= Size} = _File) ->
    if 
        Size < Min -> ok;
        true -> {error, <<"File size is too small">>}
    end;
%% @doc Validates the maximum file size
validate(max_file_size, Max, #{ file_size:= Size} = _File) ->
    if 
        Size > Max -> {error, <<"File size is too big">>};
        true -> ok
    end;
%% @doc Validates allowed file extensions
validate(extensions, Exts, #{ extension:= Ext} = _File) ->
    case lists:member(Exts, Ext) of
        false -> {error, <<"File extension not allowed">>};
        _ -> ok
    end;
validate(max_size, {Mw, Mh}, #{tmp_path:= F} = _File) ->
    {W, H} = image_magick:image_size(F),
    if
        W > Mw -> {error, <<"Image width is too big">>};
        H > Mh -> {error, <<"Image height is too big">>};
        true -> ok
    end;
validate(min_size, {Mw, Mh}, #{ tmp_path:= F} = _Fiel) ->
    {W, H} = image_magick:image_size(F),
    if
        W < Mw -> {error, <<"Image width is too small">>};
        H < Mh -> {error, <<"Image height is too small">>};
        true -> ok
    end.

rules(Conf, File) ->
    Ks = [min_file_size, max_file_size, extensions, max_size, min_size],
    maps:fold(fun(K, V, I) ->
        case lists:member(K, Ks) of
            true -> [fun() -> validate(K, V, File) end | I];
            _ -> I
        end
    end, [], Conf).

%% @doc Validates the uploaded file
%% When one of the rule function returns {error, Msg}
%% the loop is terminated
-spec validate(list()) -> ok | { error, Msg::binary()}.
validate([]) -> ok;
validate([H | T]) ->
    case H() of
        true -> T();
        Else -> Else
    end.

%% @doc Returns the file destination, where 
%% the uploaded file will be saved/moved to
-spec file_dest(map(), map()) -> binary().
file_dest(F, P) -> file_dest(F, P, <<>>).
file_dest(#{ tmp_name:= N} = _F, #{ upload_path:= UPath} = _Opt, M) ->
    P = type:to_binary(UPath),
    <<P/binary, M/binary, N/binary>>.

%% @doc check if the options paramter is
%% set with thumbnail information. If it sets, 
%% the tbumbnail will be created
thumb(#{ tmp_path:= Source} = File, Opt) ->
    case maps:find(thumb, Opt) of
        {ok, Size } -> image_magick:resize(Source, Size, file_dest(File, Opt, <<"thumb/">>));
        _ -> ok
    end.

%% @doc Saves image from tmp path to destination path.
%% The images will be resized the max_size if the max_size is defined
-spec save_image(File::map(), Options::map()) -> ok.
save_image(#{ tmp_path:= Source} = File, Opt) ->
    Dest = file_dest(File, Opt),
    case maps:find(resize_to, Opt) of
        error -> file:rename(Source, Dest);
        {ok, Size} -> image_magick:resize(Source, Size, Dest)
    end.

%% @doc Saves uploaded file to defined destination
save_file(#{ tmp_path:= Source} = File, Opt) ->
    Dest = file_dest(File, Opt),
    case file_info:is_image(Source) of
        true ->
            thumb(File, Opt),
            save_image(File, Opt);
        _ -> file:rename(Source, Dest)
    end.

    
save(File, Opt) ->
    Rules = rules(Opt, File),
    case validate(Rules) of
        ok ->  save_file(File, Opt);
        Else -> Else
    end.
