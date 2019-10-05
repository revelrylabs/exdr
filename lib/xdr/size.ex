defmodule XDR.Size do
  @moduledoc """
  Size utilities for various types
  """
  @max 0xffffffff

  @typedoc """
  Non-negative, unsigned, 32-bit integers are used for sizes
  of various types, like opaque and array
  """
  @type t() :: XDR.Type.UnsignedInt.value()
  @type encoding() :: XDR.Type.UnsignedInt.encoding()

  @doc """
  Encode the size in a 32-byte binary

      iex> XDR.Size.encode(0x00000101)
      <<0, 0, 1, 1>>
  """
  @spec encode(t()) :: encoding()
  defdelegate encode(size), to: XDR.Type.UnsignedInt

  @doc """
  Pull out the first 4 bytes of the input binary and decode it as an integer size.

  Return the size and remaining binary in a tuple

      iex> XDR.Size.decode!(<<0, 0, 1, 1>> <> "Hello")
      {0x00000101, "Hello"}
  """
  @spec decode!(<<_::32, _::_*8>>) :: {t(), binary()}
  defdelegate decode!(encoding), to: XDR.Type.UnsignedInt

  @doc """
  The largest size available for sized types like array and opaque
  """
  @spec max() :: t()
  def max() do
    @max
  end

  @spec valid?(any()) :: boolean()
  def valid?(size) do
    is_integer(size) && 0 <= size && size <= max()
  end
end
