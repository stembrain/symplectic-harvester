package uk.co.tfd.symplectic.harvester;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.Map;
import java.util.Set;

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
	private Map<String, AtomEntryLoader> toLoad;
	private Set<String> loaded;
	private boolean list;
	protected static XMLRecordOutputStream baseXMLROS = new XMLRecordOutputStream(
			new String[] { "api:relationship" },
			"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<relationship xmlns=\"http://www.symplectic.co.uk/vivo/\" xmlns:api=\"http://www.symplectic.co.uk/publications/api\">\n",
			"</relationship>", ".*?id=\"(.*?)\".*?", null);

	public APIRelationship(RecordHandler rh,
			Map<String, AtomEntryLoader> toLoad, Set<String> loaded, boolean list) {
		this.rh = rh;
		this.type = "relationship";
		this.toLoad = toLoad;
		this.loaded = loaded;
		this.list = list;
	}
	
	public String getType() {
		return type;
	}


	@Override
	public void loadEntry(Node item) throws AtomEntryLoadException {
		String relationshipHref = XmlAide.findAttribute(item,
				"api:relationship", "href");
		if (relationshipHref != null) {
			if (!loaded.contains(relationshipHref)) {
				try {
					Document doc = XmlAide.loadXmlDocument(relationshipHref);
					NodeList relationships = doc
							.getElementsByTagName("api:relationship");
					for (int i = 0; i < relationships.getLength(); i++) {
						Element relationship = (Element) relationships.item(i);
						relationship.setAttribute("uriref",
								XmlAide.hash(relationshipHref));
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
					loaded.add(relationshipHref);
					toLoad.remove(relationshipHref);
				} catch (Exception e) {
					throw new AtomEntryLoadException(e.getMessage(), e);
				}
			}
		}
		// load api:related/api:object@href
		Node relationship = XmlAide.findNode(item, "api:relationship");
		if ( relationship != null ) {
			Node object = XmlAide.findNode(item, "api:object");
			if ( object != null ) {
				String category = XmlAide.findAttribute(object, "category");
				String href = XmlAide.findAttribute(object, "href");
				if ( category != null && href != null && !loaded.contains(href) && !toLoad.containsKey(href)) {
					toLoad.put(href, new APIObject(rh, category, toLoad, loaded, false));
				}
				String relationshipsHref = XmlAide.findAttribute(object, "api:relationships",  "href");
				if ( relationshipsHref != null && !loaded.contains(relationshipsHref) && !toLoad.containsKey(relationshipsHref)) {
					toLoad.put(href, new APIRelationship(rh, toLoad, loaded, true));
				}
			}
		}

	}

	@Override
	public void writeRecord(String id, String data) throws IOException {
		LOGGER.info("Adding Record " + type + id);
		rh.addRecord(type + id, data, getClass());
	}

	@Override
	public boolean isList() {
		return list;
	}

	@Override
	public void addPage(String url) {
		if ( !loaded.contains(url) && !toLoad.containsKey(url)) {
			toLoad.put(url, new APIRelationship(rh, toLoad, loaded, false));
		}
		
	}

}
