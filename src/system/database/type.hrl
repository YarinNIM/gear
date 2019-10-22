-type preposition_type() :: 'or' | 'and'.
-type join_type():: 'inner' | 'left outer' | 'right outer'.
-type join_table_type() ::{
    Join_type:: join_type(),
    Join_table:: string(),
    {Join_table_field:: string(), Table_field::string()}
}.
-type order_by_type():: desc | asc.
-type data_type():: 'ARRAY' | 'character' | 'character varying' | 'integer' | 'jsonb' | 'mumeric' | 'text'.
-type udt_type() :: '_bpchar' | 'bpchar' | 'int4' | 'jsonb' | 'varchar' | '_varchar' | 'text' | '_text'.
-type from_type():: Table::string() | {Table::string(), [Join_talbe::join_table_type()]}.


