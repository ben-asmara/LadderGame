// to compile: g++ push_button2.s -lwiringPi -g -o push_button2

.equ INPUT, 0
.equ OUTPUT, 1
.equ LOW, 0
.equ HIGH, 1
.equ LED_PIN, 1      // wiringPi 1 (physical 12)
.equ STOP_PIN, 6     // wiringPi 6 (physical 22)
.equ LED_OUTPUT_PIN, 16

.section .rodata
out_msg1: .asciz "Led should be on!\n"
out_msg2: .asciz "Led should be off!\n"

.text
.global main
main:
    // int main()
    push {lr} //{
    bl wiringPiSetup // wiringPiSetup(); // initialize the wiringPi library

    mov r0, #LED_PIN       // pinMode(1,INPUT); // set the wpi 1 pin for input
    mov r1, #INPUT
    bl pinMode

    mov r0, #STOP_PIN      // pinMode(6,INPUT); // set the wpi 6 pin for input
    mov r1, #INPUT
    bl pinMode

    mov r0, #LED_OUTPUT_PIN
    mov r1, #OUTPUT
    bl pinMode

    mov r4, #0     // zero is state in which led is off
do_while:
    cmp r4, #1
    bne l2
    mov r0, #LED_OUTPUT_PIN
    mov r1, #HIGH
    bl digitalWrite
    b continue_2
l2:
    mov r0, #LED_OUTPUT_PIN
    mov r1, #LOW
    bl digitalWrite
continue_2:
    mov r0, #STOP_PIN
    bl digitalRead       // r0 = digitalRead(STOP_PIN);
    cmp r0, #LOW         // is r0 == LOW (0)?
    bne end_do_while     // no, then exit do while loop

    mov r0, #100
    bl delay

    mov r0, #LED_PIN
    bl digitalRead       // r0 = digitalRead(LED_PIN);
    cmp r0, #HIGH        // is r0 == HIGH (1)?
    bne continue_while  // no, go to continue_while

    mov r4, #1       // state 1 is led on
    ldr r0, =out_msg1 // output message that LED is on
    bl printf
    b do_while
continue_while:
    mov r4, #0
    ldr r0, =out_msg2
    bl printf
    b do_while
end_do_while:
    mov r0, #0   //return 0;
    pop {pc}//}
