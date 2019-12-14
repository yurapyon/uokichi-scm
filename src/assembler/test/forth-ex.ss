10 15 +

(.ldi (&r16) 10)
(.st (&r16) 'y-)

(.ldi (&r16) 15)
(.st (&r16) 'y-)

(.ld (&r16) 'y+)
(.ld (&r17) 'y+)
(.add (&r16) (&r17))
(.st (&r16) 'y-)

ym-init

(set-bit &ddrd 5)
(asm (.sbi (&ddrd '_io) 5))
(.sbi (&ddrd '_io) 5)

#b00100011 (&tccr0a) out

(.ldi (&r16) #b00100011)
(.st (&r16) 'y-)
(.ld (&r16) 'y+)
(.out (&r16) (&tccr0a))
