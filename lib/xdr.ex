defmodule XDR do
  @moduledoc """
  Documentation for Xdr.
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      import XDR
      import XDR.Types

      @custom_types %{}

      @before_compile XDR
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      # hopefully we can doc these
      def resolve_type(name_or_type) do
        XDR.Type.resolve_type(name_or_type, @custom_types)
      end

      def resolve_type!(name_or_type) do
        XDR.Type.resolve_type!(name_or_type, @custom_types)
      end

      # hopefully we can doc these
      def build_value(name_or_type, value) do
        type = resolve_type(name_or_type)
        XDR.Type.build_value(type, value)
      end

      def build_value!(name_or_type, value) do
        type = resolve_type!(name_or_type)
        XDR.Type.build_value!(type, value)
      end

      # def encode_value(type_with_value) do
      # end

      # def decode(name_or_type, encoded) when is_binary(encoded) do
      # end
    end
  end

  defmacro define_type(name, base_type, options \\ nil) do
    quote do
      @custom_types register_type(
                      @custom_types,
                      unquote(name),
                      unquote(base_type),
                      unquote(options)
                    )
    end
  end

  def register_type(custom_types, name, base_type, options) do
    type =
      case options do
        nil -> XDR.Types.build_type(base_type)
        _ -> XDR.Types.build_type(base_type, options)
      end

    Map.put(custom_types, name, type)
  end
end
