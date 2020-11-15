# Digital Mishnah

The Digital Mishnah Project aims to create a digital critical edition of the Mishnah. This will involve transcribing and encoding major (ideally all) manuscript witnesses to the text of the Mishnah, as well as citations in medieval and early modern commentaries.

* Provide digital renditions of manuscript witnesses
* Ability to show witnesses synoptically
* Ability to provide computer-processed collation of variants
* Statistical tools for measuring proximity or distance of witnesses

This is the eXist web application for the project website. The TEI data for the project is located in [this GitHub repository](https://github.com/umd-mith/mishnah-data).

# Installation

Pre-requisites:

 * eXist 3.6.1 or higher
 * nodeJS for compiling JavaScript front-end code

To install and upload webapp and data to exist run:

`ant`

# Suggested workflow for eXist and GitHub

To commit changes to GitHub:

* use the eXist IDE to synchronize code to your clone
* commit and push changes to GitHub

To get changes from GitHub:

* pull from GitHub
* run `ant` to upload to eXist (NB the existing webapp will be replaced)
