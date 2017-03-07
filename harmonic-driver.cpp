//=======1=========2=========3=========4=========5=========6=========7=========8=========9=========0=========1=========2=========3=========4=========5=========6=========7**
//Author information
//  Author name: Sina Amini
//  Author email: sinamindev@gmail.com
//Project information
//  Title: Harmonic Series
//  Purpose: Review measuring execution time, optimize algorithm speed, applications of harmonic sum
//  Status: Performs correctly on Linux 64-bit platforms with AVX
//  Files: harmonic-driver.cpp, harmonic.asm
//Module information
//  This module's call name: runme.out  This module is invoked by the user
//  Language: C++
//  Date last modified: 2014-Dec-8
//  Purpose: This module is the top level driver: it will call harmonic
//  File name: harmonic-driver.cpp
//  Status: In production.  No known errors.
//  Future enhancements: None planned
//Translator information
//  Gnu compiler: g++ -c -m64 -Wall -l harmonic.lis -o harmonic-driver.o harmonic-driver.cpp
//  Gnu linker:   g++ -m64 -o runme.out harmonic-driver.o harmonic.o 
//References and credits
//  This module is standard C++
//Format information
//  Page width: 172 columns
//  Begin comments: 61
//  Optimal print specification: Landscape, 7 points or smaller, monospace, 8½x11 paper
//
//===== Begin code area ===================================================================================================================================================

#include <stdio.h>
#include <stdint.h>
#include <ctime>
#include <cstring>
#include <iostream>
using namespace std;

extern "C" double harmonic(long* info);

int main(){
  double return_code = 9.99;
  long* my = new long;
  printf("%s","\nWelcome to the harmonic series by Sina Amini \n\n");
  return_code = harmonic(my);
  
  printf("%s%ld%s%1.10f\n","The driver received these numbers: ", *my, " and ",  return_code);
  printf("%s\n\n","The driver will now return a 0 to the operating system.");

  return 0;
}//End of main

//===== End of main =======================================================================================================================================================
