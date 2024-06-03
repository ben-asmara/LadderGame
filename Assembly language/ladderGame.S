.section .data
.align 4

# Define GPIO pin numbers
.equ LED_PINS, 0x3C0000    # GPIO 17, 27, 22, 23, 24, 25
.equ BUTTON_PIN, 12

# Define GPIO register addresses
.equ GPFSEL1, 0x20200004
.equ GPFSEL2, 0x20200008
.equ GPSET0, 0x2020001C
.equ GPCLR0, 0x20200028
.equ GPLEV0, 0x20200034

.section .bss
.align 4
current_level: .space 4

.section .text
.global _start

_start:
    # Initialize GPIO pins for LEDs and button
    bl setup_gpio

main_loop:
    # Flash LEDs to indicate waiting for input
    bl flash_leds
    
    # Check if button is pressed
    ldr r0, =GPLEV0
    ldr r1, [r0]
    tst r1, #(1 << BUTTON_PIN)
    beq main_loop
    
    # Debounce button
    bl debounce
    
    # Check current level and advance
    ldr r0, =current_level
    ldr r1, [r0]
    cmp r1, #8
    blt advance_level

    # Reset game if maximum level is reached
    bl reset_game
    b main_loop

advance_level:
    ldr r0, =current_level
    ldr r1, [r0]
    lsl r2, r1, #2
    ldr r3, =LED_PINS
    add r3, r3, r2
    ldr r4, [r3]
    bl set_gpio
    add r1, r1, #1
    str r1, [r0]
    b main_loop

reset_game:
    ldr r0, =LED_PINS
    ldr r1, =0xFC  # Mask for GPIO 17-27
    bl clear_gpio
    ldr r0, =current_level
    mov r1, #0
    str r1, [r0]
    bx lr

flash_leds:
    ldr r0, =LED_PINS
    ldr r1, =0xFC  # Mask for GPIO 17-27
    bl set_gpio
    bl delay
    ldr r0, =LED_PINS
    ldr r1, =0xFC  # Mask for GPIO 17-27
    bl clear_gpio
    bl delay
    bx lr

setup_gpio:
    ldr r0, =GPFSEL1
    ldr r1, [r0]
    orr r1, r1, #(1 << (3 * 7)) | (1 << (3 * 8)) | (1 << (3 * 9))  # Set GPIO 17, 27, 22 as output
    str r1, [r0]

    ldr r0, =GPFSEL2
    ldr r1, [r0]
    orr r1, r1, #(1 << (3 * 3)) | (1 << (3 * 4)) | (1 << (3 * 5))  # Set GPIO 23, 24, 25 as output
    str r1, [r0]
    
    ldr r0, =GPFSEL1
    ldr r1, [r0]
    bic r1, r1, #(7 << (3 * 2))  # Set GPIO 12 as input
    str r1, [r0]
    bx lr

set_gpio:
    ldr r1, =GPSET0
    str r0, [r1]
    bx lr

clear_gpio:
    ldr r1, =GPCLR0
    str r0, [r1]
    bx lr

debounce:
    mov r0, #0x3FFFFF
debounce_loop:
    subs r0, r0, #1
    bne debounce_loop
    bx lr

delay:
    mov r0, #0x3FFFFF
delay_loop:
    subs r0, r0, #1
    bne delay_loop
    bx lr
