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

    mishnah/
        .gitignore                 (Indicates files not under version control)
        incoming/                  (Legacy data)
        data/
            tei/                   (TEI sources)
            odd/                   (TEI ODD specifications)
            xsl/                   (Stylesheets)
            derivative/            (Automatically generated; DO NOT EDIT)
                rng/               (RELAX NG schemas generated from ODD files)
        lib/                       (Unmanaged libraries)
        cocoon/
            pom.xml                (General build configuration)
            text/                  (Block for text transformation logic)
                pom.xml
                src/
                    main/   
                    java/          (Java code)
                    scala/         (Scala code)
                    resources/     (Additional resources, such as sitemaps)
                test/              (Unit tests)
            viewer/                (Block for web application)
                pom.xml
                src/
                    main/   
                    java/          (Java code)
                    scala/         (Scala code)
                    resources/     (Additional resources, such as sitemaps)
                test/              (Unit tests)

(Note that the `data/derivative` directory is only included for the sake of
convenience for transcribers who are not using Roma. Please do not edit these
files directly.)

The following commands will build the web application and run it in Jetty:

    cd cocoon/
    mvn install
    mvn jetty:run

The application will be available at `http://localhost:8888/text/`. You can
also build a `war` file that can be run in any servlet container by entering
the following:

    cd cocoon/
    mvn install
    mvn package

The file will be created in `cocoon/viewer/target/`.

