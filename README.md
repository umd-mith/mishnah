Digital Mishnah
===============

The Digital Mishnah Project aims to create a digital critical edition of the
Mishnah. This will involve transcribing and encoding major (ideally all)
manuscript witnesses to the text of the Mishnah, as well as citations in
medieval and early modern commentaries. The project is in its initial phases
and is using Bava Metsia Ch. 2 to develop a proof of concept. The goals for
this proof of concept are to:

* Provide digital renditions of manuscript witnesses
* Ability to show witnesses synoptically
* Ability to provide computer-processed collation of variants
* Statistical tools for measuring proximity or distance of witnesses

Directory structure
-------------------

This repository contains (or will contain) the following files and
directories:

    .gitignore         (Indicates files not under version control)
    incoming/          (Legacy data)
    data/
        tei/           (TEI sources)
        odd/           (TEI ODD specifications)
        rng/           (RELAX NG schemas generated from ODD files; DO NOT EDIT)
        xsl/           (Stylesheets)
    src/
        main/   
            java/      (Java code)
            scala/     (Scala code)
            resources/ (Additional project resources such as Cocoon sitemaps)
        test/          (Unit tests)
    lib/               (Unmanaged libraries)

