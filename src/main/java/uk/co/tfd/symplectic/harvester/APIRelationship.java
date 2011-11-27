package uk.co.tfd.symplectic.harvester;

import java.io.IOException;
import java.io.OutputStreamWriter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.vivoweb.harvester.util.repo.RecordHandler;
import org.vivoweb.harvester.util.repo.RecordStreamOrigin;
import org.vivoweb.harvester.util.repo.XMLRecordOutputStream;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class APIRelationship implements AtomEntryLoader, RecordStreamOrigin {

	private static final Logger LOGGER = LoggerFactory
			.getLogger(APIRelationship.class);
	private OutputStreamWriter osWriter;
	private RecordHandler rh;
	private String type;
	private ProgressTracker tracker;
	protected static XMLRecordOutputStream baseXMLROS = new XMLRecordOutputStream(
			new String[] { "api:relationship" },
			"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<relationship xmlns=\"http://www.symplectic.co.uk/vivo/\" xmlns:api=\"http://www.symplectic.co.uk/publications/api\">\n",
			"</relationship>", ".*?id=\"(.*?)\".*?", null);

	public APIRelationship(RecordHandler rh,
			ProgressTracker tracker) {
		this.rh = rh;
		this.type = "relationship";
		this.tracker = tracker;
	}
	
	public String getType() {
		return type;
	}


	@Override
	public void writeRecord(String id, String data) throws IOException {
		LOGGER.info("Adding Record " + type + id);
		rh.addRecord(type + id, data, getClass());
	}


	
	@Override
	public void loadEntry(String url) throws AtomEntryLoadException {
		try {
			Document doc = XmlAide.loadXmlDocument(url);
			NodeList relationships = doc
					.getElementsByTagName("api:relationship");
			for (int i = 0; i < relationships.getLength(); i++) {
				Element relationship = (Element) relationships.item(i);
				relationship.setAttribute("uriref",
						XmlAide.hash(url));
				String userAsString = XmlAide
						.getXmlFromNode(relationship);
				if (osWriter == null) {
					osWriter = new OutputStreamWriter(baseXMLROS
							.clone().setRso(this), "UTF-8");
				}
				osWriter.write(userAsString);
				// file close statements. Warning, not closing the file
				// will
				// leave incomplete xml files and break the translate
				// method
				osWriter.write("\n");
				osWriter.flush();

			}
			tracker.loaded(url);
		} catch (Exception e) {
			throw new AtomEntryLoadException(e.getMessage(), e);
		}
	}


}
