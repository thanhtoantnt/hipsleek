(lang dune 3.14)

(using menhir 3.0)

(name hipsleek)
(generate_opam_files true)

(source
 (github hipsleek/hipsleek))

(authors "HIP/SLEEK contributors")

(maintainers "hip.sleek@gmail.com")
(license MIT)

(package
 (name hipsleek)
 (synopsis "Separation logic verifier")
 (description "The HIP/SLEEK separation logic verifier")
 (depends
  (fileutils (>= 0.6.4))
  (ocamlgraph (>= 2.1.0))
  (camlp5 (>= 8.00))
  (camlp-streams (>= 5.0.1))
  num
  (ppx_expect (>= v0.15.1))
  (ppx_deriving (>= 6.0.3))
  (visitors (>= 20210608))
  (menhir (>= 20220210))
  dune
  (cppo :build)
))

