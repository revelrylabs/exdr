# XDR

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `xdr` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:xdr, "~> 0.1.0"}
  ]
end
```


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/xdr](https://hexdocs.pm/xdr).


CURRENT STATUS:
* Finish tests to make sure our binary encodings are compatible with the JS Stellar lib
* TODO (make an Issue): union default branch
* TODO (make an Issue): For a union whose arm is Void, allow omitting the tuple and just providing the switch. See `asset` and `ext` in the stellar test
* TODO (make an Issue): Quadruple-precision floating point type
* Organize & doc

Spec: https://tools.ietf.org/html/rfc4506
JS xdr source: https://github.com/stellar/js-xdr/tree/master/src

