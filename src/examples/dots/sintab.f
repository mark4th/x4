\ Sin and Cos table based on 512 degree circle.
\ -----------------------------------------------------------------------

create sin_tab
  $0000 w, $00c9 w, $0192 w, $025b w, $0323 w, $03ec w, $04b5 w, $057d w,
  $0645 w, $070d w, $07d5 w, $089c w, $0964 w, $0a2a w, $0af1 w, $0bb6 w, 
  $0c7c w, $0d41 w, $0e05 w, $0ec9 w, $0f8c w, $104f w, $1111 w, $11d3 w,
  $1294 w, $1354 w, $1413 w, $14d1 w, $158f w, $164c w, $1708 w, $17c3 w,
  $187d w, $1937 w, $19ef w, $1aa6 w, $1b5d w, $1c12 w, $1cc6 w, $1d79 w,
  $1e2b w, $1edc w, $1f8b w, $2039 w, $20e7 w, $2192 w, $223d w, $22e6 w,
  $238e w, $2434 w, $24da w, $257d w, $261f w, $26c0 w, $275f w, $27fd w,
  $2899 w, $2934 w, $29cd w, $2a65 w, $2afa w, $2b8e w, $2c21 w, $2cb2 w,
  $2d41 w, $2dce w, $2e5a w, $2ee3 w, $2f6b w, $2ff1 w, $3076 w, $30f8 w,
  $3179 w, $31f7 w, $3274 w, $32ee w, $3367 w, $33de w, $3453 w, $34c6 w,
  $3536 w, $35a5 w, $3612 w, $367c w, $36e5 w, $374b w, $37af w, $3811 w,
  $3871 w, $38cf w, $392a w, $3983 w, $39da w, $3a2f w, $3a82 w, $3ad2 w,
  $3b20 w, $3b6c w, $3bb6 w, $3bfd w, $3c42 w, $3c84 w, $3cc5 w, $3d02 w,
  $3d3e w, $3d77 w, $3dae w, $3de2 w, $3e14 w, $3e44 w, $3e71 w, $3e9c w,
  $3ec5 w, $3eeb w, $3f0e w, $3f2f w, $3f4e w, $3f6a w, $3f84 w, $3f9c w,
  $3fb1 w, $3fc3 w, $3fd3 w, $3fe1 w, $3fec w, $3ff4 w, $3ffb w, $3ffe w,

  $3fff w, $3ffe w, $3ffb w, $3ff4 w, $3fec w, $3fe1 w, $3fd3 w, $3fc3 w,
  $3fb1 w, $3f9c w, $3f84 w, $3f6a w, $3f4e w, $3f2f w, $3f0e w, $3eeb w, 
  $3ec5 w, $3e9c w, $3e71 w, $3e44 w, $3e14 w, $3de2 w, $3dae w, $3d77 w, 
  $3d3e w, $3d02 w, $3cc5 w, $3c84 w, $3c42 w, $3bfd w, $3bb6 w, $3b6c w, 
  $3b20 w, $3ad2 w, $3a82 w, $3a2f w, $39da w, $3983 w, $392a w, $38cf w,
  $3871 w, $3811 w, $37af w, $374b w, $36e5 w, $367c w, $3612 w, $35a5 w,
  $3536 w, $34c6 w, $3453 w, $33de w, $3367 w, $32ee w, $3274 w, $31f7 w,
  $3179 w, $30f8 w, $3076 w, $2ff1 w, $2f6b w, $2ee3 w, $2e5a w, $2dce w,
  $2d41 w, $2cb2 w, $2c21 w, $2b8e w, $2afa w, $2a65 w, $29cd w, $2934 w,
  $2899 w, $27fd w, $275f w, $26c0 w, $261f w, $257d w, $24da w, $2434 w,
  $238e w, $22e6 w, $223d w, $2192 w, $20e7 w, $2039 w, $1f8b w, $1edc w,
  $1e2b w, $1d79 w, $1cc6 w, $1c12 w, $1b5d w, $1aa6 w, $19ef w, $1937 w,
  $187d w, $17c3 w, $1708 w, $164c w, $158f w, $14d1 w, $1413 w, $1354 w,
  $1294 w, $11d3 w, $1111 w, $104f w, $0f8c w, $0ec9 w, $0e05 w, $0d41 w,
  $0c7c w, $0bb6 w, $0af1 w, $0a2a w, $0964 w, $089c w, $07d5 w, $070d w,
  $0645 w, $057d w, $04b5 w, $03ec w, $0323 w, $025b w, $0192 w, $00c9 w,

  $0000 w, $ff37 w, $fe6e w, $fda5 w, $fcdd w, $fc14 w, $fb4b w, $fa83 w,
  $f9bb w, $f8f3 w, $f82b w, $f764 w, $f69c w, $f5d6 w, $f50f w, $f44a w,
  $f384 w, $f2bf w, $f1fb w, $f137 w, $f074 w, $efb1 w, $eeef w, $ee2d w,
  $ed6c w, $ecac w, $ebed w, $eb2f w, $ea71 w, $e9b4 w, $e8f8 w, $e83d w,
  $e783 w, $e6c9 w, $e611 w, $e55a w, $e4a3 w, $e3ee w, $e33a w, $e287 w,
  $e1d5 w, $e124 w, $e075 w, $dfc7 w, $df19 w, $de6e w, $ddc3 w, $dd1a w,
  $dc72 w, $dbcc w, $db26 w, $da83 w, $d9e1 w, $d940 w, $d8a1 w, $d803 w,
  $d767 w, $d6cc w, $d633 w, $d59b w, $d506 w, $d472 w, $d3df w, $d34e w,
  $d2bf w, $d232 w, $d1a6 w, $d11d w, $d095 w, $d00f w, $cf8a w, $cf08 w,
  $ce87 w, $ce09 w, $cd8c w, $cd12 w, $cc99 w, $cc22 w, $cbad w, $cb3a w,
  $caca w, $ca5b w, $c9ee w, $c984 w, $c91b w, $c8b5 w, $c851 w, $c7ef w,
  $c78f w, $c731 w, $c6d6 w, $c67d w, $c626 w, $c5d1 w, $c57e w, $c52e w,
  $c4e0 w, $c494 w, $c44a w, $c403 w, $c3be w, $c37c w, $c33b w, $c2fe w,
  $c2c2 w, $c289 w, $c252 w, $c21e w, $c1ec w, $c1bc w, $c18f w, $c164 w,
  $c13b w, $c115 w, $c0f2 w, $c0d1 w, $c0b2 w, $c096 w, $c07c w, $c064 w,
  $c04f w, $c03d w, $c02d w, $c01f w, $c014 w, $c00c w, $c005 w, $c002 w,

  $c001 w, $c002 w, $c005 w, $c00c w, $c014 w, $c01f w, $c02d w, $c03d w,
  $c04f w, $c064 w, $c07c w, $c096 w, $c0b2 w, $c0d1 w, $c0f2 w, $c115 w,
  $c13b w, $c164 w, $c18f w, $c1bc w, $c1ec w, $c21e w, $c252 w, $c289 w,
  $c2c2 w, $c2fe w, $c33b w, $c37c w, $c3be w, $c403 w, $c44a w, $c494 w,
  $c4e0 w, $c52e w, $c57e w, $c5d1 w, $c626 w, $c67d w, $c6d6 w, $c731 w,
  $c78f w, $c7ef w, $c851 w, $c8b5 w, $c91b w, $c984 w, $c9ee w, $ca5b w,
  $caca w, $cb3a w, $cbad w, $cc22 w, $cc99 w, $cd12 w, $cd8c w, $ce09 w,
  $ce88 w, $cf08 w, $cf8a w, $d00f w, $d095 w, $d11d w, $d1a6 w, $d232 w,
  $d2bf w, $d34e w, $d3df w, $d472 w, $d506 w, $d59b w, $d633 w, $d6cc w,
  $d767 w, $d803 w, $d8a1 w, $d940 w, $d9e1 w, $da83 w, $db26 w, $dbcc w,
  $dc72 w, $dd1a w, $ddc3 w, $de6e w, $df19 w, $dfc7 w, $e075 w, $e124 w,
  $e1d5 w, $e287 w, $e33a w, $e3ee w, $e4a3 w, $e55a w, $e611 w, $e6c9 w,
  $e783 w, $e83d w, $e8f8 w, $e9b4 w, $ea71 w, $eb2f w, $ebed w, $ecac w,
  $ed6c w, $ee2d w, $eeef w, $efb1 w, $f074 w, $f137 w, $f1fb w, $f2bf w,
  $f384 w, $f44a w, $f50f w, $f5d6 w, $f69c w, $f764 w, $f82b w, $f8f3 w,
  $f9bb w, $fa83 w, $fb4b w, $fc14 w, $fcdd w, $fda5 w, $fe6e w, $ff37 w,

\ =======================================================================















