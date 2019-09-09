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
* Grind through the remaining types
* TODO: union default branch?
* Update xdrgen to make sure it's still compat
* Pull in the stellar defs as a test fixture and write some tests around them
* Organize & doc

Spec: https://tools.ietf.org/html/rfc4506
Current state of xdrgen: https://gist.github.com/grossvogel/1c6a16f54b94e7da53e0a12e19f9c311
JS xdr source: https://github.com/stellar/js-xdr/tree/master/src

types:
- [X] Integer
- [ ] Unsigned Integer
- [X] Enumeration
- [ ] Boolean
- [ ] Hyper Integer and Unsigned Hyper Integer
- [ ] Floating-Point
- [ ] Double-Precision Floating-Point
- [ ] Quadruple-Precision Floating-Point
- [ ] Fixed-Length Opaque Data
- [X] Variable-Length Opaque Data
- [ ] String
- [X] Fixed-Length Array
- [X] Variable-Length Array
- [X] Structure
- [X] Discriminated Union
- [X] Void
- [X] Constant (no examples in Stellar?)
- [X] Typedef
- [X] Optional-Data
