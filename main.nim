{.experimental.}
type
    Table[S:static[int],K,V] = object
        buckets*: array[S, LList[K,V]]

    LList[K,V] = object
        head*: ref Node[K,V]

    Node[K,V]  = object
        key:   K
        value: V
        next:  ref Node[K,V]

    TestA = object
        nums: array[5,int]


echo "(hello)"

var b:ref Table[256, string, int]  # required by tests (somehow)

echo "(bye)"


method popLlist[K,V](llist: var LList[K,V] ): ref Node[K,V] =
    result = llist.head
    if(result != nil):
        llist.head = result.next


method push[K,V](llist: var LList[K,V], node:ref Node[K,V]) =
    node.next  = llist.head
    llist.head = node


proc newNode[K,V](k:K,v:V, next: ref Node[K,V]): ref Node[K,V] =
    new(result)
    result.key   = k
    result.value = v
    result.next  = next


proc hashFunc(s:string):int =
    result = 0
    for i in 0 .. (s.len-1):
        result += ord(s[i])


proc indexFromHash(size:int, h:int):int =
    assert(size>0)
    return h mod size


method setValueForKey[S, K, V]( t:var Table[S,K,V], k:K, v:V) =
    let index = indexFromHash(S, k.hashFunc)
    var llist = t.buckets[index]
    var cur   = llist.head
    var prev: ref Node[K,V] = nil

    #
    # either replace match
    #
    while(cur!=nil):
        if(k == cur.key):
            cur.value = v
            return
        prev = cur
        cur  = cur.next

    #
    # or add new value
    #
    t.buckets[index].push(newNode(k,v, nil))


method valueForKey[S,K,V](t:Table[S,K,V], k:K): V =
    let index = indexFromHash(S, k.hashFunc)
    var cur   = t.buckets[index].head
    var prev: ref Node[K,V] = nil

    #
    # find value
    #
    while(cur!=nil):
        if(k == cur.key):
            return cur.value

        prev = cur
        cur  = cur.next

    #
    # not found
    #
    raise newException (KeyError, "Invalid key in valueForKey")


method removeValueForKey[S, K, V](t:Table[S,K,V], k:K) =
    echo S


when defined(testing):
    import unittest
    suite "test hash table":

        test "get value for wrong key":
            ### GIVEN
            ###     empty table
            var t:ref Table[256, string, int]
            new(t)

            ### THEN
            ###     raise Exception on get value
            expect(KeyError):
                discard t.valueForKey("nonExistent")


        test "set value for key":
            ### GIVEN
            ###     empty table
            const arrSize = 256
            var t:ref Table[arrSize, string, int]
            new(t)

            ### WHEN
            ###     add value for key
            let key:   string = "first"
            let value: int    = 10
            t.setValueForKey(key, value)

            let index = arrSize.indexFromHash(hashFunc(key))

            ### THEN
            ###     value matches
            check(t.buckets[index].head       != nil)
            check(t.buckets[index].head.value == value)
            check(t.valueForKey(key)          == value)

            ### WHEN
            ###     add value for another key
            let key2:   string = "second"
            let value2: int    = 20
            t.setValueForKey(key2, value2)

            ### THEN
            ###     value matches
            require(t.valueForKey(key2) == value2)


        test "hashFunc":
            ### THEN
            ###     different hashes for different strings
            check("hello".hashFunc != "bye".hashFunc)


        test "indexFromHash":
            ### THEN
            ###     index must be less than size
            for size in 1..10:
                for hash in 500..530:
                    check(indexFromHash(size, hash) < size)
