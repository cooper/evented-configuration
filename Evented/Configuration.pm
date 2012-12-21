# Copyright (c) 2012, Mitchell Cooper
#
# Evented::Configuration:
# a configuration file parser and event-driven configuration class.
# Evented::Configuration is based on UICd::Configuration, the class of the UIC daemon.
# UICd's parser was based on juno5's parser, which evolved from juno4, juno3, and juno2.
# Early versions of Evented::Configuration were also found in several IRC bots, including
# foxy-java. Evented::Configuration provides several convenience fetching methods.
#
# Events:
# each time a configuration value changes, change_BLOCKTYPE_BLOCKNAME_KEY is fired with the new and old values.
# for example a change of oper:cooper:password would fire change_oper:cooper_password(oldpassword, newpassword).
# the event is fired AFTER the actual value is changed.
#
package Evented::Configuration;

use warnings;
use strict;
use utf8;
use parent 'EventedObject';

our $VERSION = 2.9;

sub on  () { 1 }
sub off () { undef }

# create a new configuration instance.
sub new {
    my ($class, %opts) = (shift, @_);
    
    # if there is no 'conffile' and no 'hashref', assume they are using
    # the former ($hashref, $conffile) initialization arguments.
    if (!exists $opts{hashref} && !exists $opts{conffile}) {
        ($opts{hashref}, $opts{conffile}) = (shift, shift);
    }
    
    # if we still have no defined conffile, we must give up now.
    if (!defined $opts{conffile}) {
        $@ = 'no configuration file (conffile) option specified.';
        return;
    }
    
    # if 'hashref' is provided, use it.
    $opts{conf} = $opts{hashref} || $opts{conf} || {};
    
    # return the new configuration object.
    return bless \%opts, $class;
    
}

# parse the configuration file.
sub parse_config {
    my ($conf, $i, $block, $name, $key, $val, $config) = shift;
    open $config, '<', $conf->{conffile} or return;
    
    while (my $line = <$config>) {

        $i++;
        $line = trim($line);
        next unless $line;
        next if $line =~ m/^#/;

        # a block with a name.
        if ($line =~ m/^\[(.*?):(.*)\]$/) {
            $block = trim($1);
            $name  = trim($2);
        }

        # a nameless block.
        elsif ($line =~ m/^\[(.*)\]$/) {
            $block = 'section';
            $name  = trim($1);
        }

        # a key and value.
        elsif ($line =~ m/^(\s*)([\w:]*)(\s*)[:=]+(.*)$/ && defined $block) {
            $key = trim($2);
            $val = eval trim($4);
            die "Invalid value in $$conf{conffile} line $i: $@\n" if $@;
            
            # the value has changed, so send the event.
            if (!exists $conf->{conf}{$block}{$name}{$key} ||
                $conf->{conf}{$block}{$name}{$key} ne $val) {
                my $old = $conf->{conf}{$block}{$name}{$key} = $val;
                $conf->fire_event("change_${block}_${name}_${key}" => $old, $val);
            }
            
        }

        # I don't know how to handle this.
        else {
            die "Invalid line $i of $$conf{conffile}\n";
        }

    }
    
    return 1;
}

# returns true if the block is found.
# supports unnamed blocks by get(block, key)
# supports   named blocks by get([block type, block name], key)
sub has_block {
    my ($conf, $block) = @_;
    $block = ['section', $block] if !ref $block || ref $block ne 'ARRAY';
    return 1 if $conf->{conf}{$block->[0]}{$block->[1]};
}

# returns a list of all the names of a block type.
# for example, names_of_block('listen') might return ('0.0.0.0', '127.0.0.1')
sub names_of_block {
    my ($conf, $blocktype) = @_;
    return keys %{$conf->{conf}{$blocktype}};
}

# returns a list of all the keys in a block.
# for example, keys_of_block('modules') would return an array of every module.
# accepts block type or [block type, block name] as well.
sub keys_of_block {
    my ($conf, $block, $blocktype, $section) = (shift, shift);
    $blocktype = (ref $block && ref $block eq 'ARRAY') ? $block->[0] : 'section';
    $section   = (ref $block && ref $block eq 'ARRAY') ? $block->[1] : $block;
    return my @a unless $conf->{conf}{$blocktype}{$section};
    return keys %{$conf->{conf}{$blocktype}{$section}};
}

# returns a list of all the values in a block.
# accepts block type or [block type, block name] as well.
sub values_of_block {
    my ($conf, $block, $blocktype, $section) = (shift, shift);
    $blocktype = (ref $block && ref $block eq 'ARRAY') ? $block->[0] : 'section';
    $section   = (ref $block && ref $block eq 'ARRAY') ? $block->[1] : $block;
    return my @a unless $conf->{conf}{$blocktype}{$section};
    return values %{$conf->{conf}{$blocktype}{$section}};
}

# returns the key:value hash of a block.
# accepts block type or [block type, block name] as well.
sub hash_of_block {
    my ($conf, $block, $blocktype, $section) = (shift, shift);
    $blocktype = (ref $block && ref $block eq 'ARRAY') ? $block->[0] : 'section';
    $section   = (ref $block && ref $block eq 'ARRAY') ? $block->[1] : $block;
    return my %h unless $conf->{conf}{$blocktype}{$section};
    return %{$conf->{conf}{$blocktype}{$section}};
}

# get a configuration value.
# supports unnamed blocks by get(block, key)
# supports   named blocks by get([block type, block name], key)
sub get {
    my ($conf, $block, $key) = @_;
    if (defined ref $block && ref $block eq 'ARRAY') {
        return $conf->{conf}{$block->[0]}{$block->[1]}{$key};
    }
    return $conf->{conf}{section}{$block}{$key};
}

# remove leading and trailing whitespace.
sub trim {
    my $string = shift;
    $string =~ s/\s+$//;
    $string =~ s/^\s+//;
    return $string;
}

1
