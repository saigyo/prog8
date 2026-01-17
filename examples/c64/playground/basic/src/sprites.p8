%import textio
%import syslib
%import math
%zeropage basicsafe

main {

    sub start() {

        txt.print("balloon sprites!\n...we are all floating...\nborders are open too\n")

        ubyte[] spritecolors = [
                    colors.white, colors.red, colors.cyan, colors.purple,
                    colors.yellow, colors.orange, colors.gray, colors.brown
                ]

        ubyte @zp i
        for i in 0 to 7 {
            ; c64.set_sprite_ptr(i, &spritedata.balloonsprite)           ; alternatively, set directly:  c64.SPRPTR[i] = $0a00 / 64
            c64.SPRPTR[i] = lsb(&spritedata.balloonsprite as uword / 64)
            c64.SPXY[i*2] = 60+22*i
            c64.SPXY[i*2+1] = math.rnd()
            c64.SPCOL[i] = spritecolors[i]
        }

        c64.SPENA = 255       ; enable all sprites

        c64.XXPAND = 255      ; expand all sprites
        c64.YXPAND = 255

        c64.EXTCOL = colors.blue
        c64.BGCOL0 = colors.blue

        sys.set_rasterirq(&irq.irqhandler, 248)         ; trigger irq just above bottom border line
    }
}

colors {
    const ubyte black = 0
    const ubyte white = 1
    const ubyte red = 2
    const ubyte cyan = 3
    const ubyte purple = 4
    const ubyte green = 5
    const ubyte blue = 6
    const ubyte yellow = 7
    const ubyte orange = 8
    const ubyte brown = 9
    const ubyte lightred = 10
    const ubyte darkgray = 11
    const ubyte gray = 12
    const ubyte lightgreen = 13
    const ubyte lightblue = 14
    const ubyte lightgray = 15
}

irq {
    ; Pre-calculated bitmasks for MSIGX register (one per sprite)
    ubyte[] sprite_bitmasks = [$01, $02, $04, $08, $10, $20, $40, $80]

    sub irqhandler() -> bool {
        c64.SCROLY = %00010011             ; 24 row mode, preparing for border opening
        c64.EXTCOL = colors.green
        c64.BGCOL0 = colors.green

        ; float up & wobble horizontally
        ubyte @zp i
        ubyte @zp bitmask
        ubyte @zp lx
        for i in 0 to 14 step 2 {
            c64.SPXY[i+1]--
            ubyte @zp r = math.rnd()
            if r>215 {
                ; move right
                bitmask = sprite_bitmasks[i >> 1]
                lx = c64.SPXY[i]
                if lx==255 {
                    c64.SPXY[i] = 0
                    c64.MSIGX |= bitmask
                } else if (c64.MSIGX & bitmask) == 0 or lx < 88 {
                    c64.SPXY[i]++
                }
            } else if r<40 {
                ; move left
                bitmask = sprite_bitmasks[i >> 1]
                lx = c64.SPXY[i]
                if (c64.MSIGX & bitmask) != 0 and lx == 0 {
                    c64.MSIGX &= ~bitmask
                    c64.SPXY[i] = 255
                } else if (c64.MSIGX & bitmask) != 0 or lx > 25 {
                    c64.SPXY[i]--
                }
            }
        }

        c64.EXTCOL = colors.blue
        c64.BGCOL0 = colors.blue

        c64.SCROLY = %00011011            ; 25 row mode, border is open
        return true
    }

}

spritedata {
    ; this memory block contains the sprite data
    ; it must start on an address aligned to 64 bytes.

    ubyte[] @align64 balloonsprite = [
        %00000000,%01111111,%00000000,
        %00000001,%11111111,%11000000,
        %00000011,%11111111,%11100000,
        %00000011,%11100011,%11100000,
        %00000111,%11011100,%11110000,
        %00000111,%11011101,%11110000,
        %00000111,%11011100,%11110000,
        %00000011,%11100011,%11100000,
        %00000011,%11111111,%11100000,
        %00000011,%11111111,%11100000,
        %00000010,%11111111,%10100000,
        %00000001,%01111111,%01000000,
        %00000001,%00111110,%01000000,
        %00000000,%10011100,%10000000,
        %00000000,%10011100,%10000000,
        %00000000,%01001001,%00000000,
        %00000000,%01001001,%00000000,
        %00000000,%00111110,%00000000,
        %00000000,%00111110,%00000000,
        %00000000,%00111110,%00000000,
        %00000000,%00011100,%00000000
    ]
}
