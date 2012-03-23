package uk.co.tfd.symplectic.harvester;

import java.io.IOException;
import java.util.Map.Entry;

public interface ProgressTracker {

	/**
	 * Mark the URL as loaded
	 * @param url
	 */
	void loaded(String url);

	/**
	 * Mark the url as failed
	 * @param url
	 */
	void loadedFailed(String url);

	/**
	 * @param url
	 * @return true if the URL is loaded
	 */
	boolean isLoaded(String url);

	/**
	 * Load
	 * @param relationshipHref
	 * @param loader
	 */
	void toload(String relationshipHref, AtomEntryLoader loader);

	/**
	 * 
	 * @return true if there are items pending
	 */
	boolean hasPending();

	/**
	 * @return the number of items pending
	 */
	int pending();

	/**
	 * @return the next item
	 */
	Entry<String, AtomEntryLoader> next();

	/**
	 * Dumpo all that were loaded
	 */
	void dumpLoaded();

	/**
	 * save everything.
	 * @throws IOException
	 */
	void checkpoint() throws IOException;

}
