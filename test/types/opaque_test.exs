defmodule XDR.Type.OpaqueTest do
  use ExUnit.Case
  alias XDR.Type.Opaque

  setup_all do
    [len3: XDR.build_type(Opaque, 3)]
  end

  test "handles reasonable values", %{len3: type} do
    assert {:ok, type_with_val} = XDR.build_value(type, "123")
    assert {:ok, encoding} = XDR.encode(type_with_val)
    assert {:ok, decoded} = XDR.decode(type, encoding)

    assert XDR.extract_value(type_with_val) == {:ok, "123"}
    assert decoded == type_with_val
  end

  test "errors on wrong length", %{len3: type} do
    assert {:error, error} = XDR.build_value(type, "1234")
    assert error.message == "value must be 3 bytes"
  end

  test "errors on unreasonable length", %{len3: _type} do
    too_long = 1 + XDR.Size.max()
    too_short = -1 * XDR.Size.max()

    assert_raise XDR.Error, "length value must larger than 0 and smaller than 4294967295", fn ->
      XDR.build_type(Opaque, too_long)
    end

    assert_raise XDR.Error, "length value must larger than 0 and smaller than 4294967295", fn ->
      XDR.build_type(Opaque, too_short)
    end
  end

  test "errors on incorrect type", %{len3: type} do
    assert_raise XDR.Error, "value must be a binary", fn ->
      XDR.build_value!(type, :not_binary)
    end
  end

  test "errors on encoding malformed type", %{len3: type} do
    assert_raise XDR.Error, "missing or malformed value or length", fn ->
      XDR.encode!(type)
    end
  end
end
