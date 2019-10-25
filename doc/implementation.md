# Crunch Implementation


## Algorithms

Algorithms are implemented in as generic form as possible, taking advantage
of Ada's strong generic features. For example, the generic part
of the specification of Red-Black Tree package looks like this:

    generic
    
       type Key_Type is private;
       type Element_Type is private;
       
       with function "<"
         (Left, Right       : in     Key_Type)
                              return Boolean;
       
       with function "="
         (Left, Right       : in     Key_Type)
                              return Boolean;
   
The user of the package needs to specify two data types, key and the
data element stored in each node of the tree, and comparison functions for
the key type. "Private" in the generic part means that any type can be used,
as long as assignment is available. Examples of plausible actual key types
are integers, strings or arrays.


### Red-Black Tree
    package Utility.Binary_Search_Trees
    
Red-Black Tree is a balanced binary search tree. Every node in the tree has
a color, red or black. Five rules, or red-black properties, are defined to
guarantee that the height of the tree is never more than double the minimum
possible height. Therefore, Red-Black Tree is an excellent algorithm where
 worst-case performance is important.
 
As an additional feature, the implementation includes a node count.
The counter of a node indicates the total count of nodes in the subtree
the root of which is the node in question. Hence, the counter of the root node
indicates the total size of the tree.

Search, insertion and deletion are all O(log n), where n is the number of nodes
in the tree. The memory space required depends on the data types and how
the compiler chooses to represent the data. If 64-bit values are used for both
Key\_Type and Element\_Type, a node should not require more than 64 bytes.


### Hash Table
    package Utility.Hash_Tables

A very simple and generic hash table implementation was introduced to speed up the
Lempel-Ziv compression. It is up to the user to define a hash function, and
a data type for the hash key. The hash key is a discrete type, and its range
implicitly defines the size of the hash table. Collisions are handled by
red-black trees.

In the worst case where every value gets the same hash key, the performance equals
the performance of the red-black tree. The hash table requires 24 bytes times
the range of the hash key type of space. For example, for a 16-bit hash key
of 65536 possible values, 1.5 MB is needed.


### Linked Lists
    package Utility.Linked_Lists
    
Doubly linked lists were introduced in the later stages of the project to speed up
the Lempel-Ziv compression. They are used to maintain a list of locations where a 
certain "quadbyte", sequence of 4 bytes, can be found. Linked lists are appropriate
for this task, since the locations are introduced in increasing order, and the only
location that ever has to be removed from the list is the smallest one.

The implementation only offers O(1) functions: querying first or last,
next or previous, and removing or adding at the beginning or end of the list.


### Package-Merge

Package-Merge algorithm is a method for creating length-limited Huffman codes.
It maintains a list of letters, or combination of letters, sorted by their
probability of occurrence. Red-Black Tree is used for sorting.

Package-Merge requires O(nL) time and O(nL) space to generate an L-bit
length-limited code for an alphabet of n symbols. In the case of Deflate,
the "literal-length alphabet" has 285 symbols and the limit for bit length is 15.
Performance is therefore a non-issue.


## Code Style

Guidelines of *Ada Style Guide* are followed. The code has been designed to
be as self-documenting as possible. Comments are included only as considered
necessary for clarification. Essential Ada features, such as visibility control,
strong typing and generics, have been used to the maximum extent.


## List of packages

(excluding test packages)

    Crunch_Main_Program
    Deflate
       Deflate.Compression
       Deflate.Decompression
       Deflate.Demo
       Deflate.Huffman
       Deflate.Literal_Length_and_Distance
    Utility
       Utility.Binary_Search_Trees
       Utility.Binary_Search_Trees.Red_Black_Trees
       Utility.Binary_Search_Trees.Test
       Utility.Bits_and_Bytes
       Utility.Controlled_Accesses
       Utility.Dynamic_Arrays
       Utility.Hash_Tables
       Utility.Linked_Lists
       Utility.Test
       Utility.Test.Discrete_Types

Visibility has been minimized as much as possible.
Private child packages are used when appropriate. A private child package
(e.g. Utility.Binary\_Search\_Trees.Red\_Black\_Trees)
is not visible outside the context of its parent.


## Experimentation

The "lazy matching" method mentioned in Deflate specification was tried but
dropped from the program. It offered a very marginal improvement in compression
ratio but a big decrease in performance. Perhaps in the future, lazy matching
will be offered as an option.

Increasing the sliding window to 64 kilobytes (Deflate64) was also tried.
Again, the improvement in compression was minimal.


## Shortcomings and possible future improvements

Implementing Deflate within the timeline of the course turned out to be quite
demanding. I only started coding Lempel-Ziv a week before the final deadline.
Since the main priority was to get the program working, the code coverage of unit tests
is not great, and the documentation could be improved. The source code could
also use some cleaning up.

Crunch is extremely hungry for memory. During the Lempel-Ziv compression, the
output is represented in a table that requires 6 bytes for every literal or
length/distance pair. In practice, the process seems to use about 10 times the
size of the input file of memory.

The compression speed seems to be about 1 to 1.5 MB/s. This can be considered
decent performance for a prototype, but it definitely leaves room for improvement.
The current implementation of the 
Lempel-Ziv finds the absolute longest match possible and therefore,
most of the time, spends a lot of time for searching marginal improvements over
what has already been found.

On the positive note, I found data compression a fascinating topic and I will
almost certainly keep developing Crunch further. It would be interesting to
try the more advanced Huffman code generating algorithms introduced in 
Turpin & Moffat in 1994. Instead of handling the data one byte at a time,
the code could use 16-bit or even 24-bit words. The alphabet would then be much larger
and Huffman coding possibly more efficient. The way Deflate uses extra bits with
length and distance codes is a waste of space, since the extra bits are simply
uncoded raw numbers. Allocating a separate symbol for each length and distance
value, and increasing the maximum bit length of a Huffman code, would likely
increase the compression ratio.


## Sources

* [Ada Quality and Style Guide: Guidelines for Professional Programmers](https://en.wikibooks.org/wiki/Ada_Style_Guide)
* [Wikipedia: Huffman coding](https://en.wikipedia.org/wiki/Huffman_coding)
* [RFC 1951 DEFLATE Specification](https://tools.ietf.org/html/rfc1951)
* Cormen, Thomas H., et al. (2009), Introduction to Algorithms, Third Edition. MIT Press.
* Sayood, Khalid (2012), Introduction to data compression, Morgan Kaufmann, 4th ed.
* Turpin, A. and Moffat, A. (1994), Practical Length-Limited Coding for Large Alphabets
