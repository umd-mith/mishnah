package edu.umd.mith.mishnah.cocoon

import scala.collection.mutable.Buffer
import scala.collection.JavaConversions._
import org.xml.sax.Attributes

import eu.interedition.collatex2.implementation.CollateXEngine
import eu.interedition.collatex2.implementation.input.tokenization.WhitespaceAndPunctuationTokenizer
import eu.interedition.collatex2.interfaces._

class CollateXTransformer extends SAXTransformer("http://interedition.eu/collatex/ns/1.0") {
  val TEI_NS = "http://www.tei-c.org/ns/1.0"
  val COLLATEX_NS = "http://interedition.eu/collatex/ns/1.0"

  private val engine = new CollateXEngine
  private val witnesses = Buffer.empty[IWitness]
  private var sigil: String = _
  private var output: OutputType = _

  engine.setTokenizer(new WhitespaceAndPunctuationTokenizer)

  def startT = {
    case (_, "collation", _, attr) => {
      output = Option(attr.getValue(defaultNamespaceURI, "outputType")).map(_.trim.toLowerCase) match {
        case Some(outputType) if outputType == "tei" => AlignmentTable()
        case _ => AlignmentTable()
      }
      sigil = null
      witnesses.clear()
    }
    case (_, "witness", _, attr) => {
      sigil = Option(attr.getValue("sigil")).getOrElse("w" + (witnesses.size + 1))
      startTextRecording()
    }
  }

  def endT = {
    case (_, "collation", _) => this.ignoreHooksWrap(output.send())
    case (_, "witness", _) => this.witnesses += this.engine.createWitness(sigil, endTextRecording())
  }

  private case class AlignmentTable() extends OutputType {
    def send() {
      element("alignment") {
        //if (!witnesses.isEmpty) {
          val table = engine.align(witnesses.toArray[IWitness]: _*)
          table.getRows.foreach { row =>
            element("row", Map("sigil" -> row.getSigil)) {
              row.foreach { cell =>
                element("cell", Map("state" -> cell.getColumn.getState.toString.toLowerCase)) {
                  if (!cell.isEmpty) {
                    sendTextEvent(cell.getToken.getContent)
                  }
                }
              }
            }
          }
        //}
      }
    }
  }
}

