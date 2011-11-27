package uk.co.tfd.symplectic.harvester;

import org.vivoweb.harvester.util.repo.RecordHandler;
import org.w3c.dom.Node;

public class APIRelationships implements AtomEntryLoader, AtomEntryListLoader {

	private RecordHandler rh;
	private String type;
	private ProgressTracker tracker;

	public APIRelationships(RecordHandler rh,
			ProgressTracker tracker) {
		this.rh = rh;
		this.type = "relationships";
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
	public void addPage(Node item) throws AtomEntryLoadException {
		String relationshipHref = XmlAide.findAttribute(item,
				"api:relationship", "href");
		if (relationshipHref != null) {
			tracker.toload(relationshipHref, new APIRelationship(rh, tracker));
		}
		// load api:related/api:object@href
		Node relationship = XmlAide.findNode(item, "api:relationship");
		if ( relationship != null ) {
			Node object = XmlAide.findNode(item, "api:object");
			if ( object != null ) {
				String category = XmlAide.findAttribute(object, "category");
				String href = XmlAide.findAttribute(object, "href");
				if ( category != null && href != null ) {
					tracker.toload(href, new APIObject(rh, category, tracker));
				}
				String relationshipsHref = XmlAide.findAttribute(object, "api:relationships",  "href");
				if ( relationshipsHref != null  ) {
					tracker.toload(href, new APIRelationship(rh, tracker));
				}
			}
		}
	}

}
