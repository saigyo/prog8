%import syslib
%zeropage basicsafe
%option no_sysinit

main  {
    str msg = "hello, kernal!"
    sub start() {
        ubyte i = 0
        while msg[i] != 0 {
            cbm.CHROUT(msg[i])   ; calls $FFD2
            i++
        }
    }
}
