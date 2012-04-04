/*
 *  Copyright (c) 2011 Ian Boston for Symplectic, relicensed under the AGPL license in repository https://github.com/ieb/symplectic-harvester
 *  Please see the LICENSE file for more details
 */
package uk.co.tfd.symplectic.harvester;

import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.commons.codec.binary.Base64;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.vivoweb.harvester.util.WebAide;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

public class XmlAide {
	private static final Logger LOGGER = LoggerFactory.getLogger(XmlAide.class);

	public static Document loadXmlDocument(String url)
			throws MalformedURLException, SAXException, IOException,
			ParserConfigurationException {
		DocumentBuilderFactory docBuildFactory = DocumentBuilderFactory
				.newInstance();
		docBuildFactory.setIgnoringComments(true);
		
		String xmlDoc = null;
		if ( url.startsWith("http") ) {
		    xmlDoc = ConcurrentHttpFetch.get(url);
		} else {
		    xmlDoc = WebAide.getURLContents(url);
		}
		// doing this fixes makes it work with UTF8 chars
		return docBuildFactory.newDocumentBuilder().parse(
				new InputSource(new StringReader(xmlDoc)));
	}

	public static String findAttribute(Node n, String elementName,
			String attrName) {
		NodeList nl = n.getChildNodes();
		for (int i = 0; i < nl.getLength(); i++) {
			Node cn = nl.item(i);
			if (elementName.equals(cn.getNodeName())) {
				Node av = cn.getAttributes().getNamedItem(attrName);
				if (av == null) {
					return null;
				}
				return av.getNodeValue();
			}
		}
		return null;
	}

	public static String findAttribute(Node n, String attrName) {
		Node av = n.getAttributes().getNamedItem(attrName);
		if (av == null) {
			return null;
		}
		return av.getNodeValue();
	}

	public static Node findNode(Node n, String elementName) {
		NodeList nl = n.getChildNodes();
		for (int i = 0; i < nl.getLength(); i++) {
			Node cn = nl.item(i);
			if (elementName.equals(cn.getNodeName())) {
				return cn;
			}
		}
		return null;
	}

	public static String hash(String userUrl)
			throws UnsupportedEncodingException, NoSuchAlgorithmException {
		MessageDigest md = MessageDigest.getInstance("SHA1");
		return Base64.encodeBase64URLSafeString(md.digest(userUrl
				.getBytes("UTF-8")));
	}

	public static String getXmlFromNode(Node node)
			throws TransformerFactoryConfigurationError, TransformerException {
		StringWriter writer = new StringWriter();
		Transformer transformer = TransformerFactory.newInstance()
				.newTransformer();
		transformer.transform(new DOMSource(node), new StreamResult(writer));
		String s = writer.toString().trim();
		if (s.startsWith("<?xml")) {
			int i = s.indexOf(">");
			s = s.substring(i + 1);
		}
		return s;
	}

	public static String getNodeValue(Node n, String elementName) {
		Node element = findNode(n, elementName);
		LOGGER.info("Find Node base:{} elementName:{} found:{} ",new Object[]{n, elementName, element});
		if (element != null) {
			LOGGER.info("Value {} ", element.getTextContent());
			return element.getTextContent();
		}
		return null;
	}
}
