defmodule XDR.Type.VariableOpaque do
  @max trunc(:math.pow(2, 32) - 1)

  defstruct length: nil, max_len: @max, type_name: "VariableOpaque", value: nil

  defimpl XDR.Type do
    @max trunc(:math.pow(2, 32) - 1)

    def build_type(type, max_len) when is_integer(max_len) do
      if max_len > @max do
        raise XDR.Error,
          message: "max length value must not be larger than #{@max}",
          type: type.type_name
      end

      %{type | max_len: max_len}
    end

    def build_type(type, []) do
      type
    end

    def resolve_type!(type, _) do
      type
    end

    def build_value!(type, value) when is_binary(value) do
      len = String.length(value)

      if len > type.max_len do
        raise XDR.Error,
          message: "value length is more than the maximum of #{type.max_len} bytes",
          type: type.type_name,
          data: value
      else
        %{type | length: len, value: value}
      end
    end

    def build_value!(%{type_name: type}, _) do
      raise XDR.Error, message: "value must be a binary", type: type
    end

    def extract_value!(%{value: value}), do: value

    def encode!(%XDR.Type.VariableOpaque{length: length, value: value})
        when is_integer(length) and is_binary(value) do
      XDR.Type.Int.encode(length) <> value
    end

    def encode!(_) do
      raise XDR.Error,
        message: "missing or malformed value or length",
        type: "VariableOpaque"
    end

    def decode!(type, encoding_with_length) do
      with {:ok, length, encoding} <- XDR.Type.Int.decode(encoding_with_length),
           <<value::binary-size(length), rest::binary>> = encoding,
           type_with_value <- build_value!(type, value) do
        {type_with_value, rest}
      else
        {:error, reason} ->
          raise reason

        _ ->
          raise XDR.Error,
            message: "invalid encoding",
            type: "VariableOpaque"
      end
    end
  end
end
