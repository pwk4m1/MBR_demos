
org	0x7c00
bits	16
jmp	0x0000:main

; requires:
;	al = color
;	cx = X
;	dx = Y
draw_pixel:
	pusha
	mov	ah, 0x0C
	xor	bh, bh
	int	0x10
	popa
	ret

; This function requires:
;	cx = initial X
;	dx = initial Y
;	bx = width
draw_vertical_line:
	pusha
	.loop:
		call	draw_pixel
		inc	cx
		dec	bx
		test	bx, bx
		jnz	.loop
	popa
	ret

; This function requires:
;	cx = initial X
;	dx = initial Y
;	bx = height
;
draw_horisontal_line:
	pusha
	.loop:
		call	draw_pixel
		inc	dx
		dec	bx
		test	bx, bx
		jnz	.loop
	popa
	ret

; This function requires:
;	cx = initial X
;	dx = initial Y
;	bx = length
;	di = direction Y (0 = down, 1 = up)
;	si = direction X (0 = left, 1 = right)
;
slide:
	pusha
.start:
	call	draw_pixel
	test	di, di
	jnz	.slide_down
	inc	dx
.check_x:
	test	si, si
	jnz	.slide_right
	dec	cx
	jmp	.check_len
.slide_right:
	inc	cx
	jmp	.check_len
.slide_down:
	dec	dx
	jmp	.check_x
.check_len:
	dec	bx
	test	bx, bx
	jnz	.start
	popa
	ret

set_video_mode:
	pusha
	xor	ax, ax
	add	al, 0x12
	int	0x10
	popa
	ret

main:
	mov	ax, 0
	mov	ss, ax
	mov	sp, 0x7c00
	call	set_video_mode
	mov	al, 0x13

	; let's draw a cube
	; front side
	mov	cx, 50
	mov	dx, 50
	mov	bx, 150
	call	draw_vertical_line
	inc	dx
	call	draw_vertical_line


	add	dx, 50
	call	draw_vertical_line
	dec	dx
	call	draw_vertical_line

	sub	dx, 50
	mov	bx, 50
	call	draw_horisontal_line
	inc	cx
	call	draw_horisontal_line

	add	cx, 149
	call	draw_horisontal_line
	dec	cx
	call	draw_horisontal_line
	
	; top side
	mov	di, 1
	mov	si, di
	mov	bx, 16
	call	slide
	inc	cx
	call	slide

	sub	cx, 150
	call	slide
	inc	cx
	call	slide

	add	dx, 50
	call	slide
	inc	dx
	call	slide

	mov	bx, 150
	add	cx, 15
	sub	dx, 16
	call	draw_vertical_line

	add	cx, 133
	add	dx, 16
	mov	bx, 16
	call	slide
	inc	cx
	call	slide

	add	cx, 15
	sub	dx, (15 + 50)
	mov	bx, 50
	call	draw_horisontal_line

	sub	cx, 149
	mov	bx, 150
	sub	dx, 2
	call	draw_vertical_line

	mov	bx, 50
	add	dx, 2
	call	draw_horisontal_line

	cli
	hlt

times	510 - ($ - $$) db 0
dw	0xAA55

