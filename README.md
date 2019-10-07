|            | Build Status |
| ---------- | ------------ |
| `master` | [![Build Status](https://travis-ci.com/revelrylabs/elixir-xdr.svg?token=K2LyiUSDgTC1mWqq2YnM&branch=master)](https://travis-ci.com/revelrylabs/elixir-xdr) |
| Coverage | ![Coverage Status](https://opencov.prod.revelry.net/projects/40/badge.svg) |

# XDR

XDR is an open data format for serializing and de-serializing structured data based on shared definitions,
defined in [RFC 4506](http://tools.ietf.org/html/rfc4506.html). This library aims to provide an idiomatic
interface for working with XDR data in Elixir.


## Documentation

Detailed documentation and examples can be found at [https://hexdocs.pm/elixir-xdr](https://hexdocs.pm/elixir_xdr).


## Installation

Add [`elixir_xdr`](https://hex.pm/packages/elixir_xdr) to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:elixir_xdr, "~> 0.1.0"}
  ]
end
```


## Basic Usage

To work with XDR, an application needs to be able to do five things:

1. Define the types and structure of the data
2. Create instances of the data types with specific values
3. Encode that structured data into a binary representation
4. Decode a binary representation into structured, typed data
5. Extract the raw values from the data structures

The main `XDR` module provides functions for each of these operations.
These examples illustrate their usage:


### Building data types

Fully-determined types can be built by configuring and combining the predefined XDR types.

```elixir
int_type = XDR.build_type(XDR.Type.Int)
name_type = XDR.build_type(XDR.Type.VariableOpaque)
five_ints_type = XDR.build_type(XDR.Type.Array, type: int_type, length: 5)
student_type = XDR.build_type(XDR.Type.Struct,
  name: name_type,
  quiz_scores: five_ints_type,
  homework_scores: five_ints_type
)
```

The configuration required by each built-in type varies. See the [documentation](https://hexdocs.pm/elixir-xdr/XDR.html#build_type/2) for more details.


### Adding specific values

Once the data types are defined, values can be built. Again, the applicable values
depend on the data types.

```elixir
{:ok, single_score} = XDR.build_value(int_type, 92)
{:ok, single_name} = XDR.build_value(name_type, "Student A")
```

Complex data types can be built up all at once, rather than having to initialize
each subsidiary value:

```elixir
{:ok, student_a} = XDR.build_value(student_type,
  name: "Student A",
  quiz_scores: [100, 93, 60, 88, 100],
  homework_scores: [66, 80, 100, 99, 0]
)
```


### Encoding data

Once data structures have been defined and specific values created, they can be encoded
into a binary XDR representation:

```elixir
{:ok, single_score_encoding} = XDR.encode(single_score)
{:ok, single_name_encoding} = XDR.encode(single_name)
{:ok, student_a_encoding} = XDR.encode(student_a)
```


### Decoding data

Any XDR implementation with access to the same type definitions will be able to decode the binary
representations into structured data.

```elixir
{:ok, single_score_decoded} = XDR.decode(int_type, single_score_encoding)
{:ok, single_name_decoded} = XDR.decode(name_type, single_name_encoding)
{:ok, student_a_decoded} = XDR.decode(student_type, student_a_encoding)

# Upon decoding, these values are fully-fledged XDR types
%XDR.Type.Struct{fields: fields} = student_a_decoded
```


### Extracting underlying values

To use the data, we probably want to extract the raw values from the XDR metadata:

```elixir
{:ok, student_a_data} = XDR.extract_value(student_a_decoded)

# this should match what we put in originally
[
  name: "Student A",
  quiz_scores: [100, 93, 60, 88, 100],
  homework_scores: [66, 80, 100, 99, 0]
] = student_a_data
```


## Custom XDR Type Definitions

When building complex apps, it's not convenient to have to build up the types
manually every time time they're needed, so an application can predefine
its XDR types and compile them into the application. The `XDR.Base` module
provides the `define_type` macro for registering and accessing application-specific
types using the `define_type` macro.

```elixir
defmodule MyXDR
  @moduledoc """
  We can define custom types in our own module and then work with them through that module.

  All of the functions demonstrated above on XDR are available on MyXDR,
  and we can use simple string names to reference our predefined XDR types.
  """

  use XDR.Base

  # `define_type` works just like `build_type` with an extra `name` parameter at the front
  define_type("Student", Struct,
    name: "Name",
    quiz_scores: "Scores",
    homework_scores: "Scores",
  )

  define_type("Scores", Array,
    type: "Score",
    length: 5
  )

  define_type("Score", Int)

  define_type("Name", VariableOpaque)
end

# using the predefined types in our code
{:ok, student_b} = MyXDR.build_value!("Student",
  name: "Student B",
  quiz_scores: [93, 60, 88, 100, 84],
  homework_scores: [80, 100, 99, 0, 90]
)
{:ok, encoded_student_b} = MyXDR.encode(student_b)
{:ok, decoded_student_b} = MyXDR.decode("Student", encoded_student_b)
```

For a real-life example, see the [`Stellar.XDR`](https://github.com/revelrylabs/elixir-xdr/tree/master/test/support/stellar/Stellar.XDR_generated.ex) module, which was generated from [the Stellar type definitions](https://github.com/stellar/js-stellar-base/tree/master/xdr) using the [xdrgen tool](https://github.com/stellar/xdrgen).


## Contributing and Development

See [CONTRIBUTING.md](https://github.com/revelrylabs/elixir-xdr/blob/master/CONTRIBUTING.md)
for guidance on how to develop for this library.

Bug reports and pull requests are welcome on GitHub at https://github.com/revelrylabs/elixir-xdr. Check out [CONTRIBUTING.md](https://github.com/revelrylabs/elixir-xdr/blob/master/CONTRIBUTING.md) for more info.

Everyone is welcome to participate in the project. We expect contributors to
adhere to the Contributor Covenant Code of Conduct (see [CODE_OF_CONDUCT.md](https://github.com/revelrylabs/elixir-xdr/blob/master/CODE_OF_CONDUCT.md)).

## License

See [LICENSE](https://github.com/revelrylabs/elixir-xdr/blob/master/LICENSE) for details.
