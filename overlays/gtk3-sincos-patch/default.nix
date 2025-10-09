prev: prev.gtk3.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./gtk3-sincos.patch ];
})
