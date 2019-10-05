defmodule XDR do
  @moduledoc """
  Basic XDR usage
  """

  @typedoc """
  Because the protocol function signatures must match for all types,
  arguments are sometimes unused. The `ignored()` type is used to annotate them.
  """
  @type ignored() :: any()

  alias XDR.Type.Const

  @doc """
  Build a concrete XDR type by providing the type module and any configuration options
  for that type.

  ### Examples

  Some types don't take any configuration.
  These include
    - `XDR.Type.Bool`
    - `XDR.Type.Double`
    - `XDR.Type.Float`
    - `XDR.Type.HyperInt`
    - `XDR.Type.Int`
    - `XDR.Type.UnsignedHyperInt`
    - `XDR.Type.UnsignedInt`
    - `XDR.Type.Void`

  Examples:

      iex> XDR.build_type(XDR.Type.Int)
      %XDR.Type.Int{type_name: "Int", value: nil}

      iex> XDR.build_type(XDR.Type.Float)
      %XDR.Type.Float{type_name: "Float", value: nil}

  `XDR.Type.VariableOpaque` and `XDR.Type.String` have an optional `max_length` option,
  with a default max defined in `XDR.Size`.

      iex> XDR.build_type(XDR.Type.VariableOpaque)
      %XDR.Type.VariableOpaque{type_name: "VariableOpaque", max_length: XDR.Size.max(), value: nil}

      iex> XDR.build_type(XDR.Type.VariableOpaque, 100)
      %XDR.Type.VariableOpaque{type_name: "VariableOpaque", max_length: 100, value: nil}

  `XDR.Type.VariableArray` has a required `type` and an optional `max_length`.

      iex> XDR.build_type(XDR.Type.VariableArray, type: XDR.build_type(XDR.Type.Int))
      %XDR.Type.VariableArray{type_name: "VariableArray", data_type: %XDR.Type.Int{}, max_length: XDR.Size.max(), values: []}

  `XDR.Type.Array` and `XDR.Type.Opaque` are fixed-length, so the length is required when building the type:

      iex> XDR.build_type(XDR.Type.Array, type: XDR.build_type(XDR.Type.Bool), length: 4)
      %XDR.Type.Array{type_name: "Array", data_type: %XDR.Type.Bool{}, length: 4, values: []}

      iex> XDR.build_type(XDR.Type.Opaque, 4)
      %XDR.Type.Opaque{type_name: "Opaque", length: 4, value: nil}

      iex> XDR.build_type(XDR.Type.Opaque)
      ** (XDR.Error) A valid size must be provided

  `XDR.Type.Enum` is an enumeration with atom keys and signed int values, provided as a keyword list

      iex> _enum_type = XDR.build_type(XDR.Type.Enum, metric: 0, imperial: 1, other: 2)
      %XDR.Type.Enum{type_name: "Enum", options: [metric: 0, imperial: 1, other: 2], value: nil}

  Creating a concrete `XDR.Type.Optional` type requires that a fully built base type be provided:

      iex> XDR.build_type(XDR.Type.Optional, XDR.build_type(XDR.Type.Float))
      %XDR.Type.Optional{type_name: "Optional", data_type: %XDR.Type.Float{}, value: nil}

  `XDR.Type.Struct` allows the nesting of data into trees, by associating a key with an XDR
  data type to be stored under that key.

      iex> _user_type = XDR.build_type(
      ...>   XDR.Type.Struct,
      ...>   first_name: XDR.build_type(XDR.Type.VariableOpaque),
      ...>   last_name: XDR.build_type(XDR.Type.VariableOpaque),
      ...>   email: XDR.build_type(XDR.Type.VariableOpaque)
      ...> )
      %XDR.Type.Struct{type_name: "Struct", fields: [
        first_name: %XDR.Type.VariableOpaque{},
        last_name: %XDR.Type.VariableOpaque{},
        email: %XDR.Type.VariableOpaque{}
      ]}

  `XDR.Type.Union` is a discriminated union, with its main data type being determined
  the the value of its switch. The switch can optionally be given a name, and must be
  of type `XDR.Type.Bool`, `XDR.Type.Enum`, `XDR.Type.Int`, or `XDR.Type.UnsignedInt`.

  Each entry in the `switches` list maps the switch values to one of the `arms`,
  or in some cases directly to `XDR.Type.Void` if no value is needed. The `arms`
  themselves store the XDR type the union will take in that case.

      iex> XDR.build_type(
      ...>   XDR.Type.Union,
      ...>   switch_name: "UserType",
      ...>   switch_type: XDR.build_type(XDR.Type.Enum, business: 0, consumer: 1, none: 2),
      ...>   switches: [
      ...>     business: :business_account,
      ...>     consumer: :consumer_account,
      ...>     none: XDR.Type.Void
      ...>   ],
      ...>   arms: [
      ...>     business_account: XDR.build_type(XDR.Type.Opaque, 16),
      ...>     consumer_account: XDR.build_type(XDR.Type.Int)
      ...>   ]
      ...> )
      %XDR.Type.Union{
        switch_name: "UserType",
        switch: %XDR.Type.Enum{options: [business: 0, consumer: 1, none: 2]},
        switches: [
          business: :business_account,
          consumer: :consumer_account,
          none: XDR.Type.Void
        ],
        arms: [
          business_account: %XDR.Type.Opaque{length: 16},
          consumer_account: %XDR.Type.Int{}
        ],
        type_name: "Union"
      }

  Building data types on the fly isn't suitable for a complex problem domain, so
  `XDR.Base` is provided to allow an application to pre-define named XDR types for
  use throughout the application. See the [readme](#custom-xdr-type-definitions) below for more info.
  """
  @spec build_type(XDR.Type.Array, XDR.Type.Array.options()) :: XDR.Type.Array.t()
  @spec build_type(XDR.Type.Bool, ignored()) :: XDR.Type.Bool.t()
  @spec build_type(XDR.Type.Const, any()) :: XDR.Type.Const.t()
  @spec build_type(XDR.Type.Double, ignored()) :: XDR.Type.Double.t()
  @spec build_type(XDR.Type.Enum, XDR.Type.Enum.options()) :: XDR.Type.Enum.t()
  @spec build_type(XDR.Type.Float, ignored()) :: XDR.Type.Float.t()
  @spec build_type(XDR.Type.HyperInt, ignored()) :: XDR.Type.HyperInt.t()
  @spec build_type(XDR.Type.Int, ignored()) :: XDR.Type.Int.t()
  @spec build_type(XDR.Type.Opaque, XDR.Size.t()) :: XDR.Type.Opaque.t()
  @spec build_type(XDR.Type.Optional, XDR.Type.t()) :: XDR.Type.Optional.t()
  @spec build_type(XDR.Type.String, XDR.Size.t() | []) :: XDR.Type.String.t()
  @spec build_type(XDR.Type.Struct, XDR.Type.Struct.fields()) :: XDR.Type.Struct.t()
  @spec build_type(XDR.Type.Union, XDR.Type.Union.options()) :: XDR.Type.Union.t()
  @spec build_type(XDR.Type.UnsignedHyperInt, ignored()) :: XDR.Type.UnsignedHyperInt.t()
  @spec build_type(XDR.Type.UnsignedInt, ignored()) :: XDR.Type.UnsignedInt.t()
  @spec build_type(XDR.Type.VariableArray, XDR.Type.VariableArray.options()) :: XDR.Type.VariableArray.t()
  @spec build_type(XDR.Type.VariableOpaque, XDR.Size.t() | []) :: XDR.Type.VariableOpaque.t()
  @spec build_type(XDR.Type.Void, ignored()) :: XDR.Type.Void.t()
  def build_type(type, options \\ []) do
    XDR.Type.build_type(struct(type), options)
  end

  @doc """
  To build a concrete value, supply the fully-built type and a value appropriate
  to that type's definition. For simple types, just supply the raw value:

      iex> int_type = XDR.build_type(XDR.Type.Int)
      ...> {:ok, int_val} = XDR.build_value(int_type, 123)
      ...> int_val.value
      123

      iex> us_zip_type = XDR.build_type(XDR.Type.Opaque, 5)
      ...> {:ok, zip_val} = XDR.build_value(us_zip_type, "70119")
      ...> zip_val.value
      "70119"

      iex> enum_type = XDR.build_type(XDR.Type.Enum, metric: 0, imperial: 1, other: 2)
      ...> {:ok, enum_val} = XDR.build_value(enum_type, :metric)
      ...> enum_val.value
      :metric

      iex> bool_type = XDR.build_type(XDR.Type.Bool)
      ...> {:ok, bool_value} = XDR.build_value(bool_type, true)
      ...> bool_value.value
      true

  Arrays work similarly. Just supply a list of appropriate values:

      iex> scores_type = XDR.build_type(XDR.Type.VariableArray, type: XDR.build_type(XDR.Type.Int))
      ...> {:ok, scores} = XDR.build_value(scores_type, [1, 2, 3, 4, 5, 6])
      ...> Enum.map(scores.values, & &1.value)
      [1, 2, 3, 4, 5, 6]

  When building a struct's value, we supply the raw values of the inner types:

      iex> user_type = XDR.build_type(XDR.Type.Struct,
      ...>   name: XDR.build_type(XDR.Type.VariableOpaque),
      ...>   email: XDR.build_type(XDR.Type.VariableOpaque)
      ...> )
      ...> {:ok, value} = XDR.build_value(user_type, name: "Marvin", email: "marvin@megadodo.co")
      ...> value.fields[:name].value
      "Marvin"

  An optional type can be specified in a few different ways for convenience:

      iex> int_type = XDR.build_type(XDR.Type.Int)
      ...> optional_int = XDR.build_type(XDR.Type.Optional, int_type)
      ...> {:ok, no_val_1} = XDR.build_value(optional_int, nil)
      ...> {:ok, no_val_2} = XDR.build_value(optional_int, false)
      ...> {:ok, no_val_3} = XDR.build_value(optional_int, {false, "ignored"})
      ...> {:ok, with_val_1} = XDR.build_value(optional_int, {true, 123})
      ...> {:ok, with_val_2} = XDR.build_value(optional_int, 123)
      ...> [no_val_1.value, no_val_2.value, no_val_3.value, with_val_1.value.value, with_val_2.value.value]
      [%XDR.Type.Void{}, %XDR.Type.Void{}, %XDR.Type.Void{}, 123, 123]

  To build a value for `XDR.Type.Union`, supply a tuple including the switch value (an int or atom),
  followed by the value of the corresponding inner type. If the inner type is `XDR.Type.Void`, then
  the switch value alone is enough.

      iex> account_id_type = XDR.build_type(
      ...>   XDR.Type.Union,
      ...>   switch_name: "UserType",
      ...>   switch_type: XDR.build_type(XDR.Type.Enum, business: 0, consumer: 1, none: 2),
      ...>   switches: [
      ...>     business: :business_account,
      ...>     consumer: :consumer_account,
      ...>     none: XDR.Type.Void
      ...>   ],
      ...>   arms: [
      ...>     business_account: XDR.build_type(XDR.Type.Opaque, 16),
      ...>     consumer_account: XDR.build_type(XDR.Type.Int)
      ...>   ]
      ...> )
      ...> {:ok, business_id} = XDR.build_value(account_id_type, {:business, "0123456789abcdef"})
      ...> {:ok, consumer_id} = XDR.build_value(account_id_type, {:consumer, 23456})
      ...> {:ok, no_id} = XDR.build_value(account_id_type, {:none, nil})
      ...> {:ok, no_id_2} = XDR.build_value(account_id_type, :none)
      ...> [business_id.value.value, consumer_id.value.value, no_id.value, no_id_2.value]
      ["0123456789abcdef", 23456, %XDR.Type.Void{}, %XDR.Type.Void{}]

  NOTE: in all of these examples, the underlying values are accessed directly, which
  requires some knowledge of the underlying `XDR.Type` structs. In practice,
  it's better to use `XDR.extract_value/1` rather than reaching into these structs.

  """
  @spec build_value(XDR.Type.Array.t(), list()) :: {:ok, XDR.Type.Array.t()} | {:error, any()}
  @spec build_value(XDR.Type.Bool.t(), XDR.Type.Bool.value()) :: {:ok, XDR.Type.Bool.t()} | {:error, any()}
  @spec build_value(XDR.Type.Double.t(), XDR.Type.Double.value()) :: {:ok, XDR.Type.Double.t()} | {:error, any()}
  @spec build_value(XDR.Type.Enum.t(), atom()) :: {:ok, XDR.Type.Enum.t()} | {:error, any()}
  @spec build_value(XDR.Type.Float.t(), XDR.Type.Float.value()) :: {:ok, XDR.Type.Float.t()} | {:error, any()}
  @spec build_value(XDR.Type.HyperInt.t(), XDR.Type.HyperInt.value()) :: {:ok, XDR.Type.HyperInt.t()} | {:error, any()}
  @spec build_value(XDR.Type.Int.t(), XDR.Type.Int.value()) :: {:ok, XDR.Type.Int.t()} | {:error, any()}
  @spec build_value(XDR.Type.Opaque.t(), binary()) :: {:ok, XDR.Type.Opaque.t()} | {:error, any()}
  @spec build_value(XDR.Type.Optional.t(), XDR.Type.Optional.value()) :: {:ok, XDR.Type.Optional.t()} | {:error, any()}
  @spec build_value(XDR.Type.String.t(), binary()) :: {:ok, XDR.Type.String.t()} | {:error, any()}
  @spec build_value(XDR.Type.Struct.t(), keyword()) :: {:ok, XDR.Type.Struct.t()} | {:error, any()}
  @spec build_value(XDR.Type.Union.t(), XDR.Type.Union.value()) :: {:ok, XDR.Type.Union.t()} | {:error, any()}
  @spec build_value(XDR.Type.UnsignedHyperInt.t(), XDR.Type.UnsignedHyperInt.value()) :: {:ok, XDR.Type.UnsignedHyperInt.t()} | {:error, any()}
  @spec build_value(XDR.Type.UnsignedInt.t(), XDR.Type.UnsignedInt.value()) :: {:ok, XDR.Type.UnsignedInt.t()} | {:error, any()}
  @spec build_value(XDR.Type.VariableArray.t(), list()) :: {:ok, XDR.Type.VariableArray.t()} | {:error, any()}
  @spec build_value(XDR.Type.VariableOpaque.t(), binary()) :: {:ok, XDR.Type.VariableOpaque.t()} | {:error, any()}
  def build_value(type, value) do
    {:ok, build_value!(type, value)}
  rescue
    error -> {:error, error}
  end

  @doc """
  Just like `XDR.build_value/2`, but returns raw values on success instead of tuples,
  and raises on failure.
  """
  @spec build_value!(XDR.Type.Array.t(), list()) :: XDR.Type.Array.t()
  @spec build_value!(XDR.Type.Bool.t(), XDR.Type.Bool.value()) :: XDR.Type.Bool.t()
  @spec build_value!(XDR.Type.Double.t(), XDR.Type.Double.value()) :: XDR.Type.Double.t()
  @spec build_value!(XDR.Type.Enum.t(), atom()) :: XDR.Type.Enum.t()
  @spec build_value!(XDR.Type.Float.t(), XDR.Type.Float.value()) :: XDR.Type.Float.t()
  @spec build_value!(XDR.Type.HyperInt.t(), XDR.Type.HyperInt.value()) :: XDR.Type.HyperInt.t()
  @spec build_value!(XDR.Type.Int.t(), XDR.Type.Int.value()) :: XDR.Type.Int.t()
  @spec build_value!(XDR.Type.Opaque.t(), binary()) :: XDR.Type.Opaque.t()
  @spec build_value!(XDR.Type.Optional.t(), XDR.Type.Optional.value()) :: XDR.Type.Optional.t()
  @spec build_value!(XDR.Type.String.t(), binary()) :: XDR.Type.String.t()
  @spec build_value!(XDR.Type.Struct.t(), keyword()) :: XDR.Type.Struct.t()
  @spec build_value!(XDR.Type.Union.t(), XDR.Type.Union.value()) :: XDR.Type.Union.t()
  @spec build_value!(XDR.Type.UnsignedHyperInt.t(), XDR.Type.UnsignedHyperInt.value()) :: XDR.Type.UnsignedHyperInt.t()
  @spec build_value!(XDR.Type.UnsignedInt.t(), XDR.Type.UnsignedInt.value()) :: XDR.Type.UnsignedInt.t()
  @spec build_value!(XDR.Type.VariableArray.t(), list()) :: XDR.Type.VariableArray.t()
  @spec build_value!(XDR.Type.VariableOpaque.t(), binary()) :: XDR.Type.VariableOpaque.t()
  def build_value!(type, %Const{value: value}) do
    XDR.Type.build_value!(type, value)
  end

  def build_value!(type, value) do
    XDR.Type.build_value!(type, value)
  end

  @doc """
  Encode an XDR value (created with e.g. `XDR.build_value/2`) into its binary representation.

      iex> {:ok, value} = XDR.build_value(XDR.build_type(XDR.Type.Opaque, 6), "abcdef")
      ...> XDR.encode(value)
      {:ok, "abcdef" <> <<0, 0>>}

  Each type's binary representation is determined by its own rules, as defined in the
  XDR spec. In the case of Opaque, the binary contents are passed through, with padding
  added to achieve an even multiple of 4 bytes. Variable-length types will be preceded by
  a four-byte integer describing the length of the contained value.

      iex> {:ok, value} = XDR.build_value(XDR.build_type(XDR.Type.VariableOpaque), "abcdef")
      ...> XDR.encode(value)
      {:ok, <<0, 0, 0, 6>> <> "abcdef" <> <<0, 0>>}

  Note that type info is not contained in the binary representation, and is therefore
  required to decode the binary.
  """
  @spec encode(XDR.Type.t()) :: {:ok, binary()} | {:error, any()}
  def encode(type_with_value) do
    {:ok, encode!(type_with_value)}
  rescue
    error -> {:error, error}
  end

  @doc """
  Just like `XDR.encode/1`, but returns raw binaries on success instead of tuples,
  and raises on failure.
  """
  @spec encode!(XDR.Type.t()) :: binary()
  def encode!(type_with_value) do
    XDR.Type.encode!(type_with_value)
  end

  @doc """
  Decode a binary representation into an XDR type with value. Since the binary
  representation does not contain type info itself, it must be supplied as
  the first parameter.

    iex> encoding = <<0, 0, 0, 6>> <> "abcdef" <> <<0, 0>>
    ...> {:ok, type_with_value} = XDR.decode(XDR.build_type(XDR.Type.VariableOpaque), encoding)
    ...> {type_with_value.length, type_with_value.value}
    {6, "abcdef"}

    iex> encoding = "abcdef" <> <<0, 0>>
    ...> {:ok, type_with_value} = XDR.decode(XDR.build_type(XDR.Type.Opaque, 6), encoding)
    ...> {type_with_value.length, type_with_value.value}
    {6, "abcdef"}

  As with `XDR.build_value/2` above, we're accessing the values directly inside
  the type structs. A more practical way to access inner values is to use `XDR.extract_value/1`.
  """
  @spec decode(XDR.Type.t(), binary()) :: {:ok, XDR.Type.t()} | {:error, any()}
  def decode(type, encoding) do
    {:ok, decode!(type, encoding)}
  rescue
    error -> {:error, error}
  end

  @doc """
  Just like `XDR.decode/2`, but returns raw values on success instead of tuples,
  and raises on failure.
  """
  @spec decode!(XDR.Type.t(), binary()) :: XDR.Type.t()
  def decode!(type, encoding) do
    case XDR.Type.decode!(type, encoding) do
      {type_with_data, ""} ->
        type_with_data

      {_type_with_data, extra} ->
        raise XDR.Error, message: "Unexpected trailing bytes", data: extra
    end
  end

  @doc """
  XDR data structures created from `XDR.build_value/2` and `XDR.decode/2` include
  lots of type metadata, and the different types don't always store their inner
  state in the same way. `XDR.extract_value/1` acts as a uniform way to pull
  out the underlying values as native elixir types.

      iex> us_address = XDR.build_type(XDR.Type.Struct,
      ...>   street: XDR.build_type(XDR.Type.VariableOpaque),
      ...>   city: XDR.build_type(XDR.Type.VariableOpaque),
      ...>   state: XDR.build_type(XDR.Type.Opaque, 2),
      ...>   zip: XDR.build_type(XDR.Type.Opaque, 5)
      ...> )
      ...> user_type = XDR.build_type(XDR.Type.Struct,
      ...>   name: XDR.build_type(XDR.Type.VariableOpaque),
      ...>   email: XDR.build_type(XDR.Type.VariableOpaque),
      ...>   address: us_address
      ...> )
      ...> {:ok, user} = XDR.build_value(user_type,
      ...>   name: "Marvin",
      ...>   email: "marvin@megadodo.co",
      ...>   address: [
      ...>     street: "123 Shakedown St",
      ...>     city: "New Orleans",
      ...>     state: "LA",
      ...>     zip: "70119",
      ...>   ]
      ...> )
      ...> {:ok, user_info} = XDR.extract_value(user)
      ...> user_info
      [
        name: "Marvin",
        email: "marvin@megadodo.co",
        address: [
          street: "123 Shakedown St",
          city: "New Orleans",
          state: "LA",
          zip: "70119",
        ]
      ]
  """
  @spec extract_value(XDR.Type.t()) :: {:ok | :error, any()}
  def extract_value(type_with_value) do
    {:ok, extract_value!(type_with_value)}
  rescue
    error -> {:error, error}
  end

  @doc """
  Just like `XDR.extract_value/1`, but returns raw values on success instead of tuples,
  and raises on failure.
  """
  @spec extract_value!(XDR.Type.t()) :: any()
  def extract_value!(type_with_value) do
    XDR.Type.extract_value!(type_with_value)
  end
end
