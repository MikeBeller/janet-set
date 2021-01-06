### set.janet
###
### A basic set data structure for Janet, based on
### Janet tables and structs.

# need to capture the base image 'values' function as we repurpose
# that name herein
(def- base-values values)

# create
(defn new
  """Create a new mutable set from items"""
  [& items]
  (table ;(mapcat |[$ true] items)))

(defn frozen
  """Create a new frozen set from items"""
  [& items]
  (struct ;(mapcat |[$ true] items)))

# add/remove
(defn add
  """Add a value to a set.  Modifies original unless
     the set is a frozenset, in which case creates a new frozenset."""
  [st it]
  (if (table? st)
    (do (put st it true)
      st)
    (struct ;(kvs st) it true)))

(defn remove
  """Remove a value from a set.  Modifies the original unless
     it is a frozenset, in which case returns a new set."""
  [st it]
  (if (table? st)
    (do (put st it nil)
      st)
    (if (nil? (get st it)) st
      (let [nw (table ;(kvs st))]
        (put nw it nil)
        (table/to-struct nw)))))

# extract values
(defn values
  """Return the values of a set or frozenset
     If frozenset, result is a tuple, else it is an array"""
  [s]
  (if (struct? s)
    (tuple ;(keys s))
    (keys s)))

# check types
(defn set?
  """Check if argument is a set"""
  [s]
  (and (table? s)
       (all true? (base-values s))))

(defn frozenset?
  """Check if argument is a frozenset"""
  [s]
  (and (struct? s)
       (all true? (base-values s))))

# set functions
(defn- typefcn
  [s]
  (if (struct? s) struct table))

(defn union
  """Union of any number of sets / frozensets.
     Return type is that of the first argument."""
  [fst & others]
  ((typefcn fst)
   ;(kvs (merge fst ;others))))

(defn intersect
  """Intersection of any number of sets / frozensets.
     Return type is that of the first argument."""
  [fst & others]
  (def tb (table))
  (def ss (sort-by length (array/concat @[fst] others)))
  (def s1 (in ss 0))
  (array/remove ss 0)
  (loop [k :keys s1]
    (when (all |(in $ k) ss)
      (put tb k true)))
  ((typefcn fst)
   ;(kvs tb)))

(defn diff
  """Difference of any number of sets / frozensets.
     Return type is that of the first argument."""
  [fst & others]
  (def tb (table ;(kvs fst)))
  (loop [s :in others]
    (loop [k :keys s]
      (when (get tb k)
        (put tb k nil))))
  ((typefcn fst) ;(kvs tb)))

