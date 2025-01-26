	.inesprg 1   ; 1x 16KB PRG code
	.ineschr 1   ; 1x  8KB CHR data
	.inesmap 0   ; mapper 0 = NROM, no bank swapping
	.inesmir 1   ; background mirroring
	.bank 0
	.org $C000
reset:
	SEI          ; disable IRQs
	CLD          ; disable decimal mode
	LDX #$40
	STX $4017    ; disable APU frame IRQ
	LDX #$FF
	TXS          ; Set up stack
	INX          ; now X = 0
	STX $2000    ; disable NMI
	STX $2001    ; disable rendering
	STX $4010    ; disable DMC IRQs

	;; Wait for vblank to make sure PPU is ready
vblank_wait_first:
	BIT $2002
	BPL vblank_wait_first

clear_mem:
	LDA #$00
	STA $0000, x
	STA $0100, x
	STA $0300, x
	STA $0400, x
	STA $0500, x
	STA $0600, x
	STA $0700, x
	INX
	BNE clear_mem

	;; Wait for vblank, PPU is ready after this
vblank_wait_second:
	BIT $2002
	BPL vblank_wait_second


load_palettes:
	LDA $2002    ; read PPU status to reset the high/low latch
	LDA #$3F
	STA $2006    ; write the high byte of $3F00 address
	LDA #$00
	STA $2006    ; write the low byte of $3F00 address
	LDX #$00
load_palettes_loop:
	LDA palette, x        ;load palette byte
	STA $2007             ;write to PPU
	INX                   ;set index to next byte
	CPX #$20
	BNE load_palettes_loop  ;if x = $20, 32 bytes copied, all done


	LDX #$00
	LDY #$00
print_hello_world_loop:
	;; load the Y axis from the data bytes
	LDA txt_string_y_axis, x
	STA $0200, y
	INY
	;; load a letter from the text string data bytes
	LDA txt_string, x
	STA $0200, y
	INY
	;; color = 0, no flipping
	LDA #$00
	STA $0200, y
	INY
	;; load the X axis from the data bytes
	LDA txt_string_x_axis, x
	STA $0200, y
	INY
	;; increment the loop counter
	INX
	CPX #$0A
	BNE print_hello_world_loop  ;if x = $0A, we copied 10 bytes (10 letters from the 'hello world')

	LDA #%10000000   ; enable NMI, sprites from Pattern Table 0
	STA $2000

	LDA #%00010000   ; enable sprites
	STA $2001

NMI:
	LDA #$00
	STA $2003  ; set the low byte (00) of the RAM address
	LDA #$02
	STA $4014  ; set the high byte (02) of the RAM address, start the transfer
	RTI        ; return from interrupt

	.bank 1
	.org $E000

palette:
	.db $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
	.db $0F,$30,$0F,$0B,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F

txt_string:
	.db $11,$0E,$15,$15,$18
	.db $20,$18,$1B,$15,$0D
txt_string_x_axis:
	.db $40,$4A,$54,$5E,$68
	.db $40,$4A,$54,$5E,$68
txt_string_y_axis:
	.db $50,$50,$50,$50,$50
	.db $5F,$5F,$5F,$5F,$5F

	.org $FFFA		; set the 3 interrupts
	.dw NMI
	.dw reset
	.dw 0			; no external IRQ

	.bank 2
	.org $0000
	.incbin "sprites.chr"   ; include graphics file
