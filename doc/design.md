# Crunch Design

Crunch is a console application that compresses files using DEFLATE format. 

Crunch is written in Ada 2012 using GNAT, a free Ada compiler. GNAT is part of the GNU Compiler Collection.

The goal of the Crunch project, apart from implementing a functional file compression tool, is to experiment with some customizations of the algorithm. For example, the standard 32K sliding window can be increased to 64K (known as Deflate64) or even higher to achieve better compression ratios.

The name *Crunch* was chosen because of two meanings of the word mentioned in Wiktionary:

* _To compress (data) using a particular algorithm, so that it can be restored by decrunching._

* _The overtime work required to catch up and finish a project, usually in the final weeks of development before release._

The latter seems especially appropriate.


## Algorithms and Data Structures

Deflate uses a combination of LZSS (Lempel-Ziv-Storer-Szymanski) and Huffman encoding. LZSS is a dictionary coding technique that attempts to replace a string of symbols with a reference to a dictionary location of the same string. Huffman code is a prefix code that represents more common symbols using fewer bits than less common symbols.

Huffman code uses a binary tree. Other basic data structures that will probably need to be implemented are variable-length arrays and queues.


## Input / Output

Input: Command line arguments and the file to be compressed.

Output: the compressed file and a performance report printed on the console.

For simplicity and accuracy of benchmarking, the compression process itself will not involve any I/O. The input file will be read into RAM first, and the output file will be generated only after the compression is complete.


## Time and Space Complexity

LZSS and Huffman algorithms are O(1) in space and O(n) in time, n being the size of the input file.

The relationship between the sliding window size and compression time is too complex to be determined at this stage.

Crunch requires enough RAM to accommodate both input and output files, and the space needed for the compression process, which should be negligible compared to the input and output data.


## References

* https://en.wiktionary.org/wiki/crunch
* https://en.wikipedia.org/wiki/DEFLATE
* [DEFLATE Compressed Data Format Specification version 1.3](https://tools.ietf.org/html/rfc1951)
