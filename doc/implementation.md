# Crunch Implementation

_(work in progress)_


## Code Style

Crunch follows the guidelines of *Ada Style Guide*.


## Huffman

Huffman coding is implemented according to Deflate specification.
A specific code can be represented as a list where a bit length is
assigned to each symbol, see RFC 1951 3.2.2. Package-Merge algorithm
is used to build a length-limited Huffman code (Sayood 2012).


## Red-Black Trees

Red-Black tree is used instead of minimum heap to build the Huffman tree.
It is also used for sorting. Red-Black tree is implemented according
to the textbook Introduction to Algorithms, with the added functionality
of node counting.


## List of packages

(excluding test packages)


    Crunch_Main_Program
    Deflate
       Deflate.Demo
       Deflate.Fixed_Huffman
       Deflate.Huffman
    Utility
       Utility.Binary_Search_Trees
       Utility.Binary_Search_Trees.Red_Black_Trees
       Utility.Bit_Arrays
       Utility.Dynamic_Arrays
       Utility.Test


## Sources

* [Ada Quality and Style Guide: Guidelines for Professional Programmers](https://en.wikibooks.org/wiki/Ada_Style_Guide)
* [Wikipedia: Huffman coding](https://en.wikipedia.org/wiki/Huffman_coding)
* [RFC 1951 DEFLATE Specification](https://tools.ietf.org/html/rfc1951)
* Cormen, Thomas H., et al. (2009), Introduction to Algorithms, Third Edition. MIT Press.
* Sayood, Khalid (2012), Introduction to data compression, Morgan Kaufmann, 4th ed.
