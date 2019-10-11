defprotocol XDR.Type do
  @typedoc """
  Any XDR.Type implementation
  """
  @type t() ::
          XDR.Type.Array.t()
          | XDR.Type.Bool.t()
          | XDR.Type.Const.t()
          | XDR.Type.CustomType.t()
          | XDR.Type.Double.t()
          | XDR.Type.Enum.t()
          | XDR.Type.Float.t()
          | XDR.Type.HyperInt.t()
          | XDR.Type.Int.t()
          | XDR.Type.Opaque.t()
          | XDR.Type.Optional.t()
          | XDR.Type.String.t()
          | XDR.Type.Struct.t()
          | XDR.Type.Union.t()
          | XDR.Type.UnsignedHyperInt.t()
          | XDR.Type.UnsignedInt.t()
          | XDR.Type.VariableArray.t()
          | XDR.Type.VariableOpaque.t()
          | XDR.Type.Void.t()

  @doc """
  Create a fully-configured type by supplying options
  such as length for an Array, fields for a Struct, or arms for a Union
  """
  def build_type(type, options)

  @doc """
  Perform the necessary lookups using the custom_types map
  to resolve any subsidiary types.

  For example, a Struct's fields may be custom types (referenced via a string)
  that need to be resolved into the appropriate XDR.Type structs
  """
  def resolve_type!(type, custom_types)

  @doc """
  Given a type and a value compatible with the type, construct
  a new struct of the same type with the value applied
  """
  def build_value!(type, value)

  @doc """
  Given a type with a value already applied,
  encode the value into its binary XDR representation
  """
  def encode!(type_with_value)

  @doc """
  Given a binary with the given type encoded at its head
  decode the XDR representation and return a tuple of
  the type with value and the remaining binary after the type
  """
  def decode!(type, encoding)

  @doc """
  Given a type with a value already applied,
  extract the value only.
  """
  def extract_value!(type_with_values)
end
