# Digital Mishnah

The Digital Mishnah Project aims to create a digital critical edition of the Mishnah. This will involve transcribing and encoding major (ideally all) manuscript witnesses to the text of the Mishnah, as well as citations in medieval and early modern commentaries.

* Provide digital renditions of manuscript witnesses
* Ability to show witnesses synoptically
* Ability to provide computer-processed collation of variants
* Statistical tools for measuring proximity or distance of witnesses

This is the eXist web application for the project website. The TEI data for the project is located in [this GitHub repository](https://github.com/umd-mith/mishnah-data).

All project repositories:
* [mishnah](https://github.com/umd-mith/mishnah). This repository with an eXist webapp and framework.
* [mishnah-data](https://github.com/umd-mith/mishnah-data). The TEI data for the project.
* [mishnah-align](https://github.com/umd-mith/mishnah-align). NodeJS program for converting Mishnah-Tosefta alignment data from CSV to TEI.
* [mishnah-align-app](https://github.com/umd-mith/mishnah-align-app). React webapp for rendering alingment data between Mishnah and Tosefta using CETEIcean for TEI rendering. The built app is integrated into the eXist framework.

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
