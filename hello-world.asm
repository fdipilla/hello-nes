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

	;;
	;; print hello one sprite at a time
	;;

	LDA #$50
	STA $0200  ; Load Y axis
	LDA #$11
	STA $0201  ; load tile number 17 in hex (H letter)
	LDA #$00
	STA $0202  ; color = 0, no flipping
	LDA #$40
	STA $0203  ; Load X axis

	LDA #$50
	STA $0204  ; Load Y axis
	LDA #$0E
	STA $0205  ; load tile number 14 in hex (E letter)
	LDA #$00
	STA $0206  ; color = 0, no flipping
	LDA #$4A
	STA $0207  ; Load X axis

	LDA #$50
	STA $0208  ; Load Y axis
	LDA #$15
	STA $0209  ; load tile number 21 in hex (L letter)
	LDA #$00
	STA $020A  ; color = 0, no flipping
	LDA #$54
	STA $020B  ; Load X axis

	LDA #$50
	STA $020C  ; Load Y axis
	LDA #$15
	STA $020D  ; load tile number 21 in hex (L letter)
	LDA #$00
	STA $020E  ; color = 0, no flipping
	LDA #$5E
	STA $020F  ; Load X axis

	LDA #$50
	STA $0210  ; Load Y axis
	LDA #$18
	STA $0211  ; load tile number 24 in hex (O letter)
	LDA #$00
	STA $0212  ; color = 0, no flipping
	LDA #$68
	STA $0213  ; Load X axis

	;;
	;; print world one sprite at a time
	;;

	LDA #$5F
	STA $0214  ; Load Y axis
	LDA #$20
	STA $0215  ; load tile number 32 in hex (W letter)
	LDA #$00
	STA $0216  ; color = 0, no flipping
	LDA #$40
	STA $0217  ; Load X axis

	LDA #$5F
	STA $0218  ; Load Y axis
	LDA #$18
	STA $0219  ; load tile number 24 in hex (O letter)
	LDA #$00
	STA $021A  ; color = 0, no flipping
	LDA #$4A
	STA $021B  ; Load X axis

	LDA #$5F
	STA $021C  ; Load Y axis
	LDA #$1B
	STA $021D  ; load tile number 27 in hex (R letter)
	LDA #$00
	STA $021E  ; color = 0, no flipping
	LDA #$54
	STA $021F  ; Load X axis


	LDA #$5F
	STA $0220  ; Load Y axis
	LDA #$15
	STA $0221  ; load tile number 21 in hex (L letter)
	LDA #$00
	STA $0222  ; color = 0, no flipping
	LDA #$5E
	STA $0223  ; Load X axis


	LDA #$5F
	STA $0224  ; Load Y axis
	LDA #$0D
	STA $0225  ; load tile number 13 in hex (D letter)
	LDA #$00
	STA $0226  ; color = 0, no flipping
	LDA #$68
	STA $0227  ; Load X axis


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

	.org $FFFA		; set the 3 interrupts
	.dw NMI
	.dw reset
	.dw 0			; no external IRQ

	.bank 2
	.org $0000
	.incbin "sprites.chr"   ; include graphics file
