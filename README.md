# NAME

**Evented::Configuration** - an event-driven objective configuration class and parser for
Perl software built upon [Evented::Object](https://metacpan.org/pod/Evented::Object).

# SYNOPSIS

## Example usage

````perl
# create a new configuration instance.
my $conf = Evented::Configuration->new(conffile => 'etc/some.conf');
```

````perl
# attach a callback to respond to changes of the user:age key.
$conf->on_change('user', 'name', sub {
    my ($event, $old, $new) = @_;
    say 'The user\'s age changed from ', $old || '(not born)', "to $new";
});
```

````perl
# parse the configuration file.
$conf->parse_config();
```

## Example configuration file

````perl
# some.conf file
```

````perl
# Comments
```

````perl
# Hello, I am a comment.
# I am also a comment.
```

````perl
# Unnamed blocks
```

````perl
[ someBlock ]
```

````perl
someKey  = "some string"
otherKey = 12
another  = ['hello', 'there']
evenMore = ['a'..'z']
```

````perl
# Named blocks
```

````perl
[ cookies: sugar ]
```

````perl
favorites = ['sugar cookie', 'snickerdoodle']
```

````perl
[ cookies: chocolate ]
```

````perl
favorites = ['chocolate macadamia nut', 'chocolate chip']
```

# DESCRIPTION

As the name suggests, event firing is what makes Evented::Configuration unique in
comparison to other configuration classes.

## Blocks

Evented::Configuration's configuration is block-styled, with all keys and values
associated with a block. Blocks can be "named," meaning there are several blocks of one
type with different names, or they can be "unnamed," meaning there is only one block of
that type.

## Objective

Evented::Configuration's objective interface allows you to store nothing more than the
configuration object. Then, make the object accessible where you need it.

## Event-driven

Evented::Configuration is based upon the Evented::Object framework, firing events each time
a configuration changes. This allows software to respond immediately to changes of user
settings, etc.

## Convenience

Most configuration parsers spit out nothing more than a hash reference of keys and values.
Evented::Configuration instead supplies several convenient methods for fetching
configuration data.

# METHODS

Evented::Configuration provides several convenient methods for fetching configuration
values.

## Evented::Configuration->new(%options)

Creates a new instance of Evented::Configuration.

````perl
my $conf = Evented::Configuration->new(conffile => 'etc/some.conf');
```

**Parameters**

- **options**: a hash of constructor options.

**%options - constructor options**

- \* **conffile**: file location of a configuration file.
- \* **hashref**: _optional_, a hash ref to store configuration values in.

## $conf->parse\_config()

Parses the configuration file. Used also to rehash configuration.

````perl
$conf->parse_config();
```

## $conf->get($block, $key)

Fetches a single configuration value.

````perl
my $value = $conf->get('unnamedBlock', 'someKey');
my $other = $conf->get(['blockType', 'namedBlock'], 'someKey');
```

**Parameters**

- **block**: for unnamed blocks, should be the string block type. for named blocks, should be
an array reference in the form of `[block type, block name]`.
- **key**: the key of the configuration value being fetched.

## $conf->names\_of\_block($block\_type)

Returns an array of the names of all blocks of the specified type.

````perl
foreach my $block_name ($conf->names_of_block('cookies')) {
    print "name of this cookie block: $block_name\n";
}
```

**Parameters**

- **block\_type**: the type of the named block.

## $conf->keys\_of\_block($block)

Returns an array of all the keys in the specified block.

````perl
foreach my $key ($conf->keys_of_block('someUnnamedBlock')) {
    print "someUnnamedBlock unnamed block has key: $key\n";
}
```

````perl
foreach my $key ($conf->keys_of_block('someNamedBlock', 'someName')) {
    print "someNamedBlock:someName named block has key: $key\n";
}
```

**Parameters**

- **block**: for unnamed blocks, should be the string block type. for named blocks, should be
an array reference in the form of `[block type, block name]`.

## $conf->on\_change($block, $key, $code, %opts)

Attaches an event listener for the configuration change event. This event will be fired
even if the value never existed. If you want a listener to be called the first time the
configuration is parsed, simply add the listener before calling `->parse_config()`.
Otherwise, add listeners later.

````perl
# an example with an unnamed block
$conf->on_change('myUnnamedBlock', 'myKey', sub {
    my ($event, $old, $new) = @_;
    ...
});
```

````perl
# an example with a name block.
$conf->on_change(['myNamedBlockType', 'myBlockName'], 'someKey', sub {
    my ($event, $old, $new) = @_;
    ...
});
```

````perl
# an example with an unnamed block and ->register_event() options.
$conf->on_change('myUnnamedBlock', 'myKey', sub {
    my ($event, $old, $new) = @_;
    ...
}, priority => 100, name => 'myCallback');
```

**Parameters**

- **block**: for unnamed blocks, should be the string block type. for named blocks, should be
an array reference in the form of `[block type, block name]`.
- **key**: the key of the configuration value being listened for.
- **code**: a code reference to be called when the value is changed.
- **opts**: _optional_, a hash of any other options to be passed to Evented::Object's
`->register_event()`.

# EVENTS

Evented::Configuration fires events when configuration values are changed.

In any case, events are fired with arguments `(old value, new value)`.

Say you have an unnamed block of type `myBlock`. If you changed the key `myKey` in
`myBlock`, Evented::Configuration would fire the event
`change:myBlock:myKey`.

Now assume you have a named block of type `myBlock` with name `myName`. If you changed
the key `myKey` in `myBlock:myName`, Evented::Configuration would fire event
`change:myBlock/myName:myKey`.

However, it is recommended that you use the `->on_change()` method rather than
directly attaching event callbacks. This will insure compatibility for later versions that
could possibly change the way events are fired.

# SEE ALSO

- [Evented::Object](https://metacpan.org/pod/Evented::Object) - the event class that powers Evented::Configuration.

# AUTHOR

[Mitchell Cooper](https://github.com/cooper) <cooper@cpan.org>

Copyright � 2014. Released under BSD license.

- **IRC channel**: [irc.notroll.net #k](irc://irc.notroll.net/k)
- **Email**: cooper@cpan.org
- **CPAN**: [COOPER](http://search.cpan.org/~cooper/)
- **GitHub**: [cooper](https://github.com/cooper)

Comments, complaints, and recommendations are accepted. IRC is my preferred communication
medium. Bugs may be reported on
[RT](https://rt.cpan.org/Public/Dist/Display.html?Name=Evented-Configuration).
