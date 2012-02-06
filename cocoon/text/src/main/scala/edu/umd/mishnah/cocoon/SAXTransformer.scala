package edu.umd.mith.mishnah.cocoon

import org.apache.cocoon.transformation.AbstractSAXTransformer
import org.apache.cocoon.xml.AttributesImpl
import org.xml.sax.Attributes

abstract class SAXTransformer(namespaceURI: String) extends AbstractSAXTransformer {
  this.defaultNamespaceURI = namespaceURI

  def startT: (String, String, String, Attributes) => Unit
  def endT: (String, String, String) => Unit

  override def startTransformingElement(uri: String, name: String, raw: String, attr: Attributes) {
    this.startT(uri, name, raw, attr)
  }

  override def endTransformingElement(uri: String, name: String, raw: String) {
    this.endT(uri, name, raw)
  }

  def element(name: String)(body: => Unit) {
    this.element(name, Map.empty[String, String])(body)
  }

  def element(name: String, attrs: Map[String, String])(body: => Unit) {
    val a = new AttributesImpl
    attrs.foreach { case (k, v) => a.addCDATAAttribute("", k, v) }
    sendStartElementEventNS(name, a)
    body
    sendEndElementEventNS(name)     
  }

  def ignoreHooksWrap(body: => Unit) {
    this.ignoreHooksCount += 1
    body
    this.ignoreHooksCount -= 1
  }

  protected trait OutputType {
    def send()
  }
}

