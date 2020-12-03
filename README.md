<h2>CS 271 - Computer Architecture & Assembly Language - Portfolio Project</h2>

<p>This was the final portfolio project for my CS 271 class at OSU in the post-bacc BSCS program. This is an assembly program based around manipulating strings. The user may enter 10 numbers, so long as they are between the range -2^31 to 2^31 - 1 (size of a SDWORD), and then the numbers are displayed along with the sum and average. The program reads user input as a BYTE array, which is then validated to ensure the input is a valid number, and then the BYTE array is converted to a number and stored in an SDWORD array. When the program writes the values, the number is broken down into a BYTE array again. This is accomplished by stripping off the last digit of the number in a loop, storing the number backwards, and any sign or spacing is added at the end. The string is then reversed and displayed.</p>

<h2>Screenshot</h2>

<img src="screenshot1.png">

<h2>Project Instructions</h2>

<h3>Program Description</h3>

<p>Write and test a MASM program to perform the following tasks (check the Requirements section for specifics on program modularization):</p>

<ul>
  <li>Implement and test two macros for string processing. These macros may use Irvine’s ReadString to get input from the user, and WriteString procedures to display output.
    mGetSring:</li>
  <ul>
    <li>Display a prompt (input parameter, by reference), then get the user’s keyboard input into a memory location (output parameter, by reference). You may also need to provide a count (input parameter, by value) for the length of input string you can accommodate and a provide a number of bytes read (output parameter, by reference) by the macro.</li>
    <li>mDisplayString:  Print the string which is stored in a specified memory location (input parameter, by reference).</li>
  </ul>
  <li>Implement and test two procedures for signed integers which use string primitive instructions</li>
    <ul>
      <li>ReadVal:</li>
        <ol>
          <li>Invoke the mGetSring macro (see parameter requirements above) to get user input in the form of a string of digits.</li>
          <li>Convert (using string primitives) the string of ascii digits to its numeric value representation (SDWORD), validating the user’s input is a valid number (no letters, symbols, etc).</li>
          <li>Store this value in a memory variable (output parameter, by reference).</li>
        </ol>
      <li>WriteVal:</li>
        <ol>
          <li>Convert a numeric SDWORD value (input parameter, by value) to a string of ascii digits.</li>
          <li>Invoke the mDisplayString macro to print the ascii representation of the SDWORD value to the output.</li>
        </ol>
    </ul>
  <li>Write a test program (in main) which uses the ReadVal and WriteVal procedures above to:</li>
    <ol>
      <li>Get 10 valid integers from the user.</li>
      <li>Stores these numeric values in an array.</li>
      <li>Display the integers, their sum, and their average.</li>
    </ol>
    
<h3>Program Requirements</h3>

<ol>
  <li>User’s numeric input must be validated the hard way:</li>
    <ul>
      <li>Read the user's input as a string and convert the string to numeric form.</li>
      <li>If the user enters non-digits other than something which will indicate sign (e.g. ‘+’ or ‘-‘), or the number is too large for 32-bit registers, an error message should be displayed and the number should be discarded.</li>
      <li>If the user enters nothing (empty input), display an error and re-prompt.</li>
    </ul>
  <li>ReadInt, ReadDec, WriteInt, and WriteDec are not allowed in this program.</li>
  <li>Conversion routines must appropriately use the LODSB and/or STOSB operators.</li>
  <li>All procedure parameters must be passed on the runtime stack. Strings must be passed by reference.</li>
  <li>Prompts, identifying strings, and other memory locations must be passed by address to the macros.</li>
  <li>Used registers must be saved and restored by the called procedures and macros.</li>
  <li>The stack frame must be cleaned up by the called procedure.</li>
  <li>Procedures (except main) must not reference data segment variables or constants by name.</li>
  <li>The program must use Register Indirect addressing for array elements (except LODSB and/or STOSB as per item 3 above), and Base+Offset addressing for accessing parameters on the runtime stack.</li>
  <li>Procedures may use local variables when appropriate.</li>
  <li>The program must be fully documented and laid out according to the CS271 Style Guide. This includes a complete header block for identification, description, etc., a comment outline to explain each section of code, and proper procedure headers/documentation.</li>
</ol>

<h3>Notes</h3>

<ol>
  <li>For this assignment you are allowed to assume that the total sum of the numbers will fit inside a 32 bit register.</li>
  <li>We will be testing this program with positive and negative values.</li>
  <li>When displaying the average, you may round down (floor) to the nearest integer. For example if the sum of the 10 numbers is 3568 you may display the average as 356.</li>
  <li>Check the Course SyllabusPreview the document for late submission guidelines.</li>
  <li>Find the assembly language instruction syntax and help in the CS271 Instructions Guide.</li>
  <li>To create, assemble, run,  and modify your program, follow the instructions on the course Syllabus Page’s "Tools" tab.</li>
