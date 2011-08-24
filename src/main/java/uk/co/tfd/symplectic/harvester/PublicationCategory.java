package uk.co.tfd.symplectic.harvester;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.net.MalformedURLException;
import java.security.NoSuchAlgorithmException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactoryConfigurationError;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.vivoweb.harvester.util.repo.RecordHandler;
import org.vivoweb.harvester.util.repo.RecordStreamOrigin;
import org.vivoweb.harvester.util.repo.XMLRecordOutputStream;
import org.w3c.dom.DOMException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.xml.sax.SAXException;

public class PublicationCategory implements Category, RecordStreamOrigin   {

	
	private static final Logger LOGGER = LoggerFactory.getLogger(PublicationCategory.class);
	private OutputStreamWriter osWriter;
	private RecordHandler rh;
	protected static XMLRecordOutputStream baseXMLROS = new XMLRecordOutputStream(
			new String[] { "api:object" },
			"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<object xmlns=\"http://www.symplectic.co.uk/vivo/\" xmlns:api=\"http://www.symplectic.co.uk/publications/api\">\n",
			"</object>", ".*?id=\"(.*?)\".*?", null);
	
	public PublicationCategory(RecordHandler rh) {
		this.rh = rh;
	}
	@Override
	public boolean handles(String category) {		
		return getId().equals(category);
	}
	@Override
	public String getId() {
		return "publication";
	}


	@Override
	public void loadCategory(String userUrl) throws MalformedURLException, SAXException, IOException, ParserConfigurationException, DOMException, NoSuchAlgorithmException, TransformerFactoryConfigurationError, TransformerException {
		Document doc = XmlAide.loadXmlDocument(userUrl);
		Element user = (Element) doc.getElementsByTagName("api:object").item(0);
		user.setAttribute("uriref", XmlAide.hash(userUrl));
		String userAsString = XmlAide.getXmlFromNode(user);
		if (osWriter == null) {
			osWriter = new OutputStreamWriter(baseXMLROS.clone().setRso(this),
					"UTF-8");
		}
		osWriter.write(userAsString);
		//file close statements.  Warning, not closing the file will leave incomplete xml files and break the translate method
		osWriter.write("\n");
		osWriter.flush();
	}

	@Override
	public void loadRelationships(String findAttribute) {
	}
	@Override
	public void writeRecord(String id, String data) throws IOException {
		LOGGER.info("Adding Record " + getId()+id);
		rh.addRecord(getId()+id, data, getClass());
	}
	



}
