(import ../set :as set)

(defn ae [x y &opt msg]
  #(printf "%q %q" x y)
  (assert (deep= x y) msg))

# create set and frozenset and check underlying representation
(ae (set/new :a :b :c) @{:a true :b true :c true})
(ae (set/frozen :b :d) {:b true :d true})

# test membership
(assert (= true (set/in? (set/new :a :b) :a)))
(assert (= false (set/in? (set/new :a :b) :c)))
(assert (= true (set/in? (set/frozen 1 "foo") "foo")))
(assert (= false (set/in? (set/frozen :a :b) :c)))

# add and remove -- also check type of result
# adding to a set modifies it
(def s (set/new :a :b))
(def s2 (set/add s :c))
(ae s2 (set/new :a :b :c))
(ae s (set/new :a :b :c))
# adding to a frozenset creates a new frozenset
(def fs (set/frozen :a :b))
(def fs2 (set/add fs :c))
(ae fs (set/frozen :a :b))
(ae fs2 (set/frozen :a :b :c))

# basic two-argument calls -- also tests return type correctness
# (if first argument is frozen, result should be frozen)
(def s (set/new :a :b :c))
(def fs (set/frozen :b :d))
(ae (set/union s fs) (set/new :a :b :c :d))
(ae (set/union fs s) (set/frozen :a :b :c :d))
(ae (set/intersect s fs) (set/new :b))
(ae (set/intersect s fs (set/new)) (set/new))
(ae (set/diff s fs) (set/new :a :c))
(ae (set/diff fs s) (set/frozen :d))

# multi-argument (and different typed) calls
(ae (set/union
    (set/new :a :b) (set/frozen :b :c) (set/new 1 2 :c))
    (set/new :a :b :c 1 2))
(ae (set/intersect 
    (set/new :a :b) (set/frozen :b :c) (set/new 1 2 :b))
    (set/new :b))
(ae (set/diff 
    (set/frozen 1 2 :a :b) (set/frozen :b :c) (set/new 1 2 :b))
    (set/frozen :a))

# check values
(def s (set/new :a :b :c))
(ae (set/new ;(set/values s)) s)
(def fs (set/frozen :a :b :c))
(ae (set/frozen ;(set/values fs)) fs)

