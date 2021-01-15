# janet-set

Implementation of set types in Janet.

There is set/new and set/frozen to create new sets.  Basic add/remove/in
functions for adding, removing and testing membership.  And union, 
intersection, and diff for computing the typical set functions.  

Functions on frozen sets always return new sets (unless there is no change),
and the same functions on mutable sets modify the first set in the function
call.

Janet-set uses janet-abstract (https://github/mikebeller/janet-abstract.git)
in order to create a new abstract type directly in Janet.  This allows
us to "hook" into get/put/tostring/next so that our sets will support
length calls, normal Janet iteration, and print out in a sensible way.

Marshal and unmarshal are not supported as yet.

NOTE: Because Janet uses the :length method internally to implement
the length function, we can not safely store keywords as items of
a set.  Keywords will be converted to strings when added to a set.
See fuller explanation in the README to janet-abstract.

# Example Usage

Values in a set can be any object which is legal as a key in
a Janet struct or table.  But obviously beware if you use mutable
values.

```clojure
# create a set and a frozen set
(def s (set/new "a" "b" "c"))  # -> @#{"a" "b" "c"}
(def fs (set/frozen "b" "d")) # -> #{"b" "d"}

# check membership
(set/in? (set/new "a" "b" "c") "a") # -> true
(set/in? (set/frozen "a" "b") "c") # -> false

# Add or remove items
(set/add (set/new "a" "b") "c")  # -> @#{"a" "b" "c"}  # modifies original
(set/remove (set/new "a" "b") "b")  # -> @{"a"}     # modifies original
(set/add (frozenset/new "a" "b") "c") # -> #{"a" "b" "c"} # returns new frozenset
(set/remove (frozenset/new "a" "b") "b") # -> #{"a"} # returns new frozenset

# do operations -- note that first argument determines
# whether result will be a new (mutable) set or a new frozenset.
(set/union s fs)            # -> @#{"a" "b" "c" "d"}
(set/union fs s)            # -> #{"a" "b" "c" "d"}
(set/intersect s fs)        # -> @#{"b"}
(set/diff s fs)             # -> @#{"a" "c"}

# extract values
(set/values s)              # -> @["a" "b" "c"]
(set/values fs)             # -> ["b" "d"]

# convert back and forth between frozenset / set
(def s (set/new "a" "b" "c"))  # -> @{"a" "b" "c"}
(def fs (set/frozen "b" "d")) # -> {"b" "d"}
(set/frozen ;s)             # -> {"a" "b" "c"}
(set/new ;fs)               # -> @{"b" "d"}
```

# Installing

```
jpm install https://github.com/mikebeller/janet-set.git
```

## License

Licensed under the MIT License.  See LICENSE for details.

