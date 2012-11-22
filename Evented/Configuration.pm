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

sub on  { 1 }
sub off { undef }

# create a new configuration instance.
sub new {
    my ($class, $hashref, $filename) = @_;
    return bless {
        conf     => $hashref,
        filename => $filename
    }, $class;
}

# parse the configuration file.
sub parse_config {
    my ($conf, $i, $block, $name, $key, $val, $config) = shift;
    open $config, '<', $conf->{filename} or return;
    
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
        elsif ($line =~ m/^(\s*)([\w:]*)(\s*)=(.*)$/ && defined $block) {
            $key = trim($2);
            $val = eval trim($4);
            die "Invalid value in $$conf{filename} line $i: $@\n" if $@;
            
            # the value has changed, so send the event.
            if (!exists $conf->{conf}{$block}{$name}{$key} ||
                $conf->{conf}{$block}{$name}{$key} ne $val) {
                my $old = $conf->{conf}{$block}{$name}{$key} = $val;
                $conf->fire_event("change_${block}_${name}_${key}" => $old, $val);
            }
            
        }

        # I don't know how to handle this.
        else {
            die "Invalid line $i of $$conf{filename}\n";
        }

    }
    
    return 1;
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
