### set.janet
###
### A basic set data structure for Janet, based on
### Janet tables and structs.

(import abstract)

# Prototype for janet sets
(defn- same-keys [at bt]
  (and
    (= (length at) (length bt))
    (deep= (keys at) (keys bt))))

(def method-table
  {
    :length (fn [ab] (def st (abstract/unwrap ab)) (length (table/rawget st :data)))
    })

(def proto
  @{
    :__get (fn [st k]  # get returns key (if key present) not val!, else nil
             (if (keyword? k)
               (get method-table k)
               (if (get (table/rawget st :data) k) k)))
    :__put (fn [st k v]
             (put-in st [:data k] v))
    :__next (fn [st k]
              (next (table/rawget st :data) k))
    :__compare (fn [a b]
                 (def at (table/rawget a :data))
                 (def bt (table/rawget b :data))
                 (if (same-keys at bt) 0
                   (cmp at bt)))
    :__tostring (fn [st buf]
                  (def data (table/rawget st :data))
                  (if (table? data) (buffer/push-string buf "@"))
                  (buffer/push-string buf "#{")
                  (loop [[i it] :pairs (keys data)]
                    (when (not= i 0)
                      (buffer/push-string buf " "))
                    (buffer/push-string buf (describe it)))
                  (buffer/push-string buf "}"))
    })


# To address issue with storing keywords as keys in abstract types
(defn- keystr [it]
  (if (keyword? it) (string it) it))

# create
(defn new
  ```Create a new mutable set from items
  Because of a limitation of Janet abstract types, any keywords
  added to a set will be converted to strings.
  (See https://github.com/mikebeller/janet-abstract for discussion.)
  ```
  [& items]
  (def tb (table ;(mapcat |[(keystr $) $] items)))
  (def ab @{:data tb})
  (table/setproto ab proto)
  (abstract/new ab))

(defn frozen
  ```Create a new frozen set from items
  Because of a limitation of Janet abstract types, any keywords
  added to a set will be converted to strings.
  (See https://github.com/mikebeller/janet-abstract for discussion.)
  ```
  [& items]
  (def str (struct ;(mapcat |[(keystr $) $] items)))
  (def ab @{:data str})
  (table/setproto ab proto)
  (abstract/new ab))

# check types
(defn set?
  ```Check if argument is a set```
  [s]
  (and
    (= (type s) :abstract/new)
    (let [tb (abstract/unwrap s)]
      (table? (get tb :data)))))

(defn frozenset?
  ```Check if argument is a frozenset```
  [s]
  (= (type s) :abstract/new)
    (let [tb (abstract/unwrap s)]
      (struct? (get tb :data))))

# add/remove
(defn add
  ```Add a value to a set.  Modifies original unless
     the set is a frozenset, in which case creates a new frozenset.```
  [ab it]
  (def it (keystr it))
  (if (frozenset? ab)
    (frozen it ;(values ab))
    (do (put ab it it)
      ab)))

(defn remove
  ```Remove a value from a set.  Modifies the original unless
     it is a frozenset, in which case returns a new set.```
  [st it]
  (def it (keystr it))
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
  (def it (keystr it))
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

