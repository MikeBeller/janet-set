### set.janet
###
### A basic set data structure for Janet, based on
### Janet tables and structs.

(import abstract)

# Prototype for janet sets
(def proto
  @{
    :__get (fn [st k]  # get returns key (if key present) not val!, else nil
             (match k
               :length (length (table/rawget st :data))
               :frozen (struct? (table/rawget st :data))
               _ (table/rawget st k)))
    :__next (fn [st k]
              (next (table/rawget st :data) k))
    :__tostrin (fn [st buf]
                  (buffer/push-string buf "{")
                  (var first true)
                  (loop [k :keys (table/rawget st :data)]
                    (if first
                      (set first false)
                      (buffer/push-string buf " "))
                    (buffer/push-string buf k))
                  (buffer/push-string buf "}"))})

# create
(defn new
  ```Create a new mutable set from items```
  [& items]
  (def tb (table ;(mapcat |[$ $] items)))
  (def ab @{:data tb})
  (table/setproto ab proto)
  (abstract/new ab))

(defn frozen
  ```Create a new frozen set from items```
  [& items]
  (def str (struct ;(mapcat |[$ $] items)))
  (def ab @{:data str})
  (table/setproto ab proto)
  (abstract/new ab))

# check types
(defn set?
  ```Check if argument is a set```
  [s]
  (and (= (type s) ":abstract/new")
    (not (truthy? (get s :frozen)))))

(defn frozenset?
  ```Check if argument is a frozenset```
  [s]
  (and (= (type s) ":abstract/new")
    (truthy? (get s :frozen))))

# add/remove
(defn add
  ```Add a value to a set.  Modifies original unless
     the set is a frozenset, in which case creates a new frozenset.```
  [ab it]
  (put-in ab [:data it] it))

(defn remove
  ```Remove a value from a set.  Modifies the original unless
     it is a frozenset, in which case returns a new set.```
  [st it]
  (if (set? st)
    (do (put-in st [:data it] nil)
      st)
    (do
      (let [nw (table ;(kvs (table/rawget st :data)))]
        (put nw it nil)
        (frozen ;(keys nw))))))

# test membership
(defn in?
  ```Check if item `it` is a member of set `s`.  Returns boolean.```
  [s it]
  (truthy? (get s it)))

# set functions
(defn- typefcn
  [s]
  (if (set? s) new frozen))

(defn union
  ```Union of any number of sets / frozensets.
     Return type is a new set/frozenset depending on type of the first argument.```
  [fst & others]
  ((typefcn fst)
   ;(keys (merge fst ;others))))

(defn intersect
  ```Intersection of any number of sets / frozensets.
     Return type is a new set/frozenset depending on type of the first argument.```
  [fst & others]
  (def tb (table))
  (def ss (sort-by length (array/concat @[fst] others)))
  (def s1 (in ss 0))
  (array/remove ss 0)
  (loop [k :keys s1]
    (when (all |(in $ k) ss)
      (put tb k k)))
  ((typefcn fst)
   ;(keys tb)))

(defn diff
  ```Difference of any number of sets / frozensets.
     Return type is a new set/frozenset depending on type of the first argument.```
  [fst & others]
  (def tb (table ;(kvs fst)))
  (loop [s :in others]
    (loop [k :keys s]
      (when (get tb k)
        (put tb k nil))))
  ((typefcn fst) ;(keys tb)))

