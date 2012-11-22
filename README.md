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

## Evented::Configuration->new(\%config, $filename)

Creates a new instance of Evented::Configuration.

```perl
our %config;
my $conf = Evented::Configuration->new(\%config, 'etc/example.conf');
```

### Parameters

* **config:** a hash reference which Evented::Configuration will store its data in.
* **filename:** a string filename of the configuration to read.

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

# Events

Evented::Configuration fires events when configuration values are changed.  
  
In any case, events are fired with arguments `(old value, new value)`.  
  
Say you have an unnamed block of type `myBlock`. If you changed the key `myKey` in `myBlock`, Evented::Configuration would fire the event `change_myBlock_myKey`.  
  
Now assume you have a named block of type `myBlock` with name `myName`. If you changed the key `myKey` in `myBlock:myName`, Evented::Configuration would fire event `change_myBlock:myName_myKey`.

# History

The Evented::Configuration parser first appeared procedurally in juno-ircd version 2. The format has not changed since. The parser was used in several other IRC softwares, including foxy-java IRC bot and ntirc IRC client. It was also included in all versions of juno-ircd succeeding juno2: juno3, juno-mesh, and juno5. In the Arinity IRC services package, the parser had a basic objective interface. However, Evented::Configuration was not based on this interface. Evented::Configuration appeared initially in UICd, the Universal Internet Chat server daemon.
