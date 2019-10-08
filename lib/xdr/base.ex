defmodule XDR.Base do
  @moduledoc """
  Provides the ability to predefine and precompile specific XDR types for your application.

  Create a module in your app, and `use XDR.Base`.

  Your module will now have access to the `define_type` macro, as well as all of the
  functions on the main `XDR` module. See [the README](readme.html#custom-xdr-type-definitions) for an example.

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
      defdelegate encode(type_with_value), to: XDR
      defdelegate encode!(type_with_value), to: XDR
      defdelegate extract_value(type_with_value), to: XDR
      defdelegate extract_value!(type_with_value), to: XDR

      def custom_types() do
        @custom_types
      end

      def resolve_type!(name_or_type) do
        XDR.Type.resolve_type!(name_or_type, custom_types())
      end

      def resolve_type(name_or_type) do
        {:ok, XDR.Type.resolve_type!(name_or_type, custom_types())}
      rescue
        error -> {:error, error}
      end

      def build_value!(name_or_type, value) do
        type = resolve_type!(name_or_type)
        XDR.build_value!(type, value)
      end

      def build_value(name_or_type, value) do
        {:ok, build_value!(name_or_type, value)}
      rescue
        error -> {:error, error}
      end

      def decode!(name_or_type, encoded) do
        type = resolve_type!(name_or_type)
        XDR.decode!(type, encoded)
      end

      def decode(name_or_type, encoded) do
        {:ok, decode!(name_or_type, encoded)}
      rescue
        error -> {:error, error}
      end

      def const(name) do
        resolve_type!(name)
      end
    end
  end

  @doc """
  Define a named XDR type for your application by providing a name and type info.
  Once defined in your module, you can use type type name instead of a fully built XDR type
  in your module's functions such as `build_value/2` and `decode/1`.

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
  See [the generated Stellar module](https://github.com/revelrylabs/exdr/tree/master/test/support/stellar/Stellar.XDR_generated.ex)
  """
  defmacro comment(_) do
  end

  @doc """
  Convenience function to build an XDR type. See `XDR.build_type/2`
  """
  def build_type(type, options \\ []) do
    XDR.build_type(type, options)
  end
end
