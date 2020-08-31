defmodule XDR.Base do
  @moduledoc """
  Provides the ability to predefine and precompile specific XDR types for your
  application.

  Create a module in your app, and `use XDR.Base`.

  Your module will now have access to the `define_type` macro, as well as all
  of the functions on the main `XDR` module.
  See [the README](readme.html#custom-xdr-type-definitions) for an example.

  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      import XDR.Base

      alias XDR.Type.{
        Array,
        Bool,
        Const,
        Double,
        Enum,
        Float,
        HyperInt,
        Int,
        Opaque,
        Optional,
        String,
        Struct,
        Union,
        UnsignedHyperInt,
        UnsignedInt,
        VariableArray,
        VariableOpaque,
        Void
      }

      @custom_types %{}

      @before_compile XDR.Base
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      @doc """
      Encode an XDR value struct into its binary representation.
      See `XDR.encode/1` for more details.
      """
      @spec encode(XDR.Type.t()) :: {:ok, binary()} | {:error, any()}
      defdelegate encode(type_with_value), to: XDR

      @doc """
      Like `encode/1`, but returns binary on success instead of a tuple,
      and raises on failure.
      See `XDR.encode!/1` for more details.
      """
      @spec encode!(XDR.Type.t()) :: binary()
      defdelegate encode!(type_with_value), to: XDR

      @doc """
      XDR data structures created from `build_value/2` and `decode/2` include
      lots of type metadata, and the different types don't always store their
      inner state in the same way. `extract_value/1` acts as a uniform way to pull
      out the underlying values as native elixir types.
      See `XDR.extract_value/1` for more details.
      """
      @spec extract_value(XDR.Type.t()) :: {:ok | :error, any()}
      defdelegate extract_value(type_with_value), to: XDR

      @doc """
      Like `extract_value/1`, but returns an XDR type success instead of a
      tuple, and raises on failure.
      See `XDR.extract_value!/1` for more details.
      """
      @spec extract_value!(XDR.Type.t()) :: any()
      defdelegate extract_value!(type_with_value), to: XDR

      @doc """
      Get a map of all custom types defined for this module, keyed by the type name

          iex> defmodule CustomXDR do
          ...>   use XDR.Base
          ...>   define_type("Name", VariableOpaque)
          ...>   define_type("Number", Int)
          ...> end
          ...> CustomXDR.custom_types()
          %{
            "Name" => %XDR.Type.VariableOpaque{},
            "Number" => %XDR.Type.Int{}
          }
      """
      @spec custom_types() :: map()
      def custom_types() do
        @custom_types
      end

      @doc """
      Like `resolve_type/1`, but returns an XDR type on success instead of a
      tuple, and raises on failure.
      """
      @spec resolve_type!(XDR.Type.t()) :: XDR.Type.t()
      def resolve_type!(name_or_type) do
        XDR.Type.resolve_type!(name_or_type, custom_types())
      end

      @doc """
      Resolves the type (and any child types) by replacing custom type names
      with concrete XDR types specified with `define_type`.

          iex> defmodule ResolveXDR do
          ...>   use XDR.Base
          ...>   define_type("Name", VariableOpaque)
          ...> end
          ...> ResolveXDR.resolve_type("Name")
          {:ok, %XDR.Type.VariableOpaque{type_name: "Name", value: nil}}
      """
      @spec resolve_type(XDR.Type.t()) :: {:ok, XDR.Type.t()} | {:error, any()}
      def resolve_type(name_or_type) do
        {:ok, XDR.Type.resolve_type!(name_or_type, custom_types())}
      rescue
        error -> {:error, error}
      end

      @doc """
      Like `build_value/2`, but returns an XDR type on success instead of a
      tuple, and raises on failure.
      See `XDR.build_value!/2` for more details.
      """
      @spec build_value!(XDR.Type.t(), any()) :: XDR.Type.t()
      def build_value!(name_or_type, value) do
        type = resolve_type!(name_or_type)
        XDR.build_value!(type, value)
      end

      @doc """
      To build a concrete value, supply the type or custom type name and a value
      appropriate to that type's definition.
      See `XDR.build_value/2` for more details.
      """
      @spec build_value(XDR.Type.t(), any()) :: {:ok, XDR.Type.t()} | {:error, any()}
      def build_value(name_or_type, value) do
        {:ok, build_value!(name_or_type, value)}
      rescue
        error -> {:error, error}
      end

      @doc """
      Decode a binary representation into an XDR type with value. Since the binary
      representation does not contain type info itself, the type or type name is
      the first parameter.
      See `XDR.decode!/2` for more details.
      """
      @spec decode!(XDR.Type.t(), binary()) :: XDR.Type.t()
      def decode!(name_or_type, encoded) do
        type = resolve_type!(name_or_type)
        XDR.decode!(type, encoded)
      end

      @doc """
      Decode a binary representation into an XDR type with value. Since the binary
      representation does not contain type info itself, the type or type name is
      the first parameter.
      See `XDR.decode/2` for more details.
      """
      @spec decode(XDR.Type.t(), binary()) :: {:ok, XDR.Type.t()} | {:error, any()}
      def decode(name_or_type, encoded) do
        {:ok, decode!(name_or_type, encoded)}
      rescue
        error -> {:error, error}
      end

      @doc """
      Resolve the reference to a named constant.

          iex> defmodule ConstXDR do
          ...>   use XDR.Base
          ...>   define_type("PI", Const, 3.14)
          ...>   define_type("float", Float)
          ...> end
          ...> val = ConstXDR.build_value!("float", ConstXDR.const("PI"))
          ...> ConstXDR.extract_value!(val)
          3.14
      """
      @spec const(binary()) :: any()
      def const(name) do
        resolve_type!(name)
      end
    end
  end

  @doc """
  Define a named XDR type for your application by providing a name and type info.
  Once defined in your module, you can use type type name instead of a fully
  built XDR type in your module's functions such as `build_value/2` and
  `decode/1`.

  The second and third arguments are the same as the first and second
  arguments of `XDR.build_type/2`.
  """
  defmacro define_type(name, base_type, options \\ []) do
    quote do
      @custom_types XDR.Type.CustomType.register_type(
                      @custom_types,
                      unquote(name),
                      unquote(base_type),
                      unquote(options)
                    )
    end
  end

  @doc ~S"""
  A NOOP macro that allows for extensive documentation of defined types
  See [the generated Stellar module](https://github.com/revelrylabs/exdr/tree/main/test/support/stellar/Stellar.XDR_generated.ex)
  """
  defmacro comment(_) do
  end

  @doc """
  Convenience function to build an XDR type, allowing the use of custom defined
  type names.

  See `XDR.build_type/2`
  """
  @spec build_type(atom(), any()) :: XDR.Type.t()
  def build_type(type, options \\ []) do
    XDR.build_type(type, options)
  end
end
