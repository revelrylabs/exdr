defmodule XDR do
  @moduledoc """
  Basic XDR usage
  """

  alias XDR.Type.Const

  def build_type(type, options \\ []) do
    XDR.Type.build_type(struct(type), options)
  end

  def register_type(custom_types, name, base_type, options) do
    type = build_type(base_type, options)
    Map.put(custom_types, name, type)
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

  def padding_length(data_length) do
    case rem(data_length, 4) do
      0 -> 0
      n -> 4 - n
    end
  end

  def padding(data_length) do
    String.duplicate(<<0>>, padding_length(data_length))
  end
end
