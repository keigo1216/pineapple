#include "asm.h"

#define BOOT_PGD_ATTR PD_TABLE
#define BOOT_PUD_ATTR (PD_ACCESS | (MAIR_EL1_IDX_DEVICE_nGnRnE << 2) | PD_BLOCK)

.section ".text.boot"
.global boot
boot:
    ldr  x0, =0x30d00800 // Lttile Endian, MMU disabled, I/D-cache disabled
    msr  sctlr_el1, x0
    msr  sctlr_el2, x0
    
    // Non-Secure
    // set EL2 to AArch64
    mrs     x0, SCR_EL3
    mov     x1,  SCR_EL3_RW | SCR_EL3_NS
    orr     x0, x0, x1
    msr     SCR_EL3, x0

    // set EL1 to AArch64
    mov     x2, #HCR_EL2_RW
    msr     HCR_EL2, x2

    mrs  x1, mpidr_el1
    and  x1, x1, #3
    cbz x1, EL3_TO_EL1
    bl halt

halt:
    bl halt

EL3_TO_EL1:
    // ELR_EL3
    ldr     x0, =aarch64_boot
    msr    ELR_EL3, x0            // set up the return data
    // SPSR_EL3
    mov     x0, PSR_A_BIT | PSR_I_BIT | PSR_F_BIT | PSR_MODE_EL1h
    msr     SPSR_EL3, x0

    // Set Stack Pointer
    ldr     x4, =__boot_stack
    msr     SP_EL1, x4

    // Use SP_ELt (EL1 => SP_EL1, EL0 => SP_EL0)
    msr     SPSel, #1

    eret