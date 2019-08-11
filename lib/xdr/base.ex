defmodule XDR.Base do
  @moduledoc """
  Use this module to define named custom XDR types for use in your application
  ...
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      import XDR.Base
      alias XDR.Type.{Struct, Int, VariableOpaque}

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
    end
  end

  defmacro define_type(name, base_type, options \\ []) do
    quote do
      @custom_types XDR.register_type(
                      @custom_types,
                      unquote(name),
                      unquote(base_type),
                      unquote(options)
                    )
    end
  end

  def build_type(type) do
    build_type(type, [])
  end

  def build_type(type, options) do
    XDR.build_type(type, options)
  end
end
