# Evented::Configuration

Evented::Configuration is an event-driven objective configuration class and parser for Perl software built upon EventedObject.

# Features

* **Blocks:** Evented::Configuration's configuration is block-styled, with all keys and values associated with a block. Blocks can be "named," meaning there are several blocks of one type with different names, or they can be "unnamed," meaning there is only one block of that type.

* **Objective:** Evented::Configuration's objective interface allows you to store nothing more than the configuration object. Then, make the object accessible where you need it.

* **Event-driven:** Evented::Configuration is based upon the EventedObject framework, firing events each time a configuration changes. This allows software to respond immediately to changes of user settings, etc.

* **Convenience:** Most configuration parsers spit out nothing more than a hash reference of keys and values. Evented::Configuration instead supplies several convenient methods for fetching configuration data.

# Format

```

# Comments

# Hello, I am a comment.
# I am also a comment.

# Unnamed blocks

[ someBlock ]

someKey  = "some string"
otherKey = 12
another  = ['hello', 'there']
evenMore = ['a'..'z']

# Named blocks

[ cookies: sugar ]

favorites = ['sugar cookie', 'snickerdoodle']

[ cookies: chocolate ]

favorites = ['chocolate macadamia nut', 'chocolate chip']

```

# Methods

Evented::Configuration provides several convenient methods for fetching configuration values.

## Evented::Configuration->new(%options)

Creates a new instance of Evented::Configuration.

```perl
my $conf = Evented::Configuration->new(conffile => 'etc/some.conf');
```

### Parameters

* **options:** a hash of constructor options.

### %options - constructor options

* __conffile__: file location of a configuration file.
* __hashref__: *optional*, a hash ref to store configuration values in.

## $conf->parse_config()

Parses the configuration file. Used also to rehash configuration.

```perl
$conf->parse_config();
```

## $conf->get($block, $key)

Fetches a single configuration value.

```perl
my $value = $conf->get('unnamedBlock', 'someKey');
my $other = $conf->get(['blockType', 'namedBlock'], 'someKey');
```

### Parameters

* **block:** for unnamed blocks, should be the string block type. for named blocks, should be an array reference in the form of `[block type, block name]`.
* **key:** the key of the configuration value being fetched.

## $conf->names_of_block($block_type)

Returns an array of the names of all blocks of the specified type.

```perl
foreach my $block_name ($conf->names_of_block('cookies')) {
    print "name of this cookie block: $block_name\n";
}
```

### Parameters

* **block_type:** the type of the named block.

## $conf->keys_of_block($block)

Returns an array of all the keys in the specified block.

```perl
foreach my $key ($conf->keys_of_block('someUnnamedBlock')) {
    print "someUnnamedBlock unnamed block has key: $key\n";
}

foreach my $key ($conf->keys_of_block('someNamedBlock', 'someName')) {
    print "someNamedBlock:someName named block has key: $key\n";
}
```

### Parameters

* **block:** for unnamed blocks, should be the string block type. for named blocks, should be an array reference in the form of `[block type, block name]`.

## $conf->on_change($block, $key, $code, %opts)

Attaches an event listener for the configuration change event. This event will be fired
even if the value never existed. If you want a listener to be called the first time the
configuration is parsed, simply add the listener before calling `->parse_config()`.
Otherwise, add listeners later.

```perl
# an example with an unnamed block
$conf->on_change('myUnnamedBlock', 'myKey', sub {
    my ($event, $old, $new) = @_;
    ...
});

# an example with a name block.
$conf->on_change(['myNamedBlockType', 'myBlockName'], 'someKey', sub {
    my ($event, $old, $new) = @_;
    ...
});

# an example with an unnamed block and ->register_event() options.
$conf->on_change('myUnnamedBlock', 'myKey', sub {
    my ($event, $old, $new) = @_;
    ...
}, priority => 100, name => 'myCallback');
```

### Parameters

* __block__: for unnamed blocks, should be the string block type. for named blocks, should be an array reference in the form of `[block type, block name]`.
* __key__: the key of the configuration value being listened for.
* __code__: a code reference to be called when the value is changed.
* __opts__: *optional*, a hash of any other options to be passed to EventedObject's `->register_event()`.

# Events

Evented::Configuration fires events when configuration values are changed.  
  
In any case, events are fired with arguments `(old value, new value)`.  
  
Say you have an unnamed block of type `myBlock`. If you changed the key `myKey` in `myBlock`, Evented::Configuration would fire the event `eventedConfiguration.change:myBlock:myKey`.  
  
Now assume you have a named block of type `myBlock` with name `myName`. If you changed the key `myKey` in `myBlock:myName`, Evented::Configuration would fire event `eventedConfiguration.change:myBlock/myName:myKey`.  
  
However, it is recommended that you use the `->on_change()` method rather than directly attaching event callbacks. This will insure compatibility for later versions that could possibly change the way events are fired.

# History

The Evented::Configuration parser first appeared procedurally in juno-ircd version 2. The format has not changed since. The parser was used in several other IRC softwares, including foxy-java IRC bot and ntirc IRC client. It was also included in all versions of juno-ircd succeeding juno2: juno3, juno-mesh, and juno5. In the Arinity IRC services package, the parser had a basic objective interface. However, Evented::Configuration was not based on this interface. Evented::Configuration appeared initially in UICd, the Universal Internet Chat server daemon.

# See also

* [EventedObject](https://github.com/cooper/evented-object) - an event framework and the base class of Evented::Configuration.
* [Evented::Database](https://github.com/cooper/evented-database) - a database built upon Evented::Configuration with seamless database functionality added to a configuration class.
