package uk.co.tfd.symplectic.harvester;

import org.vivoweb.harvester.util.repo.RecordHandler;
import org.w3c.dom.Node;

public class APIObjects implements AtomEntryLoader, AtomEntryListLoader {

	private RecordHandler rh;
	private String type;
	private ProgressTracker tracker;
	private String elementType;

	public APIObjects(RecordHandler rh, String pluralType,
			ProgressTracker tracker) {
		this.rh = rh;
		this.type = pluralType;
		this.elementType = pluralType.substring(0, type.length() - 1);
		this.tracker = tracker;
	}

	public String getType() {
		return type;
	}



	@Override
	public void loadEntry(String url) throws AtomEntryLoadException {
		try {
			PageConverter pageConverter = new PageConverter(this);
			pageConverter.addAll(url);
			tracker.loaded(url);
		} catch (Exception e) {
			tracker.loadedFailed(url);
			throw new AtomEntryLoadException(e.getMessage(), e);
		}
	}

	@Override
	public void addPage(Node entry) throws AtomEntryLoadException {
		String category = XmlAide
				.findAttribute(entry, "api:object", "category");
		if (elementType.equals(category)) {
			Node apiObject = XmlAide.findNode(entry, "api:object");
			String userUrl = XmlAide.findAttribute(apiObject, "href");
			tracker.toload(userUrl, new APIObject(rh, elementType, tracker));

			String relationships = XmlAide.findAttribute(apiObject,
					"api:relationships", "href");
			if (relationships != null) {
				tracker.toload(relationships, new APIRelationships(rh, tracker));
			}
		}
	}

}
