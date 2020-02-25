
bits	16
org	0x7c00

entry:
	cld
	xor	ax, ax
	mov	es, ax
	mov	gs, ax
	mov	ss, ax
	mov	sp, 0x7c00
	mov	bp, sp

	.set_vm:
		xor	ax, ax
		mov	al, 0x12
		int	0x10

	.draw_pit_line_start:
		mov	cx, 50
		mov	dx, 50

	.get_next_position:
		mov	ax, cx
		inc	ax
		call	get_pos

		cmp	dx, bx
		jl	.direction_down
		mov	si, 0
		jmp	.do_draw

	.direction_down:
		mov	si, 1

	.do_draw:
		call	draw_line
		cmp	cx, 550
		jl	.get_next_position
	
	jmp	.set_vm

	cli
	hlt


get_pos:
	cli
	in	al, 0x40
	mov	bl, al
	sti
	ret

; cx = x
; dx = y
; di = 1 if upwards line
draw_pixel:
	pusha
	push	dx
	cmp	di, 1
	je	.do_draw
	.clear_previous:
		mov	al, 0
		mov	ah, 0x0C
		xor	bh, bh
		int	0x10
		dec	dx
		test	dx, dx
		jnz	.clear_previous
	.do_draw:
		pop	dx
		mov	al, 50
		mov	ah, 0x0C
		xor	bh, bh
		int	0x10
		popa
		ret

; ax = dst x
; bx = dst y
; cx = current x
; dx = current y
; si = direction (1 = down, 0 = up)
draw_line:
	.loop:
		call	draw_pixel
		cmp	cx, ax
		jge	.max_x_reached
		inc	cx
		mov	di, 0
		jmp	.adj_y
	.max_x_reached:
		mov	di, 1
	.adj_y:
		cmp	bx, dx
		je	.done
	.do_adj:
		test	si, si
		jz	.dec_y
		inc	dx
		jmp	.loop
	.dec_y:
		dec	dx
		jmp	.loop
	.done:
		ret

times	510-($-$$) db 0x00
dw	0xAA55

