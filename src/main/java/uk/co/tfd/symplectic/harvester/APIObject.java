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


/**
 * This class represents an api:object in 2 forms. A Atom feed containing a list of pages, and the page themselves
 * @author ieb
 *
 */
public class APIObject implements AtomEntryLoader, RecordStreamOrigin {

	private static final Logger LOGGER = LoggerFactory
			.getLogger(APIObject.class);
	private OutputStreamWriter osWriter;
	private RecordHandler rh;
	private String type;
	private Map<String, AtomEntryLoader> toLoad;
	private Set<String> loaded;
	private boolean list;
	protected static XMLRecordOutputStream baseXMLROS = new XMLRecordOutputStream(
			new String[] { "api:object" },
			"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<object xmlns=\"http://www.symplectic.co.uk/vivo/\" xmlns:api=\"http://www.symplectic.co.uk/publications/api\">\n",
			"</object>", ".*?id=\"(.*?)\".*?", null);

	public APIObject(RecordHandler rh, String type,
			Map<String, AtomEntryLoader> toLoad, Set<String> loaded, boolean list) {
		this.rh = rh;
		this.type = type;
		this.toLoad = toLoad;
		this.loaded = loaded;
		this.list = list;
	}


	public void loadEntry(Node entry) throws AtomEntryLoadException {
		String category = XmlAide
				.findAttribute(entry, "api:object", "category");
		if (type.equals(category)) {
			Node apiObject = XmlAide.findNode(entry, "api:object");
			try {
				String userUrl = XmlAide.findAttribute(apiObject, "href");
				if (!loaded.contains(userUrl)) {
					Document doc = XmlAide.loadXmlDocument(userUrl);
					Element user = (Element) doc.getElementsByTagName(
							"api:object").item(0);
					user.setAttribute("uriref", XmlAide.hash(userUrl));
					String userAsString = XmlAide.getXmlFromNode(user);
					if (osWriter == null) {
						osWriter = new OutputStreamWriter(baseXMLROS.clone()
								.setRso(this), "UTF-8");
					}
					osWriter.write(userAsString);
					// file close statements. Warning, not closing the file will
					// leave incomplete xml files and break the translate method
					osWriter.write("\n");
					osWriter.flush();
					loaded.add(userUrl);
					toLoad.remove(userUrl);
				}
			} catch (Exception e) {
				throw new AtomEntryLoadException(e.getMessage(), e);
			}
			String relationships = XmlAide.findAttribute(apiObject,
					"api:relationships", "href");
			if (!loaded.contains(relationships)
					&& !toLoad.containsKey(relationships)) {
				toLoad.put(relationships, new APIRelationship(rh, toLoad,
						loaded, true));
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
			toLoad.put(url, new APIObject(rh, type, toLoad, loaded, false));
		}
	}

}
