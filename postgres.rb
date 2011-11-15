# encoding: UTF-8

dep 'postgres has a unaccenting stemming dictionary', :db_name do
  define_var :dictionary_name, :default => 'english_stemmer'
  define_var :search_configuration_name, :default => 'unaccenting_english_stemmer'
  define_var :postgres_shared_path, :default => '/usr/share/postgresql/9.0'
  requires [
    'unaccenting installed'.with(db_name),
    'english stemming dictionary installed'.with(db_name),
    'text search configuration installed'.with(db_name)
end

dep 'unaccenting installed' do
  requires 'unaccent files exist', 'interpunct is a dash'
  met? { shell("psql #{var(:db_name)} -c '\\dFd'") =~ /public.*unaccent/ }
  meet {
    sudo "cat #{var(:postgres_shared_path) / 'contrib/unaccent.sql'} | psql #{var :db_name}",
         :as => 'postgres'
  }
end

dep 'unaccent files exist' do
  requires_when_unmet 'postgresql-contrib.managed'
  met? {
    (var(:postgres_shared_path) / 'contrib/unaccent.sql').exists? &&
    (var(:postgres_shared_path) / 'tsearch_data/unaccent.rules').exists?
  }
end

dep 'postgresql-contrib.managed' do
  requires 'benhoskings:postgres.managed'
  provides []
end

dep 'interpunct is a dash' do
  met? { grep /•\t-/, var(:postgres_shared_path) / 'tsearch_data/unaccent.rules' }
  meet { sudo 'echo -e "•\t-" >> ' + var(:postgres_shared_path) / 'tsearch_data/unaccent.rules' }
end

dep 'english stemming dictionary installed' do
  met? { shell("psql #{var(:db_name)} -c '\\dFd'") =~ /public.*#{var :dictionary_name}/ }
  meet {
    shell "psql #{var(:db_name)}", :input => %Q{
CREATE TEXT SEARCH DICTIONARY public.#{var :dictionary_name} (TEMPLATE = pg_catalog.snowball, LANGUAGE = english);
}
    }
end

dep 'text search configuration installed' do
  met? { shell("psql #{var(:db_name)} -c '\\dF'") =~ /public.*#{var :search_configuration_name}/ }
  meet {
    shell "psql #{var(:db_name)}", :input => %Q{
create text search configuration public.#{var :search_configuration_name} (copy = pg_catalog.english);
alter text search configuration #{var :search_configuration_name}
  alter mapping for asciihword, asciiword, hword, hword_asciipart, hword_numpart, hword_part, word
  with unaccent, #{var :dictionary_name};
}
  }
end
