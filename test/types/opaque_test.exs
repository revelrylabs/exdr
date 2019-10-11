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
end
