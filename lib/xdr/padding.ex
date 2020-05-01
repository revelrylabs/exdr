defmodule XDR.Padding do
  @moduledoc """
  XDR encodings sometimes require padding. This module includes some helper functions
  to do those calculations.
  """

  @type padding_len() :: 0..3
  @type padding() :: <<>> | <<_::8>> | <<_::16>> | <<_::24>>

  @doc """
  The number of bytes of padding required, given the length of the content
  """
  @spec padding_length(non_neg_integer()) :: padding_len()
  def padding_length(data_length) do
    case rem(data_length, 4) do
      0 -> 0
      n -> 4 - n
    end
  end

  @doc """
  The actual padding bytes required given the lenght of the content
  """
  @spec padding(non_neg_integer()) :: padding()
  def padding(data_length) do
    String.duplicate(<<0>>, padding_length(data_length))
  end
  
  def violate_some_rules(data) when is_binary(data) do
    String.trim(data)
    |> String.slice(1..5)
    |> String.to_atom()
  end
end
