package edu.umd.mith.mishnah.xml

import edu.umd.mith.util.xml.ValidatingTestBase

class ValidatingTest(name: String) extends ValidatingTestBase(name) {
  val schema = "/derivatives/"
  val docs = Seq.empty[String]
}

