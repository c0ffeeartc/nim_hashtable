{.experimental.}
type
    Table[S:static[int],K,V] = object
        buckets: array[S, LList[K,V]]

    LList[K,V] = object
        head: ref Node[K,V]

    Node[K,V]  = object
        k:    K
        v:    V
        next: ref Node[K,V]


proc setValueForKey[S, K, V](t:Table[S,K,V], k:K, v:V) =
    discard nil


proc valueForKey[S,K,V](t:Table[S,K,V], k:K):ref V =
    nil


proc removeValueForKey[S, K, V](t:Table[S,K,V], k:K) =
    discard nil



when defined(testing):
    import unittest
    suite "check hash table":
        test "essential truths":
            # give up and stop if this fails
            require(true)

        test "slightly less obvious stuff":
            # print a nasty message and move on, skipping
            # the remainder of this block
            # check(1 != 1)
            check("asd"[2] == 'd')

        test "out of bounds error is thrown on bad access":
            let v = @[1, 2, 3]  # you can do initialization here
            expect(IndexError):
                discard v[4]
