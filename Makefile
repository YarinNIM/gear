FULL = 1
PROJECT = gear


DEPS = cowboy erlydtl sync jsx gen_smtp epgsql poolboy gproc lager #eargon2
dep_epgsql_commit = master
dep_cowboy_commit = 2.6.3
dep_gproc_commit = master
dep_poolboy_commit = master
dep_sync_commit = master
dep_erlydtl_commit = master
# dep_eargon2_commit = master
# dep_lager_commit = master
# dep_jwt_commit = master
# dep_graphql_commit = master


dep_eargon2 = git https://github.com/ergenius/eargon2.git
dep_epgsql = git https://github.com/epgsql/epgsql.git master
dep_poolboy = git https://github.com/devinus/poolboy.git master
dep_gproc = git https://github.com/uwiger/gproc master
dep_sync = git git://github.com/rustyio/sync.git master
dep_erlydtl = git https://github.com/erlydtl/erlydtl.git master
# dep_lager =  https://github.com/erlang-lager/lager.git master

# dep_graphql = https://github.com/shopgun/graphql-erlang.git master
# dep_jwt = git https://github.com/G-Corp/jwerl.git master
# dep_account_message = cp /BTNG/bongthom/apps/account_message
include erlang.mk
