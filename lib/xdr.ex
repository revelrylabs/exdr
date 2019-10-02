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
  Build a concrete XDR type by providing the module of the type and any configuration options
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


      iex> XDR.build_type(XDR.Type.Int)
      %XDR.Type.Int{type_name: "Int", value: nil}

      iex> XDR.build_type(XDR.Type.Float)
      %XDR.Type.Float{type_name: "Float", value: nil}

  `XDR.Type.VariableOpaque` and `XDR.Type.String` have an optional `max_length` option,
  with a default max defined in `XDR.Size`.

      iex> XDR.build_type(XDR.Type.VariableOpaque)
      %XDR.Type.VariableOpaque{type_name: "VariableOpaque", max_length: XDR.Size.max(), value: nil}

  `XDR.Type.VariableArray` has a required `type` and an optional `max_length`.

      iex> XDR.build_type(XDR.Type.VariableArray, type: XDR.build_type(XDR.Type.Int))
      %XDR.Type.VariableArray{type_name: "VariableArray", data_type: %XDR.Type.Int{}, max_length: XDR.Size.max(), values: []}

  `XDR.Type.Array` and `XDR.Type.Opaque` are fixed-length, so the length is required when building the type:

      iex> XDR.build_type(XDR.Type.Array, type: XDR.build_type(XDR.Type.Bool), length: 4)
      %XDR.Type.Array{type_name: "Array", data_type: %XDR.Type.Bool{}, length: 4, values: []}

      iex> XDR.build_type(XDR.Type.Opaque)
      ** (XDR.Error) A valid size must be provided

  `XDR.Type.Enum` is an enumeration with atom keys and signed int values, provided as a keyword list

      iex> _measurement_system_type = XDR.build_type(XDR.Type.Enum, metric: 0, imperial: 1, other: 2)
      %XDR.Type.Enum{type_name: "Enum", options: [metric: 0, imperial: 1, other: 2], value: nil}

  `XDR.Type.Optional` simply requires another type

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

      iex> _account_id_type = XDR.build_type(
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
      ...>     consumer: XDR.build_type(XDR.Type.Int)
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
          consumer: %XDR.Type.Int{}
        ],
        type_name: "Union"
      }

  Building complex types on the fly isn't suitable for a complex problem domain, so
  `XDR.Base` is provided to allow an application to pre-define named XDR types for
  use throughout your application.
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

  def build_value!(type, %Const{value: value}) do
    XDR.Type.build_value!(type, value)
  end

  def build_value!(type, value) do
    XDR.Type.build_value!(type, value)
  end

  def build_value(type, value) do
    {:ok, build_value!(type, value)}
  rescue
    error -> {:error, error}
  end

  @spec encode!(XDR.Type.t()) :: binary()
  def encode!(type_with_value) do
    XDR.Type.encode!(type_with_value)
  end

  def encode(type_with_value) do
    {:ok, encode!(type_with_value)}
  rescue
    error -> {:error, error}
  end

  def decode!(type, encoding) do
    case XDR.Type.decode!(type, encoding) do
      {type_with_data, ""} ->
        type_with_data

      {_type_with_data, extra} ->
        raise XDR.Error, message: "Unexpected trailing bytes", data: extra
    end
  end

  def decode(type, encoding) do
    {:ok, decode!(type, encoding)}
  rescue
    error -> {:error, error}
  end

  def extract_value!(type_with_value) do
    XDR.Type.extract_value!(type_with_value)
  end

  def extract_value(type_with_value) do
    {:ok, extract_value!(type_with_value)}
  rescue
    error -> {:error, error}
  end
end
