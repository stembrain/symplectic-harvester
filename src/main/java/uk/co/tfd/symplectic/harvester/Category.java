package uk.co.tfd.symplectic.harvester;

import java.io.IOException;
import java.net.MalformedURLException;
import java.security.NoSuchAlgorithmException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactoryConfigurationError;

import org.w3c.dom.DOMException;
import org.xml.sax.SAXException;

public interface Category {

	boolean handles(String category);

	void loadCategory(String nodeValue) throws MalformedURLException, SAXException, IOException, ParserConfigurationException, DOMException, NoSuchAlgorithmException, TransformerFactoryConfigurationError, TransformerException;

	void loadRelationships(String findAttribute);

	String getId();

}
