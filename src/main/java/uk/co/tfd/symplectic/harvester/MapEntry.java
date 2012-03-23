package uk.co.tfd.symplectic.harvester;

import java.util.Map.Entry;

public class MapEntry implements Entry<String, AtomEntryLoader> {

	private String url;
	private AtomEntryLoader loader;

	public MapEntry(String url, AtomEntryLoader loader) {
		this.url = url;
		this.loader = loader;
	}

	@Override
	public String getKey() {
		return url;
	}

	@Override
	public AtomEntryLoader getValue() {
		return loader;
	}

	@Override
	public AtomEntryLoader setValue(AtomEntryLoader arg0) {
		AtomEntryLoader l = loader;
		loader = arg0;
		return l;

	}

}
