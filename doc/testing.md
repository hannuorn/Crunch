# Crunch Testing

_(work in progress)_

Automated tests can be run by 

    crunch -test
    
A list of tested modules will be printed.



## Program Structure

Package Utility.Test offers basic tools for testing purposes.


## Naming Convention

Automated testing of package X.Y.Z is implemented in package

    Test_X.Test_Y.Test_Z
    

## Example

In this example, a problem is found in red-black tree routines.

    C:\Git\Crunch\obj\debug>crunch -test
    Crunch - test mode
    Running unit tests...

    Utility
       Dynamic_Arrays
          Simple_Test
       Binary_Search_Trees
          Simple_Test
          Large_Test_1
          Large_Test_2

    raised CONSTRAINT_ERROR : utility-binary_search_trees-red_black_trees.adb:542 access check failed

    C:\Git\Crunch\obj\debug>
    