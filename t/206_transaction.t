use strict;
use warnings;
use utf8;
use Test::Declare;
use YAML;

use lib './t';
use Mock::BasicMySQL;

plan tests => blocks;

describe 'transaction test' => run {
    init {
        Mock::BasicMySQL->setup_test_db;
    };

    test 'do basic transaction' => run {
        Mock::BasicMySQL->txn_begin;
        my $row = Mock::BasicMySQL->insert('mock_basic_mysql',{
            name => 'perl',
        });
        is $row->id, 1;
        is $row->name, 'perl';
        Mock::BasicMySQL->txn_commit;
        
        is +Mock::BasicMySQL->single('mock_basic_mysql',{id => 1})->name, 'perl';
    };

    test 'do rollback' => run {
        Mock::BasicMySQL->txn_begin;
        my $row = Mock::BasicMySQL->insert('mock_basic_mysql',{
            name => 'perl',
        });
        is $row->id, 2;
        is $row->name, 'perl';
        Mock::BasicMySQL->txn_rollback;
        
        ok not +Mock::BasicMySQL->single('mock_basic_mysql',{id => 2});
    };

    test 'do commit' => run {
        Mock::BasicMySQL->txn_begin;
        my $row = Mock::BasicMySQL->insert('mock_basic_mysql',{
            name => 'perl',
        });
        is $row->id, 3;
        is $row->name, 'perl';
        Mock::BasicMySQL->txn_commit;

        ok +Mock::BasicMySQL->single('mock_basic_mysql',{id => 3});
    };

    cleanup {
        Mock::BasicMySQL->cleanup_test_db;
        if ( $ENV{SKINNY_PROFILE} ) {
            warn "query log";
            warn YAML::Dump(Mock::BasicMySQL->profiler->query_log);
        }
    };
};

