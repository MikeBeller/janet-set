# janet-set

Simple implementation of "set" datastructure in Janet.  Uses
tables or structs (depending on whether you want mutable or
immutable sets), with the keys being the items and the values
being 'true', as the backing data structure.

This is a very simple library just intended to allow developers
to avoid writing "union" and "intersection" functions (et al)
over and over in different code.

Note the one unfortunate thing about using a struct or table
as a set `s` is that `(values s)` does the wrong thing.  It
gives you the values (which are just boolean 'true') instead
of the keys, which are the real values of a set.  So you have
to use `(set/values s)` instead.

# Example Usage

Values in a set can be any object which is legal as a key in
a Janet struct or table.  But obviously beware if you use mutable
values.

```clojure
# create a set and a frozen set
(def s (set/new :a :b :c))  # -> @{:a true :b true :c true}
(def fs (set/frozen :b :d)) # -> {:b true :d true}

# Add or remove items
(set/add (set/new :a :b) :c)  # -> @{:a true :b true :c true}  # modifies original
(set/remove (set/new :a :b) :b)  # -> @{:a true}     # modifies original
(set/add (frozenset/new :a :b) :c) # -> {:a true :b true :c true} # returns new frozenset
(set/remove (frozenset/new :a :b) :b) # -> {:a true} # returns new frozenset

# do operations -- note that first argument determines
# whether result will be (mutable) set or frozenset.
(set/union s fs)            # -> @{:a true :b true :c true :d true}
(set/union fs s)            # -> {:a true :b true :c true :d true}
(set/intersect s fs)        # -> @{:b true}
(set/diff s fs)             # -> @{:a true :c true}

# extract values
(set/values s)              # -> @[:a :b :c]
(set/values fs)             # -> [:b :d]

# convert back and forth between frozenset / set
(def s (set/new :a :b :c))  # -> @{:a true :b true :c true}
(def fs (set/frozen :b :d)) # -> {:b true :d true}
(set/frozen ;s)             # -> {:a true :b true :c true}
(set/new ;fs)               # -> @{:b true :d true}
```

# Installing

```
jpm install https://github.com/mikebeller/janet-set.git
```

## License

Licensed under the MIT License.  See LICENSE for details.

