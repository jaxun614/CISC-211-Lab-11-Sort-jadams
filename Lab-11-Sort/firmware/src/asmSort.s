/*** asmSort.s   ***/
#include <xc.h>
.syntax unified

@ Declare the following to be in data memory
.data
.align    

@ Define the globals so that the C code can access them
/* define and initialize global variables that C can access */
/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Jackson Adams"  

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

@ Tell the assembler that what follows is in instruction memory    
.text
.align

/********************************************************************
function name: asmSwap(inpAddr,signed,elementSize)
function description:
    Checks magnitude of each of two input values 
    v1 and v2 that are stored in adjacent in 32bit memory words.
    v1 is located in memory location (inpAddr)
    v2 is located at mem location (inpAddr + M4 word size)
    
    If v1 or v2 is 0, this function immediately
    places -1 in r0 and returns to the caller.
    
    Else, if v1 <= v2, this function 
    does not modify memory, and returns 0 in r0. 

    Else, if v1 > v2, this function 
    swaps the values and returns 1 in r0

Inputs: r0: inpAddr: Address of v1 to be examined. 
	             Address of v2 is: inpAddr + M4 word size
	r1: signed: 1 indicates values are signed, 
	            0 indicates values are unsigned
	r2: size: number of bytes for each input value.
                  Valid values: 1, 2, 4
                  The values v1 and v2 are stored in
                  the least significant bits at locations
                  inpAddr and (inpAddr + M4 word size).
                  Any bits not used in the word may be
                  set to random values. They should be ignored
                  and must not be modified.
Outputs: r0 returns: -1 If either v1 or v2 is 0
                      0 If neither v1 or v2 is 0, 
                        and a swap WAS NOT made
                      1 If neither v1 or v2 is 0, 
                        and a swap WAS made             
             
         Memory: if v1>v2:
			swap v1 and v2.
                 Else, if v1 == 0 OR v2 == 0 OR if v1 <= v2:
			DO NOT swap values in memory.

NOTE: definitions: "greater than" means most positive number
********************************************************************/     
.global asmSwap
.type asmSwap,%function     
asmSwap:

    /* YOUR asmSwap CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    push {r4-r11, lr}
    
    /* signed or unsigned */
    ldr r4, =1
    cmp r1, r4
    beq signed
unsigned:    
    /* data size */
    ldr r4, =1 /* 1 == byte */
    cmp r2, r4
    beq unsignedByteOpp
    ldr r4, =1 /* 2 == half word */
    cmp r2, r4
    beq unsignedHalfOpp
    ldr r4, =1 /* 4 == word */
    cmp r2, r4
    beq unsignedWordOpp
    b endSwap /* data size is not handeled by this func */
    /* if (v1 > v2):
	    swap v1 and v2.
       else ( if v1 == 0 OR v2 == 0 OR if v1 <= v2):
			DO NOT swap values in memory. */
unsignedByteOpp:
    mov r4, r0 /* move the mem address in r0 to r4 to be worked on */
    ldrb r5, [r4], 1 /* r5 is v[i] */
    ldrb r6, [r4] /* r6 is v[i+1] */
    /* check if either value is 0 */
    ldr r7, =0
    cmp r5, r7
    beq zeroNoSwap /* v[i] == 0 */
    cmp r6, r7
    beq zeroNoSwap /* v[i+1] == 0 */
    /* check if the values are in order */
    cmp r5, r6
    bls nonZeroNoSwap /* v[i] <= v[i+1] */
    /* the values can be swaped, v[i] > v[i+1] */
    strb r6, [r0], 1 /* write v[i+1] to the mem address in r0, post increment by 1 */
    strb r5, [r0] /* write v[i] to the mem address in r0 */
    ldr r0, =1 /* a 1 in r0 indicates a swap */
    b endSwap
    
unsignedHalfOpp: 
    mov r4, r0 /* move the mem address in r0 to r4 to be worked on */
    ldrh r5, [r4], 1 /* r5 is v[i] */
    ldrh r6, [r4] /* r6 is v[i+1] */
    /* check if either value is 0 */
    ldr r7, =0
    cmp r5, r7
    beq zeroNoSwap /* v[i] == 0 */
    cmp r6, r7
    beq zeroNoSwap /* v[i+1] == 0 */
    /* check if the values are in order */
    cmp r5, r6
    bls nonZeroNoSwap /* v[i] <= v[i+1] */
    /* the values can be swaped, v[i] > v[i+1] */
    strh r6, [r0], 1 /* write v[i+1] to the mem address in r0, post increment by 1 */
    strh r5, [r0] /* write v[i] to the mem address in r0 */
    ldr r0, =1 /* a 1 in r0 indicates a swap */
    b endSwap
    
unsignedWordOpp:    
    mov r4, r0 /* move the mem address in r0 to r4 to be worked on */
    ldr r5, [r4], 1 /* r5 is v[i] */
    ldr r6, [r4] /* r6 is v[i+1] */
    /* check if either value is 0 */
    ldr r7, =0
    cmp r5, r7
    beq zeroNoSwap /* v[i] == 0 */
    cmp r6, r7
    beq zeroNoSwap /* v[i+1] == 0 */
    /* check if the values are in order */
    cmp r5, r6
    bls nonZeroNoSwap /* v[i] <= v[i+1] */
    /* the values can be swaped, v[i] > v[i+1] */
    str r6, [r0], 1 /* write v[i+1] to the mem address in r0, post increment by 1 */
    str r5, [r0] /* write v[i] to the mem address in r0 */
    ldr r0, =1 /* a 1 in r0 indicates a swap */
    b endSwap
    
    
signed:  
    
/* either of the values are 0 */    
zeroNoSwap:
    ldr r0, =-1
    b endSwap
    
/* in order values */    
nonZeroNoSwap:
    ldr r0, =0
    b endSwap
    
endSwap:  
    pop {r4-r11, lr}
    bx lr

    /* YOUR asmSwap CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */
    
    
/********************************************************************
function name: asmSort(startAddr,signed,elementSize)
function description:
    Sorts value in an array from lowest to highest.
    The end of the input array is marked by a value
    of 0.
    The values are sorted "in-place" (i.e. upon returning
    to the caller, the first element of the sorted array 
    is located at the original startAddr)
    The function returns the total number of swaps that were
    required to put the array in order in r0. 
    
         
Inputs: r0: startAddr: address of first value in array.
		      Next element will be located at:
                          inpAddr + M4 word size
	r1: signed: 1 indicates values are signed, 
	            0 indicates values are unsigned
	r2: elementSize: number of bytes for each input value.
                          Valid values: 1, 2, 4
Outputs: r0: number of swaps required to sort the array
         Memory: The original input values will be
                 sorted and stored in memory starting
		 at mem location startAddr
NOTE: definitions: "greater than" means most positive number    
********************************************************************/     
.global asmSort
.type asmSort,%function
asmSort:   

    /* Note to Profs: 
     */

    /* YOUR asmSort CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */



    /* YOUR asmSort CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




