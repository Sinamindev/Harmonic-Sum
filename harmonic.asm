;========1=========2=========3=========4=========5=========6=========7=========8=========9=========0=========1=========2=========3=========4=========5=========6=========7**
;Author information
;  Author name: Sina Amini  
;  Author email: sinamindev@gmail.com
;Project information
;  Project title: Harmonic Series
;  Purpose: Review measuring execution time, optimize algorithm speed, applications of harmonic sum
;  Status: No known errors
;  Project files: harmonic-driver.cpp, harmonic.asm
;Module information
;  This module's call name: harmonic
;  Language: X86-64
;  Syntax: Intel
;  Date last modified: 2014-Dec-8
;  Purpose: compute a harmonic series and record runtime.  
;  File name: harmonic.asm
;  Status: This module functions as expected.
;  Future enhancements: None planned
;Translator information
;  Linux: nasm -f elf64 -l harmonic.lis -o harmonic.o harmonic.asm 
;Format information
;  Page width: 172 columns
;  Begin comments: 61
;  Optimal print specification: Landscape, 7 points or smaller, monospace, 8½x11 paper
;
;===== Begin code area ====================================================================================================================================================
extern printf                                               ;External C++ function for writing to standard output device

extern scanf                                                ;External C++ function for reading from the standard input device

extern getchar                                              ;External C++ function for reading characters from standard input device

global harmonic                                             ;This makes passing callable by functions outside of this file.

%include "debug.inc"                                        ;Allows debug.inc to be used in this asm file

segment .data                                               ;Place initialized data here

;===== Declare some messages ==============================================================================================================================================

initialmessage                          db "This program will compute a partial sum of the harmonic series", 10, 10
                                        db "These results were obtained on a Lenovo Y500 labtop with Core-i7 quad core processor at 2.4GHz ", 10, 0

promptmessage                           db 10, "Please enter a positive integer for the number of terms to include in the harmonic sum: ", 0

echostart                               db "The harmonic sum H(%ld) is being computed.",10
                                        db "Please be patient . . . .", 10, 0

echofinish                              db "The sum is now computed.",10,0

clockbefore                             db "The clock time before the calculations began was  %ld ", 10, 0

clockafter                              db "The clock time after completion of calculations was %ld ", 10, 0

clockruntime                            db "The harmonic computation required %ld clock cycles (tics) which is", 0
    
timeformat                              db " %.10lf seconds on this machine.",10,0
        
echoharmonic                            db "The harmonic sum of %ld terms is %.10lf, which is 0x%.16lx.", 0

goodbye                                 db 10, "This assembly program will now return to the caller",10, 10,0               

xsavenotsupported.notsupportedmessage   db "The xsave instruction and the xrstor instruction are not supported in this microprocessor.", 10
                                        db "However, processing will continue without backing up state component data", 10, 0

stringformat                            db "%s", 0          ;general string format

xsavenotsupported.stringformat          db "%s", 0

eight_byte_format                       db "%.8lf",10, 0    ;general 8-byte float format

integer_format                          db "%ld",0          ;general integer format

segment .bss                                                ;Place un-initialized data here.

align 64                                                    ;Insure that the inext data declaration starts on a 64-byte boundar.

backuparea resb 832                                         ;Create an array for backup storage having 832 bytes.
localbackuparea resb 832                                    ;reserve space for backup

data resq 15                                                ;create data array of size 15
pointer resq 15                                             ;creata pointer array of size 15
reciprocals resq 15

segment .text                                               ;Place executable instructions in this segment.
mov rdx, 0                                                  ;prepare rdx
mov rax, 7                                                  ;machine supports avx
xsave  [localbackuparea]                                    ;backup area

;===== Begin executable instructions here =================================================================================================================================

segment .text                                               ;Place executable instructions in this segment.

GHz dq 2.4                                                  ;store 2.4 into GHz to be used to compute length of computation

harmonic:                                                   ;Entry point.  Execution begins here.

;=========== Back up all the GPRs whether used in this program or not =====================================================================================================

push       rbp                                              ;Save a copy of the stack base pointer
mov        rbp, rsp                                         ;We do this in order to be 100% compatible with C and C++.
push       rbx                                              ;Back up rbx
push       rcx                                              ;Back up rcx
push       rdx                                              ;Back up rdx
push       rsi                                              ;Back up rsi
push       rdi                                              ;Back up rdi
push       r8                                               ;Back up r8
push       r9                                               ;Back up r9
push       r10                                              ;Back up r10
push       r11                                              ;Back up r11
push       r12                                              ;Back up r12
push       r13                                              ;Back up r13
push       r14                                              ;Back up r14
push       r15                                              ;Back up r15
pushf                                                       ;Back up rflags

;==========================================================================================================================================================================
;===== Begin State Component Backup =======================================================================================================================================
;==========================================================================================================================================================================
;========== Obtain the bitmap of state components =========================================================================================================================

;Preconditions
mov        rax, 0x000000000000000d                          ;Place 13 in rax.  This number is provided in the Intel manual
mov        rcx, 0                                           ;0 is parameter that requests the subfunction that creates the bitmap

;Call the function
cpuid                                                       ;cpuid is an essential function that returns information about the cpu

;Postconditions (There are 2 of these):

;1.  edx:eax is a bit map of state components managed by xsave.  At the time this was written (year 2014) there were exactly 3 state components.  Therefore, bits numbered
;    2, 1, and 0 are important for current cpu technology.
;2.  ecx holds the number of bytes required to store all the data of enabled state components. [Post condition 2 is not used in this program.]
;This program assumes that under current technology (year 2014) there are at most three state components having a maximum combined data storage requirement of 832 bytes.
;Therefore, the value in ecx will be less than or equal to 832.

;Precaution: As an insurance against a future time when there will be more than 3 state components in a processor of the X86 family the state component bitmap is masked to
;allow only 3 state components maximum.

and        rax, 0x0000000000000007                          ;Bits 63-3 become zeros.
xor        rdx, rdx                                         ;A register xored with itself becomes zero

;========== Save all the data of all the enabled state components; GPRs are excluded ======================================================================================

;The instruction xsave will save those state components with one bits in the bitmap.  At this point edx:eax continues to hold the state component bitmap.

;Precondition: edx:eax holds the state component bit map.  This condition has been met.
xsave      [backuparea]                                     ;All the data of state components as described in the bitmap have been written to backuparea.

;Since the start of this program two critical GPRs have changed values, namely: rcx and rdx.  These are critical because they are among the six registers used to pass 
;non-float data to subprograms like this one.  To be absolutely sure that the six data passing registers have their passed-in values all six will have original values 
;restored to them although only two were at risk of losing their passed-in values.

mov        rdi, [rsp+72]
mov        rsi, [rsp+80]
mov        rdx, [rsp+88]
mov        rcx, [rsp+96]
mov        r8,  [rsp+64]
mov        r9,  [rsp+56]

;==========================================================================================================================================================================
;===== End of State Component Backup ======================================================================================================================================
;==========================================================================================================================================================================

;==========================================================================================================================================================================
startapplication: ;===== Begin the application here: Amortization Schedule ================================================================================================
;==========================================================================================================================================================================

vzeroall                                                    ;place binary zeros in all components of all vector register in SSE

;==== Show the initial message ============================================================================================================================================
mov rdx, 0                                                  ;move 0 to prepare for backup
mov rax, 7                                                  ;machine supports avx registers to backup
xsave  [localbackuparea]                                    ;backup registers to localbackuparea

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, initialmessage                              ;"This program will compute a partial sum of the harmonic series"
                                                            ;"These results were obtained on a Lenovo Y500 labtop with Core-i7 quad core processor at 2.4GHz "
call       printf                                           ;Call a library function to make the output

mov rdx, 0                                                  ;prepare to restore
mov rax, 7                                                  ;machine should restore up to ymm registers
xrstor  [localbackuparea]                                   ;restore backed up registers
    
;==== Prompt for integer number ===========================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, promptmessage                               ;"Please enter a positive integer for the number of terms to include in the harmonic sum: "
call       printf                                           ;Call a library function to make the output

;==== Obtain an integer number from the standard input device and store a copy in r15 =====================================================================================

push dword 0                                                ;Reserve 4 bytes of storage for the incoming integer
mov qword  rax, 0                                           ;SSE is not involved in this scanf operation                                          
mov        rdi, integer_format                              ;"%d"
mov        rsi,rsp                                          ;Give scanf a point to the reserved storage
call       scanf                                            ;Call a library function to do the input work
mov        r15, [rsp]                                       ;move the harmonic value as an integer into the gpr r15
pop rax                                                     ;Make free the storage that was used by scanf

mov  rdi, [rsp+72]                                          ;point rdi to the right location for the driver to recieve the inputted value
mov [rdi], rax                                              ;give inputted value back to driver

;==== Confirm computation start ===========================================================================================================================================

mov rsi, r15                                                ;move the inputted integer into rsi for output
push qword 0                                                ;Reserve 8 bytes of storage
mov   rax, 0                                                ;0 data from SSE will be printed
mov        rdi, echostart                                   ;"The harmonic sum H(%ld) is being computed."
                                                            ;"Please be patient . . . ."
call       printf                                           ;Call a library function to make the output
pop rax                                                     ;Make free the storage that was used by printf

;====== read and save clock time into r14 ===============================================================================================================================

mov rdx, 0                                                  ;move 0 to prepare for backup
mov rax, 0                                                  ;move 0 to prepare for backup

rdtsc                                                       ;copies counter to edx:eax
shl rdx, 32                                                 ;shift the values
or rdx, rax                                                 ;fills the values in rax to the end of the rdx register
mov r14, rdx                                                ;move starting time into r14

;==== Harmonic Series loop ================================================================================================================================================
;r15 inputted integer || r14 = clock || r13 = 1 
    
mov r13, 1                                                  ;move 1 into r13 to act as incramenting denominator of harmonic sum
cvtsi2sd xmm2, r13                                          ;initialize harmonic sum to 1
movq xmm0, r13                                              ;move 1 into xmm0 for devision

topofloop:                                                  ;start of loop
                        
cvtsi2sd xmm1, r13                                          ;converts integer to deciaml

divsd xmm2, xmm1                                            ;divide 1 by the denomenator to get the sum
addsd xmm0, xmm2                                            ;add the harmonic value to xmm0 to store the sum
mulsd xmm2, xmm1                                            ;restore values for the next loop iteration 

inc r13                                                     ;incremant the count of elements being enter
cmp r15, r13                                                ;checks the current number of elemetns with the total elements of data array

jl outofloop                                                ;jumps out of loop if both array sizes are equal
jmp topofloop                                               ;jumps to the top of the loop if the pointer array size is less than the data array size

outofloop:                                                  ;position to jump out of loop

movsd xmm15, xmm0                                           ;save to higher register to protect from printf

;==== Confirm computation success =========================================================================================================================================
mov rdx, 0                                                  ;move 0 to prepare for backup
mov rax, 7                                                  ;machine supports avx registers to backup
xsave  [localbackuparea]                                    ;backup registers to localbackuparea

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, echofinish                                  ;"The sum is now computed."
call       printf                                           ;Call a library function to make the output

mov rdx, 0                                                  ;prepare to restore
mov rax, 7                                                  ;machine should restore up to ymm registers
xrstor  [localbackuparea]                                   ;restore backed up registers

;====== Output starting time ==============================================================================================================================================

pop rcx                                                     ;pop starting time off of stack and into rcx register

mov        rax, 0                                           ;0 numbers will be outputted
mov        rsi , r14                                        ;move the starting clock value into rsi from r14 for outputting
mov        rdi, clockbefore                                 ;"The clock time before the calculations began was  %ld  "
call       printf                                           ;Call a library function to do the hard work

mov rdx, 0                                                  ;set rdx register to 0
mov rax, 0                                                  ;set rax register to 0

;==== Save end clock time =================================================================================================================================================

cpuid                                                       ;sync instructions for timestamp
rdtsc                                                       ;copies counter to edx:eax
shl rdx, 32                                                 ;shift the values
or rdx, rax                                                 ;fills the values in rax to the end of the rdx register; mov rdx, rax
mov r13, rdx                                                ;move end time into r14

;==== Outout end time =====================================================================================================================================================
mov rdx, 0                                                  ;move 0 to prepare for backup
mov rax, 7                                                  ;machine supports avx registers to backup
xsave  [localbackuparea]                                    ;backup registers to localbackuparea

mov        rax, 0                                           ;0 numbers will be outputted
mov        rsi ,  r13                                       ;move the end time value into rsi from r13
mov        rdi, clockafter                                  ;"The clock time after completion of calculations was %ld  "
call       printf                                           ;Call a library function to do the hard work

mov rdx, 0                                                  ;prepare to restore
mov rax, 7                                                  ;machine should restore up to ymm registers
xrstor  [localbackuparea]                                   ;restore backed up registers

;==== Outout total time ===================================================================================================================================================
sub r13, r14                                                ;subtract the endtime by the start time and store in r13

mov rdx, 0                                                  ;move 0 to prepare for backup
mov rax, 7                                                  ;machine supports avx registers to backup
xsave  [localbackuparea]                                    ;backup registers to localbackuparea

mov        rax, 0                                           ;0 numbers will be outputted
mov        rsi , r13                                        ;move the run time value into rsi from r13
mov        rdi, clockruntime                                ;"The harmonic computation required %ld clock cycles (tics) which is"
                        
call       printf                                           ;Call a library function to do the hard work

mov rdx, 0                                                  ;prepare to restore
mov rax, 7                                                  ;machine should restore up to ymm registers
xrstor  [localbackuparea]                                   ;restore backed up registers

cvtsi2sd xmm13, r13                                         ;converts the integer to decimal 
divsd xmm13, [GHz]                                          ;divide the number of tics by the clock speed
mov r10, 1000000000                                         ;move 1000000000 into r10 for seconds computation
cvtsi2sd xmm10, r10                                         ;converts the integer to decimal

divsd xmm13, xmm10                                          ;divide the nano seconds by 1000000000

movsd xmm0, xmm13                                           ;move total seconds into xmm0 for print

push qword 0                                                ;Reserve 8 bytes of storage
mov rdi, timeformat                                         ;" %.10lf seconds on this machine."
mov rsi, rax                                                ;move the computed nanoseconds value into rsi for output
mov rdx, rax                                                ;move the computed seconds value into rdx for output
mov rax, 1                                                  ;fills the rax register with the value 1
call printf                                                 ;Call a library function to do the hard work
pop rax                                                     ;Make free the storage that was used by printf

;==== harmonic sum print ==================================================================================================================================================

movsd xmm0,xmm15                                            ;move sum computed to prepare for printing
movq r14, xmm15                                             ;move sum into r14 to be returned to the driver at the end of program
movq rdx, xmm15                                             ;move sum into rdx to print as hex value
mov rsi, r15                                                ;prepare number entered for printing

;======= Print Results ====================================================================================================================================================

push qword 0                                                ;Reserve 8 bytes of storage
mov rdi, echoharmonic                                       ;Format for numeric output
mov rax, 1                                                  ;"The harmonic sum of %ld terms is %.10lf, which 0x%018lx."
call printf                                                 ;external function to print values
pop rax                                                     ;Make free the storage that was used by printf

push    qword   0                                           ;Reserve 8 bytes of storage
mov     [rsp], r15                                          ;Place a backup copy of the quotient in the reserved storage

;===== Conclusion message =================================================================================================================================================
mov rdx, 0                                                  ;move 0 to prepare for backup
mov rax, 7                                                  ;machine supports avx registers to backup
xsave  [localbackuparea]                                    ;backup registers to localbackuparea

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, goodbye                                     ;"This assembly program will now return to the caller."                              
call       printf                                           ;Call a llibrary function to do the hard work.

mov rdx, 0                                                  ;prepare to restore
mov rax, 7                                                  ;machine should restore up to ymm registers
xrstor  [localbackuparea]                                   ;restore backed up registers

;Now the stack is in the same state as when the application area was entered.  It is safe to leave this application area.

;==========================================================================================================================================================================
;===== Begin State Component Restore ======================================================================================================================================
;==========================================================================================================================================================================

;Precondition: edx:eax must hold the state component bitmap.  Therefore, go get a new copy of that bitmap.

;Preconditions for obtaining the bitmap from the cpuid instruction
mov        rax, 0x000000000000000d                          ;Place 13 in rax.  This number is provided in the Intel manual
mov        rcx, 0                                           ;0 is parameter that requests the subfunction that creates the bitmap

;Call the function
cpuid                                                       ;cpuid is an essential function that returns information about the cpu

;Postcondition: The bitmap in now in edx:eax

;Future insurance: Make sure the bitmap is limited to a maximum of 3 state components since only 3 state components existed when this software was created.
and        rax, 0x0000000000000007                          ;Bits 63-3 become zeros.
xor        rdx, rdx                                         ;A register xored with itself becomes zero

xrstor     [backuparea]                                     ;The data of the state components as described in the bitmap have been copied from array backuparea to their
                                                            ;original locations. 
;==========================================================================================================================================================================
;===== End State Component Restore ========================================================================================================================================
;==========================================================================================================================================================================

setreturnvalue: ;=========== Set the value to be returned to the caller ===================================================================================================

push       r14                                              ;r14 contains the variance to be received by the driver
movsd      xmm0, [rsp]                                      ;The variance is copied to xmm0[63-0]
pop        rax                                              ;Reverse the push of two lines earlier.

;=========== Restore GPR values and return to the caller ==================================================================================================================

popf                                                        ;Restore rflags
pop        r15                                              ;Restore r15
pop        r14                                              ;Restore r14
pop        r13                                              ;Restore r13
pop        r12                                              ;Restore r12
pop        r11                                              ;Restore r11
pop        r10                                              ;Restore r10
pop        r9                                               ;Restore r9
pop        r8                                               ;Restore r8
pop        rdi                                              ;Restore rdi
pop        rsi                                              ;Restore rsi
pop        rdx                                              ;Restore rdx
pop        rcx                                              ;Restore rcx
pop        rbx                                              ;Restore rbx
pop        rbp                                              ;Restore rbp

ret                                                         ;No parameter with this instruction.  This instruction will pop 8 bytes from
                                                            ;the integer stack, and jump to the address found on the stack.
;========== End of program passing.asm ====================================================================================================================================
;========1=========2=========3=========4=========5=========6=========7=========8=========9=========0=========1=========2=========3=========4=========5=========6=========7**

