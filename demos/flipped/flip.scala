package edu.umd.mith.mishnah

import org.w3c.dom._
import org.w3c.dom.ls._
import javax.xml.parsers.DocumentBuilderFactory
import scala.collection.JavaConverters._

object Flipper extends App {
  implicit class NodeListWrapper(val nodeList: NodeList) extends AnyVal {
    def toScala = List.tabulate(nodeList.getLength)(nodeList.item)
  }

  val xmlns = "http://www.w3.org/XML/1998/namespace"

  def nextNonWhitespace(node: Node) = {
    var n: Node = node.getNextSibling
    while (
      n != null &&
      n.getNodeType == Node.TEXT_NODE &&
      n.getTextContent.trim.isEmpty
    ) n = n.getNextSibling
    Option(n)
  }

  def getId(node: Node) = {
    val attrs = node.getAttributes
    (0 until attrs.getLength).map(attrs.item).collectFirst {
      case a: Attr if a.isId => a.getValue
    }
  }

  def precedingId(node: Node): String = {
    var n: Node = node
    while (
      n != null &&
      (
        n.getAttributes == null ||
        n.getAttributes.getNamedItem("xml:id") == null
      )
    ) n = n.getPreviousSibling
    Option(n).map(
      _.getAttributes.getNamedItem("xml:id").getNodeValue
    ).getOrElse(precedingId(node.getParentNode))
  }

  val builder = DocumentBuilderFactory.newInstance().newDocumentBuilder()

  val doc = builder.parse("../../data/tei/ref.xml")

  val byId = doc.getElementsByTagName("link").toScala.filterNot(
    _.getAttributes.getNamedItem("target").getNodeValue.startsWith("http://")
  ).groupBy(precedingId)

  val mappings = byId.toSeq.flatMap {
    case (id, links) =>
      links.zipWithIndex.flatMap { case (link: Element, i) =>
        val anchorId = "%s-%04d".format(id, i + 1)
        val parent = link.getParentNode 
        val adjacent = nextNonWhitespace(link).filter(_.getNodeName == "link")

        val targets = List(
          link.getAttributes.getNamedItem("target").getNodeValue
        ) ++ adjacent.map(_.getAttributes.getNamedItem("target").getNodeValue)

        link.setAttribute("xml:id", anchorId)
        link.removeAttribute("target")
        doc.renameNode(link, "http://www.tei-c.org/ns/1.0", "anchor")
        adjacent.foreach(parent.removeChild)

        targets.map {
          case target =>
            target.split("#") match {
              case Array(file, loc) => file -> (loc -> anchorId)
              case Array(loc) => (loc.take(2) + ".xml") -> (loc -> anchorId)
            }
        }
      }
  }.groupBy(_._1)

  val impl = doc.getImplementation.asInstanceOf[DOMImplementationLS]
  val serializer = impl.createLSSerializer()
  val out = serializer.writeToString(doc)
  val writer = new java.io.PrintWriter("data/tei/ref.xml")
  writer.println(out)
  writer.close()

  mappings.foreach {
    case (file, mappings) =>
      val doc = builder.parse("../../data/tei/" + file)

      val elements = (
        doc.getElementsByTagName("damageSpan").toScala ++
        doc.getElementsByTagName("anchor").toScala ++ 
        doc.getElementsByTagName("pb").toScala ++
        doc.getElementsByTagName("milestone").toScala
      ).groupBy(e =>
        Option(
          e.getAttributes.getNamedItem("xml:id")
        ).map(_.getNodeValue).getOrElse("NO ID!")
      )

      mappings.foreach {
        case (_, (id, anchorId)) =>
          val node = elements.get(id).map(_.head)
          node.map { case n: Element => 
            n.setAttribute("corresp", "ref.xml#" + anchorId)
          }.getOrElse(println("MISSING: " + file + " " + id))
      }

      val impl = doc.getImplementation.asInstanceOf[DOMImplementationLS]
      val serializer = impl.createLSSerializer()
      val out = serializer.writeToString(doc)
      val writer = new java.io.PrintWriter("data/tei/" + file)
      writer.println(out)
      writer.close()
  }
}

