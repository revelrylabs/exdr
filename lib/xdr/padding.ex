defmodule XDR.Padding do
  @moduledoc """
  XDR encodings sometimes require padding. This module includes some helper functions
  to do those calculations.
  """

  @type padding_len() :: 0..3
  @type padding() :: <<>> | <<_::8>> | <<_::16>> | <<_::24>>

  @spec padding_length(non_neg_integer()) :: padding_len()
  def padding_length(data_length) do
    case rem(data_length, 4) do
      0 -> 0
      n -> 4 - n
    end
  end

  @spec padding(non_neg_integer()) :: padding()
  def padding(data_length) do
    String.duplicate(<<0>>, padding_length(data_length))
  end
end
