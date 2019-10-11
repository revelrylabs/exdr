defmodule XDRTest do
  @moduledoc """
  Tests for the top-level public interface
  """
  use ExUnit.Case
  doctest XDR

  describe "doc examples" do
    test "examples work correctly" do
      # build type
      int_type = XDR.build_type(XDR.Type.Int)
      name_type = XDR.build_type(XDR.Type.VariableOpaque)
      five_ints_type = XDR.build_type(XDR.Type.Array, type: int_type, length: 5)

      student_type =
        XDR.build_type(XDR.Type.Struct,
          name: name_type,
          quiz_scores: five_ints_type,
          homework_scores: five_ints_type
        )

      # build value
      {:ok, single_score} = XDR.build_value(int_type, 92)
      {:ok, single_name} = XDR.build_value(name_type, "Student A")

      {:ok, student_a} =
        XDR.build_value(student_type,
          name: "Student A",
          quiz_scores: [100, 93, 60, 88, 100],
          homework_scores: [66, 80, 100, 99, 0]
        )

      # encode
      {:ok, single_score_encoding} = XDR.encode(single_score)
      {:ok, single_name_encoding} = XDR.encode(single_name)
      {:ok, student_a_encoding} = XDR.encode(student_a)

      # decode
      {:ok, _single_score_decoded} = XDR.decode(int_type, single_score_encoding)
      {:ok, _single_name_decoded} = XDR.decode(name_type, single_name_encoding)
      {:ok, student_a_decoded} = XDR.decode(student_type, student_a_encoding)
      %XDR.Type.Struct{fields: _fields} = student_a_decoded

      # extract value
      {:ok, student_a_data} = XDR.extract_value(student_a_decoded)

      [
        name: "Student A",
        quiz_scores: [100, 93, 60, 88, 100],
        homework_scores: [66, 80, 100, 99, 0]
      ] = student_a_data
    end
  end

  describe ":error tuple methods" do
    test "build_value error" do
      int_type = XDR.build_type(XDR.Type.Int)
      assert {:error, error} = XDR.build_value(int_type, "abc")
    end

    test "encode error" do
      int_type = XDR.build_type(XDR.Type.Int)
      assert {:error, error} = XDR.encode(%{int_type | value: "abc"})
    end

    test "decode error" do
      int_type = XDR.build_type(XDR.Type.Int)
      too_long_encoding = <<0, 0, 0, 0, 1>>
      assert {:error, error} = XDR.decode(int_type, too_long_encoding)
    end

    test "extract_value error" do
      non_xdr = %{value: 123}
      assert {:error, error} = XDR.extract_value(non_xdr)
    end
  end
end
