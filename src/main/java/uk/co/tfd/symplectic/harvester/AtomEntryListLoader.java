package uk.co.tfd.symplectic.harvester;

import org.w3c.dom.Node;

/**
 * Generic interface to load Atom Entries
 * @author ieb
 *
 */
public interface AtomEntryListLoader {


	
	void addPage(Node item) throws AtomEntryLoadException;



}
