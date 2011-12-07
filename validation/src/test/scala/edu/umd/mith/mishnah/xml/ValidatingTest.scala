package edu.umd.mith.mishnah.xml

import edu.umd.mith.util.xml.ValidatingTestBase

class ValidatingTest(name: String) extends ValidatingTestBase(name) {
  val schema = "/derivative/rng/mishnah-reference.rng"
  val docs = Seq("/tei/ref.xml")
}

