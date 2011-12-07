package edu.umd.mith.util.xml

import java.io.File

import javax.xml.XMLConstants
import javax.xml.transform.stream.StreamSource
import javax.xml.validation.SchemaFactory
import javax.xml.validation.Validator

import org.xml.sax.SAXException

import org.custommonkey.xmlunit._
//import org.custommonkey.xmlunit.jaxp13.Validator

import org.junit.Test
import org.junit.Assert._

abstract class ValidatingTestBase(name: String) extends XMLTestCase(name) {
  val schema: String
  val docs: Seq[String]

  lazy val validator = SchemaFactory.newInstance(XMLConstants.RELAXNG_NS_URI)
    .newSchema(new StreamSource(this.getClass.getResourceAsStream(this.schema)))
    .newValidator

  override def setUp() {
    System.setProperty(classOf[SchemaFactory].getName() + ":" + XMLConstants.RELAXNG_NS_URI,
      "com.thaiopensource.relaxng.jaxp.XMLSyntaxSchemaFactory")
    XMLUnit.setControlParser("org.apache.xerces.jaxp.DocumentBuilderFactoryImpl")
    XMLUnit.setSAXParserFactory("org.apache.xerces.jaxp.SAXParserFactoryImpl")
    XMLUnit.setTransformerFactory("net.sf.saxon.TransformerFactoryImpl")
    //this.validator.addSchemaSource(new StreamSource(this.getClass.getResourceAsStream(this.schema)))
  }

  @Test def testValidate() {
    this.docs.foreach { doc =>
      val result = try {
        Right(this.validator.validate(new StreamSource(this.getClass.getResourceAsStream(doc))))
      } catch {
        case e: SAXException => Left(e)
      }
      assertTrue(
        ".%s is not valid: %s".format(doc, result.left.toOption.map(_.getMessage).getOrElse("")),
        result.isRight
      )
    }
  }
}

